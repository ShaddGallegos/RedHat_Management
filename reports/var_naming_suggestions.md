## ansible_dev_node_common_tasks
- `repositories` -> `ansible_dev_node_common_tasks_repositories`
- `ntp_servers` -> `ansible_dev_node_common_tasks_ntp_servers`
- `scap_file` -> `ansible_dev_node_common_tasks_scap_file`
- `scap_profile` -> `ansible_dev_node_common_tasks_scap_profile`
- `mandatory_global_parameters` -> `ansible_dev_node_common_tasks_mandatory_global_parameters`
- `mandatory_os_config` -> `ansible_dev_node_common_tasks_mandatory_os_config`
- `environment` -> `ansible_dev_node_common_tasks_environment`
- `environment_type` -> `ansible_dev_node_common_tasks_environment_type`
- `update_strategy` -> `ansible_dev_node_common_tasks_update_strategy`

## ansible_dev_node_deployment_setup
- `deployment_setup_enabled` -> `ansible_dev_node_deployment_setup_deployment_setup_enabled`
- `deployment_setup_version` -> `ansible_dev_node_deployment_setup_deployment_setup_version`
- `deployment_setup_directories` -> `ansible_dev_node_deployment_setup_deployment_setup_directories`
- `deployment_setup_validate_environment` -> `ansible_dev_node_deployment_setup_deployment_setup_validate_environment`

## ansible_dev_node_inventory_generator
- `inventory_generator_enabled` -> `ansible_dev_node_inventory_generator_inventory_generator_enabled`
- `inventory_generator_version` -> `ansible_dev_node_inventory_generator_inventory_generator_version`
- `inventory_generator_format` -> `ansible_dev_node_inventory_generator_inventory_generator_format`
- `inventory_generator_output` -> `ansible_dev_node_inventory_generator_inventory_generator_output`
- `inventory_generator_validate_syntax` -> `ansible_dev_node_inventory_generator_inventory_generator_validate_syntax`

## ansible_dev_node_orchestration
- `orchestration_enabled` -> `ansible_dev_node_orchestration_orchestration_enabled`
- `orchestration_version` -> `ansible_dev_node_orchestration_orchestration_version`
- `orchestration_dry_run` -> `ansible_dev_node_orchestration_orchestration_dry_run`
- `orchestration_verbose` -> `ansible_dev_node_orchestration_orchestration_verbose`
- `orchestration_validate_dependencies` -> `ansible_dev_node_orchestration_orchestration_validate_dependencies`

## ansible_dev_node_orchestration_master
- `orchestration_master_enabled` -> `ansible_dev_node_orchestration_master_orchestration_master_enabled`
- `orchestration_master_version` -> `ansible_dev_node_orchestration_master_orchestration_master_version`
- `orchestration_master_timeout` -> `ansible_dev_node_orchestration_master_orchestration_master_timeout`
- `orchestration_master_max_retries` -> `ansible_dev_node_orchestration_master_orchestration_master_max_retries`
- `deploy_infrastructure` -> `ansible_dev_node_orchestration_master_deploy_infrastructure`
- `configure_os` -> `ansible_dev_node_orchestration_master_configure_os`
- `deploy_products` -> `ansible_dev_node_orchestration_master_deploy_products`
- `run_tests` -> `ansible_dev_node_orchestration_master_run_tests`
- `configure_aap_rbac` -> `ansible_dev_node_orchestration_master_configure_aap_rbac`
- `configure_satellite_api` -> `ansible_dev_node_orchestration_master_configure_satellite_api`
- `configure_satellite_content` -> `ansible_dev_node_orchestration_master_configure_satellite_content`
- `deploy_idm_replicas` -> `ansible_dev_node_orchestration_master_deploy_idm_replicas`

## ansible_dev_node_product_lifecycle
- `product_lifecycle_enabled` -> `ansible_dev_node_product_lifecycle_product_lifecycle_enabled`
- `product_lifecycle_version` -> `ansible_dev_node_product_lifecycle_product_lifecycle_version`
- `product_lifecycle_timeout` -> `ansible_dev_node_product_lifecycle_product_lifecycle_timeout`
- `manage_product_updates` -> `ansible_dev_node_product_lifecycle_manage_product_updates`
- `manage_product_upgrades` -> `ansible_dev_node_product_lifecycle_manage_product_upgrades`
- `enable_rollback` -> `ansible_dev_node_product_lifecycle_enable_rollback`
- `product_lifecycle_validate_compatibility` -> `ansible_dev_node_product_lifecycle_product_lifecycle_validate_compatibility`

## ansible_dev_node_prompts
- `infrastructure_type` -> `ansible_dev_node_prompts_infrastructure_type`
- `ansible_domain` -> `ansible_dev_node_prompts_ansible_domain`
- `libvirt_host_short_name` -> `ansible_dev_node_prompts_libvirt_host_short_name`
- `libvirt_external_network` -> `ansible_dev_node_prompts_libvirt_external_network`
- `libvirt_external_network_gw` -> `ansible_dev_node_prompts_libvirt_external_network_gw`
- `libvirt_internal_network` -> `ansible_dev_node_prompts_libvirt_internal_network`
- `libvirt_internal_network_subnet` -> `ansible_dev_node_prompts_libvirt_internal_network_subnet`
- `libvirt_internal_network_gw` -> `ansible_dev_node_prompts_libvirt_internal_network_gw`
- `libvirt_installer_node_ip` -> `ansible_dev_node_prompts_libvirt_installer_node_ip`
- `libvirt_aap_ip` -> `ansible_dev_node_prompts_libvirt_aap_ip`
- `libvirt_satellite_ip` -> `ansible_dev_node_prompts_libvirt_satellite_ip`
- `libvirt_idm_ip` -> `ansible_dev_node_prompts_libvirt_idm_ip`
- `libvirt_installer_node_short_name` -> `ansible_dev_node_prompts_libvirt_installer_node_short_name`
- `libvirt_aap_node_short_name` -> `ansible_dev_node_prompts_libvirt_aap_node_short_name`
- `libvirt_satellite_node_short_name` -> `ansible_dev_node_prompts_libvirt_satellite_node_short_name`
- `libvirt_idm_node_short_name` -> `ansible_dev_node_prompts_libvirt_idm_node_short_name`

