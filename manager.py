#!/usr/bin/env python3
"""
Consolidated manager for Add_LVM_to_System_nutanix.
Run: python3 manager.py
"""
from pathlib import Path
from typing import Dict, List, Optional
import os
import yaml
import json
import shutil
import subprocess
import getpass

ROOT = Path(__file__).resolve().parent
ENV_FILE = Path.home() / ".lvm_automation_env"
INVENTORY_DIR = ROOT / "inventory"
GROUP_VARS_DIR = ROOT / "group_vars" / "all"
MASTER_VARS_FILE = GROUP_VARS_DIR / "master_vars.yml"
VAULT_FILE = GROUP_VARS_DIR / "vault.yml"
HOSTS_FILE = INVENTORY_DIR / "hosts"
PY_BACKUP = ROOT / "py_backup"

class UI:
    """Minimal UI helper (clear, header, confirm-like prompts, status helpers)."""
    def clear(self):
        try:
            os.system("clear")
        except Exception:
            pass

    def header(self, title: str):
        print("\n" + "=" * 70)
        print(f"  {title}")
        print("=" * 70 + "\n")

    def confirm(self, prompt: str, default: bool = False) -> bool:
        return ask_yesno(prompt, default=default)

    def info(self, msg: str):
        print(f"[INFO] {msg}")

    def warning(self, msg: str):
        print(f"[WARNING] {msg}")

    def success(self, msg: str):
        print(f"[OK] {msg}")

    def pause(self):
        input("Press [Enter] to continue...")

# instantiate UI
ui = UI()

def ask_yesno(prompt: str, default: bool = False) -> bool:
    yn = "Y/n" if default else "y/N"
    resp = input(f"{prompt} [{yn}]: ").strip().lower()
    if not resp:
        return default
    return resp in ("y", "yes")

def ask_build_or_connect(component: str, default: str = "connect") -> str:
    prompt = f"  Type 'build' to build a new {component} node or 'connect' to connect to an existing one [{default}]: "
    while True:
        resp = input(prompt).strip().lower()
        if not resp:
            return default
        if resp in ("build", "connect"):
            return resp
        print("  Invalid choice, enter 'build' or 'connect'.")

def ensure_dirs():
    INVENTORY_DIR.mkdir(parents=True, exist_ok=True)
    GROUP_VARS_DIR.mkdir(parents=True, exist_ok=True)
    PY_BACKUP.mkdir(parents=True, exist_ok=True)

def save_env(env: Dict):
    try:
        with open(ENV_FILE, "w") as fh:
            json.dump(env, fh, indent=2)
        os.chmod(ENV_FILE, 0o600)
        ui.success(f"Saved env to: {ENV_FILE}")
    except Exception as e:
        ui.warning(f"Failed to save env file: {e}")

def write_hosts(nodes: List[Dict]):
    ensure_dirs()
    lines = ["[all]"]
    for n in nodes:
        fqdn = n.get("fqdn", "")
        ip = n.get("ip", "")
        user = n.get("admin_user", "")
        if fqdn:
            line = fqdn
            if ip:
                line += f" ansible_host={ip}"
            if user:
                line += f" ansible_user={user}"
            lines.append(line)
    if len(lines) == 1:
        lines.append("localhost ansible_connection=local")
    HOSTS_FILE.write_text("\n".join(lines) + "\n")
    ui.success(f"Wrote inventory hosts: {HOSTS_FILE}")

def write_master_vars(env: Dict, nodes: List[Dict], integrations: Dict):
    ensure_dirs()
    master = {
        "nodes": nodes,
        "integrations": integrations,
        "env": {k: v for k, v in env.items() if not k.endswith(("_PASSWORD", "_TOKEN", "_SECRET"))}
    }
    MASTER_VARS_FILE.write_text(yaml.safe_dump(master, default_flow_style=False))
    ui.success(f"Wrote master vars: {MASTER_VARS_FILE}")

