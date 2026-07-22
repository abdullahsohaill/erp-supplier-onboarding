# Security Test Instructions

## Application and Supply Chain

```bash
./scripts/tools/install-gitleaks.sh
./scripts/tools/install-trivy.sh
.venv/bin/pip-audit -r requirements.txt --format json \
  --output .local/reports/pip-audit.json
.local/tools/gitleaks/gitleaks detect --source . --config .gitleaks.toml \
  --no-banner --redact --report-format json \
  --report-path .local/reports/gitleaks.json
.local/tools/gitleaks/gitleaks detect --source . --no-git --config .gitleaks.toml \
  --no-banner --redact --report-format json \
  --report-path .local/reports/gitleaks-working-tree.json
.local/tools/trivy/trivy fs --scanners vuln,secret,misconfig \
  --severity HIGH,CRITICAL --exit-code 1 --format json \
  --output .local/reports/trivy-filesystem-final.json .
.local/tools/trivy/trivy image --timeout 20m --scanners vuln \
  --severity HIGH,CRITICAL --format json \
  --output .local/reports/trivy-nginx-image.json nginx:1.30.4-alpine3.24
.local/tools/trivy/trivy image --timeout 20m --scanners vuln \
  --severity HIGH,CRITICAL --format json \
  --output .local/reports/trivy-oracle-image.json \
  ghcr.io/oracle/adb-free:26.2.4.2-26ai
.venv/bin/cyclonedx-py requirements requirements.txt --output-format JSON \
  --output-file .local/reports/sbom-cyclonedx.json
ERP_RUNTIME_TESTS=1 .venv/bin/pytest -q tests/security
```

## Blocking Policy

Secrets and unresolved application/dependency High or Critical vulnerabilities block completion. The current official Oracle image finding is documented separately and requires a patched vendor image or explicit informed acceptance for local prototype use. Network isolation is mitigation, not remediation.

Runtime security tests cover OAuth, roles, IDOR, input abuse, bank-value rejection, CORS, safe errors, rate limiting, ORDS optional-surface lockdown, and redacted logs.