## ansible_dev_node_support
- `support_enabled` -> `ansible_dev_node_support_support_enabled`
- `support_version` -> `ansible_dev_node_support_support_version`
- `run_preflight_checks` -> `ansible_dev_node_support_run_preflight_checks`
- `run_tests` -> `ansible_dev_node_support_run_tests`
- `backup_and_restore` -> `ansible_dev_node_support_backup_and_restore`
- `configure_cmdb` -> `ansible_dev_node_support_configure_cmdb`
- `backup_destination` -> `ansible_dev_node_support_backup_destination`
- `backup_retention_days` -> `ansible_dev_node_support_backup_retention_days`
- `support_validate_deployment` -> `ansible_dev_node_support_support_validate_deployment`

## integration_disk_integration
- `target_disk` -> `integration_disk_integration_target_disk`
- `vg_name` -> `integration_disk_integration_vg_name`
- `lv_name` -> `integration_disk_integration_lv_name`
- `lv_size` -> `integration_disk_integration_lv_size`
- `mount_point` -> `integration_disk_integration_mount_point`
- `fs_type` -> `integration_disk_integration_fs_type`

## integration_extend_disk_on_alert
- `vg_name` -> `integration_extend_disk_on_alert_vg_name`
- `lv_name` -> `integration_extend_disk_on_alert_lv_name`
- `disk_img_path` -> `integration_extend_disk_on_alert_disk_img_path`
- `disk_device` -> `integration_extend_disk_on_alert_disk_device`

## integration_generic
- `integration_enabled` -> `integration_generic_integration_enabled`
- `integration_version` -> `integration_generic_integration_version`
- `integration_timeout` -> `integration_generic_integration_timeout`
- `configure_satellite_aap_integration` -> `integration_generic_configure_satellite_aap_integration`
- `configure_satellite_idm_integration` -> `integration_generic_configure_satellite_idm_integration`
- `configure_aap_idm_integration` -> `integration_generic_configure_aap_idm_integration`
- `configure_satellite_insights_integration` -> `integration_generic_configure_satellite_insights_integration`
- `integration_validate_connectivity` -> `integration_generic_integration_validate_connectivity`
- `integration_test_integration` -> `integration_generic_integration_test_integration`

## integration_idm_412
- `idm_integration_enabled` -> `integration_idm_412_idm_integration_enabled`
- `idm_integration_version` -> `integration_idm_412_idm_integration_version`
- `idm_integration_timeout` -> `integration_idm_412_idm_integration_timeout`
- `configure_ldap` -> `integration_idm_412_configure_ldap`
- `enable_kerberos` -> `integration_idm_412_enable_kerberos`
- `idm_integration_validate_connectivity` -> `integration_idm_412_idm_integration_validate_connectivity`

## integration_inventory_rhis
- `rhis_templates_dir` -> `integration_inventory_rhis_rhis_templates_dir`
- `rhis_files_dir` -> `integration_inventory_rhis_rhis_files_dir`
- `rhis_provisioning_templates_dir` -> `integration_inventory_rhis_rhis_provisioning_templates_dir`
- `rhis_config_templates_dir` -> `integration_inventory_rhis_rhis_config_templates_dir`
- `rhis_inventory_templates_dir` -> `integration_inventory_rhis_rhis_inventory_templates_dir`
- `rhis_execution_env_templates_dir` -> `integration_inventory_rhis_rhis_execution_env_templates_dir`
- `rhis_openscan_files_dir` -> `integration_inventory_rhis_rhis_openscan_files_dir`
- `rhis_scripts_dir` -> `integration_inventory_rhis_rhis_scripts_dir`
- `rhis_example_inventory_dir` -> `integration_inventory_rhis_rhis_example_inventory_dir`
- `rhis_use_custom_tasks` -> `integration_inventory_rhis_rhis_use_custom_tasks`

## os_generic
- `os_enabled` -> `os_generic_os_enabled`
- `os_version` -> `os_generic_os_version`
- `configure_firewall` -> `os_generic_configure_firewall`
- `enable_selinux` -> `os_generic_enable_selinux`
- `configure_network` -> `os_generic_configure_network`
- `install_required_packages` -> `os_generic_install_required_packages`

## platform_baremetal_provisioner
- `baremetal_provisioner_enabled` -> `platform_baremetal_provisioner_baremetal_provisioner_enabled`
- `baremetal_provisioner_version` -> `platform_baremetal_provisioner_baremetal_provisioner_version`
- `baremetal_provisioner_timeout` -> `platform_baremetal_provisioner_baremetal_provisioner_timeout`
- `pxe_boot_enabled` -> `platform_baremetal_provisioner_pxe_boot_enabled`
- `dhcp_range_start` -> `platform_baremetal_provisioner_dhcp_range_start`
- `dhcp_range_end` -> `platform_baremetal_provisioner_dhcp_range_end`
- `tftp_root` -> `platform_baremetal_provisioner_tftp_root`
- `baremetal_provisioner_validate_hardware` -> `platform_baremetal_provisioner_baremetal_provisioner_validate_hardware`

## platform_firewall_services
- `firewall_services_enabled` -> `platform_firewall_services_firewall_services_enabled`
- `firewall_services_profiles_enabled` -> `platform_firewall_services_firewall_services_profiles_enabled`
- `firewall_services_definitions` -> `platform_firewall_services_firewall_services_definitions`
- `firewall_zone` -> `platform_firewall_services_firewall_zone`

## platform_host_provisioning
- `provisioning_hosts` -> `platform_host_provisioning_provisioning_hosts`
- `satellite_host` -> `platform_host_provisioning_satellite_host`
- `satellite_username` -> `platform_host_provisioning_satellite_username`
- `satellite_password` -> `platform_host_provisioning_satellite_password`
- `host_organization` -> `platform_host_provisioning_host_organization`
- `host_build_sync` -> `platform_host_provisioning_host_build_sync`
- `host_wait_timeout` -> `platform_host_provisioning_host_wait_timeout`
- `host_wait_sleep` -> `platform_host_provisioning_host_wait_sleep`
- `host_wait_port` -> `platform_host_provisioning_host_wait_port`
- `default_inventory_groups` -> `platform_host_provisioning_default_inventory_groups`

## platform_infrastructure_core
- `infrastructure_enabled` -> `platform_infrastructure_core_infrastructure_enabled`
- `infrastructure_version` -> `platform_infrastructure_core_infrastructure_version`
- `infrastructure_timeout` -> `platform_infrastructure_core_infrastructure_timeout`
- `configure_networking` -> `platform_infrastructure_core_configure_networking`
- `configure_storage` -> `platform_infrastructure_core_configure_storage`
- `infrastructure_validate_resources` -> `platform_infrastructure_core_infrastructure_validate_resources`

