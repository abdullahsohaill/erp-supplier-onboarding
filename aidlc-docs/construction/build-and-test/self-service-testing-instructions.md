# Self-Service Testing Instructions

## Complete Verification

Run the complete reproducible local workflow:

```bash
./scripts/qa.sh all
```

This starts the pinned local stack, reapplies 47 ordered assets, reseeds all 18 tables, regenerates Postman and local access assets, validates the schema/OpenAPI source, proves SQLcl wallet connectivity, and runs all 67 broad tests. JUnit output is written to ignored `.local/reports/pytest-full.xml`.

The broad suite keeps detailed matrices inside capability-level tests: all 42 operations, role combinations, database objects, and user stories are still checked even though pytest no longer reports each matrix row as a separate test.

## Oracle Database Actions and SQLcl

```bash
./scripts/qa.sh generate
open .local/demo/local-access.md
open https://localhost:8444/ords/sql-developer
./scripts/sqlcl.sh
```

Database Actions and SQLcl use `ERP_VERIFY`, the generated mTLS wallet, and SELECT-only grants. The browser console is TLS-protected and bound only to loopback port 8444. See `local-demo-runbook.md` for the exact demonstration sequence and the one optional manual macOS certificate-trust step.

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
| `contract` | OpenAPI, ORDS, all 42 operations, handler roles, and local API-client assets |
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

## Bruno - Recommended Account-Free Client

```bash
./scripts/bruno.sh open
```

The command installs the pinned local CLI dependency when needed, regenerates the API collection, places generated OAuth2 values only in the ignored owner-only collection, and opens Bruno Desktop. Bruno is offline-first and does not require an account. No import, environment selection, username, client secret, or token entry is required.

In Bruno, run `00 Authentication` once and then open any Requester, Reviewer, Support/Admin, System/OIC, or Guided Flows request. If the desktop app reports a local certificate warning, select `.local/trust/local-ca.crt` under Preferences, Use Custom CA Certificate. Do not disable TLS verification.

Verify authentication and representative role endpoints without the desktop UI:

```bash
./scripts/bruno.sh test
```

This runs five token requests plus Requester, Reviewer, and Support/Admin reads with the custom CA and writes ignored JUnit evidence to `.local/reports/bruno-smoke.xml`.

## Postman - Optional Compatibility Client

Regenerate the committed collection and ignored credential environment:

```bash
./scripts/qa.sh generate
```

Import these two files into Postman Desktop:

1. `postman/erp-supplier-onboarding.postman_collection.json`
2. `.local/postman/erp-local.postman_environment.json`

Add `.local/trust/local-ca.crt` as a trusted CA certificate in Postman. Keep SSL certificate verification enabled.

Run `00 Authentication` first. It obtains short-lived tokens for both Requesters, Reviewer, Support/Admin, and System/OIC without placing tokens in the committed collection. Then run a role folder, one canonical operation, or a guided flow. The collection contains every one of the 42 operations exactly once, representative safe payloads, declared-status tests, response-time checks, and Requester, Reviewer, and Support/Admin guided flows.

The committed environment template contains placeholders only. The generated local environment is mode `0600`, Git-ignored, and must not be shared. No Postman account is needed when Bruno is used instead.

## Authorization Checks

The automated security matrix proves three independent properties:

1. Every operation rejects a missing token.
2. Every restricted operation returns HTTP `403` for a valid token carrying a disallowed role.
3. At least one declared allowed role reaches every operation without authentication, authorization, or throttle failure.

The ORDS source contract additionally compares each handler's transport guard to the roles declared for that operation in OpenAPI. Request ownership and cross-owner non-disclosure remain separate tests.
