# Scripts Organization

This directory contains utility scripts organized by function and purpose.

## Directory Structure

### 📁 [setup/](setup/) - Installation & Initialization
Main deployment and configuration scripts.

- **RHIS-installer.sh** - Primary deployment orchestrator supporting 15 scenarios and 7 platforms
- **run_setup.sh** - Initial environment setup and validation
- **generate_ansible_cfg.py** - Generates ansible.cfg from templates
- **configure_aap_inventory.py** - Creates and configures AAP inventory

**Usage:**
```bash
./setup/RHIS-installer.sh          # Main deployment
./setup/run_setup.sh               # Setup environment
```

---

### 📁 [containers/](containers/) - Container Management
Unified container operations for Docker/Podman.

- **container_manager.sh** - Consolidated container utility with subcommands:
  - `pull [version]` - Pull and tag containers
  - `run` - Run container with mounted volumes
  - `export [version]` - Export container to tar archive

**Usage:**
```bash
./containers/container_manager.sh pull          # Pull both versions
./containers/container_manager.sh pull 2.5      # Pull specific version
./containers/container_manager.sh run -g /path/to/group_vars -s /path/to/secrets
./containers/container_manager.sh export 2.4    # Export to tar
```

---

### 📁 [libvirt/](libvirt/) - VM & Hypervisor Management
KVM/libvirt virtual machine utilities.

- **libvirt_vm_helper.sh** - Interactive VM management utilities
  - List, info, console, IP retrieval
  - Start, stop, delete VMs
  - Clone, snapshot, resize operations
  
- **libvirt_vm_provisioner.py** - Automated VM provisioning
  
- **create_libvirt_vm_from_iso.sh** - Create VMs from ISO images

**Usage:**
```bash
./libvirt/libvirt_vm_helper.sh list                    # List VMs
./libvirt/libvirt_vm_helper.sh console rhel10-vm       # Connect to console
./libvirt/libvirt_vm_helper.sh ip rhel10-vm            # Get IP address
./libvirt/libvirt_vm_helper.sh clone source dest       # Clone VM
```

---

### 📁 [maintenance/](maintenance/) - Maintenance & Repair
Playbook and configuration fixup utilities.

- **fixup_playbooks.py** - Consolidated fixup utility with subcommands:
  - `convert-fqcn` - Convert Ansible modules to FQCN format
  - `wrap-lines` - Wrap long lines and remove blank lines
  - `add-pipefail` - Add `set -o pipefail` to shell blocks
  - `remove-blanks` - Remove blank-only lines from YAML
  
- **convert_rhis_templates.py** - Convert and process Jinja2 templates
  
- **update_ansible_token.py** - Update Ansible authentication tokens

**Usage:**
```bash
./maintenance/fixup_playbooks.py convert-fqcn     # Convert to FQCN
./maintenance/fixup_playbooks.py wrap-lines       # Wrap long lines
./maintenance/fixup_playbooks.py add-pipefail     # Add pipefail
./maintenance/fixup_playbooks.py remove-blanks    # Remove blank lines
```

---

### 📁 [utilities/](utilities/) - Testing & Validation
Testing, validation, and helper utilities.

- **validate-reorganization.sh** - Validate directory reorganization
  
- **test_api.sh** - API endpoint testing utilities
  
- **update.sh** - General update and maintenance script
  
- **kickstart_http_server.py** - HTTP server for serving kickstart files

**Usage:**
```bash
./utilities/validate-reorganization.sh   # Validate structure
./utilities/test_api.sh                  # Run API tests
./utilities/kickstart_http_server.py     # Start HTTP server
./utilities/update.sh                    # Run updates
```

---

## Quick Reference

| Task | Script |
|------|--------|
| Deploy infrastructure | `setup/RHIS-installer.sh` |
| Manage containers | `containers/container_manager.sh` |
| Manage VMs | `libvirt/libvirt_vm_helper.sh` |
| Fix playbooks | `maintenance/fixup_playbooks.py` |
| Validate setup | `utilities/validate-reorganization.sh` |

## Help

Most scripts support `--help` or `-h` flag for detailed usage information:

```bash
./setup/RHIS-installer.sh --help
./containers/container_manager.sh help
./libvirt/libvirt_vm_helper.sh help
./maintenance/fixup_playbooks.py --help
```
