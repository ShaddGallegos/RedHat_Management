#!/usr/bin/env python3
# Version: 2.0.6
# Last Updated: 2025-10-08
# Changes: Synced with latest Add_LVM_to_System_nutanix project structure and features

import os
import sys
import json
import socket

# Add these module-level imports so annotations and referenced modules are defined
from pathlib import Path
from typing import Optional, Tuple, List, Dict, Any
import subprocess
import yaml

def _startup_checks():
    print("Starting LVM Automation Manager...")
    print(f"Python version: {sys.version}")
    print("Testing imports...")
    try:
        import shutil  # noqa: F401
        import re  # noqa: F401
        import getpass  # noqa: F401
        import logging  # noqa: F401
        import stat  # noqa: F401
        from datetime import datetime  # noqa: F401
        import tempfile  # noqa: F401
        print("[OK] All basic imports successful")
    except ImportError as e:
        print(f"[ERROR] Import error: {e}")
        sys.exit(1)

    try:
        # Use dynamic import to avoid static analysis errors when the package
        # is not installed in the environment used by linters/editors.
        import importlib
        _requests = importlib.import_module('requests')
        globals()['REQUESTS_AVAILABLE'] = True
        globals()['requests'] = _requests
        print("[OK] requests available")
    except ModuleNotFoundError:
        globals()['REQUESTS_AVAILABLE'] = False
        globals()['requests'] = None
        print("[WARNING] requests not available (optional)")

    print("\nInitializing classes...\n")

if __name__ == "__main__":
    _startup_checks()

# ============================================================================
# CONFIGURATION & UTILITIES
# ============================================================================

# Use local Config/UI implementations; import Colors from package for styling
from aap_lvm_pkg.ui import Colors

class DryRunManager:
    def __init__(self):
        self._dry_run = False
        self._operations = []
    @property
    def enabled(self) -> bool:
        return self._dry_run
    def enable(self):
        self._dry_run = True
        self._operations = []
    def disable(self):
        self._dry_run = False
        self._operations = []

class ConfigFileManager:
    def __init__(self, config_path: Optional[Path] = None):
        self.config_path = config_path or Path.home() / ".lvm_automation_config.yml"
    def load(self) -> dict:
        if not self.config_path.exists():
            return self._get_defaults()
        try:
            with open(self.config_path, 'r') as f:
                return yaml.safe_load(f) or self._get_defaults()
        except Exception as e:
            print(f"Warning: Could not load config: {e}")
            return self._get_defaults()
    def save(self, config_data: dict):
        try:
            with open(self.config_path, 'w') as f:
                yaml.dump(config_data, f, default_flow_style=False)
        except Exception as e:
            print(f"Warning: Could not save config: {e}")
    def _get_defaults(self) -> dict:
        current_dir = Path.cwd()
        if 'GIT' in str(current_dir) or 'Add_LVM_to_System_nutanix' in str(current_dir):
            default_root = current_dir
        else:
            default_root = Path.home() / "Downloads" / "Add_LVM_to_System_nutanix"
        return {
            'project_root': str(default_root),
            'git': {'repo_url': '', 'branch': 'main', 'auto_commit': False},
            'lvm': {'threshold_percent': 80, 'critical_threshold': 90, 'extend_percent': 20, 'min_extend_gb': 10},
            'servicenow': {'priority_critical': 2, 'priority_warning': 3, 'auto_close_on_success': True},
            'notifications': {'email_enabled': False, 'slack_enabled': False, 'teams_enabled': False},
            'integrations': {
                'automation_hub_configured': False,
                'github_configured': False,
                'servicenow_configured': False,
                'nutanix_configured': False,
                'satellite_configured': False,
                'insights_configured': False
            }
        }

