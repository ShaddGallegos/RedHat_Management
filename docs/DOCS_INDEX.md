# RHIS Documentation Index

**Last Updated**: January 16, 2026  
**Status**: Production Ready

---

## Core Documentation

### Getting Started
- [README.md](README.md) - Main project overview

### Quick Reference Guides
- [Provisioning Quick Reference](PROVISIONING_QUICK_REFERENCE.md) - Provisioning services quick lookup
- [Satellite Config Quick Reference](SATELLITE_CONFIG_QUICK_REFERENCE.md) - Satellite configuration reference

---

## Provisioning Services Stack

Complete documentation for DHCP, DNS, TFTP, PXE, and network platform_infrastructure_core.

### Main Guides
- [Provisioning Services Configuration](PROVISIONING_SERVICES_CONFIGURATION.md) - Complete technical reference (600+ lines)
- [Network Interface Configuration](NETWORK_INTERFACE_CONFIGURATION.md) - Dual network setup guide
- [Dual Network Update](DUAL_NETWORK_UPDATE.md) - Network configuration summary
- [Provisioning Services Implementation](PROVISIONING_SERVICES_IMPLEMENTATION.md) - Implementation checklist

### Supplementary
- [Provisioning Services Summary](PROVISIONING_SERVICES_SUMMARY.md) - Overview
- [Satellite OS Network Configuration](SATELLITE_OS_NETWORK_CONFIGURATION.md) - OS and network setup

---

## Satellite Configuration

Documentation for Satellite 6.18 setup and configuration.

### Primary Guides
- [Satellite Kickstart Configuration](SATELLITE_KICKSTART_CONFIGURATION.md) - Kickstart setup
- [Satellite Feature Completion](SATELLITE_6_18_FEATURE_COMPLETION.md) - Feature status

---

## Reference Documentation

### Project Organization
- [File Index](FILE_INDEX.md) - Complete file inventory

### Configuration Standards
- [Variable Naming Convention](VARIABLE_NAMING_CONVENTION.md) - Variable naming standards
- [RHEL YUM Repositories](RHEL_YUM_REPOSITORIES_ENABLEMENT.md) - Repository configuration

### AAP/Automation
- [AAP Configuration Roles](AAP_CONFIGURATION_ROLES_SUMMARY.md) - AAP roles overview

---

## Archived Documentation

Historical project status and audit documents are available but primarily for reference:
- PROJECT_STATUS_JAN_16_2026.md
- AUDIT_COMPLETE_STATUS.md
- REPOSITORY_INTEGRITY_AUDIT_COMPLETE.md
- PHASE_2_IMPLEMENTATION_SUMMARY.md
- PLAYBOOKS_RESTRUCTURING_COMPLETE.md
- PLAYBOOKS_RESTRUCTURING_SUMMARY.md
- FILES_CREATED_AUDIT.md
- ROLES_IMPROVEMENT_OPPORTUNITIES.md
- ROLES_QUALITY_IMPROVEMENT_SUMMARY.md
- README_IMPLEMENTATION.md
- DOCUMENTATION.md
- CONTRIB_SUBMODULES.md
- INDEX.md

---

## Documentation Organization

```
docs/
 README.md                                    [Main entry point]
 DOCS_INDEX.md                               [This file]

 PROVISIONING/
    PROVISIONING_SERVICES_CONFIGURATION.md
    NETWORK_INTERFACE_CONFIGURATION.md
    DUAL_NETWORK_UPDATE.md
    PROVISIONING_SERVICES_IMPLEMENTATION.md
    PROVISIONING_SERVICES_SUMMARY.md
    PROVISIONING_QUICK_REFERENCE.md
    SATELLITE_OS_NETWORK_CONFIGURATION.md

 SATELLITE/
    SATELLITE_KICKSTART_CONFIGURATION.md
    SATELLITE_6_18_FEATURE_COMPLETION.md
    SATELLITE_CONFIG_QUICK_REFERENCE.md

 REFERENCE/
    FILE_INDEX.md
    VARIABLE_NAMING_CONVENTION.md
    RHEL_YUM_REPOSITORIES_ENABLEMENT.md
    AAP_CONFIGURATION_ROLES_SUMMARY.md

 ARCHIVE/
     PROJECT_STATUS_JAN_16_2026.md
     AUDIT_COMPLETE_STATUS.md
     [Other historical docs...]
```

---

## Quick Navigation

### I want to...

**Deploy platform_provisioning services**
→ [Provisioning Services Configuration](PROVISIONING_SERVICES_CONFIGURATION.md)

**Set up network interfaces**
→ [Network Interface Configuration](NETWORK_INTERFACE_CONFIGURATION.md)

**Quick lookup for platform_provisioning**
→ [Provisioning Quick Reference](PROVISIONING_QUICK_REFERENCE.md)

**Configure Satellite**
→ [Satellite Config Quick Reference](SATELLITE_CONFIG_QUICK_REFERENCE.md)

**Understand the overall setup**
→ [README.md](README.md)

---

## Key Features Documented

-  Dual network configuration (eth0 external, eth1 private)
-  DHCP, DNS, TFTP, PXE services
-  Satellite 6.18 integration_generic
-  Resolv.conf configuration
-  Firewall rules
-  Network isolation and security
-  Provisioning workflows
-  Verification procedures
-  Troubleshooting guides

---

## Document Status

| Document | Status | Type |
|----------|--------|------|
| Provisioning Services Configuration |  Current | Reference |
| Network Interface Configuration |  Current | Guide |
| Dual Network Update |  Current | Summary |
| Satellite Config Quick Reference |  Current | Quick Ref |
| Provisioning Quick Reference |  Current | Quick Ref |
| Satellite Kickstart Configuration |  Current | Guide |
| File Index |  Current | Reference |

---

**Version**: 1.0.0  
**Last Updated**: January 16, 2026
