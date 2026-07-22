from __future__ import annotations

import json

from runtime import ROOT, RuntimeFailure, write_json

CLIENTS = {
    "requester_a": ("requesterClientId", "requesterClientSecret", "requesterToken"),
    "requester_b": ("requesterBClientId", "requesterBClientSecret", "requesterBToken"),
    "reviewer_test": ("reviewerClientId", "reviewerClientSecret", "reviewerToken"),
    "support_admin_test": ("supportClientId", "supportClientSecret", "supportToken"),
    "system_oic_test": ("systemClientId", "systemClientSecret", "systemToken"),
}
OUTPUT = ROOT / ".local/postman/erp-local.postman_environment.json"


def value(key: str, current: str, *, secret: bool = False) -> dict[str, object]:
    return {
        "key": key,
        "value": current,
        "enabled": True,
        "type": "secret" if secret else "default",
    }


def main() -> int:
    source = ROOT / ".local/secrets/oauth-clients.json"
    if not source.exists():
        raise RuntimeFailure("Start the local stack first so OAuth clients are generated")
    clients = json.loads(source.read_text(encoding="utf-8"))
    values = [
        value("baseUrl", "https://127.0.0.1:8443/ords/erp/supplier-onboarding/v1"),
        value("tokenUrl", "https://127.0.0.1:8443/ords/erp/oauth/token"),
        value("flowRequestId", ""),
        value("reviewRequestId", "103"),
        value("duplicateRequestId", "104"),
        value("integrationLogId", "10002"),
    ]
    for client_name, (client_id, client_secret, token) in CLIENTS.items():
        values.extend(
            [
                value(client_id, client_name),
                value(client_secret, clients[client_name]["client_secret"], secret=True),
                value(token, "", secret=True),
            ]
        )
    environment = {
        "name": "ERP Supplier Onboarding - Local Generated",
        "values": values,
        "_postman_variable_scope": "environment",
        "_postman_exported_using": "repository generator; secrets excluded from Git",
    }
    write_json(OUTPUT, environment)
    OUTPUT.chmod(0o600)
    print(f"Generated ignored environment at {OUTPUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (RuntimeFailure, KeyError, json.JSONDecodeError) as exc:
        print(f"Postman environment generation failed: {exc}")
        raise SystemExit(1) from exc
