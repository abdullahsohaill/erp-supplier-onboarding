# Self-Service Testing Instructions

## Complete Verification

Run the complete reproducible local workflow:

```bash
./scripts/qa.sh all
```

This starts the pinned local stack, reapplies 47 ordered assets, reseeds all 18 tables, regenerates Postman assets, validates the schema/OpenAPI source, and runs all 583 tests. JUnit output is written to ignored `.local/reports/pytest-full.xml`.

Run a smaller suite against an already healthy stack:

```bash
./scripts/qa.sh db
./scripts/qa.sh contract
./scripts/qa.sh auth
./scripts/qa.sh flows
```

| Mode | Coverage |
|---|---|
| `db` | Tables, columns, keys, indexes, JSON data, seeds, packages, views, migrations, and read-only verifier |
| `contract` | OpenAPI, ORDS, all 42 operations, handler roles, Postman assets, and cloud profile |
| `auth` | Authentication, every wrong/allowed role route, ownership, abuse, TLS/CORS, masking, redaction, and throttling |
| `flows` | All 14 approved user stories |

## Read-Only Oracle Inspection

List and run the curated query catalog:

```bash
.venv/bin/python scripts/query.py --catalog
.venv/bin/python scripts/query.py --file 01_schema_inventory.sql
.venv/bin/python scripts/query.py --file 03_validation_duplicate_risk_ai.sql
```

Run an ad hoc read-only query:

```bash
.venv/bin/python scripts/query.py \
  --sql "select request_number, supplier_name, status from ERP_APP.supplier_request order by request_id"
```

The utility connects as `ERP_VERIFY`. The parser permits only `SELECT`, `WITH`, and `DESCRIBE`, while Oracle grants provide the authoritative protection: `ERP_VERIFY` has `SELECT` on the 18 tables and 4 views and no DML or DDL privilege.

For SQL Developer or another Oracle client, use the generated wallet under `.local/trust/tls_wallet`, service `erpatp_tp`, username `ERP_VERIFY`, and the local verifier password from `.local/secrets/adb.env`. Do not share or commit that file.

## Postman

Regenerate the committed collection and ignored credential environment:

```bash
./scripts/qa.sh generate
```

Import these two files into Postman Desktop:

1. `postman/erp-supplier-onboarding.postman_collection.json`
2. `.local/postman/erp-local.postman_environment.json`

Add `.local/trust/local-ca.crt` as a trusted CA certificate in Postman. Keep SSL certificate verification enabled.

Run `00 Authentication` first. It obtains short-lived tokens for both Requesters, Reviewer, Support/Admin, and System/OIC without placing tokens in the committed collection. Then run a role folder, one canonical operation, or a guided flow. The collection contains every one of the 42 operations exactly once, representative safe payloads, declared-status tests, response-time checks, and Requester, Reviewer, and Support/Admin guided flows.

The committed environment template contains placeholders only. The generated local environment is mode `0600`, Git-ignored, and must not be shared.

## Authorization Checks

The automated security matrix proves three independent properties:

1. Every operation rejects a missing token.
2. Every restricted operation returns HTTP `403` for a valid token carrying a disallowed role.
3. At least one declared allowed role reaches every operation without authentication, authorization, or throttle failure.

The ORDS source contract additionally compares each handler's transport guard to the roles declared for that operation in OpenAPI. Request ownership and cross-owner non-disclosure remain separate tests.