## platform_infrastructure_manager
- `infrastructure_manager_enabled` -> `platform_infrastructure_manager_infrastructure_manager_enabled`
- `infrastructure_manager_version` -> `platform_infrastructure_manager_infrastructure_manager_version`
- `infrastructure_manager_timeout` -> `platform_infrastructure_manager_infrastructure_manager_timeout`
- `infrastructure_manager_max_retries` -> `platform_infrastructure_manager_infrastructure_manager_max_retries`
- `deploy_infrastructure` -> `platform_infrastructure_manager_deploy_infrastructure`
- `infrastructure_platform` -> `platform_infrastructure_manager_infrastructure_platform`
- `infrastructure_network` -> `platform_infrastructure_manager_infrastructure_network`
- `infrastructure_manager_validate_prerequisites` -> `platform_infrastructure_manager_infrastructure_manager_validate_prerequisites`

## platform_infrastructure_prep
- `infrastructure_prep_enabled` -> `platform_infrastructure_prep_infrastructure_prep_enabled`
- `infrastructure_prep_version` -> `platform_infrastructure_prep_infrastructure_prep_version`
- `infrastructure_prep_timeout` -> `platform_infrastructure_prep_infrastructure_prep_timeout`
- `configure_firewall` -> `platform_infrastructure_prep_configure_firewall`
- `enable_selinux` -> `platform_infrastructure_prep_enable_selinux`
- `infrastructure_prep_validate_network` -> `platform_infrastructure_prep_infrastructure_prep_validate_network`

## platform_libvirt_setup
- `external_device` -> `platform_libvirt_setup_external_device`
- `external_type` -> `platform_libvirt_setup_external_type`
- `internal_device` -> `platform_libvirt_setup_internal_device`
- `internal_subnet` -> `platform_libvirt_setup_internal_subnet`

## platform_libvirt_vm_provisioner
- `libvirt_vm_name` -> `platform_libvirt_vm_provisioner_libvirt_vm_name`
- `libvirt_vm_cpus` -> `platform_libvirt_vm_provisioner_libvirt_vm_cpus`
- `libvirt_vm_memory` -> `platform_libvirt_vm_provisioner_libvirt_vm_memory`
- `libvirt_vm_disk` -> `platform_libvirt_vm_provisioner_libvirt_vm_disk`
- `libvirt_vm_network` -> `platform_libvirt_vm_provisioner_libvirt_vm_network`
- `libvirt_iso_file` -> `platform_libvirt_vm_provisioner_libvirt_iso_file`
- `libvirt_kickstart_file` -> `platform_libvirt_vm_provisioner_libvirt_kickstart_file`
- `libvirt_kickstart_port` -> `platform_libvirt_vm_provisioner_libvirt_kickstart_port`
- `libvirt_kickstart_http_dir` -> `platform_libvirt_vm_provisioner_libvirt_kickstart_http_dir`
- `libvirt_monitor_timeout` -> `platform_libvirt_vm_provisioner_libvirt_monitor_timeout`
- `libvirt_monitor_interval` -> `platform_libvirt_vm_provisioner_libvirt_monitor_interval`
- `libvirt_bridge_device` -> `platform_libvirt_vm_provisioner_libvirt_bridge_device`
- `libvirt_mac_address` -> `platform_libvirt_vm_provisioner_libvirt_mac_address`
- `libvirt_static_ip` -> `platform_libvirt_vm_provisioner_libvirt_static_ip`
- `libvirt_gateway` -> `platform_libvirt_vm_provisioner_libvirt_gateway`
- `libvirt_nameserver` -> `platform_libvirt_vm_provisioner_libvirt_nameserver`
- `libvirt_root_password` -> `platform_libvirt_vm_provisioner_libvirt_root_password`
- `libvirt_ansible_user` -> `platform_libvirt_vm_provisioner_libvirt_ansible_user`
- `libvirt_packages` -> `platform_libvirt_vm_provisioner_libvirt_packages`
- `libvirt_install_ansible` -> `platform_libvirt_vm_provisioner_libvirt_install_ansible`
- `libvirt_enable_selinux` -> `platform_libvirt_vm_provisioner_libvirt_enable_selinux`
- `libvirt_enable_firewall` -> `platform_libvirt_vm_provisioner_libvirt_enable_firewall`
- `libvirt_firewall_services` -> `platform_libvirt_vm_provisioner_libvirt_firewall_services`
- `libvirt_cleanup_http_server` -> `platform_libvirt_vm_provisioner_libvirt_cleanup_http_server`
- `libvirt_cleanup_temp_files` -> `platform_libvirt_vm_provisioner_libvirt_cleanup_temp_files`
- `libvirt_log_level` -> `platform_libvirt_vm_provisioner_libvirt_log_level`
- `libvirt_save_logs` -> `platform_libvirt_vm_provisioner_libvirt_save_logs`
- `libvirt_logs_dir` -> `platform_libvirt_vm_provisioner_libvirt_logs_dir`
- `use_cloud_init_iso` -> `platform_libvirt_vm_provisioner_use_cloud_init_iso`
- `use_cloud_init_disk` -> `platform_libvirt_vm_provisioner_use_cloud_init_disk`
- `cloud_init_allow_password_auth` -> `platform_libvirt_vm_provisioner_cloud_init_allow_password_auth`
- `seed_disk_size_mb` -> `platform_libvirt_vm_provisioner_seed_disk_size_mb`
- `ssh_public_key` -> `platform_libvirt_vm_provisioner_ssh_public_key`

## platform_network_infrastructure
- `network_config_enabled` -> `platform_network_infrastructure_network_config_enabled`
- `network_config_version` -> `platform_network_infrastructure_network_config_version`
- `network_config_timeout` -> `platform_network_infrastructure_network_config_timeout`
- `network_interface` -> `platform_network_infrastructure_network_interface`
- `network_name` -> `platform_network_infrastructure_network_name`
- `network_domain` -> `platform_network_infrastructure_network_domain`
- `primary_subnet` -> `platform_network_infrastructure_primary_subnet`
- `dhcp_primary` -> `platform_network_infrastructure_dhcp_primary`
- `dns_primary` -> `platform_network_infrastructure_dns_primary`
- `host_groups` -> `platform_network_infrastructure_host_groups`
- `static_hosts` -> `platform_network_infrastructure_static_hosts`
- `firewall_rules` -> `platform_network_infrastructure_firewall_rules`
- `network_validation` -> `platform_network_infrastructure_network_validation`

