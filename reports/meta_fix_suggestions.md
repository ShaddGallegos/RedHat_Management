Suggested fixes for role meta files
=================================

Recommended automatic edits (preview):

- Replace `categories:` keys under `galaxy_info` with `galaxy_tags:`
- Remove `max_ansible_version:` entries (not allowed by current galaxy schema)
- Ensure tag values use lowercase letters and digits only (replace invalid underscores or mixed case)

Files detected (examples):

```
roles/ansible_dev_node_deployment_setup/meta/main.yml
roles/integration_idm_412/meta/main.yml
roles/platform_infrastructure_core/meta/main.yml
roles/platform_infrastructure_manager/meta/main.yml
roles/platform_infrastructure_prep/meta/main.yml
roles/integration_generic/meta/main.yml
roles/ansible_dev_node_inventory_generator/meta/main.yml
roles/platform_libvirt_vm_provisioner/meta/main.yml
roles/scenario_openshift_4_21_deployment/meta/main.yml
roles/ansible_dev_node_orchestration/meta/main.yml
roles/ansible_dev_node_product_lifecycle/meta/main.yml
roles/ansible_dev_node_prompts/meta/main.yml
roles/platform_provisioning/meta/main.yml
roles/scenario_aap_controller_setup/meta/main.yml
roles/platform_host_provisioning/meta/main.yml
roles/scenario_satellite_618_configure_provisioning/meta/main.yml
roles/scenario_satellite_618_install/meta/main.yml
roles/scenario_satellite_activation_config/meta/main.yml
roles/scenario_satellite_lifecycle_config/meta/main.yml
roles/platform_services_provisioning_stack/meta/main.yml
roles/ansible_dev_node_support/meta/main.yml
roles/platform_tftp_boot_server/meta/main.yml
roles/scenario_aap_setup/meta/main.yml
roles/scenario_aap_credentials/meta/main.yml
roles/scenario_aap_inventories/meta/main.yml
roles/scenario_aap_projects/meta/main.yml
roles/scenario_aap_templates/meta/main.yml
roles/scenario_ansible_cmdb_setup/meta/main.yml
roles/platform_baremetal_provisioner/meta/main.yml
roles/scenario_ansible_cmdb_core/meta/main.yml
roles/os_generic/meta/main.yml
roles/ansible_dev_node_redhat_products/meta/main.yml
roles/scenario_aap_deployment/meta/main.yml
roles/integration_inventory_rhis/meta/main.yml
```

Example suggested change (YAML snippet):

Before:

  categories:
    - cloud
    - system

After:

  galaxy_tags:
    - cloud
    - system

Also remove lines such as `max_ansible_version: "2.16"` from `galaxy_info` blocks.

Next steps I can take when you approve:

- Apply these replacements across all detected `meta/main.yml` files and open a PR.
- Or generate per-file patch files for review before applying.
