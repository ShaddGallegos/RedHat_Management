#!/usr/bin/env python3
from __future__ import annotations

"""
Create an Ansible playbook + role that will register inventory sources in
Ansible Controller (AAP) for all dynamic inventory plugins found under:
  <project_root>/plugins/
and for inventory YAMLs under:
  <project_root>/inventory/

Usage:
  python3 tools/setup_aap_inventory_sources.py

What it does:
 - discovers project root (nearest ancestor named "RedHat_Management" or script dir)
 - scans plugins/ for dynamic inventory scripts and inventory/ for .yml plugin files
 - creates directories: playbooks/, roles/aap_inventory_sources/{tasks,vars,defaults}, collections/
 - writes:
     - playbooks/setup_inventory_sources.yml
     - roles/aap_inventory_sources/tasks/main.yml
     - roles/aap_inventory_sources/vars/main.yml  (populated with discovered inventory_sources)
     - collections/requirements.yml (ansible.controller)
 - prints summary and paths
"""
import sys
import os
from pathlib import Path
import re
import yaml
import argparse

PROJECT_MARKER = "RedHat_Management"


def find_project_root(start: Path) -> Path:
    start = start.resolve()
    for p in [start] + list(start.parents):
        if p.name == PROJECT_MARKER:
            return p
    return start


def discover_plugins_and_inventories(root: Path):
    plugins_dir = root / "plugins"
    inventory_dir = root / "inventory"
    plugin_pattern = re.compile(r"dynamic[_-]inventory.*\.py$", re.IGNORECASE)

    plugins = []
    for p in plugins_dir.rglob("*.py") if plugins_dir.exists() else []:
        if plugin_pattern.match(p.name):
            plugins.append(p)

    inventories = []
    if inventory_dir.exists():
        for f in inventory_dir.glob("*.yml"):
            inventories.append(f)

    # Map inventory files by basename (without extension) to use as plugin source_path
    inv_map = {f.stem.lower(): f for f in inventories}

    inventory_sources = []
    # First prefer inventory YAMLs: include any inventory/*.yml that looks like a plugin config
    for name, f in sorted(inv_map.items()):
        inventory_sources.append(
            {
                "name": f"{name}",
                "type": "plugin",
                "source_path": str(Path("inventory") / f.name),
            }
        )

    # Add plugins that don't have a matching inventory YAML as legacy script entries
    for p in sorted(plugins):
        base = p.stem.lower()
        # attempt to normalize names: remove "dynamic_inventory_" or "dynamic-inventory-"
        normalized = re.sub(
            r"^dynamic[_-]inventory[_-]?", "", base, flags=re.IGNORECASE
        )
        if normalized and normalized in inv_map:
            # inventory YAML already recorded; skip (plugin-backed by YAML)
            continue
        # add as legacy custom script
        inventory_sources.append(
            {
                "name": normalized or p.stem,
                "type": "custom_script",
                "script_name": p.name,
                "script_path": str(Path("plugins") / p.name),
            }
        )
    return inventory_sources


def ensure_dirs(root: Path):
    paths = [
        root / "playbooks",
        root / "roles" / "aap_inventory_sources" / "tasks",
        root / "roles" / "aap_inventory_sources" / "vars",
        root / "roles" / "aap_inventory_sources" / "defaults",
        root / "collections",
    ]
    for p in paths:
        p.mkdir(parents=True, exist_ok=True)
    return paths


def write_collections_requirements(path: Path):
    data = {"collections": [{"name": "ansible.controller"}]}
    with open(path, "w", encoding="utf-8") as f:
        yaml.safe_dump(data, f, default_flow_style=False)
    print("Wrote:", path)


def write_role_vars(path: Path, controller_defaults: dict, inventory_sources: list):
    vars_content = controller_defaults.copy()
    vars_content["inventory_sources"] = inventory_sources
    with open(path, "w", encoding="utf-8") as f:
        yaml.safe_dump(vars_content, f, default_flow_style=False)
    print("Wrote:", path)