## platform_provisioning
- `provisioning_enabled` -> `platform_provisioning_provisioning_enabled`
- `provisioning_version` -> `platform_provisioning_provisioning_version`
- `provisioning_timeout` -> `platform_provisioning_provisioning_timeout`
- `provisioning_max_retries` -> `platform_provisioning_provisioning_max_retries`
- `provision_hosts` -> `platform_provisioning_provision_hosts`
- `configure_networking` -> `platform_provisioning_configure_networking`
- `provisioning_validate_connectivity` -> `platform_provisioning_provisioning_validate_connectivity`

## platform_services_provisioning_stack
- `provisioning_host` -> `platform_services_provisioning_stack_provisioning_host`
- `provisioning_host_fqdn` -> `platform_services_provisioning_stack_provisioning_host_fqdn`
- `provisioning_primary_interface` -> `platform_services_provisioning_stack_provisioning_primary_interface`
- `provisioning_primary_interface_type` -> `platform_services_provisioning_stack_provisioning_primary_interface_type`
- `provisioning_primary_connection_type` -> `platform_services_provisioning_stack_provisioning_primary_connection_type`
- `provisioning_primary_autoconnect` -> `platform_services_provisioning_stack_provisioning_primary_autoconnect`
- `provisioning_primary_description` -> `platform_services_provisioning_stack_provisioning_primary_description`
- `provisioning_secondary_interface` -> `platform_services_provisioning_stack_provisioning_secondary_interface`
- `provisioning_interface_ip` -> `platform_services_provisioning_stack_provisioning_interface_ip`
- `provisioning_interface_netmask` -> `platform_services_provisioning_stack_provisioning_interface_netmask`
- `provisioning_interface_gateway` -> `platform_services_provisioning_stack_provisioning_interface_gateway`
- `provisioning_interface_network` -> `platform_services_provisioning_stack_provisioning_interface_network`
- `provisioning_interface_broadcast` -> `platform_services_provisioning_stack_provisioning_interface_broadcast`
- `provisioning_secondary_connection_type` -> `platform_services_provisioning_stack_provisioning_secondary_connection_type`
- `provisioning_secondary_autoconnect` -> `platform_services_provisioning_stack_provisioning_secondary_autoconnect`
- `provisioning_secondary_description` -> `platform_services_provisioning_stack_provisioning_secondary_description`
- `dhcp_enabled` -> `platform_services_provisioning_stack_dhcp_enabled`
- `dhcp_package` -> `platform_services_provisioning_stack_dhcp_package`
- `dhcp_service` -> `platform_services_provisioning_stack_dhcp_service`
- `dhcp_config_file` -> `platform_services_provisioning_stack_dhcp_config_file`
- `dhcp_leases_file` -> `platform_services_provisioning_stack_dhcp_leases_file`
- `dhcp_subnet` -> `platform_services_provisioning_stack_dhcp_subnet`
- `dhcp_netmask` -> `platform_services_provisioning_stack_dhcp_netmask`
- `dhcp_range_start` -> `platform_services_provisioning_stack_dhcp_range_start`
- `dhcp_range_end` -> `platform_services_provisioning_stack_dhcp_range_end`
- `dhcp_lease_time` -> `platform_services_provisioning_stack_dhcp_lease_time`
- `dhcp_max_lease_time` -> `platform_services_provisioning_stack_dhcp_max_lease_time`
- `dhcp_default_lease_time` -> `platform_services_provisioning_stack_dhcp_default_lease_time`
- `dhcp_option_routers` -> `platform_services_provisioning_stack_dhcp_option_routers`
- `dhcp_option_domain_name` -> `platform_services_provisioning_stack_dhcp_option_domain_name`
- `dhcp_option_domain_name_servers` -> `platform_services_provisioning_stack_dhcp_option_domain_name_servers`
- `dhcp_option_ntp_servers` -> `platform_services_provisioning_stack_dhcp_option_ntp_servers`
- `dhcp_option_netbios_name_servers` -> `platform_services_provisioning_stack_dhcp_option_netbios_name_servers`
- `pxe_enabled` -> `platform_services_provisioning_stack_pxe_enabled`
- `pxe_bootloader` -> `platform_services_provisioning_stack_pxe_bootloader`
- `pxe_boot_file` -> `platform_services_provisioning_stack_pxe_boot_file`
- `pxe_menu_file` -> `platform_services_provisioning_stack_pxe_menu_file`
- `pxe_menu_label` -> `platform_services_provisioning_stack_pxe_menu_label`
- `pxe_kernel_append_params` -> `platform_services_provisioning_stack_pxe_kernel_append_params`
- `tftp_enabled` -> `platform_services_provisioning_stack_tftp_enabled`
- `tftp_package` -> `platform_services_provisioning_stack_tftp_package`
- `tftp_service` -> `platform_services_provisioning_stack_tftp_service`
- `tftp_socket_service` -> `platform_services_provisioning_stack_tftp_socket_service`
- `tftp_root` -> `platform_services_provisioning_stack_tftp_root`
- `tftp_user` -> `platform_services_provisioning_stack_tftp_user`
- `tftp_group` -> `platform_services_provisioning_stack_tftp_group`
- `tftp_permissions` -> `platform_services_provisioning_stack_tftp_permissions`
- `tftp_file_permissions` -> `platform_services_provisioning_stack_tftp_file_permissions`
- `dns_enabled` -> `platform_services_provisioning_stack_dns_enabled`
- `dns_package` -> `platform_services_provisioning_stack_dns_package`
- `dns_service` -> `platform_services_provisioning_stack_dns_service`
- `dns_config_file` -> `platform_services_provisioning_stack_dns_config_file`
- `dns_zones_dir` -> `platform_services_provisioning_stack_dns_zones_dir`
- `dns_zone_name` -> `platform_services_provisioning_stack_dns_zone_name`
- `dns_zone_file` -> `platform_services_provisioning_stack_dns_zone_file`
- `dns_secondary_zone_name` -> `platform_services_provisioning_stack_dns_secondary_zone_name`
- `dns_secondary_zone_file` -> `platform_services_provisioning_stack_dns_secondary_zone_file`
- `dns_nameserver_ip` -> `platform_services_provisioning_stack_dns_nameserver_ip`
- `dns_secondary_ip` -> `platform_services_provisioning_stack_dns_secondary_ip`
- `dns_forward_servers` -> `platform_services_provisioning_stack_dns_forward_servers`
- `resolv_conf_path` -> `platform_services_provisioning_stack_resolv_conf_path`
- `resolv_conf_nameservers` -> `platform_services_provisioning_stack_resolv_conf_nameservers`
- `resolv_conf_search_domains` -> `platform_services_provisioning_stack_resolv_conf_search_domains`
- `resolv_conf_options` -> `platform_services_provisioning_stack_resolv_conf_options`
- `service_restart_enabled` -> `platform_services_provisioning_stack_service_restart_enabled`
- `service_enable_on_boot` -> `platform_services_provisioning_stack_service_enable_on_boot`
- `firewall_enabled` -> `platform_services_provisioning_stack_firewall_enabled`
- `firewall_rules` -> `platform_services_provisioning_stack_firewall_rules`
- `logging_enabled` -> `platform_services_provisioning_stack_logging_enabled`
- `log_level` -> `platform_services_provisioning_stack_log_level`
- `dhcp_log_file` -> `platform_services_provisioning_stack_dhcp_log_file`
- `dns_log_file` -> `platform_services_provisioning_stack_dns_log_file`
- `tftp_log_file` -> `platform_services_provisioning_stack_tftp_log_file`
- `backup_enabled` -> `platform_services_provisioning_stack_backup_enabled`
- `backup_configs` -> `platform_services_provisioning_stack_backup_configs`
- `backup_directory` -> `platform_services_provisioning_stack_backup_directory`

