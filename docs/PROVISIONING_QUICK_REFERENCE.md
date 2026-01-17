# Provisioning Services - Quick Reference

## Architecture at a Glance

```
satellite.prod.spg (eth1: 10.168.0.1)
│
├─ DHCP   (port 67/UDP)  → 10.168.50.0 - 10.168.200.255
├─ DNS    (port 53)      → example.com, prod.example.com
├─ TFTP   (port 69/UDP)  → /var/lib/tftpboot
└─ PXE    (via DHCP)     → pxelinux.0 + menu
```

## Deployed Services

### 1. DHCP Server
**Service**: dhcpd  
**Config**: `/etc/dhcp/dhcpd.conf`  
**Range**: 10.168.50.0 - 10.168.200.255  
**Nameservers**: 10.168.0.1, 10.168.1.53, 8.8.8.8  

### 2. DNS Server
**Service**: named (BIND)  
**Config**: `/etc/named.conf`  
**Resolver**: 10.168.0.1:53  
**Zones**: example.com, prod.example.com, lab.example.com  

**Resolv.conf**:
```
nameserver 10.168.0.1
search example.com prod.example.com lab.example.com
options rotate timeout:2 attempts:3
```

### 3. TFTP Server
**Service**: xinetd tftp  
**Config**: `/etc/xinetd.d/tftp`  
**Root**: `/var/lib/tftpboot`  

### 4. PXE Boot Menu
**File**: `/var/lib/tftpboot/pxelinux.cfg/default`  
**Options**: RHEL 9/10 Minimal, Full Stack, Rescue, Memtest  

## Quick Commands

### Check Service Status
```bash
systemctl status dhcpd
systemctl status named
systemctl status xinetd
```

### Verify Configuration
```bash
# DHCP
dhcpd -t

# DNS
named-checkconf /etc/named.conf

# Resolv.conf
cat /etc/resolv.conf
```

### Test Services
```bash
# DNS
dig @10.168.0.1 satellite.prod.spg.example.com

# DHCP (from another host)
dhclient -v eth0

# TFTP
tftp 10.168.0.1
tftp> get pxelinux.0
tftp> quit
```

### View Logs
```bash
# DHCP logs
journalctl -u dhcpd -f

# DNS logs
journalctl -u named -f

# xinetd logs
journalctl -u xinetd -f
```

## Deployment Commands

### All Services
```bash
ansible-playbook playbooks/provisioning_services_setup.yml -i inventory/hosts -b
```

### Individual Services
```bash
# DHCP only
ansible-playbook playbooks/provisioning_dhcp_setup.yml -i inventory/hosts -b

# DNS only
ansible-playbook playbooks/provisioning_dns_setup.yml -i inventory/hosts -b

# TFTP/PXE only
ansible-playbook playbooks/provisioning_tftp_pxe_setup.yml -i inventory/hosts -b
```

## File Locations

### Configuration Files
- `/etc/dhcp/dhcpd.conf` - DHCP config
- `/etc/named.conf` - DNS main config
- `/var/named/named.zones` - DNS zones
- `/var/named/named.example.com` - example.com zone file
- `/var/named/named.prod.example.com` - prod.example.com zone file
- `/etc/xinetd.d/tftp` - TFTP config
- `/etc/resolv.conf` - DNS resolver config

### Boot Files
- `/var/lib/tftpboot/pxelinux.0` - PXE bootloader
- `/var/lib/tftpboot/pxelinux.cfg/default` - PXE menu
- `/var/lib/tftpboot/rhel9/` - RHEL 9 kernel/initrd
- `/var/lib/tftpboot/rhel10/` - RHEL 10 kernel/initrd

### Log Files
- `/var/log/dhcpd.log` - DHCP service log
- `/var/log/named.log` - DNS service log
- `/var/log/tftp.log` - TFTP service log

## Provisioning Workflow

