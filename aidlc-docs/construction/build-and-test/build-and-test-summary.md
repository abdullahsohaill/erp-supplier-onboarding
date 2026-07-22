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
| Application tests | PASS: 67 of 67 broad tests |
| Local performance | PASS |
| Application-controlled security scans | PASS |
| Oracle base-image vulnerability gate | BLOCKED |

## Test Distribution

| Suite | Passed |
|---|---:|
| Unit | 10 |
| Property | 4 |
| Integration | 12 |
| Contract | 12 |
| Security | 13 |
| E2E/story | 15 |
| Pytest performance | 1 |
| Total | 67 |

The post-authorization-fix performance harness passed ten workers for 300 seconds with 574 requests and zero errors. Every measured p95 was below its local threshold.

## Overall Status

UOW-001 through UOW-005 application code, migrations, APIs, seeds, mocks, account-free Bruno, Postman compatibility, self-service query tooling, and tests are complete. The local runtime is healthy and suitable for controlled development/demo review. Build and Test cannot mark the local container production-ready because the latest official Oracle ADB Free image scan contains 184 High and 3 Critical fixed-version findings.

## Required Decision

Continue using the pinned local Oracle ADB Free image for controlled development and demonstration, with the vendor finding explicitly accepted for that limited purpose, or adopt a patched official local image when Oracle publishes one. Do not treat the current image as production-ready.
