from __future__ import annotations

from runtime import RuntimeFailure, command

SETTINGS = {
    "database.api.enabled": "false",
    "feature.sdw": "false",
    "mongo.enabled": "false",
    "restEnabledSql.active": "false",
}


def main() -> int:
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
            ]
        )
    for name, expected in SETTINGS.items():
        result = command(
            [
                "docker",
                "exec",
                "erp-oracle-adb",
                "ords",
                "--config",
                "/u01/ords",
                "config",
                "get",
                name,
            ]
        )
        if expected not in result.stdout.lower():
            raise RuntimeFailure(f"ORDS hardening setting did not persist: {name}")
    print("ORDS optional SQL, Database API, Database Actions, and Mongo features disabled")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except RuntimeFailure as exc:
        print(f"ORDS hardening failed: {exc}")
        raise SystemExit(1) from exc
