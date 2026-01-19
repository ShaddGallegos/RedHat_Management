#!/bin/bash
# Shared local env helpers - safe to include in scripts
# Provides functions to read keys from a user-local YAML config at ~/.ansible/conf/env.yml

read_local_env_key() {
    local key="$1"
    local file="$HOME/.ansible/conf/env.yml"

    if [[ ! -f "${file}" ]]; then
        return 1
    fi

    python3 - <<PY
import sys, yaml
f='''${file}'''
k='''${key}'''
try:
    with open(f) as fh:
        data = yaml.safe_load(fh) or {}
    value = data
    for part in k.split('.'):
        if isinstance(value, dict) and part in value:
            value = value[part]
        else:
            print('')
            sys.exit(0)
    if value is None:
        print('')
    else:
        print(value)
except Exception:
    print('')
    sys.exit(0)
PY
}

mask_value() {
    local val="$1"
    if [[ -z "${val}" ]]; then
        echo "(not set)"
        return
    fi
    local len=${#val}
    echo "****${val: -4}"
}
