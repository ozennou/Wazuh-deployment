## GitHub actions self-hosted runner:

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

resource "azurerm_subnet" "default" {
  name                 = "${var.name_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "default" {
  name                = "${var.name_prefix}-public-ip"
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

  security_rule { # Used for the communication between the runner & Github
    name                       = "allow_outbound_https"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
}

resource "azurerm_network_interface" "default" {
  name                = "${var.name_prefix}-NIC"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.default.id
  }
}

resource "azurerm_network_interface_security_group_association" "default" {
  network_interface_id      = azurerm_network_interface.default.id
  network_security_group_id = azurerm_network_security_group.default.id
}

resource "azurerm_linux_virtual_machine" "default" {
  name                = "${var.name_prefix}-VM"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  size                = "Standard_D4ds_v4" ## 16 GB ram & 4 vCPU
  admin_username      = var.ssh_username

  network_interface_ids = [azurerm_network_interface.default.id]

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
}