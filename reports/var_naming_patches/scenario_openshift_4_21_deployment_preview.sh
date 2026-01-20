#!/usr/bin/env bash
# Preview script for role: scenario_openshift_4_21_deployment
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

echo 'Role: scenario_openshift_4_21_deployment'
echo 'Mappings:'
echo '  openshift_4_21_deployment_enabled -> scenario_openshift_4_21_deployment_openshift_4_21_deployment_enabled'
echo '  openshift_4_21_deployment_version -> scenario_openshift_4_21_deployment_openshift_4_21_deployment_version'
echo '  openshift_rhis_environment -> scenario_openshift_4_21_deployment_openshift_rhis_environment'
echo '  openshift_4_21_deployment_validate_config -> scenario_openshift_4_21_deployment_openshift_4_21_deployment_validate_config'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: openshift_4_21_deployment_enabled -> scenario_openshift_4_21_deployment_openshift_4_21_deployment_enabled'
grep -R -l -w -e openshift_4_21_deployment_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" openshift_4_21_deployment_enabled scenario_openshift_4_21_deployment_openshift_4_21_deployment_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e openshift_4_21_deployment_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: openshift_4_21_deployment_version -> scenario_openshift_4_21_deployment_openshift_4_21_deployment_version'
grep -R -l -w -e openshift_4_21_deployment_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" openshift_4_21_deployment_version scenario_openshift_4_21_deployment_openshift_4_21_deployment_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e openshift_4_21_deployment_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: openshift_rhis_environment -> scenario_openshift_4_21_deployment_openshift_rhis_environment'
grep -R -l -w -e openshift_rhis_environment $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" openshift_rhis_environment scenario_openshift_4_21_deployment_openshift_rhis_environment > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e openshift_rhis_environment $EXCLUDES .) || true
echo '---'
echo 'Mapping: openshift_4_21_deployment_validate_config -> scenario_openshift_4_21_deployment_openshift_4_21_deployment_validate_config'
grep -R -l -w -e openshift_4_21_deployment_validate_config $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" openshift_4_21_deployment_validate_config scenario_openshift_4_21_deployment_openshift_4_21_deployment_validate_config > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e openshift_4_21_deployment_validate_config $EXCLUDES .) || true
echo 'Preview complete.'
