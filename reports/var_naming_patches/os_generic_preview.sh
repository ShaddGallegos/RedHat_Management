#!/usr/bin/env bash
# Preview script for role: os_generic
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

echo 'Role: os_generic'
echo 'Mappings:'
echo '  os_enabled -> os_generic_os_enabled'
echo '  os_version -> os_generic_os_version'
echo '  configure_firewall -> os_generic_configure_firewall'
echo '  enable_selinux -> os_generic_enable_selinux'
echo '  configure_network -> os_generic_configure_network'
echo '  install_required_packages -> os_generic_install_required_packages'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: os_enabled -> os_generic_os_enabled'
grep -R -l -w -e os_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" os_enabled os_generic_os_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e os_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: os_version -> os_generic_os_version'
grep -R -l -w -e os_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" os_version os_generic_os_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e os_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: configure_firewall -> os_generic_configure_firewall'
grep -R -l -w -e configure_firewall $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" configure_firewall os_generic_configure_firewall > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e configure_firewall $EXCLUDES .) || true
echo '---'
echo 'Mapping: enable_selinux -> os_generic_enable_selinux'
grep -R -l -w -e enable_selinux $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" enable_selinux os_generic_enable_selinux > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e enable_selinux $EXCLUDES .) || true
echo '---'
echo 'Mapping: configure_network -> os_generic_configure_network'
grep -R -l -w -e configure_network $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" configure_network os_generic_configure_network > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e configure_network $EXCLUDES .) || true
echo '---'
echo 'Mapping: install_required_packages -> os_generic_install_required_packages'
grep -R -l -w -e install_required_packages $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" install_required_packages os_generic_install_required_packages > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e install_required_packages $EXCLUDES .) || true
echo 'Preview complete.'