class Config:
    def __init__(self):
        self.config_manager = ConfigFileManager()
        config_data = self.config_manager.load()
        project_root_str = config_data.get('project_root', str(Path.home() / "Downloads" / "Add_LVM_to_System_nutanix"))
        self.project_root = Path(project_root_str)
        try:
            if not self.project_root.exists():
                self.project_root.mkdir(parents=True, exist_ok=True)
        except Exception as e:
            print(f"Warning: Could not create project root: {e}")
        self.backup_dir = self.project_root / "backups"
        self.dry_run = DryRunManager()
        self.integrations = config_data.get('integrations', {})
        self.roles = [
            'servicenow_ticket_management',
            'lvm_smart_extend',
            'lvm_system_inspection',
            'lvm_extension_orchestrator',
            'disk_usage_alerting',
            'credential_manager',
            'aap_inventory_sources',
            'aap_project_setup',
            'eda_configuration'
        ]
        self.playbooks = {
            'lvm_auto_extend': 'playbooks/operations/lvm_auto_extend.yml',
            'lvm_health_check': 'playbooks/operations/lvm_health_check.yml',
            'system_inspection': 'playbooks/operations/system_inspection.yml',
            'emergency_extend': 'playbooks/operations/emergency_disk_space.yml',
            'manual_extend': 'playbooks/operations/manual_lvm_extension.yml',
            'disk_alerting': 'playbooks/operations/disk_usage_alerting.yml',
            'sync_inventories': 'playbooks/operations/sync_all_inventories.yml',
            'setup_credentials': 'playbooks/setup_credentials.yml',
            'complete_aap_setup': 'playbooks/complete_aap_setup.yml',
            'eda_setup': 'playbooks/setup_eda.yml'
        }
        self.inventory_sources = [
            'servicenow_inventory.yml',
            'nutanix_inventory.yml',
            'satellite_inventory.yml',
            'insights_inventory.yml'
        ]
        self.email_templates = [
            'disk_alert_email.j2',
            'lvm_extend_email.j2',
            'inspection_report_email.j2'
        ]
        self.aap_credentials = {
            'username': '',
            'password': '',
            'vault_password': ''
        }
        self.snow_credentials = {
            'instance': '',
            'username': '',
            'password': ''
        }
        self.nutanix_credentials = {
            'host': '',
            'username': '',
            'password': ''
        }
        self.satellite_credentials = {
            'url': '',
            'username': '',
            'password': ''
        }
        self.insights_credentials = {
            'username': '',
            'password': '',
            'org_id': ''
        }

class UI:
    @staticmethod
    def clear():
        os.system('clear' if os.name != 'nt' else 'cls')
    @staticmethod
    def header(title: str):
        print(f"\n{Colors.CYAN}{'='*70}{Colors.RESET}")
        print(f"{Colors.CYAN} {title:^66}{Colors.RESET}")
        print(f"{Colors.CYAN}{'='*70}{Colors.RESET}\n")
    @staticmethod
    def pause():
        input(f"\n{Colors.YELLOW}Press [Enter] to continue...{Colors.RESET}")
    @staticmethod
    def confirm(message: str, default: bool = True) -> bool:
        prompt = f"{Colors.YELLOW}{message} [{'Y/n' if default else 'y/N'}]: {Colors.RESET}"
        response = input(prompt).strip().lower()
        if not response:
            return default
        return response == 'y'
    @staticmethod
    def success(message: str):
        print(f"{Colors.GREEN}[OK]{Colors.RESET} {message}")
    @staticmethod
    def error(message: str):
        print(f"{Colors.RED}[ERROR]{Colors.RESET} {message}")
    @staticmethod
    def warning(message: str):
        print(f"{Colors.YELLOW}[WARNING]{Colors.RESET} {message}")
    @staticmethod
    def info(message: str):
        print(f"{Colors.BLUE}[INFO]{Colors.RESET} {message}")

# ============================================================================
# VAULT MANAGER
# ============================================================================

class VaultManager:
    """Ansible Vault operations"""
    
    def __init__(self, config: Config):
        self.config = config
        self.vault_file = config.project_root / "group_vars" / "all" / "vault.yml"
    
    def create_vault_file(self, variables: dict, vault_password: str):
        """Create encrypted vault file"""
        temp_file = self.vault_file.with_suffix('.tmp')
        
        # Ensure directory exists
        self.vault_file.parent.mkdir(parents=True, exist_ok=True)
        
        # Write unencrypted content
        with open(temp_file, 'w') as f:
            yaml.dump(variables, f)
        
        # Encrypt with ansible-vault
        cmd = [
            'ansible-vault', 'encrypt',
            str(temp_file),
            '--output', str(self.vault_file)
        ]
        
        # Create password file temporarily
        pass_file = self.config.project_root / ".vault_pass_tmp"
        pass_file.write_text(vault_password)
        
        try:
            cmd.extend(['--vault-password-file', str(pass_file)])
            subprocess.run(cmd, check=True)
        finally:
            temp_file.unlink(missing_ok=True)
            pass_file.unlink(missing_ok=True)
    
    def edit_vault(self, vault_password: str):
        """Edit vault file interactively"""
        if not self.vault_file.exists():
            raise FileNotFoundError(f"Vault file not found: {self.vault_file}")
        
        pass_file = self.config.project_root / ".vault_pass_tmp"
        pass_file.write_text(vault_password)
        
        try:
            cmd = ['ansible-vault', 'edit', str(self.vault_file), '--vault-password-file', str(pass_file)]
            subprocess.run(cmd)
        finally:
            pass_file.unlink(missing_ok=True)
    
    def view_vault(self, vault_password: str) -> dict:
        """View vault contents"""
        if not self.vault_file.exists():
            raise FileNotFoundError(f"Vault file not found: {self.vault_file}")
        
        pass_file = self.config.project_root / ".vault_pass_tmp"
        pass_file.write_text(vault_password)
        
        try:
            cmd = ['ansible-vault', 'view', str(self.vault_file), '--vault-password-file', str(pass_file)]
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            return yaml.safe_load(result.stdout)
        finally:
            pass_file.unlink(missing_ok=True)

