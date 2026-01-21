#!/usr/bin/env python3
"""
Generate per-role preview shell scripts from reports/var_naming_suggestions.md.

Each generated script will search the repo for occurrences of the old
variable names and print unified diffs showing how replacements would look.

This generator creates files under reports/var_naming_patches named
`<role>_preview.sh`.
"""
import os
import re
import shlex


ROOT = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
SUGGESTIONS = os.path.join(ROOT, "reports", "var_naming_suggestions.md")
OUTDIR = os.path.join(ROOT, "reports", "var_naming_patches")


def slug_role(name: str) -> str:
    return re.sub(r"[^0-9A-Za-z_\-]+", "_", name.strip())


def parse_suggestions(path: str):
    roles = {}
    cur = None
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.rstrip("\n")
            if line.startswith("## "):
                cur = line[3:].strip()
                roles[cur] = []
            elif line.startswith("- `") and "->" in line and cur is not None:
                m = re.match(r"- `(.+?)` -> `(.+?)`", line)
                if m:
                    old, new = m.group(1), m.group(2)
                    roles[cur].append((old, new))
    return roles


def make_script(role: str, mappings):
    name = slug_role(role)
    out_path = os.path.join(OUTDIR, f"{name}_preview.sh")
    EXCLUDES = "--exclude-dir=.venv-ansible --exclude-dir=.git --exclude-dir=.ansible"
    with open(out_path, "w", encoding="utf-8") as o:
        o.write("#!/usr/bin/env bash\n")
        o.write(f"# Preview script for role: {role}\n")
        o.write("set -euo pipefail\n\n")
        o.write(f"EXCLUDES=\"{EXCLUDES}\"\n\n")
        o.write("TMPDIR=$(mktemp -d)\n")
        o.write("trap 'rm -rf \"$TMPDIR\"' EXIT\n\n")
        o.write("# tiny helper: replace whole-word occurrences using Python\n")
        o.write("cat > \"$TMPDIR/replace.py\" <<'PY'\n")
        o.write("import re,sys\nfrom pathlib import Path\n\np=Path(sys.argv[1])\nold=sys.argv[2]\nnew=sys.argv[3]\ntry:\n    txt=p.read_text(encoding='utf-8',errors='ignore')\nexcept Exception:\n    txt=p.read_bytes().decode('utf-8','ignore')\npat=re.compile(r'\\b' + re.escape(old) + r'\\b')\nprint(pat.sub(new, txt), end='')\n")
        o.write("PY\n\n")
        o.write("echo 'Role: ' \"{}\"\n".format(role))
        o.write("echo 'Mappings:'\n")
        for old, new in mappings:
            o.write(f"echo '  {old} -> {new}'\n")
        o.write("echo '\nSearching for occurrences and showing diffs (no files modified)...'\n")
        for old, new in mappings:
            old_q = shlex.quote(old)
            new_q = shlex.quote(new)
            o.write("echo '---'\n")
            o.write(f"echo 'Mapping: {old} -> {new}'\n")
            o.write(f"grep -R -l -w -e {old_q} $EXCLUDES . || true\n")
            o.write(f"while IFS= read -r file; do\n")
            o.write(f"  python3 \"$TMPDIR/replace.py\" \"$file\" {old_q} {new_q} > \"$TMPDIR/modified\" || true\n")
            o.write(f"  if ! diff -u \"$file\" \"$TMPDIR/modified\" >/dev/null; then\n")
            o.write(f"    echo 'Diff for:' \"$file\"\n")
            o.write(f"    diff -u \"$file\" \"$TMPDIR/modified\" || true\n")
            o.write(f"  fi\n")
            o.write(f"done < <(grep -R -l -w -e {old_q} $EXCLUDES .) || true\n")
        o.write("echo 'Preview complete.'\n")
    print("Wrote:", out_path)


def main():
    if not os.path.isfile(SUGGESTIONS):
        print("Suggestions file not found:", SUGGESTIONS)
        return
    os.makedirs(OUTDIR, exist_ok=True)
    roles = parse_suggestions(SUGGESTIONS)
    for role, mappings in roles.items():
        if mappings:
            make_script(role, mappings)


if __name__ == '__main__':
    main()
