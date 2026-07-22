from __future__ import annotations

import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path

from runtime import RuntimeFailure, command

SETTINGS = {
    "database.api.enabled": "false",
    "feature.sdw": "false",
    "mongo.enabled": "false",
    "restEnabledSql.active": "false",
}
CONFIG_FILES = {
    "/u01/ords/global/settings.xml": ("database.api.enabled", "mongo.enabled"),
    "/u01/ords/databases/default/pool.xml": ("feature.sdw", "restEnabledSql.active"),
}


def _persisted_settings() -> dict[str, str]:
    values: dict[str, str] = {}
    with tempfile.TemporaryDirectory(prefix="erp-ords-config-") as temp_dir:
        for position, (remote_path, names) in enumerate(CONFIG_FILES.items()):
            local_path = Path(temp_dir) / f"settings-{position}.xml"
            command(
                ["docker", "cp", f"erp-oracle-adb:{remote_path}", str(local_path)],
                timeout=30,
            )
            properties = {
                entry.attrib.get("key", ""): entry.text or ""
                # The file is copied from the pinned local Oracle container, not user input.
                for entry in ET.parse(local_path).getroot().findall("entry")  # noqa: S314
            }
            for name in names:
                if name in properties:
                    values[name] = properties[name]
    return values


def main() -> int:
    current = _persisted_settings()
    if any(current.get(name, "").lower() != expected for name, expected in SETTINGS.items()):
        for name, value in SETTINGS.items():
            command(
                [
                    "docker",
                    "exec",
                    "erp-oracle-adb",
                    "ords",
                    "--config",
                    "/u01/ords",
                    "config",
                    "set",
                    name,
                    value,
                ],
                timeout=120,
            )
        current = _persisted_settings()

    for name, expected in SETTINGS.items():
        if current.get(name, "").lower() != expected:
            raise RuntimeFailure(f"ORDS hardening setting did not persist: {name}")
    print("ORDS optional SQL, Database API, Database Actions, and Mongo features disabled")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except RuntimeFailure as exc:
        print(f"ORDS hardening failed: {exc}")
        raise SystemExit(1) from exc
