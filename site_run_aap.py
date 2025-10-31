#!/usr/bin/env python3
"""
Unified interactive launcher / integrator for infra-automation.

Integrates infra_automation.py and inventory_sources.py features into a single
menu with submenus. Provides actions to:
 - manage persisted inventory sources (list/add/remove)
 - scaffold dynamic-inventory role / provision credential types via infra_automation
 - run/copy integration scripts (Add_LVM nutanix/libvirt)
 - launch integrated Add_LVM managers (if wrappers present)
 - list/install inventory plugins
 - archive/remove legacy bootstrapper and temporary files (py_backup)
"""
from __future__ import annotations
import sys
import shutil
import subprocess
import importlib
from pathlib import Path
from typing import Optional, List

ROOT = Path(__file__).resolve().parent

# try to import infra_automation.scaffold function (best-effort)
try:
    infra_mod = importlib.import_module("infra_automation")
except Exception:
    infra_mod = None

# InventorySourceManager (external module) - fallback if unavailable
try:
    ism_mod = importlib.import_module("inventory_sources")
    InventorySourceManager = getattr(ism_mod, "InventorySourceManager")
except Exception:
    InventorySourceManager = None

# integration wrappers (optional)
def _load_wrapper(name: str, fn: str):
    try:
        m = importlib.import_module(name)
        return getattr(m, fn)
    except Exception:
        return None

launch_add_lvm_menu = _load_wrapper("integrations.add_lvm_wrapper", "launch_add_lvm_menu")
launch_add_lvm_libvirt_menu = _load_wrapper("integrations.add_lvm_libvirt_wrapper", "launch_add_lvm_libvirt_menu")

SCRIPTS_DIR = ROOT / "scripts"
PLUGINS_DIR = ROOT / "plugins" / "inventory"

def safe_run(cmd: List[str], check: bool = False) -> int:
    try:
        return subprocess.run(cmd, check=check).returncode or 0
    except Exception as e:
        print("[ERROR] command failed:", e)
        return 2

# --- inventory source submenu ---
def inventory_submenu():
    if InventorySourceManager is None:
        print("[WARN] inventory_sources module not found. Install or restore inventory_sources.py")
        return
    ism = InventorySourceManager(ROOT)
    while True:
        print("\nInventory Sources")
        print("1) List sources")
        print("2) Add source")
        print("3) Remove source")
        print("4) Back")
        c = input("Choose [1-4]: ").strip()
        if c == "1":
            items = ism.list_inventory_sources()
            if not items:
                print("No inventory sources recorded.")
            else:
                for s in items:
                    print(f"- {s.get('name')} (type: {s.get('type')}) created: {s.get('created_at')}")
        elif c == "2":
            name = input("Name: ").strip()
            stype = input("Plugin/type (e.g. foreman, libvirt, servicenow): ").strip()
            ok = ism.add_inventory_source(name, stype, overwrite=False)
            print("Added." if ok else "Not added (exists or invalid).")
        elif c == "3":
            name = input("Name to remove: ").strip()
            ok = ism.remove_inventory_source(name)
            print("Removed." if ok else "Not found.")
        elif c == "4":
            return
        else:
            print("Invalid choice.")

# --- plugins submenu ---
def plugins_submenu():
    while True:
        print("\nInventory Plugins")
        print("1) List available plugin files (plugins/inventory)")
        print("2) Install plugin to system path (copy)")
        print("3) Back")
        c = input("Choose [1-3]: ").strip()
        if c == "1":
            if not PLUGINS_DIR.exists():
                print("No plugins directory:", PLUGINS_DIR)
                continue
            for p in sorted(PLUGINS_DIR.glob("*.py")):
                print("-", p.name)
        elif c == "2":
            dest = input("Destination directory (full path) [/etc/ansible/plugins/inventory]: ").strip() or "/etc/ansible/plugins/inventory"
            dpath = Path(dest).expanduser()
            dpath.mkdir(parents=True, exist_ok=True)
            src_name = input("Plugin filename to install (from plugins/inventory): ").strip()
            src_file = PLUGINS_DIR / src_name
            if not src_file.exists():
                print("Source plugin not found:", src_file)
                continue
            shutil.copy2(src_file, dpath / src_file.name)
            print("Copied", src_file.name, "->", dpath)
        elif c == "3":
            return
        else:
            print("Invalid.")

