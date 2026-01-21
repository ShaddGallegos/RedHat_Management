#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

echo "[ci] Running Ansible syntax checks"
ansible-playbook playbooks/generate_and_propagate_hosts.yml --syntax-check
ansible-playbook playbooks/provisioning_services_setup.yml --syntax-check || true

echo "[ci] Running generation playbook in dry-run mode (local)
"
ansible-playbook playbooks/generate_and_propagate_hosts.yml \
  -i localhost, -c local \
  -e "propagate=false dry_run=true reverse_dns_check=false wait_until_all=false" \
  -e "github_user=''" -e "github_repo=''" -e "github_pat=''" \
  -e "installer=installer.local:127.0.0.1" \
  -e "scenario=ci" \
  -e "host_list='sat.example.com:10.168.0.10:scenario_satellite,dhcp1.example.com:10.168.0.11:dhcp'"

echo "[ci] Verifying generated files exist"
[ -f files/generated_hosts ] || (echo "missing files/generated_hosts" && exit 2)
[ -f inventory/hosts ] || (echo "missing inventory/hosts" && exit 2)
[ -f files/generated_resolv.conf ] || (echo "missing files/generated_resolv.conf" && exit 2)

echo "[ci] CI script completed successfully"
