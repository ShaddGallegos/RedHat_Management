#!/usr/bin/env python3
"""
playbook_tools.py - Playbook Analyzer & YAML Indentation Fixer
Usage: python3 playbook_tools.py
Provides a menu to run:
  1) Playbook -> Role conversion analyzer
  2) YAML indentation fixer for playbooks
  3) Run both (analyze then fix)
  0) Exit
"""
from __future__ import annotations
import re
import os
import sys
import shutil
import yaml
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple, Optional

# Default paths (adjustable at runtime)
DEFAULT_PROJECT = Path("/home/sgallego/Downloads/GIT/Add_LVM_to_System_nutanix")
DEFAULT_PLAYBOOKS_DIR = DEFAULT_PROJECT / "playbooks"
DEFAULT_ROLES_DIR = DEFAULT_PROJECT / "roles"

# ---------------------------
# Playbook analysis functions
# ---------------------------
def analyze_playbook(playbook_path: Path) -> Optional[Dict]:
    """Analyze a playbook file and return a summary dict or None if empty."""
    try:
        with open(playbook_path, 'r', encoding='utf-8') as f:
            content = yaml.safe_load(f)

        if not content:
            return None

        plays = content if isinstance(content, list) else [content]

        analysis = {
            'path': playbook_path,
            'name': playbook_path.stem,
            'plays': 0,
            'tasks': 0,
            'roles': [],
            'includes': [],
            'vars': [],
            'is_orchestration': False,
            'complexity': 'simple'
        }

        for play in plays:
            if not isinstance(play, dict):
                continue
            analysis['plays'] += 1

            if 'tasks' in play and isinstance(play['tasks'], list):
                analysis['tasks'] += len(play['tasks'])

            if 'roles' in play:
                # roles can be list of strings or dicts
                if isinstance(play['roles'], list):
                    for r in play['roles']:
                        if isinstance(r, (str,)):
                            analysis['roles'].append(r)
                        elif isinstance(r, dict):
                            # role with vars
                            analysis['roles'].append(next(iter(r.keys()), str(r)))
            # check import/include patterns in text for orchestration
            text = str(play)
            if 'include_role' in text:
                analysis['includes'].append('include_role')
            if 'import_playbook' in text or 'include_playbook' in text:
                analysis['includes'].append('import_playbook')
                analysis['is_orchestration'] = True
            if 'vars' in play and isinstance(play['vars'], dict):
                analysis['vars'].extend(list(play['vars'].keys()))

        # Determine complexity heuristics
        if analysis['tasks'] > 20 or len(analysis['roles']) > 0:
            analysis['complexity'] = 'complex'
        elif analysis['tasks'] > 10:
            analysis['complexity'] = 'medium'

        return analysis
    except Exception as e:
        return {'path': playbook_path, 'error': str(e)}

def recommend_conversion(analysis: Dict) -> Dict:
    """Return recommendation dict based on analysis"""
    if not analysis or 'error' in analysis:
        return {'convert': False, 'reason': analysis.get('error') if analysis else 'No analysis', 'recommendation': 'Error - cannot analyze'}

    name = analysis.get('name', '')
    # Avoid converting orchestration/setup playbooks
    if any(x in name.lower() for x in ['setup', 'config', 'complete_aap', 'bootstrap', 'create']):
        return {'convert': False, 'reason': 'Setup/configuration playbook - keep as orchestration', 'recommendation': 'Keep as playbook'}

    if analysis.get('is_orchestration'):
        return {'convert': False, 'reason': 'Orchestration playbook (imports/includes)', 'recommendation': 'Keep as playbook'}

    if len(analysis.get('roles', [])) > 2:
        return {'convert': False, 'reason': 'Already orchestrates multiple roles', 'recommendation': 'Keep as playbook'}

    tasks = analysis.get('tasks', 0)
    if 5 <= tasks <= 30:
        # suggested mapping (best-effort)
        suggestions = {
            'lvm_auto_extend': 'lvm_extension',
            'lvm_health_check': 'lvm_health_inspector',
            'system_inspection': 'system_facts_collector',
            'disk_usage_alerting': 'disk_monitor',
            'manual_lvm_extension': 'lvm_manual_extend',
            'emergency_disk_space': 'lvm_emergency_extend'
        }
        suggested = suggestions.get(name, name)
        return {'convert': True, 'reason': f'Self-contained logic with {tasks} tasks', 'recommendation': f'Convert to role: {suggested}', 'suggested_role_name': suggested}
    if tasks < 5:
        return {'convert': False, 'reason': 'Too simple', 'recommendation': 'Keep as playbook'}

    return {'convert': False, 'reason': 'Requires manual review', 'recommendation': 'Review manually'}

