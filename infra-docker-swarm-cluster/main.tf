
resource "azurerm_resource_group" "default" {
  name     = "${var.name_prefix}-resource-group"
  location = var.location
}

resource "azurerm_virtual_network" "default" {
  name                = "${var.name_prefix}-VN"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_subnet" "master" {
  name                 = "${var.name_prefix}-master-subnet"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "worker" {
  name                 = "${var.name_prefix}-worker-subnet"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "master" {
  count               = var.master_vm_count
  name                = "${var.name_prefix}-public-ip-master-${count.index}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "worker" {
  count               = var.worker_vm_count
  name                = "${var.name_prefix}-public-ip-worker-${count.index}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "default" {
  name                = "${var.name_prefix}-NSG"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_outbound_https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
}

resource "azurerm_network_interface" "master" {
  count               = var.master_vm_count
  name                = "${var.name_prefix}-NIC-master-${count.index}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.master.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.master[count.index].id
  }
}

resource "azurerm_network_interface_security_group_association" "master" {
  count                     = var.master_vm_count
  network_interface_id      = azurerm_network_interface.master[count.index].id
  network_security_group_id = azurerm_network_security_group.default.id
}

resource "azurerm_network_interface" "worker" {
  count               = var.worker_vm_count
  name                = "${var.name_prefix}-NIC-worker-${count.index}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.worker.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.worker[count.index].id
  }
}

resource "azurerm_network_interface_security_group_association" "worker" {
  count                     = var.worker_vm_count
  network_interface_id      = azurerm_network_interface.worker[count.index].id
  network_security_group_id = azurerm_network_security_group.default.id
}

resource "azurerm_linux_virtual_machine" "master" {
  count               = var.master_vm_count
  name                = "${var.name_prefix}-master-VM-${count.index}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  size                = var.master_size
  admin_username      = var.ssh_username

  network_interface_ids = [azurerm_network_interface.master[count.index].id]

  admin_ssh_key {
    username   = var.ssh_username
    public_key = file("${var.ssh_public_key_file}")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://get.docker.com | sh",
      "sudo sysctl -w vm.max_map_count=262144" #Increase max_map_count for Wazuh indexer to work properly
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_username
      private_key = file(var.ssh_private_key_file)
      host        = azurerm_public_ip.master[count.index].ip_address
    }
  }
}

resource "azurerm_linux_virtual_machine" "worker" {
  count               = var.worker_vm_count
  name                = "${var.name_prefix}-worker-VM-${count.index}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  size                = var.worker_size
  admin_username      = var.ssh_username

  network_interface_ids = [azurerm_network_interface.worker[count.index].id]

  admin_ssh_key {
    username   = var.ssh_username
    public_key = file("${var.ssh_public_key_file}")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://get.docker.com | sh",
      "pip3 install jsondiff",
      "sudo sysctl -w vm.max_map_count=262144" #Increase max_map_count for Wazuh indexer to work properly
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_username
      private_key = file(var.ssh_private_key_file)
      host        = azurerm_public_ip.worker[count.index].ip_address
    }
  }
}