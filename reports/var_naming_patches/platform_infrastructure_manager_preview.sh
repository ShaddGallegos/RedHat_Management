#!/usr/bin/env bash
# Preview script for role: platform_infrastructure_manager
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

echo 'Role: platform_infrastructure_manager'
echo 'Mappings:'
echo '  infrastructure_manager_enabled -> platform_infrastructure_manager_infrastructure_manager_enabled'
echo '  infrastructure_manager_version -> platform_infrastructure_manager_infrastructure_manager_version'
echo '  infrastructure_manager_timeout -> platform_infrastructure_manager_infrastructure_manager_timeout'
echo '  infrastructure_manager_max_retries -> platform_infrastructure_manager_infrastructure_manager_max_retries'
echo '  deploy_infrastructure -> platform_infrastructure_manager_deploy_infrastructure'
echo '  infrastructure_platform -> platform_infrastructure_manager_infrastructure_platform'
echo '  infrastructure_network -> platform_infrastructure_manager_infrastructure_network'
echo '  infrastructure_manager_validate_prerequisites -> platform_infrastructure_manager_infrastructure_manager_validate_prerequisites'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: infrastructure_manager_enabled -> platform_infrastructure_manager_infrastructure_manager_enabled'
grep -R -l -w -e infrastructure_manager_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" infrastructure_manager_enabled platform_infrastructure_manager_infrastructure_manager_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e infrastructure_manager_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: infrastructure_manager_version -> platform_infrastructure_manager_infrastructure_manager_version'
grep -R -l -w -e infrastructure_manager_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" infrastructure_manager_version platform_infrastructure_manager_infrastructure_manager_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e infrastructure_manager_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: infrastructure_manager_timeout -> platform_infrastructure_manager_infrastructure_manager_timeout'
grep -R -l -w -e infrastructure_manager_timeout $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" infrastructure_manager_timeout platform_infrastructure_manager_infrastructure_manager_timeout > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e infrastructure_manager_timeout $EXCLUDES .) || true
echo '---'
echo 'Mapping: infrastructure_manager_max_retries -> platform_infrastructure_manager_infrastructure_manager_max_retries'
grep -R -l -w -e infrastructure_manager_max_retries $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" infrastructure_manager_max_retries platform_infrastructure_manager_infrastructure_manager_max_retries > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e infrastructure_manager_max_retries $EXCLUDES .) || true
echo '---'
echo 'Mapping: deploy_infrastructure -> platform_infrastructure_manager_deploy_infrastructure'
grep -R -l -w -e deploy_infrastructure $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" deploy_infrastructure platform_infrastructure_manager_deploy_infrastructure > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e deploy_infrastructure $EXCLUDES .) || true
echo '---'
echo 'Mapping: infrastructure_platform -> platform_infrastructure_manager_infrastructure_platform'
grep -R -l -w -e infrastructure_platform $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" infrastructure_platform platform_infrastructure_manager_infrastructure_platform > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e infrastructure_platform $EXCLUDES .) || true
echo '---'
echo 'Mapping: infrastructure_network -> platform_infrastructure_manager_infrastructure_network'
grep -R -l -w -e infrastructure_network $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" infrastructure_network platform_infrastructure_manager_infrastructure_network > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e infrastructure_network $EXCLUDES .) || true
echo '---'
echo 'Mapping: infrastructure_manager_validate_prerequisites -> platform_infrastructure_manager_infrastructure_manager_validate_prerequisites'
grep -R -l -w -e infrastructure_manager_validate_prerequisites $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" infrastructure_manager_validate_prerequisites platform_infrastructure_manager_infrastructure_manager_validate_prerequisites > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e infrastructure_manager_validate_prerequisites $EXCLUDES .) || true
echo 'Preview complete.'
