#!/usr/bin/env python3
from __future__ import annotations
"""
Unified Infra Automation Manager
- Consolidates project scaffolding, inventory management, vault handling,
  playbook running, plugins, integrations and archive utilities.
- Menu reorganized into: Requirements, Project, Inventory, Playbooks, Vault,
  Integrations, Plugins, Maintenance, Exit.
"""
import os
import sys
import json
import shutil
import subprocess
import webbrowser
import importlib
import getpass
from pathlib import Path
from typing import Optional, List, Dict, Any, Tuple
import yaml

# --------------------
# Styling / UI helpers
# --------------------
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
        try:
            os.system('clear' if os.name != 'nt' else 'cls')
        except Exception:
            pass

    @staticmethod
    def header(title: str):
        print(f"\n{Colors.CYAN}{'='*70}{Colors.RESET}")
        print(f"{Colors.CYAN} {title:^66}{Colors.RESET}")
        print(f"{Colors.CYAN}{'='*70}{Colors.RESET}\n")

    def pause(self):
        if self.test_mode:
            return
        input(f"\n{Colors.YELLOW}Press [Enter] to continue...{Colors.RESET}")

    @staticmethod
    def success(msg: str):
        print(f"{Colors.GREEN}[OK]{Colors.RESET} {msg}")

    @staticmethod
    def info(msg: str):
        print(f"{Colors.BLUE}[INFO]{Colors.RESET} {msg}")

    @staticmethod
    def warning(msg: str):
        print(f"{Colors.YELLOW}[WARNING]{Colors.RESET} {msg}")

    @staticmethod
    def error(msg: str):
        print(f"{Colors.RED}[ERROR]{Colors.RESET} {msg}")

# --------------------
# Config & helpers
# --------------------
ROOT = Path(__file__).resolve().parent
DEFAULT_ENV_FILE = Path.home() / ".lvm_automation_env"
PY_BACKUP = ROOT / "py_backup"

def ask_yesno(prompt: str, default: bool = False) -> bool:
    yn = "Y/n" if default else "y/N"
    resp = input(f"{prompt} [{yn}]: ").strip().lower()
    if not resp:
        return default
    return resp in ("y", "yes")

# --------------------
# Config classes
# --------------------
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

# --------------------
# Inventory source manager (self-contained fallback)
# --------------------
class InventorySourceManager:
    def __init__(self, project_root: Optional[Path] = None):
        self.project_root = Path(project_root) if project_root else Path.cwd()
        self.sources_file = self.project_root / "inventory_sources.yml"

    def _load(self) -> List[Dict[str, Any]]:
        if not self.sources_file.exists():
            return []
        try:
            with open(self.sources_file, 'r', encoding='utf-8') as f:
                return yaml.safe_load(f) or []
        except Exception:
            return []

    def _save(self, sources: List[Dict[str, Any]]):
        try:
            self.sources_file.parent.mkdir(parents=True, exist_ok=True)
            with open(self.sources_file, 'w', encoding='utf-8') as f:
                yaml.safe_dump(sources, f, default_flow_style=False)
        except Exception:
            pass

    def list_inventory_sources(self) -> List[Dict[str, Any]]:
        return self._load()

    def add_inventory_source(self, name: str, source_type: str, overwrite: bool = False) -> bool:
        name = name.strip()
        source_type = source_type.strip()
        if not name or not source_type:
            return False
        sources = self._load()
        if any(s.get('name') == name for s in sources) and not overwrite:
            return False
        entry = {'name': name, 'type': source_type}
        sources = [s for s in sources if s.get('name') != name] + [entry]
        self._save(sources)
        # create stub inventory file
        inv_dir = self.project_root / "inventory"
        inv_dir.mkdir(parents=True, exist_ok=True)
        stub = inv_dir / f"{name}.yml"
        content = f"---\n# plugin stub for {name}\nplugin: {source_type}\n"
        if not stub.exists() or overwrite:
            stub.write_text(content, encoding='utf-8')
        return True

    def remove_inventory_source(self, name: str) -> bool:
        name = name.strip()
        if not name:
            return False
        sources = self._load()
        new = [s for s in sources if s.get('name') != name]
        if len(new) == len(sources):
            return False
        self._save(new)
        stub = self.project_root / "inventory" / f"{name}.yml"
        try:
            if stub.exists():
                stub.unlink()
        except Exception:
            pass
        return True

