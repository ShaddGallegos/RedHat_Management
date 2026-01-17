---
# Product Playbooks Structure
# 
# This directory contains organized playbooks for each product lifecycle:
#   - install/    : Installation and initial configuration
#   - uninstall/  : Safe removal and cleanup
#   - integrate/  : Integration with other components
#   - backup/     : Backup and recovery procedures
#   - test/       : Validation and testing
#
# Products covered:
#   - aap         : Ansible Automation Platform 2.6
#   - satellite   : Red Hat Satellite 6.18
#   - idm         : Identity Management
#   - insights    : Red Hat Insights
#   - openshift   : Red Hat OpenShift
#
# Usage:
#   # Install a product
#   ansible-playbook playbooks/products/aap/install.yml
#
#   # Test integration between products
#   ansible-playbook playbooks/integrations/aap-satellite-integration-test.yml
#
#   # Backup a product
#   ansible-playbook playbooks/products/satellite/backup.yml
#
# See docs/products/ for detailed documentation on each product.
