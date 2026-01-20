#!/usr/bin/env bash
# Preview script for role: scenario_aap_setup
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

echo 'Role: scenario_aap_setup'
echo 'Mappings:'
echo '  aap_2_6_setup_enabled -> scenario_aap_setup_aap_2_6_setup_enabled'
echo '  aap_2_6_setup_version -> scenario_aap_setup_aap_2_6_setup_version'
echo '  setup_aap_controllers -> scenario_aap_setup_setup_aap_controllers'
echo '  setup_aap_event_driven -> scenario_aap_setup_setup_aap_event_driven'
echo '  aap_2_6_setup_validate_prerequisites -> scenario_aap_setup_aap_2_6_setup_validate_prerequisites'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: aap_2_6_setup_enabled -> scenario_aap_setup_aap_2_6_setup_enabled'
grep -R -l -w -e aap_2_6_setup_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_2_6_setup_enabled scenario_aap_setup_aap_2_6_setup_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_2_6_setup_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_2_6_setup_version -> scenario_aap_setup_aap_2_6_setup_version'
grep -R -l -w -e aap_2_6_setup_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_2_6_setup_version scenario_aap_setup_aap_2_6_setup_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_2_6_setup_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: setup_aap_controllers -> scenario_aap_setup_setup_aap_controllers'
grep -R -l -w -e setup_aap_controllers $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" setup_aap_controllers scenario_aap_setup_setup_aap_controllers > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e setup_aap_controllers $EXCLUDES .) || true
echo '---'
echo 'Mapping: setup_aap_event_driven -> scenario_aap_setup_setup_aap_event_driven'
grep -R -l -w -e setup_aap_event_driven $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" setup_aap_event_driven scenario_aap_setup_setup_aap_event_driven > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e setup_aap_event_driven $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_2_6_setup_validate_prerequisites -> scenario_aap_setup_aap_2_6_setup_validate_prerequisites'
grep -R -l -w -e aap_2_6_setup_validate_prerequisites $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_2_6_setup_validate_prerequisites scenario_aap_setup_aap_2_6_setup_validate_prerequisites > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_2_6_setup_validate_prerequisites $EXCLUDES .) || true
echo 'Preview complete.'
