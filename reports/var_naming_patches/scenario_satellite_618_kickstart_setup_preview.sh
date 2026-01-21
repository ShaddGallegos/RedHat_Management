#!/usr/bin/env bash
# Preview script for role: scenario_satellite_618_kickstart_setup
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

echo 'Role: scenario_satellite_618_kickstart_setup'
echo 'Mappings:'
echo '  satellite_kickstart_config_enabled -> scenario_satellite_618_kickstart_setup_satellite_kickstart_config_enabled'
echo '  satellite_kickstart_config_version -> scenario_satellite_618_kickstart_setup_satellite_kickstart_config_version'
echo '  satellite_kickstart_config_timeout -> scenario_satellite_618_kickstart_setup_satellite_kickstart_config_timeout'
echo '  satellite_url -> scenario_satellite_618_kickstart_setup_satellite_url'
echo '  satellite_username -> scenario_satellite_618_kickstart_setup_satellite_username'
echo '  satellite_validate_ssl -> scenario_satellite_618_kickstart_setup_satellite_validate_ssl'
echo '  satellite_organization -> scenario_satellite_618_kickstart_setup_satellite_organization'
echo '  create_provisioning_templates -> scenario_satellite_618_kickstart_setup_create_provisioning_templates'
echo '  upload_kickstart_files -> scenario_satellite_618_kickstart_setup_upload_kickstart_files'
echo '  kickstart_templates -> scenario_satellite_618_kickstart_setup_kickstart_templates'
echo '  kickstart_files_path -> scenario_satellite_618_kickstart_setup_kickstart_files_path'
echo '  kickstart_web_url -> scenario_satellite_618_kickstart_setup_kickstart_web_url'
echo '  rhel9_baseos_minimal_ks -> scenario_satellite_618_kickstart_setup_rhel9_baseos_minimal_ks'
echo '  rhel10_baseos_minimal_ks -> scenario_satellite_618_kickstart_setup_rhel10_baseos_minimal_ks'
echo '  rhel9_fullstack_ks -> scenario_satellite_618_kickstart_setup_rhel9_fullstack_ks'
echo '  rhel10_fullstack_ks -> scenario_satellite_618_kickstart_setup_rhel10_fullstack_ks'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: satellite_kickstart_config_enabled -> scenario_satellite_618_kickstart_setup_satellite_kickstart_config_enabled'
grep -R -l -w -e satellite_kickstart_config_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_kickstart_config_enabled scenario_satellite_618_kickstart_setup_satellite_kickstart_config_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_kickstart_config_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_kickstart_config_version -> scenario_satellite_618_kickstart_setup_satellite_kickstart_config_version'
grep -R -l -w -e satellite_kickstart_config_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_kickstart_config_version scenario_satellite_618_kickstart_setup_satellite_kickstart_config_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_kickstart_config_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_kickstart_config_timeout -> scenario_satellite_618_kickstart_setup_satellite_kickstart_config_timeout'
grep -R -l -w -e satellite_kickstart_config_timeout $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_kickstart_config_timeout scenario_satellite_618_kickstart_setup_satellite_kickstart_config_timeout > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_kickstart_config_timeout $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_url -> scenario_satellite_618_kickstart_setup_satellite_url'
grep -R -l -w -e satellite_url $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_url scenario_satellite_618_kickstart_setup_satellite_url > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_url $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_username -> scenario_satellite_618_kickstart_setup_satellite_username'
grep -R -l -w -e satellite_username $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_username scenario_satellite_618_kickstart_setup_satellite_username > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_username $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_validate_ssl -> scenario_satellite_618_kickstart_setup_satellite_validate_ssl'
grep -R -l -w -e satellite_validate_ssl $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_validate_ssl scenario_satellite_618_kickstart_setup_satellite_validate_ssl > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_validate_ssl $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_organization -> scenario_satellite_618_kickstart_setup_satellite_organization'
grep -R -l -w -e satellite_organization $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_organization scenario_satellite_618_kickstart_setup_satellite_organization > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_organization $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_provisioning_templates -> scenario_satellite_618_kickstart_setup_create_provisioning_templates'
grep -R -l -w -e create_provisioning_templates $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_provisioning_templates scenario_satellite_618_kickstart_setup_create_provisioning_templates > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_provisioning_templates $EXCLUDES .) || true
echo '---'
echo 'Mapping: upload_kickstart_files -> scenario_satellite_618_kickstart_setup_upload_kickstart_files'
grep -R -l -w -e upload_kickstart_files $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" upload_kickstart_files scenario_satellite_618_kickstart_setup_upload_kickstart_files > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e upload_kickstart_files $EXCLUDES .) || true
echo '---'
echo 'Mapping: kickstart_templates -> scenario_satellite_618_kickstart_setup_kickstart_templates'
grep -R -l -w -e kickstart_templates $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" kickstart_templates scenario_satellite_618_kickstart_setup_kickstart_templates > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e kickstart_templates $EXCLUDES .) || true
echo '---'
echo 'Mapping: kickstart_files_path -> scenario_satellite_618_kickstart_setup_kickstart_files_path'
grep -R -l -w -e kickstart_files_path $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" kickstart_files_path scenario_satellite_618_kickstart_setup_kickstart_files_path > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e kickstart_files_path $EXCLUDES .) || true
echo '---'
echo 'Mapping: kickstart_web_url -> scenario_satellite_618_kickstart_setup_kickstart_web_url'
grep -R -l -w -e kickstart_web_url $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" kickstart_web_url scenario_satellite_618_kickstart_setup_kickstart_web_url > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e kickstart_web_url $EXCLUDES .) || true
echo '---'
echo 'Mapping: rhel9_baseos_minimal_ks -> scenario_satellite_618_kickstart_setup_rhel9_baseos_minimal_ks'
grep -R -l -w -e rhel9_baseos_minimal_ks $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" rhel9_baseos_minimal_ks scenario_satellite_618_kickstart_setup_rhel9_baseos_minimal_ks > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e rhel9_baseos_minimal_ks $EXCLUDES .) || true
echo '---'
echo 'Mapping: rhel10_baseos_minimal_ks -> scenario_satellite_618_kickstart_setup_rhel10_baseos_minimal_ks'
grep -R -l -w -e rhel10_baseos_minimal_ks $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" rhel10_baseos_minimal_ks scenario_satellite_618_kickstart_setup_rhel10_baseos_minimal_ks > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e rhel10_baseos_minimal_ks $EXCLUDES .) || true
echo '---'
echo 'Mapping: rhel9_fullstack_ks -> scenario_satellite_618_kickstart_setup_rhel9_fullstack_ks'
grep -R -l -w -e rhel9_fullstack_ks $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" rhel9_fullstack_ks scenario_satellite_618_kickstart_setup_rhel9_fullstack_ks > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e rhel9_fullstack_ks $EXCLUDES .) || true
echo '---'
echo 'Mapping: rhel10_fullstack_ks -> scenario_satellite_618_kickstart_setup_rhel10_fullstack_ks'
grep -R -l -w -e rhel10_fullstack_ks $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" rhel10_fullstack_ks scenario_satellite_618_kickstart_setup_rhel10_fullstack_ks > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e rhel10_fullstack_ks $EXCLUDES .) || true
echo 'Preview complete.'
