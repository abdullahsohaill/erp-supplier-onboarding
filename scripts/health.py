from __future__ import annotations

import json
import ssl
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
    write_json(REPORTS / "health.json", {"containers": containers, "database": "UP", "edge": edge})
    print("Local stack health passed")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (RuntimeFailure, KeyError, OSError, ValueError) as exc:
        print(f"Health failed: {exc}")
        raise SystemExit(1) from exc
