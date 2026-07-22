from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TEMPLATE = ROOT / "config/atp-cloud.env.example"


def test_cloud_profile_contains_only_placeholders() -> None:
    source = TEMPLATE.read_text(encoding="utf-8")
    required = {
        "ATP_CLOUD_USER",
        "ATP_CLOUD_PASSWORD",
        "ATP_CLOUD_DSN",
        "ATP_CLOUD_WALLET_DIR",
        "ATP_CLOUD_WALLET_PASSWORD",
        "ATP_CLOUD_ORDS_URL",
    }
    present = {
        line.partition("=")[0]
        for line in source.splitlines()
        if line and not line.startswith("#")
    }
    assert present == required
    assert "replace-with" in source
    assert "BEGIN PRIVATE KEY" not in source


def test_real_cloud_profile_and_wallet_are_git_ignored() -> None:
    gitignore = (ROOT / ".gitignore").read_text(encoding="utf-8")
    assert ".local/" in gitignore
    assert "*.sso" in gitignore
    assert "*.pem" in gitignore
