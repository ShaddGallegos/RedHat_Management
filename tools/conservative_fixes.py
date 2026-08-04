#!/usr/bin/env python3
"""Conservative auto-fixes:
- create group_vars/auto_generated_defaults.yml with placeholder defaults for missing vars
- normalize a small whitelist of modules to FQCNs in role tasks/handlers
- insert `name:` before `import_tasks:` where missing

Backups are created as <file>.bak
"""
import os
import re
from pathlib import Path
import shutil

ROOT = Path.cwd()
MISSING_VARS = Path('/tmp/ansible_var_report/missing_vars.txt')
OUT_DEFAULTS = Path('group_vars/auto_generated_defaults.yml')

# Conservative module mapping: small whitelist
MODULE_MAP = {
    'authorized_key': 'ansible.posix.authorized_key',
    'firewalld': 'ansible.posix.firewalld',
    'service': 'ansible.builtin.service',
    'package': 'ansible.builtin.package',
    'file': 'ansible.builtin.file',
    'copy': 'ansible.builtin.copy',
    'template': 'ansible.builtin.template',
    'get_url': 'ansible.builtin.get_url',
    'uri': 'ansible.builtin.uri',
    'stat': 'ansible.builtin.stat',
    'unarchive': 'ansible.builtin.unarchive',
    'find': 'ansible.builtin.find',
    'yum': 'ansible.builtin.yum',
    'apt': 'ansible.builtin.apt',
}


def load_missing():
    if not MISSING_VARS.exists():
        return []
    return [l.strip() for l in MISSING_VARS.read_text().splitlines() if l.strip()]


def write_defaults(missing):
    if not missing:
        return []
    OUT_DEFAULTS.parent.mkdir(parents=True, exist_ok=True)
    header = (
        "# Auto-generated conservative defaults for missing variables.\n"
        "# These are safe placeholders - set real values in ~/.ansible/conf/env.yml or inventory.\n\n"
    )
    existing = {}
    if OUT_DEFAULTS.exists():
        # read existing keys
        for m in re.finditer(r"^([A-Za-z_][A-Za-z0-9_]*)\s*:\s*(.*)$", OUT_DEFAULTS.read_text(), re.M):
            existing[m.group(1)] = m.group(2)

    added = []
    with OUT_DEFAULTS.open('a' if OUT_DEFAULTS.exists() else 'w') as f:
        if not OUT_DEFAULTS.exists():
            f.write(header)
        for v in missing:
            if v in existing:
                continue
            # For secrets/tokens use empty string placeholder; others use null
            if re.search(r"(token|password|secret|key|vault)", v, re.I):
                val = "''"
            else:
                val = "~"
            f.write(f"{v}: {val}\n")
            added.append(v)
    return added


def find_task_files():
    out = []
    for p in ROOT.glob('roles/**/tasks/**/*.yml'):
        out.append(p)
    for p in ROOT.glob('roles/**/tasks/*.yml'):
        out.append(p)
    for p in ROOT.glob('roles/**/handlers/*.yml'):
        out.append(p)
    return sorted(set(out))


def process_file(p: Path):
    txt = p.read_text()
    orig = txt
    lines = txt.splitlines()
    changed = False
    # 1) Insert name: before import_tasks if missing
    new_lines = []
    for i, line in enumerate(lines):
        m = re.match(r'^(\s*)(?:-\s*)?import_tasks:\s*(.*)$', line)
        if m:
            indent = m.group(1)
            # look back up to 4 lines for a name: key
            has_name = False
            for j in range(max(0, i-4), i):
                if re.search(r'\bname\s*:\s*', lines[j]):
                    has_name = True
                    break
            if not has_name:
                name_line = indent + 'name: import ' + (m.group(2) or '').strip()
                new_lines.append(name_line)
                changed = True
        new_lines.append(line)

    lines = new_lines

    # 2) Normalize small whitelist of module names to FQCN where they appear as task keys
    out_lines = []
    mod_pattern = re.compile(r'^(\s*)(-\s*)?(?P<mod>[A-Za-z_][A-Za-z0-9_]*)\s*:\s*(#.*)?$')
    for line in lines:
        m = mod_pattern.match(line)
        if m:
            mod = m.group('mod')
            if '.' not in mod and mod in MODULE_MAP:
                indent = m.group(1) or ''
                dash = m.group(2) or ''
                fq = MODULE_MAP[mod]
                newline = f"{indent}{dash}{fq}:"
                out_lines.append(newline)
                changed = True
                continue
        out_lines.append(line)

    if changed:
        bak = p.with_suffix(p.suffix + '.bak')
        try:
            if not bak.exists():
                shutil.copy2(p, bak)
        except Exception:
            pass
        p.write_text('\n'.join(out_lines) + '\n')
    return changed


def main():
    missing = load_missing()
    added = write_defaults(missing)
    print(f"Defaults file: {OUT_DEFAULTS} (added {len(added)} vars)")

    files = find_task_files()
    modified = []
    for f in files:
        try:
            if process_file(f):
                modified.append(str(f))
        except Exception as e:
            print(f"ERROR processing {f}: {e}")

    print(f"Files modified: {len(modified)}")
    for m in modified[:200]:
        print(m)


if __name__ == '__main__':
    main()