# --------------------
# Inventory / project utilities
# --------------------
class ProjectManager:
    def __init__(self, root: Path, ui: UI):
        self.root = root
        self.ui = ui
        self.roles = ["prework", "aap", "satellite", "libvirt", "insights", "integration"]
        self.plugins = ["dynamic_inventory_libvirt.py", "dynamic_inventory_satellite.py", "dynamic_inventory_aap.py", "dynamic_inventory_insights.py"]

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
        # plugin stubs
        for pl in self.plugins:
            ppath = self.root / "plugins" / pl
            if not ppath.exists():
                ppath.parent.mkdir(parents=True, exist_ok=True)
                ppath.write_text("# Dynamic inventory plugin stub\n")
                self.ui.success(f"Created: {ppath}")
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

# --------------------
# Vault manager (simple wrappers)
# --------------------
class VaultManager:
    def __init__(self, project_root: Path, ui: UI):
        self.project_root = project_root
        self.vault_file = project_root / "group_vars" / "all" / "vault.yml"
        self.ui = ui

    def write_vault_plain(self, secrets: Dict[str, Any]):
        self.vault_file.parent.mkdir(parents=True, exist_ok=True)
        if not secrets:
            self.ui.info("No secrets provided; skipping vault write.")
            return
        self.vault_file.write_text(yaml.safe_dump(secrets, default_flow_style=False))
        try:
            os.chmod(self.vault_file, 0o600)
        except Exception:
            pass
        self.ui.success(f"Wrote vault (plaintext): {self.vault_file}")

    def edit_vault(self):
        av = shutil.which("ansible-vault")
        p = input(f"Path to vault [{self.vault_file}]: ").strip() or str(self.vault_file)
        vault_path = Path(p).expanduser()
        vault_path.parent.mkdir(parents=True, exist_ok=True)
        if av:
            subprocess.run([av, "edit", str(vault_path)], check=False)
        else:
            editor = os.environ.get("EDITOR", shutil.which("vi") or "vi")
            subprocess.run([editor, str(vault_path)], check=False)

# --------------------
# Playbook runner
# --------------------
class PlaybookRunner:
    def __init__(self, project_root: Path, ui: UI):
        self.project_root = project_root
        self.ui = ui

    def run(self, playbook: str, inventory: Optional[str] = None, extra_vars: Optional[dict] = None, check: bool = False) -> int:
        pb = Path(playbook)
        if not pb.is_absolute():
            pb = self.project_root / playbook
        if not pb.exists():
            self.ui.error(f"Playbook not found: {pb}")
            return 2
        cmd = ["ansible-playbook", str(pb)]
        if inventory:
            cmd += ["-i", inventory]
        if extra_vars:
            cmd += ["--extra-vars", json.dumps(extra_vars)]
        if check:
            cmd.append("--check")
        self.ui.info("Running: " + " ".join(cmd))
        try:
            subprocess.run(cmd, check=False)
            return 0
        except FileNotFoundError:
            self.ui.error("ansible-playbook not found on PATH.")
            return 3
        except Exception as e:
            self.ui.error(f"Playbook run failed: {e}")
            return 4

# --------------------
# Utility functions
# --------------------
def backup_py_files(root: Path, keep: Optional[List[str]], ui: UI):
    backup = root / "py_backup"
    backup.mkdir(parents=True, exist_ok=True)
    keep_set = set(keep or [])
    for p in root.glob("*.py"):
        if p.name in keep_set or p.name == Path(__file__).name:
            continue
        try:
            shutil.move(str(p), str(backup / p.name))
            ui.success(f"Archived {p.name} -> py_backup/")
        except Exception as e:
            ui.warning(f"Failed to archive {p.name}: {e}")

def update_gitignore(project_root: Path, ui: UI):
    gitignore = project_root / ".gitignore"
    entries = ["ansible.cfg", "env.yml", "vault.yml", "__pycache__/", "py_backup/"]
    existing = set()
    if gitignore.exists():
        existing = set(line.strip() for line in gitignore.read_text().splitlines())
    with open(gitignore, "a+") as fh:
        fh.seek(0, os.SEEK_END)
        for e in entries:
            if e not in existing:
                fh.write(e + "\n")
    ui.success(f"Updated .gitignore at {gitignore}")

