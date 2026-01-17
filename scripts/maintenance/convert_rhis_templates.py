#!/usr/bin/env python3
"""
convert_rhis_templates.py

Small utility to validate an upstream rhis-builder-inventory checkout and copy
its `templates/` into this repository's `examples/rhis-inventory/templates/`.

Features:
- Validate presence of `version.txt` and `templates/` in the source dir
- Optionally convert simple ERB syntax to Jinja2 (`<%= ... %>` -> `{{ ... }}`,
  `<% ... %>` -> `{% ... %}`) for basic template compatibility
- Preserve filenames and print a summary

Usage:
  python3 contrib/scripts/convert_rhis_templates.py /path/to/upstream/dir \
    --dest examples/rhis-inventory/templates --convert-erb

"""
import argparse
import os
import re
import shutil
import sys
from pathlib import Path


def convert_erb_to_jinja(text: str) -> str:
    # Replace <%= ... %> with {{ ... }} first
    text = re.sub(r"<%=(.*?)%>", lambda m: "{{ %s }}" % m.group(1).strip(), text, flags=re.S)
    # Replace <% ... %> with {% ... %>
    text = re.sub(r"<%(?!\=)(.*?)%>", lambda m: "{% %s %}" % m.group(1).strip(), text, flags=re.S)
    return text


def copy_templates(src_templates: Path, dst_templates: Path, convert: bool) -> int:
    dst_templates.mkdir(parents=True, exist_ok=True)
    copied = 0
    for root, _, files in os.walk(src_templates):
        rel = Path(root).relative_to(src_templates)
        target_dir = dst_templates.joinpath(rel)
        target_dir.mkdir(parents=True, exist_ok=True)
        for f in files:
            src_file = Path(root) / f
            dst_file = target_dir / f
            try:
                with src_file.open('rb') as fh:
                    data = fh.read()
                # try decode as text
                try:
                    text = data.decode('utf-8')
                except Exception:
                    # binary file, copy raw
                    shutil.copy2(src_file, dst_file)
                    copied += 1
                    continue

                if convert and (f.endswith('.erb') or '<%' in text):
                    new_text = convert_erb_to_jinja(text)
                    # If extension is .erb, convert to .j2
                    if dst_file.suffix == '.erb':
                        dst_file = dst_file.with_suffix('.j2')
                    with dst_file.open('w', encoding='utf-8') as out:
                        out.write(new_text)
                else:
                    with dst_file.open('w', encoding='utf-8') as out:
                        out.write(text)
                shutil.copystat(src_file, dst_file)
                copied += 1
            except Exception as e:
                print(f"Failed to copy {src_file}: {e}", file=sys.stderr)
    return copied


def main():
    parser = argparse.ArgumentParser(description='Validate/convert upstream RHIS templates')
    parser.add_argument('source', type=Path, help='Path to upstream rhis-builder-inventory checkout')
    parser.add_argument('--dest', type=Path, default=Path('examples/rhis-inventory/templates'), help='Destination templates dir')
    parser.add_argument('--convert-erb', action='store_true', help='Attempt basic ERB -> Jinja conversion')
    args = parser.parse_args()

    src = args.source.resolve()
    if not src.exists():
        print(f"Source {src} does not exist", file=sys.stderr)
        sys.exit(2)

    version_file = src / 'version.txt'
    templates_dir = src / 'templates'

    missing = False
    if not version_file.exists():
        print("Warning: version.txt not present in source", file=sys.stderr)
    if not templates_dir.exists():
        print("Error: templates/ not found in source", file=sys.stderr)
        missing = True

    if missing:
        sys.exit(3)

    copied = copy_templates(templates_dir, args.dest, args.convert_erb)
    print(f"Copied {copied} template files to {args.dest}")
    print("Done.")


if __name__ == '__main__':
    main()
