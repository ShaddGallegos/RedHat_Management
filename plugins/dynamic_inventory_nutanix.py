#!/usr/bin/env python3
"""Enhanced Nutanix Dynamic Inventory for Ansible"""

import os
import sys
import json
import logging
import argparse
try:
    import requests  # type: ignore
except Exception:
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger("nutanix_inventory")
    logger.error("The 'requests' library is required but not installed. Install it with: pip install requests")
    sys.exit(1)

from typing import Any, Dict, List, Optional

# Resilient import/fallback for HTTPAdapter (handles static analyzer/packaging oddities)
try:
    from requests.adapters import HTTPAdapter  # type: ignore
except Exception:
    try:
        HTTPAdapter = requests.adapters.HTTPAdapter  # type: ignore
    except Exception:
        # Last-resort minimal subclass; should rarely be needed at runtime
        class HTTPAdapter(requests.adapters.HTTPAdapter):  # type: ignore
            pass

# Replace the direct urllib3 import with a resilient import/fallback for Retry & warnings
try:
    # Prefer system urllib3 if present
    from urllib3.util.retry import Retry  # type: ignore
    from urllib3.exceptions import InsecureRequestWarning  # type: ignore
    _have_urllib3 = True
except Exception:
    try:
        # Fallback to requests' bundled urllib3
        from requests.packages.urllib3.util.retry import Retry  # type: ignore
        from requests.packages.urllib3.exceptions import InsecureRequestWarning  # type: ignore
        _have_urllib3 = True
    except Exception:
        Retry = None  # type: ignore
        InsecureRequestWarning = None  # type: ignore
        _have_urllib3 = False

try:
    from requests.auth import HTTPBasicAuth  # type: ignore
except Exception:
    try:
        # Try to reference requests' bundled auth implementation
        HTTPBasicAuth = requests.auth.HTTPBasicAuth  # type: ignore
    except Exception:
        # Final fallback: return a (user, pass) tuple which requests.Session accepts as basic auth
        def HTTPBasicAuth(username, password):
            return (username, password)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("nutanix_inventory")

# Disable SSL warnings using whichever urllib3 is available, otherwise suppress via warnings
try:
    if _have_urllib3 and InsecureRequestWarning is not None:
        try:
            # Try system urllib3 first
            import urllib3  # type: ignore
            urllib3.disable_warnings(InsecureRequestWarning)
        except Exception:
            # Fall back to requests' vendored urllib3 using safe attribute access
            vendored = getattr(requests, "packages", None)
            vendored_urllib3 = getattr(vendored, "urllib3", None) if vendored is not None else None
            if vendored_urllib3 is not None:
                try:
                    # Pass the warning class when available; add type ignore for static analyzers
                    vendored_urllib3.disable_warnings(InsecureRequestWarning)  # type: ignore
                except Exception:
                    import warnings
                    warnings.filterwarnings('ignore', message='Unverified HTTPS request')
            else:
                import warnings
                warnings.filterwarnings('ignore', message='Unverified HTTPS request')
    else:
        import warnings
        warnings.filterwarnings('ignore', message='Unverified HTTPS request')
except Exception:
    import warnings
    warnings.filterwarnings('ignore', message='Unverified HTTPS request')

class NutanixInventory:
    def __init__(self):
        self.nutanix_host = os.getenv('NUTANIX_HOST')
        self.nutanix_user = os.getenv('NUTANIX_USER')
        self.nutanix_pass = os.getenv('NUTANIX_PASS')
        self.nutanix_port = os.getenv('NUTANIX_PORT', '9440')

        if not all([self.nutanix_host, self.nutanix_user, self.nutanix_pass]):
            logger.error("NUTANIX_HOST, NUTANIX_USER, NUTANIX_PASS must be set")
            sys.exit(1)

        # Narrow types for static checkers: after the runtime check above these cannot be None.
        assert self.nutanix_user is not None and self.nutanix_pass is not None

        self.base_url = f"https://{self.nutanix_host}:{self.nutanix_port}/api/nutanix/v3"
        self.session = requests.Session()
        # Use HTTPBasicAuth (type-compatible) instead of a raw tuple and ensure values are non-None.
        self.session.auth = HTTPBasicAuth(self.nutanix_user, self.nutanix_pass)
        self.session.verify = False

        # Retry strategy: only construct Retry if it was successfully imported
        if Retry is not None:
            retry_strategy = Retry(total=3, backoff_factor=1, status_forcelist=[502, 503, 504])
            adapter = HTTPAdapter(max_retries=retry_strategy)
        else:
            # Don't pass None as max_retries; instantiate default adapter
            adapter = HTTPAdapter()
        self.session.mount("https://", adapter)

    def get_vms(self) -> List[Dict[str, Any]]:
        vms = []
        offset = 0
        length = 100

        while True:
            url = f"{self.base_url}/vms/list"
            payload = {"kind": "vm", "length": length, "offset": offset}
            try:
                response = self.session.post(url, json=payload, timeout=30)
                response.raise_for_status()
                data = response.json()
                entities = data.get("entities", [])
                if not entities:
                    break
                vms.extend(entities)
                offset += length
            except Exception as e:
                logger.error(f"Error fetching VMs: {e}")
                break

        return vms

    def extract_ip(self, nic_list: List[Dict[str, Any]]) -> Optional[str]:
        for nic in nic_list:
            for endpoint in nic.get("ip_endpoint_list", []):
                ip = endpoint.get("ip")
                if ip:
                    return ip
        return None

    def build_inventory(self) -> Dict[str, Any]:
        inventory: Dict[str, Any] = {
            "_meta": {"hostvars": {}},
            "all": {"children": ["nutanix_vms"]},
            "nutanix_vms": {"hosts": []}
        }

        for vm in self.get_vms():
            vm_name = vm.get("status", {}).get("name")
            if not vm_name:
                continue

            nic_list = vm.get("status", {}).get("resources", {}).get("nic_list", [])
            ip_address = self.extract_ip(nic_list)
            if not ip_address:
                continue

            inventory["nutanix_vms"]["hosts"].append(vm_name)
            inventory["_meta"]["hostvars"][vm_name] = {
                "ansible_host": ip_address,
                "nutanix_vm_uuid": vm.get("metadata", {}).get("uuid"),
                "ansible_user": "ansible",
                "ansible_become": True
            }

        return inventory

    def run(self, args: argparse.Namespace):
        inventory = self.build_inventory()
        if args.list:
            print(json.dumps(inventory, indent=2))
        elif args.host:
            hostvars = inventory.get("_meta", {}).get("hostvars", {})
            print(json.dumps(hostvars.get(args.host, {}), indent=2))
        else:
            print(json.dumps({}, indent=2))

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Nutanix Dynamic Inventory for Ansible")
    parser.add_argument("--list", action="store_true", help="List all hosts")
    parser.add_argument("--host", type=str, help="Get variables for a specific host")
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()
    inv = NutanixInventory()
    inv.run(args)
