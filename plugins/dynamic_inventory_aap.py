"""
Enhanced Ansible dynamic inventory plugin for AAP.
Supports both static example and API-based host discovery.

Usage:
- Place this file under plugins/
- Reference in inventory config (YAML):
  plugin: aap
  api_url: http://aap.example.com/api/v2/hosts
  api_token: <your_token>
  fallback: true
"""
import sys
import json
import os

try:
    import requests
except ImportError:
    requests = None

class BaseInventoryPlugin(object):
    NAME = "aap"
    def __init__(self, api_url=None, api_token=None, fallback=True):
        self.api_url = api_url or os.environ.get("AAP_API_URL")
        self.api_token = api_token or os.environ.get("AAP_API_TOKEN")
        self.fallback = fallback
        self.hosts = []
        self.groups = {}
        self.hostvars = {}
        self._populate_inventory()

    def _populate_inventory(self):
        if self.api_url and requests:
            try:
                headers = {"Authorization": f"Bearer {self.api_token}"} if self.api_token else {}
                resp = requests.get(self.api_url, headers=headers, timeout=10)
                resp.raise_for_status()
                data = resp.json()
                # Example: expects data['results'] to be a list of host dicts
                for host in data.get('results', []):
                    name = host.get('name')
                    self.hosts.append(name)
                    self.hostvars[name] = {
                        "ansible_host": host.get('ip', '127.0.0.1'),
                        "description": host.get('description', ''),
                        "enabled": host.get('enabled', True)
                    }
                self.groups = {"aap_api_group": self.hosts}
                return
            except Exception as e:
                print(f"API error: {e}. Falling back to static inventory.", file=sys.stderr)
                if not self.fallback:
                    raise
        # Fallback static example
        self.hosts = ["aap-controller1.example.com", "aap-controller2.example.com", "aap-executor.example.com"]
        self.groups = {
            "controllers": ["aap-controller1.example.com", "aap-controller2.example.com"],
            "executors": ["aap-executor.example.com"],
            "aap_all": ["aap-controller1.example.com", "aap-controller2.example.com", "aap-executor.example.com"]
        }
        self.hostvars = {
            "aap-controller1.example.com": {"ansible_host": "192.168.1.11", "role": "controller"},
            "aap-controller2.example.com": {"ansible_host": "192.168.1.12", "role": "controller"},
            "aap-executor.example.com": {"ansible_host": "192.168.1.13", "role": "executor"}
        }

    def parse(self, loader, path, cache=True):
        # Minimal parse: just returns inventory
        return self.inventory()

    def inventory(self):
        return {
            "all": {
                "hosts": self.hosts,
                "children": list(self.groups.keys()),
            },
            **{g: {"hosts": hlist} for g, hlist in self.groups.items()},
            "_meta": {"hostvars": self.hostvars}
        }

if __name__ == "__main__":
    # Example usage: python dynamic_inventory_aap.py <api_url> <api_token>
    api_url = sys.argv[1] if len(sys.argv) > 1 else None
    api_token = sys.argv[2] if len(sys.argv) > 2 else None
    plugin = BaseInventoryPlugin(api_url=api_url, api_token=api_token)
    print(json.dumps(plugin.inventory(), indent=2))
