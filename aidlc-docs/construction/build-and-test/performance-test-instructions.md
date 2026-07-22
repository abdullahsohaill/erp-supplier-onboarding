# Performance Test Instructions

## Scope

These are local prototype measurements, not production capacity claims. The approved host baseline is at least 4 Docker CPUs and 8 GiB memory.

## Full Evidence Run

```bash
ERP_PERF_DURATION_SECONDS=300 \
  ERP_PERF_READ_SAMPLES=60 \
  ERP_PERF_WRITE_CYCLES=10 \
  .venv/bin/python scripts/performance.py
```

The harness warms each read path, records list/detail/dashboard/create/update/submit p50, p95, and maximum latency, then runs ten workers for five minutes. It records host allocation, image metadata, dataset counts, operations, errors, and error rate in ignored `.local/reports/performance.json`.

## Local Targets

| Operation | p95 target |
|---|---:|
| Request list/detail | 2 seconds |
| Requester dashboard | 3 seconds |
| Draft create/update | 2 seconds |
| Governed submit | 5 seconds |
| Ten-worker smoke | Less than 1 percent HTTP errors |

Investigate rate limiting, Oracle health, query plans, Docker memory pressure, and test-data growth before changing a threshold.
