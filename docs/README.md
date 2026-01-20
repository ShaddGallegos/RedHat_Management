# Documentation Index

Complete reference for Red Hat Infrastructure Setup (RHIS) documentation.

**Status**: Production Ready | **Updated**: January 16, 2026 | **Active Docs**: 11 | **Archived**: 18

---

## 🚀 Quick Start (5 Minutes)

Start here if you're new to the project:

1. **[Provisioning Quick Reference](PROVISIONING_QUICK_REFERENCE.md)** - DHCP, DNS, TFTP, PXE setup
2. **[Satellite Config Quick Reference](SATELLITE_CONFIG_QUICK_REFERENCE.md)** - Satellite basics

---

## 📚 Complete Guides

Detailed configuration and implementation documentation:

### Provisioning Services (Production Stack)
- **[PROVISIONING_SERVICES_CONFIGURATION.md](PROVISIONING_SERVICES_CONFIGURATION.md)** - Complete 600+ line guide
  - DHCP server configuration
  - DNS (BIND) setup with 9 zones
  - TFTP/PXE boot system
  - Firewall rules
  - Troubleshooting
  - **Time to read**: ~20 minutes

- **[NETWORK_INTERFACE_CONFIGURATION.md](NETWORK_INTERFACE_CONFIGURATION.md)** - Network setup guide
  - Primary interface (eth0) - External NAT
  - Secondary interface (eth1) - Private 10.168.0.0/16
  - NetworkManager configuration
  - Routing and DNS resolution
  - **Time to read**: ~15 minutes

- **[DUAL_NETWORK_UPDATE.md](DUAL_NETWORK_UPDATE.md)** - Dual network implementation
  - Architecture overview
  - Configuration changes
  - Deployment steps
  - Verification procedures
  - **Time to read**: ~10 minutes

### Satellite Configuration
- **[SATELLITE_KICKSTART_CONFIGURATION.md](SATELLITE_KICKSTART_CONFIGURATION.md)** - Kickstart templates
  - RHEL 9/10 kickstart files
  - Post-installation scripts
  - Network configuration
  - Repository setup
  - **Time to read**: ~15 minutes

- **[SATELLITE_OS_NETWORK_CONFIGURATION.md](SATELLITE_OS_NETWORK_CONFIGURATION.md)** - OS configuration
  - OS definitions
  - Installation media
  - Partition schemes
  - Network settings
  - **Time to read**: ~15 minutes

- **[RHEL_YUM_REPOSITORIES_ENABLEMENT.md](RHEL_YUM_REPOSITORIES_ENABLEMENT.md)** - Repository management
  - Repository configuration
  - Content sync
  - Repository sync plans
  - Satellite sync procedures
  - **Time to read**: ~12 minutes

---

## 📖 Reference Materials

Specific reference documents and standards:

| Document | Purpose | Audience |
|----------|---------|----------|
| [VARIABLE_NAMING_CONVENTION.md](VARIABLE_NAMING_CONVENTION.md) | Variable naming standards | Developers |
| [FILE_INDEX.md](FILE_INDEX.md) | Complete file inventory | All users |

---

## 📂 Documentation Structure

```
docs/
├── README (this file for root)
├── ✅ Active Documentation (11 files)
│   ├── DOCS_INDEX.md                          (Navigation guide)
│   ├── Quick References (2)
│   │   ├── PROVISIONING_QUICK_REFERENCE.md
│   │   └── SATELLITE_CONFIG_QUICK_REFERENCE.md
│   ├── Provisioning Guides (3)
│   │   ├── PROVISIONING_SERVICES_CONFIGURATION.md
│   │   ├── NETWORK_INTERFACE_CONFIGURATION.md
│   │   └── DUAL_NETWORK_UPDATE.md
│   ├── Satellite Guides (3)
│   │   ├── SATELLITE_KICKSTART_CONFIGURATION.md
│   │   ├── SATELLITE_OS_NETWORK_CONFIGURATION.md
│   │   └── RHEL_YUM_REPOSITORIES_ENABLEMENT.md
│   └── Reference (2)
│       ├── VARIABLE_NAMING_CONVENTION.md
│       └── FILE_INDEX.md
│
└── archive/                          (Legacy documentation - 18 files)
    ├── README.md                     (Archive guide)
    ├── Status reports (6 files)
    ├── Implementation docs (2 files)
    ├── Audit reports (5 files)
    ├── Quality analysis (2 files)
    ├── Legacy docs (3 files)
    └── [Other ansible_dev_node_legacy_archive documentation]
```

---

## 🎯 Documentation by Purpose

### For System Administrators
1. Read: [PROVISIONING_QUICK_REFERENCE.md](PROVISIONING_QUICK_REFERENCE.md) (5 min)
2. Read: [NETWORK_INTERFACE_CONFIGURATION.md](NETWORK_INTERFACE_CONFIGURATION.md) (15 min)
3. Deploy: Use playbooks from `playbooks/`
4. Reference: [PROVISIONING_SERVICES_CONFIGURATION.md](PROVISIONING_SERVICES_CONFIGURATION.md) (ongoing)

