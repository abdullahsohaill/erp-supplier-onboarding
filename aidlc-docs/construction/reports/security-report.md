# Security Report

## Status

Application-controlled security gates pass. The local-container release remains blocked pending Oracle vendor-image remediation or explicit informed acceptance for local prototype use. Managed Oracle Always Free ATP is the recommended supported target for shared/cloud verification.

## Passing Evidence

| Gate | Result |
|---|---|
| Python dependencies | 76 scanned; zero vulnerabilities |
| Git history secret scan | Zero findings after one exact documented false-positive allowlist |
| Working-tree secret scan | Zero findings |
| Filesystem vulnerability/secret/misconfiguration scan | Zero High/Critical findings |
| Nginx image | Zero High/Critical findings after upgrade to 1.30.4 Alpine 3.24 |
| CycloneDX SBOM | Generated with 78 components |
| Runtime security tests | 133 OAuth, role-matrix, ownership, input, CORS, masking, redaction, throttling, and hardening tests |

## Blocking Vendor Finding

Trivy found 184 High and 3 Critical fixed-version findings in the latest official `ghcr.io/oracle/adb-free:26.2.4.2-26ai` image. Oracle's official repository listed this as the latest 26ai release at verification time. The three Critical records apply to packaged kernel headers; other findings include OS, bundled ORDS/Jetty/Jackson, database tooling, and Python packages.

The stack mitigates exposure through loopback ingress, private ORDS networking, verified TLS, OAuth2, exact per-handler role guards, package authorization, one-MiB input limits, throttling, route allowlisting, and disabled REST SQL/Database API/Database Actions/Mongo. These controls do not patch the image.

## Decision Required

Use managed Oracle Always Free ATP, where Oracle controls service image patching, for shared/cloud verification. A cloud security decision still requires the tenancy, region, network, wallet, identity, ORDS, logging, backup, and retention configuration to be tested. If the team retains the current image strictly for a local, non-production demo, record explicit informed acceptance with an expiry/review date. Do not carry that exception into production.
