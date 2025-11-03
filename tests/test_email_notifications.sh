#!/bin/bash
# test_email_notifications.sh - Test email notification functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Testing Email Notification System ==="
echo "Date: $(date)"
echo

# Check if ansible is available
if! command -v ansible-playbook &> /dev/null; then
 echo "ERROR: ansible-playbook not found. Please install Ansible."
 exit 1
fi

# Check if inventory file exists
if [! -f "inventory.yml" ]; then
 echo "ERROR: inventory.yml not found"
 exit 1
fi

echo "1. Testing basic email configuration..."

# Create a simple test playbook for email
cat > test_email_temp.yml << 'EOF'
---
- name: Test Email Notification System
 hosts: localhost
 gather_facts: true
 vars:
 admin_email: "admin@example.com"
 
 tasks:
 - name: Test basic email notification
 ansible.builtin.mail:
 to: "{{ admin_email }}"
 subject: "LVM Automation Test - {{ ansible_date_time.iso8601 }}"
 body: |
 This is a test email from your LVM automation system.
 
 Server: {{ inventory_hostname }}
 Test Time: {{ ansible_date_time.iso8601 }}
 
 If you receive this email, your notification system is working correctly.
 
 System Information:
 - OS: {{ ansible_distribution }} {{ ansible_distribution_version }}
 - Architecture: {{ ansible_architecture }}
 - Memory: {{ (ansible_memtotal_mb / 1024) | round(2) }}GB
 
 This is an automated test message.
 ignore_errors: true
 register: email_test_result
 
 - name: Display test results
 ansible.builtin.debug:
 msg: |
 Email Test Results:
 {% if email_test_result is succeeded %}
 SUCCESS: Email sent successfully
 {% else %}
 FAILED: Email failed to send
 Error: {{ email_test_result.msg | default('Unknown error') }}
 {% endif %}
 
 - name: Test email template loading
 ansible.builtin.include_vars:
 file: email_templates.yml
 ignore_errors: true
 register: template_load_result
 
 - name: Display template test results
 ansible.builtin.debug:
 msg: |
 Template Loading Results:
 {% if template_load_result.failed is not defined or not template_load_result.failed %}
 SUCCESS: Email templates loaded successfully
 Available templates: {{ email_templates.keys() | list | join(', ') }}
 {% else %}
 FAILED: Failed to load email templates
 Error: {{ template_load_result.msg | default('Unknown error') }}
 {% endif %}
EOF

echo "Running email test playbook..."
ansible-playbook test_email_temp.yml -i inventory.yml --connection=local

echo
echo "2. Testing webhook notification system..."

# Test webhook endpoints if they're available
if command -v curl &> /dev/null; then
 echo "Testing webhook connectivity..."
 
 # Test main webhook endpoint
 if curl -s --connect-timeout 5 -X POST http://localhost:5000/webhook \
 -H "Content-Type: application/json" \
 -d '{"test": "email_notification_test", "hostname": "test-server"}' > /dev/null 2>&1; then
 echo "SUCCESS: Main webhook endpoint responding"
 else
 echo "FAILED: Main webhook endpoint not responding (EDA may not be running)"
 echo " Start EDA with:./start_eda.sh"
 fi
 
 # Test other webhook endpoints
 for endpoint in "create-disk" "integrate-disk" "completion"; do
 if curl -s --connect-timeout 2 -X POST "http://localhost:5000/webhook/$endpoint" \
 -H "Content-Type: application/json" \
 -d '{"test": "connectivity"}' > /dev/null 2>&1; then
 echo "SUCCESS: Webhook endpoint /$endpoint responding"
 else
 echo "FAILED: Webhook endpoint /$endpoint not responding"
 fi
 done
else
 echo "curl not available - skipping webhook tests"
fi

echo
echo "3. Validating email configuration in inventory..."

# Check inventory for email configuration
if grep -q "admin_email:" inventory.yml; then
 admin_email=$(grep "admin_email:" inventory.yml | awk '{print $2}' | tr -d '"')
 echo "SUCCESS: Admin email configured: $admin_email"
else
 echo "FAILED: Admin email not configured in inventory.yml"
fi

# Check for SMTP configuration
if grep -q "mail_smtp_host:" inventory.yml; then
 echo "SUCCESS: Custom SMTP configuration found"
else
 echo "INFO: Using default SMTP configuration (localhost:25)"
 echo " Configure mail_smtp_* variables in inventory.yml for custom SMTP"
fi

echo
echo "4. Testing playbook email integration..."

# Test if the main playbooks have email notifications
playbooks_to_check=(
 "extend_lvm.yml"
 "nutanix_disk_creation.yml" 
 "disk_integration.yml"
 "disk_usage_monitor.yml"
 "non_lvm_alert.yml"
 "unsupported_os_alert.yml"
)

for playbook in "${playbooks_to_check[@]}"; do
 if [ -f "$playbook" ]; then
 if grep -q "community.general.mail:" "$playbook"; then
 echo "SUCCESS: $playbook has email notifications"
 else
 echo "FAILED: $playbook missing email notifications"
 fi
 else
 echo "FAILED: $playbook not found"
 fi
done

# Cleanup temporary test file
rm -f test_email_temp.yml

echo
echo "=== Email Notification Test Complete ==="
echo
echo "Summary:"
echo "- Ensure your SMTP server is configured and accessible"
echo "- Update admin_email in inventory.yml with your actual email address"
echo "- Configure mail_smtp_* variables in inventory.yml if using external SMTP"
echo "- Test with a real high disk usage scenario to verify end-to-end functionality"
echo
echo "To manually test email sending:"
echo " ansible localhost -m mail -a \"to=test@example.com subject='Test' body='Test message'\""
echo
echo "To start the Event Driven Ansible system:"
echo "./start_eda.sh"
echo