### For Satellite Administrators
1. Read: [SATELLITE_CONFIG_QUICK_REFERENCE.md](SATELLITE_CONFIG_QUICK_REFERENCE.md) (5 min)
2. Read: [SATELLITE_KICKSTART_CONFIGURATION.md](SATELLITE_KICKSTART_CONFIGURATION.md) (15 min)
3. Review: [RHEL_YUM_REPOSITORIES_ENABLEMENT.md](RHEL_YUM_REPOSITORIES_ENABLEMENT.md) (12 min)
4. Reference: [SATELLITE_OS_NETWORK_CONFIGURATION.md](SATELLITE_OS_NETWORK_CONFIGURATION.md) (ongoing)

### For Developers
1. Review: [VARIABLE_NAMING_CONVENTION.md](VARIABLE_NAMING_CONVENTION.md) (10 min)
2. Refer: [FILE_INDEX.md](FILE_INDEX.md) (as needed)
3. Contribute: Follow naming standards and conventions
4. Document: Update relevant guides when modifying roles

### For Troubleshooting
1. Check: Relevant Quick Reference
2. Review: Configuration guide troubleshooting section
3. Search: `grep -r "error message" docs/`
4. Archive: Check ansible_dev_node_legacy_archive docs if needed: `grep -r "topic" docs/archive/`

---

## 🔍 Quick Search

### Find by Topic

**DHCP Configuration**
→ [PROVISIONING_SERVICES_CONFIGURATION.md#dhcp](PROVISIONING_SERVICES_CONFIGURATION.md#dhcp)

**DNS/BIND Setup**
→ [PROVISIONING_SERVICES_CONFIGURATION.md#dns](PROVISIONING_SERVICES_CONFIGURATION.md#dns)

**TFTP/PXE Boot**
→ [PROVISIONING_SERVICES_CONFIGURATION.md#tftp](PROVISIONING_SERVICES_CONFIGURATION.md#tftp)

**Network Interfaces**
→ [NETWORK_INTERFACE_CONFIGURATION.md](NETWORK_INTERFACE_CONFIGURATION.md)

**Kickstart Templates**
→ [SATELLITE_KICKSTART_CONFIGURATION.md](SATELLITE_KICKSTART_CONFIGURATION.md)

**Repositories**
→ [RHEL_YUM_REPOSITORIES_ENABLEMENT.md](RHEL_YUM_REPOSITORIES_ENABLEMENT.md)

### Search Commands

```bash
# Find all references to a topic
grep -r "DHCP" docs/*.md

# Search in specific document
grep -n "DHCP" docs/PROVISIONING_SERVICES_CONFIGURATION.md

# Search with context
grep -B2 -A2 "error" docs/*.md

# Search in archive
grep -r "ansible_dev_node_legacy_archive topic" docs/archive/
```

---

## 📊 Documentation Statistics

| Category | Count | Last Updated |
|----------|-------|--------------|
| Quick References | 2 | Jan 16, 2026 |
| Provisioning Guides | 3 | Jan 16, 2026 |
| Satellite Guides | 3 | Jan 16, 2026 |
| Reference Materials | 2 | Jan 16, 2026 |
| **Active Total** | **11** | **Jan 16, 2026** |
| Archived Documents | 18 | Jan 16, 2026 |

---

## 🔗 Related Resources

- **Main README**: [PROJECT_README.md](../PROJECT_README.md)
- **Playbooks**: [playbooks/](../playbooks/)
- **Roles**: [roles/](../roles/)
- **Configuration**: [ansible.cfg](../ansible.cfg)
- **Inventory**: [inventory/](../inventory/)

---

## ✅ Checklist for New Users

- [ ] Read [PROVISIONING_QUICK_REFERENCE.md](PROVISIONING_QUICK_REFERENCE.md) (5 min)
- [ ] Review [NETWORK_INTERFACE_CONFIGURATION.md](NETWORK_INTERFACE_CONFIGURATION.md) (15 min)
- [ ] Check your role in [inventory/hosts](../inventory/hosts)
- [ ] Review group variables [group_vars/](../group_vars/)
- [ ] Run syntax check: `make test`
- [ ] Deploy: `ansible-playbook playbooks/provisioning_services_setup.yml -i inventory/hosts -b`
- [ ] Verify: Check service status in [PROVISIONING_SERVICES_CONFIGURATION.md#verification](PROVISIONING_SERVICES_CONFIGURATION.md#verification)

---

## 📝 Document Maintenance

**Adding New Documentation**
1. Follow naming convention: `TOPIC_SUBTOPIC.md`
2. Add to appropriate section in this index
3. Include "See Also" section with cross-references
4. Update FILE_INDEX.md if needed

**Archiving Documents**
1. Move to `archive/` when superseded or ansible_dev_node_legacy_archive
2. Update ARCHIVE_INDEX.md
3. Remove from main DOCS_INDEX.md
4. Notify team of archive status

**Updating Documentation**
1. Update "Last Updated" date
2. Maintain table of contents
3. Update cross-references
4. Test all code examples

---

## 🆘 Support

- **Documentation Issues**: Check [Troubleshooting sections](PROVISIONING_SERVICES_CONFIGURATION.md#troubleshooting)
- **Configuration Questions**: Review relevant guide
- **Search Documentation**: Use grep commands above
- **Legacy Information**: Check [archive/README.md](archive/README.md)

---

**Quick Links**: [Quick Ref](PROVISIONING_QUICK_REFERENCE.md) | [Sat Config](SATELLITE_CONFIG_QUICK_REFERENCE.md) | [Provisioning](PROVISIONING_SERVICES_CONFIGURATION.md) | [Network](NETWORK_INTERFACE_CONFIGURATION.md) | [Files](FILE_INDEX.md)
