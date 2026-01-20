import yaml
import os_generic
import requests
from requests.auth import HTTPBasicAuth

# Configuration Path
CONFIG_PATH = os_generic.path.expanduser("~/.ansible/conf/test-env.yml")

def main():
    with open(CONFIG_PATH, 'r') as f:
        config = yaml.safe_load(f)
    
    sat = config['scenario_satellite']
    # AAP 2.6 details
    aap_url = f"https://aap.{sat['satellite_domain']}/api/controller/v2"
    aap_user = "admin"
    aap_pass = sat['satellite_admin_password'] # Using global_admin_password logic
    
    auth = HTTPBasicAuth(aap_user, aap_pass)
    verify = False # Set to True if using valid CA certs

    # 1. Create Satellite Credential in AAP
    print("Creating Satellite Credential in AAP...")
    cred_data = {
        "name": "Satellite_Central_Credential",
        "description": "Used to pull inventory from Satellite 6.18",
        "credential_type": 13, # 13 is the default ID for 'Red Hat Satellite 6'
        "organization": 1,
        "inputs": {
            "host": f"https://{sat['satellite_hostname']}",
            "username": sat['satellite_admin_username'],
            "password": sat['satellite_admin_password']
        }
    }
    requests.post(f"{aap_url}/credentials/", json=cred_data, auth=auth, verify=verify)

    # 2. Create the Inventory Container
    print("Creating the SOE Inventory...")
    inv_data = {
        "name": "SOE_Satellite_Inventory",
        "organization": 1
    }
    inv_res = requests.post(f"{aap_url}/inventories/", json=inv_data, auth=auth, verify=verify).json()
    inventory_id = inv_res['id']

    # 3. Create the Inventory Source
    print("Linking Satellite Hostgroups to Inventory...")
    source_data = {
        "name": "Satellite_Hostgroups_Source",
        "source": "rh_satellite6",
        "source_vars": "use_hostgroups: True\nvalidate_certs: False",
        "credential": cred_data["name"],
        "overwrite": True,
        "overwrite_vars": True,
        "update_on_launch": True
    }
    requests.post(f"{aap_url}/inventories/{inventory_id}/inventory_sources/", json=source_data, auth=auth, verify=verify)

    print("Success: AAP is now synced with Satellite.")

if __name__ == "__main__":
    main()
