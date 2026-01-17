# AAP Configuration Roles - Implementation Summary

## Overview

Created 4 comprehensive roles for Ansible Automation Platform (AAP) configuration to manage all aspects of RHIS deployments.

## Roles Created

### 1. aap_credentials_config
**Purpose**: Manage all credential types in AAP

**Capabilities**:
- Machine Credentials (SSH keys, sudo configuration)
- Vault Credentials (Ansible vault integration)
- Registry Credentials (Container registry access)
- Satellite Credentials (Satellite API access)
- Cloud Credentials (AWS, Azure, GCP)
- Network Credentials (optional)

**Key Features**:
- Automatic credential creation and validation
- SSH key file reading and injection
- Vault password integration
- Connection testing
- Detailed summary reporting

**Default Credentials Configured**:
- `RHIS_SSH_Key` - SSH key for Ansible user
- `RHIS_Root_SSH` - Root SSH for privileged operations
- `RHIS_Vault` - Ansible vault credentials
- `RedHat_Registry` - Red Hat registry credentials
- `Satellite_API` - Satellite API credentials

**Files**:
- `meta/main.yml` - Role metadata
- `defaults/main.yml` - Configurable defaults (15+ variables)
- `tasks/main.yml` - Implementation (6 task blocks)
- `README.md` - Complete documentation
- `tests/test_role.yml` - Test validation

---

### 2. aap_inventories_config
**Purpose**: Configure static and dynamic inventories in AAP

**Capabilities**:
- Static Inventories (manual host/group definitions)
- Dynamic Inventories (auto-populated from sources)
- Inventory Sources (Satellite, AWS, project sync)
- Inventory Variables (per-inventory configurations)
- Inventory Synchronization

**Key Features**:
- Multiple inventory creation
- Dynamic source integration
- Variable inheritance
- Inventory import/sync
- Coverage reporting

**Default Inventories Configured**:
- `RHIS_Infrastructure` - Main infrastructure inventory
- `Satellite_Hosts` - Satellite server inventory
- `AAP_Controllers` - AAP controller nodes
- `Satellite_Sync` - Dynamic Satellite inventory
- `AWS_Dynamic` - Dynamic AWS inventory
- Inventory sources for project sync

**Files**:
- `meta/main.yml` - Role metadata
- `defaults/main.yml` - Configurable defaults (12+ variables)
- `tasks/main.yml` - Implementation (4 task blocks)
- `README.md` - Complete documentation
- `tests/test_role.yml` - Test validation

---

### 3. aap_projects_config
**Purpose**: Configure projects (playbook repositories) in AAP

**Capabilities**:
- Git Projects (GitHub, GitLab, Gitea repositories)
- Manual Projects (locally uploaded playbooks)
- Project Synchronization (on-launch or manual)
- Branch Management
- Credential Support

**Key Features**:
- Repository authentication
- Automatic project sync
- Branch tracking
- Multiple git project support
- Sync status monitoring

**Default Projects Configured**:
- `RHIS_Playbooks` - Main RHIS playbook repository
- `Satellite_Playbooks` - Satellite management playbooks
- `IdM_Playbooks` - Identity Management automation
- `AAP_Playbooks` - AAP deployment and configuration
- `Infrastructure_Playbooks` - Infrastructure provisioning
- `RHIS_Local` - Manual/local playbooks

**Files**:
- `meta/main.yml` - Role metadata
- `defaults/main.yml` - Configurable defaults (15+ variables)
- `tasks/main.yml` - Implementation (3 task blocks)
- `README.md` - Complete documentation
- `tests/test_role.yml` - Test validation

---

### 4. aap_templates_config
**Purpose**: Configure job and workflow templates in AAP

**Capabilities**:
- Job Templates (single playbook execution)
- Workflow Templates (multi-step orchestration)
- Workflow Nodes (workflow step definitions)
- Execution Parameters (verbosity, limits, tags)
- Prompt Options (ask on launch)
- Extra Variables Support

