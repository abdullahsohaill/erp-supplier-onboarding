# Local Oracle Demonstration Runbook

## Current Ready State

The local stack is installed, running, freshly migrated, and seeded. Postman Desktop, Oracle SQLcl, and OpenJDK are installed. Generated passwords, OAuth clients, wallet files, and certificates are under ignored `.local/` directories.

## Before the Meeting

1. Start Docker Desktop and allow at least 4 CPUs and 8 GiB RAM.
2. In the repository, run:

```bash
git checkout construction-phase
./scripts/start.sh
.venv/bin/python scripts/health.py
```

3. Generate or refresh the owner-only access card and Postman environment:

```bash
./scripts/qa.sh generate
open .local/demo/local-access.md
```

Do not screen-share or send the access card. It contains the local read-only database password.

## One Manual Certificate Step

For a browser with no certificate warning, open `.local/trust/local-ca.crt` in Keychain Access, add it to the login keychain, and set it to Always Trust. This changes macOS trust settings and is intentionally left as a manual user action.

Postman can trust the same file under Settings, Certificates, CA Certificates. Keep SSL certificate verification enabled.

## Demonstrate Oracle Database Actions

1. Open `https://localhost:8444/ords/sql-developer`.
2. Sign in with user `ERP_VERIFY` and the password in `.local/demo/local-access.md`.
3. If Advanced asks for a path/schema alias, enter `erp-inspector`.
4. Open SQL Worksheet and run:

```sql
select request_number, supplier_name, status
from ERP_APP.supplier_request
order by request_id;
```

5. Show schema scale:

```sql
select count(*) table_count from all_tables where owner = 'ERP_APP';
select count(*) column_count from all_tab_columns where owner = 'ERP_APP';
select count(*) foreign_keys
from all_constraints
where owner = 'ERP_APP' and constraint_type = 'R';
```

Expected values are 18 tables, 189 columns, and 17 foreign keys.

6. Show duplicate/risk/integration evidence:

```sql
select r.request_number, d.match_score, d.match_level, d.candidate_supplier_number
from ERP_APP.supplier_request r
join ERP_APP.duplicate_match d on d.request_id = r.request_id
where d.is_current = 1;

select r.request_number, a.risk_score, a.risk_level
from ERP_APP.supplier_request r
join ERP_APP.risk_assessment a on a.request_id = r.request_id
where a.is_current = 1;

select r.request_number, i.status, i.error_category, i.retry_count
from ERP_APP.supplier_request r
join ERP_APP.integration_log i on i.request_id = r.request_id;
```

`ERP_VERIFY` cannot insert, update, delete, or create objects. The automated suite proves write attempts fail.

## Demonstrate Oracle SQLcl

Run:

```bash
./scripts/sqlcl.sh
```

Enter the `ERP_VERIFY` password from `.local/demo/local-access.md`. The wrapper sets the Homebrew OpenJDK location, `TNS_ADMIN`, generated wallet, and `erpatp_tp` service.

At the SQL prompt:

```sql
select request_number, supplier_name, status
from ERP_APP.supplier_request
order by request_id;
```

Exit with `exit`.

For an automated native-client proof:

```bash
.venv/bin/python scripts/sqlcl_smoke.py
```

## Demonstrate Postman

1. Open Postman Desktop.
2. Import `postman/erp-supplier-onboarding.postman_collection.json`.
3. Import `.local/postman/erp-local.postman_environment.json`.
4. Select the imported local environment.
5. Add `.local/trust/local-ca.crt` as a CA certificate and keep TLS verification enabled.
6. Run `00 Authentication` first.
7. Run a guided flow or a role folder.

Recommended sequence:

| Order | Demonstration | Expected point |
|---:|---|---|
| 1 | Requester list/detail | Ownership-safe status and timeline |
| 2 | Create Draft | Structured supplier, address, contact, masked bank metadata |
| 3 | Submit critical duplicate | Exact tax/bank prevents submission |
| 4 | Reviewer evidence | Duplicate, risk, validation, and advisory AI are together |
| 5 | Request correction | Targeted correction item is recorded |
| 6 | Approve clean request | Selected evidence is stored with decision |
| 7 | Submit to Fusion mock | Supplier number and integration success appear |
| 8 | Retry failed integration | Retry count/history and eligibility update atomically |
| 9 | Admin Settings | Validation/risk/duplicate controls and reference data |

The collection contains all 42 canonical operations exactly once and generates role tokens without committing secrets.

## Fast Read-Only CLI Inspection

```bash
.venv/bin/python scripts/query.py --catalog
.venv/bin/python scripts/query.py --file 01_schema_inventory.sql
.venv/bin/python scripts/query.py --file 02_requests_and_status.sql
.venv/bin/python scripts/query.py --file 03_validation_duplicate_risk_ai.sql
.venv/bin/python scripts/query.py --file 04_integration_and_retry.sql
.venv/bin/python scripts/query.py --file 05_admin_settings.sql
.venv/bin/python scripts/query.py --file 06_security_and_privileges.sql
```

## Test and Report Evidence

```bash
./scripts/qa.sh all
.venv/bin/python scripts/report.py
```

The complete suite is 67 broad tests. The committed presentation report is `aidlc-docs/construction/reports/team-lead-construction-report.md`. Sanitized raw runtime evidence is generated under ignored `.local/reports/`.

## Stop and Resume

Stop without deleting the database:

```bash
./scripts/stop.sh
```

Resume later:

```bash
./scripts/start.sh
```

Do not run the guarded reset before a presentation. It deletes the local database volume and is intended only for a deliberate clean rebuild.

