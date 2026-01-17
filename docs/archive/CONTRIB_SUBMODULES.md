# Contrib Submodules Integration

## Overview
The `contrib/` directory now contains three git submodules that provide reference implementations and building blocks for the RHIS (Red Hat Infrastructure Standard) deployment automation framework.

## Submodules

### 1. rhis-builder
**Source:** https://github.com/parmstro/labbuilder2.git  
**Path:** `contrib/rhis-builder/`  
**Status:** `heads/main`  
**Description:** The main rhis-builder project that provides comprehensive Red Hat environment building capabilities including Satellite, AAP, IdM, and OpenShift deployment patterns.

**Purpose:**
- Reference implementation for multi-product Red Hat deployments
- Lab and demonstration environment building
- Documentation and examples for infrastructure deployment
- Ansible playbooks and roles for product configuration

**Key Resources:**
- Wiki: https://github.com/parmstro/labbuilder2/wiki
- Configuration guides for buildimage variables
- IdM integration patterns
- Satellite configuration examples

### 2. rhis-builder-baremetal-init
**Source:** https://github.com/parmstro/rhis-builder-baremetal-init.git  
**Path:** `contrib/rhis-builder-baremetal-init/`  
**Status:** `v1.0-5-g083ddfb`  
**Description:** Provides baremetal initialization methods for bootstrapping the first IdM and Satellite nodes using OEMDRV/Kickstart automation.

**Purpose:**
- Automated baremetal system builds with kickstart files
- OEMDRV USB drive creation workflows
- Ansible Image Builder integration for automated ISO generation
- BMC-managed boot orchestration

**Key Features:**
- Multiple initialization methods (USB OEMDRV, automated ISO generation)
- Supports RHEL 9+ minimal installations
- Vault-based credential management
- Integration with rhis-builder-inventory

**Related Projects:**
- rhis-provisioner-container: https://github.com/parmstro/rhis-provisioner-container
- rhis-builder-inventory: https://github.com/parmstro/rhis-builder-inventory

### 3. rhis-builder-inventory
**Source:** https://github.com/parmstro/rhis-builder-inventory.git  
**Path:** `contrib/rhis-builder-inventory/`  
**Status:** `heads/main`  
**Description:** Centralized inventory and configuration repository for all rhis-builder-* projects, providing unified variable management and secrets definitions.

**Purpose:**
- Unified configuration management across all rhis-builder projects
- Centralized secrets and vault definitions
- Sample configurations and deployment scenarios
- Variable inheritance and precedence management

**Key Features:**
- Group and host variable organization
- Vault file management for credentials
- Scenario-based configurations
- Integration point for all rhis-builder components

## Usage

### Clone with Submodules
To clone this repository with all submodules initialized:
```bash
git clone --recursive https://github.com/your-org/RedHat_Management.git
```

### Update Submodules
To pull the latest changes from all submodule sources:
```bash
git submodule update --remote
```

### Update Specific Submodule
```bash
cd contrib/rhis-builder
git pull origin main
cd ../..
```

### Initialize Submodules (if cloning without --recursive)
```bash
git submodule update --init --recursive
```

## Integration with RHIS Deployment Framework

The contrib/ submodules provide:

1. **Reference Implementations:** Examples of complete RHIS deployments
2. **Building Blocks:** Reusable roles, playbooks, and templates
3. **Best Practices:** Documented patterns for Red Hat infrastructure
4. **Community Contributions:** Access to rhis-builder ecosystem projects

## Development Workflow

### Working with Submodules
1. Navigate to the submodule directory: `cd contrib/rhis-builder`
2. Create a branch for your work: `git checkout -b feature/my-change`
3. Make changes and commit: `git add . && git commit -m "..."`
4. Push to your fork and create a PR
5. Once merged, return to parent: `cd ../..`
6. Stage the submodule change: `git add contrib/rhis-builder`
7. Commit in parent: `git commit -m "Update rhis-builder submodule"`

### Updating Submodules
To pull latest changes from all submodule repositories:
```bash
git pull
git submodule update --remote
git commit -m "Update contrib submodules to latest"
git push
```

## Credentials and Security

The rhis-builder projects use vault-encrypted files for credentials:
- Store vault files outside the repository
- Use `.gitignore` to exclude `vault.yml` and `*-vault.yml`
- Reference vault locations in documentation
- Implement secret scanning where possible

## Additional Resources

- **labbuilder2 Wiki:** https://github.com/parmstro/labbuilder2/wiki
- **rhis-provisioner-container:** https://github.com/parmstro/rhis-provisioner-container
- **Main RHIS Documentation:** See `docs/deployment/` directory

## Troubleshooting

### Submodule Not Updating
```bash
git submodule update --remote --merge
```

### Detached HEAD in Submodule
```bash
cd contrib/rhis-builder
git checkout main
cd ../..
```

### Clean Submodule State
```bash
git submodule deinit -f --all
git submodule update --init --recursive
```

## References

- .gitmodules configuration: Root `.gitmodules` file
- Submodule status: `git submodule status`
- Submodule log: `git log --oneline --all -- contrib/`

---
**Last Updated:** January 16, 2026  
**Status:** Active - All three submodules configured and current
