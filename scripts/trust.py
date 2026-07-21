from __future__ import annotations

import re

from runtime import REPORTS, TRUST, RuntimeFailure, command, ensure_local_dirs, write_json


def main() -> int:
    ensure_local_dirs()
    wallet = TRUST / "tls_wallet"
    if wallet.exists():
        command(["rm", "-rf", str(wallet)])
    command(["docker", "cp", "erp-oracle-adb:/u01/app/oracle/wallets/tls_wallet", str(wallet)])

    probe = command(
        [
            "docker",
            "exec",
            "erp-oracle-adb",
            "bash",
            "-lc",
            "printf '' | openssl s_client -connect 127.0.0.1:8443 "
            "-servername oracle-adb -showcerts 2>/dev/null",
        ]
    ).stdout
    certificates = re.findall(
        r"-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----", probe, re.DOTALL
    )
    if not certificates:
        raise RuntimeFailure("ORDS did not present a certificate")
    ords_ca = TRUST / "ords-ca.crt"
    ords_ca.write_text(certificates[-1] + "\n", encoding="ascii")
    ords_ca.chmod(0o600)

    command(["openssl", "verify", "-CAfile", str(ords_ca), str(ords_ca)])
    cert_text = command(
        [
            "openssl",
            "x509",
            "-in",
            str(ords_ca),
            "-noout",
            "-subject",
            "-issuer",
            "-dates",
            "-fingerprint",
            "-sha256",
        ]
    ).stdout
    write_json(REPORTS / "ords-certificate.json", {"certificate": cert_text.splitlines()})
    print("Wallet and verified ORDS trust material extracted")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except RuntimeFailure as exc:
        print(f"Trust setup failed: {exc}")
        raise SystemExit(1) from exc
