#!/bin/bash
# migrate-poc-roles.sh
# Migrate libvirt_host and satellite roles to organized structure with local task files

set -euo pipefail

ROLES_DIR="/run/media/sgallego/SD_Card/GIT/RedHat_Management/roles"
ORGANIZED_DIR="${ROLES_DIR}/organized"
LIBVIRT_ORGANIZED="${ORGANIZED_DIR}/os_libvirt/tasks"
SATELLITE_ORGANIZED="${ORGANIZED_DIR}/product_satellite/tasks"

echo "=== PoC Role Migration Script ==="
echo "Migrating libvirt_host and satellite roles to organized structure..."
echo ""

# Helper function to create files
create_file() {
    local filepath="$1"
    local content="$2"
    
    mkdir -p "$(dirname "$filepath")"
    echo "$content" > "$filepath"
    echo " Created: $filepath"
}

# ============================================================================
# 1. Create libvirt task files in organized/os_libvirt/tasks/
# ============================================================================

echo "--- Creating libvirt task files ---"

create_file "${LIBVIRT_ORGANIZED}/users.yml" '---
# Configure libvirt users and permissions
- name: Configure libvirt users and permissions
  ansible.builtin.user:
    name: "{{ libvirt_ssh_user }}"
    groups: libvirt,kvm
    append: yes
    createhome: yes
    shell: /bin/bash
  when: libvirt_ssh_user != '"'"'root'"'"'

- name: Create polkit rule for libvirt management
  ansible.builtin.copy:
    content: |
      polkit.addRule(function(action, subject) {
        if (subject.user == "{{ libvirt_ssh_user }}" && action.id == "org.libvirt.unix.manage") {
          return polkit.Result.YES;
        }
      });
    dest: /etc/polkit-1/rules.d/60-libvirt-{{ libvirt_ssh_user }}.rules
    owner: root
    group: root
    mode: '"'"'0644'"'"'
  when: libvirt_ssh_user != '"'"'root'"'"'
'

create_file "${LIBVIRT_ORGANIZED}/firewall.yml" '---
# Configure firewall rules for libvirt
- name: Ensure firewalld is started and enabled
  ansible.builtin.systemd:
    name: firewalld
    state: started
    enabled: true
  register: firewall_start
  failed_when: firewall_start.failed and '"'"'firewall'"'"' not in firewall_start.msg | lower

- name: Configure firewall rules for libvirt
  ansible.posix.firewalld:
    service: libvirt
    permanent: yes
    state: enabled
    zone: public
  ignore_errors: yes
  when: firewall_start.changed or firewall_start.status.ActiveState == '"'"'active'"'"'
'

create_file "${LIBVIRT_ORGANIZED}/selinux.yml" '---
# Configure SELinux for libvirt
- name: Check SELinux status
  ansible.builtin.command: getenforce
  register: selinux_status
  changed_when: false

- name: Configure SELinux for libvirt
  ansible.builtin.shell: |
    semanage port -a -t virt_port_t -p tcp 5900:5910 2>/dev/null || true
    semanage port -a -t virt_port_t -p tcp 49152:49215 2>/dev/null || true
  when: selinux_status.stdout != '"'"'Disabled'"'"'
  changed_when: false
'

create_file "${LIBVIRT_ORGANIZED}/certs.yml" '---
# Verify and generate certificates for libvirt
- name: Verify certificate directories exist
  ansible.builtin.file:
    path: "{{ item }}"
    state: directory
    owner: root
    group: root
    mode: '"'"'0700'"'"'
  loop:
    - /etc/pki/libvirt
    - /etc/pki/libvirt/private

- name: Check for existing certificates
  ansible.builtin.stat:
    path: /etc/pki/libvirt/server-cert.pem
  register: libvirt_cert_stat

- name: Generate self-signed certificate if missing
  ansible.builtin.shell: |
    openssl req -new -x509 -days 365 -nodes \
      -out /etc/pki/libvirt/server-cert.pem \
      -keyout /etc/pki/libvirt/private/server-key.pem \
      -subj "/CN=$(hostname -f)"
  when: not libvirt_cert_stat.stat.exists
'

create_file "${LIBVIRT_ORGANIZED}/validate.yml" '---
# Validate libvirt installation and configuration
- name: Validate libvirt installation
  ansible.builtin.command: virsh list
  changed_when: false
  register: virsh_list

- name: Display virsh status
  ansible.builtin.debug:
    msg: "Libvirt is operational. Active VMs: {{ virsh_list.stdout_lines | length - 2 }}"

- name: Check libvirtd service status
  ansible.builtin.systemd:
    name: libvirtd
  register: libvirtd_service
  failed_when: libvirtd_service.status.ActiveState != '"'"'active'"'"'