## platform_tftp_boot_server
- `tftp_server_ip` -> `platform_tftp_boot_server_tftp_server_ip`
- `tftp_enable` -> `platform_tftp_boot_server_tftp_enable`
- `tftp_enable_firewall` -> `platform_tftp_boot_server_tftp_enable_firewall`
- `tftp_root` -> `platform_tftp_boot_server_tftp_root`
- `tftp_iso_dir` -> `platform_tftp_boot_server_tftp_iso_dir`
- `project_root` -> `platform_tftp_boot_server_project_root`
- `dhcp_tftp_server` -> `platform_tftp_boot_server_dhcp_tftp_server`
- `dhcp_boot_file` -> `platform_tftp_boot_server_dhcp_boot_file`

## scenario_aap_controller_setup
- `aap_controller_host` -> `scenario_aap_controller_setup_aap_controller_host`
- `aap_controller_username` -> `scenario_aap_controller_setup_aap_controller_username`
- `aap_controller_password` -> `scenario_aap_controller_setup_aap_controller_password`
- `aap_controller_validate_certs` -> `scenario_aap_controller_setup_aap_controller_validate_certs`
- `aap_manifest_source_path` -> `scenario_aap_controller_setup_aap_manifest_source_path`
- `aap_manifest_force` -> `scenario_aap_controller_setup_aap_manifest_force`
- `aap_settings` -> `scenario_aap_controller_setup_aap_settings`
- `aap_service_cert_path` -> `scenario_aap_controller_setup_aap_service_cert_path`
- `aap_service_key_path` -> `scenario_aap_controller_setup_aap_service_key_path`
- `rhis_controller_manifest_refresh_tag` -> `scenario_aap_controller_setup_rhis_controller_manifest_refresh_tag`

## scenario_aap_credentials
- `aap_credentials_config_enabled` -> `scenario_aap_credentials_aap_credentials_config_enabled`
- `aap_credentials_config_version` -> `scenario_aap_credentials_aap_credentials_config_version`
- `aap_credentials_config_timeout` -> `scenario_aap_credentials_aap_credentials_config_timeout`
- `aap_url` -> `scenario_aap_credentials_aap_url`
- `aap_username` -> `scenario_aap_credentials_aap_username`
- `aap_verify_ssl` -> `scenario_aap_credentials_aap_verify_ssl`
- `aap_credentials_organization` -> `scenario_aap_credentials_aap_credentials_organization`
- `create_machine_credentials` -> `scenario_aap_credentials_create_machine_credentials`
- `machine_credentials` -> `scenario_aap_credentials_machine_credentials`
- `create_cloud_credentials` -> `scenario_aap_credentials_create_cloud_credentials`
- `cloud_credentials` -> `scenario_aap_credentials_cloud_credentials`
- `create_network_credentials` -> `scenario_aap_credentials_create_network_credentials`
- `network_credentials` -> `scenario_aap_credentials_network_credentials`
- `create_vault_credentials` -> `scenario_aap_credentials_create_vault_credentials`
- `vault_credentials` -> `scenario_aap_credentials_vault_credentials`
- `create_registry_credentials` -> `scenario_aap_credentials_create_registry_credentials`
- `registry_credentials` -> `scenario_aap_credentials_registry_credentials`
- `create_satellite_credentials` -> `scenario_aap_credentials_create_satellite_credentials`
- `satellite_credentials` -> `scenario_aap_credentials_satellite_credentials`
- `create_idm_credentials` -> `scenario_aap_credentials_create_idm_credentials`
- `idm_credentials` -> `scenario_aap_credentials_idm_credentials`
- `aap_credentials_validate_connectivity` -> `scenario_aap_credentials_aap_credentials_validate_connectivity`
- `aap_credentials_test_connections` -> `scenario_aap_credentials_aap_credentials_test_connections`

## scenario_aap_deployment
- `aap_installer_version` -> `scenario_aap_deployment_aap_installer_version`
- `aap_installer_download_url` -> `scenario_aap_deployment_aap_installer_download_url`
- `aap_installer_bundle_dir` -> `scenario_aap_deployment_aap_installer_bundle_dir`
- `aap_installer_inventory_dir` -> `scenario_aap_deployment_aap_installer_inventory_dir`
- `aap_content_source_path` -> `scenario_aap_deployment_aap_content_source_path`
- `aap_content_download_timeout` -> `scenario_aap_deployment_aap_content_download_timeout`
- `builder_key_file` -> `scenario_aap_deployment_builder_key_file`
- `deployment_user` -> `scenario_aap_deployment_deployment_user`
- `controllers` -> `scenario_aap_deployment_controllers`
- `aap_installer_template_src` -> `scenario_aap_deployment_aap_installer_template_src`
- `aap_installer_template_dest` -> `scenario_aap_deployment_aap_installer_template_dest`
- `aap_install_verbosity` -> `scenario_aap_deployment_aap_install_verbosity`

