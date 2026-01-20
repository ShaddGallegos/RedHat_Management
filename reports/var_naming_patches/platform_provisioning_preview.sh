#!/usr/bin/env bash
# Preview script for role: platform_provisioning
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

echo 'Role: platform_provisioning'
echo 'Mappings:'
echo '  provisioning_enabled -> platform_provisioning_provisioning_enabled'
echo '  provisioning_version -> platform_provisioning_provisioning_version'
echo '  provisioning_timeout -> platform_provisioning_provisioning_timeout'
echo '  provisioning_max_retries -> platform_provisioning_provisioning_max_retries'
echo '  provision_hosts -> platform_provisioning_provision_hosts'
echo '  configure_networking -> platform_provisioning_configure_networking'
echo '  provisioning_validate_connectivity -> platform_provisioning_provisioning_validate_connectivity'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: provisioning_enabled -> platform_provisioning_provisioning_enabled'
grep -R -l -w -e provisioning_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" provisioning_enabled platform_provisioning_provisioning_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e provisioning_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: provisioning_version -> platform_provisioning_provisioning_version'
grep -R -l -w -e provisioning_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" provisioning_version platform_provisioning_provisioning_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e provisioning_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: provisioning_timeout -> platform_provisioning_provisioning_timeout'
grep -R -l -w -e provisioning_timeout $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" provisioning_timeout platform_provisioning_provisioning_timeout > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e provisioning_timeout $EXCLUDES .) || true
echo '---'
echo 'Mapping: provisioning_max_retries -> platform_provisioning_provisioning_max_retries'
grep -R -l -w -e provisioning_max_retries $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" provisioning_max_retries platform_provisioning_provisioning_max_retries > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e provisioning_max_retries $EXCLUDES .) || true
echo '---'
echo 'Mapping: provision_hosts -> platform_provisioning_provision_hosts'
grep -R -l -w -e provision_hosts $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" provision_hosts platform_provisioning_provision_hosts > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e provision_hosts $EXCLUDES .) || true
echo '---'
echo 'Mapping: configure_networking -> platform_provisioning_configure_networking'
grep -R -l -w -e configure_networking $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" configure_networking platform_provisioning_configure_networking > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e configure_networking $EXCLUDES .) || true
echo '---'
echo 'Mapping: provisioning_validate_connectivity -> platform_provisioning_provisioning_validate_connectivity'
grep -R -l -w -e provisioning_validate_connectivity $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" provisioning_validate_connectivity platform_provisioning_provisioning_validate_connectivity > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e provisioning_validate_connectivity $EXCLUDES .) || true
echo 'Preview complete.'
