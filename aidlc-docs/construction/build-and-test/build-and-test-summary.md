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
| Application tests | PASS: 583 of 583 |
| Local performance | PASS |
| Application-controlled security scans | PASS |
| Oracle base-image vulnerability gate | BLOCKED |

## Test Distribution

| Suite | Passed |
|---|---:|
| Unit | 17 |
| Property | 4 |
| Integration | 151 |
| Contract | 262 |
| Security | 133 |
| E2E/story | 15 |
| Pytest performance | 1 |
| Total | 583 |

The post-authorization-fix performance harness passed ten workers for 300 seconds with 574 requests and zero errors. Every measured p95 was below its local threshold.

## Overall Status

UOW-001 through UOW-005 application code, migrations, APIs, seeds, mocks, self-service query/Postman tooling, and tests are complete. The local runtime is healthy and suitable for controlled development/demo review. Build and Test cannot mark the local container production-ready because the latest official Oracle ADB Free image scan contains 184 High and 3 Critical fixed-version findings.

## Required Decision

Use managed Oracle Always Free ATP for the supported shared/cloud target, or use a patched official local image when Oracle publishes one. A time-bounded local-only exception still requires explicit informed acceptance. Managed cloud execution remains pending the user's OCI database, wallet, network, credentials, and ORDS endpoint.
