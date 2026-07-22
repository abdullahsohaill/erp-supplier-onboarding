# Oracle Always Free ATP Instructions

## Supported Target

Oracle Always Free Autonomous AI Database remains the recommended shared/cloud target. Create it with the Transaction Processing workload. Oracle manages the service image and patching, so the local ADB Free container vulnerability finding does not transfer to this managed target.

The repository is cloud-ready but has not connected to an OCI tenancy because no user wallet or credentials were supplied. Do not treat the local evidence as proof of a cloud deployment.

Official references:

- [Always Free Autonomous AI Database](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/autonomous-always-free.html)
- [Download an instance wallet](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/connect-download-wallet.html)
- [Configure customer-managed ORDS for Autonomous Database](https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/26.1/ordig/installing-and-configuring-customer-managed-ords-autonomous-database.html)

## Manual OCI Steps

1. Sign in to OCI and create an Autonomous AI Database in Transaction Processing mode with the Always Free option.
2. Select the approved region, compartment, database/display names, ADMIN password, and network-access policy. Do not use repository sample passwords.
3. From Database Connection, download an instance wallet and create a separate strong wallet password.
4. Extract the wallet under an ignored location such as `.local/secrets/atp-wallet/` and restrict it to the local user.
5. Copy `config/atp-cloud.env.example` to `.local/secrets/atp-cloud.env` and replace every placeholder locally.
6. Run the connection preflight below.
7. Decide whether to use Autonomous Database's managed ORDS endpoint or a customer-managed ORDS 26.1 deployment. Configure OAuth/IAM roles and allowed origins before installing the API contract.

## Connection Preflight

```bash
chmod 600 .local/secrets/atp-cloud.env
.venv/bin/python scripts/cloud_atp_preflight.py
```

The preflight verifies wallet files, establishes a TLS database session, reports only non-secret database metadata, and optionally verifies that an unauthenticated ORDS request is denied. It never prints a password or wallet password.

## Cloud Installation Gate

After the preflight passes, run the same ordered DDL, package, ORDS, seed, and test responsibilities against a dedicated non-production cloud schema. Local OAuth client registration is intentionally excluded from cloud installation; cloud identity must use the approved OCI/enterprise configuration.

Cloud migration execution requires the actual wallet, target service name, ADMIN/application credentials, ORDS choice, and approved network policy. Those are the only blocking user-supplied inputs. Once supplied, capture a separate cloud migration report and rerun the contract, authorization, story, security, and performance suites against the cloud URLs before calling the managed target complete.

## Secret Handling

- Never commit wallet ZIPs, extracted wallet files, `.local/secrets/atp-cloud.env`, passwords, client secrets, or tokens.
- Do not disable TLS verification.
- Use a dedicated non-production database for migration and destructive test execution.
- Rotate any credential that appears in terminal history, chat, screenshots, or Git.
