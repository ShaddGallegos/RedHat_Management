#!/usr/bin/env bash
# Preview script for role: integration_generic
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

echo 'Role: integration_generic'
echo 'Mappings:'
echo '  integration_enabled -> integration_generic_integration_enabled'
echo '  integration_version -> integration_generic_integration_version'
echo '  integration_timeout -> integration_generic_integration_timeout'
echo '  configure_satellite_aap_integration -> integration_generic_configure_satellite_aap_integration'
echo '  configure_satellite_idm_integration -> integration_generic_configure_satellite_idm_integration'
echo '  configure_aap_idm_integration -> integration_generic_configure_aap_idm_integration'
echo '  configure_satellite_insights_integration -> integration_generic_configure_satellite_insights_integration'
echo '  integration_validate_connectivity -> integration_generic_integration_validate_connectivity'
echo '  integration_test_integration -> integration_generic_integration_test_integration'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: integration_enabled -> integration_generic_integration_enabled'
grep -R -l -w -e integration_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" integration_enabled integration_generic_integration_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e integration_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: integration_version -> integration_generic_integration_version'
grep -R -l -w -e integration_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" integration_version integration_generic_integration_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e integration_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: integration_timeout -> integration_generic_integration_timeout'
grep -R -l -w -e integration_timeout $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" integration_timeout integration_generic_integration_timeout > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e integration_timeout $EXCLUDES .) || true
echo '---'
echo 'Mapping: configure_satellite_aap_integration -> integration_generic_configure_satellite_aap_integration'
grep -R -l -w -e configure_satellite_aap_integration $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" configure_satellite_aap_integration integration_generic_configure_satellite_aap_integration > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e configure_satellite_aap_integration $EXCLUDES .) || true
echo '---'
echo 'Mapping: configure_satellite_idm_integration -> integration_generic_configure_satellite_idm_integration'
grep -R -l -w -e configure_satellite_idm_integration $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" configure_satellite_idm_integration integration_generic_configure_satellite_idm_integration > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e configure_satellite_idm_integration $EXCLUDES .) || true
echo '---'
echo 'Mapping: configure_aap_idm_integration -> integration_generic_configure_aap_idm_integration'
grep -R -l -w -e configure_aap_idm_integration $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" configure_aap_idm_integration integration_generic_configure_aap_idm_integration > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e configure_aap_idm_integration $EXCLUDES .) || true
echo '---'
echo 'Mapping: configure_satellite_insights_integration -> integration_generic_configure_satellite_insights_integration'
grep -R -l -w -e configure_satellite_insights_integration $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" configure_satellite_insights_integration integration_generic_configure_satellite_insights_integration > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e configure_satellite_insights_integration $EXCLUDES .) || true
echo '---'
echo 'Mapping: integration_validate_connectivity -> integration_generic_integration_validate_connectivity'
grep -R -l -w -e integration_validate_connectivity $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" integration_validate_connectivity integration_generic_integration_validate_connectivity > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e integration_validate_connectivity $EXCLUDES .) || true
echo '---'
echo 'Mapping: integration_test_integration -> integration_generic_integration_test_integration'
grep -R -l -w -e integration_test_integration $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" integration_test_integration integration_generic_integration_test_integration > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e integration_test_integration $EXCLUDES .) || true
echo 'Preview complete.'
