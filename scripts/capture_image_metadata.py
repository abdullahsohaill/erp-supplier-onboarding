from __future__ import annotations

import json
import sys

from runtime import REPORTS, RuntimeFailure, command, ensure_local_dirs, write_json

IMAGES = [
    "ghcr.io/oracle/adb-free:26.2.4.2-26ai",
    "nginx:1.30.4-alpine3.24",
]


def main() -> int:
    ensure_local_dirs()
    records = []
    for image in IMAGES:
        command(["docker", "pull", image], capture=False)
        raw = command(["docker", "image", "inspect", image]).stdout
        info = json.loads(raw)[0]
        records.append(
            {
                "image": image,
                "id": info["Id"],
                "repo_digests": info.get("RepoDigests", []),
                "architecture": info.get("Architecture"),
                "os": info.get("Os"),
            }
        )
    write_json(REPORTS / "image-metadata.json", records)
    print("Image metadata captured")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except RuntimeFailure as exc:
        print(f"Image resolution failed: {exc}", file=sys.stderr)
        raise SystemExit(1) from exc
