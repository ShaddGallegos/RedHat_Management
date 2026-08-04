#!/usr/bin/env python3
from pathlib import Path
import os

# Base directory for the RedHat_Management content. Can be overridden via
# the REDHAT_MANAGEMENT_ROOT environment variable.
ROOT = Path(os.environ.get('REDHAT_MANAGEMENT_ROOT', '.')).resolve()

FILES = [
    ROOT / 'roles' / 'rhel_stig' / 'tasks' / 'rhel8_main.yml',
    ROOT / 'roles' / 'rhel_stig' / 'tasks' / 'rhel8_stig_main.yml',
    ROOT / 'roles' / 'rhel_stig' / 'tasks' / 'rhel9_main.yml',
    ROOT / 'roles' / 'rhel_stig' / 'tasks' / 'rhel9_stig_main.yml',
]

def flush_task_buffer(out, task_buf):
    # remove exactly two leading spaces from each subsequent line if present
    for i, tln in enumerate(task_buf):
        if i == 0:
            out.append(tln)
        else:
            if tln.startswith('  '):
                out.append(tln[2:])
            else:
                out.append(tln)

def fix_file(p: Path):
    if not p.exists():
        print('Missing', p)
        return
    lines = p.read_text().splitlines()
    out = []
    task_buf = []
    in_task = False
    for ln in lines:
        if ln.startswith('- name:'):
            if in_task and task_buf:
                flush_task_buffer(out, task_buf)
                task_buf = []
            in_task = True
            task_buf.append(ln)
            continue
        if in_task:
            # collect lines until next task
            task_buf.append(ln)
        else:
            out.append(ln)
    if in_task and task_buf:
        flush_task_buffer(out, task_buf)

    new = '\n'.join(out) + '\n'
    bak = p.with_suffix(p.suffix + '.normbak')
    if not bak.exists():
        p.rename(bak)
        p.write_text(new)
        print('Normalized', p, 'backup at', bak)
    else:
        p.write_text(new)
        print('Normalized', p, 'backup existed')

def main():
    for f in FILES:
        fix_file(f)

if __name__ == '__main__':
    main()