1. **System Powers On** → BIOS/UEFI PXE boot
2. **DHCP Discovery** → Broadcast on network
3. **DHCP Response** → Get IP + boot server address
4. **TFTP Download** → Get pxelinux.0 bootloader
5. **PXE Menu** → User selects RHEL 9 or 10
6. **Boot Kernel** → Anaconda downloads kickstart
7. **Installation** → Automatic based on kickstart
8. **Registration** → System registers with Satellite
9. **Ready** → System available for management

## Firewall Rules

```
DHCP       67/UDP
DNS        53/UDP, 53/TCP
TFTP       69/UDP
PXE        4011/UDP
```

## Host Reservations

| Host | IP | MAC |
|------|----|----|
| satellite.prod.spg | 10.168.0.10 | 52:54:00:00:00:10 |
| idm.prod.spg | 10.168.0.20 | 52:54:00:00:00:20 |
| aap.prod.spg | 10.168.0.30 | 52:54:00:00:00:30 |

## Troubleshooting

### DHCP not working
```bash
# Check service
systemctl status dhcpd

# Check configuration
dhcpd -t

# Check leases
cat /var/lib/dhcp/dhcpd.leases

# View logs
journalctl -u dhcpd -n 50
```

### DNS not resolving
```bash
# Check service
systemctl status named

# Check config
named-checkconf /etc/named.conf

# Test directly
dig @10.168.0.1 satellite.prod.spg.example.com

# View logs
journalctl -u named -n 50
```

### TFTP/PXE not working
```bash
# Check xinetd
systemctl status xinetd

# Check TFTP root
ls -la /var/lib/tftpboot/

# Check PXE menu
cat /var/lib/tftpboot/pxelinux.cfg/default

# View logs
journalctl -u xinetd -n 50
```

### Resolv.conf not correct
```bash
# Check current state
cat /etc/resolv.conf

# Should contain:
# nameserver 10.168.0.1
# search example.com prod.example.com lab.example.com
# options rotate timeout:2 attempts:3

# Verify DNS works
nslookup google.com 10.168.0.1
```

## Performance Tuning

### DHCP
- Max leases: 38,401 (10.168.50.0 - 10.168.200.255)
- Lease time: 86,400s (24 hours)
- Renewal: 43,200s (12 hours)

### DNS
- Query logging: Enabled (can disable for performance)
- DNSSEC: Enabled (can disable if not needed)
- Caching: Unlimited TTL

### TFTP
- Per-source limit: 11 connections
- CPS: 100 per 2 seconds
- Root: 10MB+ recommended free space

## References

### Documentation
- `docs/PROVISIONING_SERVICES_CONFIGURATION.md` - Full documentation
- `docs/PROVISIONING_SERVICES_SUMMARY.md` - Implementation summary
- `roles/services_provisioning_stack/README.md` - Role documentation

### Playbooks
- `playbooks/provisioning_services_setup.yml` - Complete stack
- `playbooks/provisioning_dhcp_setup.yml` - DHCP only
- `playbooks/provisioning_dns_setup.yml` - DNS only
- `playbooks/provisioning_tftp_pxe_setup.yml` - TFTP/PXE only

## Quick Restart

```bash
# Restart all services
sudo systemctl restart dhcpd named xinetd

# Restart individual services
sudo systemctl restart dhcpd    # DHCP
sudo systemctl restart named    # DNS
sudo systemctl restart xinetd   # TFTP
```

## Status Check

```bash
# All services
systemctl status dhcpd named xinetd

# Network interface
ip addr show eth1

# Firewall
sudo firewall-cmd --list-ports

# Resolv.conf
cat /etc/resolv.conf
```

## Start Using

```bash
# 1. Deploy all services
ansible-playbook playbooks/provisioning_services_setup.yml -i inventory/hosts -b

# 2. Verify services
systemctl status dhcpd named xinetd

# 3. Test DNS
dig @10.168.0.1 satellite.prod.spg.example.com

# 4. Boot a system from network (PXE)
# Select RHEL 9 or 10 from menu

# 5. Watch installation
# Anaconda loads kickstart automatically

# 6. System registers with Satellite
# Check Satellite UI for new host
```

---

**Version**: 1.0.0  
**Status**: Production Ready  
**Last Updated**: January 16, 2026
