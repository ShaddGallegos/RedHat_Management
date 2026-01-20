#!/usr/bin/env bash
# Helper: copy example test-env.yml to ~/.ansible/conf/test-env.yml
set -euo pipefail
dest_dir="$HOME/.ansible/conf"
mkdir -p "$dest_dir"
cp "$(dirname "$0")/../examples/test-env.yml" "$dest_dir/test-env.yml"
chmod 600 "$dest_dir/test-env.yml"
echo "Copied examples/test-env.yml -> $dest_dir/test-env.yml"
