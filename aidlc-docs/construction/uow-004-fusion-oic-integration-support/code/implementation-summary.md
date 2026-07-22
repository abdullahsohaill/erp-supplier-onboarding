# UOW-004 Implementation Summary

UOW-004 implements US-010 through US-012 and FR-011 through FR-013. `ERP_INTEGRATION_PKG` supplies deterministic local Fusion/OIC submission, idempotent results, request-scoped logs, bounded retry, support summaries, reference upsert, and callbacks.

Only Approved requests submit. Local success creates deterministic mock identifiers; configured failures expose safe business status and Admin diagnostics. Eligible retry appends typed evidence atomically; retry count equals history length. Rejected/Marked Duplicate cannot retry.

This is a local adapter substitute. Real OIC/Fusion connections, roles, mappings, SSO, credentials, and production policies remain deployment gates.
