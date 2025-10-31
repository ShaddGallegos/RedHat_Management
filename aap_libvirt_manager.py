from pathlib import Path
import subprocess
import webbrowser
import os
import sys

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
    def __init__(self, testall_mode=False):
        self.testall_mode = testall_mode

    @staticmethod
    def header(title):
        print(f"\n{Colors.CYAN}{'='*70}{Colors.RESET}")
        print(f"{Colors.CYAN} {title:^66}{Colors.RESET}")
        print(f"{Colors.CYAN}{'='*70}{Colors.RESET}\n")

    def pause(self):
        if self.testall_mode:
            return
        input(f"\n{Colors.YELLOW}Press [Enter] to continue...{Colors.RESET}")

    @staticmethod
    def success(message):
        print(f"{Colors.GREEN}[OK]{Colors.RESET} {message}")

    @staticmethod
    def error(message):
        print(f"{Colors.RED}[ERROR]{Colors.RESET} {message}")

    @staticmethod
    def warning(message):
        print(f"{Colors.YELLOW}[WARNING]{Colors.RESET} {message}")

class ProjectManager:
    def __init__(self, base_folder):
        self.base_folder = Path(base_folder)
        self.roles = [
            "prework",
            "aap",
            "satellite",
            "libvirt",
            "insights",
            "integration"
        ]
        self.plugins = [
            "dynamic_inventory_libvirt.py",
            "dynamic_inventory_satellite.py",
            "dynamic_inventory_aap.py",
            "dynamic_inventory_insights.py"
        ]
        self.ui = UI()

    def create_project_structure(self):
        folders = ["roles", "playbooks", "inventory", "plugins", "templates", "docs"]
        for folder in folders:
            path = self.base_folder / folder
            path.mkdir(parents=True, exist_ok=True)
            self.ui.success(f"Ensured folder: {path}")
        for role in self.roles:
            role_path = self.base_folder / "roles" / role / "tasks"
            role_path.mkdir(parents=True, exist_ok=True)
            main_yml = role_path / "main.yml"
            if not main_yml.exists():
                with open(main_yml, "w") as f:
                    f.write(f"# tasks for {role}\n")
                self.ui.success(f"Created: {main_yml}")
        for plugin in self.plugins:
            plugin_path = self.base_folder / "plugins" / plugin
            if not plugin_path.exists():
                with open(plugin_path, "w") as f:
                    f.write("# Dynamic inventory plugin stub\n")
                self.ui.success(f"Created: {plugin_path}")
        playbook_examples = {
            "prework.yml": "prework",
            "aap_install.yml": "aap",
            "satellite_install.yml": "satellite",
            "libvirt_setup.yml": "libvirt",
            "insights_setup.yml": "insights",
            "integration.yml": "integration"
        }
        for pb_name, role in playbook_examples.items():
            pb_path = self.base_folder / "playbooks" / pb_name
            if not pb_path.exists():
                with open(pb_path, "w") as f:
                    f.write(f'''---\n- hosts: localhost\n  roles:\n    - {role}\n''')
                self.ui.success(f"Created: {pb_path}")

    def show_roles(self):
        self.ui.header("Available Roles")
        for role in self.roles:
            print(f"- {role}")
        self.ui.pause()

    def show_plugins(self):
        self.ui.header("Available Dynamic Inventory Plugins")
        for plugin in self.plugins:
            print(f"- {plugin}")
        self.ui.pause()

    def open_docs(self):
        doc_path = self.base_folder / "docs" / "REQUIREMENTS.md"
        if doc_path.exists():
            os.system(f"less {doc_path}")
        else:
            self.ui.error("REQUIREMENTS.md not found.")
        self.ui.pause()

    def open_redhat_downloads(self):
        self.ui.header("Opening Red Hat Downloads Page")
        webbrowser.open("https://access.redhat.com/downloads/")
        self.ui.success("Red Hat Downloads page opened in your default browser.")
        self.ui.pause()

    def show_requirements_menu(self):
        self.ui.header("Product Requirements & Architecture Diagrams")
        print("  1. Ansible Automation Platform 2.6")
        print("  2. Red Hat Satellite 6.17")
        print("  3. OpenShift 4.20")
        print("  4. Ansible Development Node")
        print("  0. Back to Main Menu")
        choice = input("Select product to view details: ").strip()
        if choice == '1':
            self.show_aap_requirements()
        elif choice == '2':
            self.show_satellite_requirements()
        elif choice == '3':
            self.show_openshift_requirements()
        elif choice == '4':
            self.show_ansible_dev_requirements()
        elif choice == '0':
            return
        else:
            self.ui.warning("Invalid option")
            self.ui.pause()

    def show_aap_requirements(self):
        self.ui.header("Ansible Automation Platform 2.6 Requirements & Architecture")
        print("""
+-----------------------------+
|     Control Node (RHEL)     |
|-----------------------------|
| - Automation Controller     |
| - Execution Environment     |
| - PostgreSQL Database       |
| - Automation Hub (optional) |
| - Automation Mesh (optional)|
| - Event-Driven Ansible (EDA)|
+-----------------------------+

         |
         | (Containerized services via Podman or Docker)
         v

+-----------------------------+
|     Local or Remote Hosts   |
|-----------------------------|
| - Target systems for playbooks |
+-----------------------------+

Minimum System Requirements:
- OS: RHEL 8.6+ or RHEL 9.2+
- CPU: 4 vCPUs
- RAM: 16 GB
- Disk: 100 GB SSD
- Network: 1 Gbps NIC (External), 2 Gbps NIC (Internal)
- Container Engine: Podman 4.6+
Additional: NTP, Firewall (80,443,5432,22), SELinux enforcing, Red Hat subscription
""")
        self.ui.pause()

    def show_satellite_requirements(self):
        self.ui.header("Red Hat Satellite 6.17 Requirements & Architecture")
        print("""
+-----------------------------+
|     Satellite Server        |
|-----------------------------|
| - Capsule Server (optional)|
| - PostgreSQL Database       |
| - Redis (for Smart Proxy)  |
| - Ansible (for remote tasks)|
+-----------------------------+

         |
         | (Managed via Satellite)
         v

+-----------------------------+
|     Managed Hosts           |
|-----------------------------|
| - Physical or Virtual machines |
| - RHEL 8.6+ / RHEL 9.2+    |
+-----------------------------+

Minimum System Requirements:
- OS: RHEL 8.6+ or RHEL 9.2+ (for Satellite and managed hosts)
- CPU: 4 vCPUs (Satellite), 2 vCPUs (managed hosts)
- RAM: 16 GB (Satellite), 4 GB (managed hosts)
- Disk: 100 GB SSD (Satellite), 20 GB free (managed hosts)
- Network: 1 Gbps NIC (Satellite), Internet access (managed hosts)
- Container Engine: Podman 4.6+ (optional, for containerized Satellite components)
Additional: NTP, Firewall (80,443,5432,22), SELinux enforcing, Red Hat subscription
""")
        self.ui.pause()

    def show_openshift_requirements(self):
        self.ui.header("OpenShift 4.20 Requirements & Architecture")
        print("""
+---------------------+       +---------------------+       +---------------------+
|  Control Plane Node |       |  Control Plane Node |       |  Control Plane Node |
|     (Master #1)     |       |     (Master #2)     |       |     (Master #3)     |
|  etcd + API + Core  |       |  etcd + API + Core  |       |  etcd + API + Core  |
+---------------------+       +---------------------+       +---------------------+
          |                           |                             |
          v                           v                             v
+---------------------+       +---------------------+
|     Worker Node     |       |     Worker Node     |
|   (App workloads)   |       |   (App workloads)   |
+---------------------+       +---------------------+

External Load Balancer (optional for HA)
Bootstrap Node (temporary, used during install)

Minimum System Requirements:
Control Plane: 4 vCPU, 16 GB RAM, 120 GB SSD, 1 Gbps NIC
Worker: 2 vCPU, 8 GB RAM, 120 GB SSD, 1 Gbps NIC
Bootstrap: Same as control plane
Networking: DHCP/static IPs, DNS, Load balancer
Storage: Local/NFS, optional CSI drivers
""")
        self.ui.pause()

    def show_ansible_dev_requirements(self):
        self.ui.header("Ansible Development Node Requirements & Architecture")
        print("""
+-----------------------------+
|     Ansible Dev Node       |
|-----------------------------|
| - RHEL / Fedora / Ubuntu   |
| - Python 3.x               |
| - python3-pip              |
| - ansible-core             |
| - ansible-lint             |
| - ansible-dev-tools        |
| - Git                      |
| - SSH client               |
+-----------------------------+
            |
            | SSH
            v
+-----------------------------+
|     Target Host(s)         |
|-----------------------------|
| - Any SSH-accessible host  |
| - Python (optional)        |
| - Inventory defined        |
+-----------------------------+

Minimum System Requirements:
- OS: RHEL 8.6+ / RHEL 9.2+
- CPU: 2 vCPUs
- RAM: 4 GB
- Disk: 20 GB free
- Network: Internet access
Required Packages: python3, python3-pip, ansible-core, ansible-lint, ansible-dev-tools, git, openssh-clients
""")
        self.ui.pause()

