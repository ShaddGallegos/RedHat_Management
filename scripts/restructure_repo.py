#!/usr/bin/env python3
"""
Restructure infra-automation repo into a consolidated layout.

Usage:
  cd /home/sgallego/Downloads/GIT/infra-automation
  python3 scripts/restructure_repo.py

What it does (safe, idempotent):
 - Creates playbooks/, roles/, plugins/inventory/, scripts/, inventory/, external/, py_backup/<timestamp>/
 - Moves playbooks (*.yml, *.yaml) from repo root -> playbooks/ (skips known entrypoints)
 - Moves role directories into roles/
 - Moves plugin python files into plugins/inventory/
 - Moves integrator shell scripts into scripts/
 - Moves inventory stub files (*.yml) from root -> inventory/
 - Moves external Add_LVM project copies into external/
 - Archives any overwritten or moved files into py_backup/<timestamp>/
 - Prints a summary of changes

It does NOT permanently delete anything (moved items are archived/relocated).
"""
from __future__ import annotations
import shutil
import sys
from pathlib import Path
from datetime import datetime
import stat

ROOT = Path(__file__).resolve().parent.parent
BACKUP_ROOT = ROOT / "py_backup" / datetime.utcnow().strftime("%Y%m%d_%H%M%S")
BACKUP_ROOT.mkdir(parents=True, exist_ok=True)

TARGETS = {
    "playbooks": ROOT / "playbooks",
    "roles": ROOT / "roles",
    "plugins_inventory": ROOT / "plugins" / "inventory",
    "scripts": ROOT / "scripts",
    "inventory": ROOT / "inventory",
    "external": ROOT / "external",
}

# Known entrypoints / files we should not move from repo root
KEEP_ROOT_FILES = {
    "site_run_aap.py",
    "infra_automation.py",
    "inventory_sources.py",
    "ansible.cfg",
    "README.md",
    "LICENSE",
    "pyproject.toml",
    "setup.cfg",
    "requirements.txt",
}

# file patterns considered playbooks (but skip site_run_aap.py etc.)
PLAYBOOK_EXTS = {".yml", ".yaml"}

# common plugin filename pattern (python files)
PLUGIN_DIR_CANDIDATES = [
    ROOT / "plugins" / "inventory",
    ROOT / "inventory_plugins",
    ROOT / "plugins_inventory",
]

def ensure_targets():
    for k, p in TARGETS.items():
        p.mkdir(parents=True, exist_ok=True)

def archive(path: Path):
    """Move path to backup preserving structure under BACKUP_ROOT."""
    try:
        rel = path.relative_to(ROOT)
    except Exception:
        rel = Path(path.name)
    dest = BACKUP_ROOT / rel
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.move(str(path), str(dest))
    print(f"[ARCHIVE] {path} -> {dest}")

def safe_move(src: Path, dst_dir: Path):
    """Move src into dst_dir; if dst exists, archive it first."""
    dst_dir.mkdir(parents=True, exist_ok=True)
    dst = dst_dir / src.name
    if dst.exists():
        # archive current dst before overwrite
        archive(dst)
    try:
        shutil.move(str(src), str(dst))
        print(f"[MOVE] {src} -> {dst}")
    except Exception as e:
        print(f"[ERROR] Failed to move {src} -> {dst}: {e}")

def move_playbooks():
    count = 0
    for p in ROOT.iterdir():
        if p.is_file() and p.suffix.lower() in PLAYBOOK_EXTS:
            if p.name in KEEP_ROOT_FILES:
                continue
            # Avoid moving inventory files that belong to plugin directories or roles
            safe_move(p, TARGETS["playbooks"])
            count += 1
    return count

def move_roles():
    count = 0
    # detect directories that look like roles (contain tasks/main.yml or meta/main.yml)
    for d in ROOT.iterdir():
        if d.is_dir() and d.name not in {"scripts", "plugins", "roles", "external", "playbooks", "inventory", "py_backup", "__pycache__"}:
            # skip typical integration/external dirs that we want to keep
            if (d / "tasks").exists() or (d / "meta").exists():
                safe_move(d, TARGETS["roles"])
                count += 1
    # also ensure any existing roles/ subdirs already present are kept
    return count

