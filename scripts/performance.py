from __future__ import annotations

import os
import statistics
import sys
import time
from collections.abc import Callable
from concurrent.futures import ThreadPoolExecutor
from datetime import UTC, datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from runtime import REPORTS, RuntimeFailure, command, ensure_local_dirs, write_json

from tests.e2e.helpers import complete_payload
from tests.support.api import ApiClient
from tests.support.config import load_runtime_config
from tests.support.db import query_scalar


def percentile(values: list[float], percent: int) -> float:
    ordered = sorted(values)
    index = max(0, min(len(ordered) - 1, round((percent / 100) * (len(ordered) - 1))))
    return ordered[index]


def timed_call(operation: Callable[[], object]) -> tuple[float, object]:
    started = time.perf_counter()
    result = operation()
    return (time.perf_counter() - started) * 1000, result


def summarize(values: list[float], target_ms: float) -> dict[str, float | int | bool]:
    return {
        "samples": len(values),
        "p50_ms": round(statistics.median(values), 2),
        "p95_ms": round(percentile(values, 95), 2),
        "max_ms": round(max(values), 2),
        "target_p95_ms": target_ms,
        "passed": percentile(values, 95) <= target_ms,
    }


def assert_success(response: object, expected: set[int] | None = None) -> None:
    expected = expected or {200}
    status = getattr(response, "status_code", None)
    if status not in expected:
        body = getattr(response, "text", "")
        raise RuntimeFailure(f"Performance operation returned HTTP {status}: {body[:300]}")


def measure_reads(client: ApiClient, request_id: int, samples: int) -> dict[str, object]:
    operations = {
        "list": lambda: client.request("GET", "/requests?limit=25"),
        "detail": lambda: client.request("GET", f"/requests/{request_id}"),
        "dashboard": lambda: client.request("GET", "/dashboard/requester-summary"),
    }
    values = {name: [] for name in operations}
    for operation in operations.values():
        for _ in range(2):
            assert_success(operation())
    for index in range(samples):
        name = tuple(operations)[index % len(operations)]
        elapsed, response = timed_call(operations[name])
        assert_success(response)
        values[name].append(elapsed)
        time.sleep(0.55)
    return {
        "list": summarize(values["list"], 2_000),
        "detail": summarize(values["detail"], 2_000),
        "dashboard": summarize(values["dashboard"], 3_000),
    }


def measure_writes(client: ApiClient, cycles: int) -> dict[str, object]:
    values: dict[str, list[float]] = {"create": [], "update": [], "submit": []}
    for _ in range(cycles):
        elapsed, response = timed_call(
            lambda: client.request("POST", "/requests", json=complete_payload())
        )
        assert_success(response, {201})
        values["create"].append(elapsed)
        request_id = response.json()["data"]["requestId"]
        time.sleep(2.05)

        elapsed, response = timed_call(
            lambda request_id=request_id: client.request(
                "PATCH",
                f"/requests/{request_id}",
                json={"businessJustification": "Measured complete business justification."},
            )
        )
        assert_success(response)
        values["update"].append(elapsed)
        time.sleep(2.05)

        elapsed, response = timed_call(
            lambda request_id=request_id: client.request(
                "POST", f"/requests/{request_id}/submit"
            )
        )
        assert_success(response)
        values["submit"].append(elapsed)
        time.sleep(2.05)
    return {
        "create": summarize(values["create"], 2_000),
        "update": summarize(values["update"], 2_000),
        "submit": summarize(values["submit"], 5_000),
    }


def concurrent_smoke(
    clients: tuple[ApiClient, ApiClient],
    request_ids: tuple[int, int],
    duration_seconds: int,
) -> dict[str, float | int | bool]:
    deadline = time.monotonic() + duration_seconds

    def worker(worker_id: int) -> tuple[int, int]:
        client = clients[worker_id % len(clients)]
        request_id = request_ids[worker_id % len(request_ids)]
        paths = (
            "/requests?limit=25",
            f"/requests/{request_id}",
            "/dashboard/requester-summary",
        )
        total = 0
        errors = 0
        while time.monotonic() < deadline:
            response = client.request("GET", paths[total % len(paths)])
            total += 1
            errors += int(response.status_code >= 400)
            time.sleep(5.1)
        return total, errors

    with ThreadPoolExecutor(max_workers=10) as executor:
        results = list(executor.map(worker, range(10)))
    total = sum(item[0] for item in results)
    errors = sum(item[1] for item in results)
    error_rate = errors / total if total else 1.0
    return {
        "workers": 10,
        "duration_seconds": duration_seconds,
        "requests": total,
        "errors": errors,
        "error_rate_percent": round(error_rate * 100, 3),
        "passed": error_rate < 0.01,
    }


def main() -> int:
    ensure_local_dirs()
    config = load_runtime_config()
    requester_a = ApiClient(config, "requester_a")
    requester_b = ApiClient(config, "requester_b")
    duration = int(os.environ.get("ERP_PERF_DURATION_SECONDS", "30"))
    read_samples = int(os.environ.get("ERP_PERF_READ_SAMPLES", "30"))
    write_cycles = int(os.environ.get("ERP_PERF_WRITE_CYCLES", "5"))

    seed_a = requester_a.request("POST", "/requests", json=complete_payload())
    seed_b = requester_b.request("POST", "/requests", json=complete_payload())
    assert_success(seed_a, {201})
    assert_success(seed_b, {201})
    request_ids = (seed_a.json()["data"]["requestId"], seed_b.json()["data"]["requestId"])
    time.sleep(2.05)

    report = {
        "generated_at": datetime.now(UTC).isoformat(),
        "scope": "local prototype only; not a production benchmark",
        "host": command(
            ["docker", "info", "--format", "{{.NCPU}} CPUs, {{.MemTotal}} bytes memory"]
        ).stdout.strip(),
        "images": command(
            ["docker", "compose", "images", "--format", "json"]
        ).stdout.splitlines(),
        "dataset": {
            "supplier_requests_before_measurement": int(
                query_scalar("select count(*) from supplier_request")
            ),
            "existing_suppliers": int(query_scalar("select count(*) from existing_supplier_ref")),
        },
        "warmup": "Two calls per read operation plus two seed creates",
        "sequential_reads": measure_reads(requester_a, request_ids[0], read_samples),
        "sequential_writes": measure_writes(requester_a, write_cycles),
        "concurrent_smoke": concurrent_smoke(
            (requester_a, requester_b), request_ids, duration
        ),
    }
    passed = all(
        item["passed"]
        for section in (report["sequential_reads"], report["sequential_writes"])
        for item in section.values()
    ) and report["concurrent_smoke"]["passed"]
    report["passed"] = passed
    write_json(REPORTS / "performance.json", report)
    if not passed:
        raise RuntimeFailure("One or more local performance gates failed")
    print("Local performance evidence passed; report written to .local/reports/performance.json")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (RuntimeFailure, KeyError, OSError, ValueError) as exc:
        print(f"Performance evidence failed: {exc}")
        raise SystemExit(1) from exc
