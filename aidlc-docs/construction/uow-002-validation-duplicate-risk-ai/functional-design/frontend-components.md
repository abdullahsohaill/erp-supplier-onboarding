# UOW-002 Frontend Components

The approved static wireframe remains the UI source; no Visual Builder source project exists in Construction.

| Component | User | State/Input | API |
|---|---|---|---|
| Validation evidence list | Reviewer, Support/Admin | Blocking/warning filters, corrective guidance | `GET .../validation-results` |
| Duplicate evidence panel | Reviewer, Support/Admin | Candidate, level, score, matched fields | `GET .../duplicate-matches` |
| Risk explanation panel | Reviewer, Support/Admin | Current score/level/reasons/version | `GET .../risk-assessment` |
| AI advisory panel | Reviewer, Support/Admin | Summary history and regenerate state | `GET .../ai-summaries`, `POST .../ai-summary` |
| Requester validation result | Requester owner | Safe blocker/warning guidance only | submit 422 and validation-results |

Interactive implementation must use stable test IDs, keep automatic scoring weights out of Reviewer decision controls, and never render full bank values.