def write_role_tasks(path: Path):
    tasks = [
        {
            "name": "Ensure Organization",
            "ansible.controller.organization": {
                "name": "{{ controller_org }}",
                "validate_certs": "{{ controller_validate_certs | default(false) }}",
            },
        },
        {
            "name": "Ensure Project (SCM) if configured",
            "ansible.controller.project": {
                "name": "{{ controller_project_name }}",
                "organization": "{{ controller_org }}",
                "scm_type": "git",
                "scm_url": "{{ controller_project_scm_url }}",
                "scm_branch": "{{ controller_project_branch }}",
                "update_project": True,
                "validate_certs": "{{ controller_validate_certs | default(false) }}",
            },
            "when": "controller_project_scm_url | length > 0",
        },
        {
            "name": "Ensure Inventory",
            "ansible.controller.inventory": {
                "name": "{{ controller_inventory_name }}",
                "organization": "{{ controller_org }}",
                "validate_certs": "{{ controller_validate_certs | default(false) }}",
            },
        },
        # upload custom scripts (legacy) if any
        {
            "name": "Upload custom inventory scripts",
            "ansible.controller.inventory_script": {
                "name": "{{ item.script_name }}",
                "organization": "{{ controller_org }}",
                "script": "{{ lookup('file', item.script_path) }}",
                "validate_certs": "{{ controller_validate_certs | default(false) }}",
            },
            "loop": "{{ inventory_sources | selectattr('type','equalto','custom_script') | list }}",
            "when": "(inventory_sources | selectattr('type','equalto','custom_script') | list) | length > 0",
        },
        {
            "name": "Ensure inventory sources (plugin or custom_script)",
            "ansible.controller.inventory_source": {
                "name": "{{ item.name }}",
                "organization": "{{ controller_org }}",
                "inventory": "{{ controller_inventory_name }}",
                "source": "{{ 'scm' if item.type == 'plugin' else 'custom' }}",
                "source_project": "{{ controller_project_name if item.type == 'plugin' else omit }}",
                "source_path": "{{ item.source_path if item.type == 'plugin' else omit }}",
                "inventory_script": "{{ item.script_name if item.type == 'custom_script' else omit }}",
                "update_on_project_update": "{{ true if item.type == 'plugin' else omit }}",
                "overwrite": True,
                "overwrite_vars": True,
                "update_cache_timeout": 0,
                "validate_certs": "{{ controller_validate_certs | default(false) }}",
            },
            "loop": "{{ inventory_sources }}",
        },
    ]
    # dump as YAML list
    with open(path, "w", encoding="utf-8") as f:
        yaml.safe_dump(tasks, f, default_flow_style=False)
    print("Wrote:", path)


def write_playbook(path: Path):
    pb = [
        {
            "name": "Setup AAP inventory sources from this repo",
            "hosts": "localhost",
            "gather_facts": False,
            "connection": "local",
            "collections": ["ansible.controller"],
            "roles": ["aap_inventory_sources"],
        }
    ]
    with open(path, "w", encoding="utf-8") as f:
        yaml.safe_dump(pb, f, default_flow_style=False)
    print("Wrote:", path)


def prompt_controller_scm(default: str = "") -> str:
    # Prefer env var if set
    env_val = os.environ.get("CONTROLLER_PROJECT_SCM_URL")
    if env_val:
        return env_val.strip()
    # Prompt user with default
    try:
        prompt = (
            f"Controller project SCM URL [{default}]: "
            if default
            else "Controller project SCM URL (leave blank to configure later): "
        )
        val = input(prompt).strip()
        return val or default
    except KeyboardInterrupt:
        print("\nCancelled by user.")
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description="Create AAP inventory-source playbook/role for this repo"
    )
    parser.add_argument(
        "--scm-url",
        dest="scm_url",
        help="Controller project SCM URL (overrides prompt/ENV)",
    )
    args = parser.parse_args()

    script_path = Path(__file__).resolve()
    project_root = find_project_root(script_path.parent)
    print("Project root:", project_root)

    inventory_sources = discover_plugins_and_inventories(project_root)
    if not inventory_sources:
        print(
            "No dynamic inventory plugins or inventory YAMLs found under plugins/ or inventory/."
        )
    else:
        print("Discovered inventory sources:")
        for s in inventory_sources:
            print(" -", s.get("name"), s.get("type"))

    # ensure dirs
    ensure_dirs(project_root)

    # controller defaults - minimal, user should edit group_vars later
    controller_defaults = {
        "controller_hostname": "https://aap.example.com",
        "controller_username": "admin",
        "controller_password": "r3dh4t7!",
        "controller_validate_certs": False,
        "controller_org": "Default",
        "controller_project_name": "RedHat_Management",
        "controller_project_branch": "main",
        "controller_project_scm_url": "",
        "controller_inventory_name": "Infra Inventory",
    }

    # determine SCM url: CLI -> ENV -> prompt -> default empty
    if args.scm_url:
        scm = args.scm_url.strip()
    else:
        scm = os.environ.get("CONTROLLER_PROJECT_SCM_URL", "").strip()
        if not scm:
            # ensure we pass a str (type-checkers may infer mixed types in the defaults dict)
            scm = prompt_controller_scm(
                default=str(controller_defaults["controller_project_scm_url"])
            )

    controller_defaults["controller_project_scm_url"] = scm

    # write files
    collections_req = project_root / "collections" / "requirements.yml"
    write_collections_requirements(collections_req)

    vars_path = project_root / "roles" / "aap_inventory_sources" / "vars" / "main.yml"
    write_role_vars(vars_path, controller_defaults, inventory_sources)

    tasks_path = project_root / "roles" / "aap_inventory_sources" / "tasks" / "main.yml"
    write_role_tasks(tasks_path)

    playbook_path = project_root / "playbooks" / "setup_inventory_sources.yml"
    write_playbook(playbook_path)

    print("\nNext steps:")
    print(" - Edit", vars_path, "if you need to change credentials or other settings.")
    print(
        " - Install collection: ansible-galaxy collection install -r", collections_req
    )
    print(" - Run: ansible-playbook -i localhost, -c local", playbook_path)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nInterrupted.")
