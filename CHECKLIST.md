# RedHat_Management — Checklist

Purpose: Orchestration and role collections for comprehensive Red Hat platform deployments.

Prerequisites
- `ansible-core`, required collections, Python dependencies
- Optional: Automation Hub token for `requirements_hub.yml`

Quick start
```bash
cd RedHat_Management
# Install public collections
ansible-galaxy collection install -r requirements.yml
# For Hub collections (subscription)
ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN=<token> ansible-galaxy collection install -r requirements_hub.yml
# Run orchestration (interactive prompts recommended)
ansible-playbook system_prompts.yml
ansible-playbook playbooks/orchestration.yml -e deployment_scenario=satellite_aap
```

Verify
- Inventory file under `inventory/hosts` exists and groups are populated
- Check `reports/` for generated outputs

Notes
- Use `make install` to provision pip deps and collections where provided.
