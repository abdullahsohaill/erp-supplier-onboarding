from __future__ import annotations

import argparse

from runtime import REPORTS, ROOT, RuntimeFailure, command, ensure_local_dirs

PYTHON = ROOT / ".venv/bin/python"


def run_python(script: str) -> None:
    command([str(PYTHON), script], capture=False)


def runtime_pytest(label: str, paths: list[str]) -> None:
    report = REPORTS / f"pytest-{label}.xml"
    command(
        [str(PYTHON), "-m", "pytest", "-q", f"--junitxml={report}", *paths],
        capture=False,
        env={"ERP_RUNTIME_TESTS": "1"},
        timeout=1200,
    )


def generate() -> None:
    run_python("scripts/generate_postman.py")
    run_python("scripts/generate_postman_environment.py")


def require_runtime() -> None:
    command([str(PYTHON), "scripts/health.py"], capture=False)


def main() -> int:
    parser = argparse.ArgumentParser(description="Self-service ERP verification runner")
    parser.add_argument("mode", choices=["generate", "db", "contract", "auth", "flows", "all"])
    args = parser.parse_args()
    ensure_local_dirs()
    if args.mode == "generate":
        generate()
        return 0
    if args.mode == "all":
        command([str(ROOT / "scripts/start.sh")], capture=False, timeout=1800)
        run_python("scripts/migrate.py")
        run_python("scripts/seed.py")
        generate()
        run_python("scripts/verify.py")
        command(
            [str(ROOT / "scripts/test.sh"), "-q", f"--junitxml={REPORTS / 'pytest-full.xml'}"],
            capture=False,
            env={"ERP_RUNTIME_TESTS": "1", "PYTHONHASHSEED": "0"},
            timeout=1800,
        )
        return 0
    require_runtime()
    selections = {
        "db": ["tests/integration"],
        "contract": ["tests/contract"],
        "auth": ["tests/security"],
        "flows": ["tests/e2e"],
    }
    runtime_pytest(args.mode, selections[args.mode])
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (RuntimeFailure, OSError, KeyError) as exc:
        print(f"QA run failed: {exc}")
        raise SystemExit(1) from exc
