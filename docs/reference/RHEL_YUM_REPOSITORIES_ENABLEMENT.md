# RHEL Yum Repository Enablement for Satellite 6.18

## Overview

Updated the `satellite_content_config` role to automatically enable RHEL yum repositories for all configured products in Satellite 6.18. This ensures that RHEL BaseOS and AppStream repositories are available for content views, lifecycle environments, and activation keys.

## Changes Made

### 1. Updated `defaults/main.yml`

Added new feature toggle and repository sets configuration:

```yaml
# Feature toggles
enable_repository_sets: true

# Repository Sets Configuration - Enable RHEL yum repos for each product
repository_sets_to_enable:
  - name: "Red Hat Enterprise Linux Server (v. 9 for x86_64)"
    product: "Red Hat Enterprise Linux Server"
    basearch: "x86_64"
    releasever: "9"

  - name: "Red Hat Enterprise Linux AppStream (v. 9 for x86_64)"
    product: "Red Hat Enterprise Linux Server"
    basearch: "x86_64"
    releasever: "9"

  - name: "Red Hat Enterprise Linux Server (v. 10 for x86_64)"
    product: "Red Hat Enterprise Linux Server"
    basearch: "x86_64"
    releasever: "10"

  - name: "Red Hat Enterprise Linux AppStream (v. 10 for x86_64)"
    product: "Red Hat Enterprise Linux Server"
    basearch: "x86_64"
    releasever: "10"
```

**Key Variables**:
- `enable_repository_sets`: Toggle to enable/disable repository set enablement (default: `true`)
- `repository_sets_to_enable`: List of official RHEL repository sets to enable for each product

### 2. Updated `tasks/main.yml`

Added new task block "Enable RHEL Repository Sets" that:

1. **Enables official RHEL repository sets** for each product
   - Uses `redhat.scenario_satellite.repository_set` module
   - Automatically enables RHEL 9 and RHEL 10 repository sets
   - Configures basearch (x86_64) and release versions

2. **Displays enabled repositories** with debug output
   - Shows each repository set that was enabled
   - Includes release version for clarity

3. **Verifies repository sets** via API
   - Queries Satellite API to confirm enablement
   - Retrieves product information

4. **Provides summary status** of enabled repositories
   - Lists all enabled RHEL repositories
   - Confirms availability for content views and activation keys

### 3. Updated `README.md`

Enhanced documentation with:

- Added "Repository Sets" to Features section
- New section: "Repository Sets Configuration - Enable RHEL Yum Repositories"
- Updated usage examples showing repository set enablement
- Added option to disable repository sets if needed
- Updated Output section to include repository enablement

## Repositories Enabled

By default, the role now enables:

### RHEL 9 Repositories
-  Red Hat Enterprise Linux Server (v. 9 for x86_64) - **BaseOS**
-  Red Hat Enterprise Linux AppStream (v. 9 for x86_64) - **Applications**

### RHEL 10 Repositories
-  Red Hat Enterprise Linux Server (v. 10 for x86_64) - **BaseOS**
-  Red Hat Enterprise Linux AppStream (v. 10 for x86_64) - **Applications**

## How It Works

### Automatic Enablement Flow

```
satellite_content_config role runs
        ↓
Organizations created (if enabled)
        ↓
Locations created (if enabled)
        ↓
Products created (if enabled)
        ↓
Repositories configured (if enabled)
        ↓
[NEW] RHEL Repository Sets enabled (if enabled_repository_sets: true)
        ↓
Sync Plans configured (if enabled)
        ↓
RHEL yum repos available for:
  - Content Views (scenario_satellite_lifecycle_config)
  - Activation Keys (scenario_satellite_activation_config)
  - Host registration and updates
```

### Task Execution

```
1. Enable RHEL yum repository sets
   - Enables official RHEL Server repos (BaseOS)
   - Enables official RHEL AppStream repos (Applications)
   - Configures for RHEL 9 and RHEL 10
   
2. Display enabled repository sets
   - Shows which repos were successfully enabled
   - Provides release version information
   
3. Verify repository sets via API
   - Queries Satellite to confirm enablement
   - Retrieves product information
   
4. Display summary status
   - Confirms all repos are now available
   - Notes availability for content views and activation keys
```

## Usage

### Default Behavior (Enable RHEL Repositories)

```yaml
- name: Configure Satellite Content with RHEL Repositories
  hosts: scenario_satellite
  roles:
    - role: satellite_content_config
      vars:
        create_organizations: true
        create_locations: true
        enable_repository_sets: true  # Automatically enables RHEL repos
```

### Disable Repository Set Enablement

```yaml
- role: satellite_content_config
  vars:
    create_organizations: true
    create_locations: true
    enable_repository_sets: false  # Skip automatic repo enablement
```

### Enable Only Repository Sets

```yaml
- role: satellite_content_config
  vars:
    create_organizations: false
    create_locations: false
    create_repositories: false
    enable_repository_sets: true  # Only enable RHEL repos
```

