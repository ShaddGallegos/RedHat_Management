# Getting Started - Quick Start Guide

Get started with RHIS deployment in 30 minutes.

## Prerequisites

- RHEL 9.x system with 64GB RAM, 16+ CPU cores, 1TB+ storage
- Network connectivity and sudo access
- Basic Linux/Ansible knowledge helpful

## 5-Step Quick Start

### Step 1: Clone the Project (2 min)

```bash
git clone <repository-url> rhis
cd rhis
```

### Step 2: Configure Environment (5 min)

```bash
# Copy example environment
mkdir -p ~/.ansible/conf && cp env.yml.example ~/.ansible/conf/env.yml

# Edit with your settings
vi ~/.ansible/conf/env.yml

# Key variables to set:
# - deployment_scenario: satellite-only, aap-only, or full-stack
# - infrastructure_platform: libvirt, aws, azure, gcp
# - network configuration: IP ranges, DNS, etc.
```

### Step 3: Validate Setup (3 min)

```bash
# Check ansible installation
ansible --version

# Validate inventory
ansible-inventory -i inventory/hosts -y | head

# Syntax check playbooks
ansible-playbook redhat_management-site.yml --syntax-check
```

### Step 4: Run Deployment (15 min)

```bash
# Interactive deployment with RHIS-installer
./scripts/setup/RHIS-installer.sh

# Or direct deployment
ansible-playbook redhat_management-site.yml

# Monitor progress
tail -f logs/deployment.log
```

### Step 5: Verify Deployment (5 min)

```bash
# Check system status
ansible all -m ping

# Access deployed systems
# AAP: https://aap-host
# Satellite: https://satellite-host
# IdM: https://idm-host
```

## Common Scenarios

### Scenario: Satellite-Only

```bash
# Set scenario in your local ~/.ansible/conf/env.yml
deployment_scenario: satellite-only

# Deploy
ansible-playbook redhat_management-site.yml -t satellite
```

### Scenario: AAP-Only  

```bash
# Set scenario in your local ~/.ansible/conf/env.yml
deployment_scenario: aap-only

# Deploy
ansible-playbook redhat_management-site.yml -t aap
```

### Scenario: Full Stack

```bash
# Set scenario in your local ~/.ansible/conf/env.yml
deployment_scenario: full-stack

# Deploy all products
ansible-playbook redhat_management-site.yml
```

## Deployment on Different Platforms

### LibVirt (Local)

```bash
# Use local KVM virtualization
infrastructure_platform: libvirt

# Deploy with RHIS-installer
./scripts/setup/RHIS-installer.sh
```

### AWS

```bash
# Use AWS cloud platform
infrastructure_platform: aws

# Set AWS credentials
export AWS_ACCESS_KEY_ID=xxxx
export AWS_SECRET_ACCESS_KEY=xxxx

# Deploy
ansible-playbook redhat_management-site.yml
```

### Azure

```bash
# Use Azure cloud platform
infrastructure_platform: azure

# Set Azure credentials
ansible-playbook redhat_management-site.yml -e azure_subscription_id=xxxx
```

## Troubleshooting Quick Fixes

| Issue | Solution |
|-------|----------|
| Ansible not found | `pip install ansible` |
| Python version error | Use Python 3.9+ |
| SELinux issues | Set to permissive or disabled |
| Network unreachable | Check firewall and routing |
| Out of disk space | Ensure 1TB+ available |
| Out of memory | Need minimum 64GB RAM |

## Next Steps

After successful deployment:

1. **Access Systems**: Use credentials from deployment output
2. **Configure Products**: See product-specific guides in [Products](../products/)
3. **Run Playbooks**: Execute custom playbooks in [Playbooks](../playbooks/)
4. **Monitor Systems**: Set up monitoring in [Operations](../operations/)
5. **Read Full Docs**: See complete guides in [Getting Started](../getting-started/)

## Support

- Check [Troubleshooting](../troubleshooting/)
- Review [Reference](../reference/)
- Consult logs in `logs/` directory

---

**Time Estimate:** 30 minutes  
**Difficulty:** Intermediate
