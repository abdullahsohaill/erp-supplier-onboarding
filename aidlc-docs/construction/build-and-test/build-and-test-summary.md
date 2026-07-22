# Build and Test Summary

## Build Status

| Gate | Result |
|---|---|
| Hash-locked Python environment | PASS |
| Ruff and Python compile | PASS |
| Oracle/ORDS startup and health | PASS |
| Migration and package compile | PASS |
| Schema parity | PASS: 18 tables / 189 columns / 17 foreign keys / 0 invalid objects |
| Seed completeness | PASS: data in all 18 tables |
| OpenAPI/ORDS parity | PASS: 42 operations |
| Stop/start persistence | PASS |
| Application tests | PASS: 45 of 45 |
| Local performance | PASS |
| Application-controlled security scans | PASS |
| Oracle base-image vulnerability gate | BLOCKED |

## Test Distribution

| Suite | Passed |
|---|---:|
| Unit | 8 |
| Property | 4 |
| Integration | 5 |
| Contract | 3 |
| Security | 9 |
| E2E/story | 15 |
| Pytest performance | 1 |
| Total | 45 |

The separate full performance harness passed ten workers for 300 seconds with 570 requests and zero errors. Every measured p95 was below its local threshold.

## Overall Status

UOW-001 through UOW-005 application code, migrations, APIs, seeds, mocks, and tests are complete. The local runtime is healthy and suitable for controlled development/demo review. Build and Test cannot be marked production-ready because the latest official Oracle ADB Free image scan contains 184 High and 3 Critical fixed-version findings.

## Required Decision

Use a patched official Oracle image when Oracle publishes one, or explicitly accept the documented image risk for time-bounded local prototype use. Production acceptance is not recommended.
