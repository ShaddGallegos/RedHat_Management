#!/usr/bin/env bash
# Preview script for role: platform_infrastructure_core
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

echo 'Role: platform_infrastructure_core'
echo 'Mappings:'
echo '  infrastructure_enabled -> platform_infrastructure_core_infrastructure_enabled'
echo '  infrastructure_version -> platform_infrastructure_core_infrastructure_version'
echo '  infrastructure_timeout -> platform_infrastructure_core_infrastructure_timeout'
echo '  configure_networking -> platform_infrastructure_core_configure_networking'
echo '  configure_storage -> platform_infrastructure_core_configure_storage'
echo '  infrastructure_validate_resources -> platform_infrastructure_core_infrastructure_validate_resources'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: infrastructure_enabled -> platform_infrastructure_core_infrastructure_enabled'
grep -R -l -w -e infrastructure_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" infrastructure_enabled platform_infrastructure_core_infrastructure_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e infrastructure_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: infrastructure_version -> platform_infrastructure_core_infrastructure_version'
grep -R -l -w -e infrastructure_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" infrastructure_version platform_infrastructure_core_infrastructure_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e infrastructure_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: infrastructure_timeout -> platform_infrastructure_core_infrastructure_timeout'
grep -R -l -w -e infrastructure_timeout $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" infrastructure_timeout platform_infrastructure_core_infrastructure_timeout > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e infrastructure_timeout $EXCLUDES .) || true
echo '---'
echo 'Mapping: configure_networking -> platform_infrastructure_core_configure_networking'
grep -R -l -w -e configure_networking $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" configure_networking platform_infrastructure_core_configure_networking > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e configure_networking $EXCLUDES .) || true
echo '---'
echo 'Mapping: configure_storage -> platform_infrastructure_core_configure_storage'
grep -R -l -w -e configure_storage $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" configure_storage platform_infrastructure_core_configure_storage > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e configure_storage $EXCLUDES .) || true
echo '---'
echo 'Mapping: infrastructure_validate_resources -> platform_infrastructure_core_infrastructure_validate_resources'
grep -R -l -w -e infrastructure_validate_resources $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" infrastructure_validate_resources platform_infrastructure_core_infrastructure_validate_resources > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e infrastructure_validate_resources $EXCLUDES .) || true
echo 'Preview complete.'
