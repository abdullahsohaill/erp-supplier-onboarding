from __future__ import annotations

import ssl
from pathlib import Path
from urllib.parse import urlparse

import requests
from requests.adapters import HTTPAdapter


class _LocalCertificateAdapter(HTTPAdapter):
    def __init__(self, certificate: Path) -> None:
        context = ssl.create_default_context(cafile=str(certificate))
        if not hasattr(ssl, "VERIFY_X509_PARTIAL_CHAIN"):
            raise RuntimeError("This Python/OpenSSL runtime cannot validate the local ORDS leaf certificate")
        context.verify_flags |= ssl.VERIFY_X509_PARTIAL_CHAIN
        self._context = context
        super().__init__()

    def init_poolmanager(self, *args, **kwargs):  # type: ignore[no-untyped-def]
        kwargs["ssl_context"] = self._context
        return super().init_poolmanager(*args, **kwargs)


def local_https_session(base_url: str, certificate: Path) -> requests.Session:
    parsed = urlparse(base_url)
    if parsed.scheme != "https" or parsed.hostname not in {"localhost", "127.0.0.1", "::1"}:
        raise RuntimeError("The local ORDS certificate adapter is restricted to an HTTPS loopback URL")
    if not certificate.is_file():
        raise FileNotFoundError(f"Local ORDS certificate not found: {certificate}")
    session = requests.Session()
    session.mount("https://", _LocalCertificateAdapter(certificate))
    return session
