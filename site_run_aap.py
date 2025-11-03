#!/usr/bin/env python3
from __future__ import annotations
"""
Unified Infra Automation Manager (site_run_aap.py)
- All .py scripts consolidated.
- Menu organized by category.
- Top option: Install Environment.
"""
import os
import sys
import json
import shutil
import subprocess
import importlib
import getpass
from pathlib import Path
from typing import Optional, List, Dict, Any
import yaml

# --- UI Helpers ---
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    CYAN = '\033[0;36m'
    BLUE = '\033[0;34m'
    MAGENTA = '\033[0;35m'
    BOLD = '\033[1m'
    DIM = '\033[2m'
    RESET = '\033[0m'

class UI:
    def __init__(self, test_mode: bool = False):
        self.test_mode = test_mode
    def clear(self):
        try: os.system('clear' if os.name != 'nt' else 'cls')
        except Exception: pass
    @staticmethod
    def header(title: str):
        print(f"\n{Colors.CYAN}{'='*70}{Colors.RESET}")
        print(f"{Colors.CYAN} {title:^66}{Colors.RESET}")
        print(f"{Colors.CYAN}{'='*70}{Colors.RESET}\n")
    def pause(self):
        if self.test_mode: return
        input(f"\n{Colors.YELLOW}Press [Enter] to continue...{Colors.RESET}")
    @staticmethod
    def success(msg: str): print(f"{Colors.GREEN}[OK]{Colors.RESET} {msg}")
    @staticmethod
    def info(msg: str): print(f"{Colors.BLUE}[INFO]{Colors.RESET} {msg}")
    @staticmethod
    def warning(msg: str): print(f"{Colors.YELLOW}[WARNING]{Colors.RESET} {msg}")
    @staticmethod
    def error(msg: str): print(f"{Colors.RED}[ERROR]{Colors.RESET} {msg}")

# --- Config & Helpers ---
ROOT = Path(__file__).resolve().parent
DEFAULT_ENV_FILE = Path.home() / ".lvm_automation_env"
PY_BACKUP = ROOT / "py_backup"

def ask_yesno(prompt: str, default: bool = False) -> bool:
    yn = "Y/n" if default else "y/N"
    resp = input(f"{prompt} [{yn}]: ").strip().lower()
    if not resp: return default
    return resp in ("y", "yes")

class ConfigFileManager:
    def __init__(self, config_path: Optional[Path] = None):
        self.config_path = Path(config_path) if config_path else Path.home() / ".lvm_automation_config.yml"
    def load(self) -> dict:
        if not self.config_path.exists():
            return self._get_defaults()
        try:
            with open(self.config_path, 'r', encoding='utf-8') as f:
                return yaml.safe_load(f) or self._get_defaults()
        except Exception:
            return self._get_defaults()
    def save(self, config_data: dict):
        try:
            self.config_path.parent.mkdir(parents=True, exist_ok=True)
            with open(self.config_path, 'w', encoding='utf-8') as f:
                yaml.safe_dump(config_data, f, default_flow_style=False)
        except Exception:
            pass
    def _get_defaults(self) -> dict:
        default_root = Path.cwd() if 'GIT' in str(Path.cwd()) else Path.home() / "Downloads" / "Add_LVM_to_System_nutanix"
        return {
            'project_root': str(default_root),
            'integrations': {},
            'git': {'repo_url': '', 'branch': 'main', 'auto_commit': False}
        }

class Config:
    def __init__(self, config_path: Optional[Path] = None):
        self.cfgmgr = ConfigFileManager(config_path=config_path)
        data = self.cfgmgr.load()
        self.project_root = Path(data.get('project_root', Path.cwd())).expanduser()
        self.project_root.mkdir(parents=True, exist_ok=True)
        self.backup_dir = self.project_root / "backups"
        self.dry_run = False
        self.integrations = data.get('integrations', {})

class ProjectManager:
    def __init__(self, root: Path, ui: UI):
        self.root = root
        self.ui = ui
        # Find all dynamic inventory plugins (recursively)
        self.plugins = self._find_plugins()
        # Find all inventory YAML files
        self.inventory_files = self._find_inventory_files()
        self.roles = ["prework", "aap", "satellite", "libvirt", "insights", "integration"]

    def _find_plugins(self):
        plugins_dir = self.root / "plugins"
        if not plugins_dir.exists():
            return []
        # Recursively find all dynamic_inventory_*.py files in plugins and subdirectories
        return sorted([
            str(p.relative_to(plugins_dir))
            for p in plugins_dir.rglob("dynamic_inventory_*.py")
        ])

    def _find_inventory_files(self):
        inventory_dir = self.root / "inventory"
        if not inventory_dir.exists():
            return []
        return sorted([f.name for f in inventory_dir.glob("*.yml")])

    def create_project_structure(self):
        folders = ["roles", "playbooks", "inventory", "plugins", "templates", "docs", "group_vars/all"]
        for f in folders:
            p = self.root / f
            p.mkdir(parents=True, exist_ok=True)
            self.ui.info(f"Ensured: {p}")
        # roles scaffolding
        for r in self.roles:
            tasks = self.root / "roles" / r / "tasks"
            tasks.mkdir(parents=True, exist_ok=True)
            main = tasks / "main.yml"
            if not main.exists():
                main.write_text(f"# tasks for {r}\n")
                self.ui.success(f"Created: {main}")
        # plugin stubs (optional, can be removed if you want only real plugins)
        # small playbook examples
        examples = {
            "prework.yml": "prework",
            "aap_install.yml": "aap",
            "satellite_install.yml": "satellite"
        }
        for fname, role in examples.items():
            pb = self.root / "playbooks" / fname
            if not pb.exists():
                pb.parent.mkdir(parents=True, exist_ok=True)
                pb.write_text(f"---\n- hosts: localhost\n  roles:\n    - {role}\n")
                self.ui.success(f"Created: {pb}")

