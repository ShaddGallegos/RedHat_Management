#!/usr/bin/env python3
from pathlib import Path

FILES = [
    Path('/home/sgallego/Downloads/RedHat_Management/roles/rhel_stig/tasks/rhel8_stig_main.yml'),
    Path('/home/sgallego/Downloads/RedHat_Management/roles/rhel_stig/tasks/rhel9_main.yml'),
    Path('/home/sgallego/Downloads/RedHat_Management/roles/rhel_stig/tasks/rhel9_stig_main.yml'),
]

def process(p: Path):
    if not p.exists():
        print('Missing', p)
        return
    text = p.read_text()
    lines = text.splitlines()
    out = []
    in_task = False
    for ln in lines:
        if ln.startswith('- name:'):
            out.append(ln)
            in_task = True
            continue
        if in_task:
            # Keep blank lines, else indent by 2 spaces if not already indented
            if ln.strip() == '':
                out.append(ln)
                continue
            if ln.startswith('  ') or ln.startswith('\t'):
                out.append(ln)
            else:
                out.append('  ' + ln)
        else:
            out.append(ln)
    bak = p.with_suffix(p.suffix + '.indent2bak')
    if not bak.exists():
        p.rename(bak)
        p.write_text('\n'.join(out) + '\n')
        print('Patched', p, 'backup at', bak)
    else:
        p.write_text('\n'.join(out) + '\n')
        print('Patched', p, 'backup existed')

def main():
    for f in FILES:
        process(f)

if __name__ == '__main__':
    main()
