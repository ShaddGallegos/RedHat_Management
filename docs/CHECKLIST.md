# Add_LVM_to_System_nutanix - Requirements & Setup Checklist

---

## 1. Architecture & Platform Planning

- [Red Hat Automation Architecture Options](https://www.redhat.com/en/resources/ansible-automation-platform-architecture-options-overview)
- [Ansible Automation Platform on RHEL or OpenShift](https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.4/html-single/installation_guide/index)
- [OpenShift Documentation](https://docs.openshift.com/container-platform/latest/welcome/index.html)

---

## 2. System Requirements

- **Supported OS:** RHEL 8.x or 9.x (latest recommended)
- **RAM:** Minimum 8 GB (16 GB+ recommended for production)
- **CPU:** 4 vCPU (8+ recommended for production)
- **Storage:** Minimum 40 GB free (100 GB+ recommended)
- **Partitions:** `/var/lib/awx` (AAP), `/etc/ansible`, `/var/log/ansible`, `/opt/automation`
- **Network:** Outbound access to Red Hat, ServiceNow, Nutanix, Satellite, Insights APIs

---

## 3. RPMs & Packages

- `ansible`
- `ansible-core`
- `ansible-runner`
- `python3`
- `python3-pip`
- `lvm2`
- `parted`
- `git`
- `openssl`
- `python3-requests`
- `python3-PyYAML`
- `python3-cryptography`
- `python3-paramiko`
- `python3-bcrypt`
- `python3-dateutil`
- `python3-dotenv`
- `python3-jmespath`
- `python3-jsonschema`
- `python3-urllib3`
- `python3-colorama`
- `python3-tabulate`
- `python3-click`
- `python3-rich`
- `python3-pysnow` (ServiceNow)
- `python3-insights-client` (Red Hat Insights)
- `python3-nutanix-api` (Nutanix)
- `python3-prism-api` (Nutanix)
- `python3-sendgrid` (optional, for email)
- `python3-sphinx` (optional, for docs)

---

## 4. Ansible Automation Platform

- **Version:** 2.4+ (latest recommended)
- [Download & Install AAP](https://access.redhat.com/downloads/content/480/ver=2.4/rhel-8/2.4/x86_64/product-software)
- [AAP Documentation](https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.4/html-single/installation_guide/index)

---

## 5. Ansible Collections

Install required collections:
```bash
ansible-galaxy collection install community.general
ansible-galaxy collection install servicenow.itsm
ansible-galaxy collection install nutanix.ncp
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install community.crypto
```

---

## 6. Users, Passwords, and URLs

| Integration      | Username         | Password/Token         | URL/Instance                       |
|------------------|------------------|------------------------|-------------------------------------|
| AAP Controller   | aap_admin        | [set in vault]         | https://aap.example.com             |
| ServiceNow       | snow_admin       | [set in vault]         | https://dev.servicenow.com          |
| Nutanix Prism    | nutanix_admin    | [set in vault]         | https://prism.example.com           |
| Satellite        | satellite_admin  | [set in vault]         | https://satellite.example.com       |
| Insights         | rh_user          | [set in vault]         | https://console.redhat.com          |
| SMTP (Email)     | smtp_user        | [set in vault]         | smtp.example.com                    |

**Store all passwords in Ansible Vault or environment variables.**

---

## 7. Integration Setup Order

1. **Install RHEL and required RPMs**
2. **Install Ansible Automation Platform**
3. **Install required Python packages and Ansible collections**
4. **Configure AAP Controller**
   - Create admin user
   - Set up credentials (vault, ServiceNow, Nutanix, Satellite, Insights)
5. **Configure ServiceNow**
   - Create API user
   - Generate credentials
   - Test API access
6. **Configure Nutanix Prism**
   - Create API user
   - Generate credentials
   - Test API access
7. **Configure Red Hat Satellite**
   - Create API user
   - Generate credentials
   - Test API access
8. **Configure Red Hat Insights**
   - Create API user
   - Generate credentials
   - Test API access
9. **Configure SMTP/Email**
   - Set up SMTP server
   - Create credentials
   - Test email sending
10. **Configure Ansible Vault**
    - Create vault file
    - Store all sensitive credentials
11. **Configure dynamic inventories**
    - ServiceNow, Nutanix, Satellite, Insights
12. **Run setup playbooks**
    - `setup_credentials.yml`
    - `complete_aap_setup.yml`
    - `setup_eda.yml`
13. **Test all integrations**
    - Run health checks and sample playbooks

---

## 8. Useful Links

- [Red Hat Ansible Automation Platform Documentation](https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/)
- [Red Hat Satellite Documentation](https://access.redhat.com/documentation/en-us/red_hat_satellite/)
- [Red Hat Insights Documentation](https://access.redhat.com/documentation/en-us/red_hat_insights/)
- [ServiceNow Developer Docs](https://developer.servicenow.com/dev.do#!/reference/api)
- [Nutanix Prism API Docs](https://www.nutanix.dev/reference/prism_central/v4/api/)
- [Ansible Collections Index](https://galaxy.ansible.com/collections)

---

## 9. Additional Recommendations

- Use Ansible Vault for all secrets.
- Document all environment variables and credentials.
- Maintain a secure backup of all configuration files.
- Regularly update all packages and collections.
- Enable logging and monitoring for all automation tasks.

---

**This checklist should be followed in order for a successful deployment and integration of Add_LVM_to_System_nutanix.**