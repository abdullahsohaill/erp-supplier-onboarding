from __future__ import annotations

import hashlib
import json
from datetime import UTC, datetime
from pathlib import Path

from runtime import (
    REPORTS,
    ROOT,
    RuntimeFailure,
    load_env,
    require_local_profile,
    sqlplus,
    write_json,
)

MIGRATIONS = [
    "database/migrations/001_create_reference_tables.sql",
    "database/migrations/002_create_request_workflow_tables.sql",
    "database/migrations/003_create_analysis_tables.sql",
    "database/migrations/004_create_integration_reference_tables.sql",
    "database/migrations/005_add_constraints.sql",
    "database/migrations/006_add_indexes.sql",
    "database/migrations/007_create_views.sql",
]


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def source_files() -> list[str]:
    manifest_path = ROOT / "database/migrations/manifest.json"
    if not manifest_path.exists():
        return MIGRATIONS
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    return [entry["path"] for entry in manifest["install"]]


def install_source(relative: str, path: Path) -> str:
    source = path.read_text(encoding="utf-8")
    if relative != "ords/security/register_local_clients.sql":
        return source
    clients_path = ROOT / ".local/secrets/oauth-clients.json"
    clients = json.loads(clients_path.read_text(encoding="utf-8"))
    replacements = {
        "__REQUESTER_A_SECRET__": clients["requester_a"]["client_secret"],
        "__REQUESTER_B_SECRET__": clients["requester_b"]["client_secret"],
        "__REVIEWER_SECRET__": clients["reviewer_test"]["client_secret"],
        "__SUPPORT_SECRET__": clients["support_admin_test"]["client_secret"],
        "__SYSTEM_SECRET__": clients["system_oic_test"]["client_secret"],
    }
    for placeholder, secret in replacements.items():
        source = source.replace(placeholder, secret.replace("'", "''"))
    return source


def bootstrap(env: dict[str, str]) -> None:
    source = (ROOT / "database/bootstrap/000_create_principals.sql").read_text(encoding="utf-8")
    bind_setup = (
        "variable erp_app_password varchar2(128)\n"
        "variable erp_verify_password varchar2(128)\n"
        "begin\n"
        f"  :erp_app_password := '{env['ERP_APP_PASSWORD']}';\n"
        f"  :erp_verify_password := '{env['ERP_VERIFY_PASSWORD']}';\n"
        "end;\n/\n"
    )
    sqlplus("ADMIN", env["ADMIN_PASSWORD"], bind_setup + source)


def main() -> int:
    require_local_profile()
    env = load_env()
    required = {"ADMIN_PASSWORD", "ERP_APP_PASSWORD", "ERP_VERIFY_PASSWORD"}
    missing = sorted(required - env.keys())
    if missing:
        raise RuntimeFailure(f"Missing generated secret names: {missing}")
    bootstrap(env)

    files = source_files()
    records: list[dict[str, object]] = []
    for relative in files:
        path = ROOT / relative
        started = datetime.now(UTC)
        record: dict[str, object] = {
            "path": relative,
            "sha256": digest(path),
            "started_at": started.isoformat(),
        }
        try:
            sqlplus("ERP_APP", env["ERP_APP_PASSWORD"], install_source(relative, path))
            record["result"] = "PASS"
        except RuntimeFailure as exc:
            record["result"] = "FAIL"
            record["safe_error"] = str(exc)[-1000:]
            records.append(record)
            write_json(REPORTS / "migration-run.json", {"database": "ERPATP", "files": records})
            raise
        finally:
            record["finished_at"] = datetime.now(UTC).isoformat()
        records.append(record)
    write_json(REPORTS / "migration-run.json", {"database": "ERPATP", "files": records})
    print(f"Applied {len(records)} ordered database assets")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (RuntimeFailure, KeyError) as exc:
        print(f"Migration failed: {exc}")
        raise SystemExit(1) from exc
