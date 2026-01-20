# Role: integration_generic

## Description

The `integration_generic` role orchestrates product-to-product integrations, managing data flow and API connections between Satellite, AAP, IdM, and OpenShift. It enables unified management across the Red Hat platform_infrastructure_core stack.

**Key Responsibility**: Configure and manage product integrations.

## When to Use

- Setting up multi-product environments
- Configuring product authentication/authorization
- Enabling inventory sharing
- Creating unified management experience

## Supported Integrations

### Satellite + AAP
- Satellite as inventory source for AAP
- AAP playbooks for Satellite remediation
- Unified credential management

### Satellite + IdM
- Satellite users from IdM LDAP
- Satellite groups mapped to IdM groups
- Unified authentication

### Satellite + Insights
- Insights data collection
- Predictive analytics
- Automated remediation

### AAP + IdM
- AAP users from IdM LDAP
- Kerberos authentication
- RBAC integrated with IdM

### Insights Integrations
- Automated vulnerability patching
- Compliance monitoring
- Security analytics

### ServiceNow Integration
- Change management workflow
- Ticket automation
- CMDB sync

## Requirements

### Prerequisites
- All products already deployed
- Network connectivity between products
- API credentials configured
- Firewall rules allowing API traffic

## Required Variables

```yaml
deployment_scenario: "satellite_aap"  # Must include products to integrate
```

## Optional Variables

```yaml
# Integration controls
configure_satellite_aap_integration: true
configure_satellite_idm_integration: true
configure_satellite_insights_integration: true
configure_aap_idm_integration: true

# API endpoints
satellite_url: "https://scenario_satellite.example.com"
aap_url: "https://aap.example.com"
idm_url: "https://idm.example.com"

# Credentials (use vault!)
satellite_api_token: "{{ vault_sat_token }}"
aap_api_token: "{{ vault_aap_token }}"
idm_admin_password: "{{ vault_idm_pwd }}"
```

## Usage Examples

### Satellite + AAP Integration
```yaml
- name: Setup Satellite + AAP
  hosts: localhost
  roles:
    - role: integration_generic
      vars:
        deployment_scenario: "satellite_aap"
        satellite_url: "https://scenario_satellite.example.com"
        aap_url: "https://aap.example.com"
```

### Satellite + IdM Integration
```yaml
- name: Setup Satellite + IdM
  hosts: localhost
  roles:
    - role: integration_generic
      vars:
        deployment_scenario: "satellite_idm"
        idm_url: "https://idm.example.com"
```

### Complete Multi-Product Integration
```yaml
- name: Setup All Integrations
  hosts: localhost
  roles:
    - role: integration_generic
      vars:
        deployment_scenario: "satellite_aap_idm_openshift"
```

## Integration Details

### Satellite → AAP
- Satellite provides inventory to AAP
- Hosts automatically discovered
- Grouping by Satellite host groups
- Dynamic inventory updates

### Satellite → IdM
- User authentication via LDAP
- Group membership from IdM
- Automated account platform_provisioning
- SSO capability

### AAP → IdM
- AAP users from IdM LDAP
- RBAC integrated with IdM groups
- Kerberos single sign-on
- Centralized user management

### Insights Integration
- Data collection from products
- Vulnerability analysis
- Compliance reporting
- Remediation automation

## Deployment Flow

1. **Validate Products** - Ensure all products running
2. **Configure Authentication** - Setup API credentials
3. **Enable APIs** - Activate product APIs
4. **Setup Sync** - Configure data synchronization
5. **Test Connectivity** - Verify integration_generic links
6. **Monitor** - Track integration_generic health

## Common Issues & Resolution

### Issue: "Cannot connect to scenario_satellite API"
**Cause**: Network connectivity or API disabled
**Resolution**: Verify Satellite API is enabled, check firewall

### Issue: "LDAP authentication failed"
**Cause**: Incorrect IdM credentials or configuration
**Resolution**: Verify IdM connectivity and credentials

### Issue: "Inventory sync timeout"
**Cause**: Large inventory or slow network
**Resolution**: Increase timeout, verify network bandwidth

### Issue: "Token expired"
**Cause**: API token has expired
**Resolution**: Regenerate and update API token

## Security Considerations

- Store all API tokens in vault
- Use HTTPS/TLS for all API calls
- Implement API rate limiting
- Regular rotation of API keys
- Audit integration_generic logs
- Restrict integration_generic service accounts
- Enable encryption for data in transit

## Monitoring Integration Health

```bash
# Check Satellite inventory sync
hammer settings list | grep inventory_upload

# Verify AAP inventory
awx-manage inventory_source get --name scenario_satellite

# Test IdM LDAP
ldaptest --ldap-type ad
```

## Performance Tuning

```yaml
# For large inventories
satellite_inventory_sync_interval: 3600  # 1 hour
aap_inventory_cache_ttl: 1800            # 30 min
ldap_sync_timeout: 300                   # 5 min
```

## Troubleshooting Checklist

- [ ] All products deployed and operational
- [ ] Network connectivity verified
- [ ] Firewall rules allowing API traffic
- [ ] API credentials configured
- [ ] API endpoints accessible
- [ ] SSL certificates valid
- [ ] Service accounts have proper permissions
- [ ] Integration test connections successful

## Support & Documentation

- See ansible_dev_node_orchestration_master README for ansible_dev_node_orchestration
- See product-specific READMEs for product details
- See integration_generic/*/README.md for integration_generic specifics

## Author

Red Hat Management Team

## License

Apache-2.0