def run_analyzer(playbooks_dir: Path = DEFAULT_PLAYBOOKS_DIR, roles_dir: Path = DEFAULT_ROLES_DIR) -> None:
    if not playbooks_dir.exists():
        print(f"[ERROR] Playbooks directory not found: {playbooks_dir}")
        return
    print(f"\nScanning playbooks in: {playbooks_dir}")
    playbook_files = sorted(list(playbooks_dir.rglob("*.yml")) + list(playbooks_dir.rglob("*.yaml")))
    print(f"Found {len(playbook_files)} playbook(s)\n")
    existing_roles = [d.name for d in roles_dir.iterdir() if roles_dir.exists() and d.is_dir()] if roles_dir.exists() else []
    for p in playbook_files:
        rel = p.relative_to(playbooks_dir)
        print(f"\n{'─'*60}\nPlaybook: {rel}\n{'─'*60}")
        analysis = analyze_playbook(p)
        if not analysis:
            print("  [WARN] Empty or unreadable")
            continue
        if 'error' in analysis:
            print(f"  [ERROR] {analysis['error']}")
            continue
        print(f"  Plays: {analysis['plays']}  Tasks: {analysis['tasks']}  Complexity: {analysis['complexity']}")
        if analysis['roles']:
            print(f"  Roles used: {', '.join(map(str, analysis['roles']))}")
        rec = recommend_conversion(analysis)
        if rec.get('convert'):
            suggested = rec.get('suggested_role_name')
            exists = suggested in existing_roles
            print(f"  [RECOMMEND] Convert -> {suggested} {'(exists)' if exists else ''}")
        else:
            print(f"  [RECOMMEND] {rec.get('recommendation')} - {rec.get('reason')}")

# ---------------------------
# YAML indentation fixer
# ---------------------------
def make_backup(file_path: Path) -> Path:
    backup_dir = file_path.parent / ".backup"
    backup_dir.mkdir(parents=True, exist_ok=True)
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = backup_dir / f"{file_path.stem}_{ts}.yml.bak"
    shutil.copy2(file_path, backup_path)
    return backup_path

def fix_yaml_indentation(file_path: Path) -> Tuple[bool, str]:
    """Attempt to fix common indentation issues in Ansible playbooks"""
    try:
        backup = make_backup(file_path)
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        if not lines:
            return False, "Empty file"

        fixed_lines: List[str] = []
        changes = 0
        in_tasks = False
        in_vars = False

        for i, line in enumerate(lines):
            original = line
            stripped = line.lstrip()
            if not stripped or stripped.startswith("#"):
                fixed_lines.append(line)
                continue
            if stripped.startswith('---'):
                fixed_lines.append(line)
                in_tasks = in_vars = False
                continue
            # detect top-level play keys (hosts/name)
            if re.match(r'^-?\s*(name|hosts|gather_facts|become|vars|tasks|roles|handlers):', stripped):
                key = stripped.split(':', 1)[0].strip('- ').strip()
                if key in ['name', 'hosts']:
                    fixed_line = '- ' + stripped if not stripped.startswith('- ') else stripped
                    fixed_lines.append(fixed_line)
                    in_tasks = in_vars = False
                    if original != fixed_line:
                        changes += 1
                    continue
                elif key in ['gather_facts', 'become', 'vars', 'tasks', 'roles', 'handlers']:
                    fixed_line = '  ' + stripped.lstrip('- ')
                    fixed_lines.append(fixed_line)
                    if key == 'tasks':
                        in_tasks = True
                        in_vars = False
                    elif key == 'vars':
                        in_vars = True
                        in_tasks = False
                    else:
                        in_tasks = in_vars = False
                    if original.rstrip() != fixed_line.rstrip():
                        changes += 1
                    continue

            # task items
            if in_tasks:
                if re.match(r'^-?\s*name:', stripped):
                    fixed_line = '    - name:' + stripped.split('name:', 1)[1]
                    fixed_lines.append(fixed_line)
                    if original.rstrip() != fixed_line.rstrip():
                        changes += 1
                    continue
                elif re.match(r'^[a-zA-Z0-9_\-]+(\.[a-zA-Z0-9_\-]+)*:', stripped):
                    fixed_line = '      ' + stripped
                    fixed_lines.append(fixed_line)
                    if original.rstrip() != fixed_line.rstrip():
                        changes += 1
                    continue

            if in_vars:
                if re.match(r'^[a-zA-Z0-9_\-]+:', stripped):
                    fixed_line = '    ' + stripped
                    fixed_lines.append(fixed_line)
                    if original.rstrip() != fixed_line.rstrip():
                        changes += 1
                    continue

            fixed_lines.append(line)

        if changes > 0:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.writelines(fixed_lines)
            # validate YAML
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    yaml.safe_load(f)
                return True, f"Fixed {changes} indentation issue(s) - YAML valid (backup: {backup.name})"
            except Exception as e:
                return True, f"Fixed {changes} issue(s) - YAML parse warning: {str(e).splitlines()[0][:120]}"
        else:
            # No changes, validate
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    yaml.safe_load(f)
                return True, "Already valid"
            except Exception as e:
                return False, f"Needs manual fix - parse error: {str(e).splitlines()[0][:120]}"

    except Exception as exc:
        return False, f"Error processing file: {str(exc)[:200]}"

