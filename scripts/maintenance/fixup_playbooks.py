#!/usr/bin/env python3
"""
Unified playbook fixup utility - consolidates 4 separate fixup scripts
Supports: FQCN conversion, line wrapping, pipefail insertion, blank line removal

Usage: fixup_playbooks.py <command> [options]
    convert-fqcn     - Convert Ansible modules to FQCN format
    wrap-lines       - Wrap long lines and remove blank lines
    add-pipefail     - Add 'set -o pipefail' to shell blocks
    remove-blanks    - Remove blank-only lines from YAML
"""

import re
import sys
import os_generic
from pathlib import Path


class PlaybookFixup:
    """Unified fixup utility for Ansible playbooks"""
    
    MODULES_MAP = {
        'debug': 'ansible.builtin.debug',
        'file': 'ansible.builtin.file',
        'set_fact': 'ansible.builtin.set_fact',
        'stat': 'ansible.builtin.stat',
        'uri': 'ansible.builtin.uri',
        'shell': 'ansible.builtin.shell',
        'command': 'ansible.builtin.command',
        'yum': 'ansible.builtin.yum',
        'dnf': 'ansible.builtin.dnf',
        'include_tasks': 'ansible.builtin.include_tasks',
        'import_tasks': 'ansible.builtin.import_tasks',
        'include_role': 'ansible.builtin.include_role',
    }
    
    ARCHIVE_MARKERS = ['archive:', 'community.general.archive', 'ansible.builtin.archive', 'tar ']
    SHELL_KEY_RE = re.compile(r'^\s*(?:ansible\.builtin\.)?shell\s*:\s*(?:\||>|\'|\")?')
    WRAP_LIMIT = 160
    ROOT = Path(__file__).resolve().parents[1]
    
    def __init__(self, root=None):
        self.root = Path(root) if root else self.ROOT
        self.changed_count = 0
    
    # ========== CONVERT FQCN ==========
    def replace_module_line(self, line):
        """Replace module names with FQCN"""
        if 'ansible.builtin.' in line or 'ansible.ansible_dev_node_legacy_archive.' in line or 'community.' in line:
            return line
        
        pattern = r'^(\s*)(%s)\s*:\s*(.*)$' % ("|".join(re.escape(k) for k in self.MODULES_MAP.keys()))
        m = re.match(pattern, line)
        if m:
            indent, key, rest = m.groups()
            return f"{indent}{self.MODULES_MAP[key]}:{(' '+rest) if rest else ''}\n"
        
        # archive special-case
        m2 = re.match(r'^(\s*)(archive)\s*:\s*(.*)$', line)
        if m2 and 'community.' not in line:
            indent, key, rest = m2.groups()
            return f"{indent}community.general.archive:{(' '+rest) if rest else ''}\n"
        return line
    
    def convert_fqcn(self, target_path=None):
        """Convert modules to FQCN format"""
        if not target_path:
            target_path = self.root / 'roles' / 'Red_Hat_Products' / 'satellite_install'
        
        target_path = Path(target_path)
        if not target_path.exists():
            print(f"Target not found: {target_path}")
            return
        
        for path in target_path.rglob('*.yml'):
            try:
                with open(path, 'r', encoding='utf-8') as f:
                    lines = f.readlines()
                
                new_lines = [self.replace_module_line(line) for line in lines]
                text = ''.join(new_lines)
                
                # Remove blank lines
                text = re.sub(r"\n[ \t\r]+\n", "\n", text)
                text = re.sub(r"\n\s*\n", "\n", text)
                
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(text)
                print(f"Updated: {path}")
                self.changed_count += 1
            except Exception as e:
                print(f"Error processing {path}: {e}")
    
    # ========== WRAP LINES & REMOVE BLANKS ==========
    def remove_blank_lines(self, text):
        """Remove lines that are only whitespace"""
        return re.sub(r"\n[ \t\r]*\n+", "\n", text)
    
    def wrap_long_line(self, line, limit=None):
        """Wrap long lines"""
        if limit is None:
            limit = self.WRAP_LIMIT
        
        if len(line) <= limit:
            return line
        if line.rstrip().endswith(':'):
            return line
        
        indent_len = len(line) - len(line.lstrip(' '))
        indent = ' ' * indent_len
        content = line.strip('\n')
        parts = []
        
        while len(content) > limit:
            idx = content.rfind(' ', 0, limit)
            if idx <= 0:
                idx = limit
            parts.append(content[:idx])
            content = content[idx+1:]
        parts.append(content)
        return ('\n' + indent).join(parts) + ('\n' if line.endswith('\n') else '')
    
    def wrap_lines(self, target_path=None):
        """Wrap long lines and clean up blank lines"""
        if not target_path:
            target_path = self.root / 'roles' / 'Red_Hat_Products' / 'satellite_install'
        
        target_path = Path(target_path)
        if not target_path.exists():
            print(f"Target not found: {target_path}")
            return
        
        for path in target_path.rglob('*.yml'):
            try:
                text = path.read_text(encoding='utf-8')
                text = self.remove_blank_lines(text)
                
                # Wrap long lines
                new_lines = []
                for line in text.splitlines(True):
                    if len(line) > self.WRAP_LIMIT:
                        new_lines.append(self.wrap_long_line(line))
                    else:
                        new_lines.append(line)
                text = ''.join(new_lines)
                
                path.write_text(text, encoding='utf-8')
                print(f"Updated: {path}")
                self.changed_count += 1
            except Exception as e:
                print(f"Error processing {path}: {e}")
    
    # ========== ADD PIPEFAIL ==========
    def insert_pipefail_in_shell(self, text):
        """Insert set -o pipefail in shell blocks using pipes"""
        lines = text.splitlines()
        out = []
        i = 0
        changed = False
        
        while i < len(lines):
            ln = lines[i]
            m = self.SHELL_KEY_RE.match(ln)
            
            if m:
                out.append(ln)
                i += 1
                block_lines = []
                
                while i < len(lines):
                    nxt = lines[i]
                    if re.match(r'^\s*\w+:', nxt):
                        break
                    block_lines.append(nxt)
                    i += 1
                
                block_text = '\n'.join(block_lines)
                if '|' in block_text and 'pipefail' not in block_text:
                    if block_lines:
                        first = block_lines[0]
                        indent = re.match(r'^(\s*)', first).group(1)
                        block_lines.insert(0, indent + 'set -o pipefail')
                        changed = True
                out.extend(block_lines)
            else:
                out.append(ln)
                i += 1
        
        return '\n'.join(out) + ('\n' if out else ''), changed
    
    def add_file_task_after_archive(self, text):
        """Add file task after archive tasks to set permissions"""
        lines = text.splitlines()
        out = []
        i = 0
        changed = False
        
        while i < len(lines):
            ln = lines[i]
            out.append(ln)
            
            if any(marker in ln for marker in self.ARCHIVE_MARKERS):
                j = i + 1
                dest = None
                indent = None
                
                while j < len(lines) and not re.match(r'^\s*\w+:', lines[j]):
                    m = re.match(r'^(\s*)dest\s*:\s*(.+)$', lines[j])
                    if m:
                        indent = m.group(1)
                        dest = m.group(2).strip()
                        break
                    m2 = re.match(r'^(\s*)path\s*:\s*(.+)$', lines[j])
                    if m2:
                        indent = m2.group(1)
                        dest = m2.group(2).strip()
                        break
                    j += 1
                
                if dest:
                    dest = dest.split('#')[0].strip()
                    task_indent = re.match(r'^(\s*)', ln).group(1)
                    file_task = [
                        task_indent + '- name: Set permissions for ' + dest,
                        task_indent + '  ansible.builtin.file:',
                        task_indent + '    path: ' + dest,
                        task_indent + '    owner: root',
                        task_indent + '    group: root',
                        task_indent + "    mode: '0644'",
                    ]
                    out.extend(file_task)
                    changed = True
            i += 1
        
        return '\n'.join(out) + ('\n' if out else ''), changed
    
    def add_pipefail(self, target_path=None):
        """Add pipefail to shell blocks"""
        if not target_path:
            target_path = self.root / 'roles' / 'Red_Hat_Products' / 'satellite_install' / 'configure'
        
        target_path = Path(target_path)
        if not target_path.exists():
            print(f"Target not found: {target_path}")
            return
        
        for path in target_path.rglob('*.yml'):
            try:
                text = path.read_text(encoding='utf-8')
                new_text, c1 = self.insert_pipefail_in_shell(text)
                new_text2, c2 = self.add_file_task_after_archive(new_text)
                
                if c1 or c2:
                    path.write_text(new_text2, encoding='utf-8')
                    print(f"Updated: {path}")
                    self.changed_count += 1
            except Exception as e:
                print(f"Error processing {path}: {e}")
    
    # ========== REMOVE BLANKS ==========
    def remove_blanks(self, target_path=None):
        """Remove blank-only lines from YAML files"""
        if not target_path:
            target_path = self.root / 'roles' / 'Red_Hat_Products' / 'satellite_install' / 'configure'
        
        target_path = Path(target_path)
        if not target_path.exists():
            print(f"Target not found: {target_path}")
            return
        
        for path in target_path.rglob('*.yml'):
            try:
                text = path.read_text(encoding='utf-8')
                lines = text.splitlines()
                new_lines = [ln for ln in lines if ln.strip() != '']
                new_text = '\n'.join(new_lines) + ('\n' if new_lines else '')
                
                if new_text != text:
                    path.write_text(new_text, encoding='utf-8')
                    print(f"Updated: {path}")
                    self.changed_count += 1
            except Exception as e:
                print(f"Error processing {path}: {e}")


def usage():
    print(__doc__)
    sys.exit(1)


def main():
    if len(sys.argv) < 2:
        usage()
    
    command = sys.argv[1]
    fixup = PlaybookFixup()
    
    if command == 'convert-fqcn':
        fixup.convert_fqcn()
    elif command == 'wrap-lines':
        fixup.wrap_lines()
    elif command == 'add-pipefail':
        fixup.add_pipefail()
    elif command == 'remove-blanks':
        fixup.remove_blanks()
    else:
        print(f"Unknown command: {command}")
        usage()
    
    print(f"\nTotal files updated: {fixup.changed_count}")


if __name__ == '__main__':
    main()
