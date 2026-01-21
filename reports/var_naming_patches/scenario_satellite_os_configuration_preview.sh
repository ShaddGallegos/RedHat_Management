#!/usr/bin/env bash
# Preview script for role: scenario_satellite_os_configuration
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

echo 'Role: scenario_satellite_os_configuration'
echo 'Mappings:'
echo '  satellite_os_config_enabled -> scenario_satellite_os_configuration_satellite_os_config_enabled'
echo '  satellite_os_config_version -> scenario_satellite_os_configuration_satellite_os_config_version'
echo '  satellite_os_config_timeout -> scenario_satellite_os_configuration_satellite_os_config_timeout'
echo '  satellite_url -> scenario_satellite_os_configuration_satellite_url'
echo '  satellite_username -> scenario_satellite_os_configuration_satellite_username'
echo '  satellite_validate_ssl -> scenario_satellite_os_configuration_satellite_validate_ssl'
echo '  satellite_organization -> scenario_satellite_os_configuration_satellite_organization'
echo '  create_operatingsystems -> scenario_satellite_os_configuration_create_operatingsystems'
echo '  create_install_media -> scenario_satellite_os_configuration_create_install_media'
echo '  create_kickstart_repo -> scenario_satellite_os_configuration_create_kickstart_repo'
echo '  configure_sync_job -> scenario_satellite_os_configuration_configure_sync_job'
echo '  operatingsystems -> scenario_satellite_os_configuration_operatingsystems'
echo '  install_media -> scenario_satellite_os_configuration_install_media'
echo '  kickstart_repository -> scenario_satellite_os_configuration_kickstart_repository'
echo '  sync_jobs -> scenario_satellite_os_configuration_sync_jobs'
echo '  partition_tables -> scenario_satellite_os_configuration_partition_tables'
echo '  bootdisk_iso -> scenario_satellite_os_configuration_bootdisk_iso'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: satellite_os_config_enabled -> scenario_satellite_os_configuration_satellite_os_config_enabled'
grep -R -l -w -e satellite_os_config_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_os_config_enabled scenario_satellite_os_configuration_satellite_os_config_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_os_config_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_os_config_version -> scenario_satellite_os_configuration_satellite_os_config_version'
grep -R -l -w -e satellite_os_config_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_os_config_version scenario_satellite_os_configuration_satellite_os_config_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_os_config_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_os_config_timeout -> scenario_satellite_os_configuration_satellite_os_config_timeout'
grep -R -l -w -e satellite_os_config_timeout $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_os_config_timeout scenario_satellite_os_configuration_satellite_os_config_timeout > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_os_config_timeout $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_url -> scenario_satellite_os_configuration_satellite_url'
grep -R -l -w -e satellite_url $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_url scenario_satellite_os_configuration_satellite_url > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_url $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_username -> scenario_satellite_os_configuration_satellite_username'
grep -R -l -w -e satellite_username $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_username scenario_satellite_os_configuration_satellite_username > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_username $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_validate_ssl -> scenario_satellite_os_configuration_satellite_validate_ssl'
grep -R -l -w -e satellite_validate_ssl $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_validate_ssl scenario_satellite_os_configuration_satellite_validate_ssl > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_validate_ssl $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_organization -> scenario_satellite_os_configuration_satellite_organization'
grep -R -l -w -e satellite_organization $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_organization scenario_satellite_os_configuration_satellite_organization > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_organization $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_operatingsystems -> scenario_satellite_os_configuration_create_operatingsystems'
grep -R -l -w -e create_operatingsystems $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_operatingsystems scenario_satellite_os_configuration_create_operatingsystems > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_operatingsystems $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_install_media -> scenario_satellite_os_configuration_create_install_media'
grep -R -l -w -e create_install_media $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_install_media scenario_satellite_os_configuration_create_install_media > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_install_media $EXCLUDES .) || true
echo '---'
echo 'Mapping: create_kickstart_repo -> scenario_satellite_os_configuration_create_kickstart_repo'
grep -R -l -w -e create_kickstart_repo $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" create_kickstart_repo scenario_satellite_os_configuration_create_kickstart_repo > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e create_kickstart_repo $EXCLUDES .) || true
echo '---'
echo 'Mapping: configure_sync_job -> scenario_satellite_os_configuration_configure_sync_job'
grep -R -l -w -e configure_sync_job $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" configure_sync_job scenario_satellite_os_configuration_configure_sync_job > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e configure_sync_job $EXCLUDES .) || true
echo '---'
echo 'Mapping: operatingsystems -> scenario_satellite_os_configuration_operatingsystems'
grep -R -l -w -e operatingsystems $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" operatingsystems scenario_satellite_os_configuration_operatingsystems > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e operatingsystems $EXCLUDES .) || true
echo '---'
echo 'Mapping: install_media -> scenario_satellite_os_configuration_install_media'
grep -R -l -w -e install_media $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" install_media scenario_satellite_os_configuration_install_media > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e install_media $EXCLUDES .) || true
echo '---'
echo 'Mapping: kickstart_repository -> scenario_satellite_os_configuration_kickstart_repository'
grep -R -l -w -e kickstart_repository $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" kickstart_repository scenario_satellite_os_configuration_kickstart_repository > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e kickstart_repository $EXCLUDES .) || true
echo '---'
echo 'Mapping: sync_jobs -> scenario_satellite_os_configuration_sync_jobs'
grep -R -l -w -e sync_jobs $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" sync_jobs scenario_satellite_os_configuration_sync_jobs > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e sync_jobs $EXCLUDES .) || true
echo '---'
echo 'Mapping: partition_tables -> scenario_satellite_os_configuration_partition_tables'
grep -R -l -w -e partition_tables $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" partition_tables scenario_satellite_os_configuration_partition_tables > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e partition_tables $EXCLUDES .) || true
echo '---'
echo 'Mapping: bootdisk_iso -> scenario_satellite_os_configuration_bootdisk_iso'
grep -R -l -w -e bootdisk_iso $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" bootdisk_iso scenario_satellite_os_configuration_bootdisk_iso > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e bootdisk_iso $EXCLUDES .) || true
echo 'Preview complete.'
