#!/bin/bash
# Start Event Driven Ansible

set -e

echo "Starting Event Driven Ansible..."

if! command -v ansible-rulebook &> /dev/null; then
 echo "ERROR: ansible-rulebook not found"
 echo "Install with: pip3 install ansible-rulebook"
 exit 1
fi

if [ -f.env ]; then
 echo "Loading environment from.env..."
 source.env
fi

echo "Starting rulebook: rulebook.yml"
ansible-rulebook \
 --rulebook rulebook.yml \
 --inventory inventory/hosts \
 --verbose
