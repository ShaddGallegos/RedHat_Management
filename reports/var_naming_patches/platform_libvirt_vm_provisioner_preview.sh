#!/usr/bin/env bash
# Preview script for role: platform_libvirt_vm_provisioner
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

echo 'Role: platform_libvirt_vm_provisioner'
echo 'Mappings:'
echo '  libvirt_vm_name -> platform_libvirt_vm_provisioner_libvirt_vm_name'
echo '  libvirt_vm_cpus -> platform_libvirt_vm_provisioner_libvirt_vm_cpus'
echo '  libvirt_vm_memory -> platform_libvirt_vm_provisioner_libvirt_vm_memory'
echo '  libvirt_vm_disk -> platform_libvirt_vm_provisioner_libvirt_vm_disk'
echo '  libvirt_vm_network -> platform_libvirt_vm_provisioner_libvirt_vm_network'
echo '  libvirt_iso_file -> platform_libvirt_vm_provisioner_libvirt_iso_file'
echo '  libvirt_kickstart_file -> platform_libvirt_vm_provisioner_libvirt_kickstart_file'
echo '  libvirt_kickstart_port -> platform_libvirt_vm_provisioner_libvirt_kickstart_port'
echo '  libvirt_kickstart_http_dir -> platform_libvirt_vm_provisioner_libvirt_kickstart_http_dir'
echo '  libvirt_monitor_timeout -> platform_libvirt_vm_provisioner_libvirt_monitor_timeout'
echo '  libvirt_monitor_interval -> platform_libvirt_vm_provisioner_libvirt_monitor_interval'
echo '  libvirt_bridge_device -> platform_libvirt_vm_provisioner_libvirt_bridge_device'
echo '  libvirt_mac_address -> platform_libvirt_vm_provisioner_libvirt_mac_address'
echo '  libvirt_static_ip -> platform_libvirt_vm_provisioner_libvirt_static_ip'
echo '  libvirt_gateway -> platform_libvirt_vm_provisioner_libvirt_gateway'
echo '  libvirt_nameserver -> platform_libvirt_vm_provisioner_libvirt_nameserver'
echo '  libvirt_root_password -> platform_libvirt_vm_provisioner_libvirt_root_password'
echo '  libvirt_ansible_user -> platform_libvirt_vm_provisioner_libvirt_ansible_user'
echo '  libvirt_packages -> platform_libvirt_vm_provisioner_libvirt_packages'
echo '  libvirt_install_ansible -> platform_libvirt_vm_provisioner_libvirt_install_ansible'
echo '  libvirt_enable_selinux -> platform_libvirt_vm_provisioner_libvirt_enable_selinux'
echo '  libvirt_enable_firewall -> platform_libvirt_vm_provisioner_libvirt_enable_firewall'
echo '  libvirt_firewall_services -> platform_libvirt_vm_provisioner_libvirt_firewall_services'
echo '  libvirt_cleanup_http_server -> platform_libvirt_vm_provisioner_libvirt_cleanup_http_server'
echo '  libvirt_cleanup_temp_files -> platform_libvirt_vm_provisioner_libvirt_cleanup_temp_files'
echo '  libvirt_log_level -> platform_libvirt_vm_provisioner_libvirt_log_level'
echo '  libvirt_save_logs -> platform_libvirt_vm_provisioner_libvirt_save_logs'
echo '  libvirt_logs_dir -> platform_libvirt_vm_provisioner_libvirt_logs_dir'
echo '  use_cloud_init_iso -> platform_libvirt_vm_provisioner_use_cloud_init_iso'
echo '  use_cloud_init_disk -> platform_libvirt_vm_provisioner_use_cloud_init_disk'
echo '  cloud_init_allow_password_auth -> platform_libvirt_vm_provisioner_cloud_init_allow_password_auth'
echo '  seed_disk_size_mb -> platform_libvirt_vm_provisioner_seed_disk_size_mb'
echo '  ssh_public_key -> platform_libvirt_vm_provisioner_ssh_public_key'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: libvirt_vm_name -> platform_libvirt_vm_provisioner_libvirt_vm_name'
grep -R -l -w -e libvirt_vm_name $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_vm_name platform_libvirt_vm_provisioner_libvirt_vm_name > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_vm_name $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_vm_cpus -> platform_libvirt_vm_provisioner_libvirt_vm_cpus'
grep -R -l -w -e libvirt_vm_cpus $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_vm_cpus platform_libvirt_vm_provisioner_libvirt_vm_cpus > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_vm_cpus $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_vm_memory -> platform_libvirt_vm_provisioner_libvirt_vm_memory'
grep -R -l -w -e libvirt_vm_memory $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_vm_memory platform_libvirt_vm_provisioner_libvirt_vm_memory > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_vm_memory $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_vm_disk -> platform_libvirt_vm_provisioner_libvirt_vm_disk'
grep -R -l -w -e libvirt_vm_disk $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_vm_disk platform_libvirt_vm_provisioner_libvirt_vm_disk > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_vm_disk $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_vm_network -> platform_libvirt_vm_provisioner_libvirt_vm_network'
grep -R -l -w -e libvirt_vm_network $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_vm_network platform_libvirt_vm_provisioner_libvirt_vm_network > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_vm_network $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_iso_file -> platform_libvirt_vm_provisioner_libvirt_iso_file'
grep -R -l -w -e libvirt_iso_file $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_iso_file platform_libvirt_vm_provisioner_libvirt_iso_file > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_iso_file $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_kickstart_file -> platform_libvirt_vm_provisioner_libvirt_kickstart_file'
grep -R -l -w -e libvirt_kickstart_file $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_kickstart_file platform_libvirt_vm_provisioner_libvirt_kickstart_file > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_kickstart_file $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_kickstart_port -> platform_libvirt_vm_provisioner_libvirt_kickstart_port'
grep -R -l -w -e libvirt_kickstart_port $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_kickstart_port platform_libvirt_vm_provisioner_libvirt_kickstart_port > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_kickstart_port $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_kickstart_http_dir -> platform_libvirt_vm_provisioner_libvirt_kickstart_http_dir'
grep -R -l -w -e libvirt_kickstart_http_dir $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_kickstart_http_dir platform_libvirt_vm_provisioner_libvirt_kickstart_http_dir > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_kickstart_http_dir $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_monitor_timeout -> platform_libvirt_vm_provisioner_libvirt_monitor_timeout'
grep -R -l -w -e libvirt_monitor_timeout $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_monitor_timeout platform_libvirt_vm_provisioner_libvirt_monitor_timeout > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_monitor_timeout $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_monitor_interval -> platform_libvirt_vm_provisioner_libvirt_monitor_interval'
grep -R -l -w -e libvirt_monitor_interval $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_monitor_interval platform_libvirt_vm_provisioner_libvirt_monitor_interval > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_monitor_interval $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_bridge_device -> platform_libvirt_vm_provisioner_libvirt_bridge_device'
grep -R -l -w -e libvirt_bridge_device $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_bridge_device platform_libvirt_vm_provisioner_libvirt_bridge_device > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_bridge_device $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_mac_address -> platform_libvirt_vm_provisioner_libvirt_mac_address'
grep -R -l -w -e libvirt_mac_address $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_mac_address platform_libvirt_vm_provisioner_libvirt_mac_address > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_mac_address $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_static_ip -> platform_libvirt_vm_provisioner_libvirt_static_ip'
grep -R -l -w -e libvirt_static_ip $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_static_ip platform_libvirt_vm_provisioner_libvirt_static_ip > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_static_ip $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_gateway -> platform_libvirt_vm_provisioner_libvirt_gateway'
grep -R -l -w -e libvirt_gateway $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_gateway platform_libvirt_vm_provisioner_libvirt_gateway > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_gateway $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_nameserver -> platform_libvirt_vm_provisioner_libvirt_nameserver'
grep -R -l -w -e libvirt_nameserver $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_nameserver platform_libvirt_vm_provisioner_libvirt_nameserver > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_nameserver $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_root_password -> platform_libvirt_vm_provisioner_libvirt_root_password'
grep -R -l -w -e libvirt_root_password $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_root_password platform_libvirt_vm_provisioner_libvirt_root_password > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_root_password $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_ansible_user -> platform_libvirt_vm_provisioner_libvirt_ansible_user'
grep -R -l -w -e libvirt_ansible_user $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_ansible_user platform_libvirt_vm_provisioner_libvirt_ansible_user > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_ansible_user $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_packages -> platform_libvirt_vm_provisioner_libvirt_packages'
grep -R -l -w -e libvirt_packages $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_packages platform_libvirt_vm_provisioner_libvirt_packages > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_packages $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_install_ansible -> platform_libvirt_vm_provisioner_libvirt_install_ansible'
grep -R -l -w -e libvirt_install_ansible $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_install_ansible platform_libvirt_vm_provisioner_libvirt_install_ansible > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_install_ansible $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_enable_selinux -> platform_libvirt_vm_provisioner_libvirt_enable_selinux'
grep -R -l -w -e libvirt_enable_selinux $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_enable_selinux platform_libvirt_vm_provisioner_libvirt_enable_selinux > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_enable_selinux $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_enable_firewall -> platform_libvirt_vm_provisioner_libvirt_enable_firewall'
grep -R -l -w -e libvirt_enable_firewall $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_enable_firewall platform_libvirt_vm_provisioner_libvirt_enable_firewall > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_enable_firewall $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_firewall_services -> platform_libvirt_vm_provisioner_libvirt_firewall_services'
grep -R -l -w -e libvirt_firewall_services $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_firewall_services platform_libvirt_vm_provisioner_libvirt_firewall_services > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_firewall_services $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_cleanup_http_server -> platform_libvirt_vm_provisioner_libvirt_cleanup_http_server'
grep -R -l -w -e libvirt_cleanup_http_server $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_cleanup_http_server platform_libvirt_vm_provisioner_libvirt_cleanup_http_server > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_cleanup_http_server $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_cleanup_temp_files -> platform_libvirt_vm_provisioner_libvirt_cleanup_temp_files'
grep -R -l -w -e libvirt_cleanup_temp_files $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_cleanup_temp_files platform_libvirt_vm_provisioner_libvirt_cleanup_temp_files > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_cleanup_temp_files $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_log_level -> platform_libvirt_vm_provisioner_libvirt_log_level'
grep -R -l -w -e libvirt_log_level $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_log_level platform_libvirt_vm_provisioner_libvirt_log_level > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_log_level $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_save_logs -> platform_libvirt_vm_provisioner_libvirt_save_logs'
grep -R -l -w -e libvirt_save_logs $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_save_logs platform_libvirt_vm_provisioner_libvirt_save_logs > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_save_logs $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_logs_dir -> platform_libvirt_vm_provisioner_libvirt_logs_dir'
grep -R -l -w -e libvirt_logs_dir $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_logs_dir platform_libvirt_vm_provisioner_libvirt_logs_dir > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_logs_dir $EXCLUDES .) || true
echo '---'
echo 'Mapping: use_cloud_init_iso -> platform_libvirt_vm_provisioner_use_cloud_init_iso'
grep -R -l -w -e use_cloud_init_iso $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" use_cloud_init_iso platform_libvirt_vm_provisioner_use_cloud_init_iso > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e use_cloud_init_iso $EXCLUDES .) || true
echo '---'
echo 'Mapping: use_cloud_init_disk -> platform_libvirt_vm_provisioner_use_cloud_init_disk'
grep -R -l -w -e use_cloud_init_disk $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" use_cloud_init_disk platform_libvirt_vm_provisioner_use_cloud_init_disk > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e use_cloud_init_disk $EXCLUDES .) || true
echo '---'
echo 'Mapping: cloud_init_allow_password_auth -> platform_libvirt_vm_provisioner_cloud_init_allow_password_auth'
grep -R -l -w -e cloud_init_allow_password_auth $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" cloud_init_allow_password_auth platform_libvirt_vm_provisioner_cloud_init_allow_password_auth > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e cloud_init_allow_password_auth $EXCLUDES .) || true
echo '---'
echo 'Mapping: seed_disk_size_mb -> platform_libvirt_vm_provisioner_seed_disk_size_mb'
grep -R -l -w -e seed_disk_size_mb $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" seed_disk_size_mb platform_libvirt_vm_provisioner_seed_disk_size_mb > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e seed_disk_size_mb $EXCLUDES .) || true
echo '---'
echo 'Mapping: ssh_public_key -> platform_libvirt_vm_provisioner_ssh_public_key'
grep -R -l -w -e ssh_public_key $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" ssh_public_key platform_libvirt_vm_provisioner_ssh_public_key > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e ssh_public_key $EXCLUDES .) || true
echo 'Preview complete.'