def write_vault(secrets: Dict):
    ensure_dirs()
    if not secrets:
        if VAULT_FILE.exists():
            ui.info(f"vault file exists: {VAULT_FILE}")
        else:
            ui.info("No sensitive secrets collected; vault not written.")
        return
    VAULT_FILE.write_text(yaml.safe_dump(secrets, default_flow_style=False))
    try:
        os.chmod(VAULT_FILE, 0o600)
    except Exception:
        pass
    ui.success(f"Wrote vault (plaintext, chmod 600): {VAULT_FILE}")
    av = shutil.which("ansible-vault")
    if av and ask_yesno("ansible-vault is installed. Encrypt vault.yml now with ansible-vault (will prompt)?", default=True):
        try:
            subprocess.run([av, "encrypt", str(VAULT_FILE)], check=False)
            ui.success("ansible-vault encrypt invoked (follow prompts).")
        except Exception as e:
            ui.warning(f"ansible-vault encrypt failed: {e}")

def backup_py_files(keep: Optional[List[str]] = None):
    ensure_dirs()
    # keep is typed as List[str]; avoid assigning a set to it.
    keep_set = set(keep or [])
    for p in ROOT.glob("*.py"):
        if p.name in keep_set or p.name == Path(__file__).name:
            continue
        target = PY_BACKUP / p.name
        try:
            shutil.move(str(p), str(target))
            ui.success(f"{p.name} -> py_backup/{p.name}")
        except Exception as e:
            ui.warning(f"Failed to move {p.name}: {e}")

def run_playbook():
    pb = input("Playbook path (relative to project root): ").strip()
    if not pb:
        print("No playbook specified.")
        return
    pb_path = (ROOT / pb).resolve()
    if not pb_path.exists():
        print(f"Playbook not found: {pb_path}")
        return
    inv = input("Inventory file (leave empty for inventory/hosts): ").strip()
    inv_path = (ROOT / inv).resolve() if inv else HOSTS_FILE
    extra = input("Extra vars as JSON (optional): ").strip()
    cmd = ["ansible-playbook", str(pb_path), "-i", str(inv_path)]
    if extra:
        cmd += ["--extra-vars", extra]
    print(f"[RUN] {' '.join(cmd)}")
    try:
        subprocess.run(cmd, check=False)
    except FileNotFoundError:
        print("[ERROR] ansible-playbook not found on PATH.")
    except Exception as e:
        print(f"[ERROR] playbook run failed: {e}")

def edit_vault():
    default = Path.home() / ".vault" / "vault.yml"
    resp = input(f"Path to vault file [{default}]: ").strip()
    vault_path = Path(resp).expanduser().resolve() if resp else default
    vault_path.parent.mkdir(parents=True, exist_ok=True)
    av = shutil.which("ansible-vault")
    if not vault_path.exists():
        # create securely if no ansible-vault
        if av:
            try:
                subprocess.run([av, "create", str(vault_path)], check=False)
                return
            except Exception:
                pass
        vault_path.write_text("# ansible vault secrets\n")
        vault_path.chmod(0o600)
        ui.success(f"Created vault file: {vault_path}")
    # open with ansible-vault if available and file looks encrypted, else open with $EDITOR
    def is_encrypted(p: Path) -> bool:
        try:
            with open(p, "r", errors="ignore") as fh:
                first = fh.readline()
                return "ANSIBLE_VAULT" in first or first.lstrip().startswith("$ANSIBLE_VAULT")
        except Exception:
            return False
    if av:
        if is_encrypted(vault_path):
            subprocess.run([av, "edit", str(vault_path)], check=False)
            return
        else:
            if ask_yesno("File exists and is not encrypted. Encrypt now with ansible-vault?", default=False):
                try:
                    subprocess.run([av, "encrypt", str(vault_path)], check=False)
                    subprocess.run([av, "edit", str(vault_path)], check=False)
                    return
                except Exception:
                    ui.warning("ansible-vault steps failed; falling back to editor.")
    editor = os.environ.get("EDITOR", shutil.which("vi") or "vi")
    try:
        subprocess.run([editor, str(vault_path)], check=False)
    except Exception as e:
        print(f"[ERROR] Failed to launch editor: {e}")

