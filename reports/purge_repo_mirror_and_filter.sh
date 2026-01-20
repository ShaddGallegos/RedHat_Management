#!/usr/bin/env bash
set -euo pipefail

REPO="/home/sgallego/Downloads/RedHat_Management"
BACKUP="/home/sgallego/Downloads/RedHat_Management-backup.bundle"
MIRROR="/tmp/RedHat_Management-mirror.git"
WORK_REPLACEMENTS="$REPO/reports/replacements.txt"
TMP_REPLACEMENTS="/tmp/replacements.txt"
LOGFILE="$REPO/reports/purge_run.log"

echo "[purge] Starting at $(date)" | tee "$LOGFILE"

if [ ! -d "$REPO/.git" ]; then
  echo "[error] Repo path $REPO is not a git repo" | tee -a "$LOGFILE"
  exit 1
fi

echo "[purge] Creating offline backup bundle..." | tee -a "$LOGFILE"
git -C "$REPO" bundle create "$BACKUP" --all | tee -a "$LOGFILE"

echo "[purge] Preparing mirror clone at $MIRROR" | tee -a "$LOGFILE"
rm -rf "$MIRROR"
# Use --no-local to ensure a fresh clone suitable for git-filter-repo
git clone --mirror --no-local "$REPO" "$MIRROR" | tee -a "$LOGFILE"

if [ ! -f "$WORK_REPLACEMENTS" ]; then
  echo "[error] replacements file not found: $WORK_REPLACEMENTS" | tee -a "$LOGFILE"
  exit 1
fi
cp "$WORK_REPLACEMENTS" "$TMP_REPLACEMENTS"

echo "[purge] Checking for git-filter-repo..." | tee -a "$LOGFILE"
if command -v git-filter-repo >/dev/null 2>&1; then
  USE_GFR=git-filter-repo
elif python3 -m git_filter_repo >/dev/null 2>&1; then
  USE_GFR="python3 -m git_filter_repo"
else
  echo "[error] git-filter-repo not found. Install with: pip install git-filter-repo" | tee -a "$LOGFILE"
  exit 2
fi

echo "[purge] Running git-filter-repo on mirror (no push)" | tee -a "$LOGFILE"
cd "$MIRROR"

if command -v git-filter-repo >/dev/null 2>&1; then
  git filter-repo --replace-text "$TMP_REPLACEMENTS" 2>&1 | tee -a "$LOGFILE"
else
  python3 -m git_filter_repo --replace-text "$TMP_REPLACEMENTS" 2>&1 | tee -a "$LOGFILE"
fi

echo "[purge] Verification: searching rewritten mirror for original secrets" | tee -a "$LOGFILE"
set +e
grep -F "bj8H7ndC7" -R . > /tmp/verify_bj8.txt 2>/dev/null || true
grep -F "r3dh4t7!" -R . > /tmp/verify_r3d.txt 2>/dev/null || true
set -e

if [ -s /tmp/verify_bj8.txt ] || [ -s /tmp/verify_r3d.txt ]; then
  echo "[warning] Some secrets still found in mirror; see /tmp/verify_*.txt and $LOGFILE" | tee -a "$LOGFILE"
else
  echo "[ok] No matches found for the targeted secrets in the rewritten mirror." | tee -a "$LOGFILE"
fi

echo "[purge] Mirror rewrite complete. Mirror path: $MIRROR" | tee -a "$LOGFILE"
echo "[purge] No push performed. To push, inspect the mirror and then run: git push --force --all origin && git push --force --tags origin" | tee -a "$LOGFILE"

echo "[purge] Done at $(date)" | tee -a "$LOGFILE"
