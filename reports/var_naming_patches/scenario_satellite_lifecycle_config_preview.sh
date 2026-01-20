#!/usr/bin/env bash
# Preview script for role: scenario_satellite_lifecycle_config
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

echo 'Role: scenario_satellite_lifecycle_config'
echo 'Mappings:'
echo '  satellite_lifecycle_config_enabled -> scenario_satellite_lifecycle_config_satellite_lifecycle_config_enabled'
echo '  satellite_lifecycle_config_version -> scenario_satellite_lifecycle_config_satellite_lifecycle_config_version'
echo '  satellite_lifecycle_config_timeout -> scenario_satellite_lifecycle_config_satellite_lifecycle_config_timeout'
echo '  satellite_url -> scenario_satellite_lifecycle_config_satellite_url'
echo '  satellite_username -> scenario_satellite_lifecycle_config_satellite_username'
echo '  satellite_validate_ssl -> scenario_satellite_lifecycle_config_satellite_validate_ssl'
echo '  satellite_organization -> scenario_satellite_lifecycle_config_satellite_organization'
echo '  create_lifecycle_environments -> scenario_satellite_lifecycle_config_create_lifecycle_environments'
echo '  create_content_views -> scenario_satellite_lifecycle_config_create_content_views'
echo '  create_filters -> scenario_satellite_lifecycle_config_create_filters'
echo '  publish_content_views -> scenario_satellite_lifecycle_config_publish_content_views'
echo '  promote_content_views -> scenario_satellite_lifecycle_config_promote_content_views'
echo '  lifecycle_environments -> scenario_satellite_lifecycle_config_lifecycle_environments'
echo '  content_views -> scenario_satellite_lifecycle_config_content_views'
echo '  content_view_filters -> scenario_satellite_lifecycle_config_content_view_filters'
echo '  composite_content_views -> scenario_satellite_lifecycle_config_composite_content_views'
echo '  promote_versions -> scenario_satellite_lifecycle_config_promote_versions'
echo '  satellite_lifecycle_validate_connectivity -> scenario_satellite_lifecycle_config_satellite_lifecycle_validate_connectivity'
echo '  satellite_lifecycle_test_promotion -> scenario_satellite_lifecycle_config_satellite_lifecycle_test_promotion'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: satellite_lifecycle_config_enabled -> scenario_satellite_lifecycle_config_satellite_lifecycle_config_enabled'
grep -R -l -w -e satellite_lifecycle_config_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_lifecycle_config_enabled scenario_satellite_lifecycle_config_satellite_lifecycle_config_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_lifecycle_config_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_lifecycle_config_version -> scenario_satellite_lifecycle_config_satellite_lifecycle_config_version'
grep -R -l -w -e satellite_lifecycle_config_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_lifecycle_config_version scenario_satellite_lifecycle_config_satellite_lifecycle_config_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_lifecycle_config_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_lifecycle_config_timeout -> scenario_satellite_lifecycle_config_satellite_lifecycle_config_timeout'
grep -R -l -w -e satellite_lifecycle_config_timeout $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_lifecycle_config_timeout scenario_satellite_lifecycle_config_satellite_lifecycle_config_timeout > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_lifecycle_config_timeout $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_url -> scenario_satellite_lifecycle_config_satellite_url'
grep -R -l -w -e satellite_url $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_url scenario_satellite_lifecycle_config_satellite_url > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_url $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_username -> scenario_satellite_lifecycle_config_satellite_username'
grep -R -l -w -e satellite_username $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_username scenario_satellite_lifecycle_config_satellite_username > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_username $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_validate_ssl -> scenario_satellite_lifecycle_config_satellite_validate_ssl'
grep -R -l -w -e satellite_validate_ssl $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_validate_ssl scenario_satellite_lifecycle_config_satellite_validate_ssl > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_validate_ssl $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_organization -> scenario_satellite_lifecycle_config_satellite_organization'
grep -R -l -w -e satellite_organization $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_organization scenario_satellite_lifecycle_config_satellite_organization > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_organization $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_lifecycle_environments -> scenario_satellite_lifecycle_config_create_lifecycle_environments'
grep -R -l -w -e create_lifecycle_environments $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_lifecycle_environments scenario_satellite_lifecycle_config_create_lifecycle_environments > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_lifecycle_environments $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_content_views -> scenario_satellite_lifecycle_config_create_content_views'
grep -R -l -w -e create_content_views $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_content_views scenario_satellite_lifecycle_config_create_content_views > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_content_views $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_filters -> scenario_satellite_lifecycle_config_create_filters'
grep -R -l -w -e create_filters $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_filters scenario_satellite_lifecycle_config_create_filters > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_filters $EXCLUDES .) || true
echo '---'
echo 'Mapping: publish_content_views -> scenario_satellite_lifecycle_config_publish_content_views'
grep -R -l -w -e publish_content_views $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" publish_content_views scenario_satellite_lifecycle_config_publish_content_views > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e publish_content_views $EXCLUDES .) || true
echo '---'
echo 'Mapping: promote_content_views -> scenario_satellite_lifecycle_config_promote_content_views'
grep -R -l -w -e promote_content_views $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" promote_content_views scenario_satellite_lifecycle_config_promote_content_views > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e promote_content_views $EXCLUDES .) || true
echo '---'
echo 'Mapping: lifecycle_environments -> scenario_satellite_lifecycle_config_lifecycle_environments'
grep -R -l -w -e lifecycle_environments $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" lifecycle_environments scenario_satellite_lifecycle_config_lifecycle_environments > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e lifecycle_environments $EXCLUDES .) || true
echo '---'
echo 'Mapping: content_views -> scenario_satellite_lifecycle_config_content_views'
grep -R -l -w -e content_views $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" content_views scenario_satellite_lifecycle_config_content_views > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e content_views $EXCLUDES .) || true
echo '---'
echo 'Mapping: content_view_filters -> scenario_satellite_lifecycle_config_content_view_filters'
grep -R -l -w -e content_view_filters $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" content_view_filters scenario_satellite_lifecycle_config_content_view_filters > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e content_view_filters $EXCLUDES .) || true
echo '---'
echo 'Mapping: composite_content_views -> scenario_satellite_lifecycle_config_composite_content_views'
grep -R -l -w -e composite_content_views $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" composite_content_views scenario_satellite_lifecycle_config_composite_content_views > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e composite_content_views $EXCLUDES .) || true
echo '---'
echo 'Mapping: promote_versions -> scenario_satellite_lifecycle_config_promote_versions'
grep -R -l -w -e promote_versions $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" promote_versions scenario_satellite_lifecycle_config_promote_versions > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e promote_versions $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_lifecycle_validate_connectivity -> scenario_satellite_lifecycle_config_satellite_lifecycle_validate_connectivity'
grep -R -l -w -e satellite_lifecycle_validate_connectivity $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_lifecycle_validate_connectivity scenario_satellite_lifecycle_config_satellite_lifecycle_validate_connectivity > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_lifecycle_validate_connectivity $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_lifecycle_test_promotion -> scenario_satellite_lifecycle_config_satellite_lifecycle_test_promotion'
grep -R -l -w -e satellite_lifecycle_test_promotion $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_lifecycle_test_promotion scenario_satellite_lifecycle_config_satellite_lifecycle_test_promotion > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_lifecycle_test_promotion $EXCLUDES .) || true
echo 'Preview complete.'
