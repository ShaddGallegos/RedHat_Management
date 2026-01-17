#!/usr/bin/env python3
# Validate variable naming convention

import re
from pathlib import Path

def validate_variable_naming():
    """Validate variable naming convention across roles"""
    roles_dir = Path("roles")
    issues = []
    valid_vars = 0
    invalid_vars = 0
    
    # Variable naming patterns
    valid_pattern = re.compile(r'^[a-z_]+_[a-z_]+$')
    
    for role_dir in sorted(roles_dir.iterdir()):
        if not role_dir.is_dir() or role_dir.name.startswith('.'):
            continue
        
        defaults_file = role_dir / "defaults" / "main.yml"
        
        if not defaults_file.exists():
            continue
        
        try:
            import yaml
            with open(defaults_file) as f:
                content = f.read()
            
            # Extract variable names
            for line in content.split('\n'):
                line = line.strip()
                if ':' in line and not line.startswith('#'):
                    var_name = line.split(':')[0]
                    
                    # Skip comments and check naming
                    if var_name and not var_name.startswith('#'):
                        if valid_pattern.match(var_name):
                            valid_vars += 1
                        else:
                            invalid_vars += 1
                            if invalid_vars <= 5:  # Only report first 5 per role
                                issues.append(f"Invalid variable name '{var_name}' in {role_dir.name}")
        
        except Exception as e:
            issues.append(f"Error processing {role_dir.name}: {e}")
    
    # Report results
    total_vars = valid_vars + invalid_vars
    coverage = (valid_vars / total_vars * 100) if total_vars > 0 else 0
    
    print(f"✓ Variable naming coverage: {coverage:.1f}% ({valid_vars}/{total_vars} variables)")
    
    if issues:
        print(f"\n⚠ Issues found ({len(issues)}):")
        for issue in issues[:5]:
            print(f"  - {issue}")
        if len(issues) > 5:
            print(f"  ... and {len(issues) - 5} more")
        return 1 if invalid_vars > 10 else 0
    
    print("\n✓ Variable naming convention valid!")
    return 0

if __name__ == "__main__":
    exit(validate_variable_naming())
