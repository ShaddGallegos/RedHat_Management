#!/usr/bin/env bash
# Preview script for role: scenario_aap_projects
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

echo 'Role: scenario_aap_projects'
echo 'Mappings:'
echo '  aap_projects_config_enabled -> scenario_aap_projects_aap_projects_config_enabled'
echo '  aap_projects_config_version -> scenario_aap_projects_aap_projects_config_version'
echo '  aap_projects_config_timeout -> scenario_aap_projects_aap_projects_config_timeout'
echo '  aap_url -> scenario_aap_projects_aap_url'
echo '  aap_username -> scenario_aap_projects_aap_username'
echo '  aap_verify_ssl -> scenario_aap_projects_aap_verify_ssl'
echo '  aap_projects_organization -> scenario_aap_projects_aap_projects_organization'
echo '  create_git_projects -> scenario_aap_projects_create_git_projects'
echo '  git_projects -> scenario_aap_projects_git_projects'
echo '  create_manual_projects -> scenario_aap_projects_create_manual_projects'
echo '  manual_projects -> scenario_aap_projects_manual_projects'
echo '  aap_projects_validate_connectivity -> scenario_aap_projects_aap_projects_validate_connectivity'
echo '  aap_projects_sync_on_create -> scenario_aap_projects_aap_projects_sync_on_create'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: aap_projects_config_enabled -> scenario_aap_projects_aap_projects_config_enabled'
grep -R -l -w -e aap_projects_config_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_projects_config_enabled scenario_aap_projects_aap_projects_config_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_projects_config_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_projects_config_version -> scenario_aap_projects_aap_projects_config_version'
grep -R -l -w -e aap_projects_config_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_projects_config_version scenario_aap_projects_aap_projects_config_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_projects_config_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_projects_config_timeout -> scenario_aap_projects_aap_projects_config_timeout'
grep -R -l -w -e aap_projects_config_timeout $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_projects_config_timeout scenario_aap_projects_aap_projects_config_timeout > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_projects_config_timeout $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_url -> scenario_aap_projects_aap_url'
grep -R -l -w -e aap_url $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_url scenario_aap_projects_aap_url > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_url $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_username -> scenario_aap_projects_aap_username'
grep -R -l -w -e aap_username $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_username scenario_aap_projects_aap_username > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_username $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_verify_ssl -> scenario_aap_projects_aap_verify_ssl'
grep -R -l -w -e aap_verify_ssl $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_verify_ssl scenario_aap_projects_aap_verify_ssl > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_verify_ssl $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_projects_organization -> scenario_aap_projects_aap_projects_organization'
grep -R -l -w -e aap_projects_organization $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_projects_organization scenario_aap_projects_aap_projects_organization > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_projects_organization $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_git_projects -> scenario_aap_projects_create_git_projects'
grep -R -l -w -e create_git_projects $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_git_projects scenario_aap_projects_create_git_projects > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_git_projects $EXCLUDES .) || true
echo '---'
echo 'Mapping: git_projects -> scenario_aap_projects_git_projects'
grep -R -l -w -e git_projects $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" git_projects scenario_aap_projects_git_projects > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e git_projects $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_manual_projects -> scenario_aap_projects_create_manual_projects'
grep -R -l -w -e create_manual_projects $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_manual_projects scenario_aap_projects_create_manual_projects > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_manual_projects $EXCLUDES .) || true
echo '---'
echo 'Mapping: manual_projects -> scenario_aap_projects_manual_projects'
grep -R -l -w -e manual_projects $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" manual_projects scenario_aap_projects_manual_projects > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e manual_projects $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_projects_validate_connectivity -> scenario_aap_projects_aap_projects_validate_connectivity'
grep -R -l -w -e aap_projects_validate_connectivity $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_projects_validate_connectivity scenario_aap_projects_aap_projects_validate_connectivity > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_projects_validate_connectivity $EXCLUDES .) || true
echo '---'
echo 'Mapping: aap_projects_sync_on_create -> scenario_aap_projects_aap_projects_sync_on_create'
grep -R -l -w -e aap_projects_sync_on_create $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" aap_projects_sync_on_create scenario_aap_projects_aap_projects_sync_on_create > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e aap_projects_sync_on_create $EXCLUDES .) || true
echo 'Preview complete.'
