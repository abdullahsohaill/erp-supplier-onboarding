# Local Performance Smoke-Test Instructions

The prototype performance gate is intentionally a local smoke test rather than a production SLA:

```bash
uv run pytest -q -m performance tests/performance
```

The checks cover bounded request list, request detail, duplicate evidence, and risk-assessment queries against the seeded local database. Current thresholds are one or two seconds per query, allowing for development-host variability while still detecting unindexed or accidentally unbounded access.

Production latency, throughput, concurrency, availability, RTO, and RPO targets require customer workload and topology decisions. The local smoke limits must not be represented as production commitments.