# --------------------
# Menu handlers
# --------------------
def requirements_menu(ui: UI):
    ui.header("Product Requirements & Architecture")
    print("1) Ansible Automation Platform 2.6")
    print("2) Red Hat Satellite 6.17")
    print("3) OpenShift 4.20")
    print("0) Back")
    c = input("Select: ").strip()
    if c == "1":
        ui.header("AAP 2.6 - Minimums")
        print("- RHEL 8.6+/9.2+, 4 vCPU, 16GB RAM, 100GB disk")
    elif c == "2":
        ui.header("Satellite 6.17 - Minimums")
        print("- RHEL 8.6+/9.2+, 4 vCPU, 16GB RAM, 100GB disk")
    elif c == "3":
        ui.header("OpenShift 4.20 - Minimums")
        print("- Multi-node control plane/workers; see vendor docs")
    ui.pause()

def project_menu(pm: ProjectManager, ui: UI):
    while True:
        ui.header("Project")
        print("1) Ensure project structure")
        print("2) Show roles")
        print("3) Show plugins")
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
            ui.header("Available Plugins")
            for p in pm.plugins:
                print("-", p)
            ui.pause()
        elif c == "0":
            return
        else:
            ui.warning("Invalid option")

def inventory_menu(cfg: Config, ui: UI):
    ism = InventorySourceManager(cfg.project_root)
    while True:
        ui.header("Inventory Sources")
        print("1) List sources")
        print("2) Add source")
        print("3) Remove source")
        print("4) Create hosts inventory (static)")
        print("0) Back")
        c = input("Select: ").strip()
        if c == "1":
            items = ism.list_inventory_sources()
            if not items:
                ui.info("No inventory sources recorded.")
            else:
                for s in items:
                    print(f"- {s.get('name')} (type: {s.get('type')})")
            ui.pause()
        elif c == "2":
            name = input("Name: ").strip()
            stype = input("Plugin/type (e.g. foreman, libvirt, servicenow): ").strip()
            ok = ism.add_inventory_source(name, stype, overwrite=False)
            ui.success("Added." if ok else "Not added (exists/invalid).")
            ui.pause()
        elif c == "3":
            name = input("Name to remove: ").strip()
            ok = ism.remove_inventory_source(name)
            ui.success("Removed." if ok else "Not found.")
            ui.pause()
        elif c == "4":
            hosts = input("Enter host lines (comma separated) or leave blank for localhost: ").strip()
            inv_path = cfg.project_root / "inventory" / "hosts"
            inv_path.parent.mkdir(parents=True, exist_ok=True)
            if not hosts:
                inv_path.write_text("[all]\nlocalhost ansible_connection=local\n")
            else:
                lines = ["[all]"] + [h.strip() for h in hosts.split(",")]
                inv_path.write_text("\n".join(lines) + "\n")
            ui.success(f"Wrote {inv_path}")
            ui.pause()
        elif c == "0":
            return
        else:
            ui.warning("Invalid option")

def playbooks_menu(cfg: Config, ui: UI, runner: PlaybookRunner):
    while True:
        ui.header("Playbooks")
        print("1) Run playbook")
        print("2) Generate example lvm_auto_extend playbook")
        print("3) Update .gitignore")
        print("0) Back")
        c = input("Select: ").strip()
        if c == "1":
            pb = input("Playbook path (relative to project root): ").strip()
            inv = input("Inventory path (optional): ").strip() or None
            extra = input("Extra vars as JSON (optional): ").strip()
            extra_vars = json.loads(extra) if extra else None
            runner.run(pb, inventory=inv, extra_vars=extra_vars, check=False)
            ui.pause()
        elif c == "2":
            pg = PlaybookGenerator(cfg)
            path = pg.create_lvm_extend_playbook()
            ui.success(f"Created playbook: {path}")
            ui.pause()
        elif c == "3":
            update_gitignore(cfg.project_root, ui)
            ui.pause()
        elif c == "0":
            return
        else:
            ui.warning("Invalid option")

