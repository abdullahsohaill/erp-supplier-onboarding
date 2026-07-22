# UOW-002 Tech Stack Decisions

| Area | Decision | Rationale |
|---|---|---|
| Execution | Oracle PL/SQL packages in finalized ATP schema | Keeps governed analysis transactional and close to staged/reference data. |
| API | Bundled ORDS 25.4 plus shared OAuth2 roles/privileges | Matches the pinned Oracle image's runtime and reuses the approved versioned service boundary. |
| Local AI | Deterministic PL/SQL mock output | Reproducible offline tests with no external data disclosure. |
| Future AI | Adapter behind the same curated-facts/output contract | Provider/model remains customer-approved production choice. |
| Contracts | Shared OpenAPI 3.0.3 document | Exact 42-operation parity across units. |
| Testing | pytest, Hypothesis, direct SQL/package and HTTPS tests | Covers examples, properties, persistence, roles, and API schemas. |

No queue, cache, search engine, vector database, or extra application table is required for phase one.
