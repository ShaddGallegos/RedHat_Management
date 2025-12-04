#!/usr/bin/env python3
"""
Foreman / Satellite dynamic inventory plugin (Ansible + CLI helper).

Usage (inventory file):
---
plugin: foreman
url: https://foreman.example.com
token: "{{ lookup('env','FOREMAN_TOKEN') }}"   # preferred
user: "{{ lookup('env','FOREMAN_USER') }}"     # optional if token not used
password: "{{ lookup('env','FOREMAN_PASS') }}"
search: "operatingsystem=RedHat"               # Foreman search query (optional)
host_field: host.name                           # or 'name'
group_by: organizations                        # optional host attribute to create groups
verify_ssl: true
per_page: 500
"""
from ansible.errors import AnsibleParserError
from ansible.plugins.inventory import BaseInventoryPlugin
from typing import Any, Dict, List, Optional
import requests
import os
import json

NAME = "foreman"

DOCUMENTATION = r"""
author: "GitHub Copilot"
short_description: Foreman / Satellite dynamic inventory plugin
description:
  - Query Foreman / Satellite API to build an Ansible inventory.
options:
  plugin:
    required: true
    choices: ['foreman','satellite']
  url:
    required: true
  token:
    required: false
  user:
    required: false
  password:
    required: false
  search:
    required: false
  host_field:
    required: false
    default: name
  group_by:
    required: false
  verify_ssl:
    required: false
    default: true
  per_page:
    required: false
    default: 500
"""

EXAMPLES = r"""
plugin: foreman
url: https://satellite.example.com
token: "{{ lookup('env','FOREMAN_TOKEN') }}"
search: "hostgroup=web_servers"
host_field: name
group_by: organization
verify_ssl: true
"""


class ForemanClient:
    def __init__(
        self,
        base_url: str,
        token: Optional[str] = None,
        user: Optional[str] = None,
        password: Optional[str] = None,
        verify: bool = True,
        per_page: int = 500,
        timeout: int = 30,
    ):
        self.base = base_url.rstrip("/")
        self.verify = verify
        self.timeout = timeout
        self.per_page = int(per_page)
        self.session = requests.Session()
        if token:
            self.session.headers.update({"Authorization": f"Bearer {token}"})
        elif user and password:
            self.session.auth = (user, password)
        self.session.headers.update({"Accept": "application/json"})

    def _get_hosts_page(
        self, page: int = 1, search: Optional[str] = None
    ) -> Dict[str, Any]:
        params = {"per_page": self.per_page, "page": page}
        if search:
            params["search"] = search
        url = f"{self.base}/api/hosts"
        r = self.session.get(
            url, params=params, verify=self.verify, timeout=self.timeout
        )
        r.raise_for_status()
        return r.json()

    def list_hosts(self, search: Optional[str] = None) -> List[Dict[str, Any]]:
        hosts: List[Dict[str, Any]] = []
        page = 1
        while True:
            data = self._get_hosts_page(page=page, search=search)
            # foreman returns list (older versions) or dict with 'results' / 'total'
            if isinstance(data, dict) and "results" in data:
                batch = data.get("results", [])
                total = data.get("total", 0)
            elif isinstance(data, list):
                batch = data
                total = len(batch)
            else:
                # try to pull 'results' or fallback
                batch = data.get("results") if isinstance(data, dict) else []
                total = len(batch)
            if not batch:
                break
            hosts.extend(batch)
            if len(hosts) >= total:
                break
            page += 1
            if page > 1000:
                break
        return hosts


def normalize_host_item(
    item: Dict[str, Any], host_field: str
) -> Optional[Dict[str, Any]]:
    # host_field may be dotted (e.g., host.name) or simple key
    if "." in host_field:
        parts = host_field.split(".")
        val = item
        for p in parts:
            if isinstance(val, dict) and p in val:
                val = val[p]
            else:
                val = None
                break
        hostname = val
    else:
        hostname = (
            item.get(host_field)
            or item.get("name")
            or item.get("host")
            or item.get("fqdn")
        )
    if not hostname:
        return None
    # Best-effort extract IP and some metadata
    ip = (
        item.get("ip")
        or item.get("ip_address")
        or item.get("primary_interface", {}).get("ip")
        if isinstance(item.get("primary_interface"), dict)
        else None
    )
    return {"name": str(hostname), "ip": ip, "raw": item}


