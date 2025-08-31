variable "name_prefix" {
  description = "name prefix for the name resources"
  default     = "wazuh-docker-swarm-cluster"
}

variable "location" {
  description = "resources location"
  default     = "Spain Central"
}

variable "ssh_username" {
  sensitive = true
}

variable "ssh_public_key_file" {
  sensitive = true
}

variable "ssh_private_key_file" {
  sensitive = true
}

variable "master_size" {
  default = "Standard_D8as_v5" ## 16 GB ram & 4 vCPU
}

variable "worker_size" {
  default = "Standard_D8as_v5" ## 16 GB ram & 4 vCPU
}

variable "master_vm_count" {
  type    = number
  default = 3
}

variable "worker_vm_count" {
  type    = number
  default = 3
}
