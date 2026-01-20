#!/usr/bin/env bash
# Preview script for role: scenario_aap_credentials
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

echo 'Role: scenario_aap_credentials'
echo 'Mappings:'
echo '  aap_credentials_config_enabled -> scenario_aap_credentials_aap_credentials_config_enabled'
echo '  aap_credentials_config_version -> scenario_aap_credentials_aap_credentials_config_version'
echo '  aap_credentials_config_timeout -> scenario_aap_credentials_aap_credentials_config_timeout'
echo '  aap_url -> scenario_aap_credentials_aap_url'
echo '  aap_username -> scenario_aap_credentials_aap_username'
echo '  aap_verify_ssl -> scenario_aap_credentials_aap_verify_ssl'
echo '  aap_credentials_organization -> scenario_aap_credentials_aap_credentials_organization'
echo '  create_machine_credentials -> scenario_aap_credentials_create_machine_credentials'
echo '  machine_credentials -> scenario_aap_credentials_machine_credentials'
echo '  create_cloud_credentials -> scenario_aap_credentials_create_cloud_credentials'
echo '  cloud_credentials -> scenario_aap_credentials_cloud_credentials'
echo '  create_network_credentials -> scenario_aap_credentials_create_network_credentials'
echo '  network_credentials -> scenario_aap_credentials_network_credentials'
echo '  create_vault_credentials -> scenario_aap_credentials_create_vault_credentials'
echo '  vault_credentials -> scenario_aap_credentials_vault_credentials'
echo '  create_registry_credentials -> scenario_aap_credentials_create_registry_credentials'
echo '  registry_credentials -> scenario_aap_credentials_registry_credentials'
echo '  create_satellite_credentials -> scenario_aap_credentials_create_satellite_credentials'
echo '  satellite_credentials -> scenario_aap_credentials_satellite_credentials'
echo '  create_idm_credentials -> scenario_aap_credentials_create_idm_credentials'
echo '  idm_credentials -> scenario_aap_credentials_idm_credentials'
echo '  aap_credentials_validate_connectivity -> scenario_aap_credentials_aap_credentials_validate_connectivity'
echo '  aap_credentials_test_connections -> scenario_aap_credentials_aap_credentials_test_connections'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: aap_credentials_config_enabled -> scenario_aap_credentials_aap_credentials_config_enabled'
grep -R -l -w -e aap_credentials_config_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_credentials_config_enabled scenario_aap_credentials_aap_credentials_config_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_credentials_config_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_credentials_config_version -> scenario_aap_credentials_aap_credentials_config_version'
grep -R -l -w -e aap_credentials_config_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_credentials_config_version scenario_aap_credentials_aap_credentials_config_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_credentials_config_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_credentials_config_timeout -> scenario_aap_credentials_aap_credentials_config_timeout'
grep -R -l -w -e aap_credentials_config_timeout $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_credentials_config_timeout scenario_aap_credentials_aap_credentials_config_timeout > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_credentials_config_timeout $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_url -> scenario_aap_credentials_aap_url'
grep -R -l -w -e aap_url $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_url scenario_aap_credentials_aap_url > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_url $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_username -> scenario_aap_credentials_aap_username'
grep -R -l -w -e aap_username $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_username scenario_aap_credentials_aap_username > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_username $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_verify_ssl -> scenario_aap_credentials_aap_verify_ssl'
grep -R -l -w -e aap_verify_ssl $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_verify_ssl scenario_aap_credentials_aap_verify_ssl > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_verify_ssl $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_credentials_organization -> scenario_aap_credentials_aap_credentials_organization'
grep -R -l -w -e aap_credentials_organization $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_credentials_organization scenario_aap_credentials_aap_credentials_organization > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_credentials_organization $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_machine_credentials -> scenario_aap_credentials_create_machine_credentials'
grep -R -l -w -e create_machine_credentials $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_machine_credentials scenario_aap_credentials_create_machine_credentials > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_machine_credentials $EXCLUDES .) || true
echo '---'
echo 'Mapping: machine_credentials -> scenario_aap_credentials_machine_credentials'
grep -R -l -w -e machine_credentials $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" machine_credentials scenario_aap_credentials_machine_credentials > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e machine_credentials $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_cloud_credentials -> scenario_aap_credentials_create_cloud_credentials'
grep -R -l -w -e create_cloud_credentials $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_cloud_credentials scenario_aap_credentials_create_cloud_credentials > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_cloud_credentials $EXCLUDES .) || true
echo '---'
echo 'Mapping: cloud_credentials -> scenario_aap_credentials_cloud_credentials'
grep -R -l -w -e cloud_credentials $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" cloud_credentials scenario_aap_credentials_cloud_credentials > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e cloud_credentials $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_network_credentials -> scenario_aap_credentials_create_network_credentials'
grep -R -l -w -e create_network_credentials $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_network_credentials scenario_aap_credentials_create_network_credentials > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_network_credentials $EXCLUDES .) || true
echo '---'
echo 'Mapping: network_credentials -> scenario_aap_credentials_network_credentials'
grep -R -l -w -e network_credentials $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" network_credentials scenario_aap_credentials_network_credentials > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e network_credentials $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_vault_credentials -> scenario_aap_credentials_create_vault_credentials'
grep -R -l -w -e create_vault_credentials $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_vault_credentials scenario_aap_credentials_create_vault_credentials > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_vault_credentials $EXCLUDES .) || true
echo '---'
echo 'Mapping: vault_credentials -> scenario_aap_credentials_vault_credentials'
grep -R -l -w -e vault_credentials $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" vault_credentials scenario_aap_credentials_vault_credentials > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e vault_credentials $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_registry_credentials -> scenario_aap_credentials_create_registry_credentials'
grep -R -l -w -e create_registry_credentials $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_registry_credentials scenario_aap_credentials_create_registry_credentials > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_registry_credentials $EXCLUDES .) || true
echo '---'
echo 'Mapping: registry_credentials -> scenario_aap_credentials_registry_credentials'
grep -R -l -w -e registry_credentials $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" registry_credentials scenario_aap_credentials_registry_credentials > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e registry_credentials $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_satellite_credentials -> scenario_aap_credentials_create_satellite_credentials'
grep -R -l -w -e create_satellite_credentials $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_satellite_credentials scenario_aap_credentials_create_satellite_credentials > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_satellite_credentials $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_credentials -> scenario_aap_credentials_satellite_credentials'
grep -R -l -w -e satellite_credentials $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_credentials scenario_aap_credentials_satellite_credentials > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_credentials $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_idm_credentials -> scenario_aap_credentials_create_idm_credentials'
grep -R -l -w -e create_idm_credentials $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_idm_credentials scenario_aap_credentials_create_idm_credentials > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_idm_credentials $EXCLUDES .) || true
echo '---'
echo 'Mapping: idm_credentials -> scenario_aap_credentials_idm_credentials'
grep -R -l -w -e idm_credentials $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" idm_credentials scenario_aap_credentials_idm_credentials > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e idm_credentials $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_credentials_validate_connectivity -> scenario_aap_credentials_aap_credentials_validate_connectivity'
grep -R -l -w -e aap_credentials_validate_connectivity $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_credentials_validate_connectivity scenario_aap_credentials_aap_credentials_validate_connectivity > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_credentials_validate_connectivity $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_credentials_test_connections -> scenario_aap_credentials_aap_credentials_test_connections'
grep -R -l -w -e aap_credentials_test_connections $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_credentials_test_connections scenario_aap_credentials_aap_credentials_test_connections > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_credentials_test_connections $EXCLUDES .) || true
echo 'Preview complete.'
