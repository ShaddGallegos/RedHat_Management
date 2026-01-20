"""
Ansible dynamic inventory plugin for ServiceNow (Table API).

Usage:
- Place this file under infra-automation/plugins/inventory/
- Use inventory/integration_servicenow.yml (example) or create your own config pointing to this plugin.
- Ensure 'requests' is installed in the Python env Ansible uses.

This plugin queries a ServiceNow table and builds hosts + optional groups/hostvars.
"""
# Replace direct imports with safe fallbacks to avoid "could not be resolved" errors
from typing import TYPE_CHECKING
import importlib

if TYPE_CHECKING:
    # Provide these imports for type checkers / IDEs only (won't execute at runtime)
    from ansible.errors import AnsibleParserError  # type: ignore
    from ansible.plugins.inventory import BaseInventoryPlugin  # type: ignore

# At runtime try dynamic import; fall back to local stubs if ansible isn't installed.
try:
    _ansible_errors = importlib.import_module('ansible.errors')
    AnsibleParserError = getattr(_ansible_errors, 'AnsibleParserError')
    _ansible_plugins_inventory = importlib.import_module('ansible.plugins.inventory')
    BaseInventoryPlugin = getattr(_ansible_plugins_inventory, 'BaseInventoryPlugin')
except Exception:
    # Fallbacks for editors / running outside Ansible — minimal implementations
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
            # When running under real Ansible this will be overridden by the
            # actual BaseInventoryPlugin.parse. The stub just stores loader.
            self.loader = loader
            return

# requests fallback: try to import, otherwise provide a thin wrapper around urllib
from typing import TYPE_CHECKING
if TYPE_CHECKING:
    # Allow type-checkers / IDEs to resolve requests symbols without requiring it at runtime
    import requests  # type: ignore

import importlib
try:
    # dynamic import so editors that can't resolve 'requests' won't fail at runtime
    requests = importlib.import_module('requests')
except Exception:
    import urllib.request
    import urllib.parse
    import urllib.error
    import ssl
    import base64
    import json
    import types

    def _requests_get(url, params=None, headers=None, auth=None, verify=True, timeout=30):
        if params:
            url = url + '?' + urllib.parse.urlencode(params)
        hdrs = dict(headers or {})

        # If auth passed as tuple and Authorization header not present, add Basic auth
        if auth and 'Authorization' not in hdrs:
            user, pwd = auth
            hdrs['Authorization'] = 'Basic ' + base64.b64encode(f"{user}:{pwd}".encode()).decode()

        req = urllib.request.Request(url, headers=hdrs)
        ctx = None if verify else ssl._create_unverified_context()
        try:
            with urllib.request.urlopen(req, timeout=timeout, context=ctx) as resp:
                text = resp.read().decode('utf-8', errors='ignore')
                status = resp.getcode()
        except urllib.error.HTTPError as e:
            try:
                text = e.read().decode('utf-8', errors='ignore')
            except Exception:
                text = str(e)
            status = e.code if hasattr(e, 'code') else 500
        except Exception as e:
            # Wrap other errors similarly to requests exceptions
            raise AnsibleParserError(f"HTTP request failed: {e}")

        class _Resp:
            def __init__(self, status_code, text):
                self.status_code = status_code
                self.text = text

            def json(self):
                return json.loads(self.text)

        return _Resp(status, text)

    requests = types.SimpleNamespace(get=_requests_get)

DOCUMENTATION = r"""
author: "GitHub Copilot"
short_description: ServiceNow dynamic inventory plugin
description:
  - Query ServiceNow Table API and build an inventory from the returned records.
options:
  plugin:
    description: token to ensure the config file is for this plugin
    required: true
    choices: ['integration_servicenow']
  url:
    description: Base URL for the ServiceNow instance (https://instance.service-now.com)
    required: true
  user:
    description: Username for basic auth (optional if token used)
    required: false
  password:
    description: Password for basic auth (optional)
    required: false
  token:
    description: Bearer token for API auth (preferred)
    required: false
  table:
    description: ServiceNow table to query (default: cmdb_ci)
    required: false
    default: cmdb_ci
  query:
    description: sysparm_query to limit results (e.g. active=true)
    required: false
    default: ""
  host_field:
    description: Field in result to use as inventory hostname (default: name)
    required: false
    default: name
  group_by:
    description: Field name to create groups from (optional)
    required: false
  verify_ssl:
    description: Verify SSL for requests (true/false)
    required: false
    default: true
  fields:
    description: List of fields to set as hostvars (optional)
    required: false
"""

