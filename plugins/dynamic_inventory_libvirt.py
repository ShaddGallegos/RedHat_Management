"""
Enhanced Ansible dynamic inventory plugin for Libvirt.
Supports both static example and API-based host discovery.

Usage:
- Place this file under plugins/
- Reference in inventory config (YAML):
  plugin: libvirt
  api_url: http://libvirt.example.com/api/hosts
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
    NAME = "libvirt"
    def __init__(self, api_url=None, api_token=None, fallback=True):
        self.api_url = api_url or os.environ.get("LIBVIRT_API_URL")
        self.api_token = api_token or os.environ.get("LIBVIRT_API_TOKEN")
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
                for host in data.get('results', []):
                    name = host.get('name')
                    self.hosts.append(name)
                    self.hostvars[name] = {
                        "ansible_host": host.get('ip', '127.0.0.1'),
                        "vm": host.get('vm', True),
                        "state": host.get('state', 'running')
                    }
                self.groups = {"libvirt_api_group": self.hosts}
                return
            except Exception as e:
                print(f"API error: {e}. Falling back to static inventory.", file=sys.stderr)
                if not self.fallback:
                    raise
        # Fallback static example
        self.hosts = ["libvirt-host1.example.com", "libvirt-host2.example.com"]
        self.groups = {
            "libvirt_hosts": ["libvirt-host1.example.com", "libvirt-host2.example.com"],
            "libvirt_all": ["libvirt-host1.example.com", "libvirt-host2.example.com"]
        }
        self.hostvars = {
            "libvirt-host1.example.com": {"ansible_host": "192.168.4.11", "vm": True, "state": "running"},
            "libvirt-host2.example.com": {"ansible_host": "192.168.4.12", "vm": True, "state": "stopped"}
        }

    def parse(self, loader, path, cache=True):
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
    api_url = sys.argv[1] if len(sys.argv) > 1 else None
    api_token = sys.argv[2] if len(sys.argv) > 2 else None
    plugin = BaseInventoryPlugin(api_url=api_url, api_token=api_token)
    print(json.dumps(plugin.inventory(), indent=2))
