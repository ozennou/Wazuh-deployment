### Infrastructure

This directory contains the configuration to set up a self-hosted GitHub Actions runner on Azure using Terraform and Ansible.

### Usage

```bash
./script.sh
```
### Required Environment Variables

Before running the script, make sure to export the following environment variables:
``` bash
export TF_VAR_ssh_username=<your-ssh-username>
export TF_VAR_ssh_public_key_file=<path-to-public-key>
export ssh_private_key_file=<path-to-private-key>
export ARM_SUBSCRIPTION_ID=<your-azure-subscription-id>
export ARM_TENANT_ID=<your-azure-tenant-id>
export ARM_CLIENT_ID=<your-azure-client-id>
export ARM_CLIENT_SECRET=<your-azure-client-secret>
export GITHUB_RUNNER_TOKEN=<your-github-runner-token>
```