def plugins_menu(cfg: Config, ui: UI):
    plugins_dir = cfg.project_root / "plugins" / "inventory"
    while True:
        ui.header("Plugins")
        print("1) List local plugin files")
        print("2) Install plugin (copy to destination)")
        print("0) Back")
        c = input("Select: ").strip()
        if c == "1":
            if not plugins_dir.exists():
                ui.info(f"No plugins directory: {plugins_dir}")
            else:
                for p in sorted(plugins_dir.glob("*.py")):
                    print("-", p.name)
            ui.pause()
        elif c == "2":
            dest = input("Destination directory (default /etc/ansible/plugins/inventory): ").strip() or "/etc/ansible/plugins/inventory"
            dest_path = Path(dest).expanduser()
            dest_path.mkdir(parents=True, exist_ok=True)
            src = input("Plugin filename (from plugins/inventory): ").strip()
            src_file = plugins_dir / src
            if not src_file.exists():
                ui.error(f"Source plugin not found: {src_file}")
            else:
                shutil.copy2(src_file, dest_path / src_file.name)
                ui.success(f"Copied {src_file.name} -> {dest_path}")
            ui.pause()
        elif c == "0":
            return
        else:
            ui.warning("Invalid option")

def integrations_menu(cfg: Config, ui: UI):
    ROOT = cfg.project_root
    SCRIPTS_DIR = ROOT / "scripts"
    # optional wrappers
    def load_wrapper(name: str, fn: str):
        try:
            m = importlib.import_module(name)
            return getattr(m, fn)
        except Exception:
            return None
    launch_add_lvm = load_wrapper("integrations.add_lvm_wrapper", "launch_add_lvm_menu")
    launch_add_lvm_libvirt = load_wrapper("integrations.add_lvm_libvirt_wrapper", "launch_add_lvm_libvirt_menu")

    while True:
        ui.header("Integrations")
        print("1) Run integrator scripts (if present)")
        print("2) Launch Add_LVM Nutanix manager (if wrapper available)")
        print("3) Launch Add_LVM Libvirt manager (if wrapper available)")
        print("0) Back")
        c = input("Select: ").strip()
        if c == "1":
            for s in ("integrate_add_lvm.sh", "integrate_add_libvirt.sh"):
                sp = SCRIPTS_DIR / s
                if sp.exists():
                    subprocess.run(["bash", str(sp)], check=False)
                    ui.success(f"Ran {sp}")
                else:
                    ui.info(f"Not found: {sp}")
            ui.pause()
        elif c == "2":
            if launch_add_lvm:
                try:
                    launch_add_lvm()
                except Exception as e:
                    ui.error(f"Launch failed: {e}")
            else:
                ui.warning("Nutanix wrapper not available.")
            ui.pause()
        elif c == "3":
            if launch_add_lvm_libvirt:
                try:
                    launch_add_lvm_libvirt()
                except Exception as e:
                    ui.error(f"Launch failed: {e}")
            else:
                ui.warning("Libvirt wrapper not available.")
            ui.pause()
        elif c == "0":
            return
        else:
            ui.warning("Invalid option")

def maintenance_menu(cfg: Config, ui: UI):
    while True:
        ui.header("Maintenance")
        print("1) Archive legacy bootstrap scripts to py_backup")
        print("2) Backup other .py files to py_backup (keep selected)")
        print("3) Edit vault")
        print("0) Back")
        c = input("Select: ").strip()
        if c == "1":
            archive_old_components(cfg.project_root, ui)
            ui.pause()
        elif c == "2":
            keep = [Path(__file__).name, "manager.py", "site.py"]
            backup_py_files(cfg.project_root, keep=keep, ui=ui)
            ui.pause()
        elif c == "3":
            vm = VaultManager(cfg.project_root, ui)
            vm.edit_vault()
            ui.pause()
        elif c == "0":
            return
        else:
            ui.warning("Invalid option")

# --------------------
# Smaller utilities used by menus
# --------------------
def archive_old_components(root: Path, ui: UI):
    confirm = input("Archive legacy/bootstrap scripts to py_backup? [y/N]: ").strip().lower()
    if confirm != "y":
        ui.info("Aborted.")
        return
    backup = root / "py_backup"
    backup.mkdir(parents=True, exist_ok=True)
    candidates = [
        "bootstrap_all_in_one.py",
        "bootstrap_infra_automation.py",
        "infra_automation_one_shot.py",
        "infra_automation_old.py",
        "git_commit_inventory_extract.sh",
    ]
    for name in candidates:
        p = root / name
        try:
            if p.exists():
                shutil.move(str(p), str(backup / name))
                ui.success(f"Archived {p} -> {backup}")
        except Exception as e:
            ui.warning(f"Failed to archive {p}: {e}")
    ui.info(f"Archive complete. Review: {backup}")