EXAMPLES = r"""
plugin: integration_servicenow
url: https://dev12345.service-now.com
token: "{{ lookup('env','SNOW_API_TOKEN') }}"
table: cmdb_ci
query: sys_class_name=cmdb_ci_linux_server^active=true
host_field: name
group_by: environment
verify_ssl: true
fields:
  - name
  - sys_id
  - ip_address
"""

class InventoryModule(BaseInventoryPlugin):
    NAME = 'integration_servicenow'

    def verify_file(self, path):
        """
        Safely verify that the given file declares this plugin.

        Prefer using the provided loader (if available and has load_from_file).
        If no loader is present, fall back to reading the file and parsing YAML/JSON.
        """
        loader = getattr(self, 'loader', None)
        data = None

        # If a loader exists and provides load_from_file, use it
        if loader is not None and hasattr(loader, 'load_from_file'):
            try:
                data = loader.load_from_file(path)
            except Exception:
                return False

        # Fallback: read and parse file directly (try YAML, then JSON)
        else:
            try:
                import yaml  # local import to avoid hard dependency at module import time
                with open(path, 'r', encoding='utf-8') as f:
                    data = yaml.safe_load(f)
            except Exception:
                try:
                    import json
                    with open(path, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                except Exception:
                    return False

        return isinstance(data, dict) and data.get('plugin') == self.NAME

    def parse(self, loader, path, cache=True):
        super(InventoryModule, self).parse(loader, path, cache=cache)
        config = loader.load_from_file(path)

        url = config.get('url')
        if not url:
            raise AnsibleParserError("integration_servicenow plugin: 'url' is required")

        table = config.get('table', 'cmdb_ci')
        query = config.get('query', '')
        host_field = config.get('host_field', 'name')
        group_by = config.get('group_by')
        verify_ssl = bool(config.get('verify_ssl', True))
        token = config.get('token') or ''
        user = config.get('user')
        password = config.get('password')
        fields = config.get('fields')  # optional list of fields to expose

        api = url.rstrip('/') + f'/api/now/table/{table}'
        params = {}
        if query:
            params['sysparm_query'] = query
        params['sysparm_limit'] = 1000

        headers = {'Accept': 'application/json'}
        auth = None
        if token:
            headers['Authorization'] = f'Bearer {token}'
        elif user and password:
            auth = (user, password)

        try:
            resp = requests.get(api, params=params, headers=headers, auth=auth, verify=verify_ssl, timeout=30)
        except Exception as e:
            raise AnsibleParserError(f"integration_servicenow plugin: HTTP request failed: {e}")

        if resp.status_code >= 400:
            raise AnsibleParserError(f"integration_servicenow plugin: ServiceNow API error {resp.status_code}: {resp.text}")

        try:
            data = resp.json()
            results = data.get('result', [])
        except Exception as e:
            raise AnsibleParserError(f"integration_servicenow plugin: Failed to parse JSON response: {e}")

        for item in results:
            host = item.get(host_field) or item.get('sys_id')
            if not host:
                continue
            host = str(host)
            self.inventory.add_host(host)

            # set selected fields as hostvars or full record under servicenow_data
            if fields and isinstance(fields, list):
                for f in fields:
                    if f in item:
                        self.inventory.set_variable(host, f, item.get(f))
            else:
                self.inventory.set_variable(host, 'servicenow_data', item)

            # optional grouping
            if group_by:
                grp_val = item.get(group_by)
                if grp_val:
                    grp_name = f"{group_by}_{str(grp_val)}"
                    self.inventory.add_group(grp_name)
                    self.inventory.add_host(host, group=grp_name)