## scenario_aap_inventories
- `aap_inventories_config_enabled` -> `scenario_aap_inventories_aap_inventories_config_enabled`
- `aap_inventories_config_version` -> `scenario_aap_inventories_aap_inventories_config_version`
- `aap_inventories_config_timeout` -> `scenario_aap_inventories_aap_inventories_config_timeout`
- `aap_url` -> `scenario_aap_inventories_aap_url`
- `aap_username` -> `scenario_aap_inventories_aap_username`
- `aap_verify_ssl` -> `scenario_aap_inventories_aap_verify_ssl`
- `aap_inventories_organization` -> `scenario_aap_inventories_aap_inventories_organization`
- `create_static_inventories` -> `scenario_aap_inventories_create_static_inventories`
- `static_inventories` -> `scenario_aap_inventories_static_inventories`
- `create_dynamic_inventories` -> `scenario_aap_inventories_create_dynamic_inventories`
- `dynamic_inventories` -> `scenario_aap_inventories_dynamic_inventories`
- `create_inventory_sources` -> `scenario_aap_inventories_create_inventory_sources`
- `inventory_sources` -> `scenario_aap_inventories_inventory_sources`
- `aap_inventories_validate_connectivity` -> `scenario_aap_inventories_aap_inventories_validate_connectivity`
- `aap_inventories_test_imports` -> `scenario_aap_inventories_aap_inventories_test_imports`

## scenario_aap_projects
- `aap_projects_config_enabled` -> `scenario_aap_projects_aap_projects_config_enabled`
- `aap_projects_config_version` -> `scenario_aap_projects_aap_projects_config_version`
- `aap_projects_config_timeout` -> `scenario_aap_projects_aap_projects_config_timeout`
- `aap_url` -> `scenario_aap_projects_aap_url`
- `aap_username` -> `scenario_aap_projects_aap_username`
- `aap_verify_ssl` -> `scenario_aap_projects_aap_verify_ssl`
- `aap_projects_organization` -> `scenario_aap_projects_aap_projects_organization`
- `create_git_projects` -> `scenario_aap_projects_create_git_projects`
- `git_projects` -> `scenario_aap_projects_git_projects`
- `create_manual_projects` -> `scenario_aap_projects_create_manual_projects`
- `manual_projects` -> `scenario_aap_projects_manual_projects`
- `aap_projects_validate_connectivity` -> `scenario_aap_projects_aap_projects_validate_connectivity`
- `aap_projects_sync_on_create` -> `scenario_aap_projects_aap_projects_sync_on_create`

## scenario_aap_setup
- `aap_2_6_setup_enabled` -> `scenario_aap_setup_aap_2_6_setup_enabled`
- `aap_2_6_setup_version` -> `scenario_aap_setup_aap_2_6_setup_version`
- `setup_aap_controllers` -> `scenario_aap_setup_setup_aap_controllers`
- `setup_aap_event_driven` -> `scenario_aap_setup_setup_aap_event_driven`
- `aap_2_6_setup_validate_prerequisites` -> `scenario_aap_setup_aap_2_6_setup_validate_prerequisites`

## scenario_aap_templates
- `aap_templates_config_enabled` -> `scenario_aap_templates_aap_templates_config_enabled`
- `aap_templates_config_version` -> `scenario_aap_templates_aap_templates_config_version`
- `aap_templates_config_timeout` -> `scenario_aap_templates_aap_templates_config_timeout`
- `aap_url` -> `scenario_aap_templates_aap_url`
- `aap_username` -> `scenario_aap_templates_aap_username`
- `aap_verify_ssl` -> `scenario_aap_templates_aap_verify_ssl`
- `aap_templates_organization` -> `scenario_aap_templates_aap_templates_organization`
- `create_job_templates` -> `scenario_aap_templates_create_job_templates`
- `job_templates` -> `scenario_aap_templates_job_templates`
- `create_workflow_templates` -> `scenario_aap_templates_create_workflow_templates`
- `workflow_templates` -> `scenario_aap_templates_workflow_templates`
- `workflow_nodes` -> `scenario_aap_templates_workflow_nodes`
- `aap_templates_validate_connectivity` -> `scenario_aap_templates_aap_templates_validate_connectivity`
- `aap_templates_test_validation` -> `scenario_aap_templates_aap_templates_test_validation`
- `aap_templates_ask_variables` -> `scenario_aap_templates_aap_templates_ask_variables`

## scenario_ansible_cmdb_core
- `cmdb_enabled` -> `scenario_ansible_cmdb_core_cmdb_enabled`
- `cmdb_version` -> `scenario_ansible_cmdb_core_cmdb_version`
- `cmdb_timeout` -> `scenario_ansible_cmdb_core_cmdb_timeout`
- `cmdb_database` -> `scenario_ansible_cmdb_core_cmdb_database`
- `cmdb_update_frequency` -> `scenario_ansible_cmdb_core_cmdb_update_frequency`
- `cmdb_enable_tracking` -> `scenario_ansible_cmdb_core_cmdb_enable_tracking`

## scenario_ansible_cmdb_setup
- `ansible_cmdb_setup_enabled` -> `scenario_ansible_cmdb_setup_ansible_cmdb_setup_enabled`
- `ansible_cmdb_setup_version` -> `scenario_ansible_cmdb_setup_ansible_cmdb_setup_version`
- `ansible_cmdb_output_format` -> `scenario_ansible_cmdb_setup_ansible_cmdb_output_format`
- `ansible_cmdb_output_directory` -> `scenario_ansible_cmdb_setup_ansible_cmdb_output_directory`
- `ansible_cmdb_setup_generate_docs` -> `scenario_ansible_cmdb_setup_ansible_cmdb_setup_generate_docs`

## scenario_openshift_4_21_deployment
- `openshift_4_21_deployment_enabled` -> `scenario_openshift_4_21_deployment_openshift_4_21_deployment_enabled`
- `openshift_4_21_deployment_version` -> `scenario_openshift_4_21_deployment_openshift_4_21_deployment_version`
- `openshift_rhis_environment` -> `scenario_openshift_4_21_deployment_openshift_rhis_environment`
- `openshift_4_21_deployment_validate_config` -> `scenario_openshift_4_21_deployment_openshift_4_21_deployment_validate_config`

