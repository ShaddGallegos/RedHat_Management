#!/usr/bin/env bash
# Preview script for role: scenario_aap_inventories
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

echo 'Role: scenario_aap_inventories'
echo 'Mappings:'
echo '  aap_inventories_config_enabled -> scenario_aap_inventories_aap_inventories_config_enabled'
echo '  aap_inventories_config_version -> scenario_aap_inventories_aap_inventories_config_version'
echo '  aap_inventories_config_timeout -> scenario_aap_inventories_aap_inventories_config_timeout'
echo '  aap_url -> scenario_aap_inventories_aap_url'
echo '  aap_username -> scenario_aap_inventories_aap_username'
echo '  aap_verify_ssl -> scenario_aap_inventories_aap_verify_ssl'
echo '  aap_inventories_organization -> scenario_aap_inventories_aap_inventories_organization'
echo '  create_static_inventories -> scenario_aap_inventories_create_static_inventories'
echo '  static_inventories -> scenario_aap_inventories_static_inventories'
echo '  create_dynamic_inventories -> scenario_aap_inventories_create_dynamic_inventories'
echo '  dynamic_inventories -> scenario_aap_inventories_dynamic_inventories'
echo '  create_inventory_sources -> scenario_aap_inventories_create_inventory_sources'
echo '  inventory_sources -> scenario_aap_inventories_inventory_sources'
echo '  aap_inventories_validate_connectivity -> scenario_aap_inventories_aap_inventories_validate_connectivity'
echo '  aap_inventories_test_imports -> scenario_aap_inventories_aap_inventories_test_imports'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: aap_inventories_config_enabled -> scenario_aap_inventories_aap_inventories_config_enabled'
grep -R -l -w -e aap_inventories_config_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_inventories_config_enabled scenario_aap_inventories_aap_inventories_config_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_inventories_config_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_inventories_config_version -> scenario_aap_inventories_aap_inventories_config_version'
grep -R -l -w -e aap_inventories_config_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_inventories_config_version scenario_aap_inventories_aap_inventories_config_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_inventories_config_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_inventories_config_timeout -> scenario_aap_inventories_aap_inventories_config_timeout'
grep -R -l -w -e aap_inventories_config_timeout $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_inventories_config_timeout scenario_aap_inventories_aap_inventories_config_timeout > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_inventories_config_timeout $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_url -> scenario_aap_inventories_aap_url'
grep -R -l -w -e aap_url $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_url scenario_aap_inventories_aap_url > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_url $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_username -> scenario_aap_inventories_aap_username'
grep -R -l -w -e aap_username $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_username scenario_aap_inventories_aap_username > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_username $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_verify_ssl -> scenario_aap_inventories_aap_verify_ssl'
grep -R -l -w -e aap_verify_ssl $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_verify_ssl scenario_aap_inventories_aap_verify_ssl > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_verify_ssl $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_inventories_organization -> scenario_aap_inventories_aap_inventories_organization'
grep -R -l -w -e aap_inventories_organization $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_inventories_organization scenario_aap_inventories_aap_inventories_organization > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_inventories_organization $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_static_inventories -> scenario_aap_inventories_create_static_inventories'
grep -R -l -w -e create_static_inventories $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_static_inventories scenario_aap_inventories_create_static_inventories > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_static_inventories $EXCLUDES .) || true
echo '---'
echo 'Mapping: static_inventories -> scenario_aap_inventories_static_inventories'
grep -R -l -w -e static_inventories $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" static_inventories scenario_aap_inventories_static_inventories > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e static_inventories $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_dynamic_inventories -> scenario_aap_inventories_create_dynamic_inventories'
grep -R -l -w -e create_dynamic_inventories $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_dynamic_inventories scenario_aap_inventories_create_dynamic_inventories > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_dynamic_inventories $EXCLUDES .) || true
echo '---'
echo 'Mapping: dynamic_inventories -> scenario_aap_inventories_dynamic_inventories'
grep -R -l -w -e dynamic_inventories $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dynamic_inventories scenario_aap_inventories_dynamic_inventories > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dynamic_inventories $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_inventory_sources -> scenario_aap_inventories_create_inventory_sources'
grep -R -l -w -e create_inventory_sources $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_inventory_sources scenario_aap_inventories_create_inventory_sources > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_inventory_sources $EXCLUDES .) || true
echo '---'
echo 'Mapping: inventory_sources -> scenario_aap_inventories_inventory_sources'
grep -R -l -w -e inventory_sources $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" inventory_sources scenario_aap_inventories_inventory_sources > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e inventory_sources $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_inventories_validate_connectivity -> scenario_aap_inventories_aap_inventories_validate_connectivity'
grep -R -l -w -e aap_inventories_validate_connectivity $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_inventories_validate_connectivity scenario_aap_inventories_aap_inventories_validate_connectivity > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_inventories_validate_connectivity $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_inventories_test_imports -> scenario_aap_inventories_aap_inventories_test_imports'
grep -R -l -w -e aap_inventories_test_imports $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_inventories_test_imports scenario_aap_inventories_aap_inventories_test_imports > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_inventories_test_imports $EXCLUDES .) || true
echo 'Preview complete.'
