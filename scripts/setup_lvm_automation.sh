#!/bin/bash
# Setup script for libvirt LVM automation

set -e

echo "Setting up Libvirt LVM Automation Environment..."

# Install required collections
echo "Installing Ansible collections..."
ansible-galaxy collection install -r requirements.yml

echo "Setup complete! Configure your inventory.yml"