def show_file_comparison(file_path: Path, lines: int = 20) -> str:
    backup_dir = file_path.parent / ".backup"
    if not backup_dir.exists():
        return "No backup directory found"
    backups = sorted(backup_dir.glob(f"{file_path.stem}_*.yml.bak"))
    if not backups:
        return "No backups found"
    last = backups[-1]
    try:
        before = last.read_text(encoding='utf-8').splitlines()[:lines]
        after = file_path.read_text(encoding='utf-8').splitlines()[:lines]
        out = ["BEFORE:"]
        out += [f"  {i+1:02d}: {l}" for i,l in enumerate(before)]
        out += ["", "AFTER:"]
        out += [f"  {i+1:02d}: {l}" for i,l in enumerate(after)]
        return "\n".join(out)
    except Exception:
        return "Cannot read files for comparison"

def run_fixer(playbooks_dir: Path = DEFAULT_PLAYBOOKS_DIR) -> None:
    if not playbooks_dir.exists():
        print(f"[ERROR] Playbooks directory not found: {playbooks_dir}")
        return
    yaml_files = sorted(list(playbooks_dir.rglob("*.yml")) + list(playbooks_dir.rglob("*.yaml")))
    print(f"Found {len(yaml_files)} YAML files under {playbooks_dir}")
    resp = input("Proceed to attempt auto-fix for all files? [y/N]: ").strip().lower()
    if resp != 'y':
        print("Aborted.")
        return
    fixed = 0
    already = 0
    failed = []
    for f in yaml_files:
        ok, msg = fix_yaml_indentation(f)
        if ok:
            if msg.startswith("Already valid"):
                already += 1
                print(f"[OK] {f.relative_to(playbooks_dir)} - {msg}")
            else:
                fixed += 1
                print(f"[FIXED] {f.relative_to(playbooks_dir)} - {msg}")
        else:
            failed.append((f, msg))
            print(f"[FAILED] {f.relative_to(playbooks_dir)} - {msg}")
    print("\nSUMMARY")
    print(f"  Already valid: {already}")
    print(f"  Fixed: {fixed}")
    print(f"  Failed: {len(failed)}")
    if fixed > 0:
        # show example compare for first sample if exists
        sample = playbooks_dir / "lvm_auto_extend.yml"
        if sample.exists():
            print("\nExample comparison for lvm_auto_extend.yml:")
            print(show_file_comparison(sample, 20))

# ---------------------------
# Menu / CLI
# ---------------------------
def show_menu() -> None:
    defaults = {
        'playbooks_dir': DEFAULT_PLAYBOOKS_DIR,
        'roles_dir': DEFAULT_ROLES_DIR
    }
    while True:
        print("\n" + "="*72)
        print("Playbook Tools - Analyzer & YAML Fixer")
        print("="*72)
        print(f"Default playbooks dir: {defaults['playbooks_dir']}")
        print("1) Analyze playbooks for role-conversion")
        print("2) Fix YAML indentation for playbooks")
        print("3) Analyze then Fix (recommended order)")
        print("4) Change default playbooks directory")
        print("0) Exit")
        choice = input("Select: ").strip()
        if choice == '1':
            run_analyzer(Path(input(f"Playbooks dir [{defaults['playbooks_dir']}]: ").strip() or defaults['playbooks_dir']),
                         Path(input(f"Roles dir [{defaults['roles_dir']}]: ").strip() or defaults['roles_dir']))
            input("\nPress Enter to continue...")
        elif choice == '2':
            run_fixer(Path(input(f"Playbooks dir [{defaults['playbooks_dir']}]: ").strip() or defaults['playbooks_dir']))
            input("\nPress Enter to continue...")
        elif choice == '3':
            pb = Path(input(f"Playbooks dir [{defaults['playbooks_dir']}]: ").strip() or defaults['playbooks_dir'])
            run_analyzer(pb, Path(input(f"Roles dir [{defaults['roles_dir']}]: ").strip() or defaults['roles_dir']))
            run_fixer(pb)
            input("\nPress Enter to continue...")
        elif choice == '4':
            new = Path(input("New playbooks directory: ").strip())
            if new.exists():
                defaults['playbooks_dir'] = new
                print(f"Default playbooks dir set to: {new}")
            else:
                print("Directory does not exist.")
            input("\nPress Enter to continue...")
        elif choice == '0':
            print("Exit.")
            return
        else:
            print("Invalid choice.")

if __name__ == '__main__':
    show_menu()