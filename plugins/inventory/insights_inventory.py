#!/usr/bin/env python3
'''
Red Hat Insights Dynamic Inventory Plugin for AAP
Fetches hosts registered with Red Hat Insights
'''

import os
import sys
import json
import argparse
import requests
from typing import Dict, List, Any

class InsightsInventory:
    def __init__(self):
        self.inventory: Dict[str, Any] = {
            '_meta': {
                'hostvars': {}
            },
            'all': {
                'hosts': [],
                'vars': {}
            }
        }

        self.username = os.environ.get('RH_CDN_USERNAME')
        self.password = os.environ.get('RH_CDN_PASSWORD')
        self.org_id = os.environ.get('RH_INSIGHTS_ORG_ID', '')

        self.base_url = 'https://console.redhat.com/api/inventory/v1'

    def fetch_hosts(self) -> List[Dict]:
        '''Fetch hosts from Insights API'''
        if not self.username or not self.password:
            print("ERROR: RH_CDN_USERNAME and RH_CDN_PASSWORD required", file=sys.stderr)
            return []

        headers = {'Accept': 'application/json'}
        auth = (self.username, self.password)

        try:
            # Get systems from Insights
            url = f"{self.base_url}/hosts"
            # allow mixed value types (ints and strings) in params to avoid type errors
            params: Dict[str, Any] = {'per_page': 100}

            if self.org_id:
                # prefer numeric owner_id when possible
                try:
                    owner_id: Any = int(self.org_id)
                except ValueError:
                    owner_id = self.org_id
                params['filter[system_profile][owner_id]'] = owner_id

            response = requests.get(url, auth=auth, headers=headers, params=params, timeout=30)
            response.raise_for_status()

            data = response.json()
            return data.get('results', [])

        except requests.exceptions.RequestException as e:
            print(f"ERROR: Failed to fetch Insights data: {e}", file=sys.stderr)
            return []

    def parse_hosts(self, hosts: List[Dict]):
        '''Parse hosts into inventory format'''
        for host in hosts:
            hostname = host.get('fqdn') or host.get('display_name')
            if not hostname:
                continue

            # Add to main inventory
            self.inventory['all']['hosts'].append(hostname)

            # Add host vars
            self.inventory['_meta']['hostvars'][hostname] = {
                'insights_id': host.get('id'),
                'insights_display_name': host.get('display_name'),
                'insights_fqdn': host.get('fqdn'),
                'insights_subscription_manager_id': host.get('subscription_manager_id'),
                'ansible_host': host.get('fqdn'),
            }

            # Add system profile data if available
            system_profile = host.get('system_profile', {})
            if system_profile:
                self.inventory['_meta']['hostvars'][hostname].update({
                    'insights_os_release': system_profile.get('os_release'),
                    'insights_arch': system_profile.get('arch'),
                    'insights_cores': system_profile.get('number_of_cpus'),
                    'insights_sockets': system_profile.get('number_of_sockets'),
                })

            # Group by OS
            os_release = system_profile.get('os_release', 'unknown')
            os_group = f"insights_os_{os_release.replace('.', '_')}"
            if os_group not in self.inventory:
                self.inventory[os_group] = {'hosts': []}
            self.inventory[os_group]['hosts'].append(hostname)

            # Group by architecture
            arch = system_profile.get('arch', 'unknown')
            arch_group = f"insights_arch_{arch}"
            if arch_group not in self.inventory:
                self.inventory[arch_group] = {'hosts': []}
            self.inventory[arch_group]['hosts'].append(hostname)

            # insights_registered group
            # ensure the group exists and obtain a typed hosts list before appending
            self.inventory.setdefault('insights_registered', {})
            hosts_list: List[str] = self.inventory['insights_registered'].setdefault('hosts', [])
            hosts_list.append(hostname)

    def get_inventory(self) -> Dict:
        '''Build and return complete inventory'''
        hosts = self.fetch_hosts()
        self.parse_hosts(hosts)
        return self.inventory

    def get_host(self, hostname: str) -> Dict:
        '''Get specific host details'''
        inventory = self.get_inventory()
        return inventory['_meta']['hostvars'].get(hostname, {})

def main():
    parser = argparse.ArgumentParser(description='Red Hat Insights Inventory')
    parser.add_argument('--list', action='store_true', help='List all hosts')
    parser.add_argument('--host', help='Get specific host details')
    args = parser.parse_args()

    insights = InsightsInventory()

    if args.list:
        inventory = insights.get_inventory()
        print(json.dumps(inventory, indent=2))
    elif args.host:
        host_vars = insights.get_host(args.host)
        print(json.dumps(host_vars, indent=2))
    else:
        parser.print_help()
        sys.exit(1)

if __name__ == '__main__':
    main()