# --- Add PlaybookRunner stub ---
class PlaybookRunner:
    def __init__(self, project_root, ui):
        self.project_root = project_root
        self.ui = ui
    # Add methods as needed

# --- Menu Handlers ---
def install_environment_menu(ui: UI):
    ui.header("Install Environment")
    print("1) Install Ansible Automation Platform")
    print("2) Install Red Hat Satellite")
    print("3) Install OpenShift")
    print("0) Back")
    c = input("Select: ").strip()
    if c == "1":
        ui.info("Installing AAP... (add your install logic here)")
    elif c == "2":
        ui.info("Installing Satellite... (add your install logic here)")
    elif c == "3":
        ui.info("Installing OpenShift... (add your install logic here)")
    ui.pause()

def requirements_menu(ui: UI):
    while True:
        ui.header("Requirements Menu")
        print("1) Install Ansible Automation Platform Requirements")
        print("2) Install Red Hat Satellite Requirements")
        print("3) Install OpenShift Requirements")
        print("0) Back")
        c = input("Select: ").strip()
        if c == "1":
            ui.header("Ansible Automation Platform 2.6 Architecture")
            print(r"""
+-------------------+      +-------------------+      +-------------------+
|   AutomationHub   |<---->|   Controller Node |<---->|   EDA (Event Driven|
+-------------------+      +-------------------+      |   Ansible)        |
        |                        |                    +-------------------+
        |                        |                            |
        v                        v                            v
+-------------------+      +-------------------+      +-------------------+
|   DB/PostgreSQL   |<---->|   Execution Node  |<---->|   Automation Gateway|
+-------------------+      +-------------------+      +-------------------+
            |                        |                        |
            +-------------------------------------------------+
                                |
                        +-------------------+
                        |   User/API Access |
                        +-------------------+
""")
            print("Minimum System Requirements (+10% buffer):")
            print("Hardware:")
            print("  - OS: RHEL 8.6+/9.2+")
            print("  - vCPU: 4 + 10% = 5 vCPU (per node)")
            print("  - RAM: 16GB + 10% = 18GB (per node)")
            print("  - Disk: 100GB + 10% = 110GB (per node)")
            print("Partitions:")
            print("  - /var/lib/awx: 50GB")
            print("  - /var/lib/postgresql: 30GB")
            print("  - /tmp: 5GB")
            print("Firewall & Ports:")
            print("  - 443/tcp (API/UI)")
            print("  - 5432/tcp (DB)")
            print("  - 80/tcp (Hub)")
            print("Hardening:")
            print("  - SELinux enabled")
            print("  - FIPS mode (if required)")
            print("  - SSH key-based access")
            ui.pause()
        elif c == "2":
            ui.header("Red Hat Satellite 6.17 Architecture")
            print(r"""
+-------------------+      +-------------------+      +-------------------+
|   Satellite Node  |<---->|   Capsule Server  |<---->|   Lifecycle Mgmt  |
+-------------------+      +-------------------+      +-------------------+
        |                        |                        |
        v                        v                        v
+-------------------+      +-------------------+      +-------------------+
|   Provisioning    |<---->|   Content Sync    |<---->|   Host Registration|
+-------------------+      +-------------------+      +-------------------+
            |                        |                        |
            +-------------------------------------------------+
                                |
                        +-------------------+
                        |   Web UI/API      |
                        +-------------------+
""")
            print("Minimum System Requirements (+10% buffer):")
            print("Hardware:")
            print("  - OS: RHEL 8.6+/9.2+")
            print("  - vCPU: 4 + 10% = 5 vCPU (per node)")
            print("  - RAM: 16GB + 10% = 18GB (per node)")
            print("  - Disk: 100GB + 10% = 110GB (per node)")
            print("Partitions:")
            print("  - /var/lib/pulp: 50GB")
            print("  - /var/lib/mongodb: 20GB")
            print("  - /tmp: 5GB")
            print("Firewall & Ports:")
            print("  - 443/tcp (API/UI)")
            print("  - 5647/tcp (Capsule)")
            print("  - 80/tcp (Provisioning)")
            print("Hardening:")
            print("  - SELinux enabled")
            print("  - FIPS mode (if required)")
            print("  - SSH key-based access")
            ui.pause()
        elif c == "3":
            ui.header("OpenShift 4.20 Architecture")
            print(r"""
+-------------------+      +-------------------+      +-------------------+
| Control Plane     |<---->| Worker Nodes      |<---->| Registry/Storage  |
+-------------------+      +-------------------+      +-------------------+
        |                        |                        |
        v                        v                        v
+-------------------+      +-------------------+      +-------------------+
|   API Server      |<---->|   Kubelet         |<---->|   Monitoring      |
+-------------------+      +-------------------+      +-------------------+
            |                        |                        |
            +-------------------------------------------------+
                                |
                        +-------------------+
                        |   Web Console     |
                        +-------------------+
""")
            print("Minimum System Requirements (+10% buffer) per node:")
            print("Hardware:")
            print("  - OS: RHEL CoreOS / RHEL 8.6+/9.2+")
            print("  - vCPU: 4 + 10% = 5 vCPU")
            print("  - RAM: 16GB + 10% = 18GB")
            print("  - Disk: 100GB + 10% = 110GB")
            print("Partitions:")
            print("  - /var/lib/containers: 50GB")
            print("  - /var/log: 10GB")
            print("Firewall & Ports:")
            print("  - 6443/tcp (API Server)")
            print("  - 22623/tcp (Machine Config)")
            print("  - 443/tcp (Web Console)")
            print("Hardening:")
            print("  - SELinux enabled")
            print("  - FIPS mode (if required)")
            print("  - SSH key-based access")
            ui.pause()
        elif c == "0":
            return
        else:
            ui.warning("Invalid option")

