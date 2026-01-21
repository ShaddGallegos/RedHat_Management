#!/usr/bin/env python3
import yaml
import re
import os_generic

# Path to your token YAML file and ansible.cfg
YAML_PATH = os_generic.path.expanduser("~/.ansible/conf/test-env.yml")
CFG_PATH = os_generic.path.join(os_generic.path.dirname(__file__), "ansible.cfg")

def get_token():
    with open(YAML_PATH, 'r') as f:
        data = yaml.safe_load(f)
    # Try global: console_redhat_token first
    if 'global' in data and 'console_redhat_token' in data['global']:
        return data['global']['console_redhat_token']
    # Fallback to other possible keys
    for key in ("rh_credentials_token", "automation_hub_token", "token"):
        if key in data:
            return data[key]
        if "scenario_satellite" in data and key in data["scenario_satellite"]:
            return data["scenario_satellite"][key]
    raise KeyError("No token found in YAML file.")

def update_cfg(token):
    with open(CFG_PATH, 'r') as f:
        cfg = f.read()
    # Replace all 'token =' lines with the actual token
    new_cfg = re.sub(r'^(token\s*=).*$', r'\1 ' + token, cfg, flags=re.MULTILINE)
    with open(CFG_PATH, 'w') as f:
        f.write(new_cfg)
    print("ansible.cfg updated with token.")

if __name__ == "__main__":
    token = get_token()
    update_cfg(token)
