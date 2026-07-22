# Unit Test Instructions

## Static and Unit Gates

```bash
.venv/bin/ruff check scripts tests
.venv/bin/python -m compileall -q scripts tests
.venv/bin/pytest -q tests/unit tests/property
```

Unit tests inspect package/source contracts for safe envelopes, workflow order, projection allowlists, dashboard actions, input bounds, and state behavior. Hypothesis tests exercise mapping round trips, structured-address boundaries, ownership, forbidden fields, deterministic transformations, and retry invariants.

Runtime-marked tests are skipped unless `ERP_RUNTIME_TESTS=1`. A successful unit gate has zero failures and no Ruff or compile errors. Preserve Hypothesis reproduction details if a property fails.
