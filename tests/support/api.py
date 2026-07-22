from __future__ import annotations

from typing import Any

import requests

from tests.support.config import RuntimeConfig


class ApiClient:
    def __init__(self, config: RuntimeConfig, client_name: str):
        self.config = config
        self.client_name = client_name
        client = config.clients[client_name]
        response = requests.post(
            config.token_url,
            auth=(client_name, client["client_secret"]),
            data={"grant_type": "client_credentials"},
            headers={"Content-Type": "application/x-www-form-urlencoded"},
            verify=config.ca_file,
            timeout=15,
        )
        response.raise_for_status()
        self.token = response.json()["access_token"]

    def request(self, method: str, path: str, **kwargs: Any) -> requests.Response:
        headers = kwargs.pop("headers", {})
        headers["Authorization"] = f"Bearer {self.token}"
        headers.setdefault("Accept", "application/json")
        return requests.request(
            method,
            self.config.base_url.rstrip("/") + "/" + path.lstrip("/"),
            headers=headers,
            verify=self.config.ca_file,
            timeout=30,
            **kwargs,
        )
