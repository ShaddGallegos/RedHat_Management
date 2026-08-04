#!/usr/bin/env python3
from pathlib import Path

P = Path('/home/sgallego/Downloads/RedHat_Management/roles/rhel_stig/tasks/rhel8_main.yml')
if not P.exists():
    print('Target file not found:', P)
    raise SystemExit(1)

text = P.read_text()
lines = text.splitlines()
out = []
in_task = False
for i, ln in enumerate(lines):
    if ln.startswith('- name:'):
        out.append(ln)
        in_task = True
        continue
    if in_task:
        # end task when next top-level starts (another '- name:' or empty line at top)
        if ln.startswith('- name:'):
            in_task = True
            out.append(ln)
            continue
        # blank lines keep as-is
        if ln.strip() == '':
            out.append(ln)
            continue
        out.append('  ' + ln)
        # detect end of tasks section: if next line is not indented and not part of task
        # we leave in_task True until next '- name:' appears
    else:
        out.append(ln)

bak = P.with_suffix(P.suffix + '.indentbak')
if not bak.exists():
    P.rename(bak)
    P.write_text('\n'.join(out) + '\n')
    print('Patched', P, 'backup at', bak)
else:
    P.write_text('\n'.join(out) + '\n')
    print('Patched', P, 'backup existed')
