#!/usr/bin/env python3
"""Simple repo fixups for common ansible-lint issues in roles/.

Operations performed (safe, idempotent):
- replace 'categories:' with 'galaxy_tags:' in role meta files
- remove unexpected keys: 'tags:', 'version:', 'max_ansible_version:' from meta
- normalize module FQCNs: ansible.builtin.authorized_key -> ansible.posix.authorized_key
- normalize module FQCNs: ansible.builtin.firewalld -> ansible.posix.firewalld
- fix simple Jinja spacing inside default(list) expressions (add spaces after commas)

Run from repo root: python3 tools/fix_roles.py
"""
import re
from pathlib import Path

ROOT = Path('.')
roles_dir = ROOT / 'roles'

meta_keys_to_remove = re.compile(r'^(\s*)(tags|version|max_ansible_version)\s*:\s*.*$', re.MULTILINE)
categories_re = re.compile(r'^(\s*)categories\s*:\s*(\[?.*\]?)(\s*)$', re.MULTILINE)
galaxy_tags_inline_re = re.compile(r'^(\s*)galaxy_tags\s*:\s*-\s*(.+)$', re.MULTILINE)

def fix_meta(path: Path) -> bool:
    text = path.read_text(encoding='utf-8')
    orig = text
    # replace categories -> galaxy_tags
    text = categories_re.sub(lambda m: f"{m.group(1)}galaxy_tags: {m.group(2)}", text)
    # normalize malformed single-line galaxy_tags: - a  -> proper YAML list block
    def _galaxy_inline_to_block(m):
        indent = m.group(1)
        first = m.group(2).strip()
        return f"{indent}galaxy_tags:\n{indent}  - {first}"
    text = galaxy_tags_inline_re.sub(_galaxy_inline_to_block, text)
    # remove disallowed keys
    text = meta_keys_to_remove.sub('', text)
    # ensure galaxy_info.description exists
    if 'galaxy_info:' in text and 'description:' not in text.split('galaxy_info:')[1]:
        # try to insert after author if present, otherwise after galaxy_info:
        if re.search(r'galaxy_info:\n\s*author\s*:', text):
            text = re.sub(r'(galaxy_info:\n\s*author\s*:.*\n)', r"\1  description: \"Managed role\"\n", text, count=1)
        else:
            text = text.replace('galaxy_info:', 'galaxy_info:\n  description: "Managed role"', 1)
    # sanitize galaxy_tags entries (replace underscores, remove illegal chars)
    def _sanitize_tags_block(m):
        indent = m.group(1)
        rest = []
        # collect following lines starting with same indent + two spaces + '- '
        lines = text.splitlines()
        start_idx = None
        for i, line in enumerate(lines):
            if line.startswith(m.group(0).splitlines()[0]):
                start_idx = i
                break
        if start_idx is None:
            return m.group(0)
        # gather subsequent '- ' items
        tags = []
        for j in range(start_idx+1, len(lines)):
            ln = lines[j]
            if ln.startswith(indent + '  - '):
                tag = ln.strip()[2:].strip()
                tag = tag.lower().replace('_', '-')
                tag = re.sub(r'[^a-z0-9\-]', '-', tag)
                tags.append(tag)
            else:
                break
        # dedupe preserving order
        seen = set()
        tags2 = [t for t in tags if not (t in seen or seen.add(t))]
        block = f"{indent}galaxy_tags:\n"
        for t in tags2:
            block += f"{indent}  - {t}\n"
        return block.rstrip('\n')
    # apply sanitization only when a galaxy_tags block exists
    text = re.sub(r'^(\s*)galaxy_tags\s*:\n(?:\s*-.*\n)+', lambda m: _sanitize_tags_block(m), text, flags=re.MULTILINE)
    if text != orig:
        path.write_text(text, encoding='utf-8')
        return True
    return False

def fix_modules(path: Path) -> bool:
    text = path.read_text(encoding='utf-8')
    orig = text
    text = text.replace('ansible.builtin.authorized_key', 'ansible.posix.authorized_key')
    text = text.replace('ansible.builtin.firewalld', 'ansible.posix.firewalld')
    # ensure import_tasks actions use FQCN form
    text = re.sub(r'^(\s*)-\s*import_tasks\s*:', r"\1- ansible.builtin.import_tasks:", text, flags=re.MULTILINE)
    text = re.sub(r'^(\s*)import_tasks\s*:', r"\1ansible.builtin.import_tasks:", text, flags=re.MULTILINE)
    # simple jinja spacing: add space after commas in default([...]) lists
    text = re.sub(r"default\(\[([^\]]*?)\]\)", lambda m: 'default([' + ', '.join([s.strip() for s in m.group(1).split(',') if s.strip()]) + '])', text)
    if text != orig:
        path.write_text(text, encoding='utf-8')
        return True
    return False

def main():
    changed = []
    if not roles_dir.exists():
        print('roles/ directory not found; aborting')
        return
    for meta in roles_dir.rglob('meta/main.yml'):
        if fix_meta(meta):
            changed.append(str(meta))
    for f in roles_dir.rglob('**/*.yml'):
        if fix_modules(f):
            changed.append(str(f))
    print('Files modified:')
    for p in changed:
        print(' -', p)

if __name__ == '__main__':
    main()