## scenario_satellite_618_configure_provisioning
- `satellite_content_config_enabled` -> `scenario_satellite_618_configure_provisioning_satellite_content_config_enabled`
- `satellite_content_config_version` -> `scenario_satellite_618_configure_provisioning_satellite_content_config_version`
- `satellite_content_config_timeout` -> `scenario_satellite_618_configure_provisioning_satellite_content_config_timeout`
- `satellite_url` -> `scenario_satellite_618_configure_provisioning_satellite_url`
- `satellite_username` -> `scenario_satellite_618_configure_provisioning_satellite_username`
- `satellite_validate_ssl` -> `scenario_satellite_618_configure_provisioning_satellite_validate_ssl`
- `satellite_organization` -> `scenario_satellite_618_configure_provisioning_satellite_organization`
- `satellite_location` -> `scenario_satellite_618_configure_provisioning_satellite_location`
- `create_organizations` -> `scenario_satellite_618_configure_provisioning_create_organizations`
- `create_locations` -> `scenario_satellite_618_configure_provisioning_create_locations`
- `create_products` -> `scenario_satellite_618_configure_provisioning_create_products`
- `create_repositories` -> `scenario_satellite_618_configure_provisioning_create_repositories`
- `synchronize_repositories` -> `scenario_satellite_618_configure_provisioning_synchronize_repositories`
- `enable_repository_sets` -> `scenario_satellite_618_configure_provisioning_enable_repository_sets`
- `repository_sets_to_enable` -> `scenario_satellite_618_configure_provisioning_repository_sets_to_enable`
- `organizations` -> `scenario_satellite_618_configure_provisioning_organizations`
- `locations` -> `scenario_satellite_618_configure_provisioning_locations`
- `products` -> `scenario_satellite_618_configure_provisioning_products`
- `repositories` -> `scenario_satellite_618_configure_provisioning_repositories`
- `create_sync_plans` -> `scenario_satellite_618_configure_provisioning_create_sync_plans`
- `sync_plans` -> `scenario_satellite_618_configure_provisioning_sync_plans`
- `satellite_content_validate_connectivity` -> `scenario_satellite_618_configure_provisioning_satellite_content_validate_connectivity`
- `satellite_content_test_sync` -> `scenario_satellite_618_configure_provisioning_satellite_content_test_sync`

## scenario_satellite_618_install
- `satellite_6_18_deployment_enabled` -> `scenario_satellite_618_install_satellite_6_18_deployment_enabled`
- `satellite_6_18_deployment_version` -> `scenario_satellite_618_install_satellite_6_18_deployment_version`
- `satellite_rhis_environment` -> `scenario_satellite_618_install_satellite_rhis_environment`
- `satellite_6_18_deployment_validate_config` -> `scenario_satellite_618_install_satellite_6_18_deployment_validate_config`

## scenario_satellite_618_kickstart_setup
- `satellite_kickstart_config_enabled` -> `scenario_satellite_618_kickstart_setup_satellite_kickstart_config_enabled`
- `satellite_kickstart_config_version` -> `scenario_satellite_618_kickstart_setup_satellite_kickstart_config_version`
- `satellite_kickstart_config_timeout` -> `scenario_satellite_618_kickstart_setup_satellite_kickstart_config_timeout`
- `satellite_url` -> `scenario_satellite_618_kickstart_setup_satellite_url`
- `satellite_username` -> `scenario_satellite_618_kickstart_setup_satellite_username`
- `satellite_validate_ssl` -> `scenario_satellite_618_kickstart_setup_satellite_validate_ssl`
- `satellite_organization` -> `scenario_satellite_618_kickstart_setup_satellite_organization`
- `create_provisioning_templates` -> `scenario_satellite_618_kickstart_setup_create_provisioning_templates`
- `upload_kickstart_files` -> `scenario_satellite_618_kickstart_setup_upload_kickstart_files`
- `kickstart_templates` -> `scenario_satellite_618_kickstart_setup_kickstart_templates`
- `kickstart_files_path` -> `scenario_satellite_618_kickstart_setup_kickstart_files_path`
- `kickstart_web_url` -> `scenario_satellite_618_kickstart_setup_kickstart_web_url`
- `rhel9_baseos_minimal_ks` -> `scenario_satellite_618_kickstart_setup_rhel9_baseos_minimal_ks`
- `rhel10_baseos_minimal_ks` -> `scenario_satellite_618_kickstart_setup_rhel10_baseos_minimal_ks`
- `rhel9_fullstack_ks` -> `scenario_satellite_618_kickstart_setup_rhel9_fullstack_ks`
- `rhel10_fullstack_ks` -> `scenario_satellite_618_kickstart_setup_rhel10_fullstack_ks`

## scenario_satellite_activation_config
- `satellite_activation_config_enabled` -> `scenario_satellite_activation_config_satellite_activation_config_enabled`
- `satellite_activation_config_version` -> `scenario_satellite_activation_config_satellite_activation_config_version`
- `satellite_activation_config_timeout` -> `scenario_satellite_activation_config_satellite_activation_config_timeout`
- `satellite_url` -> `scenario_satellite_activation_config_satellite_url`
- `satellite_username` -> `scenario_satellite_activation_config_satellite_username`
- `satellite_validate_ssl` -> `scenario_satellite_activation_config_satellite_validate_ssl`
- `satellite_organization` -> `scenario_satellite_activation_config_satellite_organization`
- `create_activation_keys` -> `scenario_satellite_activation_config_create_activation_keys`
- `attach_subscriptions` -> `scenario_satellite_activation_config_attach_subscriptions`
- `configure_host_collections` -> `scenario_satellite_activation_config_configure_host_collections`
- `host_collections` -> `scenario_satellite_activation_config_host_collections`
- `activation_keys` -> `scenario_satellite_activation_config_activation_keys`
- `subscription_attachments` -> `scenario_satellite_activation_config_subscription_attachments`
- `repository_sets` -> `scenario_satellite_activation_config_repository_sets`
- `satellite_activation_validate_connectivity` -> `scenario_satellite_activation_config_satellite_activation_validate_connectivity`
- `satellite_activation_test_keys` -> `scenario_satellite_activation_config_satellite_activation_test_keys`