- name: Validate network configurations
  ansible.builtin.command: "virsh net-list --all"
  changed_when: false
'

create_file "${LIBVIRT_ORGANIZED}/satellite.yml" '---
# Register libvirt host in Satellite when requested
- name: Register libvirt host in Satellite
  block:
    - name: Install subscription-manager
      ansible.builtin.package:
        name: subscription-manager
        state: present

    - name: Register with Satellite
      ansible.builtin.command: >
        subscription-manager register
        --serverurl=https://{{ satellite_fqdn }}/rhsm
        --org='"'"'{{ satellite_org | default("Default_Org") }}'"'"'
        --username={{ satellite_admin_user }}
        --password={{ satellite_admin_password }}
        --auto-attach
      register: sat_register
      changed_when: '"'"'The system has been registered'"'"' in sat_register.stdout or '"'"'already registered'"'"' in sat_register.stdout
      no_log: true

  when: libvirt_register_in_satellite | default(false)
  vars:
    satellite_fqdn: "{{ satellite_fqdn | default('"'"'satellite.example.com'"'"') }}"
    satellite_org: "{{ satellite_org | default('"'"'Default_Org'"'"') }}"
    satellite_admin_user: "{{ satellite_admin_user | default('"'"'admin'"'"') }}"
    satellite_admin_password: "{{ satellite_admin_password | default('"'"''"'"') }}"
'

# ============================================================================
# 2. Copy satellite task files to organized/product_satellite/tasks/
# ============================================================================

echo ""
echo "--- Migrating satellite task files ---"

create_file "${SATELLITE_ORGANIZED}/install.yml" '---
- name: Satellite install placeholder
  ansible.builtin.debug:
    msg: "Implement Satellite install steps here."
'

create_file "${SATELLITE_ORGANIZED}/configure.yml" '---
- name: Satellite configure placeholder
  ansible.builtin.debug:
    msg: "Implement Satellite configuration here."
'

create_file "${SATELLITE_ORGANIZED}/test.yml" '---
- name: Satellite test placeholder
  ansible.builtin.debug:
    msg: "Implement Satellite validation here."
'

create_file "${SATELLITE_ORGANIZED}/backup.yml" '---
- name: Satellite backup placeholder
  ansible.builtin.debug:
    msg: "Implement Satellite backup here."
'

create_file "${SATELLITE_ORGANIZED}/restore.yml" '---
- name: Satellite restore placeholder
  ansible.builtin.debug:
    msg: "Implement Satellite restore/undo here."
'

# ============================================================================
# 3. Update product_satellite/tasks/main.yml to use relative includes
# ============================================================================

echo ""
echo "--- Updating product_satellite main.yml ---"

create_file "${SATELLITE_ORGANIZED}/main.yml" '---
# Organized Product-level Satellite role (PoC)
# This file includes organized satellite subtasks (local copies)
- name: Include install tasks
  ansible.builtin.include_tasks: install.yml

- name: Include configure tasks
  ansible.builtin.include_tasks: configure.yml

- name: Include test tasks
  ansible.builtin.include_tasks: test.yml

- name: Include backup tasks
  ansible.builtin.include_tasks: backup.yml

- name: Include restore tasks
  ansible.builtin.include_tasks: restore.yml
'

# ============================================================================
# 4. Backup original files
# ============================================================================

echo ""
echo "--- Creating backups of original files ---"

if [ -f "${ROLES_DIR}/satellite/tasks/main.yml" ]; then
    cp "${ROLES_DIR}/satellite/tasks/main.yml" "${ROLES_DIR}/satellite/tasks/main.yml.backup.$(date +%Y%m%d_%H%M%S)"
    echo " Backed up: satellite/tasks/main.yml"
fi

# ============================================================================
# 5. Display summary
# ============================================================================

echo ""
echo "=== Migration Complete ==="
echo ""
echo "Created files:"
echo "  Libvirt task files (${LIBVIRT_ORGANIZED}):"
ls -1 "${LIBVIRT_ORGANIZED}"/*.yml 2>/dev/null | xargs -n1 basename || echo "  (none found)"
echo ""
echo "  Satellite task files (${SATELLITE_ORGANIZED}):"
ls -1 "${SATELLITE_ORGANIZED}"/*.yml 2>/dev/null | xargs -n1 basename || echo "  (none found)"
echo ""
echo "Next steps:"
echo "  1. Review the generated task files for accuracy"
echo "  2. Update variable references in main playbooks if needed"
echo "  3. Test the migrated roles with: ansible-lint"
echo "  4. Run playbooks to validate: ansible-playbook -i inventory playbook.yml"
echo ""