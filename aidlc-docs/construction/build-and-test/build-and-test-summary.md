# Build and Test Summary

## Current Result

The implementation is installed and verified against a healthy local Oracle Autonomous AI Database Free ATP workload with bundled HTTPS ORDS. All migrations, seed data, schema checks, API tests, security checks, end-to-end scenarios, and performance smoke tests complete successfully.

## Completed Checks

| Check | Result |
|---|---|
| Managed test runtime | Python 3.13.14 provisioned by `uv` |
| Locked dependencies | `uv.lock` generated and synchronized |
| Complete automated suite | 64 passed, 0 failed, 0 skipped |
| Oracle/ORDS/e2e/performance tests | Passed against the live local HTTPS runtime |
| Schema parity | Live verification passed: 18 tables, 189 columns, 17 foreign keys, 0 invalid objects |
| Endpoint parity | 42 technical-design entries = 42 ORDS declarations = 42 OpenAPI operations |
| Seed coverage | Every one of the 18 application tables has meaningful synthetic inserts |
| Validation catalog | VAL-001 through VAL-009 present |
| Scoring configuration | 12 risk rows and 10 duplicate rows, including thresholds |
| Property tests | Normalization, round trip, score ranges, status behavior, projection minimization, money, and retry history passed |
| Secret/TLS/security checks | Passed; loopback ports, ignored secret paths, OAuth on all operations, no disabled certificate validation |
| Dependency audit | Initial two findings fixed by upgrading pytest to 9.0.3 and requests to 2.33.0; final audit reports no known vulnerabilities |
| SBOM | CycloneDX 1.5 generated under ignored `reports/sbom.cdx.json` |

## Reproduction Commands

After Docker Engine and Compose are available, run:

```bash
./scripts/bootstrap-local.sh
./scripts/copy-wallet.sh
uv run python scripts/run_migrations.py --wait
uv run python scripts/verify_schema.py
./scripts/run_all_tests.sh
```

The completed run satisfies the runtime gate: migrations and package compilation succeeded, all 18 tables contain seed data, no Oracle object is invalid, the secured HTTPS endpoints are reachable, all use-case checks pass, and the complete test suite executes without skips.
