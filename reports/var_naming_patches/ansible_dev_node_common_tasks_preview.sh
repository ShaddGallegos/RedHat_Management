#!/usr/bin/env bash
# Preview script for role: ansible_dev_node_common_tasks
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

echo 'Role: ansible_dev_node_common_tasks'
echo 'Mappings:'
echo '  repositories -> ansible_dev_node_common_tasks_repositories'
echo '  ntp_servers -> ansible_dev_node_common_tasks_ntp_servers'
echo '  scap_file -> ansible_dev_node_common_tasks_scap_file'
echo '  scap_profile -> ansible_dev_node_common_tasks_scap_profile'
echo '  mandatory_global_parameters -> ansible_dev_node_common_tasks_mandatory_global_parameters'
echo '  mandatory_os_config -> ansible_dev_node_common_tasks_mandatory_os_config'
echo '  environment -> ansible_dev_node_common_tasks_environment'
echo '  environment_type -> ansible_dev_node_common_tasks_environment_type'
echo '  update_strategy -> ansible_dev_node_common_tasks_update_strategy'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: repositories -> ansible_dev_node_common_tasks_repositories'
grep -R -l -w -e repositories $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" repositories ansible_dev_node_common_tasks_repositories > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e repositories $EXCLUDES .) || true
echo '---'
echo 'Mapping: ntp_servers -> ansible_dev_node_common_tasks_ntp_servers'
grep -R -l -w -e ntp_servers $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" ntp_servers ansible_dev_node_common_tasks_ntp_servers > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e ntp_servers $EXCLUDES .) || true
echo '---'
echo 'Mapping: scap_file -> ansible_dev_node_common_tasks_scap_file'
grep -R -l -w -e scap_file $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" scap_file ansible_dev_node_common_tasks_scap_file > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e scap_file $EXCLUDES .) || true
echo '---'
echo 'Mapping: scap_profile -> ansible_dev_node_common_tasks_scap_profile'
grep -R -l -w -e scap_profile $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" scap_profile ansible_dev_node_common_tasks_scap_profile > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e scap_profile $EXCLUDES .) || true
echo '---'
echo 'Mapping: mandatory_global_parameters -> ansible_dev_node_common_tasks_mandatory_global_parameters'
grep -R -l -w -e mandatory_global_parameters $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" mandatory_global_parameters ansible_dev_node_common_tasks_mandatory_global_parameters > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e mandatory_global_parameters $EXCLUDES .) || true
echo '---'
echo 'Mapping: mandatory_os_config -> ansible_dev_node_common_tasks_mandatory_os_config'
grep -R -l -w -e mandatory_os_config $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" mandatory_os_config ansible_dev_node_common_tasks_mandatory_os_config > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e mandatory_os_config $EXCLUDES .) || true
echo '---'
echo 'Mapping: environment -> ansible_dev_node_common_tasks_environment'
grep -R -l -w -e environment $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" environment ansible_dev_node_common_tasks_environment > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e environment $EXCLUDES .) || true
echo '---'
echo 'Mapping: environment_type -> ansible_dev_node_common_tasks_environment_type'
grep -R -l -w -e environment_type $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" environment_type ansible_dev_node_common_tasks_environment_type > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e environment_type $EXCLUDES .) || true
echo '---'
echo 'Mapping: update_strategy -> ansible_dev_node_common_tasks_update_strategy'
grep -R -l -w -e update_strategy $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" update_strategy ansible_dev_node_common_tasks_update_strategy > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e update_strategy $EXCLUDES .) || true
echo 'Preview complete.'
