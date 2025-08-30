# Wazuh-deplyment-challenge
Deployment of Wazuh stack in docker swarm cluster using Terraform, Ansible and Github Actions.

> [!NOTE]  
> I’d like to inform you that I included some additional topics beyond the main subject, example of infra directories, because I believe they add value to the challenge. Thank you for your understanding.

### Completed Tasks
- [x] Infrastructure for Github self-hosted runner in Azure using Terraform & Ansible (additional).
- [x] Infrastructure for docker swarm cluster with multiple masters & workers in Azure using Terraform (additional + bonus).
- [x] Configure Wazuh stack multi node(with bonus):
    - Wazuh dashboard: ≥2 replicas behind Nginx as load balancer.
    - Wazuh manager: clustered deployment (master/worker).
    - Wazuh indexer (I’m facing multiple issues configuring ≥3 data nodes, and due to limited time I’m skipping it).
    - Nginx as reverse proxy & load balancer for Wazuh dasboard replicas.
- [x] Add health probe (docker healthchecks) for wazuh stack(indexer, manager & dashboard) and nginx. 
- [x] Configure generator script for generating self signed certificates for Wazuh stack and Nginx.
- [x] Develop Ansible playbook:
    - playbooks/deploy.yml:
        - ensure that docker swarm is initialized and list the nodes.
        - copy the wazuh stack deployment code to docker swarm leader manager.
        - run the self signed certificates script in docker swarm leader manager.
        - finally deploy Wazuh stack in the swarm cluster.
    - playbooks/teardown.yml
        - remove wazuh stack deployment from docker swarm cluster.
