#!/usr/bin/env python3
from __future__ import annotations

import os
import time

import requests

from local_tls import local_https_session
from run_migrations import ROOT, load_env


def main() -> int:
    load_env()
    base = os.environ.get("ORDS_BASE_URL", "https://localhost:8443/ords/erp/v1")
    cert = ROOT / os.environ.get("ORDS_CA_CERT", "certs/ords-self-signed.crt")
    session = local_https_session(base, cert)
    deadline = time.monotonic() + 900
    while time.monotonic() < deadline:
        try:
            response = session.get(f"{base}/reference/business-units", timeout=10)
            if response.status_code in {200, 401, 403}:
                print(f"ORDS is ready with HTTP {response.status_code}")
                return 0
        except requests.RequestException:
            pass
        time.sleep(10)
    print("ORDS did not become ready within 900 seconds")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
