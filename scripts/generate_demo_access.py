from __future__ import annotations

from runtime import LOCAL, ROOT, RuntimeFailure, load_env


def main() -> int:
    env = load_env()
    password = env.get("ERP_VERIFY_PASSWORD")
    if not password:
        raise RuntimeFailure("ERP_VERIFY password is missing; run ./scripts/start.sh first")
    demo_dir = LOCAL / "demo"
    demo_dir.mkdir(parents=True, exist_ok=True, mode=0o700)
    demo_dir.chmod(0o700)
    access_card = demo_dir / "local-access.md"
    content = f"""# Local ERP Demonstration Access

This file contains a generated local-only password. Do not share or commit it.

## Oracle Database Actions

- URL: https://localhost:8444/ords/sql-developer
- User: ERP_VERIFY
- Password: {password}
- Schema alias: erp-inspector
- Access: SELECT-only on the 18 ERP_APP tables and four views

## Oracle SQLcl

- Command: ./scripts/sqlcl.sh
- User: ERP_VERIFY
- Password: {password}
- Service: erpatp_tp
- Wallet: .local/trust/tls_wallet

## ORDS API and Postman

- API base: https://localhost:8443/ords/erp/supplier-onboarding/v1
- Collection: postman/erp-supplier-onboarding.postman_collection.json
- Environment: .local/postman/erp-local.postman_environment.json
- Local CA: .local/trust/local-ca.crt
"""
    access_card.write_text(content, encoding="utf-8")
    access_card.chmod(0o600)
    print(f"Generated owner-only local access card at {access_card.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except RuntimeFailure as exc:
        print(f"Access-card generation failed: {exc}")
        raise SystemExit(1) from exc
