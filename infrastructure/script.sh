#!/bin/bash

set -e

terraform init
terraform validate
terraform apply -auto-approve

IP_ADDRESS=$(terraform output public_ip)

echo "
[runner]
server1 ansible_host=$IP_ADDRESS ansible_user=$TF_VAR_ssh_username ansible_ssh_private_key_file=$ssh_private_key_file ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
" > inventory.ini

while ! ansible all -i inventory.ini -m ping 2>/dev/null 1>/dev/null; do
    echo "Waiting for server..."
    sleep 2
done

ansible-playbook -i inventory.ini github-runner.yml