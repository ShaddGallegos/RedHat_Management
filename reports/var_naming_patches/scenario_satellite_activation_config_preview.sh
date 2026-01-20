#!/usr/bin/env bash
# Preview script for role: scenario_satellite_activation_config
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

echo 'Role: scenario_satellite_activation_config'
echo 'Mappings:'
echo '  satellite_activation_config_enabled -> scenario_satellite_activation_config_satellite_activation_config_enabled'
echo '  satellite_activation_config_version -> scenario_satellite_activation_config_satellite_activation_config_version'
echo '  satellite_activation_config_timeout -> scenario_satellite_activation_config_satellite_activation_config_timeout'
echo '  satellite_url -> scenario_satellite_activation_config_satellite_url'
echo '  satellite_username -> scenario_satellite_activation_config_satellite_username'
echo '  satellite_validate_ssl -> scenario_satellite_activation_config_satellite_validate_ssl'
echo '  satellite_organization -> scenario_satellite_activation_config_satellite_organization'
echo '  create_activation_keys -> scenario_satellite_activation_config_create_activation_keys'
echo '  attach_subscriptions -> scenario_satellite_activation_config_attach_subscriptions'
echo '  configure_host_collections -> scenario_satellite_activation_config_configure_host_collections'
echo '  host_collections -> scenario_satellite_activation_config_host_collections'
echo '  activation_keys -> scenario_satellite_activation_config_activation_keys'
echo '  subscription_attachments -> scenario_satellite_activation_config_subscription_attachments'
echo '  repository_sets -> scenario_satellite_activation_config_repository_sets'
echo '  satellite_activation_validate_connectivity -> scenario_satellite_activation_config_satellite_activation_validate_connectivity'
echo '  satellite_activation_test_keys -> scenario_satellite_activation_config_satellite_activation_test_keys'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: satellite_activation_config_enabled -> scenario_satellite_activation_config_satellite_activation_config_enabled'
grep -R -l -w -e satellite_activation_config_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_activation_config_enabled scenario_satellite_activation_config_satellite_activation_config_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_activation_config_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_activation_config_version -> scenario_satellite_activation_config_satellite_activation_config_version'
grep -R -l -w -e satellite_activation_config_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_activation_config_version scenario_satellite_activation_config_satellite_activation_config_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_activation_config_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_activation_config_timeout -> scenario_satellite_activation_config_satellite_activation_config_timeout'
grep -R -l -w -e satellite_activation_config_timeout $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_activation_config_timeout scenario_satellite_activation_config_satellite_activation_config_timeout > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_activation_config_timeout $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_url -> scenario_satellite_activation_config_satellite_url'
grep -R -l -w -e satellite_url $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_url scenario_satellite_activation_config_satellite_url > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_url $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_username -> scenario_satellite_activation_config_satellite_username'
grep -R -l -w -e satellite_username $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_username scenario_satellite_activation_config_satellite_username > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_username $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_validate_ssl -> scenario_satellite_activation_config_satellite_validate_ssl'
grep -R -l -w -e satellite_validate_ssl $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_validate_ssl scenario_satellite_activation_config_satellite_validate_ssl > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_validate_ssl $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_organization -> scenario_satellite_activation_config_satellite_organization'
grep -R -l -w -e satellite_organization $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_organization scenario_satellite_activation_config_satellite_organization > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_organization $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_activation_keys -> scenario_satellite_activation_config_create_activation_keys'
grep -R -l -w -e create_activation_keys $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_activation_keys scenario_satellite_activation_config_create_activation_keys > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_activation_keys $EXCLUDES .) || true
echo '---'
echo 'Mapping: attach_subscriptions -> scenario_satellite_activation_config_attach_subscriptions'
grep -R -l -w -e attach_subscriptions $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" attach_subscriptions scenario_satellite_activation_config_attach_subscriptions > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e attach_subscriptions $EXCLUDES .) || true
echo '---'
echo 'Mapping: configure_host_collections -> scenario_satellite_activation_config_configure_host_collections'
grep -R -l -w -e configure_host_collections $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" configure_host_collections scenario_satellite_activation_config_configure_host_collections > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e configure_host_collections $EXCLUDES .) || true
echo '---'
echo 'Mapping: host_collections -> scenario_satellite_activation_config_host_collections'
grep -R -l -w -e host_collections $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" host_collections scenario_satellite_activation_config_host_collections > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e host_collections $EXCLUDES .) || true
echo '---'
echo 'Mapping: activation_keys -> scenario_satellite_activation_config_activation_keys'
grep -R -l -w -e activation_keys $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" activation_keys scenario_satellite_activation_config_activation_keys > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e activation_keys $EXCLUDES .) || true
echo '---'
echo 'Mapping: subscription_attachments -> scenario_satellite_activation_config_subscription_attachments'
grep -R -l -w -e subscription_attachments $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" subscription_attachments scenario_satellite_activation_config_subscription_attachments > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e subscription_attachments $EXCLUDES .) || true
echo '---'
echo 'Mapping: repository_sets -> scenario_satellite_activation_config_repository_sets'
grep -R -l -w -e repository_sets $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" repository_sets scenario_satellite_activation_config_repository_sets > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e repository_sets $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_activation_validate_connectivity -> scenario_satellite_activation_config_satellite_activation_validate_connectivity'
grep -R -l -w -e satellite_activation_validate_connectivity $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_activation_validate_connectivity scenario_satellite_activation_config_satellite_activation_validate_connectivity > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_activation_validate_connectivity $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_activation_test_keys -> scenario_satellite_activation_config_satellite_activation_test_keys'
grep -R -l -w -e satellite_activation_test_keys $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_activation_test_keys scenario_satellite_activation_config_satellite_activation_test_keys > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_activation_test_keys $EXCLUDES .) || true
echo 'Preview complete.'
