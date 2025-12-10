#!/usr/bin/env python3
"""
Ansible dynamic inventory plugin + CLI helper for VMware vSphere (vCenter REST API).

Place under infra-automation/plugins/inventory/ and reference via inventory YAML:
---
plugin: vmware
url: https://vcenter.example.com
user: "{{ lookup('env','VMWARE_USERNAME') }}"
password: "{{ lookup('env','VMWARE_PASSWORD') }}"
token: "{{ lookup('env','VMWARE_TOKEN') }}"   # optional (CIS session id)
verify_ssl: true
datacenter: MyDatacenter        # optional filter
cluster: MyCluster              # optional filter
power_state: POWERED_ON         # optional filter
host_field: name                # field to use as inventory hostname
group_by: datacenter            # optional field for grouping
fetch_guest_ip: true            # try to fetch guest IP via guest endpoints
"""

# replace direct import with guarded imports to avoid static-analysis/import errors
from typing import TYPE_CHECKING
if TYPE_CHECKING:
    # allow static type checkers to resolve the name without forcing a runtime import
    from ansible.errors import AnsibleParserError  # type: ignore
else:
    try:
        import importlib
        _ansible_errors = importlib.import_module("ansible.errors")
        AnsibleParserError = getattr(_ansible_errors, "AnsibleParserError")
    except Exception:  # pragma: no cover
        class AnsibleParserError(Exception):
            """Fallback when ansible.errors is not available."""
            pass

try:
    import importlib
    _ansible_inv = importlib.import_module("ansible.plugins.inventory")
    BaseInventoryPlugin = getattr(_ansible_inv, "BaseInventoryPlugin")
except Exception:  # pragma: no cover
    # minimal fallback to allow static parsing / CLI use outside Ansible environment
    class BaseInventoryPlugin(object):
        NAME = "vmware"
        def __init__(self, *args, **kwargs):
            pass
        def parse(self, *args, **kwargs):
            raise NotImplementedError("BaseInventoryPlugin.parse is unavailable; install ansible to enable.")

from typing import Any, Dict, List, Optional, cast, TYPE_CHECKING
# Use TYPE_CHECKING so static analyzers / type checkers can resolve `requests`
# without forcing a runtime import. At runtime import dynamically via importlib
# and fall back to None when not available.
if TYPE_CHECKING:
    # Provide the symbol to static analysis tools (no runtime import)
    import requests  # type: ignore
else:
    try:
        import importlib
        requests = importlib.import_module("requests")
    except Exception:
        requests = None  # type: ignore

# Add safe alias for HTTPError so static analysis won't complain when `requests` is None
if requests is None:
    HTTPError = Exception
else:
    try:
        HTTPError = requests.exceptions.HTTPError
    except Exception:
        HTTPError = Exception

import os
import sys
import json

# remove unconditional imports and replace with guarded imports + fallbacks
# Use runtime attribute lookup on the guarded `requests` variable to avoid static analyzers
# complaining about unresolved imports or incompatible types. Annotate as Any/ignore typing
# so type checkers won't try to equate the runtime requests adapter with the fallback shim.
HTTPAdapter: Any
# remove the earlier annotation + class definitions that could shadow the name
if requests is not None:
    try:
        # access adapter via requests namespace to avoid static import resolution issues
        # use getattr on requests to avoid static analyzers complaining about requests.adapters
        _adapters_mod = getattr(requests, "adapters", None)
        HTTPAdapter = getattr(_adapters_mod, "HTTPAdapter", None) if _adapters_mod is not None else None
        if HTTPAdapter is None:
            raise AttributeError("requests.adapters.HTTPAdapter not available")
    except Exception:
        # fallback shim if requests.adapters.HTTPAdapter is unavailable at runtime
        HTTPAdapter = type(
            "HTTPAdapter",
            (),
            {
                "__init__": lambda self, max_retries=None: setattr(self, "max_retries", max_retries)
            },
        )
else:
    # minimal shim to avoid import errors when requests is not installed
    HTTPAdapter = type(
        "HTTPAdapter",
        (),
        {
            "__init__": lambda self, max_retries=None: setattr(self, "max_retries", max_retries)
        },
    )