def move_plugins():
    count = 0
    # Look for candidate plugin directories and move their .py files to plugins/inventory
    # Also move any top-level *.py plugin files named like '*_inventory.py' into plugins/inventory
    # First move from known plugin candidates
    for cand in PLUGIN_DIR_CANDIDATES:
        if cand.exists() and cand.is_dir():
            for f in cand.glob("*.py"):
                safe_move(f, TARGETS["plugins_inventory"])
                count += 1
            # remove empty candidate dir (archive if not empty)
            try:
                if not any(cand.iterdir()):
                    cand.rmdir()
                else:
                    archive(cand)
            except Exception:
                pass
    # Move top-level plugin-like files (best-effort)
    for f in ROOT.glob("*.py"):
        name = f.name
        if name in KEEP_ROOT_FILES:
            continue
        # heuristic: inventory plugin names or file size > 0 and contains 'inventory' in name
        if "inventory" in name or name.endswith("_inventory.py") or name.startswith("foreman") or name.startswith("libvirt"):
            safe_move(f, TARGETS["plugins_inventory"])
            count += 1
    return count

def move_scripts():
    count = 0
    for f in ROOT.glob("*.sh"):
        safe_move(f, TARGETS["scripts"])
        count += 1
    # also move any script files under root named 'git_commit_*.sh' or 'integrate_*'
    for f in ROOT.glob("git_commit_*.sh"):
        safe_move(f, TARGETS["scripts"])
        count += 1
    for f in ROOT.glob("integrate_*.sh"):
        safe_move(f, TARGETS["scripts"])
        count += 1
    return count

def move_inventory_stubs():
    count = 0
    for f in ROOT.glob("*.yml"):
        # skip playbooks already moved and skip known root files
        if f.name in KEEP_ROOT_FILES:
            continue
        # heuristics: if file contains 'plugin:' in top lines or name suggests inventory
        try:
            head = f.read_text(errors="ignore")[:400]
        except Exception:
            head = ""
        if "plugin:" in head or f.name.startswith("inventory") or f.name.startswith("hosts"):
            safe_move(f, TARGETS["inventory"])
            count += 1
    return count

def move_external_projects():
    count = 0
    candidates = [
        Path("/home/sgallego/Downloads/GIT/Add_LVM_to_System_nutanix"),
        Path("/home/sgallego/Downloads/GIT/Add_LVM_to_System_libvirt"),
    ]
    for src in candidates:
        if src.exists() and src.is_dir():
            dst = TARGETS["external"] / src.name
            if dst.exists():
                archive(dst)
            try:
                shutil.copytree(src, dst)
                print(f"[COPY] {src} -> {dst}")
                count += 1
            except Exception as e:
                print(f"[ERROR] copy {src} -> {dst}: {e}")
    return count

def relocate_credential_types():
    """Find credential jsons and move them into roles/infra_dynamic_inventory/files/credential_types when possible."""
    found = list(ROOT.rglob("credential_types/*.json")) + list(ROOT.rglob("files/credential_types/*.json"))
    target = TARGETS["roles"] / "infra_dynamic_inventory" / "files" / "credential_types"
    moved = 0
    for p in found:
        try:
            target.mkdir(parents=True, exist_ok=True)
            dest = target / p.name
            if dest.exists():
                archive(dest)
            shutil.copy2(p, dest)
            print(f"[COPY] credential json {p} -> {dest}")
            moved += 1
        except Exception as e:
            print("Failed to move credential json:", p, e)
    return moved

def summary_report(changes: dict):
    print("\nRestructure summary:")
    for k, v in changes.items():
        print(f" - {k}: {v}")
    print(f"\nBackups and archived items are located under: {BACKUP_ROOT}")
    print("Review moved files and adjust imports/paths in scripts if required.")
    print("If you want, run 'git status' and inspect changes, then commit.")

def main():
    ensure_targets()
    changes = {}
    changes["playbooks_moved"] = move_playbooks()
    changes["roles_moved"] = move_roles()
    changes["plugins_moved"] = move_plugins()
    changes["scripts_moved"] = move_scripts()
    changes["inventory_stubs_moved"] = move_inventory_stubs()
    changes["external_copies"] = move_external_projects()
    changes["credential_jsons_copied"] = relocate_credential_types()

    # Optionally archive any stray temporary files (bootstrap scripts) found at repo root
    stray = ["bootstrap_all_in_one.py", "infra_automation_one_shot.py", "bootstrap_infra_automation.py"]
    stray_moved = 0
    for s in stray:
        p = ROOT / s
        if p.exists():
            archive(p)
            stray_moved += 1
    changes["stray_archived"] = stray_moved

    summary_report(changes)
    return 0

if __name__ == "__main__":
    rc = main()
    sys.exit(rc)