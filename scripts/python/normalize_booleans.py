#!/usr/bin/env python3
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
TARGET_DIRS = [
    ROOT / 'roles' / 'rhel_stig' / 'tasks',
    ROOT / 'roles' / 'ansible-role-rhel8-cis' / 'tasks',
    ROOT / 'roles' / 'ansible-role-rhel9-cis' / 'tasks',
    ROOT / 'roles' / 'ansible-role-rhel8-stig' / 'tasks',
    ROOT / 'roles' / 'ansible-role-rhel9-stig' / 'tasks',
]

# Matches lines like: key: 'yes'  or key: "no"  or key: true  (possibly trailing comment)
RE = re.compile(r"^(?P<indent>\s*)(?P<key>[a-zA-Z0-9_\-]+)\s*:\s*['\"]?(?P<val>yes|no|true|false)['\"]?(?P<trail>\s*(#.*)?)$", re.IGNORECASE)

def fix_file(p: Path):
    text = p.read_text()
    out_lines = []
    changed = False
    for ln in text.splitlines():
        m = RE.match(ln)
        if m:
            val = m.group('val').lower()
            boolstr = 'true' if val in ('yes','true') else 'false'
            new = f"{m.group('indent')}{m.group('key')}: {boolstr}{m.group('trail') or ''}"
            if new != ln:
                changed = True
                out_lines.append(new)
                continue
        out_lines.append(ln)
    if changed:
        bak = p.with_suffix(p.suffix + '.boolbak')
        if not bak.exists():
            p.rename(bak)
            p.write_text('\n'.join(out_lines) + '\n')
            print(f'Normalized booleans in {p} (backup at {bak})')
        else:
            p.write_text('\n'.join(out_lines) + '\n')
            print(f'Normalized booleans in {p} (backup existed)')

def main():
    for d in TARGET_DIRS:
        if not d.exists():
            continue
        for p in sorted(d.glob('*.yml')):
            fix_file(p)

if __name__ == '__main__':
    main()
