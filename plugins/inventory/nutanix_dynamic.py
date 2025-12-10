#!/usr/bin/env python3
"""Nutanix Dynamic Inventory for Ansible"""
import os
import sys
import json
import requests
from typing import Any, Dict, List

# Disable SSL warnings - handle if urllib3 is not available
try:
    import urllib3
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
except (ImportError, AttributeError):
    # urllib3 not available or disable_warnings not found
    import warnings
    warnings.filterwarnings('ignore', message='Unverified HTTPS request')

class NutanixInventory:
    def __init__(self):
        self.nutanix_host = os.getenv('NUTANIX_HOST')
        self.nutanix_user = os.getenv('NUTANIX_USER')
        self.nutanix_pass = os.getenv('NUTANIX_PASS')
        self.nutanix_port = os.getenv('NUTANIX_PORT', '9440')
        
        if not all([self.nutanix_host, self.nutanix_user, self.nutanix_pass]):
            print("ERROR: NUTANIX_HOST, NUTANIX_USER, NUTANIX_PASS must be set", file=sys.stderr)
            sys.exit(1)
        
        # After validation, these are guaranteed to be strings
        assert self.nutanix_user is not None
        assert self.nutanix_pass is not None
        
        self.base_url = f"https://{self.nutanix_host}:{self.nutanix_port}/api/nutanix/v3"
        self.session = requests.Session()
        self.session.auth = (self.nutanix_user, self.nutanix_pass)
        self.session.verify = False
    
    def get_vms(self):
        url = f"{self.base_url}/vms/list"
        payload = {"kind": "vm", "length": 500}
        try:
            response = self.session.post(url, json=payload, timeout=30)
            response.raise_for_status()
            return response.json().get('entities', [])
        except Exception as e:
            print(f"Error: {e}", file=sys.stderr)
            return []
    
    def build_inventory(self) -> Dict[str, Any]:
        inventory: Dict[str, Any] = {
            '_meta': {'hostvars': {}},
            'all': {'children': ['nutanix_vms']},
            'nutanix_vms': {'hosts': []}
        }
        
        for vm in self.get_vms():
            vm_name = vm.get('status', {}).get('name')
            if not vm_name:
                continue
            
            nic_list = vm.get('status', {}).get('resources', {}).get('nic_list', [])
            ip_address = None
            for nic in nic_list:
                ip_endpoints = nic.get('ip_endpoint_list', [])
                if ip_endpoints:
                    ip_address = ip_endpoints[0].get('ip')
                    break
            
            if not ip_address:
                continue
            
            hosts: List[str] = inventory['nutanix_vms']['hosts']  # type: ignore
            hosts.append(vm_name)
            inventory['_meta']['hostvars'][vm_name] = {
                'ansible_host': ip_address,
                'nutanix_vm_uuid': vm.get('metadata', {}).get('uuid'),
                'ansible_user': 'ansible',
                'ansible_become': True
            }
        
        return inventory
    
    def run(self):
        inventory = self.build_inventory()
        print(json.dumps(inventory, indent=2))

if __name__ == '__main__':
    inv = NutanixInventory()
    inv.run()
