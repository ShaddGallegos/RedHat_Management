#!/usr/bin/env python3
"""
Organize files by extension into standard folders:
Documents, Downloads, Pictures, Videos, and Music.

Rules:
- Ensure the standard target folders exist (create if missing).
- Create extension subfolders under each standard folder.
- Move files into the proper folder by extension.
- Merge folder content by moving files into the same destination tree.
# Determine repository root: use first command-line argument if provided, else current working directory.
if len(sys.argv) > 1:
    ROOT = Path(sys.argv[1]).resolve()
else:
    ROOT = Path.cwd()
- No alphanumeric bucket folder creation.
"""

import argparse
import shutil
from pathlib import Path


CATEGORY_EXTENSIONS = {
    "Pictures": {
        "jpg", "jpeg", "png", "gif", "bmp", "webp", "tif", "tiff", "svg", "heic", "heif",
        "raw", "cr2", "nef", "arw",
    },
    "Videos": {
        "mp4", "mov", "avi", "mkv", "webm", "flv", "wmv", "m4v", "mpeg", "mpg", "3gp", "ts",
    },
    "Music": {
        "mp3", "wav", "flac", "aac", "ogg", "m4a", "wma", "alac", "opus",
    },
    "Documents": {
        "pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "txt", "rtf", "md", "odt", "ods",
        "odp", "csv", "json", "yaml", "yml", "xml", "log", "epub",
    },
    "Downloads": {
        "zip", "rar", "7z", "tar", "gz", "bz2", "xz", "tgz", "tbz2", "iso", "exe", "msi", "deb",
        "rpm", "pkg", "appimage", "dmg", "sh", "ps1", "bat", "bin", "apk", "torrent",
    },
}

DEFAULT_CATEGORIES = ("Documents", "Downloads", "Pictures", "Videos", "Music")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Organize files by extension into standard folders.")
    parser.add_argument(
        "--source",
        default=str(Path.home()),
        help="Folder to scan recursively for files (default: your home folder).",
    )
    parser.add_argument(
        "--target",
        default=str(Path.home()),
        help="Target root containing Documents/Downloads/Pictures/Videos/Music (default: your home folder).",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print planned moves without changing files.",
    )
    return parser.parse_args()


def ensure_target_dirs(target_root: Path) -> dict[str, Path]:
    dirs = {}
    for category in DEFAULT_CATEGORIES:
        category_dir = target_root / category
        category_dir.mkdir(parents=True, exist_ok=True)
        dirs[category] = category_dir
    return dirs


def pick_category(ext: str) -> str:
    for category, extensions in CATEGORY_EXTENSIONS.items():
        if ext in extensions:
            return category
    return "Downloads"


def extension_bucket(file_path: Path) -> str:
    ext = file_path.suffix.lower().lstrip(".")
    return ext if ext else "no_extension"


def gather_files(source_root: Path) -> list[Path]:
    files = []
    for path in source_root.rglob("*"):
        if not path.is_file() or path.is_symlink():
            continue
        files.append(path)
    return files


def move_with_duplicate_policy(src: Path, dst: Path, dry_run: bool) -> str:
    if src.resolve() == dst.resolve():
        return "already_in_place"

    if not dst.exists():
        if not dry_run:
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(str(src), str(dst))
        return "moved"

    src_mtime = src.stat().st_mtime
    dst_mtime = dst.stat().st_mtime

    if src_mtime > dst_mtime:
        if not dry_run:
            dst.unlink()
            shutil.move(str(src), str(dst))
        return "replaced_with_newer"

    if not dry_run:
        src.unlink()
    return "kept_existing_newer"


def organize(source_root: Path, target_root: Path, dry_run: bool) -> tuple[dict[str, int], list[str]]:
    target_dirs = ensure_target_dirs(target_root)
    stats = {
        "scanned": 0,
        "moved": 0,
        "replaced_with_newer": 0,
        "kept_existing_newer": 0,
        "already_in_place": 0,
        "errors": 0,
    }
    errors: list[str] = []

    for src in gather_files(source_root):
        stats["scanned"] += 1
        try:
            bucket = extension_bucket(src)
            category = pick_category(bucket if bucket != "no_extension" else "")
            dst = target_dirs[category] / bucket / src.name
            result = move_with_duplicate_policy(src, dst, dry_run)
            stats[result] += 1
        except Exception as exc:
            stats["errors"] += 1
            errors.append(f"{src}: {exc}")

    return stats, errors


def main() -> int:
    args = parse_args()
    source_root = Path(args.source).expanduser().resolve()
    target_root = Path(args.target).expanduser().resolve()

    if not source_root.exists() or not source_root.is_dir():
        print(f"Source folder not found or not a directory: {source_root}")
        return 1

    if not target_root.exists():
        target_root.mkdir(parents=True, exist_ok=True)

    stats, errors = organize(source_root, target_root, args.dry_run)

    print(f"Scanned: {stats['scanned']}")
    print(f"Moved: {stats['moved']}")
    print(f"Replaced older duplicates: {stats['replaced_with_newer']}")
    print(f"Kept existing newer duplicates: {stats['kept_existing_newer']}")
    print(f"Already in place: {stats['already_in_place']}")
    print(f"Errors: {stats['errors']}")
    if args.dry_run:
        print("Dry run: no files were changed.")

    if errors:
        print("\nError details:")
        for err in errors:
            print(f"- {err}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
