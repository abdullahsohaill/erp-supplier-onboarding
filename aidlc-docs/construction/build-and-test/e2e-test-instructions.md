# End-to-End Test Instructions

## Run All Story Flows

```bash
./scripts/start.sh
python3 scripts/migrate.py
python3 scripts/seed.py
ERP_RUNTIME_TESTS=1 .venv/bin/pytest -q tests/e2e
```

The suite covers US-001 through US-014: intake/submit, correction/resubmit, tracking, critical validation, duplicate/risk/AI evidence, Reviewer decisions, dashboards, Fusion/mock submission, integration troubleshooting/retry, reference synchronization, Admin Settings, and demo scenarios.

The session fixture restores mutable integration scenarios before execution. Tests create unique dummy suppliers and never use real customer or banking data. A failure should be rerun first at the individual test path, then with the full E2E and regression suites.
