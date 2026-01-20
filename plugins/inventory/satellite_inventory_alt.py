#!/usr/bin/env python3
'''
Red Hat Satellite Dynamic Inventory Plugin for AAP
Fetches hosts from Satellite/Foreman
'''

import os_generic
import sys
import json
import argparse
import requests
from typing import Dict, List
from urllib3.exceptions import InsecureRequestWarning

# Suppress SSL warnings if verify is disabled
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

class SatelliteInventory:
 def __init__(self):
 self.inventory = {
 '_meta': {
 'hostvars': {}
 },
 'all': {
 'hosts': [],
 'vars': {}
 }
 }
 
 self.url = os_generic.environ.get('SATELLITE_URL')
 self.username = os_generic.environ.get('SATELLITE_USERNAME')
 self.password = os_generic.environ.get('SATELLITE_PASSWORD')
 self.verify_ssl = os_generic.environ.get('SATELLITE_VERIFY_SSL', 'true').lower() == 'true'
 
 if not all([self.url, self.username, self.password]):
 print("ERROR: SATELLITE_URL, SATELLITE_USERNAME, and SATELLITE_PASSWORD required", 
 file=sys.stderr)
 sys.exit(1)
 
 self.session = requests.Session()
 self.session.auth = (self.username, self.password)
 self.session.headers.update({'Accept': 'application/json'})
 
 def api_get(self, endpoint: str, params: Dict = None) -> Dict:
 '''Make API request to Satellite'''
 url = f"{self.url}/api/v2/{endpoint}"
 try:
 response = self.session.get(
 url, 
 params=params or {}, 
 verify=self.verify_ssl,
 timeout=30
 )
 response.raise_for_status()
 return response.json()
 except requests.exceptions.RequestException as e:
 print(f"ERROR: API request failed: {e}", file=sys.stderr)
 return {}
 
 def fetch_hosts(self) -> List[Dict]:
 '''Fetch all hosts from Satellite'''
 hosts = []
 page = 1
 per_page = 100
 
 while True:
 data = self.api_get('hosts', {
 'page': page,
 'per_page': per_page,
 'thin': 1
 })
 
 results = data.get('results', [])
 if not results:
 break
 
 hosts.extend(results)
 
 # Check if more pages
 if len(results) < per_page:
 break
 page += 1
 
 return hosts
 
 def fetch_host_details(self, host_id: int) -> Dict:
 '''Fetch detailed info for a specific host'''
 return self.api_get(f'hosts/{host_id}')
 
 def parse_hosts(self, hosts: List[Dict]):
 '''Parse hosts into inventory format'''
 for host in hosts:
 hostname = host.get('name')
 if not hostname:
 continue
 
 # Get full details
 details = self.fetch_host_details(host['id'])
 
 # Add to inventory
 self.inventory['all']['hosts'].append(hostname)
 
 # Host variables
 self.inventory['_meta']['hostvars'][hostname] = {
 'satellite_id': host['id'],
 'satellite_name': hostname,
 'ansible_host': host.get('ip') or hostname,
 'satellite_os': details.get('operatingsystem_name'),
 'satellite_environment': details.get('environment_name'),
 'satellite_location': details.get('location_name'),
 'satellite_organization': details.get('organization_name'),
 }
 
 # Group by OS
 os_name = details.get('operatingsystem_name', 'unknown').replace(' ', '_')
 os_group = f"satellite_os_{os_name}"
 if os_group not in self.inventory:
 self.inventory[os_group] = {'hosts': []}
 self.inventory[os_group]['hosts'].append(hostname)
 
 # Group by environment
 env_name = details.get('environment_name')
 if env_name:
 env_group = f"satellite_env_{env_name}"
 if env_group not in self.inventory:
 self.inventory[env_group] = {'hosts': []}
 self.inventory[env_group]['hosts'].append(hostname)
 
 # Group by location
 location = details.get('location_name')
 if location:
 loc_group = f"satellite_location_{location.replace(' ', '_')}"
 if loc_group not in self.inventory:
 self.inventory[loc_group] = {'hosts': []}
 self.inventory[loc_group]['hosts'].append(hostname)
 
 # Group by organization
 org = details.get('organization_name')
 if org:
 org_group = f"satellite_org_{org.replace(' ', '_')}"
 if org_group not in self.inventory:
 self.inventory[org_group] = {'hosts': []}
 self.inventory[org_group]['hosts'].append(hostname)
 
 # Add to satellite_managed group
 if 'satellite_managed' not in self.inventory:
 self.inventory['satellite_managed'] = {'hosts': []}
 self.inventory['satellite_managed']['hosts'].append(hostname)
 
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
 parser = argparse.ArgumentParser(description='Satellite Inventory')
 parser.add_argument('--list', action='store_true', help='List all hosts')
 parser.add_argument('--host', help='Get specific host details')
 args = parser.parse_args()
 
 scenario_satellite = SatelliteInventory()
 
 if args.list:
 inventory = scenario_satellite.get_inventory()
 print(json.dumps(inventory, indent=2))
 elif args.host:
 host_vars = scenario_satellite.get_host(args.host)
 print(json.dumps(host_vars, indent=2))
 else:
 parser.print_help()
 sys.exit(1)

if __name__ == '__main__':
 main()
