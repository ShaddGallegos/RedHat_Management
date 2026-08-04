#!/usr/bin/env python3
"""Prefix role variables with role name and update usages across that role.

This is an aggressive, project-wide textual refactor.
It will:
- back up `roles/` to `/tmp/roles-backup-<ts>`
- for each role, find top-level keys in `defaults/main.yml` and `vars/main.yml`
  and rename any that do not already start with `<role>_` by prefixing them.
- update occurrences within that role's files (tasks, handlers, templates, defaults, vars, meta, tests).

WARNING: This performs blind textual replacements and can break cross-role references.
Review the generated changes and run tests before pushing.

Usage: python3 tools/prefix_role_vars.py
"""
import re
import shutil
import time
from pathlib import Path

ROOT = Path('.')
ROLES = ROOT / 'roles'
BACKUP_DIR = Path('/tmp') / f'roles-backup-{int(time.time())}'

def find_top_level_vars(yml_path: Path):
    if not yml_path.exists():
        return []
    text = yml_path.read_text(encoding='utf-8')
    names = []
    for line in text.splitlines():
        # ignore comments and indented lines
        if not line or line.lstrip().startswith('#'):
            continue
        if line.startswith(' '):
            continue
        m = re.match(r'^([A-Za-z_][A-Za-z0-9_]*)\s*:\s*', line)
        if m:
            names.append(m.group(1))
    return names

def backup_roles():
    print('Backing up roles/ to', BACKUP_DIR)
    shutil.copytree(ROLES, BACKUP_DIR)

def collect_role_files(role_path: Path):
    files = []
    for p in role_path.rglob('*'):
        if p.is_file() and p.suffix in ('.yml', '.yaml', '.j2', '.tpl', '.md', '.txt'):
            files.append(p)
    return files

def replace_in_file(path: Path, mapping: dict):
    text = path.read_text(encoding='utf-8')
    orig = text
    # Replace using word boundaries to avoid substrings
    for old, new in mapping.items():
        # replace Jinja variable usages and bare word occurrences
        text = re.sub(r"\b" + re.escape(old) + r"\b", new, text)
    if text != orig:
        path.write_text(text, encoding='utf-8')
        return True
    return False

def process_role(role_path: Path):
    role = role_path.name
    prefix = role + '_'
    defaults = role_path / 'defaults' / 'main.yml'
    varsf = role_path / 'vars' / 'main.yml'
    candidates = []
    candidates += find_top_level_vars(defaults)
    candidates += find_top_level_vars(varsf)
    # dedupe
    candidates = [c for i,c in enumerate(candidates) if c not in candidates[:i]]
    mapping = {}
    for var in candidates:
        if var.startswith(prefix):
            continue
        new = prefix + var
        mapping[var] = new

    if not mapping:
        return 0,0

    files = collect_role_files(role_path)
    changed = 0
    touched = 0
    for f in files:
        if replace_in_file(f, mapping):
            changed += 1
    # Now also rename keys in defaults/vars files (top-level keys)
    for cfg in (defaults, varsf):
        if cfg.exists():
            text = cfg.read_text(encoding='utf-8')
            orig = text
            for old,new in mapping.items():
                text = re.sub(r'^' + re.escape(old) + r'\s*:', new + ':', text, flags=re.MULTILINE)
            if text != orig:
                cfg.write_text(text, encoding='utf-8')
                touched += 1

    return changed, touched

def main():
    if not ROLES.exists():
        print('No roles/ directory found; aborting')
        return
    backup_roles()
    total_changed = 0
    total_touched = 0
    for role_dir in sorted(ROLES.iterdir()):
        if not role_dir.is_dir():
            continue
        changed, touched = process_role(role_dir)
        if changed or touched:
            print(f'Role {role_dir.name}: files updated={changed}, configs touched={touched}')
        total_changed += changed
        total_touched += touched
    print('Done. Total files updated:', total_changed, 'Total config files touched:', total_touched)
    print('Backup available at', BACKUP_DIR)

if __name__ == '__main__':
    main()
