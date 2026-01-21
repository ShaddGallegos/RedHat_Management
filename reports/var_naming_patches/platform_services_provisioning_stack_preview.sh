#!/usr/bin/env bash
# Preview script for role: platform_services_provisioning_stack
set -euo pipefail

EXCLUDES="--exclude-dir=.venv-ansible --exclude-dir=.git --exclude-dir=.ansible"

TMPDIR=$(mktemp -d)
trap "rm -rf "$TMPDIR"" EXIT

cat > "$TMPDIR/replace.py" <<'PY'
import re,sys
from pathlib import Path

p=Path(sys.argv[1])
old=sys.argv[2]
new=sys.argv[3]
try:
    txt=p.read_text(encoding='utf-8',errors='ignore')
except Exception:
    txt=p.read_bytes().decode('utf-8','ignore')
pat=re.compile(r'\b' + re.escape(old) + r'\b')
print(pat.sub(new, txt), end='')
PY

echo 'Role: platform_services_provisioning_stack'
echo 'Mappings:'
echo '  provisioning_host -> platform_services_provisioning_stack_provisioning_host'
echo '  provisioning_host_fqdn -> platform_services_provisioning_stack_provisioning_host_fqdn'
echo '  provisioning_primary_interface -> platform_services_provisioning_stack_provisioning_primary_interface'
echo '  provisioning_primary_interface_type -> platform_services_provisioning_stack_provisioning_primary_interface_type'
echo '  provisioning_primary_connection_type -> platform_services_provisioning_stack_provisioning_primary_connection_type'
echo '  provisioning_primary_autoconnect -> platform_services_provisioning_stack_provisioning_primary_autoconnect'
echo '  provisioning_primary_description -> platform_services_provisioning_stack_provisioning_primary_description'
echo '  provisioning_secondary_interface -> platform_services_provisioning_stack_provisioning_secondary_interface'
echo '  provisioning_interface_ip -> platform_services_provisioning_stack_provisioning_interface_ip'
echo '  provisioning_interface_netmask -> platform_services_provisioning_stack_provisioning_interface_netmask'
echo '  provisioning_interface_gateway -> platform_services_provisioning_stack_provisioning_interface_gateway'
echo '  provisioning_interface_network -> platform_services_provisioning_stack_provisioning_interface_network'
echo '  provisioning_interface_broadcast -> platform_services_provisioning_stack_provisioning_interface_broadcast'
echo '  provisioning_secondary_connection_type -> platform_services_provisioning_stack_provisioning_secondary_connection_type'
echo '  provisioning_secondary_autoconnect -> platform_services_provisioning_stack_provisioning_secondary_autoconnect'
echo '  provisioning_secondary_description -> platform_services_provisioning_stack_provisioning_secondary_description'
echo '  dhcp_enabled -> platform_services_provisioning_stack_dhcp_enabled'
echo '  dhcp_package -> platform_services_provisioning_stack_dhcp_package'
echo '  dhcp_service -> platform_services_provisioning_stack_dhcp_service'
echo '  dhcp_config_file -> platform_services_provisioning_stack_dhcp_config_file'
echo '  dhcp_leases_file -> platform_services_provisioning_stack_dhcp_leases_file'
echo '  dhcp_subnet -> platform_services_provisioning_stack_dhcp_subnet'
echo '  dhcp_netmask -> platform_services_provisioning_stack_dhcp_netmask'
echo '  dhcp_range_start -> platform_services_provisioning_stack_dhcp_range_start'
echo '  dhcp_range_end -> platform_services_provisioning_stack_dhcp_range_end'
echo '  dhcp_lease_time -> platform_services_provisioning_stack_dhcp_lease_time'
echo '  dhcp_max_lease_time -> platform_services_provisioning_stack_dhcp_max_lease_time'
echo '  dhcp_default_lease_time -> platform_services_provisioning_stack_dhcp_default_lease_time'
echo '  dhcp_option_routers -> platform_services_provisioning_stack_dhcp_option_routers'
echo '  dhcp_option_domain_name -> platform_services_provisioning_stack_dhcp_option_domain_name'
echo '  dhcp_option_domain_name_servers -> platform_services_provisioning_stack_dhcp_option_domain_name_servers'
echo '  dhcp_option_ntp_servers -> platform_services_provisioning_stack_dhcp_option_ntp_servers'
echo '  dhcp_option_netbios_name_servers -> platform_services_provisioning_stack_dhcp_option_netbios_name_servers'
echo '  pxe_enabled -> platform_services_provisioning_stack_pxe_enabled'
echo '  pxe_bootloader -> platform_services_provisioning_stack_pxe_bootloader'
echo '  pxe_boot_file -> platform_services_provisioning_stack_pxe_boot_file'
echo '  pxe_menu_file -> platform_services_provisioning_stack_pxe_menu_file'
echo '  pxe_menu_label -> platform_services_provisioning_stack_pxe_menu_label'
echo '  pxe_kernel_append_params -> platform_services_provisioning_stack_pxe_kernel_append_params'
echo '  tftp_enabled -> platform_services_provisioning_stack_tftp_enabled'
echo '  tftp_package -> platform_services_provisioning_stack_tftp_package'
echo '  tftp_service -> platform_services_provisioning_stack_tftp_service'
echo '  tftp_socket_service -> platform_services_provisioning_stack_tftp_socket_service'
echo '  tftp_root -> platform_services_provisioning_stack_tftp_root'
echo '  tftp_user -> platform_services_provisioning_stack_tftp_user'
echo '  tftp_group -> platform_services_provisioning_stack_tftp_group'
echo '  tftp_permissions -> platform_services_provisioning_stack_tftp_permissions'
echo '  tftp_file_permissions -> platform_services_provisioning_stack_tftp_file_permissions'
echo '  dns_enabled -> platform_services_provisioning_stack_dns_enabled'
echo '  dns_package -> platform_services_provisioning_stack_dns_package'
echo '  dns_service -> platform_services_provisioning_stack_dns_service'
echo '  dns_config_file -> platform_services_provisioning_stack_dns_config_file'
echo '  dns_zones_dir -> platform_services_provisioning_stack_dns_zones_dir'
echo '  dns_zone_name -> platform_services_provisioning_stack_dns_zone_name'
echo '  dns_zone_file -> platform_services_provisioning_stack_dns_zone_file'
echo '  dns_secondary_zone_name -> platform_services_provisioning_stack_dns_secondary_zone_name'
echo '  dns_secondary_zone_file -> platform_services_provisioning_stack_dns_secondary_zone_file'
echo '  dns_nameserver_ip -> platform_services_provisioning_stack_dns_nameserver_ip'
echo '  dns_secondary_ip -> platform_services_provisioning_stack_dns_secondary_ip'
echo '  dns_forward_servers -> platform_services_provisioning_stack_dns_forward_servers'
echo '  resolv_conf_path -> platform_services_provisioning_stack_resolv_conf_path'
echo '  resolv_conf_nameservers -> platform_services_provisioning_stack_resolv_conf_nameservers'
echo '  resolv_conf_search_domains -> platform_services_provisioning_stack_resolv_conf_search_domains'
echo '  resolv_conf_options -> platform_services_provisioning_stack_resolv_conf_options'
echo '  service_restart_enabled -> platform_services_provisioning_stack_service_restart_enabled'
echo '  service_enable_on_boot -> platform_services_provisioning_stack_service_enable_on_boot'
echo '  firewall_enabled -> platform_services_provisioning_stack_firewall_enabled'
echo '  firewall_rules -> platform_services_provisioning_stack_firewall_rules'
echo '  logging_enabled -> platform_services_provisioning_stack_logging_enabled'
echo '  log_level -> platform_services_provisioning_stack_log_level'
echo '  dhcp_log_file -> platform_services_provisioning_stack_dhcp_log_file'
echo '  dns_log_file -> platform_services_provisioning_stack_dns_log_file'
echo '  tftp_log_file -> platform_services_provisioning_stack_tftp_log_file'
echo '  backup_enabled -> platform_services_provisioning_stack_backup_enabled'
echo '  backup_configs -> platform_services_provisioning_stack_backup_configs'
echo '  backup_directory -> platform_services_provisioning_stack_backup_directory'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: provisioning_host -> platform_services_provisioning_stack_provisioning_host'
grep -R -l -w -e provisioning_host $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" provisioning_host platform_services_provisioning_stack_provisioning_host > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e provisioning_host $EXCLUDES .) || true
echo '---'
echo 'Mapping: provisioning_host_fqdn -> platform_services_provisioning_stack_provisioning_host_fqdn'
grep -R -l -w -e provisioning_host_fqdn $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" provisioning_host_fqdn platform_services_provisioning_stack_provisioning_host_fqdn > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e provisioning_host_fqdn $EXCLUDES .) || true
echo '---'
echo 'Mapping: provisioning_primary_interface -> platform_services_provisioning_stack_provisioning_primary_interface'
grep -R -l -w -e provisioning_primary_interface $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" provisioning_primary_interface platform_services_provisioning_stack_provisioning_primary_interface > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e provisioning_primary_interface $EXCLUDES .) || true
echo '---'
echo 'Mapping: provisioning_primary_interface_type -> platform_services_provisioning_stack_provisioning_primary_interface_type'
grep -R -l -w -e provisioning_primary_interface_type $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" provisioning_primary_interface_type platform_services_provisioning_stack_provisioning_primary_interface_type > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e provisioning_primary_interface_type $EXCLUDES .) || true
echo '---'
echo 'Mapping: provisioning_primary_connection_type -> platform_services_provisioning_stack_provisioning_primary_connection_type'
grep -R -l -w -e provisioning_primary_connection_type $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" provisioning_primary_connection_type platform_services_provisioning_stack_provisioning_primary_connection_type > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e provisioning_primary_connection_type $EXCLUDES .) || true
echo '---'
echo 'Mapping: provisioning_primary_autoconnect -> platform_services_provisioning_stack_provisioning_primary_autoconnect'
grep -R -l -w -e provisioning_primary_autoconnect $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" provisioning_primary_autoconnect platform_services_provisioning_stack_provisioning_primary_autoconnect > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e provisioning_primary_autoconnect $EXCLUDES .) || true
echo '---'
echo 'Mapping: provisioning_primary_description -> platform_services_provisioning_stack_provisioning_primary_description'
grep -R -l -w -e provisioning_primary_description $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" provisioning_primary_description platform_services_provisioning_stack_provisioning_primary_description > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e provisioning_primary_description $EXCLUDES .) || true
echo '---'
echo 'Mapping: provisioning_secondary_interface -> platform_services_provisioning_stack_provisioning_secondary_interface'
grep -R -l -w -e provisioning_secondary_interface $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" provisioning_secondary_interface platform_services_provisioning_stack_provisioning_secondary_interface > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e provisioning_secondary_interface $EXCLUDES .) || true
echo '---'
echo 'Mapping: provisioning_interface_ip -> platform_services_provisioning_stack_provisioning_interface_ip'
grep -R -l -w -e provisioning_interface_ip $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" provisioning_interface_ip platform_services_provisioning_stack_provisioning_interface_ip > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e provisioning_interface_ip $EXCLUDES .) || true
echo '---'
echo 'Mapping: provisioning_interface_netmask -> platform_services_provisioning_stack_provisioning_interface_netmask'
grep -R -l -w -e provisioning_interface_netmask $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" provisioning_interface_netmask platform_services_provisioning_stack_provisioning_interface_netmask > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e provisioning_interface_netmask $EXCLUDES .) || true
echo '---'
echo 'Mapping: provisioning_interface_gateway -> platform_services_provisioning_stack_provisioning_interface_gateway'
grep -R -l -w -e provisioning_interface_gateway $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" provisioning_interface_gateway platform_services_provisioning_stack_provisioning_interface_gateway > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e provisioning_interface_gateway $EXCLUDES .) || true
echo '---'
echo 'Mapping: provisioning_interface_network -> platform_services_provisioning_stack_provisioning_interface_network'
grep -R -l -w -e provisioning_interface_network $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" provisioning_interface_network platform_services_provisioning_stack_provisioning_interface_network > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e provisioning_interface_network $EXCLUDES .) || true
echo '---'
echo 'Mapping: provisioning_interface_broadcast -> platform_services_provisioning_stack_provisioning_interface_broadcast'
grep -R -l -w -e provisioning_interface_broadcast $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" provisioning_interface_broadcast platform_services_provisioning_stack_provisioning_interface_broadcast > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e provisioning_interface_broadcast $EXCLUDES .) || true
echo '---'
echo 'Mapping: provisioning_secondary_connection_type -> platform_services_provisioning_stack_provisioning_secondary_connection_type'
grep -R -l -w -e provisioning_secondary_connection_type $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" provisioning_secondary_connection_type platform_services_provisioning_stack_provisioning_secondary_connection_type > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e provisioning_secondary_connection_type $EXCLUDES .) || true
echo '---'
echo 'Mapping: provisioning_secondary_autoconnect -> platform_services_provisioning_stack_provisioning_secondary_autoconnect'
grep -R -l -w -e provisioning_secondary_autoconnect $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" provisioning_secondary_autoconnect platform_services_provisioning_stack_provisioning_secondary_autoconnect > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e provisioning_secondary_autoconnect $EXCLUDES .) || true
echo '---'
echo 'Mapping: provisioning_secondary_description -> platform_services_provisioning_stack_provisioning_secondary_description'
grep -R -l -w -e provisioning_secondary_description $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" provisioning_secondary_description platform_services_provisioning_stack_provisioning_secondary_description > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e provisioning_secondary_description $EXCLUDES .) || true
echo '---'
echo 'Mapping: dhcp_enabled -> platform_services_provisioning_stack_dhcp_enabled'
grep -R -l -w -e dhcp_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dhcp_enabled platform_services_provisioning_stack_dhcp_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dhcp_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: dhcp_package -> platform_services_provisioning_stack_dhcp_package'
grep -R -l -w -e dhcp_package $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dhcp_package platform_services_provisioning_stack_dhcp_package > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dhcp_package $EXCLUDES .) || true
echo '---'
echo 'Mapping: dhcp_service -> platform_services_provisioning_stack_dhcp_service'
grep -R -l -w -e dhcp_service $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dhcp_service platform_services_provisioning_stack_dhcp_service > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dhcp_service $EXCLUDES .) || true
echo '---'
echo 'Mapping: dhcp_config_file -> platform_services_provisioning_stack_dhcp_config_file'
grep -R -l -w -e dhcp_config_file $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dhcp_config_file platform_services_provisioning_stack_dhcp_config_file > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dhcp_config_file $EXCLUDES .) || true
echo '---'
echo 'Mapping: dhcp_leases_file -> platform_services_provisioning_stack_dhcp_leases_file'
grep -R -l -w -e dhcp_leases_file $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dhcp_leases_file platform_services_provisioning_stack_dhcp_leases_file > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dhcp_leases_file $EXCLUDES .) || true
echo '---'
echo 'Mapping: dhcp_subnet -> platform_services_provisioning_stack_dhcp_subnet'
grep -R -l -w -e dhcp_subnet $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dhcp_subnet platform_services_provisioning_stack_dhcp_subnet > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dhcp_subnet $EXCLUDES .) || true
echo '---'
echo 'Mapping: dhcp_netmask -> platform_services_provisioning_stack_dhcp_netmask'
grep -R -l -w -e dhcp_netmask $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dhcp_netmask platform_services_provisioning_stack_dhcp_netmask > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dhcp_netmask $EXCLUDES .) || true
echo '---'
echo 'Mapping: dhcp_range_start -> platform_services_provisioning_stack_dhcp_range_start'
grep -R -l -w -e dhcp_range_start $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dhcp_range_start platform_services_provisioning_stack_dhcp_range_start > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dhcp_range_start $EXCLUDES .) || true
echo '---'
echo 'Mapping: dhcp_range_end -> platform_services_provisioning_stack_dhcp_range_end'
grep -R -l -w -e dhcp_range_end $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dhcp_range_end platform_services_provisioning_stack_dhcp_range_end > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dhcp_range_end $EXCLUDES .) || true
echo '---'
echo 'Mapping: dhcp_lease_time -> platform_services_provisioning_stack_dhcp_lease_time'
grep -R -l -w -e dhcp_lease_time $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dhcp_lease_time platform_services_provisioning_stack_dhcp_lease_time > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dhcp_lease_time $EXCLUDES .) || true
echo '---'
echo 'Mapping: dhcp_max_lease_time -> platform_services_provisioning_stack_dhcp_max_lease_time'
grep -R -l -w -e dhcp_max_lease_time $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dhcp_max_lease_time platform_services_provisioning_stack_dhcp_max_lease_time > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dhcp_max_lease_time $EXCLUDES .) || true
echo '---'
echo 'Mapping: dhcp_default_lease_time -> platform_services_provisioning_stack_dhcp_default_lease_time'
grep -R -l -w -e dhcp_default_lease_time $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dhcp_default_lease_time platform_services_provisioning_stack_dhcp_default_lease_time > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dhcp_default_lease_time $EXCLUDES .) || true
echo '---'
echo 'Mapping: dhcp_option_routers -> platform_services_provisioning_stack_dhcp_option_routers'
grep -R -l -w -e dhcp_option_routers $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dhcp_option_routers platform_services_provisioning_stack_dhcp_option_routers > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dhcp_option_routers $EXCLUDES .) || true
echo '---'
echo 'Mapping: dhcp_option_domain_name -> platform_services_provisioning_stack_dhcp_option_domain_name'
grep -R -l -w -e dhcp_option_domain_name $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dhcp_option_domain_name platform_services_provisioning_stack_dhcp_option_domain_name > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dhcp_option_domain_name $EXCLUDES .) || true
echo '---'
echo 'Mapping: dhcp_option_domain_name_servers -> platform_services_provisioning_stack_dhcp_option_domain_name_servers'
grep -R -l -w -e dhcp_option_domain_name_servers $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dhcp_option_domain_name_servers platform_services_provisioning_stack_dhcp_option_domain_name_servers > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dhcp_option_domain_name_servers $EXCLUDES .) || true
echo '---'
echo 'Mapping: dhcp_option_ntp_servers -> platform_services_provisioning_stack_dhcp_option_ntp_servers'
grep -R -l -w -e dhcp_option_ntp_servers $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dhcp_option_ntp_servers platform_services_provisioning_stack_dhcp_option_ntp_servers > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dhcp_option_ntp_servers $EXCLUDES .) || true
echo '---'
echo 'Mapping: dhcp_option_netbios_name_servers -> platform_services_provisioning_stack_dhcp_option_netbios_name_servers'
grep -R -l -w -e dhcp_option_netbios_name_servers $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dhcp_option_netbios_name_servers platform_services_provisioning_stack_dhcp_option_netbios_name_servers > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dhcp_option_netbios_name_servers $EXCLUDES .) || true
echo '---'
echo 'Mapping: pxe_enabled -> platform_services_provisioning_stack_pxe_enabled'
grep -R -l -w -e pxe_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" pxe_enabled platform_services_provisioning_stack_pxe_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e pxe_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: pxe_bootloader -> platform_services_provisioning_stack_pxe_bootloader'
grep -R -l -w -e pxe_bootloader $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" pxe_bootloader platform_services_provisioning_stack_pxe_bootloader > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e pxe_bootloader $EXCLUDES .) || true
echo '---'
echo 'Mapping: pxe_boot_file -> platform_services_provisioning_stack_pxe_boot_file'
grep -R -l -w -e pxe_boot_file $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" pxe_boot_file platform_services_provisioning_stack_pxe_boot_file > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e pxe_boot_file $EXCLUDES .) || true
echo '---'
echo 'Mapping: pxe_menu_file -> platform_services_provisioning_stack_pxe_menu_file'
grep -R -l -w -e pxe_menu_file $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" pxe_menu_file platform_services_provisioning_stack_pxe_menu_file > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e pxe_menu_file $EXCLUDES .) || true
echo '---'
echo 'Mapping: pxe_menu_label -> platform_services_provisioning_stack_pxe_menu_label'
grep -R -l -w -e pxe_menu_label $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" pxe_menu_label platform_services_provisioning_stack_pxe_menu_label > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e pxe_menu_label $EXCLUDES .) || true
echo '---'
echo 'Mapping: pxe_kernel_append_params -> platform_services_provisioning_stack_pxe_kernel_append_params'
grep -R -l -w -e pxe_kernel_append_params $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" pxe_kernel_append_params platform_services_provisioning_stack_pxe_kernel_append_params > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e pxe_kernel_append_params $EXCLUDES .) || true
echo '---'
echo 'Mapping: tftp_enabled -> platform_services_provisioning_stack_tftp_enabled'
grep -R -l -w -e tftp_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" tftp_enabled platform_services_provisioning_stack_tftp_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e tftp_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: tftp_package -> platform_services_provisioning_stack_tftp_package'
grep -R -l -w -e tftp_package $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" tftp_package platform_services_provisioning_stack_tftp_package > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e tftp_package $EXCLUDES .) || true
echo '---'
echo 'Mapping: tftp_service -> platform_services_provisioning_stack_tftp_service'
grep -R -l -w -e tftp_service $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" tftp_service platform_services_provisioning_stack_tftp_service > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e tftp_service $EXCLUDES .) || true
echo '---'
echo 'Mapping: tftp_socket_service -> platform_services_provisioning_stack_tftp_socket_service'
grep -R -l -w -e tftp_socket_service $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" tftp_socket_service platform_services_provisioning_stack_tftp_socket_service > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e tftp_socket_service $EXCLUDES .) || true
echo '---'
echo 'Mapping: tftp_root -> platform_services_provisioning_stack_tftp_root'
grep -R -l -w -e tftp_root $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" tftp_root platform_services_provisioning_stack_tftp_root > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e tftp_root $EXCLUDES .) || true
echo '---'
echo 'Mapping: tftp_user -> platform_services_provisioning_stack_tftp_user'
grep -R -l -w -e tftp_user $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" tftp_user platform_services_provisioning_stack_tftp_user > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e tftp_user $EXCLUDES .) || true
echo '---'
echo 'Mapping: tftp_group -> platform_services_provisioning_stack_tftp_group'
grep -R -l -w -e tftp_group $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" tftp_group platform_services_provisioning_stack_tftp_group > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e tftp_group $EXCLUDES .) || true
echo '---'
echo 'Mapping: tftp_permissions -> platform_services_provisioning_stack_tftp_permissions'
grep -R -l -w -e tftp_permissions $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" tftp_permissions platform_services_provisioning_stack_tftp_permissions > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e tftp_permissions $EXCLUDES .) || true
echo '---'
echo 'Mapping: tftp_file_permissions -> platform_services_provisioning_stack_tftp_file_permissions'
grep -R -l -w -e tftp_file_permissions $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" tftp_file_permissions platform_services_provisioning_stack_tftp_file_permissions > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e tftp_file_permissions $EXCLUDES .) || true
echo '---'
echo 'Mapping: dns_enabled -> platform_services_provisioning_stack_dns_enabled'
grep -R -l -w -e dns_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dns_enabled platform_services_provisioning_stack_dns_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dns_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: dns_package -> platform_services_provisioning_stack_dns_package'
grep -R -l -w -e dns_package $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dns_package platform_services_provisioning_stack_dns_package > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dns_package $EXCLUDES .) || true
echo '---'
echo 'Mapping: dns_service -> platform_services_provisioning_stack_dns_service'
grep -R -l -w -e dns_service $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dns_service platform_services_provisioning_stack_dns_service > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dns_service $EXCLUDES .) || true
echo '---'
echo 'Mapping: dns_config_file -> platform_services_provisioning_stack_dns_config_file'
grep -R -l -w -e dns_config_file $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dns_config_file platform_services_provisioning_stack_dns_config_file > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dns_config_file $EXCLUDES .) || true
echo '---'
echo 'Mapping: dns_zones_dir -> platform_services_provisioning_stack_dns_zones_dir'
grep -R -l -w -e dns_zones_dir $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dns_zones_dir platform_services_provisioning_stack_dns_zones_dir > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dns_zones_dir $EXCLUDES .) || true
echo '---'
echo 'Mapping: dns_zone_name -> platform_services_provisioning_stack_dns_zone_name'
grep -R -l -w -e dns_zone_name $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dns_zone_name platform_services_provisioning_stack_dns_zone_name > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dns_zone_name $EXCLUDES .) || true
echo '---'
echo 'Mapping: dns_zone_file -> platform_services_provisioning_stack_dns_zone_file'
grep -R -l -w -e dns_zone_file $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dns_zone_file platform_services_provisioning_stack_dns_zone_file > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dns_zone_file $EXCLUDES .) || true
echo '---'
echo 'Mapping: dns_secondary_zone_name -> platform_services_provisioning_stack_dns_secondary_zone_name'
grep -R -l -w -e dns_secondary_zone_name $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dns_secondary_zone_name platform_services_provisioning_stack_dns_secondary_zone_name > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dns_secondary_zone_name $EXCLUDES .) || true
echo '---'
echo 'Mapping: dns_secondary_zone_file -> platform_services_provisioning_stack_dns_secondary_zone_file'
grep -R -l -w -e dns_secondary_zone_file $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dns_secondary_zone_file platform_services_provisioning_stack_dns_secondary_zone_file > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dns_secondary_zone_file $EXCLUDES .) || true
echo '---'
echo 'Mapping: dns_nameserver_ip -> platform_services_provisioning_stack_dns_nameserver_ip'
grep -R -l -w -e dns_nameserver_ip $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dns_nameserver_ip platform_services_provisioning_stack_dns_nameserver_ip > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dns_nameserver_ip $EXCLUDES .) || true
echo '---'
echo 'Mapping: dns_secondary_ip -> platform_services_provisioning_stack_dns_secondary_ip'
grep -R -l -w -e dns_secondary_ip $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dns_secondary_ip platform_services_provisioning_stack_dns_secondary_ip > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dns_secondary_ip $EXCLUDES .) || true
echo '---'
echo 'Mapping: dns_forward_servers -> platform_services_provisioning_stack_dns_forward_servers'
grep -R -l -w -e dns_forward_servers $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dns_forward_servers platform_services_provisioning_stack_dns_forward_servers > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dns_forward_servers $EXCLUDES .) || true
echo '---'
echo 'Mapping: resolv_conf_path -> platform_services_provisioning_stack_resolv_conf_path'
grep -R -l -w -e resolv_conf_path $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" resolv_conf_path platform_services_provisioning_stack_resolv_conf_path > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e resolv_conf_path $EXCLUDES .) || true
echo '---'
echo 'Mapping: resolv_conf_nameservers -> platform_services_provisioning_stack_resolv_conf_nameservers'
grep -R -l -w -e resolv_conf_nameservers $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" resolv_conf_nameservers platform_services_provisioning_stack_resolv_conf_nameservers > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e resolv_conf_nameservers $EXCLUDES .) || true
echo '---'
echo 'Mapping: resolv_conf_search_domains -> platform_services_provisioning_stack_resolv_conf_search_domains'
grep -R -l -w -e resolv_conf_search_domains $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" resolv_conf_search_domains platform_services_provisioning_stack_resolv_conf_search_domains > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e resolv_conf_search_domains $EXCLUDES .) || true
echo '---'
echo 'Mapping: resolv_conf_options -> platform_services_provisioning_stack_resolv_conf_options'
grep -R -l -w -e resolv_conf_options $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" resolv_conf_options platform_services_provisioning_stack_resolv_conf_options > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e resolv_conf_options $EXCLUDES .) || true
echo '---'
echo 'Mapping: service_restart_enabled -> platform_services_provisioning_stack_service_restart_enabled'
grep -R -l -w -e service_restart_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" service_restart_enabled platform_services_provisioning_stack_service_restart_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e service_restart_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: service_enable_on_boot -> platform_services_provisioning_stack_service_enable_on_boot'
grep -R -l -w -e service_enable_on_boot $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" service_enable_on_boot platform_services_provisioning_stack_service_enable_on_boot > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e service_enable_on_boot $EXCLUDES .) || true
echo '---'
echo 'Mapping: firewall_enabled -> platform_services_provisioning_stack_firewall_enabled'
grep -R -l -w -e firewall_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" firewall_enabled platform_services_provisioning_stack_firewall_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e firewall_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: firewall_rules -> platform_services_provisioning_stack_firewall_rules'
grep -R -l -w -e firewall_rules $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" firewall_rules platform_services_provisioning_stack_firewall_rules > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e firewall_rules $EXCLUDES .) || true
echo '---'
echo 'Mapping: logging_enabled -> platform_services_provisioning_stack_logging_enabled'
grep -R -l -w -e logging_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" logging_enabled platform_services_provisioning_stack_logging_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e logging_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: log_level -> platform_services_provisioning_stack_log_level'
grep -R -l -w -e log_level $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" log_level platform_services_provisioning_stack_log_level > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e log_level $EXCLUDES .) || true
echo '---'
echo 'Mapping: dhcp_log_file -> platform_services_provisioning_stack_dhcp_log_file'
grep -R -l -w -e dhcp_log_file $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dhcp_log_file platform_services_provisioning_stack_dhcp_log_file > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dhcp_log_file $EXCLUDES .) || true
echo '---'
echo 'Mapping: dns_log_file -> platform_services_provisioning_stack_dns_log_file'
grep -R -l -w -e dns_log_file $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dns_log_file platform_services_provisioning_stack_dns_log_file > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dns_log_file $EXCLUDES .) || true
echo '---'
echo 'Mapping: tftp_log_file -> platform_services_provisioning_stack_tftp_log_file'
grep -R -l -w -e tftp_log_file $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" tftp_log_file platform_services_provisioning_stack_tftp_log_file > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e tftp_log_file $EXCLUDES .) || true
echo '---'
echo 'Mapping: backup_enabled -> platform_services_provisioning_stack_backup_enabled'
grep -R -l -w -e backup_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" backup_enabled platform_services_provisioning_stack_backup_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e backup_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: backup_configs -> platform_services_provisioning_stack_backup_configs'
grep -R -l -w -e backup_configs $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" backup_configs platform_services_provisioning_stack_backup_configs > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e backup_configs $EXCLUDES .) || true
echo '---'
echo 'Mapping: backup_directory -> platform_services_provisioning_stack_backup_directory'
grep -R -l -w -e backup_directory $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" backup_directory platform_services_provisioning_stack_backup_directory > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e backup_directory $EXCLUDES .) || true
echo 'Preview complete.'
