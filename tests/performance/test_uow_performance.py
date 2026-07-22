from __future__ import annotations

import statistics
import time

import pytest


@pytest.mark.runtime
@pytest.mark.performance
def test_local_read_p95_is_under_two_seconds(requester_a) -> None:
    durations = []
    for _ in range(20):
        started = time.perf_counter()
        response = requester_a.request("GET", "/requests?limit=25")
        durations.append(time.perf_counter() - started)
        assert response.status_code == 200
    p95 = statistics.quantiles(durations, n=20)[18]
    assert p95 < 2.0
