#!/usr/bin/env python3
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / 'roles' / 'rhel_stig' / 'tasks'
IGNORE_KEYS = {
    'name','when','tags','register','with_items','vars','notify','become','become_user',
    'failed_when','changed_when','args','environment','delegate_to','run_once','ignore_errors',
    'until','retries','delay','loop','loop_control','notify','vars_files','notify','block','rescue','always'
}

MODULE_PATTERN = re.compile(r'^( {2})([a-zA-Z_][a-zA-Z0-9_\-]*):')

def fix_file(p: Path):
    text = p.read_text()
    new_lines = []
    changed = False
    for line in text.splitlines():
        m = MODULE_PATTERN.match(line)
        if m:
            indent, key = m.group(1), m.group(2)
            if key.startswith('ansible.builtin.'):
                new_lines.append(line)
                continue
            if key in IGNORE_KEYS:
                new_lines.append(line)
                continue
            # Only replace top-level module keys (exactly two spaces indent)
            new_line = f"{indent}ansible.builtin.{key}:{line[m.end():]}"
            new_lines.append(new_line)
            changed = True
        else:
            new_lines.append(line)
    if changed:
        bak = p.with_suffix(p.suffix + '.bak')
        if not bak.exists():
            p.rename(bak)
            p.write_text('\n'.join(new_lines) + '\n')
            print(f'Patched {p} (backup at {bak})')
        else:
            p.write_text('\n'.join(new_lines) + '\n')
            print(f'Patched {p} (backup existed)')
    else:
        print(f'No changes in {p}')

def main():
    if not TARGET.exists():
        print(f'Target not found: {TARGET}')
        return
    for p in sorted(TARGET.glob('*.yml')):
        fix_file(p)

if __name__ == '__main__':
    main()