## scenario_satellite_lifecycle_config
- `satellite_lifecycle_config_enabled` -> `scenario_satellite_lifecycle_config_satellite_lifecycle_config_enabled`
- `satellite_lifecycle_config_version` -> `scenario_satellite_lifecycle_config_satellite_lifecycle_config_version`
- `satellite_lifecycle_config_timeout` -> `scenario_satellite_lifecycle_config_satellite_lifecycle_config_timeout`
- `satellite_url` -> `scenario_satellite_lifecycle_config_satellite_url`
- `satellite_username` -> `scenario_satellite_lifecycle_config_satellite_username`
- `satellite_validate_ssl` -> `scenario_satellite_lifecycle_config_satellite_validate_ssl`
- `satellite_organization` -> `scenario_satellite_lifecycle_config_satellite_organization`
- `create_lifecycle_environments` -> `scenario_satellite_lifecycle_config_create_lifecycle_environments`
- `create_content_views` -> `scenario_satellite_lifecycle_config_create_content_views`
- `create_filters` -> `scenario_satellite_lifecycle_config_create_filters`
- `publish_content_views` -> `scenario_satellite_lifecycle_config_publish_content_views`
- `promote_content_views` -> `scenario_satellite_lifecycle_config_promote_content_views`
- `lifecycle_environments` -> `scenario_satellite_lifecycle_config_lifecycle_environments`
- `content_views` -> `scenario_satellite_lifecycle_config_content_views`
- `content_view_filters` -> `scenario_satellite_lifecycle_config_content_view_filters`
- `composite_content_views` -> `scenario_satellite_lifecycle_config_composite_content_views`
- `promote_versions` -> `scenario_satellite_lifecycle_config_promote_versions`
- `satellite_lifecycle_validate_connectivity` -> `scenario_satellite_lifecycle_config_satellite_lifecycle_validate_connectivity`
- `satellite_lifecycle_test_promotion` -> `scenario_satellite_lifecycle_config_satellite_lifecycle_test_promotion`

## scenario_satellite_mail_setup
- `satellite_mail_targets` -> `scenario_satellite_mail_setup_satellite_mail_targets`
- `satellite_mail_master_vars_dest` -> `scenario_satellite_mail_setup_satellite_mail_master_vars_dest`
- `satellite_mail_inventory_dest` -> `scenario_satellite_mail_setup_satellite_mail_inventory_dest`
- `satellite_fqdn` -> `scenario_satellite_mail_setup_satellite_fqdn`
- `satellite_org` -> `scenario_satellite_mail_setup_satellite_org`
- `satellite_location` -> `scenario_satellite_mail_setup_satellite_location`
- `satellite_admin_user` -> `scenario_satellite_mail_setup_satellite_admin_user`
- `satellite_admin_password` -> `scenario_satellite_mail_setup_satellite_admin_password`
- `satellite_mail_relay` -> `scenario_satellite_mail_setup_satellite_mail_relay`
- `satellite_mail_relay_credentials` -> `scenario_satellite_mail_setup_satellite_mail_relay_credentials`
- `libvirt_host` -> `scenario_satellite_mail_setup_libvirt_host`
- `libvirt_user` -> `scenario_satellite_mail_setup_libvirt_user`
- `satellite_vm_name` -> `scenario_satellite_mail_setup_satellite_vm_name`
- `satellite_vm_hostname` -> `scenario_satellite_mail_setup_satellite_vm_hostname`
- `satellite_vm_memory_mb` -> `scenario_satellite_mail_setup_satellite_vm_memory_mb`
- `satellite_vm_vcpus` -> `scenario_satellite_mail_setup_satellite_vm_vcpus`
- `satellite_vm_disk_size_gb` -> `scenario_satellite_mail_setup_satellite_vm_disk_size_gb`
- `satellite_vm_disk_name` -> `scenario_satellite_mail_setup_satellite_vm_disk_name`
- `satellite_vm_pool` -> `scenario_satellite_mail_setup_satellite_vm_pool`
- `satellite_vm_network` -> `scenario_satellite_mail_setup_satellite_vm_network`
- `satellite_vm_root_pubkey` -> `scenario_satellite_mail_setup_satellite_vm_root_pubkey`
- `satellite_admin_pubkey` -> `scenario_satellite_mail_setup_satellite_admin_pubkey`
- `satellite_root_pubkey` -> `scenario_satellite_mail_setup_satellite_root_pubkey`
- `satellite_base_packages` -> `scenario_satellite_mail_setup_satellite_base_packages`
- `satellite_hosts_entries` -> `scenario_satellite_mail_setup_satellite_hosts_entries`
- `satellite_nameservers` -> `scenario_satellite_mail_setup_satellite_nameservers`
- `satellite_search_domain` -> `scenario_satellite_mail_setup_satellite_search_domain`
- `aap_inventory_path` -> `scenario_satellite_mail_setup_aap_inventory_path`
- `aap_admin_user` -> `scenario_satellite_mail_setup_aap_admin_user`
- `aap_admin_password` -> `scenario_satellite_mail_setup_aap_admin_password`
- `insights_account` -> `scenario_satellite_mail_setup_insights_account`
- `insights_username` -> `scenario_satellite_mail_setup_insights_username`
- `insights_password` -> `scenario_satellite_mail_setup_insights_password`

## scenario_satellite_os_configuration
- `satellite_os_config_enabled` -> `scenario_satellite_os_configuration_satellite_os_config_enabled`
- `satellite_os_config_version` -> `scenario_satellite_os_configuration_satellite_os_config_version`
- `satellite_os_config_timeout` -> `scenario_satellite_os_configuration_satellite_os_config_timeout`
- `satellite_url` -> `scenario_satellite_os_configuration_satellite_url`
- `satellite_username` -> `scenario_satellite_os_configuration_satellite_username`
- `satellite_validate_ssl` -> `scenario_satellite_os_configuration_satellite_validate_ssl`
- `satellite_organization` -> `scenario_satellite_os_configuration_satellite_organization`
- `create_operatingsystems` -> `scenario_satellite_os_configuration_create_operatingsystems`
- `create_install_media` -> `scenario_satellite_os_configuration_create_install_media`
- `create_kickstart_repo` -> `scenario_satellite_os_configuration_create_kickstart_repo`
- `configure_sync_job` -> `scenario_satellite_os_configuration_configure_sync_job`
- `operatingsystems` -> `scenario_satellite_os_configuration_operatingsystems`
- `install_media` -> `scenario_satellite_os_configuration_install_media`
- `kickstart_repository` -> `scenario_satellite_os_configuration_kickstart_repository`
- `sync_jobs` -> `scenario_satellite_os_configuration_sync_jobs`
- `partition_tables` -> `scenario_satellite_os_configuration_partition_tables`
- `bootdisk_iso` -> `scenario_satellite_os_configuration_bootdisk_iso`
