# UOW-005 Business Rules

| ID | Rule |
|---|---|
| ADM-BR-001 | Only Support/Admin may read or mutate Admin Settings. |
| ADM-BR-002 | `VAL-001` through `VAL-009` remain stable catalog identities and toggle independently. |
| ADM-BR-003 | Scoring identity is `rule_type + rule_code + version`; updates cannot silently change identity. |
| ADM-BR-004 | Risk and duplicate active settings are independent. |
| ADM-BR-005 | High-risk country identity includes country and effective-from date; effective-to cannot precede it. |
| ADM-BR-006 | Business unit and supplier type use stable codes; active/tax/Fusion mapping changes are audited. |
| ADM-BR-007 | Policy updates derive actor/time on the server and reject unknown fields/invalid values. |
| ADM-BR-008 | Bank values remain masked/tokenized; payment setup and account creation remain out of scope. |
| ADM-BR-009 | Demo data is deterministic, synthetic, referentially valid, and covers every table. |
| ADM-BR-010 | Retry count equals embedded history length in every sample and runtime result. |
| ADM-BR-011 | Reports contain no generated secret, wallet, token, raw bank, or unsanitized technical payload. |
| ADM-BR-012 | Proposal/demo claims distinguish local mocks from real ATP Cloud/OIC/Fusion/AI production services. |
