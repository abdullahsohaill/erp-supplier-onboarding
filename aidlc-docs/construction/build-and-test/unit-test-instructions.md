# Unit, Property, Contract, and Security Test Instructions

These checks do not require Oracle or ORDS:

```bash
uv sync --locked
uv run pytest -q tests/unit tests/property tests/contract tests/security
```

Coverage includes:

- request normalization, score levels, state transitions, safe projection, retry-history invariants, and money constraints;
- Hypothesis round-trip, idempotency, range, lifecycle, data-minimization, and retry properties with shrinking enabled;
- exact DBML-to-DDL parity at 18 tables, 189 columns, and 17 foreign keys;
- exact parity among the technical catalog, 42 ORDS handler declarations, and 42 OpenAPI operations;
- meaningful seed inserts for every table and complete validation/risk/duplicate catalogs;
- manifest ordering, file coverage, and SHA-256 checksums;
- SQL/PLSQL install-unit completeness;
- loopback-only container ports, ignored secrets, masked bank design, OAuth on every operation, rate limits, and verified TLS use.

Generate machine-readable results and coverage:

```bash
uv run pytest -q tests/unit tests/property tests/contract tests/security \
  --junitxml=reports/pytest-static.xml \
  --cov=tests.support.reference_model \
  --cov=scripts.run_migrations \
  --cov-report=json:reports/coverage.json \
  --cov-fail-under=0
```

Hypothesis reports the minimal shrunk counterexample and replay information when a property fails. A discovered counterexample must be retained as an example-based regression test.
