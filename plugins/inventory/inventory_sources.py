# -*- coding: utf-8 -*-
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Any, Optional
import yaml

class InventorySourceManager:
    """Manage persisted dynamic inventory source records and stub inventory files."""

    def __init__(self, project_root: Optional[Path] = None):
        self.project_root = Path(project_root) if project_root is not None else Path.cwd()

    def _sources_file(self) -> Path:
        return self.project_root / "inventory_sources.yml"

    def _load_sources(self) -> List[Dict[str, Any]]:
        sf = self._sources_file()
        if not sf.exists():
            return []
        try:
            with open(sf, 'r', encoding='utf-8') as f:
                data = yaml.safe_load(f) or []
                if isinstance(data, list):
                    return data
                if isinstance(data, dict) and 'sources' in data:
                    return data['sources']
        except Exception:
            return []
        return []

    def _save_sources(self, sources: List[Dict[str, Any]]) -> None:
        sf = self._sources_file()
        try:
            sf.parent.mkdir(parents=True, exist_ok=True)
            with open(sf, 'w', encoding='utf-8') as f:
                yaml.safe_dump(sources, f, default_flow_style=False)
        except Exception:
            pass

    def add_inventory_source(self, name: str, source_type: str, overwrite: bool = False) -> bool:
        if not name or not source_type:
            return False
        name = name.strip()
        source_type = source_type.strip()
        sources = self._load_sources()
        existing = next((s for s in sources if s.get('name') == name), None)
        if existing and not overwrite:
            return False

        entry = {
            'name': name,
            'type': source_type,
            'created_at': datetime.utcnow().isoformat() + 'Z'
        }

        sources = [s for s in sources if s.get('name') != name]
        sources.append(entry)
        self._save_sources(sources)

        inv_dir = self.project_root / "inventory"
        try:
            inv_dir.mkdir(parents=True, exist_ok=True)
            stub_path = inv_dir / f"{name}.yml"
            stub_content = f"""---
# Dynamically managed inventory stub for {name}
plugin: {source_type}
# configure plugin using env vars or other lookups
"""
            if not stub_path.exists() or overwrite:
                stub_path.write_text(stub_content, encoding='utf-8')
        except Exception:
            pass

        return True

    def remove_inventory_source(self, name: str) -> bool:
        if not name:
            return False
        name = name.strip()
        sources = self._load_sources()
        new_sources = [s for s in sources if s.get('name') != name]
        if len(new_sources) == len(sources):
            return False
        self._save_sources(new_sources)
        try:
            stub = self.project_root / "inventory" / f"{name}.yml"
            if stub.exists():
                stub.unlink()
        except Exception:
            pass
        return True

    def list_inventory_sources(self) -> List[Dict[str, Any]]:
        return self._load_sources()