# --- integrations submenu ---
def integrations_submenu():
    while True:
        print("\nIntegrations")
        print("1) Run Nutanix integrator (copy external project)")
        print("2) Run Libvirt integrator (copy external project)")
        print("3) Launch Add_LVM Nutanix manager")
        print("4) Launch Add_LVM Libvirt manager")
        print("5) Back")
        c = input("Choose [1-5]: ").strip()
        if c == "1":
            script = SCRIPTS_DIR / "integrate_add_lvm.sh"
            if script.exists():
                safe_run(["bash", str(script)])
            else:
                print("Integrator not found:", script)
        elif c == "2":
            script = SCRIPTS_DIR / "integrate_add_libvirt.sh"
            if script.exists():
                safe_run(["bash", str(script)])
            else:
                print("Integrator not found:", script)
        elif c == "3":
            if launch_add_lvm_menu:
                try:
                    rc = launch_add_lvm_menu()
                    print("Return code:", rc)
                except Exception as e:
                    print("Launch failed:", e)
            else:
                print("Nutanix wrapper not available (integrate project first).")
        elif c == "4":
            if launch_add_lvm_libvirt_menu:
                try:
                    rc = launch_add_lvm_libvirt_menu()
                    print("Return code:", rc)
                except Exception as e:
                    print("Launch failed:", e)
            else:
                print("Libvirt wrapper not available.")
        elif c == "5":
            return
        else:
            print("Invalid.")

# --- provisioning (scaffold) ---
def provision_credentials():
    if infra_mod and hasattr(infra_mod, "scaffold_dynamic_inventory_role"):
        try:
            role_path = infra_mod.scaffold_dynamic_inventory_role(ROOT)
            print("[OK] Role scaffolded at:", role_path)
        except Exception as e:
            print("[ERROR] scaffold failed:", e)
    else:
        print("[ERROR] infra_automation.scaffold_dynamic_inventory_role not available.")

# --- cleanup / archive old files ---
def archive_old_components():
    confirm = input("This will archive legacy bootstrap/run scripts to py_backup and remove a set of known temporary files. Proceed? [y/N]: ").strip().lower()
    if confirm != "y":
        print("Aborted.")
        return
    backup = ROOT / "py_backup"
    backup.mkdir(exist_ok=True)
    candidates = [
        "bootstrap_all_in_one.py",
        "bootstrap_infra_automation.py",
        "infra_automation_one_shot.py",
        "bootstrap_infra_automation.py",
        "infra_automation_old.py",
        "py_backup",  # if present, will be moved (skipped)
        "git_commit_inventory_extract.sh",
    ]
    moved = []
    for name in candidates:
        p = ROOT / name
        try:
            if p.exists():
                target = backup / name
                if p.is_dir():
                    shutil.move(str(p), str(target))
                else:
                    shutil.move(str(p), str(target))
                moved.append(p)
                print("Archived:", p, "->", target)
        except Exception as e:
            print("Failed to archive", p, ":", e)
    # also remove integrator scripts if present and user confirms
    to_remove = []
    for s in ("integrate_add_lvm.sh", "integrate_add_libvirt.sh"):
        sp = SCRIPTS_DIR / s
        if sp.exists():
            to_remove.append(sp)
    if to_remove:
        confirm2 = input(f"Remove integrator scripts {to_remove}? [y/N]: ").strip().lower()
        if confirm2 == "y":
            for sp in to_remove:
                try:
                    sp.unlink()
                    print("Removed:", sp)
                except Exception as e:
                    print("Failed to remove", sp, ":", e)
    print("Archive complete. Review:", backup)

# --- top-level menu ---
def show_menu() -> int:
    while True:
        print("\nInfra-Automation Main Menu")
        print("1) Inventory sources (list/add/remove)")
        print("2) Plugins (list / install)")
        print("3) Integrations (copy / launch Add_LVM)")
        print("4) Provision credentials (scaffold role & import to AAP)")
        print("5) Archive / remove legacy bootstrap files")
        print("6) Exit")
        choice = input("Select [1-6]: ").strip()
        if choice == "1":
            inventory_submenu()
        elif choice == "2":
            plugins_submenu()
        elif choice == "3":
            integrations_submenu()
        elif choice == "4":
            provision_credentials()
        elif choice == "5":
            archive_old_components()
        elif choice == "6":
            print("Goodbye.")
            return 0
        else:
            print("Invalid selection.")

def main() -> int:
    # preserve previous CLI flags too
    if "--launch-add-lvm" in sys.argv:
        if launch_add_lvm_menu:
            return launch_add_lvm_menu()
        print("Nutanix wrapper not available.")
        return 2
    if "--launch-add-libvirt" in sys.argv:
        if launch_add_lvm_libvirt_menu:
            return launch_add_lvm_libvirt_menu()
        print("Libvirt wrapper not available.")
        return 2
    if "--provision-credentials" in sys.argv:
        provision_credentials()
        return 0
    # default interactive
    return show_menu()

if __name__ == "__main__":
    rc = main()
    sys.exit(rc)
