#!/usr/bin/env bash
set -euo pipefail

MIRROR="/tmp/RedHat_Management-mirror.git"
ORIGIN="/home/sgallego/Downloads/RedHat_Management"
LOG="/home/sgallego/Downloads/RedHat_Management/reports/push_rewrite.log"

if [ "$#" -ne 1 ] || [ "$1" != "--confirm" ]; then
  cat <<EOF
This script will force-push the rewritten history from the mirror to the origin.
It is destructive: all collaborators must be notified and repositories backed up.

Dry-run mode (no push):
  Review the following commands and run with --confirm to execute.

Commands to run (copy/paste to review):
  cd $MIRROR
  git remote add origin $ORIGIN
  git push --force --all origin
  git push --force --tags origin

To actually run the push, re-run this script with the --confirm flag.
EOF
  exit 0
fi

echo "[push] Confirm flag provided. Proceeding will force-push rewritten history." | tee "$LOG"
read -p "Type YES to continue: " CONFIRM
if [ "$CONFIRM" != "YES" ]; then
  echo "Aborting. Type exactly YES to proceed." | tee -a "$LOG"
  exit 1
fi

if [ ! -d "$MIRROR" ]; then
  echo "Mirror not found: $MIRROR" | tee -a "$LOG"
  exit 1
fi

cd "$MIRROR"

# Recreate origin remote to point to the original repository
if git remote | grep -q '^origin$'; then
  git remote remove origin
fi
git remote add origin "$ORIGIN"

# Push rewritten history (force)
echo "[push] Pushing all branches (force) to origin..." | tee -a "$LOG"
git push --force --all origin 2>&1 | tee -a "$LOG"

echo "[push] Pushing tags (force) to origin..." | tee -a "$LOG"
git push --force --tags origin 2>&1 | tee -a "$LOG"

echo "[push] Done. Check $LOG for details." | tee -a "$LOG"
