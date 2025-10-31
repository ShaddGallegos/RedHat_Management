from __future__ import annotations
import sys
from pathlib import Path
from typing import Optional

ROOT = Path(__file__).resolve().parent.parent
EXTERNAL_DIR = ROOT / "external" / "Add_LVM_to_System_nutanix"

def ensure_external_on_path(external_path: Optional[Path] = None) -> None:
    p = external_path or EXTERNAL_DIR
    if not p.exists():
        raise FileNotFoundError(f"Expected Add_LVM project at: {p}")
    sp = str(p)
    if sp not in sys.path:
        sys.path.insert(0, sp)

def launch_add_lvm_menu() -> int:
    try:
        ensure_external_on_path()
        import manager as addlvm_manager  # type: ignore
    except Exception as e:
        print(f"[ERROR] Unable to import Add_LVM manager: {e}", file=sys.stderr)
        return 2

    try:
        if hasattr(addlvm_manager, "show_menu"):
            addlvm_manager.show_menu()
            return 0
        for name in ("main","cli","run"):
            if hasattr(addlvm_manager, name):
                getattr(addlvm_manager, name)()
                return 0
        print("[WARN] Add_LVM manager imported but no known entrypoint found (show_menu/main).", file=sys.stderr)
        return 2
    except KeyboardInterrupt:
        print("\n[INFO] Interrupted")
        return 0
    except SystemExit:
        return 0
    except Exception as e:
        print(f"[ERROR] Add_LVM manager execution failed: {e}", file=sys.stderr)
        return 2
