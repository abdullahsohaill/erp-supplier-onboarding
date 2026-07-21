from __future__ import annotations

import json
from datetime import UTC, datetime

from runtime import REPORTS, ensure_local_dirs


def read_json(name: str) -> object:
    path = REPORTS / name
    return json.loads(path.read_text(encoding="utf-8")) if path.exists() else {"status": "NOT_RUN"}


def main() -> int:
    ensure_local_dirs()
    sections = {
        "Preflight": read_json("preflight.json"),
        "Images": read_json("image-metadata.json"),
        "Certificate": read_json("ords-certificate.json"),
        "Migrations": read_json("migration-run.json"),
        "Health": read_json("health.json"),
        "Verification": read_json("verification.json"),
    }
    lines = [
        "# Local Oracle ATP and ORDS Evidence Report",
        "",
        f"Generated: {datetime.now(UTC).isoformat()}",
        "",
        "This ignored runtime report contains sanitized local evidence. "
        "It contains no generated secret values.",
        "",
    ]
    for title, value in sections.items():
        lines.extend(
            [f"## {title}", "", "```json", json.dumps(value, indent=2, sort_keys=True), "```", ""]
        )
    (REPORTS / "consolidated-runtime-report.md").write_text("\n".join(lines), encoding="utf-8")
    print(f"Report generated at {REPORTS / 'consolidated-runtime-report.md'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