from typing import TYPE_CHECKING
if TYPE_CHECKING:
    # Provide the symbol for type checkers without forcing a runtime import (suppress unresolved import warnings)
    from urllib3.util.retry import Retry  # type: ignore
else:
    try:
        import importlib
        _urllib3_retry_mod = importlib.import_module("urllib3.util.retry")
        Retry = getattr(_urllib3_retry_mod, "Retry")
    except Exception:  # pragma: no cover
        class Retry:
            def __init__(self, total=0, backoff_factor=0, status_forcelist=None):
                # minimal shim; parameters accepted but no behavior implemented
                self.total = total
                self.backoff_factor = backoff_factor
                self.status_forcelist = status_forcelist

DOCUMENTATION = r"""
author: "GitHub Copilot"
short_description: VMware vSphere dynamic inventory plugin
description:
  - Query vCenter REST API (vcenter/vm) and build inventory of VMs.
options:
  plugin:
    required: true
    choices: ['vmware']
  url:
    required: true
  user:
    required: false
  password:
    required: false
  token:
    required: false
  verify_ssl:
    required: false
    default: true
  datacenter:
    required: false
  cluster:
    required: false
  power_state:
    required: false
  host_field:
    required: false
    default: name
  group_by:
    required: false
  fetch_guest_ip:
    required: false
    default: true
"""

EXAMPLES = r"""
plugin: vmware
url: https://vcenter.example.com
user: "{{ lookup('env','VMWARE_USERNAME') }}"
password: "{{ lookup('env','VMWARE_PASSWORD') }}"
verify_ssl: false
datacenter: MyDatacenter
cluster: MyCluster
power_state: POWERED_ON
host_field: name
group_by: datacenter
fetch_guest_ip: true
"""

NAME = "vmware"
DEFAULT_TIMEOUT = 30

