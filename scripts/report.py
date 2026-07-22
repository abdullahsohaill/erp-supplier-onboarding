from __future__ import annotations

import json
from datetime import UTC, datetime
from pathlib import Path

from defusedxml import ElementTree
from runtime import REPORTS, ensure_local_dirs


def read_json(name: str) -> object:
    path = REPORTS / name
    return json.loads(path.read_text(encoding="utf-8")) if path.exists() else {"status": "NOT_RUN"}


def trivy_summary(name: str) -> dict[str, object]:
    report = read_json(name)
    if not isinstance(report, dict) or "Results" not in report:
        return {"status": "NOT_RUN"}
    vulnerabilities = [
        item
        for result in report.get("Results", [])
        for item in (result.get("Vulnerabilities") or [])
    ]
    return {
        "high": sum(item.get("Severity") == "HIGH" for item in vulnerabilities),
        "critical": sum(item.get("Severity") == "CRITICAL" for item in vulnerabilities),
        "total": len(vulnerabilities),
    }


def test_summary(path: Path) -> dict[str, object]:
    if not path.exists():
        return {"status": "NOT_RUN"}
    root = ElementTree.parse(path).getroot()
    suites = [root] if root.tag == "testsuite" else list(root.findall("testsuite"))
    keys = ("tests", "failures", "errors", "skipped")
    return {key: sum(int(suite.get(key, "0")) for suite in suites) for key in keys}


def security_summary() -> dict[str, object]:
    pip_audit = read_json("pip-audit.json")
    dependencies = pip_audit.get("dependencies", []) if isinstance(pip_audit, dict) else []
    gitleaks = read_json("gitleaks-working-tree.json")
    return {
        "python_dependencies": len(dependencies),
        "python_vulnerabilities": sum(len(item.get("vulns", [])) for item in dependencies),
        "gitleaks_findings": len(gitleaks) if isinstance(gitleaks, list) else "NOT_RUN",
        "filesystem": trivy_summary("trivy-filesystem-final.json"),
        "nginx_image": trivy_summary("trivy-nginx-image.json"),
        "oracle_image": trivy_summary("trivy-oracle-image.json"),
        "oracle_image_gate": "BLOCKED_PENDING_VENDOR_PATCH_OR_EXPLICIT_ACCEPTANCE",
    }


def main() -> int:
    ensure_local_dirs()
    pytest_report = REPORTS / "pytest-full.xml"
    if not pytest_report.exists():
        pytest_report = REPORTS / "pytest.xml"
    sections = {
        "Preflight": read_json("preflight.json"),
        "Images": read_json("image-metadata.json"),
        "Certificate": read_json("ords-certificate.json"),
        "Migrations": read_json("migration-run.json"),
        "Health": read_json("health.json"),
        "Verification": read_json("verification.json"),
        "SQLcl": read_json("sqlcl-smoke.json"),
        "Tests": test_summary(pytest_report),
        "Performance": read_json("performance.json"),
        "Security": security_summary(),
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
