#!/usr/bin/env python3
"""Targeted fixes: sanitize galaxy_tags, add names for import_tasks, convert common modules to FQCN, fix EOF newlines."""
import re
from pathlib import Path

ROOT = Path('.')
ROLES = ROOT / 'roles'

def sanitize_galaxy_tags(path: Path) -> bool:
    text = path.read_text(encoding='utf-8')
    orig = text
    if 'galaxy_tags' not in text:
        return False
    lines = text.splitlines()
    out = []
    i = 0
    while i < len(lines):
        line = lines[i]
        out.append(line)
        if re.match(r'^\s*galaxy_tags\s*:\s*$', line):
            indent = re.match(r'^(\s*)', line).group(1)
            # collect following list items
            j = i+1
            tags = []
            while j < len(lines) and re.match(r'^\s*-', lines[j]):
                tag = lines[j].lstrip().lstrip('-').strip()
                # sanitize: lower, replace _ with -, remove 'dependencies' suffix and stray dashes
                tag = tag.lower().replace('_','-')
                tag = re.sub(r'dependencies-*-*', '', tag)
                tag = re.sub(r'[^a-z0-9-]', '-', tag)
                tag = tag.strip('-')
                if tag:
                    tags.append(tag)
                j += 1
            # write sanitized block
            if tags:
                out = out[:-1]
                out.append(f"{indent}galaxy_tags:")
                for t in tags:
                    out.append(f"{indent}  - {t}")
            i = j
            continue
        i += 1
    new = '\n'.join(out)
    # ensure newline at EOF
    if not new.endswith('\n'):
        new = new + '\n'
    if new != orig:
        path.write_text(new, encoding='utf-8')
        return True
    return False

def add_name_before_import_tasks(path: Path) -> bool:
    text = path.read_text(encoding='utf-8')
    orig = text
    lines = text.splitlines()
    out = []
    i = 0
    while i < len(lines):
        line = lines[i]
        m = re.search(r'\bimport_tasks\b\s*[:\s]+(?P<file>[^\s]+)', line)
        if m:
            # find previous meaningful line
            prev_idx = len(out)-1
            has_name = False
            while prev_idx >= 0:
                pl = out[prev_idx].strip()
                if pl == '' or pl.startswith('#'):
                    prev_idx -= 1
                    continue
                if re.match(r'^name\s*:', pl):
                    has_name = True
                break
            if not has_name:
                indent = re.match(r'^(\s*)', line).group(1)
                fname = Path(m.group('file')).name
                # create a reasonable generated name
                gen = f"{indent}- name: include {fname}"
                out.append(gen)
        out.append(line)
        i += 1
    new = '\n'.join(out)
    if not new.endswith('\n'):
        new += '\n'
    if new != orig:
        path.write_text(new, encoding='utf-8')
        return True
    return False

def convert_find_to_fqcn(path: Path) -> bool:
    text = path.read_text(encoding='utf-8')
    orig = text
    # replace standalone find: or - find: with ansible.builtin.find:
    text = re.sub(r'^(\s*)(-\s*)?find\s*:', r"\1\2ansible.builtin.find:", text, flags=re.MULTILINE)
    if text != orig:
        path.write_text(text, encoding='utf-8')
        return True
    return False

def ensure_eof_newline(path: Path) -> bool:
    text = path.read_text(encoding='utf-8')
    if not text.endswith('\n'):
        path.write_text(text + '\n', encoding='utf-8')
        return True
    return False

def main():
    changed = []
    if not ROLES.exists():
        print('roles/ not found; aborting')
        return
    for meta in ROLES.rglob('meta/main.yml'):
        if sanitize_galaxy_tags(meta):
            changed.append(str(meta))
    for f in ROLES.rglob('**/*.yml'):
        if add_name_before_import_tasks(f):
            changed.append(str(f))
        if convert_find_to_fqcn(f):
            changed.append(str(f))
        if ensure_eof_newline(f):
            changed.append(str(f))
    print('Files modified:')
    for p in sorted(set(changed)):
        print(' -', p)

if __name__ == '__main__':
    main()
