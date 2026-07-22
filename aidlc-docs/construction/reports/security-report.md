# Security Report

## Status

Application-controlled security gates pass. Overall release security remains blocked pending Oracle vendor-image remediation or explicit informed acceptance for local prototype use.

## Passing Evidence

| Gate | Result |
|---|---|
| Python dependencies | 76 scanned; zero vulnerabilities |
| Git history secret scan | Zero findings after one exact documented false-positive allowlist |
| Working-tree secret scan | Zero findings |
| Filesystem vulnerability/secret/misconfiguration scan | Zero High/Critical findings |
| Nginx image | Zero High/Critical findings after upgrade to 1.30.4 Alpine 3.24 |
| CycloneDX SBOM | Generated with 78 components |
| Runtime security tests | OAuth, roles, ownership, inputs, CORS, masking, redaction, throttling, hardening |

## Blocking Vendor Finding

Trivy found 184 High and 3 Critical fixed-version findings in the latest official `ghcr.io/oracle/adb-free:26.2.4.2-26ai` image. Oracle's official repository listed this as the latest 26ai release at verification time. The three Critical records apply to packaged kernel headers; other findings include OS, bundled ORDS/Jetty/Jackson, database tooling, and Python packages.

The stack mitigates exposure through loopback ingress, private ORDS networking, verified TLS, OAuth2, role/package authorization, one-MiB input limits, throttling, route allowlisting, and disabled REST SQL/Database API/Database Actions/Mongo. These controls do not patch the image.

## Decision Required

Use a newer clean official Oracle image when available. If the team needs to retain this image strictly for a local, non-production demo, record explicit informed acceptance with an expiry/review date. Do not carry that exception into production.