# --------------------
# Playbook generator (small)
# --------------------
class PlaybookGenerator:
    def __init__(self, cfg: Config):
        self.project_root = cfg.project_root

    def create_lvm_extend_playbook(self) -> Path:
        content = """---
- name: LVM Auto Extension
  hosts: all
  become: true
  gather_facts: true
  tasks:
    - name: Inspect LVM (placeholder)
      debug: msg="Inspecting LVM"
"""
        path = self.project_root / "playbooks" / "operations" / "lvm_auto_extend.yml"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
        return path

# --------------------
# Setup wizard (condensed)
# --------------------
def setup_wizard(cfg: Config, ui: UI):
    ui.header("Setup Wizard (nodes & integrations)")
    env: Dict[str, Any] = {}
    nodes: List[Dict[str, Any]] = []
    secrets: Dict[str, Any] = {}
    # Ask for Satellite example
    if ask_yesno("Configure Satellite integration?", default=True):
        fqdn = input("Satellite FQDN: ").strip() or "satellite.example.com"
        ip = input("Satellite IP (optional): ").strip()
        user = input("Satellite admin user [admin]: ").strip() or "admin"
        pwd = getpass.getpass("Satellite admin password (hidden): ").strip()
        env.update({"SATELLITE_URL": fqdn, "SATELLITE_USERNAME": user})
        if ip:
            nodes.append({"role": "satellite", "fqdn": fqdn, "ip": ip, "admin_user": user})
        if pwd:
            secrets["SATELLITE_PASSWORD"] = pwd
    # Persist a minimal env file
    env_file = DEFAULT_ENV_FILE
    env_file.parent.mkdir(parents=True, exist_ok=True)
    with open(env_file, "w", encoding='utf-8') as fh:
        json.dump(env, fh, indent=2)
    ui.success(f"Saved env to {env_file}")
    # write hosts and master vars
    inv = cfg.project_root / "inventory" / "hosts"
    inv.parent.mkdir(parents=True, exist_ok=True)
    if nodes:
        lines = ["[all]"] + [f"{n['fqdn']} ansible_host={n['ip']}" if n.get('ip') else n['fqdn'] for n in nodes]
        inv.write_text("\n".join(lines) + "\n")
    else:
        inv.write_text("[all]\nlocalhost ansible_connection=local\n")
    ui.success(f"Wrote inventory: {inv}")
    # write vault plaintext then optionally encrypt
    vm = VaultManager(cfg.project_root, ui)
    vm.write_vault_plain(secrets)
    ui.pause()

# --------------------
# Top-level menu
# --------------------
def main_menu(cfg: Config, ui: UI):
    pm = ProjectManager(cfg.project_root, ui)
    runner = PlaybookRunner(cfg.project_root, ui)
    while True:
        ui.header("Infra Automation Main Menu")
        print("1) Requirements")
        print("2) Project")
        print("3) Inventory")
        print("4) Playbooks")
        print("5) Vault")
        print("6) Integrations")
        print("7) Plugins")
        print("8) Maintenance")
        print("0) Exit")
        choice = input("Select: ").strip()
        if choice == "1":
            requirements_menu(ui)
        elif choice == "2":
            project_menu(pm, ui)
        elif choice == "3":
            inventory_menu(cfg, ui)
        elif choice == "4":
            playbooks_menu(cfg, ui, runner)
        elif choice == "5":
            vm = VaultManager(cfg.project_root, ui)
            vm.edit_vault()
        elif choice == "6":
            integrations_menu(cfg, ui)
        elif choice == "7":
            plugins_menu(cfg, ui)
        elif choice == "8":
            maintenance_menu(cfg, ui)
        elif choice == "0":
            ui.info("Goodbye.")
            return 0
        else:
            ui.warning("Invalid selection")

# --------------------
# Entry point
# --------------------
def main(argv: Optional[List[str]] = None) -> int:
    argv = argv or sys.argv[1:]
    ui = UI(test_mode=("--test" in argv))
    cfg = Config()
    # If inventory_sources module exists use that instead of local fallback
    try:
        ism_mod = importlib.import_module("inventory_sources")
        InventorySourceManagerLocal = getattr(ism_mod, "InventorySourceManager")
        # override global fallback
        globals()['InventorySourceManager'] = InventorySourceManagerLocal
    except Exception:
        pass
    return main_menu(cfg, ui)

if __name__ == "__main__":
    try:
        rc = main()
        sys.exit(rc)
    except KeyboardInterrupt:
        print("\nInterrupted, exiting.")
