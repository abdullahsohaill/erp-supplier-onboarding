# Local Performance Report

## Environment

- Apple Silicon ARM64.
- Docker allocation: 10 CPUs and 10,419,826,688 bytes memory.
- Oracle image: `ghcr.io/oracle/adb-free:26.2.4.2-26ai`.
- Nginx image: `nginx:1.30.4-alpine3.24`.
- Dataset before measurement: 9 supplier requests and 2 existing supplier references.
- Warm-up: two calls per read path and two seed creates.

## Sequential Results

| Operation | Samples | p50 ms | p95 ms | Max ms | Target p95 ms | Result |
|---|---:|---:|---:|---:|---:|---|
| List | 20 | 60.07 | 141.11 | 233.22 | 2,000 | PASS |
| Detail | 20 | 44.18 | 95.78 | 156.40 | 2,000 | PASS |
| Requester dashboard | 20 | 53.49 | 134.90 | 230.41 | 3,000 | PASS |
| Create | 10 | 58.60 | 162.53 | 162.53 | 2,000 | PASS |
| Update | 10 | 70.20 | 322.20 | 322.20 | 2,000 | PASS |
| Submit | 10 | 100.93 | 415.00 | 415.00 | 5,000 | PASS |

## Concurrent Smoke

Ten workers ran mixed owner-scoped list, detail, and dashboard reads for 300 seconds. They completed 570 requests with zero HTTP errors and a 0.0 percent error rate.

These measurements validate the local prototype only. They do not establish production capacity, SLA, sizing, or cloud-network performance.
