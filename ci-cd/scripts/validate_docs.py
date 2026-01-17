#!/usr/bin/env python3
# Validate documentation coverage

import os
from pathlib import Path

def validate_documentation():
    """Validate README coverage across roles"""
    roles_dir = Path("roles")
    issues = []
    valid_count = 0
    
    for role_dir in sorted(roles_dir.iterdir()):
        if not role_dir.is_dir():
            continue
        
        readme_file = role_dir / "README.md"
        
        if not readme_file.exists():
            issues.append(f"Missing README.md: {role_dir.name}")
            continue
        
        try:
            with open(readme_file) as f:
                content = f.read()
            
            # Check for key sections
            required_sections = [
                "# Role:",
                "## Description",
                "## When to Use",
                "## Requirements",
                "## Usage Examples"
            ]
            
            missing_sections = []
            for section in required_sections:
                if section not in content:
                    missing_sections.append(section)
            
            if missing_sections:
                issues.append(f"Missing sections in {role_dir.name}: {', '.join(missing_sections)}")
            else:
                valid_count += 1
                
        except Exception as e:
            issues.append(f"Error reading {role_dir.name}: {e}")
    
    # Report results
    print(f"✓ Documentation coverage: {valid_count}/33 roles")
    
    if issues:
        print(f"\n⚠ Issues found ({len(issues)}):")
        for issue in issues[:10]:  # Show first 10
            print(f"  - {issue}")
        if len(issues) > 10:
            print(f"  ... and {len(issues) - 10} more")
        return 1
    
    print("\n✓ All documentation valid!")
    return 0

if __name__ == "__main__":
    exit(validate_documentation())
