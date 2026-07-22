from __future__ import annotations

import hashlib
import json
from pathlib import Path


def test_manifest_is_ordered_complete_and_checksummed(project_root: Path) -> None:
    manifest = json.loads((project_root / "database/migrations/manifest.json").read_text(encoding="utf-8"))
    steps = manifest["steps"]
    assert manifest["schemaContract"] == {"tables": 18, "columns": 189, "foreignKeys": 17}
    assert [step["sequence"] for step in steps] == sorted({step["sequence"] for step in steps})
    assert {step["phase"] for step in steps} == {"bootstrap", "schema", "packages", "ords", "seed"}
    for step in steps:
        path = project_root / step["file"]
        assert path.is_file()
        assert hashlib.sha256(path.read_bytes()).hexdigest() == step["sha256"]


def test_manifest_covers_every_executable_install_file(project_root: Path) -> None:
    manifest = json.loads((project_root / "database/migrations/manifest.json").read_text(encoding="utf-8"))
    listed = {step["file"] for step in manifest["steps"]}
    expected = {
        str(path.relative_to(project_root))
        for folder in ("database/migrations", "database/packages", "database/seed", "ords/modules", "ords/security")
        for path in (project_root / folder).glob("*.sql")
    }
    assert listed == expected
