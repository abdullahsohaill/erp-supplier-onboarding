from __future__ import annotations

import json
import os
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


@dataclass(frozen=True)
class RuntimeConfig:
    base_url: str
    token_url: str
    ca_file: Path
    clients: dict[str, dict[str, str]]


def runtime_enabled() -> bool:
    return os.environ.get("ERP_RUNTIME_TESTS") == "1"


def load_runtime_config() -> RuntimeConfig:
    clients_path = ROOT / ".local/secrets/oauth-clients.json"
    return RuntimeConfig(
        base_url=os.environ.get(
            "API_BASE_URL", "https://127.0.0.1:8443/ords/erp/supplier-onboarding/v1"
        ),
        token_url=os.environ.get("OAUTH_TOKEN_URL", "https://127.0.0.1:8443/ords/erp/oauth/token"),
        ca_file=ROOT / ".local/trust/local-ca.crt",
        clients=json.loads(clients_path.read_text(encoding="utf-8")),
    )
