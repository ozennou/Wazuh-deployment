### Infrastructure of docker swarm cluster

This directory contains the provisioning source code of docker swarm cluster VMs in Azure using Terraform.

#### manipulate the size and the number of masters & workers nodes

``` HCL
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

```

#### Required Environment Variables

Before running the terraform, make sure to export the following environment variables:
``` bash
export TF_VAR_ssh_username=<your-ssh-username>
export TF_VAR_ssh_public_key_file=<path-to-public-key>
export ARM_SUBSCRIPTION_ID=<your-azure-subscription-id>
export ARM_TENANT_ID=<your-azure-tenant-id>
export ARM_CLIENT_ID=<your-azure-client-id>
export ARM_CLIENT_SECRET=<your-azure-client-secret>
```