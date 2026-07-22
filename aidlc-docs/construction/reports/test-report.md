# Consolidated Test Report

## Execution

Final command: `ERP_RUNTIME_TESTS=1 ./scripts/test.sh -q --junitxml=.local/reports/pytest.xml`

Result: 45 passed, 0 failed, 0 errors, 0 skipped, with one dependency deprecation warning. Runtime was 40.28 seconds.

| Category | Tests | Result |
|---|---:|---|
| Unit | 8 | PASS |
| Property-based | 4 | PASS |
| Integration/database | 5 | PASS |
| OpenAPI/ORDS contract | 3 | PASS |
| Security/abuse | 9 | PASS |
| End-to-end/user stories | 15 | PASS |
| Pytest performance smoke | 1 | PASS |

## Functional Coverage

All 14 approved user stories have executable flows. Tests cover the 42-operation API, five role boundaries, automatic validation/duplicate/risk processing, critical blockers, warning behavior, Reviewer evidence and decisions, dashboard actions, Admin Settings toggles, deterministic AI, Fusion/OIC mock behavior, retries, reference upserts, every-table seeds, and restart persistence.

## Quality Notes

Ruff and compile checks passed. The warning comes from the installed OpenAPI validator's deprecated convenience function and does not affect contract validity. JUnit and raw local evidence remain ignored under `.local/reports/`.
