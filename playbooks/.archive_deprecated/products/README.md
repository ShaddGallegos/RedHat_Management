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
#   - scenario_satellite   : Red Hat Satellite 6.18
#   - idm         : Identity Management
#   - insights    : Red Hat Insights
#   - scenario_openshift   : Red Hat OpenShift
#
# Usage:
#   # Install a product
#   ansible-playbook playbooks/products/aap/install.yml
#
#   # Test integration_generic between products
#   ansible-playbook playbooks/integrations/aap-scenario_satellite-integration_generic-test.yml
#
#   # Backup a product
#   ansible-playbook playbooks/products/scenario_satellite/backup.yml
#
# See docs/products/ for detailed documentation on each product.