**Key Features**:
- Complete job template configuration
- Workflow orchestration setup
- Credential/inventory/project linking
- Execution customization
- Template validation

**Default Job Templates Configured**:
- `RHIS_Deploy_Infrastructure` - Infrastructure deployment
- `RHIS_Configure_Satellite` - Satellite configuration
- `RHIS_Setup_AAP` - AAP setup
- `RHIS_Configure_IdM` - Identity Management configuration
- `RHIS_Provision_Infrastructure` - Infrastructure provisioning

**Default Workflow Templates Configured**:
- `RHIS_Complete_Deployment` - Full deployment workflow
- `RHIS_Infrastructure_Setup` - Infrastructure setup workflow
- `RHIS_Product_Deployment` - Product deployment workflow

**Files**:
- `meta/main.yml` - Role metadata
- `defaults/main.yml` - Configurable defaults (20+ variables)
- `tasks/main.yml` - Implementation (4 task blocks)
- `README.md` - Complete documentation
- `tests/test_role.yml` - Test validation

---

## Configuration Integration

### Usage in Site Playbook

```yaml
- name: Configure AAP for RHIS
  hosts: aap_controllers
  roles:
    # First configure credentials
    - role: aap_credentials_config
      vars:
        aap_url: "https://aap.prod.example.com"
        aap_username: "admin"
        aap_password: "{{ vault_aap_admin_password }}"
        create_machine_credentials: true
        create_vault_credentials: true
        create_registry_credentials: true
        create_satellite_credentials: true

    # Then configure inventories
    - role: aap_inventories_config
      vars:
        aap_url: "https://aap.prod.example.com"
        create_static_inventories: true
        create_dynamic_inventories: true
        create_inventory_sources: true

    # Then configure projects
    - role: aap_projects_config
      vars:
        aap_url: "https://aap.prod.example.com"
        create_git_projects: true
        create_manual_projects: true
        aap_projects_sync_on_create: true

    # Finally configure templates
    - role: aap_templates_config
      vars:
        aap_url: "https://aap.prod.example.com"
        create_job_templates: true
        create_workflow_templates: true
```

### Execution Order

1. **aap_credentials_config** - Create all credentials first
2. **aap_inventories_config** - Create inventories
3. **aap_projects_config** - Setup projects with repositories
4. **aap_templates_config** - Create templates that reference above

This order ensures all dependencies are met before template creation.

---

## Variables and Customization

### Credentials Configuration

**Machine Credentials**:
```yaml
machine_credentials:
  - name: "RHIS_SSH_Key"
    username: "ansible"
    ssh_key_data: "~/.ssh/id_rsa"
    become_method: "sudo"
    tags: ["rhis", "machine"]
```

**Vault Credentials**:
```yaml
vault_credentials:
  - name: "RHIS_Vault"
    vault_password: "{{ vault_aap_vault_password }}"
```

**Registry Credentials**:
```yaml
registry_credentials:
  - name: "RedHat_Registry"
    host: "registry.redhat.io"
    username: "{{ rhel_subscription_username }}"
    password: "{{ vault_rhel_subscription_password }}"
```

### Inventory Configuration

**Static Inventories**:
```yaml
static_inventories:
  - name: "RHIS_Infrastructure"
    description: "RHIS infrastructure hosts"
    variables:
      ansible_connection: "ssh"
      ansible_user: "ansible"
```

**Dynamic Inventories**:
```yaml
dynamic_inventories:
  - name: "Satellite_Sync"
    source: "satellite"
    source_vars:
      satellite_host: "satellite.example.com"
```

### Project Configuration

**Git Projects**:
```yaml
git_projects:
  - name: "RHIS_Playbooks"
    scm_url: "https://github.com/example/rhis.git"
    scm_branch: "main"
    update_on_launch: true
```

### Template Configuration

