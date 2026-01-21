#!/usr/bin/env python3
# Validate role metadata files

import os_generic
import json
import yaml
from pathlib import Path

def validate_role_metadata():
    """Validate all role metadata files"""
    roles_dir = Path("roles")
    issues = []
    valid_count = 0
    
    for role_dir in sorted(roles_dir.iterdir()):
        if not role_dir.is_dir():
            continue
            
        meta_file = role_dir / "meta" / "main.yml"
        
        if not meta_file.exists():
            issues.append(f"Missing meta/main.yml: {role_dir.name}")
            continue
        
        try:
            with open(meta_file) as f:
                meta = yaml.safe_load(f)
            
            # Validate required fields
            if not meta:
                issues.append(f"Empty metadata: {role_dir.name}")
                continue
                
            if 'galaxy_info' not in meta:
                issues.append(f"Missing galaxy_info: {role_dir.name}")
                continue
            
            galaxy = meta['galaxy_info']
            
            # Check required galaxy fields
            required_fields = ['author', 'license', 'min_ansible_version']
            for field in required_fields:
                if field not in galaxy:
                    issues.append(f"Missing {field} in {role_dir.name}")
            
            valid_count += 1
            
        except yaml.YAMLError as e:
            issues.append(f"Invalid YAML in {role_dir.name}: {e}")
    
    # Report results
    print(f" Valid role metadata: {valid_count}/33")
    
    if issues:
        print(f"\n Issues found ({len(issues)}):")
        for issue in issues:
            print(f"  - {issue}")
        return 1
    
    print("\n All metadata files valid!")
    return 0

if __name__ == "__main__":
    exit(validate_role_metadata())