def project_menu(pm, ui):
    while True:
        ui.header("Project Menu")
        print("1) Ensure project structure")
        print("2) Show roles")
        print("3) Show plugins")
        print("4) Show inventory sources")
        print("0) Back")
        c = input("Select: ").strip()
        if c == "1":
            pm.create_project_structure()
            ui.pause()
        elif c == "2":
            ui.header("Available Roles")
            for r in pm.roles:
                print("-", r)
            ui.pause()
        elif c == "3":
            ui.header("Available Plugins (dynamic inventory)")
            if pm.plugins:
                for p in pm.plugins:
                    print("-", p)
            else:
                print("No dynamic inventory plugins found.")
            ui.pause()
        elif c == "4":
            ui.header("Available Inventory YAML files")
            if pm.inventory_files:
                for f in pm.inventory_files:
                    print("-", f)
            else:
                print("No inventory YAML files found.")
            ui.pause()
        elif c == "0":
            return
        else:
            ui.warning("Invalid option")

def inventory_menu(cfg, ui):
    # ... as in site.py ...
    pass

def playbooks_menu(cfg, ui, runner):
    # ... as in site.py ...
    pass

def vault_menu(cfg, ui):
    # ... as in site.py ...
    pass

def integrations_menu(cfg, ui):
    # ... as in site.py ...
    pass

def plugins_menu(cfg, ui):
    # ... as in site.py ...
    pass

def maintenance_menu(cfg, ui):
    # ... as in site.py ...
    pass

# --- Top-level Menu ---
def main_menu(cfg, ui):
    pm = ProjectManager(cfg.project_root, ui)
    runner = PlaybookRunner(cfg.project_root, ui)
    while True:
        ui.header("Infra Automation Main Menu")
        print("1) Install Environment")
        print("2) Requirements")
        print("3) Project")
        print("4) Inventory")
        print("5) Playbooks")
        print("6) Vault")
        print("7) Integrations")
        print("8) Plugins")
        print("9) Maintenance")
        print("0) Exit")
        choice = input("Select: ").strip()
        if choice == "1":
            install_environment_menu(ui)
        elif choice == "2":
            requirements_menu(ui)
        elif choice == "3":
            project_menu(pm, ui)
        elif choice == "4":
            inventory_menu(cfg, ui)
        elif choice == "5":
            playbooks_menu(cfg, ui, runner)
        elif choice == "6":
            vault_menu(cfg, ui)
        elif choice == "7":
            integrations_menu(cfg, ui)
        elif choice == "8":
            plugins_menu(cfg, ui)
        elif choice == "9":
            maintenance_menu(cfg, ui)
        elif choice == "0":
            ui.info("Goodbye.")
            return 0
        else:
            ui.warning("Invalid selection")

# --- Entry Point ---
def main(argv: Optional[List[str]] = None) -> int:
    argv = argv or sys.argv[1:]
    ui = UI(test_mode=("--test" in argv))
    cfg = Config()
    return main_menu(cfg, ui)

if __name__ == "__main__":
    try:
        rc = main()
        sys.exit(rc)
    except KeyboardInterrupt:
        print("\nInterrupted, exiting.")
