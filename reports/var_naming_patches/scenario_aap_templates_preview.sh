#!/usr/bin/env bash
# Preview script for role: scenario_aap_templates
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

echo 'Role: scenario_aap_templates'
echo 'Mappings:'
echo '  aap_templates_config_enabled -> scenario_aap_templates_aap_templates_config_enabled'
echo '  aap_templates_config_version -> scenario_aap_templates_aap_templates_config_version'
echo '  aap_templates_config_timeout -> scenario_aap_templates_aap_templates_config_timeout'
echo '  aap_url -> scenario_aap_templates_aap_url'
echo '  aap_username -> scenario_aap_templates_aap_username'
echo '  aap_verify_ssl -> scenario_aap_templates_aap_verify_ssl'
echo '  aap_templates_organization -> scenario_aap_templates_aap_templates_organization'
echo '  create_job_templates -> scenario_aap_templates_create_job_templates'
echo '  job_templates -> scenario_aap_templates_job_templates'
echo '  create_workflow_templates -> scenario_aap_templates_create_workflow_templates'
echo '  workflow_templates -> scenario_aap_templates_workflow_templates'
echo '  workflow_nodes -> scenario_aap_templates_workflow_nodes'
echo '  aap_templates_validate_connectivity -> scenario_aap_templates_aap_templates_validate_connectivity'
echo '  aap_templates_test_validation -> scenario_aap_templates_aap_templates_test_validation'
echo '  aap_templates_ask_variables -> scenario_aap_templates_aap_templates_ask_variables'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: aap_templates_config_enabled -> scenario_aap_templates_aap_templates_config_enabled'
grep -R -l -w -e aap_templates_config_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_templates_config_enabled scenario_aap_templates_aap_templates_config_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_templates_config_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_templates_config_version -> scenario_aap_templates_aap_templates_config_version'
grep -R -l -w -e aap_templates_config_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_templates_config_version scenario_aap_templates_aap_templates_config_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_templates_config_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_templates_config_timeout -> scenario_aap_templates_aap_templates_config_timeout'
grep -R -l -w -e aap_templates_config_timeout $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_templates_config_timeout scenario_aap_templates_aap_templates_config_timeout > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_templates_config_timeout $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_url -> scenario_aap_templates_aap_url'
grep -R -l -w -e aap_url $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_url scenario_aap_templates_aap_url > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_url $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_username -> scenario_aap_templates_aap_username'
grep -R -l -w -e aap_username $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_username scenario_aap_templates_aap_username > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_username $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_verify_ssl -> scenario_aap_templates_aap_verify_ssl'
grep -R -l -w -e aap_verify_ssl $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_verify_ssl scenario_aap_templates_aap_verify_ssl > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_verify_ssl $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_templates_organization -> scenario_aap_templates_aap_templates_organization'
grep -R -l -w -e aap_templates_organization $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_templates_organization scenario_aap_templates_aap_templates_organization > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_templates_organization $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_job_templates -> scenario_aap_templates_create_job_templates'
grep -R -l -w -e create_job_templates $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_job_templates scenario_aap_templates_create_job_templates > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_job_templates $EXCLUDES .) || true
echo '---'
echo 'Mapping: job_templates -> scenario_aap_templates_job_templates'
grep -R -l -w -e job_templates $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" job_templates scenario_aap_templates_job_templates > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e job_templates $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_workflow_templates -> scenario_aap_templates_create_workflow_templates'
grep -R -l -w -e create_workflow_templates $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_workflow_templates scenario_aap_templates_create_workflow_templates > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_workflow_templates $EXCLUDES .) || true
echo '---'
echo 'Mapping: workflow_templates -> scenario_aap_templates_workflow_templates'
grep -R -l -w -e workflow_templates $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" workflow_templates scenario_aap_templates_workflow_templates > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e workflow_templates $EXCLUDES .) || true
echo '---'
echo 'Mapping: workflow_nodes -> scenario_aap_templates_workflow_nodes'
grep -R -l -w -e workflow_nodes $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" workflow_nodes scenario_aap_templates_workflow_nodes > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e workflow_nodes $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_templates_validate_connectivity -> scenario_aap_templates_aap_templates_validate_connectivity'
grep -R -l -w -e aap_templates_validate_connectivity $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_templates_validate_connectivity scenario_aap_templates_aap_templates_validate_connectivity > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_templates_validate_connectivity $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_templates_test_validation -> scenario_aap_templates_aap_templates_test_validation'
grep -R -l -w -e aap_templates_test_validation $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_templates_test_validation scenario_aap_templates_aap_templates_test_validation > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_templates_test_validation $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_templates_ask_variables -> scenario_aap_templates_aap_templates_ask_variables'
grep -R -l -w -e aap_templates_ask_variables $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_templates_ask_variables scenario_aap_templates_aap_templates_ask_variables > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_templates_ask_variables $EXCLUDES .) || true
echo 'Preview complete.'