# ============================================================================
# PLAYBOOK RUNNER
# ============================================================================

class PlaybookRunner:
    """Execute Ansible playbooks"""
    
    def __init__(self, config: Config):
        self.config = config
    
    def run_playbook(
        self,
        playbook_path: Path,
        inventory: Optional[str] = None,
        extra_vars: Optional[dict] = None,
        limit: Optional[str] = None,
        check_mode: bool = False
    ) -> Tuple[int, str, str]:
        """Run ansible-playbook"""
        
        cmd = ['ansible-playbook', str(playbook_path)]
        
        if inventory:
            cmd.extend(['-i', inventory])
        
        if extra_vars:
            cmd.extend(['-e', json.dumps(extra_vars)])
        
        if limit:
            cmd.extend(['--limit', limit])
        
        if check_mode or self.config.dry_run.enabled:
            cmd.append('--check')
        
        # Add vault password if available
        vault_file = self.config.project_root / "group_vars" / "all" / "vault.yml"
        if vault_file.exists():
            cmd.append('--ask-vault-pass')
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.returncode, result.stdout, result.stderr

# ============================================================================
# ROLE & PLAYBOOK GENERATORS
# ============================================================================

class RoleGenerator:
    """Generate Ansible roles"""
    
    def __init__(self, config: Config):
        self.config = config
    
    def create_role_structure(self, role_name: str) -> Path:
        """Create role directory structure"""
        role_path = self.config.project_root / "roles" / role_name
        
        subdirs = ['tasks', 'handlers', 'templates', 'files', 'vars', 'defaults', 'meta']
        for subdir in subdirs:
            (role_path / subdir).mkdir(parents=True, exist_ok=True)
        
        # Create main.yml files
        (role_path / 'tasks' / 'main.yml').write_text('---\n# Tasks for ' + role_name + '\n')
        (role_path / 'defaults' / 'main.yml').write_text('---\n# Defaults for ' + role_name + '\n')
        (role_path / 'meta' / 'main.yml').write_text('---\ndependencies: []\n')
        
        return role_path

class PlaybookGenerator:
    """Generate playbooks from templates"""
    
    def __init__(self, config: Config):
        self.config = config
    
    def create_lvm_extend_playbook(self) -> Path:
        """Create LVM extension playbook"""
        content = """---
- name: LVM Auto Extension
  hosts: all
  become: true
  gather_facts: true
  
  vars:
    vg_name: "{{ vg_name | mandatory }}"
    lv_name: "{{ lv_name | mandatory }}"
    mount_point: "{{ mount_point | default('/') }}"
    extend_percent: "{{ extend_percent | default(20) }}"
  
  tasks:
    - name: Include LVM inspection role
      include_role:
        name: lvm_system_inspection
    
    - name: Include LVM extension role
      include_role:
        name: lvm_smart_extend
      when: lvm_inspection is defined
"""
        
        playbook_path = self.config.project_root / "playbooks" / "operations" / "lvm_auto_extend.yml"
        playbook_path.parent.mkdir(parents=True, exist_ok=True)
        playbook_path.write_text(content)
        
        return playbook_path

# ============================================================================
# INVENTORY MANAGER
# ============================================================================

from inventory_sources import InventorySourceManager

