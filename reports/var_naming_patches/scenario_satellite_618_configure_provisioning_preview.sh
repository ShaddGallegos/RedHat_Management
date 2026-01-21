#!/usr/bin/env bash
# Preview script for role: scenario_satellite_618_configure_provisioning
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

echo 'Role: scenario_satellite_618_configure_provisioning'
echo 'Mappings:'
echo '  satellite_content_config_enabled -> scenario_satellite_618_configure_provisioning_satellite_content_config_enabled'
echo '  satellite_content_config_version -> scenario_satellite_618_configure_provisioning_satellite_content_config_version'
echo '  satellite_content_config_timeout -> scenario_satellite_618_configure_provisioning_satellite_content_config_timeout'
echo '  satellite_url -> scenario_satellite_618_configure_provisioning_satellite_url'
echo '  satellite_username -> scenario_satellite_618_configure_provisioning_satellite_username'
echo '  satellite_validate_ssl -> scenario_satellite_618_configure_provisioning_satellite_validate_ssl'
echo '  satellite_organization -> scenario_satellite_618_configure_provisioning_satellite_organization'
echo '  satellite_location -> scenario_satellite_618_configure_provisioning_satellite_location'
echo '  create_organizations -> scenario_satellite_618_configure_provisioning_create_organizations'
echo '  create_locations -> scenario_satellite_618_configure_provisioning_create_locations'
echo '  create_products -> scenario_satellite_618_configure_provisioning_create_products'
echo '  create_repositories -> scenario_satellite_618_configure_provisioning_create_repositories'
echo '  synchronize_repositories -> scenario_satellite_618_configure_provisioning_synchronize_repositories'
echo '  enable_repository_sets -> scenario_satellite_618_configure_provisioning_enable_repository_sets'
echo '  repository_sets_to_enable -> scenario_satellite_618_configure_provisioning_repository_sets_to_enable'
echo '  organizations -> scenario_satellite_618_configure_provisioning_organizations'
echo '  locations -> scenario_satellite_618_configure_provisioning_locations'
echo '  products -> scenario_satellite_618_configure_provisioning_products'
echo '  repositories -> scenario_satellite_618_configure_provisioning_repositories'
echo '  create_sync_plans -> scenario_satellite_618_configure_provisioning_create_sync_plans'
echo '  sync_plans -> scenario_satellite_618_configure_provisioning_sync_plans'
echo '  satellite_content_validate_connectivity -> scenario_satellite_618_configure_provisioning_satellite_content_validate_connectivity'
echo '  satellite_content_test_sync -> scenario_satellite_618_configure_provisioning_satellite_content_test_sync'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: satellite_content_config_enabled -> scenario_satellite_618_configure_provisioning_satellite_content_config_enabled'
grep -R -l -w -e satellite_content_config_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_content_config_enabled scenario_satellite_618_configure_provisioning_satellite_content_config_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_content_config_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_content_config_version -> scenario_satellite_618_configure_provisioning_satellite_content_config_version'
grep -R -l -w -e satellite_content_config_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_content_config_version scenario_satellite_618_configure_provisioning_satellite_content_config_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_content_config_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_content_config_timeout -> scenario_satellite_618_configure_provisioning_satellite_content_config_timeout'
grep -R -l -w -e satellite_content_config_timeout $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_content_config_timeout scenario_satellite_618_configure_provisioning_satellite_content_config_timeout > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_content_config_timeout $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_url -> scenario_satellite_618_configure_provisioning_satellite_url'
grep -R -l -w -e satellite_url $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_url scenario_satellite_618_configure_provisioning_satellite_url > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_url $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_username -> scenario_satellite_618_configure_provisioning_satellite_username'
grep -R -l -w -e satellite_username $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_username scenario_satellite_618_configure_provisioning_satellite_username > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_username $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_validate_ssl -> scenario_satellite_618_configure_provisioning_satellite_validate_ssl'
grep -R -l -w -e satellite_validate_ssl $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_validate_ssl scenario_satellite_618_configure_provisioning_satellite_validate_ssl > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_validate_ssl $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_organization -> scenario_satellite_618_configure_provisioning_satellite_organization'
grep -R -l -w -e satellite_organization $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_organization scenario_satellite_618_configure_provisioning_satellite_organization > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_organization $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_location -> scenario_satellite_618_configure_provisioning_satellite_location'
grep -R -l -w -e satellite_location $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_location scenario_satellite_618_configure_provisioning_satellite_location > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_location $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_organizations -> scenario_satellite_618_configure_provisioning_create_organizations'
grep -R -l -w -e create_organizations $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_organizations scenario_satellite_618_configure_provisioning_create_organizations > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_organizations $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_locations -> scenario_satellite_618_configure_provisioning_create_locations'
grep -R -l -w -e create_locations $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_locations scenario_satellite_618_configure_provisioning_create_locations > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_locations $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_products -> scenario_satellite_618_configure_provisioning_create_products'
grep -R -l -w -e create_products $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_products scenario_satellite_618_configure_provisioning_create_products > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_products $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_repositories -> scenario_satellite_618_configure_provisioning_create_repositories'
grep -R -l -w -e create_repositories $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_repositories scenario_satellite_618_configure_provisioning_create_repositories > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_repositories $EXCLUDES .) || true
echo '---'
echo 'Mapping: synchronize_repositories -> scenario_satellite_618_configure_provisioning_synchronize_repositories'
grep -R -l -w -e synchronize_repositories $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" synchronize_repositories scenario_satellite_618_configure_provisioning_synchronize_repositories > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e synchronize_repositories $EXCLUDES .) || true
echo '---'
echo 'Mapping: enable_repository_sets -> scenario_satellite_618_configure_provisioning_enable_repository_sets'
grep -R -l -w -e enable_repository_sets $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" enable_repository_sets scenario_satellite_618_configure_provisioning_enable_repository_sets > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e enable_repository_sets $EXCLUDES .) || true
echo '---'
echo 'Mapping: repository_sets_to_enable -> scenario_satellite_618_configure_provisioning_repository_sets_to_enable'
grep -R -l -w -e repository_sets_to_enable $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" repository_sets_to_enable scenario_satellite_618_configure_provisioning_repository_sets_to_enable > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e repository_sets_to_enable $EXCLUDES .) || true
echo '---'
echo 'Mapping: organizations -> scenario_satellite_618_configure_provisioning_organizations'
grep -R -l -w -e organizations $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" organizations scenario_satellite_618_configure_provisioning_organizations > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e organizations $EXCLUDES .) || true
echo '---'
echo 'Mapping: locations -> scenario_satellite_618_configure_provisioning_locations'
grep -R -l -w -e locations $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" locations scenario_satellite_618_configure_provisioning_locations > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e locations $EXCLUDES .) || true
echo '---'
echo 'Mapping: products -> scenario_satellite_618_configure_provisioning_products'
grep -R -l -w -e products $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" products scenario_satellite_618_configure_provisioning_products > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e products $EXCLUDES .) || true
echo '---'
echo 'Mapping: repositories -> scenario_satellite_618_configure_provisioning_repositories'
grep -R -l -w -e repositories $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" repositories scenario_satellite_618_configure_provisioning_repositories > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e repositories $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_sync_plans -> scenario_satellite_618_configure_provisioning_create_sync_plans'
grep -R -l -w -e create_sync_plans $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_sync_plans scenario_satellite_618_configure_provisioning_create_sync_plans > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_sync_plans $EXCLUDES .) || true
echo '---'
echo 'Mapping: sync_plans -> scenario_satellite_618_configure_provisioning_sync_plans'
grep -R -l -w -e sync_plans $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" sync_plans scenario_satellite_618_configure_provisioning_sync_plans > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e sync_plans $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_content_validate_connectivity -> scenario_satellite_618_configure_provisioning_satellite_content_validate_connectivity'
grep -R -l -w -e satellite_content_validate_connectivity $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_content_validate_connectivity scenario_satellite_618_configure_provisioning_satellite_content_validate_connectivity > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_content_validate_connectivity $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_content_test_sync -> scenario_satellite_618_configure_provisioning_satellite_content_test_sync'
grep -R -l -w -e satellite_content_test_sync $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_content_test_sync scenario_satellite_618_configure_provisioning_satellite_content_test_sync > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_content_test_sync $EXCLUDES .) || true
echo 'Preview complete.'
