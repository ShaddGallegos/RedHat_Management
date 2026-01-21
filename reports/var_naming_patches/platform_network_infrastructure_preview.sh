#!/usr/bin/env bash
# Preview script for role: platform_network_infrastructure
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

echo 'Role: platform_network_infrastructure'
echo 'Mappings:'
echo '  network_config_enabled -> platform_network_infrastructure_network_config_enabled'
echo '  network_config_version -> platform_network_infrastructure_network_config_version'
echo '  network_config_timeout -> platform_network_infrastructure_network_config_timeout'
echo '  network_interface -> platform_network_infrastructure_network_interface'
echo '  network_name -> platform_network_infrastructure_network_name'
echo '  network_domain -> platform_network_infrastructure_network_domain'
echo '  primary_subnet -> platform_network_infrastructure_primary_subnet'
echo '  dhcp_primary -> platform_network_infrastructure_dhcp_primary'
echo '  dns_primary -> platform_network_infrastructure_dns_primary'
echo '  host_groups -> platform_network_infrastructure_host_groups'
echo '  static_hosts -> platform_network_infrastructure_static_hosts'
echo '  firewall_rules -> platform_network_infrastructure_firewall_rules'
echo '  network_validation -> platform_network_infrastructure_network_validation'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: network_config_enabled -> platform_network_infrastructure_network_config_enabled'
grep -R -l -w -e network_config_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" network_config_enabled platform_network_infrastructure_network_config_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e network_config_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: network_config_version -> platform_network_infrastructure_network_config_version'
grep -R -l -w -e network_config_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" network_config_version platform_network_infrastructure_network_config_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e network_config_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: network_config_timeout -> platform_network_infrastructure_network_config_timeout'
grep -R -l -w -e network_config_timeout $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" network_config_timeout platform_network_infrastructure_network_config_timeout > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e network_config_timeout $EXCLUDES .) || true
echo '---'
echo 'Mapping: network_interface -> platform_network_infrastructure_network_interface'
grep -R -l -w -e network_interface $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" network_interface platform_network_infrastructure_network_interface > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e network_interface $EXCLUDES .) || true
echo '---'
echo 'Mapping: network_name -> platform_network_infrastructure_network_name'
grep -R -l -w -e network_name $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" network_name platform_network_infrastructure_network_name > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e network_name $EXCLUDES .) || true
echo '---'
echo 'Mapping: network_domain -> platform_network_infrastructure_network_domain'
grep -R -l -w -e network_domain $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" network_domain platform_network_infrastructure_network_domain > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e network_domain $EXCLUDES .) || true
echo '---'
echo 'Mapping: primary_subnet -> platform_network_infrastructure_primary_subnet'
grep -R -l -w -e primary_subnet $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" primary_subnet platform_network_infrastructure_primary_subnet > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e primary_subnet $EXCLUDES .) || true
echo '---'
echo 'Mapping: dhcp_primary -> platform_network_infrastructure_dhcp_primary'
grep -R -l -w -e dhcp_primary $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dhcp_primary platform_network_infrastructure_dhcp_primary > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dhcp_primary $EXCLUDES .) || true
echo '---'
echo 'Mapping: dns_primary -> platform_network_infrastructure_dns_primary'
grep -R -l -w -e dns_primary $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dns_primary platform_network_infrastructure_dns_primary > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dns_primary $EXCLUDES .) || true
echo '---'
echo 'Mapping: host_groups -> platform_network_infrastructure_host_groups'
grep -R -l -w -e host_groups $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" host_groups platform_network_infrastructure_host_groups > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e host_groups $EXCLUDES .) || true
echo '---'
echo 'Mapping: static_hosts -> platform_network_infrastructure_static_hosts'
grep -R -l -w -e static_hosts $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" static_hosts platform_network_infrastructure_static_hosts > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e static_hosts $EXCLUDES .) || true
echo '---'
echo 'Mapping: firewall_rules -> platform_network_infrastructure_firewall_rules'
grep -R -l -w -e firewall_rules $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" firewall_rules platform_network_infrastructure_firewall_rules > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e firewall_rules $EXCLUDES .) || true
echo '---'
echo 'Mapping: network_validation -> platform_network_infrastructure_network_validation'
grep -R -l -w -e network_validation $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" network_validation platform_network_infrastructure_network_validation > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e network_validation $EXCLUDES .) || true
echo 'Preview complete.'
