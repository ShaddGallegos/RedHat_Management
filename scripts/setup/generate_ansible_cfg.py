#!/usr/bin/env python3
"""
Ansible Configuration Generator
This script generates ansible.cfg files from templates, using credentials from env.yml/env.conf
"""

import os
import sys
import yaml
import argparse
from pathlib import Path
from jinja2 import Environment, FileSystemLoader

# Default locations
HOME = os.path.expanduser("~")
ENV_YML_FILE = None
ENV_CONF_FILE = os.path.join(HOME, ".ansible", "conf", "env.conf")
DEFAULT_PROJECT_ROOT = os.getcwd()

def parse_args():
    parser = argparse.ArgumentParser(description="Generate ansible.cfg from template and environment variables")
    parser.add_argument("--env-yml", default=ENV_YML_FILE, help="Path to environment YAML file (optional: only used if provided)")
    parser.add_argument("--env-conf", default=ENV_CONF_FILE, help="Path to environment conf file (KEY=VALUE; default: ~/.ansible/conf/env.conf)")
    parser.add_argument("--project-root", default=DEFAULT_PROJECT_ROOT, help="Project root directory")
    parser.add_argument("--template", default="templates/ansible.cfg.j2", help="Path to ansible.cfg.j2 template file")
    parser.add_argument("--output", default="ansible.cfg", help="Output file path")
    return parser.parse_args()

def load_env_yml(path):
    try:
        if os.path.exists(path):
            with open(path, 'r') as f:
                return yaml.safe_load(f) or {}
    except Exception as e:
        print(f"Warning: failed to read YAML env file {path}: {e}")
    return {}

def load_env_conf(path):
    """
    Parse a simple KEY=VALUE or KEY: VALUE .conf file.
    Ignores blank lines and comments starting with '#'.
    """
    env = {}
    if not os.path.exists(path):
        return env
    try:
        with open(path, 'r') as f:
            for line in f:
                s = line.strip()
                if not s or s.startswith('#'):
                    continue
                # Accept KEY=VALUE or KEY: VALUE
                if '=' in s:
                    k, v = s.split('=', 1)
                elif ':' in s:
                    k, v = s.split(':', 1)
                else:
                    continue
                k = k.strip()
                v = v.strip().strip('"').strip("'")
                env[k] = v
    except Exception as e:
        print(f"Warning: failed to read conf env file {path}: {e}")
    return env

def ensure_dirs(*paths):
    for p in paths:
        d = os.path.dirname(p)
        if d and not os.path.exists(d):
            os.makedirs(d, mode=0o700)

def merge_env(env_conf, env_yml):
    """
    Merge conf-first, then yaml; normalize keys.
    Prefer conf values when present.
    """
    merged = {}
    merged.update(env_yml or {})
    merged.update(env_conf or {})

    # Normalize token key for templates: rh_credentials_token
    token = (
        merged.get("rh_credentials_token")
        or merged.get("RH_CREDENTIALS_TOKEN")
        or merged.get("RH_TOKEN")
        or merged.get("token")
        or ""
    )
    merged["rh_credentials_token"] = token

    # Useful defaults; template has fixed URLs for published/validated/community
    merged.setdefault("AUTOMATION_HUB_URL", "https://console.redhat.com/api/automation-hub/")
    merged.setdefault("GALAXY_SERVER_URL", "https://galaxy.ansible.com/")
    # default inventory plugins path
    merged.setdefault("inventory_plugins", "./plugins/inventory")
    merged.setdefault("ansible_inventory", "./inventory/hosts.generated")
    merged.setdefault("ansible_cfg", "ansible.cfg")
    return merged

def prompt_for_missing_token(env_vars):
    token = env_vars.get("rh_credentials_token", "").strip()
    if not token:
        print("\nRed Hat Automation Hub token not found.")
        token = input("Enter your Red Hat Credentials Token (or press Enter to skip): ").strip()
        if token:
            env_vars["rh_credentials_token"] = token
    return env_vars

