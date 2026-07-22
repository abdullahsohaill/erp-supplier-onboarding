# Manual Steps

## Required Locally

1. Start Docker Desktop.
2. Allocate at least 4 CPUs and 8 GiB memory; 10 GiB is recommended.
3. Keep at least 25 GiB free for the Oracle image, first-boot PDB cache, and named volume.
4. Allow Docker networking/filesystem prompts if macOS requests them.
5. Optionally trust `.local/trust/local-ca.crt` in the macOS login keychain for Database Actions without a browser warning.
6. Import the generated collection/environment into Postman Desktop and add the same local CA certificate.

CLI tests already trust the generated CA explicitly and never disable TLS verification.

Postman Desktop, Oracle SQLcl, and Homebrew OpenJDK are already installed on this Mac. No OCI account, Oracle Playground, cloud wallet, or database creation step is required.

## Required Before Real Integrations

- Provide OIC endpoint, OAuth/connection, integration identifiers, and monitoring policy.
- Confirm Fusion Procurement supplier/site APIs, roles, business units, supplier types, tax policy, and error contracts.
- Provide enterprise SSO/identity mapping for Requester, Reviewer, and Support/Admin.
- Select and approve an AI provider, region, model, data policy, prompt/schema, and credentials.
- Confirm retention, backup, RTO/RPO, availability, alerting, log storage, and compliance requirements.
- Use a patched official local Oracle image for any future production-like exercise, or explicitly accept the current image only for a time-bounded local prototype.

Real supplier, bank, OIC, Fusion, SSO, database, or AI secrets must never be placed in this repository.