class InventoryManager:
    """Manage dynamic inventories"""
    
    def __init__(self, config: Config):
        self.config = config
        # delegate inventory source persistence to the extracted manager
        self.sources = InventorySourceManager(getattr(self.config, "project_root", None))
    
    def create_servicenow_inventory(self) -> Path:
        """Create ServiceNow dynamic inventory"""
        content = """---
plugin: servicenow.itsm.now
instance: "{{ lookup('env', 'SNOW_INSTANCE') }}"
username: "{{ lookup('env', 'SNOW_USERNAME') }}"
password: "{{ lookup('env', 'SNOW_PASSWORD') }}"
table: cmdb_ci_linux_server
fields:
  - name
  - ip_address
  - os
  - sys_class_name
compose:
  ansible_host: ip_address
"""
        
        inv_path = self.config.project_root / "inventory" / "servicenow.yml"
        inv_path.parent.mkdir(parents=True, exist_ok=True)
        inv_path.write_text(content)
        
        return inv_path
    
    def create_nutanix_inventory(self) -> Path:
        """Create Nutanix dynamic inventory"""
        content = """---
plugin: nutanix.ncp.ntnx_vms_inventory
nutanix_hostname: "{{ lookup('env', 'NUTANIX_HOST') }}"
nutanix_username: "{{ lookup('env', 'NUTANIX_USERNAME') }}"
nutanix_password: "{{ lookup('env', 'NUTANIX_PASSWORD') }}"
validate_certs: false
compose:
  ansible_host: vm_nics[0].ip_endpoint_list[0].ip
"""
        
        inv_path = self.config.project_root / "inventory" / "nutanix.yml"
        inv_path.parent.mkdir(parents=True, exist_ok=True)
        inv_path.write_text(content)
        
        return inv_path
    
    def create_satellite_inventory(self) -> Path:
        """Create Satellite dynamic inventory"""
        content = """---
plugin: redhat.satellite.foreman
url: "{{ lookup('env', 'SATELLITE_URL') }}"
username: "{{ lookup('env', 'SATELLITE_USERNAME') }}"
password: "{{ lookup('env', 'SATELLITE_PASSWORD') }}"
validate_certs: false
compose:
  ansible_host: ip
"""
        inv_path = self.config.project_root / "inventory" / "satellite.yml"
        inv_path.parent.mkdir(parents=True, exist_ok=True)
        if not inv_path.exists():
            inv_path.write_text(content)
        return inv_path

    def create_aap_inventory(self) -> Path:
        """Create AAP (AWX/Tower) dynamic inventory"""
        content = """---
plugin: awx.awx.tower
host: "{{ lookup('env', 'AAP_HOST') }}"
username: "{{ lookup('env', 'AAP_USERNAME') }}"
password: "{{ lookup('env', 'AAP_PASSWORD') }}"
validate_certs: false
"""
        inv_path = self.config.project_root / "inventory" / "aap.yml"
        inv_path.parent.mkdir(parents=True, exist_ok=True)
        if not inv_path.exists():
            inv_path.write_text(content)
        return inv_path

    def create_insights_inventory(self) -> Path:
        """Create Red Hat Insights dynamic inventory"""
        content = """---
plugin: redhat.insights.insights
username: "{{ lookup('env', 'RH_CDN_USERNAME') }}"
password: "{{ lookup('env', 'RH_CDN_PASSWORD') }}"
org_id: "{{ lookup('env', 'RH_INSIGHTS_ORG_ID') | default(omit) }}"
"""
        inv_path = self.config.project_root / "inventory" / "insights.yml"
        inv_path.parent.mkdir(parents=True, exist_ok=True)
        if not inv_path.exists():
            inv_path.write_text(content)
        return inv_path

    def create_hosts_inventory(self) -> Path:
        """
        Create a static hosts inventory file if missing.
        """
        inv_path = self.config.project_root / "inventory" / "hosts"
        inv_path.parent.mkdir(parents=True, exist_ok=True)
        if not inv_path.exists():
            # Minimal default content
            content = "[all]\nlocalhost ansible_connection=local\n"
            inv_path.write_text(content)
        return inv_path

    def create_all_dynamic_inventories(self):
        """Create all dynamic inventory plugin files if missing"""
        self.create_servicenow_inventory()
        self.create_nutanix_inventory()
        self.create_satellite_inventory()
        self.create_aap_inventory()
        self.create_insights_inventory()

    def write_master_inventory(self, nodes: list) -> None:
        """
        Write a static hosts inventory file based on the provided nodes.
        """
        inv_path = self.config.project_root / "inventory" / "hosts"
        inv_path.parent.mkdir(parents=True, exist_ok=True)
        lines = ["[all]"]
        for node in nodes:
            fqdn = node.get('fqdn', '')
            ip = node.get('ip', '')
            admin_user = node.get('admin_user', '')
            # Compose inventory line
            if fqdn:
                line = fqdn
                if ip:
                    line += f" ansible_host={ip}"
                if admin_user:
                    line += f" ansible_user={admin_user}"
                lines.append(line)
        if len(lines) == 1:
            lines.append("localhost ansible_connection=local")
        inv_path.write_text('\n'.join(lines) + '\n')
