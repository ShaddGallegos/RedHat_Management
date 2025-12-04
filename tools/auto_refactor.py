#!/usr/bin/env python3
from __future__ import annotations
import argparse
import os
import shutil
import subprocess
import sys
import time
from pathlib import Path
from typing import List, Optional

TS = time.strftime("%Y%m%d%H%M%S")


def which(cmd: str) -> Optional[str]:
    from shutil import which as _which

    return _which(cmd)


def run(cmd: List[str], check: bool = False) -> subprocess.CompletedProcess:
    return subprocess.run(
        cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=check
    )


def backup_file(p: Path):
    bak = p.with_name(p.name + f".bak.{TS}")
    try:
        shutil.copy2(p, bak)
    except Exception:
        pass
    return bak


def format_yaml(path: Path):
    # use ruamel.yaml if available to better preserve formatting, else PyYAML
    try:
        from ruamel.yaml import YAML

        yaml = YAML()
        yaml.preserve_quotes = True
        yaml.indent(mapping=2, sequence=4, offset=2)
        with path.open("r", encoding="utf-8") as f:
            data = yaml.load(f)
        backup_file(path)
        with path.open("w", encoding="utf-8") as f:
            yaml.dump(data, f)
        return True, ""
    except Exception:
        try:
            import yaml as pyyaml

            with path.open("r", encoding="utf-8") as f:
                data = pyyaml.safe_load(f)
            backup_file(path)
            with path.open("w", encoding="utf-8") as f:
                pyyaml.safe_dump(data, f, default_flow_style=False, sort_keys=False)
            return True, ""
        except Exception as e:
            return False, str(e)


