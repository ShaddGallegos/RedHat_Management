#!/usr/bin/env bash
# Preview script for role: ansible_dev_node_prompts
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

echo 'Role: ansible_dev_node_prompts'
echo 'Mappings:'
echo '  infrastructure_type -> ansible_dev_node_prompts_infrastructure_type'
echo '  ansible_domain -> ansible_dev_node_prompts_ansible_domain'
echo '  libvirt_host_short_name -> ansible_dev_node_prompts_libvirt_host_short_name'
echo '  libvirt_external_network -> ansible_dev_node_prompts_libvirt_external_network'
echo '  libvirt_external_network_gw -> ansible_dev_node_prompts_libvirt_external_network_gw'
echo '  libvirt_internal_network -> ansible_dev_node_prompts_libvirt_internal_network'
echo '  libvirt_internal_network_subnet -> ansible_dev_node_prompts_libvirt_internal_network_subnet'
echo '  libvirt_internal_network_gw -> ansible_dev_node_prompts_libvirt_internal_network_gw'
echo '  libvirt_installer_node_ip -> ansible_dev_node_prompts_libvirt_installer_node_ip'
echo '  libvirt_aap_ip -> ansible_dev_node_prompts_libvirt_aap_ip'
echo '  libvirt_satellite_ip -> ansible_dev_node_prompts_libvirt_satellite_ip'
echo '  libvirt_idm_ip -> ansible_dev_node_prompts_libvirt_idm_ip'
echo '  libvirt_installer_node_short_name -> ansible_dev_node_prompts_libvirt_installer_node_short_name'
echo '  libvirt_aap_node_short_name -> ansible_dev_node_prompts_libvirt_aap_node_short_name'
echo '  libvirt_satellite_node_short_name -> ansible_dev_node_prompts_libvirt_satellite_node_short_name'
echo '  libvirt_idm_node_short_name -> ansible_dev_node_prompts_libvirt_idm_node_short_name'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: infrastructure_type -> ansible_dev_node_prompts_infrastructure_type'
grep -R -l -w -e infrastructure_type $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" infrastructure_type ansible_dev_node_prompts_infrastructure_type > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e infrastructure_type $EXCLUDES .) || true
echo '---'
echo 'Mapping: ansible_domain -> ansible_dev_node_prompts_ansible_domain'
grep -R -l -w -e ansible_domain $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" ansible_domain ansible_dev_node_prompts_ansible_domain > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e ansible_domain $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_host_short_name -> ansible_dev_node_prompts_libvirt_host_short_name'
grep -R -l -w -e libvirt_host_short_name $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_host_short_name ansible_dev_node_prompts_libvirt_host_short_name > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_host_short_name $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_external_network -> ansible_dev_node_prompts_libvirt_external_network'
grep -R -l -w -e libvirt_external_network $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_external_network ansible_dev_node_prompts_libvirt_external_network > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_external_network $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_external_network_gw -> ansible_dev_node_prompts_libvirt_external_network_gw'
grep -R -l -w -e libvirt_external_network_gw $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_external_network_gw ansible_dev_node_prompts_libvirt_external_network_gw > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_external_network_gw $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_internal_network -> ansible_dev_node_prompts_libvirt_internal_network'
grep -R -l -w -e libvirt_internal_network $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_internal_network ansible_dev_node_prompts_libvirt_internal_network > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_internal_network $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_internal_network_subnet -> ansible_dev_node_prompts_libvirt_internal_network_subnet'
grep -R -l -w -e libvirt_internal_network_subnet $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_internal_network_subnet ansible_dev_node_prompts_libvirt_internal_network_subnet > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_internal_network_subnet $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_internal_network_gw -> ansible_dev_node_prompts_libvirt_internal_network_gw'
grep -R -l -w -e libvirt_internal_network_gw $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_internal_network_gw ansible_dev_node_prompts_libvirt_internal_network_gw > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_internal_network_gw $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_installer_node_ip -> ansible_dev_node_prompts_libvirt_installer_node_ip'
grep -R -l -w -e libvirt_installer_node_ip $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_installer_node_ip ansible_dev_node_prompts_libvirt_installer_node_ip > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_installer_node_ip $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_aap_ip -> ansible_dev_node_prompts_libvirt_aap_ip'
grep -R -l -w -e libvirt_aap_ip $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_aap_ip ansible_dev_node_prompts_libvirt_aap_ip > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_aap_ip $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_satellite_ip -> ansible_dev_node_prompts_libvirt_satellite_ip'
grep -R -l -w -e libvirt_satellite_ip $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_satellite_ip ansible_dev_node_prompts_libvirt_satellite_ip > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_satellite_ip $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_idm_ip -> ansible_dev_node_prompts_libvirt_idm_ip'
grep -R -l -w -e libvirt_idm_ip $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_idm_ip ansible_dev_node_prompts_libvirt_idm_ip > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_idm_ip $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_installer_node_short_name -> ansible_dev_node_prompts_libvirt_installer_node_short_name'
grep -R -l -w -e libvirt_installer_node_short_name $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_installer_node_short_name ansible_dev_node_prompts_libvirt_installer_node_short_name > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_installer_node_short_name $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_aap_node_short_name -> ansible_dev_node_prompts_libvirt_aap_node_short_name'
grep -R -l -w -e libvirt_aap_node_short_name $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_aap_node_short_name ansible_dev_node_prompts_libvirt_aap_node_short_name > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_aap_node_short_name $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_satellite_node_short_name -> ansible_dev_node_prompts_libvirt_satellite_node_short_name'
grep -R -l -w -e libvirt_satellite_node_short_name $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_satellite_node_short_name ansible_dev_node_prompts_libvirt_satellite_node_short_name > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_satellite_node_short_name $EXCLUDES .) || true
echo '---'
echo 'Mapping: libvirt_idm_node_short_name -> ansible_dev_node_prompts_libvirt_idm_node_short_name'
grep -R -l -w -e libvirt_idm_node_short_name $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" libvirt_idm_node_short_name ansible_dev_node_prompts_libvirt_idm_node_short_name > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e libvirt_idm_node_short_name $EXCLUDES .) || true
echo 'Preview complete.'
