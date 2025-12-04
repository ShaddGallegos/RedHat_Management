#!/bin/bash

# Set the roles path explicitly and run the complete deployment
export ANSIBLE_ROLES_PATH="./roles"
ansible-playbook -i inventory playbooks/satellite_complete_deployment.yml