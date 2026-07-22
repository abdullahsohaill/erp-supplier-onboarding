# Consolidated Test Report

## Execution

Final command: `./scripts/qa.sh all`

Result: 66 passed, 0 failed, 0 errors, 0 skipped, with one dependency deprecation warning. Pytest runtime was 209.18 seconds.

| Category | Tests | Result |
|---|---:|---|
| Unit | 10 | PASS |
| Property-based | 4 | PASS |
| Integration/database | 12 | PASS |
| OpenAPI/ORDS/Postman contract | 12 | PASS |
| Security/abuse/role matrix | 12 | PASS |
| End-to-end/user stories | 15 | PASS |
| Pytest performance smoke | 1 | PASS |
| Total | 66 | PASS |

## Functional Coverage

All 14 approved user stories have executable flows. Tests cover the 42-operation API, five identities/four application roles, every unauthenticated route, every restricted route with a wrong role, every route with an allowed role, OpenAPI-to-handler role parity, automatic validation/duplicate/risk processing, critical blockers, warning behavior, Reviewer evidence and decisions, dashboard actions, Admin Settings toggles, deterministic AI, Fusion/OIC mock behavior, retries, reference upserts, every table/column/key/index/JSON/package/view, read-only verifier privileges, Postman assets, and restart persistence.

## Quality Notes

The matrix coverage is grouped into broad capability tests so pytest reports a reviewable total while retaining every detailed assertion. The final rerun also corrected repeat-start behavior by verifying persisted ORDS hardening through its configuration files instead of invoking a potentially blocking live `ords config get` process. Every handler has an exact transport role guard and returns HTTP `403` before business logic for a disallowed role.

Ruff and compile checks passed. The warning comes from the installed OpenAPI validator's deprecated convenience function and does not affect contract validity. JUnit and raw local evidence remain ignored under `.local/reports/`.
