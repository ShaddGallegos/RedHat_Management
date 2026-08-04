# Project Prompting Role - Testing Guide

## What Was Added

Successfully expanded the `roles/project_prompting` role with comprehensive prompts for:

### IdM (13 prompts)
- Domain and realm configuration
- Admin and Directory Manager passwords
- DNS settings (enable/disable, forwarders)
- Network configuration (interface, FQDN, IP, subnet, gateway)
- LDAP base DN
- Kerberos realm

### Satellite (24 prompts)  
- Version, domain, FQDN, IP, network settings
- DHCP/DNS/TFTP configuration
- Admin credentials and email
- RHEL repository management
- Lifecycle environments
- Content views and activation keys
- Foreman proxy settings

### AAP (17 prompts)
- Version, domain, hostname
- Network configuration (IP, interface, subnet, gateway)
- Admin credentials
- Installer bundle path
- Component FQDNs (Gateway, Controller, Hub, EDA, Database)

## How to Test Interactively

The prompting role is designed for INTERACTIVE use only. To test it properly:

```bash
# Run the prompting playbook
ansible-playbook system_prompts.yml
```

Then:
1. Select platform components (e.g., `1` for IdM)
2. Select infrastructure (e.g., `2` for Libvirt)  
3. Select integrations (e.g., `1` for Insights)
4. Answer each prompt or press Enter to use defaults

The configuration will be saved to:
- `~/.ansible/conf/env.yml`

## Technical Details

### Fix Applied
- Moved `project_prompting_system_admin_user` to the top of the prompt list
- Set default value before the prompting loop to prevent "undefined variable" errors
- Added debug statements to verify component selection

### Component Mapping
- Platform selection `1` → `idm` component
- Platform selection `2` → `aap` component  
- Platform selection `3` → `satellite` component
- Infrastructure selection `2` → `libvirt` component
- Integration selection `1` → `insights` component

## Files Modified

1. `roles/project_prompting/defaults/main.yml` - Added 40+ new prompts
2. `roles/project_prompting/tasks/main.yml` - Fixed variable ordering
3. `test_prompting.sh` - Test automation script (limited - for non-interactive testing only)

## Note on Automated Testing

The `ansible.builtin.pause` module does NOT work with piped input. When stdin is not a TTY, Ansible displays:  
`[WARNING]: Not waiting for response to prompt as stdin is not interactive`

Therefore, automated testing via scripts will skip prompts and use empty/default values.  
**For real testing, run interactively in a terminal.**
