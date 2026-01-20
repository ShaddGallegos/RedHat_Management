# Role: ansible_dev_node_redhat_products/idm

## Description

The `ansible_dev_node_redhat_products/idm` role orchestrates the deployment of Red Hat Identity Management (IdM) 3.0+. It coordinates directory services, Kerberos authentication, certificate management, DNS integration_generic, and replication setup.

**Key Responsibility**: Deploy and configure IdM for centralized identity and access management.

## When to Use

- Deploying centralized identity services
- Kerberos authentication platform_infrastructure_core
- Certificate authority setup
- User and group management
- Integration with LDAP/Active Directory

## Features

- **Directory Services**: LDAP-based identity management
- **Kerberos Authentication**: Secure authentication protocol
- **Certificate Authority**: Internal CA for certificates
- **DNS Integration**: Integrated DNS management
- **Replication**: Multi-server replication ansible_dev_node_support
- **Integration**: LDAP integration_generic capabilities

## Requirements

### System Requirements
- **CPU**: 4 cores minimum (8+ for HA)
- **Memory**: 8 GB minimum (16+ for HA)
- **Disk**: 50 GB minimum
- **OS**: RHEL 9 or RHEL 10

### Network Requirements
- Ports: 80, 443, 389, 636, 88, 464, 53
- Proper DNS configuration
- Forward and reverse DNS resolution
- Kerberos realm setup

## Required Variables

```yaml
deployment_scenario: "idm_only"  # IdM in scenario
```

## Optional Variables

```yaml
# IdM controls
configure_idm_integration: true    # Setup integrations
deploy_idm_replicas: false         # Deploy replica servers

# IdM configuration
idm_realm: "EXAMPLE.COM"           # Kerberos realm
idm_domain: "example.com"          # DNS domain
idm_hostname: "idm.example.com"    # IdM server FQDN
idm_admin_password: "{{ vault_idm_pwd }}"  # Admin password (vault!)
idm_directory_manager_pwd: "{{ vault_dm_pwd }}"  # DM password (vault!)

# Replication (if deploy_idm_replicas: true)
idm_replica_hostnames:
  - "idm-replica1.example.com"
  - "idm-replica2.example.com"

# Certificate settings
idm_ca_cn: "Certificate Authority"
idm_cert_validity: 3650  # Days

# User/Group defaults
create_default_users: true
create_default_groups: true
```

## Usage Examples

### Basic IdM Deployment
```yaml
- name: Deploy IdM
  hosts: localhost
  roles:
    - role: ansible_dev_node_redhat_products/idm
      vars:
        deployment_scenario: "idm_only"
        idm_realm: "EXAMPLE.COM"
        idm_domain: "example.com"
        idm_admin_password: "{{ vault_idm_admin_pwd }}"
```

### IdM with Replication
```yaml
- name: Deploy IdM HA
  hosts: localhost
  roles:
    - role: ansible_dev_node_redhat_products/idm
      vars:
        deployment_scenario: "idm_only"
        deploy_idm_replicas: true
        idm_replica_hostnames:
          - "idm-replica1.example.com"
          - "idm-replica2.example.com"
```

### IdM with Satellite Integration
```yaml
- name: Deploy IdM + Satellite
  hosts: localhost
  roles:
    - role: ansible_dev_node_redhat_products/idm
      vars:
        deployment_scenario: "satellite_idm"
        configure_idm_integration: true
```

## Deployment Flow

1. **Validate DNS/Domain** - Verify DNS configuration
2. **Deploy Base** - Core IdM services
3. **Configure Kerberos** - Kerberos realm setup
4. **Configure Certificate Authority** - CA initialization
5. **Deploy Replicas** (optional) - Multi-master replication
6. **Configure Integrations** - LDAP integrations
7. **Health Validation** - Verify all components

## Supported Scenarios

- `idm_only` - IdM standalone
- `satellite_idm` - Satellite + IdM
- `aap_idm` - AAP + IdM
- `idm_openshift` - IdM + OpenShift
- All multi-product scenarios containing IdM

## Output

- IdM web UI accessible at `https://{{ idm_hostname }}`
- Kerberos realm configured
- Certificate authority operational
- LDAP directory functional
- Replicas synchronized (if deployed)

## Dependencies

| Role | Purpose |
|------|---------|
| ansible_dev_node_deployment_setup | Initialize environment |
| platform_infrastructure_manager | Provision platform_infrastructure_core |
| os_generic | Configure OS |
| integration_generic/satellite_idm | Satellite integration_generic |

## Common Issues & Resolution

### Issue: "DNS resolution failed"
**Cause**: DNS not properly configured
**Resolution**: Configure forward and reverse DNS records

### Issue: "Kerberos realm creation failed"
**Cause**: Invalid realm name or domain
**Resolution**: Verify FQDN and realm match domain

### Issue: "Replica sync failed"
**Cause**: Network connectivity or replication agreement
**Resolution**: Check network, verify replica credentials

### Issue: "Certificate generation failed"
**Cause**: Invalid certificate parameters
**Resolution**: Verify CA settings and validity dates

## User Management

```bash
# Add user
ipa user-add john.doe --first John --last Doe

# Add to group
ipa group-add-member admins --users john.doe

# Generate OTP
ipa user-add-otp john.doe
```

## Replication Strategy

For high availability:
1. Deploy primary IdM server
2. Add 1-2 replica servers
3. Configure load balancer
4. Monitor replication status
5. Regular backup of all servers

## Security Considerations

- Store all passwords in Ansible vault
- Use HTTPS/TLS for all connections
- Implement strong Kerberos policies
- Regular backup of IdM database
- Monitor audit logs
- Update IdM regularly
- Enforce password complexity
- Enable 2FA for admin accounts

## Monitoring & Troubleshooting

**Check Status**:
```bash
ipactl status
```

**View Directory Entries**:
```bash
ldapsearch -H ldap://{{ idm_hostname }} -x -b "dc=example,dc=com"
```

**Verify Kerberos**:
```bash
kinit admin
klist
```

**Check Replication**:
```bash
ipa replica-manage list
```

## Performance Considerations

- Base deployment: 15-20 minutes
- Replica deployment: 10-15 minutes per replica
- Certificate operations: < 1 minute
- User sync (first time): Varies by user count

## Support & Documentation

- Red Hat IdM Documentation: https://access.redhat.com/documentation/identity_management/
- Kerberos: https://web.mit.edu/kerberos/
- See ansible_dev_node_orchestration_master README for integration_generic

## Author

Red Hat Management Team

## License

Apache-2.0