**Job Templates**:
```yaml
job_templates:
  - name: "RHIS_Deploy_Infrastructure"
    inventory: "RHIS_Infrastructure"
    project: "RHIS_Playbooks"
    playbook: "playbooks/deploy_components.yml"
    credential: "RHIS_SSH_Key"
    tags: ["rhis", "deploy"]
```

---

## Security Considerations

1. **Credentials Management**
   - All passwords stored in Ansible vault
   - SSH keys read from secure locations
   - No credentials logged or displayed

2. **Access Control**
   - Credentials organized by organization
   - Inventory access per organization
   - Template permissions enforced

3. **Vault Integration**
   - Vault credential support for all templates
   - Encrypted variable passing
   - Password protection for sensitive data

---

## Validation & Testing

Each role includes:
- **Connectivity validation** - AAP API connectivity check
- **Token extraction** - OAuth token generation
- **Organization lookup** - Verify target organization
- **Resource creation** - API calls for resource creation
- **Summary reporting** - List all created resources
- **Test validation** - Test files for CI/CD integration

---

## Dependencies

**External Requirements**:
- AAP 2.6+ running and accessible
- AAP admin credentials
- SSH keys available (for machine credentials)
- Git repositories accessible (for projects)
- Valid inventory data sources

**Role Dependencies**:
- None (AAP must be pre-deployed)
- aap_2_6_setup (recommended as prerequisite)

---

## API Integration

All roles use AAP REST API v2:
- Authentication: Token-based
- Content-Type: application/json
- Error Handling: HTTP status code validation
- Logging: No-log for sensitive data

### API Endpoints Used

- `/api/v2/auth/token/` - Authentication
- `/api/v2/organizations/` - Organization lookup
- `/api/v2/credentials/` - Credential management
- `/api/v2/inventories/` - Inventory management
- `/api/v2/projects/` - Project management
- `/api/v2/job_templates/` - Job template management
- `/api/v2/workflow_job_templates/` - Workflow management

---

## Output & Reporting

Each role provides:
1. **Creation Summary** - List of created resources
2. **Resource Count** - Total number of resources
3. **Validation Checks** - Pass/fail status
4. **Debug Information** - Detailed resource details
5. **Error Handling** - Clear error messages

---

## Files Created

**Total**: 20 files across 4 roles
- 4 meta/main.yml (metadata)
- 4 defaults/main.yml (variables)
- 4 tasks/main.yml (implementation)
- 4 README.md (documentation)
- 4 tests/test_role.yml (validation)

---

## Integration with RHIS

These roles complete the RHIS automation stack by enabling:

1. **Full Lifecycle Management** - From infrastructure to application
2. **Multi-Product Support** - Satellite, AAP, IdM, OpenShift
3. **Automated Provisioning** - Complete deployment automation
4. **Configuration Management** - All product configurations
5. **Orchestrated Workflows** - Multi-step deployment workflows

---

## Next Steps

1. **Configure Vault Variables**:
   ```yaml
   vault_aap_admin_password: "{{ vault value }}"
   vault_rhel_subscription_password: "{{ vault value }}"
   vault_satellite_api_password: "{{ vault value }}"
   ```

2. **Setup Git Repositories**:
   - Update scm_url for your Git repositories
   - Ensure branches exist (main/develop)
   - Configure read access credentials if needed

3. **Customize Credentials**:
   - Update SSH key paths
   - Add additional credential types as needed
   - Configure cloud credentials if using clouds

4. **Define Inventories**:
   - Add specific hosts/groups to inventories
   - Configure dynamic source variables
   - Update inventory variable templates

5. **Execute Configuration**:
   ```bash
   ansible-playbook playbooks/deploy_components.yml \
     --tags aap_credentials \
     --tags aap_inventories \
     --tags aap_projects \
     --tags aap_templates
   ```

---

## Author

Red Hat Management Team

## License

Apache-2.0

## Version

1.0 - Initial AAP Configuration Roles
