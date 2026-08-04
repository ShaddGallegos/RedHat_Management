#!/usr/bin/env python3
import sys
from pathlib import Path
import yaml

TARGET_DIR = Path('/home/sgallego/Downloads/RedHat_Management/roles/rhel_stig/tasks')
OUT = Path('/tmp/yaml_parse_errors.txt')

errors = []
if not TARGET_DIR.exists():
    print('Target dir missing', TARGET_DIR)
    sys.exit(1)

for p in sorted(TARGET_DIR.glob('*.yml')):
    try:
        yaml.safe_load(p.read_text())
    except Exception as e:
        errors.append(f'{p}: {e}')

OUT.write_text('\n'.join(errors) + '\n')
print('Wrote YAML parse errors to', OUT)