def setup_wizard():
    ui.header("Setup Nodes and Variables")
    env = {}
    nodes = []
    integrations = {}
    secrets = {}

    # Satellite
    if ui.confirm("Do you want to build or connect to a Satellite node?", default=True):
        integrations['satellite'] = True
        action = ask_build_or_connect("Satellite", default="connect")
        ip = input("  What is the Satellite node IP? ").strip()
        fqdn = input("  What is the Satellite node FQDN [default: satellite.example.com]: ").strip() or "satellite.example.com"
        user = input("  Satellite admin username [default: admin]: ").strip() or "admin"
        pwd = getpass.getpass("  Satellite admin password (hidden) [default: REMOVED_EXAMPLE_PASSWORD]: ").strip() or "REMOVED_EXAMPLE_PASSWORD"
        # Satellite provisioning details
        sat_org = input("  Satellite Organization (for provisioning) [optional]: ").strip()
        sat_hostgroup = input("  Satellite Hostgroup [optional]: ").strip()
        sat_compute = input("  Satellite Compute resource name (libvirt/AWS/etc) [optional]: ").strip()
        sat_activation = getpass.getpass("  Satellite Activation Key (hidden) [optional]: ").strip()
        sat_ssh_pub = input("  Satellite SSH public key (for provisioning) [optional]: ").strip()
        sat_domain = input("  Satellite domain [optional]: ").strip()
        sat_subnet = input("  Satellite subnet name [optional]: ").strip()
        sat_partition = input("  Satellite partition [optional]: ").strip()
        sat_content_view = input("  Satellite Content View [optional]: ").strip()
        sat_lifecycle = input("  Satellite Lifecycle Environment [optional]: ").strip()
        env.update({
            "SATELLITE_ACTION": action,
            "SATELLITE_URL": fqdn,
            "SATELLITE_USERNAME": user,
            "SATELLITE_ORG": sat_org,
            "SATELLITE_HOSTGROUP": sat_hostgroup,
            "SATELLITE_COMPUTE_RESOURCE": sat_compute,
            "SATELLITE_DOMAIN": sat_domain,
            "SATELLITE_SUBNET": sat_subnet,
            "SATELLITE_PARTITION": sat_partition,
            "SATELLITE_CONTENT_VIEW": sat_content_view,
            "SATELLITE_LIFECYCLE_ENV": sat_lifecycle,
            "SATELLITE_SSH_PUBLIC_KEY": sat_ssh_pub
        })
        secrets["SATELLITE_PASSWORD"] = pwd
        if sat_activation:
            secrets["SATELLITE_ACTIVATION_KEY"] = sat_activation
        nodes.append({"role": "satellite", "fqdn": fqdn, "ip": ip, "admin_user": user, "action": action})
    else:
        integrations['satellite'] = False
        env["SATELLITE_ACTION"] = "skip"

    # Nutanix
    if ui.confirm("Do you want to build or connect to a Nutanix server?", default=False):
        integrations['nutanix'] = True
        action = ask_build_or_connect("Nutanix", default="connect")
        nx_ip = input("  Nutanix server IP: ").strip()
        nx_fqdn = input("  Nutanix FQDN [default: nutanix.example.com]: ").strip() or "nutanix.example.com"
        nx_user = input("  Nutanix admin username [default: admin]: ").strip() or "admin"
        nx_pwd = getpass.getpass("  Nutanix admin password (hidden): ").strip() or "REMOVED_EXAMPLE_PASSWORD"
        # optional nutanix settings
        nx_cluster = input("  Nutanix Cluster IP/hostname [optional]: ").strip()
        nx_project = input("  Nutanix project name/ID [optional]: ").strip()
        env.update({"NUTANIX_ACTION": action, "NUTANIX_HOST": nx_ip, "NUTANIX_USERNAME": nx_user, "NUTANIX_CLUSTER": nx_cluster})
        secrets["NUTANIX_PASSWORD"] = nx_pwd
        if nx_project:
            env["NUTANIX_PROJECT"] = nx_project
        nodes.append({"role": "nutanix", "fqdn": nx_fqdn, "ip": nx_ip, "admin_user": nx_user, "action": action})
    else:
        integrations['nutanix'] = False
        env["NUTANIX_ACTION"] = "skip"

    # ServiceNow
    if ui.confirm("Do you want to configure ServiceNow integration?", default=False):
        integrations['servicenow'] = True
        sn_user = input("  ServiceNow username [default: admin]: ").strip() or "admin"
        sn_pwd = getpass.getpass("  ServiceNow password or API token (hidden): ").strip() or "REMOVED_EXAMPLE_PASSWORD"
        sn_instance = input("  ServiceNow instance name (e.g., dev12345): ").strip()
        sn_api = input("  ServiceNow API URL base [optional]: ").strip() or (f"https://{sn_instance}.service-now.com" if sn_instance else "")
        env.update({"SNOW_INSTANCE": sn_instance, "SNOW_USERNAME": sn_user, "SNOW_API_URL": sn_api})
        secrets["SNOW_PASSWORD"] = sn_pwd
    else:
        integrations['servicenow'] = False
        env["SNOW_SKIP"] = True

    # Red Hat Insights (connect)
    if ui.confirm("Do you want to configure Red Hat Insights (connect)?", default=False):
        integrations['insights'] = True
        rh_user = input("  Insights username: ").strip()
        rh_pwd = getpass.getpass("  Insights password (hidden): ").strip()
        rh_org = input("  Insights organization ID [optional]: ").strip()
        rh_token = getpass.getpass("  Insights token for ansible.cfg (hidden) [optional]: ").strip()
        env.update({"RH_CDN_USERNAME": rh_user, "RH_INSIGHTS_ORG_ID": rh_org})
        secrets["RH_CDN_PASSWORD"] = rh_pwd
        if rh_token:
            secrets["INSIGHTS_TOKEN"] = rh_token
    else:
        integrations['insights'] = False

    # GitHub
    if ui.confirm("Do you want to build or connect to a GitHub target (repo/runner)?", default=False):
        integrations['github'] = True
        gh_action = ask_build_or_connect("GitHub target", default="connect")
        gh_repo = input("  Repository URL (optional): ").strip()
        gh_user = input("  GitHub Username: ").strip()
        gh_token = getpass.getpass("  GitHub Personal Access Token (hidden): ").strip()
        env.update({"GITHUB_ACTION": gh_action, "GITHUB_USERNAME": gh_user})
        if gh_repo:
            env["GITHUB_REPO"] = gh_repo
        secrets["GITHUB_TOKEN"] = gh_token
        if gh_action == "build":
            env["GITHUB_TARGET_IP"] = input("  Target IP for GitHub runner: ").strip()
            env["GITHUB_TARGET_HOSTNAME"] = input("  Target hostname for GitHub runner: ").strip()
            env["GITHUB_SSH_USER"] = input("  Target SSH user for runner [default: root]: ").strip() or "root"
            env["GITHUB_SSH_KEY_PATH"] = input("  Path to SSH private key for runner (if building): ").strip()
    else:
        integrations['github'] = False

    # AAP
    if ui.confirm("Do you want to build or connect to an Ansible Automation Platform instance?", default=False):
        integrations['aap'] = True
        aap_action = ask_build_or_connect("Ansible Automation Platform", default="connect")
        if aap_action == "connect":
            aap_host = input("  AAP Host (url): ").strip()
            aap_user = input("  AAP Username: ").strip()
            aap_pwd = getpass.getpass("  AAP Password (hidden): ").strip()
            aap_verify = input("  Verify SSL for AAP? [true/false] [default: true]: ").strip().lower() or "true"
            env.update({"AAP_ACTION": aap_action, "AAP_HOST": aap_host, "AAP_USERNAME": aap_user, "AAP_VERIFY_SSL": aap_verify})
            secrets["AAP_PASSWORD"] = aap_pwd
        else:
            env.update({"AAP_ACTION": aap_action, "AAP_BUILD_IP": input("  AAP target IP: ").strip(), "AAP_BUILD_FQDN": input("  AAP target FQDN: ").strip()})
    else:
        integrations['aap'] = False
        env["AAP_ACTION"] = "skip"

    # Automation Hub (cloud) & local hub
    if ui.confirm("Do you want to configure Automation Hub (cloud) or local Automation Hub?", default=False):
        integrations['ahub'] = True
        ahub_token = getpass.getpass("  Automation Hub Token (hidden): ").strip()
        ahub_url = input("  Automation Hub URL [leave blank for cloud default]: ").strip() or "https://console.redhat.com/api/automation-hub/"
        ahub_admin = input("  Local Automation Hub admin username [optional]: ").strip()
        ahub_admin_pass = getpass.getpass("  Local Automation Hub admin password (hidden) [optional]: ").strip()
        env.update({"ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_URL": ahub_url, "AHUB_URL": ahub_url, "AHUB_ADMIN_USER": ahub_admin})
        secrets["ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN"] = ahub_token
        if ahub_admin_pass:
            secrets["AHUB_ADMIN_PASSWORD"] = ahub_admin_pass
    else:
        integrations['ahub'] = False

    # EDA
    if ui.confirm("Do you want to configure EDA (Event-Driven Automation)?", default=False):
        integrations['eda'] = True
        eda_url = input("  EDA Controller URL: ").strip()
        eda_user = input("  EDA Username: ").strip()
        eda_pass = getpass.getpass("  EDA Password (hidden): ").strip()
        eda_api_token = getpass.getpass("  EDA API token (hidden) [optional]: ").strip()
        env.update({"EDA_URL": eda_url, "EDA_USERNAME": eda_user})
        secrets["EDA_PASSWORD"] = eda_pass
        if eda_api_token:
            secrets["EDA_API_TOKEN"] = eda_api_token
    else:
        integrations['eda'] = False

    # Cloud providers
    if ui.confirm("Will you provision resources in AWS via Satellite/Foreman?", default=False):
        integrations['aws'] = True
        aws_key = input("  AWS Access Key ID: ").strip()
        aws_secret = getpass.getpass("  AWS Secret Access Key (hidden): ").strip()
        aws_region = input("  AWS Region [default: us-east-1]: ").strip() or "us-east-1"
        aws_vpc = input("  AWS VPC ID [optional]: ").strip()
        aws_subnet = input("  AWS Subnet ID [optional]: ").strip()
        aws_sgs = input("  AWS Security Group IDs (comma separated) [optional]: ").strip()
        aws_keypair = input("  AWS Key Pair name (public key must exist in cloud) [optional]: ").strip()
        aws_ami = input("  AWS AMI ID to use [optional]: ").strip()
        aws_instance_type = input("  AWS instance type [optional]: ").strip()
        env.update({"AWS_ACCESS_KEY_ID": aws_key, "AWS_REGION": aws_region, "AWS_VPC_ID": aws_vpc, "AWS_SUBNET_ID": aws_subnet, "AWS_SECURITY_GROUP_IDS": aws_sgs, "AWS_KEY_PAIR_NAME": aws_keypair, "AWS_AMI_ID": aws_ami, "AWS_INSTANCE_TYPE": aws_instance_type})
        secrets["AWS_SECRET_ACCESS_KEY"] = aws_secret
    else:
        integrations['aws'] = False

    if ui.confirm("Will you provision resources in GCP via Satellite/Foreman?", default=False):
        integrations['gcp'] = True
        gcp_proj = input("  GCP Project ID: ").strip()
        gcp_sa = input("  GCP Service Account JSON path or content: ").strip()
        gcp_region = input("  GCP Region/Zone [optional]: ").strip()
        gcp_image = input("  GCP Image name [optional]: ").strip()
        env.update({"GCP_PROJECT_ID": gcp_proj, "GCP_SERVICE_ACCOUNT_JSON": gcp_sa, "GCP_REGION": gcp_region, "GCP_IMAGE": gcp_image})
    else:
        integrations['gcp'] = False

    if ui.confirm("Will you provision resources in Azure via Satellite/Foreman?", default=False):
        integrations['azure'] = True
        az_client = input("  Azure Client ID: ").strip()
        az_secret = getpass.getpass("  Azure Secret (hidden): ").strip()
        az_tenant = input("  Azure Tenant ID: ").strip()
        az_sub = input("  Azure Subscription ID: ").strip()
        az_rg = input("  Azure Resource Group [optional]: ").strip()
        az_loc = input("  Azure Location [optional]: ").strip()
        env.update({"AZURE_CLIENT_ID": az_client, "AZURE_TENANT": az_tenant, "AZURE_SUBSCRIPTION_ID": az_sub, "AZURE_RESOURCE_GROUP": az_rg, "AZURE_REGION": az_loc})
        secrets["AZURE_SECRET"] = az_secret
    else:
        integrations['azure'] = False

    # VMware / vSphere
    if ui.confirm("Will you provision resources in VMware vSphere (vCenter/ESXi) via Satellite/Foreman?", default=False):
        integrations['vmware'] = True
        vm_host = input("  vCenter/ESXi host or FQDN: ").strip()
        vm_user = input("  vSphere username: ").strip()
        vm_pass = getpass.getpass("  vSphere password (hidden): ").strip()
        vm_datacenter = input("  vSphere Datacenter [optional]: ").strip()
        vm_cluster = input("  vSphere Cluster name [optional]: ").strip()
        vm_datastore = input("  vSphere Datastore [optional]: ").strip()
        vm_network = input("  vSphere Network/Portgroup [optional]: ").strip()
        vm_thumbprint = input("  vSphere SSL thumbprint (optional): ").strip()
        # persist
        env.update({
            "VMWARE_HOST": vm_host,
            "VMWARE_DATACENTER": vm_datacenter,
            "VMWARE_CLUSTER": vm_cluster,
            "VMWARE_DATASTORE": vm_datastore,
            "VMWARE_NETWORK": vm_network,
            "VMWARE_SSL_THUMBPRINT": vm_thumbprint
        })
        # keep credentials in vault/secrets
        secrets["VMWARE_USERNAME"] = vm_user
        secrets["VMWARE_PASSWORD"] = vm_pass
    else:
        integrations['vmware'] = False

    # Libvirt
    if ui.confirm("Do you want to configure libvirt as a compute resource?", default=False):
        integrations['libvirt'] = True
        lib_action = ask_build_or_connect("libvirt compute", default="connect")
        lib_uri = input("  Libvirt connection URI (e.g., qemu+ssh://root@host/system): ").strip()
        lib_ssh = input("  Path to libvirt SSH private key (used by Satellite compute resource): ").strip()
        lib_storage = input("  Libvirt storage pool name [optional]: ").strip()
        lib_network = input("  Libvirt network name [optional]: ").strip()
        lib_image = input("  Libvirt cloud image path or name [optional]: ").strip()
        # Satellite needs the public key string to create guests
        sat_libvirt_pub = input("  Satellite libvirt SSH public key (paste or path) [optional]: ").strip()
        env.update({"LIBVIRT_ACTION": lib_action, "LIBVIRT_URI": lib_uri, "LIBVIRT_SSH_KEY_PATH": lib_ssh, "LIBVIRT_STORAGE_POOL": lib_storage, "LIBVIRT_NETWORK": lib_network, "LIBVIRT_IMAGE_PATH": lib_image})
        if sat_libvirt_pub:
            env["SATELLITE_LIBVIRT_SSH_PUB"] = sat_libvirt_pub
    else:
        integrations['libvirt'] = False

    # Additional common vars
    default_admin = input("Default admin username [default: admin]: ").strip() or "admin"
    default_admin_pass = getpass.getpass("Default admin password (hidden) [default: REMOVED_EXAMPLE_PASSWORD]: ").strip() or "REMOVED_EXAMPLE_PASSWORD"
    env.update({"DEFAULT_ADMIN_USER": default_admin})
    secrets["DEFAULT_ADMIN_PASSWORD"] = default_admin_pass

    # Persist everything
    save_env(env)
    write_hosts(nodes)
    write_master_vars(env, nodes, integrations)
    write_vault(secrets)

    # write role defaults for roles consumption by playbooks
    try:
        write_role_defaults(nodes)
    except Exception:
        pass

    # run preflight check and pause
    preflight_check(env)
    ui.success("Setup wizard completed.")
    ui.pause()

def show_menu():
    while True:
        ui.header("LVM Automation Manager")
        print("  1. Setup Nodes and Variables (wizard)")
        print("  2. Edit vault")
        print("  3. Run Ansible playbook")
        print("  4. Backup other .py files to py_backup/")
        print("  0. Quit")
        choice = input("\nSelect option: ").strip()
        if choice == "1":
            setup_wizard()
        elif choice == "2":
            edit_vault()
        elif choice == "3":
            run_playbook()
        elif choice == "4":
            keep = [Path(__file__).name, "run_aap.py", "manager.py"]
            backup_py_files(keep=keep)
            ui.pause()
        elif choice == "0":
            print("Exiting.")
            return
        else:
            print("Invalid option.")

# === begin: embedded aap_lvm_pkg/config.py contents ===
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
    def __init__(self, config_path: Optional[Path] = None):
        self.config_manager = ConfigFileManager(config_path=config_path)
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
# === end: embedded config classes ===

if __name__ == "__main__":
    try:
        show_menu()
    except KeyboardInterrupt:
        print("\nInterrupted, exiting.")