from __future__ import annotations

import json
import secrets
import shutil
import string
import subprocess
from pathlib import Path

from runtime import SECRETS, TRUST, ensure_local_dirs


def strong_password(length: int = 24) -> str:
    alphabet = string.ascii_letters + string.digits + "_-#"
    while True:
        value = "A1a_" + "".join(secrets.choice(alphabet) for _ in range(length - 4))
        if all(ch in value for ch in ("A", "1", "a", "_")):
            return value


def write_private(path: Path, text: str) -> None:
    path.write_text(text, encoding="utf-8")
    path.chmod(0o600)


def run_openssl(args: list[str]) -> None:
    executable = shutil.which("openssl")
    if not executable:
        raise RuntimeError("OpenSSL is required")
    subprocess.run(  # noqa: S603 - executable and arguments are locally controlled.
        [executable, *args], check=True, capture_output=True, text=True
    )


def generate_tls() -> None:
    ca_key = SECRETS / "local-ca.key"
    ca_crt = TRUST / "local-ca.crt"
    edge_key = SECRETS / "edge.key"
    edge_csr = TRUST / "edge.csr"
    edge_crt = TRUST / "edge.crt"
    extension = TRUST / "edge.ext"
    if edge_crt.exists() and edge_key.exists() and ca_crt.exists():
        return
    run_openssl(["genrsa", "-out", str(ca_key), "3072"])
    run_openssl(
        [
            "req",
            "-x509",
            "-new",
            "-key",
            str(ca_key),
            "-sha256",
            "-days",
            "365",
            "-subj",
            "/CN=ERP Supplier Onboarding Local CA",
            "-out",
            str(ca_crt),
        ]
    )
    run_openssl(
        [
            "req",
            "-new",
            "-newkey",
            "rsa:3072",
            "-nodes",
            "-keyout",
            str(edge_key),
            "-subj",
            "/CN=localhost",
            "-out",
            str(edge_csr),
        ]
    )
    write_private(
        extension,
        "subjectAltName=DNS:localhost,IP:127.0.0.1\n"
        "keyUsage=digitalSignature,keyEncipherment\n"
        "extendedKeyUsage=serverAuth\n",
    )
    run_openssl(
        [
            "x509",
            "-req",
            "-in",
            str(edge_csr),
            "-CA",
            str(ca_crt),
            "-CAkey",
            str(ca_key),
            "-CAcreateserial",
            "-out",
            str(edge_crt),
            "-days",
            "365",
            "-sha256",
            "-extfile",
            str(extension),
        ]
    )
    for path in (ca_key, edge_key):
        path.chmod(0o600)
    ca_crt.chmod(0o600)
    edge_crt.chmod(0o600)


def main() -> int:
    ensure_local_dirs()
    adb_env = SECRETS / "adb.env"
    if not adb_env.exists():
        values = {
            "ADMIN_PASSWORD": strong_password(),
            "WALLET_PASSWORD": strong_password(),
            "ERP_APP_PASSWORD": strong_password(),
            "ERP_VERIFY_PASSWORD": strong_password(),
        }
        write_private(adb_env, "".join(f"{key}={value}\n" for key, value in values.items()))
    oauth_path = SECRETS / "oauth-clients.json"
    if not oauth_path.exists():
        clients = {
            name: {"client_secret": secrets.token_urlsafe(36), "role": role}
            for name, role in {
                "requester_a": "ERP_REQUESTER",
                "requester_b": "ERP_REQUESTER",
                "reviewer_test": "ERP_REVIEWER",
                "support_admin_test": "ERP_SUPPORT_ADMIN",
                "system_oic_test": "ERP_SYSTEM_OIC",
            }.items()
        }
        write_private(oauth_path, json.dumps(clients, indent=2, sort_keys=True) + "\n")
    generate_tls()
    print("Local secrets and TLS material are ready (values not displayed)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
