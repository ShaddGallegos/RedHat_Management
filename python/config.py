import os
from pathlib import Path
from typing import Optional
import yaml

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