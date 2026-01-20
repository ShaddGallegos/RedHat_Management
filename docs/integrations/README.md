# Product Integration Guide

## Integration Architecture

```
┌─────────────────────────────────────────┐
│      Ansible Automation Platform        │
│            (AAP 2.6)                    │
└────────────────┬────────────────────────┘
                 │
     ┌───────────┼───────────┐
     │           │           │
     ▼           ▼           ▼
┌─────────┐  ┌──────────┐  ┌──────────┐
│Identity │  │Satellite │  │Insights  │
│  Mgmt   │  │  6.18    │  │          │
│ (IdM)   │  │          │  │          │
└────┬────┘  └────┬─────┘  └──────────┘
     │            │
     │            ▼
     │      ┌──────────────────┐
     │      │ OpenShift / K8s  │
     │      └──────────────────┘
     │
     └──────────────────────────────────>  All integrate with IdM for auth
```

## Integration Order

### Phase 1: Foundation
1. **Deploy Identity Management (IdM)**
   - Kerberos realm setup
   - LDAP directory
   - Certificate authority

### Phase 2: Infrastructure
2. **Deploy Satellite 6.18**
   - Connect to IdM for authentication
   - Configure DHCP/DNS
   - Setup platform_provisioning

### Phase 3: Automation
3. **Deploy AAP 2.6**
   - Connect to IdM for authentication
   - Connect to Satellite for inventory
   - Configure execution environments

### Phase 4: Observability
4. **Deploy Insights (optional)**
   - Connect to Satellite
   - Configure reporting

### Phase 5: Container Platform
5. **Deploy OpenShift (optional)**
   - Connect to IdM for authentication
   - Configure service mesh
   - Setup operator hub

## Integration Tasks

### IdM → Satellite
```bash
ansible-playbook playbooks/integrations/idm-scenario_satellite-integration_generic.yml
```

Tasks:
- Configure LDAP authentication
- Setup IPA CA for SSL certificates
- Configure IdM DNS records for Satellite

### IdM → AAP
```bash
ansible-playbook playbooks/integrations/idm-aap-integration_generic.yml
```

Tasks:
- Configure LDAP authentication for AAP
- Setup organization sync
- Configure RBAC

### Satellite → AAP
```bash
ansible-playbook playbooks/integrations/scenario_satellite-aap-integration_generic.yml
```

Tasks:
- Configure Satellite as dynamic inventory
- Setup platform_provisioning callback
- Configure remote execution

### Satellite → Insights
```bash
ansible-playbook playbooks/integrations/scenario_satellite-insights-integration_generic.yml
```

Tasks:
- Enable Insights plugin
- Configure reporting
- Setup automation rules

### IdM → OpenShift
```bash
ansible-playbook playbooks/integrations/idm-scenario_openshift-integration_generic.yml
```

Tasks:
- Configure OIDC authentication
- Setup certificate signing
- Configure RBAC

## Full Stack Integration

```bash
ansible-playbook playbooks/integrations/full-stack-integration_generic.yml
```

This playbook:
1. Validates all components are deployed
2. Runs all integration_generic playbooks in order
3. Performs integration_generic testing
4. Generates integration_generic report

## Unintegration

If you need to remove a component:

1. **Backup all data first**
   ```bash
   ansible-playbook playbooks/operations/backup-all.yml
   ```

2. **Remove integrations gracefully**
   ```bash
   ansible-playbook playbooks/integrations/remove-scenario_satellite-integration_generic.yml
   ```

3. **Uninstall product**
   ```bash
   ansible-playbook playbooks/products/scenario_satellite/uninstall.yml
   ```

## Testing Integration

```bash
# Test all integrations
ansible-playbook playbooks/integrations/test-all-integrations.yml

# Test specific integration_generic
ansible-playbook playbooks/integrations/idm-scenario_satellite-integration_generic-test.yml
```

## Troubleshooting

See [Integration Troubleshooting](INTEGRATION_TROUBLESHOOTING.md) for:
- Common integration_generic issues
- Debugging steps
- Log locations
- Solution procedures

## Best Practices

1. **Follow deployment order** - Don't skip steps
2. **Test each integration_generic** - Before moving to next
3. **Document customizations** - For future reference
4. **Monitor integrations** - Use health checks
5. **Plan for unintegration** - Before tight coupling
