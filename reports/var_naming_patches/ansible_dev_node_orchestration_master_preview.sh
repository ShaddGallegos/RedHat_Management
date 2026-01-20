#!/usr/bin/env bash
# Preview script for role: ansible_dev_node_orchestration_master
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

echo 'Role: ansible_dev_node_orchestration_master'
echo 'Mappings:'
echo '  orchestration_master_enabled -> ansible_dev_node_orchestration_master_orchestration_master_enabled'
echo '  orchestration_master_version -> ansible_dev_node_orchestration_master_orchestration_master_version'
echo '  orchestration_master_timeout -> ansible_dev_node_orchestration_master_orchestration_master_timeout'
echo '  orchestration_master_max_retries -> ansible_dev_node_orchestration_master_orchestration_master_max_retries'
echo '  deploy_infrastructure -> ansible_dev_node_orchestration_master_deploy_infrastructure'
echo '  configure_os -> ansible_dev_node_orchestration_master_configure_os'
echo '  deploy_products -> ansible_dev_node_orchestration_master_deploy_products'
echo '  run_tests -> ansible_dev_node_orchestration_master_run_tests'
echo '  configure_aap_rbac -> ansible_dev_node_orchestration_master_configure_aap_rbac'
echo '  configure_satellite_api -> ansible_dev_node_orchestration_master_configure_satellite_api'
echo '  configure_satellite_content -> ansible_dev_node_orchestration_master_configure_satellite_content'
echo '  deploy_idm_replicas -> ansible_dev_node_orchestration_master_deploy_idm_replicas'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: orchestration_master_enabled -> ansible_dev_node_orchestration_master_orchestration_master_enabled'
grep -R -l -w -e orchestration_master_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" orchestration_master_enabled ansible_dev_node_orchestration_master_orchestration_master_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e orchestration_master_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: orchestration_master_version -> ansible_dev_node_orchestration_master_orchestration_master_version'
grep -R -l -w -e orchestration_master_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" orchestration_master_version ansible_dev_node_orchestration_master_orchestration_master_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e orchestration_master_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: orchestration_master_timeout -> ansible_dev_node_orchestration_master_orchestration_master_timeout'
grep -R -l -w -e orchestration_master_timeout $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" orchestration_master_timeout ansible_dev_node_orchestration_master_orchestration_master_timeout > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e orchestration_master_timeout $EXCLUDES .) || true
echo '---'
echo 'Mapping: orchestration_master_max_retries -> ansible_dev_node_orchestration_master_orchestration_master_max_retries'
grep -R -l -w -e orchestration_master_max_retries $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" orchestration_master_max_retries ansible_dev_node_orchestration_master_orchestration_master_max_retries > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e orchestration_master_max_retries $EXCLUDES .) || true
echo '---'
echo 'Mapping: deploy_infrastructure -> ansible_dev_node_orchestration_master_deploy_infrastructure'
grep -R -l -w -e deploy_infrastructure $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" deploy_infrastructure ansible_dev_node_orchestration_master_deploy_infrastructure > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e deploy_infrastructure $EXCLUDES .) || true
echo '---'
echo 'Mapping: configure_os -> ansible_dev_node_orchestration_master_configure_os'
grep -R -l -w -e configure_os $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" configure_os ansible_dev_node_orchestration_master_configure_os > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e configure_os $EXCLUDES .) || true
echo '---'
echo 'Mapping: deploy_products -> ansible_dev_node_orchestration_master_deploy_products'
grep -R -l -w -e deploy_products $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" deploy_products ansible_dev_node_orchestration_master_deploy_products > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e deploy_products $EXCLUDES .) || true
echo '---'
echo 'Mapping: run_tests -> ansible_dev_node_orchestration_master_run_tests'
grep -R -l -w -e run_tests $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" run_tests ansible_dev_node_orchestration_master_run_tests > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e run_tests $EXCLUDES .) || true
echo '---'
echo 'Mapping: configure_aap_rbac -> ansible_dev_node_orchestration_master_configure_aap_rbac'
grep -R -l -w -e configure_aap_rbac $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" configure_aap_rbac ansible_dev_node_orchestration_master_configure_aap_rbac > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e configure_aap_rbac $EXCLUDES .) || true
echo '---'
echo 'Mapping: configure_satellite_api -> ansible_dev_node_orchestration_master_configure_satellite_api'
grep -R -l -w -e configure_satellite_api $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" configure_satellite_api ansible_dev_node_orchestration_master_configure_satellite_api > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e configure_satellite_api $EXCLUDES .) || true
echo '---'
echo 'Mapping: configure_satellite_content -> ansible_dev_node_orchestration_master_configure_satellite_content'
grep -R -l -w -e configure_satellite_content $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" configure_satellite_content ansible_dev_node_orchestration_master_configure_satellite_content > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e configure_satellite_content $EXCLUDES .) || true
echo '---'
echo 'Mapping: deploy_idm_replicas -> ansible_dev_node_orchestration_master_deploy_idm_replicas'
grep -R -l -w -e deploy_idm_replicas $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" deploy_idm_replicas ansible_dev_node_orchestration_master_deploy_idm_replicas > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e deploy_idm_replicas $EXCLUDES .) || true
echo 'Preview complete.'
