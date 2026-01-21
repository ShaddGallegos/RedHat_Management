#!/usr/bin/env bash
# Preview script for role: scenario_aap_controller_setup
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

echo 'Role: scenario_aap_controller_setup'
echo 'Mappings:'
echo '  aap_controller_host -> scenario_aap_controller_setup_aap_controller_host'
echo '  aap_controller_username -> scenario_aap_controller_setup_aap_controller_username'
echo '  aap_controller_password -> scenario_aap_controller_setup_aap_controller_password'
echo '  aap_controller_validate_certs -> scenario_aap_controller_setup_aap_controller_validate_certs'
echo '  aap_manifest_source_path -> scenario_aap_controller_setup_aap_manifest_source_path'
echo '  aap_manifest_force -> scenario_aap_controller_setup_aap_manifest_force'
echo '  aap_settings -> scenario_aap_controller_setup_aap_settings'
echo '  aap_service_cert_path -> scenario_aap_controller_setup_aap_service_cert_path'
echo '  aap_service_key_path -> scenario_aap_controller_setup_aap_service_key_path'
echo '  rhis_controller_manifest_refresh_tag -> scenario_aap_controller_setup_rhis_controller_manifest_refresh_tag'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: aap_controller_host -> scenario_aap_controller_setup_aap_controller_host'
grep -R -l -w -e aap_controller_host $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_controller_host scenario_aap_controller_setup_aap_controller_host > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_controller_host $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_controller_username -> scenario_aap_controller_setup_aap_controller_username'
grep -R -l -w -e aap_controller_username $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_controller_username scenario_aap_controller_setup_aap_controller_username > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_controller_username $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_controller_password -> scenario_aap_controller_setup_aap_controller_password'
grep -R -l -w -e aap_controller_password $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_controller_password scenario_aap_controller_setup_aap_controller_password > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_controller_password $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_controller_validate_certs -> scenario_aap_controller_setup_aap_controller_validate_certs'
grep -R -l -w -e aap_controller_validate_certs $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_controller_validate_certs scenario_aap_controller_setup_aap_controller_validate_certs > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_controller_validate_certs $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_manifest_source_path -> scenario_aap_controller_setup_aap_manifest_source_path'
grep -R -l -w -e aap_manifest_source_path $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_manifest_source_path scenario_aap_controller_setup_aap_manifest_source_path > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_manifest_source_path $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_manifest_force -> scenario_aap_controller_setup_aap_manifest_force'
grep -R -l -w -e aap_manifest_force $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_manifest_force scenario_aap_controller_setup_aap_manifest_force > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_manifest_force $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_settings -> scenario_aap_controller_setup_aap_settings'
grep -R -l -w -e aap_settings $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_settings scenario_aap_controller_setup_aap_settings > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_settings $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_service_cert_path -> scenario_aap_controller_setup_aap_service_cert_path'
grep -R -l -w -e aap_service_cert_path $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_service_cert_path scenario_aap_controller_setup_aap_service_cert_path > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_service_cert_path $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_service_key_path -> scenario_aap_controller_setup_aap_service_key_path'
grep -R -l -w -e aap_service_key_path $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_service_key_path scenario_aap_controller_setup_aap_service_key_path > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_service_key_path $EXCLUDES .) || true
echo '---'
echo 'Mapping: rhis_controller_manifest_refresh_tag -> scenario_aap_controller_setup_rhis_controller_manifest_refresh_tag'
grep -R -l -w -e rhis_controller_manifest_refresh_tag $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" rhis_controller_manifest_refresh_tag scenario_aap_controller_setup_rhis_controller_manifest_refresh_tag > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e rhis_controller_manifest_refresh_tag $EXCLUDES .) || true
echo 'Preview complete.'
