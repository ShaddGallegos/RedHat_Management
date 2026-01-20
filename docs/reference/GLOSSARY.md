# Glossary

Common terms and abbreviations used in RHIS documentation and deployments.

## A

**AAP**
Red Hat Ansible Automation Platform. Workflow automation and task ansible_dev_node_orchestration platform.

**ABAC**
Attribute-Based Access Control. Fine-grained access control based on attributes.

**AK**
Activation Key. Satellite credential for registering systems without admin credentials.

**API**
Application Programming Interface. Mechanism for programmatic interaction with systems.

**ARD**
Analysis and Reporting Database. Satellite component storing system facts and reports.

## B

**Baseline**
Reference configuration snapshot for compliance checking.

**Bind**
Berkeley Internet Name Domain. DNS server implementation used in IdM.

**BYOC**
Bring Your Own Cloud. Feature allowing automation in external cloud providers.

## C

**CA**
Certificate Authority. IdM component issuing and managing digital certificates.

**CMDB**
Configuration Management Database. Ansible-scenario_ansible_cmdb_core tool generating host inventory snapshots.

**CN**
Common Name. Component of LDAP distinguished names.

**CSR**
Certificate Signing Request. Request for certificate from CA.

**CRUD**
Create, Read, Update, Delete. Basic data operations.

## D

**DC**
Domain Component. LDAP directory structure element.

**DN**
Distinguished Name. Unique LDAP object identifier.

**DNS**
Domain Name System. Network service resolving hostnames to IPs.

**DSA**
Directory Server Agent. LDAP server component.

## E

**EE**
Execution Environment. Container image with Ansible, dependencies, and collections.

**FQDN**
Fully Qualified Domain Name. Complete hostname including domain (e.g., host.example.com).

## F

**Fact**
System data collected by Ansible (OS, memory, network, etc.) or Satellite.

**Foreman**
Web UI and management framework underlying Satellite.

## G

**GNOME**
Graphical desktop environment. Used in IdM with FreeIPA for web interface.

**Grafana**
Monitoring visualization platform integrated with AAP.

## H

**HA**
High Availability. Multi-node redundant deployment.

**Hostgroup**
Satellite collection of hosts sharing configuration and content.

**HTTP/HTTPS**
HyperText Transfer Protocol. Web communication protocol.

**Hypervisor**
Virtual machine host (KVM, VMware, Hyper-V, etc.).

## I

**IdM**
Red Hat Identity Management (FreeIPA). Centralized authentication and authorization.

**IP**
Internet Protocol. Network protocol (IPv4, IPv6).

**IPTABLES**
Kernel firewall configuration tool (Linux).

## J

**JWT**
JSON Web Token. Stateless authentication token format.

## K

**KDC**
Key Distribution Center. Kerberos service issuing tickets.

**Kerberos**
Network authentication protocol. Used by IdM for SSO.

**Keytab**
Kerberos key table. File containing service credentials.

**KVM**
Kernel-based Virtual Machine. Linux hypervisor.

## L

**LDAP**
Lightweight Directory Access Protocol. Directory service protocol.

**LDAPS**
LDAP Secure. LDAP over TLS/SSL (port 636).

**LVM**
Logical Volume Manager. Disk partitioning system.

## M

**MAC**
Media Access Control. Physical network address.

**Molecule**
Ansible testing framework for role development.

**MTA**
Mail Transfer Agent. Email server software.

## N

**NFS**
Network File System. Shared storage protocol.

**NTP**
Network Time Protocol. Time synchronization service.

## O

**OIDC**
OpenID Connect. Authentication protocol layered on OAuth 2.0.

**Organization**
Satellite/AAP logical grouping for multi-tenancy.

**OS**
Operating System or Organization Specific (context dependent).

## P

**PEM**
Privacy Enhanced Mail. Certificate/key encoding format.

**Playbook**
Ansible workflow file (YAML format) defining tasks.

**Pod**
Kubernetes container abstraction. In AAP/OpenShift context.

