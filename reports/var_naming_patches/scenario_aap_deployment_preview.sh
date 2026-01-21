#!/usr/bin/env bash
# Preview script for role: scenario_aap_deployment
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

echo 'Role: scenario_aap_deployment'
echo 'Mappings:'
echo '  aap_installer_version -> scenario_aap_deployment_aap_installer_version'
echo '  aap_installer_download_url -> scenario_aap_deployment_aap_installer_download_url'
echo '  aap_installer_bundle_dir -> scenario_aap_deployment_aap_installer_bundle_dir'
echo '  aap_installer_inventory_dir -> scenario_aap_deployment_aap_installer_inventory_dir'
echo '  aap_content_source_path -> scenario_aap_deployment_aap_content_source_path'
echo '  aap_content_download_timeout -> scenario_aap_deployment_aap_content_download_timeout'
echo '  builder_key_file -> scenario_aap_deployment_builder_key_file'
echo '  deployment_user -> scenario_aap_deployment_deployment_user'
echo '  controllers -> scenario_aap_deployment_controllers'
echo '  aap_installer_template_src -> scenario_aap_deployment_aap_installer_template_src'
echo '  aap_installer_template_dest -> scenario_aap_deployment_aap_installer_template_dest'
echo '  aap_install_verbosity -> scenario_aap_deployment_aap_install_verbosity'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: aap_installer_version -> scenario_aap_deployment_aap_installer_version'
grep -R -l -w -e aap_installer_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_installer_version scenario_aap_deployment_aap_installer_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_installer_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_installer_download_url -> scenario_aap_deployment_aap_installer_download_url'
grep -R -l -w -e aap_installer_download_url $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_installer_download_url scenario_aap_deployment_aap_installer_download_url > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_installer_download_url $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_installer_bundle_dir -> scenario_aap_deployment_aap_installer_bundle_dir'
grep -R -l -w -e aap_installer_bundle_dir $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_installer_bundle_dir scenario_aap_deployment_aap_installer_bundle_dir > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_installer_bundle_dir $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_installer_inventory_dir -> scenario_aap_deployment_aap_installer_inventory_dir'
grep -R -l -w -e aap_installer_inventory_dir $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_installer_inventory_dir scenario_aap_deployment_aap_installer_inventory_dir > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_installer_inventory_dir $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_content_source_path -> scenario_aap_deployment_aap_content_source_path'
grep -R -l -w -e aap_content_source_path $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_content_source_path scenario_aap_deployment_aap_content_source_path > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_content_source_path $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_content_download_timeout -> scenario_aap_deployment_aap_content_download_timeout'
grep -R -l -w -e aap_content_download_timeout $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_content_download_timeout scenario_aap_deployment_aap_content_download_timeout > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_content_download_timeout $EXCLUDES .) || true
echo '---'
echo 'Mapping: builder_key_file -> scenario_aap_deployment_builder_key_file'
grep -R -l -w -e builder_key_file $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" builder_key_file scenario_aap_deployment_builder_key_file > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e builder_key_file $EXCLUDES .) || true
echo '---'
echo 'Mapping: deployment_user -> scenario_aap_deployment_deployment_user'
grep -R -l -w -e deployment_user $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" deployment_user scenario_aap_deployment_deployment_user > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e deployment_user $EXCLUDES .) || true
echo '---'
echo 'Mapping: controllers -> scenario_aap_deployment_controllers'
grep -R -l -w -e controllers $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" controllers scenario_aap_deployment_controllers > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e controllers $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_installer_template_src -> scenario_aap_deployment_aap_installer_template_src'
grep -R -l -w -e aap_installer_template_src $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_installer_template_src scenario_aap_deployment_aap_installer_template_src > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_installer_template_src $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_installer_template_dest -> scenario_aap_deployment_aap_installer_template_dest'
grep -R -l -w -e aap_installer_template_dest $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_installer_template_dest scenario_aap_deployment_aap_installer_template_dest > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_installer_template_dest $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_install_verbosity -> scenario_aap_deployment_aap_install_verbosity'
grep -R -l -w -e aap_install_verbosity $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_install_verbosity scenario_aap_deployment_aap_install_verbosity > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_install_verbosity $EXCLUDES .) || true
echo 'Preview complete.'
