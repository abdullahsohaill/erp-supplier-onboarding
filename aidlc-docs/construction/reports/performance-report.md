# Local Performance Report

## Environment

- Apple Silicon ARM64.
- Docker allocation: 10 CPUs and 10,419,826,688 bytes memory.
- Oracle image: `ghcr.io/oracle/adb-free:26.2.4.2-26ai`.
- Nginx image: `nginx:1.30.4-alpine3.24`.
- Dataset before measurement: 82 supplier requests and 3 existing supplier references.
- Warm-up: two calls per read path and two seed creates.

## Sequential Results

| Operation | Samples | p50 ms | p95 ms | Max ms | Target p95 ms | Result |
|---|---:|---:|---:|---:|---:|---|
| List | 20 | 90.60 | 490.15 | 626.81 | 2,000 | PASS |
| Detail | 20 | 59.38 | 361.15 | 380.45 | 2,000 | PASS |
| Requester dashboard | 20 | 56.48 | 177.29 | 391.48 | 3,000 | PASS |
| Create | 10 | 72.15 | 710.37 | 710.37 | 2,000 | PASS |
| Update | 10 | 65.34 | 1,555.90 | 1,555.90 | 2,000 | PASS |
| Submit | 10 | 64.07 | 2,527.11 | 2,527.11 | 5,000 | PASS |

## Concurrent Smoke

Ten workers ran mixed owner-scoped list, detail, and dashboard reads for 300 seconds. They completed 574 requests with zero HTTP errors and a 0.0 percent error rate.

These measurements validate the local prototype only. They do not establish production capacity, SLA, sizing, or cloud-network performance.
