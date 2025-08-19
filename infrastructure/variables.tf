variable "name_prefix" {
  description = "name prefix for the name resources"
  default     = "wazuh-deploy-challenge"
}

variable "location" {
  description = "resources location"
  default     = "West Europe"
}

variable "ssh_username" {
  sensitive = true
}

variable "ssh_public_key_file" {
  sensitive = true
}