class InventoryModule(BaseInventoryPlugin):
    NAME = NAME

    def verify_file(self, path):
        try:
            data = self.loader.load_from_file(path)
        except Exception:
            return False
        return data.get("plugin") in (self.NAME, "satellite")

    def parse(self, loader, path, cache=True):
        super(InventoryModule, self).parse(loader, path, cache=cache)
        cfg = loader.load_from_file(path)

        url = cfg.get("url")
        if not url:
            raise AnsibleParserError("foreman plugin: 'url' is required")
        token = cfg.get("token") or os.getenv("FOREMAN_TOKEN")
        user = cfg.get("user") or os.getenv("FOREMAN_USER")
        password = cfg.get("password") or os.getenv("FOREMAN_PASS")
        search = cfg.get("search")
        host_field = cfg.get("host_field", "name")
        group_by = cfg.get("group_by")
        verify = bool(cfg.get("verify_ssl", True))
        per_page = cfg.get("per_page", 500)

        client = ForemanClient(
            base_url=url,
            token=token,
            user=user,
            password=password,
            verify=verify,
            per_page=per_page,
        )
        try:
            hosts = client.list_hosts(search=search)
        except Exception as e:
            raise AnsibleParserError(f"foreman plugin: API error: {e}")

        # build inventory
        for item in hosts:
            norm = normalize_host_item(item, host_field)
            if not norm:
                continue
            name = norm["name"]
            self.inventory.add_host(name)
            if norm.get("ip"):
                self.inventory.set_variable(name, "ansible_host", norm["ip"])
            self.inventory.set_variable(name, "foreman_raw", norm["raw"])
            # grouping: use group_by field found in item (simple key)
            if group_by:
                grp_val = item.get(group_by)
                if grp_val:
                    grp = f"{group_by}_{str(grp_val)}"
                    self.inventory.add_group(grp)
                    self.inventory.add_host(name, group=grp)


# CLI helper (quick test)
def cli_main():
    import argparse

    parser = argparse.ArgumentParser(
        description="Foreman/Satellite dynamic inventory CLI"
    )
    parser.add_argument("--list", action="store_true")
    parser.add_argument("--host", help="host name to show vars")
    parser.add_argument("--url", help="Foreman URL (env FOREMAN_URL)")
    parser.add_argument("--token", help="token (env FOREMAN_TOKEN)")
    parser.add_argument("--search", help="search string (optional)")
    args = parser.parse_args()

    url = args.url or os.getenv("FOREMAN_URL")
    token = args.token or os.getenv("FOREMAN_TOKEN")
    if not url:
        sys.stderr.write("FOREMAN_URL or --url required\n")
        raise SystemExit(2)
    client = ForemanClient(base_url=url, token=token, verify=True)
    hosts = client.list_hosts(search=args.search)
    inv = {
        "_meta": {"hostvars": {}},
        "all": {"children": ["foreman_hosts"]},
        "foreman_hosts": {"hosts": []},
    }
    for item in hosts:
        norm = normalize_host_item(item, "name")
        if not norm:
            continue
        h = norm["name"]
        inv["foreman_hosts"]["hosts"].append(h)
        hv = {"foreman_raw": norm["raw"]}
        if norm.get("ip"):
            hv["ansible_host"] = norm["ip"]
        inv["_meta"]["hostvars"][h] = hv
    if args.list:
        print(json.dumps(inv, indent=2))
    elif args.host:
        print(json.dumps(inv["_meta"]["hostvars"].get(args.host, {}), indent=2))
    else:
        print(json.dumps(inv, indent=2))


if __name__ == "__main__":
    cli_main()
