# Devops Project

## Project Description
This project showcases the use of DevOps tools like Ansible, Docker and Jenkins. The project includes ansible scripts to deploy these 2 projects:
* [Backend Spring Project](https://github.com/Kostas-Xafis/Dtst-2.git)
* [Frontend Application Project](https://github.com/Kostas-Xafis/DtstFrontendProject.git)

## Project Prerequisites

`ansible`, `ansible-playbook` and `ansible-vault` must be installed on the machine that will run the ansible scripts.

> [!IMPORTANT]
> 1. **You will need to have setup the ssh config of your machine to connect to the appropriate virtual machines, each specified in [hosts.yaml](https://github.com/Kostas-Xafis/ansible-devops/blob/main/hosts.yaml).**
>
> 2. **You'll will also need to decrypty the encrypted files with ansible vault, either at runtime or beforehand.**
>  

# Deployments

## Project Deployment with Ansible Playbooks

```bash
# Clone the repository
git clone https://github.com/Kostas-Xafis/ansible-devops.git

# Change directory to the cloned repository
cd ansible-devops

# Optional - Decrypt the encrypted files
ansible-vault decrypt host_vars/* 

# Deploy the Postgres project
ansible-playbook -l gcloud-db-server playbooks/postgres.yaml [--ask-vault-pass]

# Deploy the Backend Spring project
ansible-playbook -l gcloud-backend-server playbooks/spring.yaml [--ask-vault-pass]

# Deploy the Frontend project
ansible-playbook -l gcloud-frontend-server playbooks/website.yaml [--ask-vault-pass] -e "backend_server_host={YOUR_BACKEND_IP}"

# Congratulations! You have successfully deployed the projects with Ansible!
```
  
## Project Deployment with Ansible Playbooks in Docker Containers

```bash
# Clone the repository
git clone https://github.com/Kostas-Xafis/ansible-devops.git

# Change directory to the cloned repository
cd ansible-devops

# Optional - Decrypt the encrypted files
ansible-vault decrypt playbooks/docker/env/*

# Deploy the Backend Spring project
ansible-playbook -l docker-backend-server playbooks/docker.yaml [--ask-vault-pass] -e docker_services='pgdb spring'

# Deploy the Frontend project
ansible-playbook -l docker-server playbooks/docker.yaml [--ask-vault-pass] -e "docker_services='frontend' backend_server_host='{YOUR_BACKEND_IP}'"

# Congratulations! You have successfully deployed the projects with Ansible in Docker containers!
```