**PostgreSQL**
Object-relational database. Used by AAP and Satellite.

**Prometheus**
Monitoring and alerting system used with AAP.

**Proxy**
Satellite component executing tasks on remote networks.

## R

**RBAC**
Role-Based Access Control. Access control based on user roles.

**Realm**
Kerberos domain (e.g., EXAMPLE.COM).

**Receptor**
AAP component for multi-hop automation execution.

**Remediation**
Automated corrective action to resolve non-compliance.

**Repository**
Satellite storage of packages/content for deployment.

**RHEL**
Red Hat Enterprise Linux. Enterprise Linux distribution.

**RHIS**
Red Hat Infrastructure Standard. This deployment framework.

**Role**
Reusable Ansible task collection. Also used for RBAC.

**RPM**
Red Hat Package Manager. Package format used by RHEL.

## S

**SA**
Service Account. Non-human user account for applications.

**SASL**
Simple Authentication and Security Layer. Authentication framework.

**Satellite**
Red Hat Satellite. Systems management, platform_provisioning, and patching platform.

**SCAP**
Security Content Automation Protocol. Vulnerability assessment standard.

**SELinux**
Security-Enhanced Linux. Mandatory access control system.

**SMTP**
Simple Mail Transfer Protocol. Email transmission protocol.

**Snapshot**
Point-in-time VM or logical volume copy.

**SOA**
Service-Oriented Architecture. System design pattern.

**SSL/TLS**
Secure Socket Layer / Transport Layer Security. Encryption protocols.

**SSO**
Single Sign-On. Unified authentication across systems.

**Subnet**
Logical network division (e.g., 192.168.1.0/24).

## T

**Ticket**
Kerberos authentication credential.

**TLS**
Transport Layer Security. Modern encryption protocol (successor to SSL).

**Tomcat**
Java web application server. Used by Satellite and Foreman.

## U

**UID**
User ID. Unique user identifier in LDAP (not numeric).

**URI**
Uniform Resource Identifier. Web resource address.

**URL**
Uniform Resource Locator. Web address.

**UUID**
Universally Unique Identifier. Globally unique identifier.

## V

**Vault**
Ansible Vault. Ansible encryption tool for secrets.

**Virtualization**
Technology enabling multiple VMs on single hardware.

**VM**
Virtual Machine. Simulated computer instance.

## W

**Webhook**
HTTP callback triggered by events. Used for integrations.

**Workload**
Application or service deployed and managed by RHIS.

## X

**X.509**
Certificate standard for digital certificates.

## Y

**YAML**
YAML Ain't Markup Language. Data serialization format used by Ansible.

## Z

**Zone**
DNS zone. Domain area managed by specific nameserver.

---

## Common Abbreviations

| Abbreviation | Meaning |
|--------------|---------|
| AAP | Ansible Automation Platform |
| AD | Active Directory |
| API | Application Programming Interface |
| AK | Activation Key |
| AWS | Amazon Web Services |
| CA | Certificate Authority |
| CMDB | Configuration Management Database |
| DB | Database |
| DN | Distinguished Name |
| DNS | Domain Name System |
| EE | Execution Environment |
| FQCN | Fully Qualified Collection Name |
| FQDN | Fully Qualified Domain Name |
| HA | High Availability |
| HTTP/S | HyperText Transfer Protocol (Secure) |
| IdM | Identity Management |
| IP | Internet Protocol |
| KDC | Key Distribution Center |
| LDAP | Lightweight Directory Access Protocol |
| NFS | Network File System |
| NTP | Network Time Protocol |
| RBAC | Role-Based Access Control |
| RHEL | Red Hat Enterprise Linux |
| RHIS | Red Hat Infrastructure Standard |
| RPM | Red Hat Package Manager |
| SSO | Single Sign-On |
| SSL/TLS | Secure Socket Layer / Transport Layer Security |
| UID | User Identifier |
| VM | Virtual Machine |
| YAML | YAML Ain't Markup Language |

---

See [Quick Reference](./QUICK_REFERENCE.md) for quick lookup guide.
