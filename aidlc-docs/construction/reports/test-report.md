# Consolidated Test Report

## Execution

Final command: `./scripts/qa.sh all`

Result: 583 passed, 0 failed, 0 errors, 0 skipped, with one dependency deprecation warning. Pytest runtime was 209.52 seconds.

| Category | Tests | Result |
|---|---:|---|
| Unit | 17 | PASS |
| Property-based | 4 | PASS |
| Integration/database | 151 | PASS |
| OpenAPI/ORDS/Postman/cloud contract | 262 | PASS |
| Security/abuse/role matrix | 133 | PASS |
| End-to-end/user stories | 15 | PASS |
| Pytest performance smoke | 1 | PASS |
| Total | 583 | PASS |

## Functional Coverage

All 14 approved user stories have executable flows. Tests cover the 42-operation API, five identities/four application roles, every unauthenticated route, every restricted route with a wrong role, every route with an allowed role, OpenAPI-to-handler role parity, automatic validation/duplicate/risk processing, critical blockers, warning behavior, Reviewer evidence and decisions, dashboard actions, Admin Settings toggles, deterministic AI, Fusion/OIC mock behavior, retries, reference upserts, every table/column/key/index/JSON/package/view, read-only verifier privileges, Postman assets, cloud-profile safety, and restart persistence.

## Quality Notes

The expansion exposed and corrected inconsistent wrong-role HTTP handling across ORDS handlers, a repeat-run cleanup dependency, a long column-list assertion, and a QA subprocess error path. Every handler now has an exact transport role guard and returns HTTP `403` before business logic for a disallowed role.

Ruff and compile checks passed. The warning comes from the installed OpenAPI validator's deprecated convenience function and does not affect contract validity. JUnit and raw local evidence remain ignored under `.local/reports/`.