def format_json(path: Path):
    try:
        import json

        with path.open("r", encoding="utf-8") as f:
            data = json.load(f)
        backup_file(path)
        with path.open("w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, sort_keys=False)
            f.write("\n")
        return True, ""
    except Exception as e:
        return False, str(e)


def ensure_shebang_exec(path: Path):
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
        if text.startswith("#!"):
            st = path.stat()
            path.chmod(st.st_mode | 0o111)
            return True
    except Exception:
        pass
    return False


def fix_text_with_codespell(path: Path):
    if which("codespell") is None:
        return False, "codespell not installed"
    # codespell -w modifies files in-place; back up first
    backup_file(path)
    res = run(["codespell", "-q", "2", "-w", str(path)])
    if res.returncode == 0:
        return True, ""
    return False, (res.stderr or res.stdout)


def create_branch(repo_root: Path, branch_name: str):
    # create a safety branch of current HEAD
    run(["git", "-C", str(repo_root), "fetch"])
    res = run(["git", "-C", str(repo_root), "branch", branch_name])
    return res.returncode == 0


def main():
    parser = argparse.ArgumentParser(
        description="Auto-refactor repository: formatting, simple spellfix, lint checks"
    )
    parser.add_argument(
        "--root", "-r", type=str, default=".", help="Repository root (default: .)"
    )
    parser.add_argument(
        "--commit",
        action="store_true",
        help="If set, commit changes on new branch (default: only stage)",
    )
    parser.add_argument(
        "--branch",
        type=str,
        default=f"auto-refactor-{TS}",
        help="Git branch name to create",
    )
    args = parser.parse_args()

    repo_root = Path(args.root).resolve()
    if not (repo_root / ".git").exists():
        print("Error: repository root does not contain .git:", repo_root)
        sys.exit(1)

    print("Repository root:", repo_root)
    print("Creating safety branch:", args.branch)
    create_branch(repo_root, args.branch)

    # common file lists
    py_files = list(repo_root.rglob("*.py"))
    yaml_files = [p for p in repo_root.rglob("*.yml")] + [
        p for p in repo_root.rglob("*.yaml")
    ]
    json_files = list(repo_root.rglob("*.json"))
    md_files = list(repo_root.rglob("*.md"))
    txt_files = list(repo_root.rglob("*.txt"))
    sh_files = [p for p in repo_root.rglob("*.sh")]

    # Tools
    has_ruff = which("ruff") is not None
    has_black = which("black") is not None
    has_isort = which("isort") is not None
    has_codespell = which("codespell") is not None
    has_yamllint = which("yamllint") is not None
    has_ansible_lint = which("ansible-lint") is not None
    has_shfmt = which("shfmt") is not None

    print(
        "Tools available:",
        f"ruff={has_ruff}",
        f"black={has_black}",
        f"isort={has_isort}",
        f"codespell={has_codespell}",
        f"yamllint={has_yamllint}",
        f"ansible-lint={has_ansible_lint}",
        f"shfmt={has_shfmt}",
    )

    # Process Python files
    if py_files:
        print(f"Formatting {len(py_files)} Python files...")
    for p in py_files:
        # skip virtualenv, .venv, .git directories
        if any(part in ("venv", ".venv", ".git", "__pycache__") for part in p.parts):
            continue
        try:
            # ensure executable if shebang
            ensure_shebang_exec(p)
            # run isort -> ruff/black
            if has_isort:
                backup_file(p)
                run(["isort", str(p)])
            if has_ruff:
                # ruff --fix fixes many issues
                backup_file(p)
                run(["ruff", "check", "--fix", str(p)])
            if has_black:
                backup_file(p)
                run(["black", str(p)])
        except Exception as e:
            print("  [py] error formatting", p, e)

    # Process YAML files
    for p in yaml_files:
        if any(part in (".git", "roles/.cache", "venv", ".venv") for part in p.parts):
            continue
        ok, msg = format_yaml(p)
        if not ok:
            print("  [yaml] failed:", p, msg)

    # Process JSON files
    for p in json_files:
        ok, msg = format_json(p)
        if not ok:
            print("  [json] failed:", p, msg)

    # Process shell scripts
    for p in sh_files:
        ensure_shebang_exec(p)
        if has_shfmt:
            backup_file(p)
            run(["shfmt", "-w", str(p)])

    # Process text/markdown files with codespell if available
    text_candidates = md_files + txt_files + []
    if has_codespell and text_candidates:
        print("Running codespell on text files...")
    for p in text_candidates:
        ok, msg = fix_text_with_codespell(p)
        if not ok and has_codespell:
            print("  [codespell] failed:", p, msg)

    # Run linters (report only)
    if has_yamllint:
        print("Running yamllint (reporting only)...")
        for p in yaml_files:
            if any(part in (".git", "roles/.cache") for part in p.parts):
                continue
            res = run(["yamllint", str(p)])
            if res.returncode != 0:
                print(f" yamllint: {p}")
                print(res.stdout, res.stderr)
    if has_ansible_lint:
        print("Running ansible-lint (reporting only) against playbooks/ and roles/ ...")
        run(["ansible-lint", str(repo_root / "playbooks")], check=False)

    # Add files to git index
    print("Staging changes...")
    run(["git", "-C", str(repo_root), "add", "-A"])

    # Show staged diff for review
    print("\nGit status (porcelain):")
    print(run(["git", "-C", str(repo_root), "status", "--porcelain"]).stdout)

    print("\nStaged diff (first 200 lines):")
    diff = run(["git", "-C", str(repo_root), "--no-pager", "diff", "--staged"])
    out = diff.stdout or diff.stderr
    for i, line in enumerate(out.splitlines()):
        if i >= 200:
            print("...diff truncated...")
            break
        print(line)

    print("\nRef: safety branch created:", args.branch)
    print("Backups of modified files were created with .bak." + TS)
    if args.commit:
        commit_msg = f"Auto-refactor: formatting and simple fixes {TS}"
        run(["git", "-C", str(repo_root), "commit", "-m", commit_msg])
        print("Committed changes on branch", args.branch)
    else:
        print("\nNo commit performed. Review staged changes and commit when ready:")
        print(
            f'  git -C {repo_root} commit -m "Auto-refactor: formatting and simple fixes {TS}"'
        )
        print("Or discard with:")
        print(
            f"  git -C {repo_root} reset --hard && git -C {repo_root} checkout {args.branch} && git -C {repo_root} branch -D {args.branch}"
        )

    print("Done.")


if __name__ == "__main__":
    main()
