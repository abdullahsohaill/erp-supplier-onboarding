# Database, ORDS, Security, and End-to-End Test Instructions

After the container, wallet, migrations, seed data, and OAuth secrets are ready:

```bash
uv run python scripts/verify_schema.py
uv run python scripts/wait_for_ords.py
uv run pytest -q tests/integration tests/e2e
```

Database checks verify live schema counts, object validity, nonempty tables, validation-rule foreign keys, and the invariant that `retry_count` equals embedded retry-history length.

ORDS checks use the generated local CA certificate and OAuth client credentials. They verify:

- Requesters can read only their safe request projection.
- Requesters receive HTTP 403 for internal risk evidence.
- Reviewers can retrieve risk and duplicate evidence.
- Support/Admin can retrieve technical log details and embedded retry history.

The 14 end-to-end story checks cover request intake, correction, status, validation/duplicate evidence, risk, advisory AI output, Reviewer decisions, Requester guidance, dashboards, retry, mock Fusion creation, supplier-reference data, governed settings, sensitive-data masking, and the complete demo scenario set.

Generated reports are stored under ignored `reports/`. Tests never use `verify=False` and do not commit OAuth, wallet, or database secrets.
