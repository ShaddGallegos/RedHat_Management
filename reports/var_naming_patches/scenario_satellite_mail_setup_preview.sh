#!/usr/bin/env bash
# Preview script for role: scenario_satellite_mail_setup
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

echo 'Role: scenario_satellite_mail_setup'
echo 'Mappings:'
echo '  satellite_mail_targets -> scenario_satellite_mail_setup_satellite_mail_targets'
echo '  satellite_mail_master_vars_dest -> scenario_satellite_mail_setup_satellite_mail_master_vars_dest'
echo '  satellite_mail_inventory_dest -> scenario_satellite_mail_setup_satellite_mail_inventory_dest'
echo '  satellite_fqdn -> scenario_satellite_mail_setup_satellite_fqdn'
echo '  satellite_org -> scenario_satellite_mail_setup_satellite_org'
echo '  satellite_location -> scenario_satellite_mail_setup_satellite_location'
echo '  satellite_admin_user -> scenario_satellite_mail_setup_satellite_admin_user'
echo '  satellite_admin_password -> scenario_satellite_mail_setup_satellite_admin_password'
echo '  satellite_mail_relay -> scenario_satellite_mail_setup_satellite_mail_relay'
echo '  satellite_mail_relay_credentials -> scenario_satellite_mail_setup_satellite_mail_relay_credentials'
echo '  libvirt_host -> scenario_satellite_mail_setup_libvirt_host'
echo '  libvirt_user -> scenario_satellite_mail_setup_libvirt_user'
echo '  satellite_vm_name -> scenario_satellite_mail_setup_satellite_vm_name'
echo '  satellite_vm_hostname -> scenario_satellite_mail_setup_satellite_vm_hostname'
echo '  satellite_vm_memory_mb -> scenario_satellite_mail_setup_satellite_vm_memory_mb'
echo '  satellite_vm_vcpus -> scenario_satellite_mail_setup_satellite_vm_vcpus'
echo '  satellite_vm_disk_size_gb -> scenario_satellite_mail_setup_satellite_vm_disk_size_gb'
echo '  satellite_vm_disk_name -> scenario_satellite_mail_setup_satellite_vm_disk_name'
echo '  satellite_vm_pool -> scenario_satellite_mail_setup_satellite_vm_pool'
echo '  satellite_vm_network -> scenario_satellite_mail_setup_satellite_vm_network'
echo '  satellite_vm_root_pubkey -> scenario_satellite_mail_setup_satellite_vm_root_pubkey'
echo '  satellite_admin_pubkey -> scenario_satellite_mail_setup_satellite_admin_pubkey'
echo '  satellite_root_pubkey -> scenario_satellite_mail_setup_satellite_root_pubkey'
echo '  satellite_base_packages -> scenario_satellite_mail_setup_satellite_base_packages'
echo '  satellite_hosts_entries -> scenario_satellite_mail_setup_satellite_hosts_entries'
echo '  satellite_nameservers -> scenario_satellite_mail_setup_satellite_nameservers'
echo '  satellite_search_domain -> scenario_satellite_mail_setup_satellite_search_domain'
echo '  aap_inventory_path -> scenario_satellite_mail_setup_aap_inventory_path'
echo '  aap_admin_user -> scenario_satellite_mail_setup_aap_admin_user'
echo '  aap_admin_password -> scenario_satellite_mail_setup_aap_admin_password'
echo '  insights_account -> scenario_satellite_mail_setup_insights_account'
echo '  insights_username -> scenario_satellite_mail_setup_insights_username'
echo '  insights_password -> scenario_satellite_mail_setup_insights_password'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: satellite_mail_targets -> scenario_satellite_mail_setup_satellite_mail_targets'
grep -R -l -w -e satellite_mail_targets $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_mail_targets scenario_satellite_mail_setup_satellite_mail_targets > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_mail_targets $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_mail_master_vars_dest -> scenario_satellite_mail_setup_satellite_mail_master_vars_dest'
grep -R -l -w -e satellite_mail_master_vars_dest $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_mail_master_vars_dest scenario_satellite_mail_setup_satellite_mail_master_vars_dest > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_mail_master_vars_dest $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_mail_inventory_dest -> scenario_satellite_mail_setup_satellite_mail_inventory_dest'
grep -R -l -w -e satellite_mail_inventory_dest $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_mail_inventory_dest scenario_satellite_mail_setup_satellite_mail_inventory_dest > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_mail_inventory_dest $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_fqdn -> scenario_satellite_mail_setup_satellite_fqdn'
grep -R -l -w -e satellite_fqdn $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_fqdn scenario_satellite_mail_setup_satellite_fqdn > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_fqdn $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_org -> scenario_satellite_mail_setup_satellite_org'
grep -R -l -w -e satellite_org $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_org scenario_satellite_mail_setup_satellite_org > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_org $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_location -> scenario_satellite_mail_setup_satellite_location'
grep -R -l -w -e satellite_location $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_location scenario_satellite_mail_setup_satellite_location > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_location $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_admin_user -> scenario_satellite_mail_setup_satellite_admin_user'
grep -R -l -w -e satellite_admin_user $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_admin_user scenario_satellite_mail_setup_satellite_admin_user > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_admin_user $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_admin_password -> scenario_satellite_mail_setup_satellite_admin_password'
grep -R -l -w -e satellite_admin_password $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_admin_password scenario_satellite_mail_setup_satellite_admin_password > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_admin_password $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_mail_relay -> scenario_satellite_mail_setup_satellite_mail_relay'
grep -R -l -w -e satellite_mail_relay $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_mail_relay scenario_satellite_mail_setup_satellite_mail_relay > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_mail_relay $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_mail_relay_credentials -> scenario_satellite_mail_setup_satellite_mail_relay_credentials'
grep -R -l -w -e satellite_mail_relay_credentials $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_mail_relay_credentials scenario_satellite_mail_setup_satellite_mail_relay_credentials > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_mail_relay_credentials $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_host -> scenario_satellite_mail_setup_libvirt_host'
grep -R -l -w -e libvirt_host $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_host scenario_satellite_mail_setup_libvirt_host > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_host $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_user -> scenario_satellite_mail_setup_libvirt_user'
grep -R -l -w -e libvirt_user $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_user scenario_satellite_mail_setup_libvirt_user > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_user $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_vm_name -> scenario_satellite_mail_setup_satellite_vm_name'
grep -R -l -w -e satellite_vm_name $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_vm_name scenario_satellite_mail_setup_satellite_vm_name > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_vm_name $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_vm_hostname -> scenario_satellite_mail_setup_satellite_vm_hostname'
grep -R -l -w -e satellite_vm_hostname $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_vm_hostname scenario_satellite_mail_setup_satellite_vm_hostname > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_vm_hostname $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_vm_memory_mb -> scenario_satellite_mail_setup_satellite_vm_memory_mb'
grep -R -l -w -e satellite_vm_memory_mb $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_vm_memory_mb scenario_satellite_mail_setup_satellite_vm_memory_mb > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_vm_memory_mb $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_vm_vcpus -> scenario_satellite_mail_setup_satellite_vm_vcpus'
grep -R -l -w -e satellite_vm_vcpus $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_vm_vcpus scenario_satellite_mail_setup_satellite_vm_vcpus > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_vm_vcpus $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_vm_disk_size_gb -> scenario_satellite_mail_setup_satellite_vm_disk_size_gb'
grep -R -l -w -e satellite_vm_disk_size_gb $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_vm_disk_size_gb scenario_satellite_mail_setup_satellite_vm_disk_size_gb > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_vm_disk_size_gb $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_vm_disk_name -> scenario_satellite_mail_setup_satellite_vm_disk_name'
grep -R -l -w -e satellite_vm_disk_name $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_vm_disk_name scenario_satellite_mail_setup_satellite_vm_disk_name > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_vm_disk_name $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_vm_pool -> scenario_satellite_mail_setup_satellite_vm_pool'
grep -R -l -w -e satellite_vm_pool $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_vm_pool scenario_satellite_mail_setup_satellite_vm_pool > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_vm_pool $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_vm_network -> scenario_satellite_mail_setup_satellite_vm_network'
grep -R -l -w -e satellite_vm_network $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_vm_network scenario_satellite_mail_setup_satellite_vm_network > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_vm_network $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_vm_root_pubkey -> scenario_satellite_mail_setup_satellite_vm_root_pubkey'
grep -R -l -w -e satellite_vm_root_pubkey $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_vm_root_pubkey scenario_satellite_mail_setup_satellite_vm_root_pubkey > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_vm_root_pubkey $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_admin_pubkey -> scenario_satellite_mail_setup_satellite_admin_pubkey'
grep -R -l -w -e satellite_admin_pubkey $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_admin_pubkey scenario_satellite_mail_setup_satellite_admin_pubkey > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_admin_pubkey $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_root_pubkey -> scenario_satellite_mail_setup_satellite_root_pubkey'
grep -R -l -w -e satellite_root_pubkey $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_root_pubkey scenario_satellite_mail_setup_satellite_root_pubkey > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_root_pubkey $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_base_packages -> scenario_satellite_mail_setup_satellite_base_packages'
grep -R -l -w -e satellite_base_packages $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_base_packages scenario_satellite_mail_setup_satellite_base_packages > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_base_packages $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_hosts_entries -> scenario_satellite_mail_setup_satellite_hosts_entries'
grep -R -l -w -e satellite_hosts_entries $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_hosts_entries scenario_satellite_mail_setup_satellite_hosts_entries > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_hosts_entries $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_nameservers -> scenario_satellite_mail_setup_satellite_nameservers'
grep -R -l -w -e satellite_nameservers $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_nameservers scenario_satellite_mail_setup_satellite_nameservers > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_nameservers $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_search_domain -> scenario_satellite_mail_setup_satellite_search_domain'
grep -R -l -w -e satellite_search_domain $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_search_domain scenario_satellite_mail_setup_satellite_search_domain > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_search_domain $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_inventory_path -> scenario_satellite_mail_setup_aap_inventory_path'
grep -R -l -w -e aap_inventory_path $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_inventory_path scenario_satellite_mail_setup_aap_inventory_path > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_inventory_path $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_admin_user -> scenario_satellite_mail_setup_aap_admin_user'
grep -R -l -w -e aap_admin_user $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_admin_user scenario_satellite_mail_setup_aap_admin_user > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_admin_user $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_admin_password -> scenario_satellite_mail_setup_aap_admin_password'
grep -R -l -w -e aap_admin_password $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_admin_password scenario_satellite_mail_setup_aap_admin_password > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_admin_password $EXCLUDES .) || true
echo '---'
echo 'Mapping: insights_account -> scenario_satellite_mail_setup_insights_account'
grep -R -l -w -e insights_account $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" insights_account scenario_satellite_mail_setup_insights_account > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e insights_account $EXCLUDES .) || true
echo '---'
echo 'Mapping: insights_username -> scenario_satellite_mail_setup_insights_username'
grep -R -l -w -e insights_username $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" insights_username scenario_satellite_mail_setup_insights_username > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e insights_username $EXCLUDES .) || true
echo '---'
echo 'Mapping: insights_password -> scenario_satellite_mail_setup_insights_password'
grep -R -l -w -e insights_password $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" insights_password scenario_satellite_mail_setup_insights_password > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e insights_password $EXCLUDES .) || true
echo 'Preview complete.'