class MenuSystem:
    def __init__(self, pm, testall_mode=False):
        self.pm = pm
        self.testall_mode = testall_mode
        self.ui = UI(testall_mode=testall_mode)
        self.running = True

    def preflight_checks_and_node_building(self):
        self.ui.header("Preflight Checks & Node Building Automation")
        print("This will check system requirements and simulate node creation based on selected integrations.")
        print("Select integrations for node building (comma separated):")
        print("  AWS, GCP, Azure, VMware, Nutanix, Libvirt, Vagrant, Bare Metal, Insights, EDA")
        if self.testall_mode:
            integrations = ['aws','gcp','azure','vmware','nutanix','libvirt','vagrant','baremetal','insights','eda']
        else:
            integrations = input("Enter integrations: ").lower().replace(' ', '').split(',')
        valid = {'aws', 'gcp', 'azure', 'vmware', 'nutanix', 'libvirt', 'vagrant', 'baremetal', 'insights', 'eda'}
        selected = [i for i in integrations if i in valid]
        if not selected:
            self.ui.warning("No valid integrations selected.")
            self.ui.pause()
            return
        print("\nChecking system requirements for each integration (with +10% best practice buffer):")
        requirements = {
            'aws': {'CPU': 4, 'RAM': 16, 'Disk': 110},
            'gcp': {'CPU': 4, 'RAM': 16, 'Disk': 110},
            'azure': {'CPU': 4, 'RAM': 16, 'Disk': 110},
            'vmware': {'CPU': 4, 'RAM': 16, 'Disk': 110},
            'nutanix': {'CPU': 4, 'RAM': 16, 'Disk': 110},
            'libvirt': {'CPU': 4, 'RAM': 16, 'Disk': 110},
            'vagrant': {'CPU': 2, 'RAM': 4, 'Disk': 22},
            'baremetal': {'CPU': 4, 'RAM': 16, 'Disk': 110},
            'insights': {'CPU': 2, 'RAM': 4, 'Disk': 22},
            'eda': {'CPU': 2, 'RAM': 4, 'Disk': 22}
        }
        for i in selected:
            req = requirements[i]
            print(f"- {i.title()}: CPU={int(req['CPU']*1.1)} vCPUs, RAM={int(req['RAM']*1.1)} GB, Disk={int(req['Disk']*1.1)} GB")
        print("\nSimulating node creation...")
        for i in selected:
            print(f"Creating node for {i.title()} with best practice specs...")
        self.ui.success("Preflight checks and node building simulation complete.")
        self.ui.pause()

# Main entry point
if __name__ == "__main__":
    base_folder = os.getcwd()
    pm = ProjectManager(base_folder)
    menu = MenuSystem(pm)
    while menu.running:
        print(f"\n{Colors.BOLD}{Colors.CYAN}Red Hat PoC Automation Menu{Colors.RESET}")
        print("  1. Product Requirements & Architecture Diagrams")
        print("  2. Preflight Checks & Node Building")
        print("  3. Show Roles")
        print("  4. Show Plugins")
        print("  5. Open Documentation")
        print("  6. Open Red Hat Downloads")
        print("  0. Exit")
        choice = input("Select an option: ").strip()
        if choice == "1":
            pm.show_requirements_menu()
        elif choice == "2":
            menu.preflight_checks_and_node_building()
        elif choice == "3":
            pm.show_roles()
        elif choice == "4":
            pm.show_plugins()
        elif choice == "5":
            pm.open_docs()
        elif choice == "6":
            pm.open_redhat_downloads()
        elif choice == "0":
            menu.running = False
        else:
            menu.ui.warning("Invalid option")
            menu.ui.pause()