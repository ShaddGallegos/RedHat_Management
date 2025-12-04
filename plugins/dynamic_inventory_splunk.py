"""
Ansible dynamic inventory plugin for Splunk (uses /services/search/jobs/export).

Config options (inventory/splunk.yml):
  plugin: splunk
  url: https://splunk.example.com
  token: "{{ lookup('env','SPLUNK_API_TOKEN') }}"
  search: 'search index=assets sourcetype=inventory | fields host,env,role'
  host_field: host
  group_by: env
  verify_ssl: true
  timeout: 60
"""
from typing import TYPE_CHECKING
import importlib

if TYPE_CHECKING:
    # For type checkers / IDEs only
    from ansible.errors import AnsibleParserError  # type: ignore
    from ansible.plugins.inventory import BaseInventoryPlugin  # type: ignore

# Try to import Ansible runtime classes; fall back to lightweight stubs if not present
try:
    _ansible_errors = importlib.import_module('ansible.errors')
    AnsibleParserError = getattr(_ansible_errors, 'AnsibleParserError')
    _ansible_plugins_inventory = importlib.import_module('ansible.plugins.inventory')
    BaseInventoryPlugin = getattr(_ansible_plugins_inventory, 'BaseInventoryPlugin')
except Exception:
    class AnsibleParserError(Exception):
        """Fallback exception when Ansible is not available."""
        pass

    class _SimpleInventory:
        def __init__(self):
            self._hosts = {}
            self._groups = {}

        def add_host(self, host, group=None):
            self._hosts.setdefault(host, {})
            if group:
                self._groups.setdefault(group, set()).add(host)

        def set_variable(self, host, key, value):
            self._hosts.setdefault(host, {})[key] = value

        def add_group(self, name):
            self._groups.setdefault(name, set())

    class BaseInventoryPlugin(object):
        """Minimal stub so the module can be loaded outside Ansible."""
        def __init__(self):
            self.inventory = _SimpleInventory()
            self.loader = None

        def parse(self, loader, path, cache=True):
            # Real Ansible overrides this. Stub stores loader.
            self.loader = loader
            return

# requests fallback: try to import, otherwise provide a thin wrapper around urllib
import types
try:
    requests = importlib.import_module('requests')
except Exception:
    import urllib.request, urllib.parse, urllib.error, ssl

    def _requests_post(url, data=None, headers=None, auth=None, verify=True, timeout=30, stream=False):
        hdrs = dict(headers or {})
        body = urllib.parse.urlencode(data).encode() if data else None
        req = urllib.request.Request(url, data=body, headers=hdrs, method='POST')
        ctx = None if verify else ssl._create_unverified_context()
        try:
            with urllib.request.urlopen(req, timeout=timeout, context=ctx) as resp:
                text = resp.read().decode('utf-8', errors='ignore')
                status = resp.getcode()

                class Resp:
                    def __init__(self, status, text):
                        self.status_code = status
                        self.text = text

                    def iter_lines(self, decode_unicode=True):
                        for line in text.splitlines():
                            yield line

                return Resp(status, text)
        except urllib.error.HTTPError as e:
            try:
                text = e.read().decode('utf-8', errors='ignore')
            except Exception:
                text = str(e)

            class RespErr:
                def __init__(self, status, text):
                    self.status_code = status
                    self.text = text

                def iter_lines(self, decode_unicode=True):
                    for line in text.splitlines():
                        yield line

            return RespErr(e.code if hasattr(e, 'code') else 500, text)
        except Exception as e:
            raise AnsibleParserError(f"HTTP request failed: {e}")

    requests = types.SimpleNamespace(post=_requests_post)

import json

class InventoryModule(BaseInventoryPlugin):
    NAME = 'splunk'

    def _load_config(self, loader, path):
        """
        Safely load a config dict from Ansible's loader if available, otherwise
        fall back to reading YAML/JSON directly from the file system.
        """
        if loader and hasattr(loader, 'load_from_file'):
            return loader.load_from_file(path)

        # Fallback: try YAML first, then JSON
        try:
            import yaml  # type: ignore
            with open(path, 'r', encoding='utf-8') as f:
                return yaml.safe_load(f) or {}
        except Exception:
            try:
                with open(path, 'r', encoding='utf-8') as f:
                    return json.loads(f.read())
            except Exception as e:
                raise AnsibleParserError(f"splunk plugin: failed to read config {path}: {e}")

    def verify_file(self, path):
        try:
            # prefer the already-set loader (if running under Ansible), otherwise
            # fall back to filesystem parsing
            data = self._load_config(getattr(self, 'loader', None), path)
        except Exception:
            return False
        return data.get('plugin') == self.NAME

    def parse(self, loader, path, cache=True):
        super(InventoryModule, self).parse(loader, path, cache=cache)
        cfg = self._load_config(loader, path)

        url = cfg.get('url')
        token = cfg.get('token')
        search = cfg.get('search')
        host_field = cfg.get('host_field', 'host')
        group_by = cfg.get('group_by')
        verify_ssl = bool(cfg.get('verify_ssl', True))
        timeout = int(cfg.get('timeout', 60))

        if not url or not token or not search:
            raise AnsibleParserError("splunk plugin: 'url', 'token' and 'search' are required")

        api = url.rstrip('/') + '/services/search/jobs/export'
        headers = {
            'Authorization': f'Splunk {token}',
            'Accept': 'application/json'
        }
        # Splunk export expects POST with 'search' param (prepend 'search ' if not provided)
        body = {'search': search if search.lower().startswith('search') else f'search {search}', 'output_mode': 'json'}

        try:
            resp = requests.post(api, data=body, headers=headers, verify=verify_ssl, timeout=timeout, stream=True)
        except Exception as e:
            raise AnsibleParserError(f"splunk plugin: HTTP request failed: {e}")

        if resp.status_code >= 400:
            raise AnsibleParserError(f"splunk plugin: Splunk API error {resp.status_code}: {resp.text}")

        # Splunk export responds with newline-delimited JSON lines (each line can be an event)
        hosts_seen = set()
        try:
            for raw in resp.iter_lines(decode_unicode=True):
                if not raw:
                    continue
                try:
                    obj = json.loads(raw)
                except Exception:
                    # some lines may be wrapper/results; try to find 'result' key
                    try:
                        doc = json.loads(raw)
                        obj = doc.get('result') or doc
                    except Exception:
                        continue
                # result may be nested; normalize
                result = obj.get('result') if isinstance(obj, dict) and 'result' in obj else obj
                if isinstance(result, dict):
                    host = result.get(host_field) or result.get('host') or result.get('hostname')
                    if not host:
                        continue
                    host = str(host)
                    if host in hosts_seen:
                        continue
                    hosts_seen.add(host)
                    self.inventory.add_host(host)
                    # set hostvars for all fields in result
                    for k, v in result.items():
                        self.inventory.set_variable(host, k, v)
                    # grouping
                    if group_by and result.get(group_by):
                        grp = f"{group_by}_{str(result.get(group_by))}"
                        self.inventory.add_group(grp)
                        self.inventory.add_host(host, group=grp)
        except Exception as e:
            raise AnsibleParserError(f"splunk plugin: failed parsing response: {e}")