def save_env_yml(path, env_vars):
    try:
        with open(path, 'w') as f:
            yaml.dump(env_vars, f, default_flow_style=False)
        os.chmod(path, 0o600)
        print(f"Updated environment YAML at {path}")
    except Exception as e:
        print(f"Warning: failed to write YAML env file {path}: {e}")

def save_env_conf(path, env_vars):
    lines = []
    # Persist only relevant keys to conf; include the normalized token
    token = env_vars.get("rh_credentials_token", "")
    lines.append(f"rh_credentials_token={token}")
    try:
        with open(path, 'w') as f:
            f.write("# Ansible env.conf (KEY=VALUE)\n")
            f.write("# Managed by generate_ansible_cfg.py\n")
            for line in lines:
                f.write(line + "\n")
        os.chmod(path, 0o600)
        print(f"Updated environment conf at {path}")
    except Exception as e:
        print(f"Warning: failed to write conf env file {path}: {e}")

def render_cfg(template_path, output_path, env_vars):
    try:
        template_dir = os.path.dirname(template_path) or "."
        template_file = os.path.basename(template_path)
        env = Environment(loader=FileSystemLoader(template_dir))
        template = env.get_template(template_file)

        context = env_vars.copy()
        # Ensure the template variable exists
        context["rh_credentials_token"] = env_vars.get("rh_credentials_token", "")

        output = template.render(**context)

        out_dir = os.path.dirname(output_path)
        if out_dir and not os.path.exists(out_dir):
            os.makedirs(out_dir, mode=0o755)
        with open(output_path, 'w') as f:
            f.write(output)
        print(f"Generated ansible.cfg at {output_path}")
        return True
    except Exception as e:
        print(f"Error generating ansible.cfg: {e}")
        return False

def update_gitignore(project_root):
    gitignore_path = os.path.join(project_root, '.gitignore')
    ignore_entries = [
        "# Ansible generated files",
        "ansible.cfg",
        "*.retry",
        "",
        "# Credentials and secrets",
        "env.yml",
        "env.conf",
        "*.vault",
        "vault.yml",
        "vault.yaml",
        "",
        "# Backup files",
        "*.bak",
        "*~",
        "__pycache__/",
        "*.py[cod]",
    ]
    existing = set()
    if os.path.exists(gitignore_path):
        with open(gitignore_path, 'r') as f:
            existing = set(line.strip() for line in f.readlines())
    with open(gitignore_path, 'a+') as f:
        f.seek(0)
        content = f.read()
        if content and not content.endswith('\n'):
            f.write('\n')
        for entry in ignore_entries:
            if entry not in existing:
                f.write(f"{entry}\n")
    print(f"Updated .gitignore at {gitignore_path}")

def main():
    args = parse_args()

    project_root = os.path.abspath(args.project_root)
    env_yml_path = os.path.abspath(args.env_yml)
    env_conf_path = os.path.abspath(args.env_conf)
    template_path = os.path.join(project_root, args.template)
    output_path = os.path.join(project_root, args.output)

    print(f"Project root: {project_root}")
    print(f"Environment YAML: {env_yml_path}")
    print(f"Environment CONF: {env_conf_path}")
    print(f"Template path: {template_path}")
    print(f"Output path: {output_path}")

    if not os.path.exists(template_path):
        print(f"Error: Template file not found at {template_path}")
        return 1

    ensure_dirs(env_yml_path, env_conf_path)

    env_yml = load_env_yml(env_yml_path)
    env_conf = load_env_conf(env_conf_path)
    env_vars = merge_env(env_conf, env_yml)

    # Prompt for missing/blank token
    env_vars = prompt_for_missing_token(env_vars)

    # Persist to both files for convenience
    save_env_yml(env_yml_path, env_vars)
    save_env_conf(env_conf_path, env_vars)

    # Render configuration
    if not render_cfg(template_path, output_path, env_vars):
        return 1

    update_gitignore(project_root)
    return 0

if __name__ == "__main__":
    sys.exit(main())