## Integration with RHIS Stack

### Complete Content Configuration Workflow

```
1. satellite_6_18_deployment
   ↓ (Deploys Satellite 6.18)
   
2. satellite_content_config [UPDATED]
    Creates organizations
    Creates locations
    Configures products
    Configures repositories
    [NEW] Enables RHEL yum repository sets 
   ↓
   
3. scenario_satellite_lifecycle_config
    Creates lifecycle environments (Dev → Staging → Prod)
    Creates content views
    Filters content (uses RHEL repos )
    Promotes content across environments
   ↓
   
4. scenario_satellite_activation_config
    Creates host collections
    Creates activation keys
    Attaches subscriptions (uses RHEL repos )
    Enables repository sets per key
   ↓
   
5. Hosts register with activation key
   - Automatic repository enablement via key
   - RHEL yum repos available immediately
   - Content accessible from lifecycle environments
```

## Benefits

 **Automated RHEL Repository Setup**
- No manual repository enablement required
- Reduces human error and setup time
- Ensures consistency across environments

 **Full RHEL 9 & RHEL 10 Support**
- BaseOS repositories enabled for both versions
- AppStream repositories enabled for both versions
- Multi-version deployments fully supported

 **Seamless Content Lifecycle Integration**
- Enabled repos automatically available in content views
- Content can be filtered and promoted
- Activation keys automatically have access

 **Time Savings**
- Eliminates manual repository set enablement steps
- Reduces deployment time
- Fewer configuration errors

## Implementation Details

### Repository Set Module Usage

```yaml
- name: Enable RHEL yum repository sets for products
  redhat.scenario_satellite.repository_set:
    name: "{{ item.name }}"                    # Official repo set name
    product: "{{ item.product }}"              # Product name (Red Hat Enterprise Linux Server)
    organization: "{{ satellite_organization }}" # Organization
    basearch: "{{ item.basearch }}"             # Architecture (x86_64)
    releasever: "{{ item.releasever }}"        # Release version (9 or 10)
    state: "enabled"                           # Ensure repos are enabled
    server_url: "{{ satellite_url }}"
    username: "{{ satellite_username }}"
    password: "{{ satellite_password }}"
    validate_certs: "{{ satellite_validate_ssl }}"
```

### State Management

- **State**: `enabled` - Ensures repositories are active
- **Idempotent**: Can be run multiple times safely
- **Non-destructive**: Only enables, doesn't remove existing repos

## Verification

### Check Enabled Repositories in Satellite UI

1. Navigate to: **Content → Products**
2. Select: **Red Hat Enterprise Linux Server**
3. View: **Repository Sets** tab
4. Confirm: RHEL 9 and RHEL 10 repos are **Enabled**

### Check via Satellite API

```bash
curl -k -u admin:password \
  https://scenario_satellite.example.com/api/v2/repository_sets \
  | jq '.results[] | select(.product.name == "Red Hat Enterprise Linux Server")'
```

### Check via Ansible

```yaml
- name: Verify RHEL repositories enabled
  ansible.builtin.uri:
    url: "{{ satellite_url }}/api/v2/repository_sets"
    user: "{{ satellite_username }}"
    password: "{{ satellite_password }}"
    validate_certs: "{{ satellite_validate_ssl }}"
  register: repo_sets
```

## Troubleshooting

### Issue: Repository sets fail to enable

**Solution**: Ensure:
- Red Hat Enterprise Linux Server product exists
- Satellite credentials are correct
- Network connectivity to Satellite
- User has permission to manage repository sets

### Issue: RHEL 10 repos not enabling

**Solution**: Verify:
- RHEL 10 ansible_dev_node_support enabled in Satellite configuration
- Proper repository set name for RHEL 10
- Subscription includes RHEL 10 access

## Files Modified

- `roles/satellite_content_config/defaults/main.yml` - Added repository sets configuration
- `roles/satellite_content_config/tasks/main.yml` - Added Enable RHEL Repository Sets task block
- `roles/satellite_content_config/README.md` - Updated documentation

## Related Roles

- **satellite_6_18_deployment**: Core Satellite installation
- **scenario_satellite_lifecycle_config**: Content views and lifecycle management
- **scenario_satellite_activation_config**: Activation keys and host subscriptions

## Next Steps

1. Customize `repository_sets_to_enable` for additional repositories (if needed)
2. Set `enable_repository_sets: true` in your deployment variables
3. Run satellite_content_config role
4. Verify RHEL repositories are enabled in Satellite UI
5. Use repositories in content views via scenario_satellite_lifecycle_config
6. Create activation keys via scenario_satellite_activation_config with RHEL repos attached

## Summary

The `satellite_content_config` role now automatically enables RHEL yum repositories for all configured products, ensuring RHEL BaseOS and AppStream repositories are available for content views, lifecycle environments, and host registrations. This eliminates manual repository enablement steps and streamlines the Satellite 6.18 configuration process.

**Status**:  Complete and integrated with RHIS stack
