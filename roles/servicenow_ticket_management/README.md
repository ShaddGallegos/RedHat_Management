# ServiceNow Ticket Management Role

## Description

This Ansible role automates ServiceNow ticket management for infrastructure events, such as disk or LVM alerts.  
It supports creating, updating, and closing incident tickets, and can be integrated with monitoring or automation workflows.

## Requirements

- RHEL 8/9
- Ansible 2.9+ (recommended: 2.14+)
- Python 3.x on control node
- ServiceNow ITSM module (`servicenow.itsm`) installed via Ansible Galaxy:
  ```bash
  ansible-galaxy collection install servicenow.itsm
  ```

## Role Variables

See [`defaults/main.yml`](defaults/main.yml) for all configurable options.

### Main Variables

- `servicenow_instance`: ServiceNow instance URL
- `servicenow_username`: ServiceNow API username
- `servicenow_password`: ServiceNow API password
- `servicenow_table`: Table to use (default: `incident`)
- `servicenow_ticket_short_description`: Ticket short description
- `servicenow_ticket_description`: Ticket full description
- `servicenow_ticket_category`: Ticket category (e.g., Infrastructure)
- `servicenow_ticket_impact`: Impact level (1=High, 2=Medium, 3=Low)
- `servicenow_ticket_urgency`: Urgency level (1=High, 2=Medium, 3=Low)
- `servicenow_ticket_assignment_group`: Assignment group for ticket
- `servicenow_ticket_caller_id`: Caller ID for ticket
- `servicenow_api_timeout`: API timeout in seconds
- `servicenow_verify_ssl`: Verify SSL certificates (true/false)

See [`defaults/main.yml`](defaults/main.yml) for defaults and override as needed.

## Example Playbook

```yaml
- hosts: servers
  roles:
    - role: servicenow_ticket_management
      vars:
        servicenow_instance: "https://dev.servicenow.com"
        servicenow_username: "admin"
        servicenow_password: "{{ vault_servicenow_password }}"
        servicenow_ticket_short_description: "Automated LVM Alert"
        servicenow_ticket_assignment_group: "Linux Admins"
```

## Tasks Included

- Create ServiceNow incident ticket
- Update ServiceNow ticket (add work notes, change state)
- Close ServiceNow ticket
- Log ticket actions

## License

MIT

## Author

Your Name <your.email@example.com>
