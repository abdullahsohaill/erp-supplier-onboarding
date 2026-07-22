from __future__ import annotations

import json
import ssl
import time
import urllib.error
import urllib.request

from runtime import REPORTS, TRUST, RuntimeFailure, command, load_env, sqlplus, write_json


def main() -> int:
    env = load_env()
    state = command(["docker", "compose", "ps", "--format", "json"]).stdout
    containers = [json.loads(line) for line in state.splitlines() if line.strip()]
    if len(containers) != 2 or any(item.get("State") != "running" for item in containers):
        raise RuntimeFailure("Expected Oracle and edge containers are not both running")
    database = sqlplus("ADMIN", env["ADMIN_PASSWORD"], "select 'DATABASE_UP' status from dual;")
    if "DATABASE_UP" not in database:
        raise RuntimeFailure("Database health query failed")
    context = ssl.create_default_context(cafile=str(TRUST / "local-ca.crt"))
    with urllib.request.urlopen(
        "https://127.0.0.1:8443/healthz", context=context, timeout=10
    ) as response:
        edge = json.loads(response.read().decode("utf-8"))
    if edge.get("status") != "UP":
        raise RuntimeFailure("Edge health endpoint did not report UP")
    application_api: dict[str, object] | None = None
    for attempt in range(1, 7):
        try:
            urllib.request.urlopen(  # noqa: S310 - fixed local HTTPS endpoint.
                "https://127.0.0.1:8443/ords/erp/supplier-onboarding/v1/requests",
                context=context,
                timeout=30,
            )
        except urllib.error.HTTPError as exc:
            if exc.code not in {401, 403}:
                raise
            application_api = {
                "status": "UP",
                "unauthenticated_status": exc.code,
                "attempt": attempt,
            }
            break
        except (TimeoutError, urllib.error.URLError):
            if attempt == 6:
                raise
            time.sleep(5)
        else:
            raise RuntimeFailure("Application API did not deny unauthenticated readiness probe")
    if application_api is None:
        raise RuntimeFailure("Application API readiness probe did not complete")
    database_actions_request = urllib.request.Request(
        "https://127.0.0.1:8444/ords/sql-developer", method="GET"
    )
    try:
        with urllib.request.urlopen(  # noqa: S310 - fixed local HTTPS endpoint.
            database_actions_request, context=context, timeout=20
        ) as response:
            database_actions = {
                "status": "UP",
                "http_status": response.status,
                "final_url": response.url,
            }
    except urllib.error.HTTPError as exc:
        if exc.code not in {401, 302, 303}:
            raise
        database_actions = {
            "status": "UP",
            "http_status": exc.code,
            "final_url": exc.url,
        }
    write_json(
        REPORTS / "health.json",
        {
            "containers": containers,
            "database": "UP",
            "edge": edge,
            "application_api": application_api,
            "database_actions": database_actions,
        },
    )
    print("Local stack health passed")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (RuntimeFailure, KeyError, OSError, ValueError) as exc:
        print(f"Health failed: {exc}")
        raise SystemExit(1) from exc
