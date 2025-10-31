# Red Hat Collection Setup Instructions

## For Red Hat Enterprise Environments

If you have a Red Hat subscription, you should use Red Hat Certified Collections for better support and integration.

### Step 1: Get Your API Token

1. Go to <https://console.redhat.com/ansible/automation-hub/token>
2. Copy your API token

### Step 2: Configure Authentication

#### Option A: Command Line

```bash
ansible-galaxy collection install -r requirements.yml \
 --api-key YOUR_API_TOKEN \
 -s https://console.redhat.com/api/automation-hub/
```

#### Option B: Configure ansible.cfg

```ini
[galaxy]
server_list = automation_hub, community

[galaxy_server.automation_hub]
url=https://console.redhat.com/api/automation-hub/
token=YOUR_API_TOKEN

[galaxy_server.community]
url=https://galaxy.ansible.com/
```

### Step 3: Install Collections

```bash
# Install all collections (community + Red Hat certified)
ansible-galaxy collection install -r requirements.yml

# Or install only essential collections
ansible-galaxy collection install \
 community.general \
 nutanix.ncp \
 ansible.posix \
 ansible.eda \
 redhat.rhel_system_roles \
 redhat.insights
```

### Priority Collections for LVM Automation

#### Essential (Required)

- `community.general` - Mail, LVM, partitioning modules
- `nutanix.ncp` - Nutanix API integration
- `ansible.posix` - System operations
- `ansible.eda` - Event Driven Ansible

#### Recommended for Enterprise

- `redhat.rhel_system_roles` - RHEL management and system roles
- `redhat.insights` - System insights and recommendations

#### Optional (Based on Environment)

- `servicenow.itsm` - ServiceNow integration for tickets
- `redhat.satellite` - Satellite-managed systems
- `ansible.controller` - Automation Controller features

### Benefits of Red Hat Certified Collections

1. **Enterprise Support** - Backed by Red Hat support
2. **Security** - Regular security updates and patches
3. **Stability** - Tested with Red Hat products
4. **Integration** - Better integration with RHEL, Satellite, etc.
5. **Documentation** - Enterprise-grade documentation

### For Non-Red Hat Environments

If you don't have Red Hat subscriptions, the community collections will work fine:

```bash
ansible-galaxy collection install \
 community.general \
 nutanix.ncp \
 ansible.posix \
 ansible.eda
```

The LVM automation system will work with either community or Red Hat certified collections.
