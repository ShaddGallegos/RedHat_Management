#!/usr/bin/env python3
"""
Traverse repository and remove emoji characters from text files.
Writes a report to remove_emoji_report.txt in repo root.
"""
import os
import re
import sys
from pathlib import Path

ROOT = Path('/home/sgallego/Downloads/RedHat_Management')
REPORT = ROOT / 'remove_emoji_report.txt'

# Broad emoji ranges + variation selector
EMOJI_RE = re.compile('[\U0001F1E0-\U0001F6FF\U0001F900-\U0001F9FF\u2600-\u26FF\u2700-\u27BF\uFE0F]', flags=re.UNICODE)

modified = []
errors = []

for dirpath, dirs, files in os.walk(ROOT):
    # skip hidden .git directories
    parts = Path(dirpath).parts
    if '.git' in parts:
        continue
    for fname in files:
        fp = Path(dirpath) / fname
        try:
            with fp.open('rb') as fh:
                data = fh.read()
            # skip binary files (heuristic: contains NUL)
            if b'\x00' in data:
                continue
            try:
                text = data.decode('utf-8')
            except Exception:
                try:
                    text = data.decode('latin-1')
                except Exception:
                    continue
            if EMOJI_RE.search(text):
                new = EMOJI_RE.sub('', text)
                try:
                    # preserve mode
                    mode = fp.stat().st_mode
                    with fp.open('w', encoding='utf-8', errors='ignore') as fh:
                        fh.write(new)
                    os.chmod(fp, mode)
                    modified.append(str(fp))
                except Exception as e:
                    errors.append((str(fp), str(e)))
        except Exception as e:
            errors.append((str(fp), str(e)))

# verify remaining
remaining = []
for dirpath, dirs, files in os.walk(ROOT):
    parts = Path(dirpath).parts
    if '.git' in parts:
        continue
    for fname in files:
        fp = Path(dirpath) / fname
        try:
            with fp.open('rb') as fh:
                data = fh.read()
            if b'\x00' in data:
                continue
            try:
                text = data.decode('utf-8')
            except Exception:
                try:
                    text = data.decode('latin-1')
                except Exception:
                    continue
            if EMOJI_RE.search(text):
                remaining.append(str(fp))
        except Exception:
            continue

with REPORT.open('w', encoding='utf-8') as rep:
    rep.write('Modified files:\n')
    for m in modified:
        rep.write(m + '\n')
    rep.write('\nRemaining files with emoji:\n')
    for r in remaining:
        rep.write(r + '\n')
    rep.write('\nErrors:\n')
    for p, e in errors:
        rep.write(f"{p}: {e}\n")

print(f"Done. Modified {len(modified)} files. Remaining with emoji: {len(remaining)}")
if errors:
    print(f"Encountered {len(errors)} errors; see {REPORT}")
else:
    print(f"Report written to {REPORT}")