class VCenterClient:
    def __init__(self, base_url: str, username: Optional[str] = None, password: Optional[str] = None,
                 token: Optional[str] = None, verify: bool = True, timeout: int = DEFAULT_TIMEOUT):
        # if requests is not available, raise a clear error at runtime
        if requests is None:
            raise AnsibleParserError(
                "vmware plugin requires the 'requests' package. "
                "Install it in the Python environment used by Ansible (e.g. pip install requests)."
            )
        self.base = base_url.rstrip('/')
        self.username = username
        self.password = password
        self.token = token
        self.verify = verify
        self.timeout = timeout
        self.session = requests.Session()
        retries = Retry(total=3, backoff_factor=0.3, status_forcelist=[502,503,504])
        self.session.mount("https://", HTTPAdapter(max_retries=retries))
        # If a CIS session token is provided, use it
        if token:
            # token expected to be a CIS session id
            self.session.headers.update({'vmware-api-session-id': token})
        elif username and password:
            # create session via CIS endpoint and store token header if possible
            try:
                resp = self.session.post(f"{self.base}/rest/com/vmware/cis/session",
                                         auth=(username, password),
                                         verify=self.verify,
                                         timeout=self.timeout)
                if resp.ok:
                    jd = resp.json()
                    sid = jd.get('value')
                    if sid:
                        self.session.headers.update({'vmware-api-session-id': sid})
                else:
                    # fallback: use basic auth on subsequent requests
                    self.session.auth = (username, password)
            except Exception:
                # fallback to basic auth if session creation fails
                self.session.auth = (username, password)

    def _get(self, path: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        url = f"{self.base}{path}"
        resp = self.session.get(url, params=params or {}, verify=self.verify, timeout=self.timeout)
        resp.raise_for_status()
        return resp.json()

    def list_vms(self, filters: Optional[Dict[str, Any]] = None) -> List[Dict[str, Any]]:
        """
        Return list of VMs from /rest/vcenter/vm.
        Filters may include datacenter, cluster, power_state, name.
        """
        params = {}
        if filters:
            # map some common filter names to query params accepted by vcenter/vm
            for k in ('datacenter', 'cluster', 'power_state', 'name'):
                if k in filters and filters[k]:
                    params[k] = filters[k]
        try:
            data = self._get("/rest/vcenter/vm", params=params)
            # vcenter endpoints commonly respond with {'value': [...]}
            return data.get('value', []) if isinstance(data, dict) else data
        except HTTPError:
            raise
        except Exception:
            return []

    def get_vm_guest_network(self, vm_id: str) -> Optional[Dict[str, Any]]:
        """
        Try to get guest network info for vm_id. Attempts common guest endpoints.
        Returns a dict or None.
        """
        # endpoint may be /rest/vcenter/vm/{vm}/guest/network or /rest/vcenter/vm/{vm}/guest/identity
        candidates = [
            f"/rest/vcenter/vm/{vm_id}/guest/network",
            f"/rest/vcenter/vm/{vm_id}/guest/identity",
            f"/rest/vcenter/vm/{vm_id}/guest/summaries"
        ]
        for p in candidates:
            try:
                data = self._get(p)
                if isinstance(data, dict):
                    # return value wrapper normalization
                    return data.get('value', data)
                return data
            except HTTPError:
                continue
            except Exception:
                continue
        return None

# Ansible plugin wrapper
class InventoryModule(BaseInventoryPlugin):
    NAME = NAME
    # declare attributes used by the base plugin so static analyzers/type checkers
    # recognize them (they are provided by Ansible at runtime).
    loader: Any = None
    inventory: Any = None

    def verify_file(self, path):
        try:
            data = self.loader.load_from_file(path)
        except Exception:
            return False
        return data.get('plugin') == self.NAME

    def parse(self, loader, path, cache=True):
        super(InventoryModule, self).parse(loader, path, cache=cache)
        cfg = loader.load_from_file(path)

        url = cfg.get('url')
        if not url:
            raise AnsibleParserError("vmware plugin: 'url' is required")

        user = cfg.get('user')
        password = cfg.get('password')
        token = cfg.get('token')
        verify = bool(cfg.get('verify_ssl', True))
        datacenter = cfg.get('datacenter')
        cluster = cfg.get('cluster')
        power_state = cfg.get('power_state')
        host_field = cfg.get('host_field', 'name')
        group_by = cfg.get('group_by')
        fetch_guest_ip = bool(cfg.get('fetch_guest_ip', True))

        filters = {}
        if datacenter:
            filters['datacenter'] = datacenter
        if cluster:
            filters['cluster'] = cluster
        if power_state:
            filters['power_state'] = power_state

        try:
            client = VCenterClient(base_url=url, username=user, password=password, token=token, verify=verify)
        except Exception as e:
            raise AnsibleParserError(f"vmware plugin: unable to create vCenter client: {e}")

        try:
            vms = client.list_vms(filters=filters)
        except Exception as e:
            raise AnsibleParserError(f"vmware plugin: vcenter list_vms failed: {e}")

        # build inventory
        for vm in vms:
            # typical fields: vm (id), name, power_state, guest_os etc.
            vm_id = vm.get('vm') or vm.get('id') or vm.get('value') or vm.get('vm_id')
            vm_name = vm.get('name') or vm.get('hostname') or vm_id
            if not vm_name:
                continue
            host = str(vm_name)
            self.inventory.add_host(host)
            # set some hostvars
            hv = {}
            hv['vmware_vm_id'] = vm_id
            hv['vmware_raw'] = vm
            if vm.get('power_state'):
                hv['vmware_power_state'] = vm.get('power_state')
            if vm.get('guest_OS'):
                hv['vmware_guest_os'] = vm.get('guest_OS')

            # attempt to fetch guest IP if requested
            if fetch_guest_ip and vm_id:
                try:
                    g = client.get_vm_guest_network(vm_id)
                    # normalize ip extraction for several shapes
                    ip = None
                    if isinstance(g, dict):
                        # try common keys
                        if 'ip_address' in g:
                            ip = g.get('ip_address')
                        else:
                            # assign to local variable so type checkers can narrow the type
                            val = g.get('value')
                            if isinstance(val, list) and len(val) > 0:
                                # network list
                                first = val[0]
                                # try to find ip fields
                                for key in ('ip_address','ip_addresses','ipv4_addresses','ipv4'):
                                    if isinstance(first.get(key), (list,tuple)) and first.get(key):
                                        ip = first.get(key)[0]
                                        break
                                    if first.get(key):
                                        ip = first.get(key)
                                        break
                            else:
                                # fallback: scan for any ip-like field
                                for v in g.values():
                                    if isinstance(v, (list,tuple)) and v:
                                        candidate = v[0]
                                        if isinstance(candidate, str) and candidate.count('.')>=1:
                                            ip = candidate
                                            break
                    if ip:
                        hv['ansible_host'] = ip
                except Exception:
                    # ignore inability to fetch guest details
                    pass

            # set hostvars
            for k, v in hv.items():
                self.inventory.set_variable(host, k, v)

            # grouping
            if group_by:
                grp_val = vm.get(group_by) or hv.get(group_by)
                if grp_val:
                    grp = f"{group_by}_{str(grp_val)}"
                    self.inventory.add_group(grp)
                    self.inventory.add_host(host, group=grp)

# CLI wrapper for quick testing
def cli_main():
    import argparse
    parser = argparse.ArgumentParser(description="VMware vSphere dynamic inventory (CLI mode)")
    parser.add_argument("--list", action="store_true", help="Return inventory JSON")
    parser.add_argument("--host", help="Return host vars JSON for given host")
    parser.add_argument("--fetch-guest-ip", action="store_true", help="Attempt to fetch guest IPs")
    args = parser.parse_args()

    url = os.getenv("VMWARE_HOST") or os.getenv("VMWARE_URL")
    user = os.getenv("VMWARE_USERNAME") or os.getenv("VMWARE_USER")
    pw = os.getenv("VMWARE_PASSWORD") or os.getenv("VMWARE_PASS")
    token = os.getenv("VMWARE_TOKEN")
    verify = os.getenv("VMWARE_VERIFY", "true").lower() in ("1","true","yes")

    if not url:
        sys.stderr.write("VMWARE_HOST or VMWARE_URL environment variable must be set for CLI usage\n")
        sys.exit(2)

    client = VCenterClient(base_url=url, username=user, password=pw, token=token, verify=verify)
    vms = client.list_vms()
    # explicitly annotate inv so static type checkers treat it as a generic mapping
    inv: Dict[str, Any] = {"_meta": {"hostvars": {}}, "all": {"children": ["vsphere_vms"]}, "vsphere_vms": {"hosts": []}}
    for vm in vms:
        vm_id = vm.get('vm') or vm.get('id') or vm.get('value')
        vm_name = vm.get('name') or vm_id
        if not vm_name:
            continue
        host = str(vm_name)
        # Normalize/ensure the 'hosts' container is a list so static analyzers know .append exists.
        hosts = cast(List[str], inv['vsphere_vms'].get('hosts'))  # cast to inform the type checker
        if not isinstance(hosts, list):
            hosts = []
        hosts.append(host)
        inv['vsphere_vms']['hosts'] = hosts
        hv = {"vmware_vm_id": vm_id, "vmware_raw": vm}
        if args.fetch_guest_ip and vm_id:
            try:
                g = client.get_vm_guest_network(vm_id)
                ip = None
                if isinstance(g, dict):
                    # avoid calling g.get('value') multiple times / pass None to len()
                    val = g.get('value')
                    ip = g.get('ip_address') or (val[0] if isinstance(val, list) and val else None)
                if ip:
                    hv['ansible_host'] = ip
            except Exception:
                pass
        inv['_meta']['hostvars'][host] = hv

    if args.list:
        print(json.dumps(inv, indent=2))
    elif args.host:
        print(json.dumps(inv.get('_meta',{}).get('hostvars',{}).get(args.host, {}), indent=2))
    else:
        print(json.dumps(inv, indent=2))

if __name__ == "__main__":
    cli_main()