# Integration Test Instructions

## Setup

```bash
./scripts/start.sh
python3 scripts/migrate.py
python3 scripts/seed.py
ERP_RUNTIME_TESTS=1 .venv/bin/pytest -q tests/integration tests/contract
```

## Scenarios

| Scenario | Expected result |
|---|---|
| Migration/install | 46 assets apply in order; validators pass |
| Verified rerun | Unchanged assets skip safely; validators rerun |
| Schema contract | 18 tables, 189 columns, 17 foreign keys, zero invalid objects |
| Seed contract | Every table has data; retry count equals history length |
| ORDS/OpenAPI | 42 operations match method/path source |
| OAuth and roles | Unauthenticated, wrong-role, and cross-owner access fail |
| Restart recovery | Compose stop/start preserves the named volume and data |
| Cross-unit workflow | Intake, analysis, review, integration, retry, and Admin Settings interoperate |

After testing, use `./scripts/stop.sh` to preserve data or leave the healthy local stack running for review.
