# RedHat_Management

A comprehensive Ansible-based infrastructure orchestration platform for deploying and managing Red Hat enterprise products across cloud and on-premises platforms. It includes role collections for **Foreman/Satellite, Identity Management (FreeIPA/IdM), Ansible Automation Platform (AAP), and OpenShift**, plus supporting infrastructure roles. It supports 15+ deployment scenarios and 7 target platforms (LibVirt/KVM, Baremetal, AWS, Azure, GCP, VMware, Nutanix) via a master orchestration playbook with interactive prompting.

## Top-Level Structure

| Directory | Purpose |
|---|---|
| `roles/` | 170+ Ansible roles: `foreman`, `ansible-freeipa`, `ansible_dev_node_*` (dev environment setup), `platform_*` (cloud/infra provisioning), `scenario_*` (complete deployment scenarios), `integration_*` (third-party integrations like ServiceNow), `idm`, `os_*` (OS-specific config), and compliance roles (`rhel8/9-cis`, `-ospp`, `-stig`, `-pci-dss`) |
| `playbooks/` | Entry points: `orchestration.yml` (full deployment), `satellite_infrastructure_setup.yml`, `provisioning_*` (DNS/DHCP/TFTP/PXE), `network_infrastructure_setup.yml` |
| `inventory/` | `hosts` (static inventory), `hosts.generated` (dynamically generated) |
| `group_vars/` | `all.yml` (global defaults), `all.yml.example` (template), `auto_generated_defaults.yml`, `missing_defaults_*` (debug helpers) |
| `scripts/` | Setup, collection-install, and testing helper scripts |
| `docs/` | Documentation and guides |
| `templates/` | Jinja2 templates for managed configuration files |
| `files/` | Static files distributed to managed nodes |
| `plugins/` | Custom Ansible plugins |
| `ci-cd/` | CI/CD pipeline configuration |
| `reports/` | Deployment reports and outputs |

## Usage

**Quick start**
```bash
make install     # install collections and dependencies
make bootstrap    # install + setup
make site         # run the complete site deployment
```

**Interactive setup (recommended for first-time use)**
```bash
ansible-playbook system_prompts.yml
# Saves your configuration to ~/.ansible/conf/env.yml
```

**Full orchestration with parameters**
```bash
ansible-playbook playbooks/orchestration.yml \
  -e deployment_scenario=satellite_aap \
  -e deployment_platform=aws \
  -e deployment_os=rhel-9 \
  -e install_method=oemdrv
```

**Targeted phase/tag execution**
```bash
ansible-playbook orchestration.yml -t phase1,phase2,phase3
ansible-playbook playbooks/orchestration.yml --tags "scenario_satellite,aws"
```

### Key Variables

- `deployment_scenario` — e.g. `satellite_aap`, `full_stack`, `scenario_openshift`, `scenario_satellite`
- `deployment_platform` — `libvirt`, `aws`, `azure`, `gcp`, `baremetal`, `vmware`, `nutanix`
- `deployment_os` — `rhel-9`, `rhel-10`
- `install_method` — e.g. `oemdrv`, `online`

### Inventory

- Inventory file: `inventory/hosts` or `inventory/hosts.generated`
- Expected groups: `[libvirt]`, `[installer]`, `[scenario_satellite]`, `[aap]`, `[idm]`, etc.
- Hosts need `ansible_host`, `ansible_user`, credentials/SSH keys, and `ansible_become: true`.

## Requirements

**Public collections** (`requirements.yml`): `ansible.posix`, `ansible.netcommon`, `ansible.utils`, `community.general`, `freeipa.ansible_freeipa`, `infra.leapp`

```bash
ansible-galaxy collection install -r requirements.yml
```

**Automation Hub collections** (`requirements_hub.yml`, subscription required) — 25+ collections including `redhat.satellite_operations`, `redhat.rhel_system_roles`, `infra.aap_configuration`, `redhat.insights`, `redhat.{certificates,firewall,logging,monitoring,network_insights,storage,users,workloads}`, and community collections (`community.general`, `community.crypto`, `community.docker`, `community.kubernetes`, `community.hashi_vault`, `community.platform_vmware`)

```bash
ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN=<token> \
  ansible-galaxy collection install -r requirements_hub.yml
```

Python dependencies are managed via `requirements.txt`/`requirements-pip.txt` and installed by `make install`. Ansible ≥2.12 is required.

## Additional Docs

- `PROGRESS.md` — development checkpoint/task tracking
- `README_PROMPTING.md` — guide to the interactive prompting/component-selection system
- `LICENSE` / `LICENSE.APACHE` — Apache 2.0
