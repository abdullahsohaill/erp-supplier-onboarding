# AI-DLC Execution Plan

## Detailed Analysis Summary

- **Project Type**: Greenfield prototype.
- **Primary Change**: New supplier onboarding and integration application.
- **User-facing Changes**: Yes. The three prototype personas are requester, reviewer, and support/admin user.
- **Structural Changes**: Yes. New ATP data model, ORDS API layer, OIC integrations, and Fusion API mapping.
- **Data Model Changes**: Yes. New staging and tracking schema in ATP.
- **API Changes**: Yes. New ORDS APIs and OIC integration APIs.
- **NFR Impact**: High. Security, auditability, data masking, explainability, observability, retry, and resiliency matter.
- **Risk Level**: High for production, Medium for prototype.
- **Testing Complexity**: Moderate to complex because duplicate/risk scoring, integration failures, and security boundaries must be tested.

## Recommended AI-DLC Stages

| Stage | Decision | Reason |
|---|---|---|
| Workspace Detection | Executed | Required, greenfield workspace. |
| Reverse Engineering | Skipped | No existing codebase. |
| Requirements Analysis | Execute | Complex customer transcript with multiple stakeholders. |
| User Stories | Execute | Multiple personas and workflows. |
| Workflow Planning | Execute | Required. |
| Application Design | Execute | New components, APIs, integrations, and data model. |
| Units Generation | Execute | Multiple logical units can be built/tested independently. |
| Functional Design | Execute per unit | Business rules need detail. |
| NFR Requirements | Execute per unit | Security, masking, observability, AI safety, resiliency. |
| NFR Design | Execute per unit | Needed for production-realistic prototype. |
| Infrastructure Design | Execute per unit | Oracle stack and integration environment decisions. |
| Code Generation | Later | Only after proposal/design approval. |
| Build and Test | Later | Only after code generation planning. |

## Workflow Visualization

```mermaid
flowchart TD
    Start(["Customer ERP Requirements"])
    WD["Workspace Detection<br/><b>DONE</b>"]
    RE["Reverse Engineering<br/><b>SKIP</b>"]
    RA["Requirements Analysis<br/><b>DRAFT</b>"]
    US["User Stories<br/><b>DRAFT</b>"]
    WP["Workflow Planning<br/><b>DRAFT</b>"]
    AD["Application Design<br/><b>DRAFT</b>"]
    UG["Units Generation<br/><b>DRAFT</b>"]
    FD["Functional Design<br/><b>NEXT</b>"]
    NFRA["NFR Requirements<br/><b>NEXT</b>"]
    NFRD["NFR Design<br/><b>NEXT</b>"]
    ID["Infrastructure Design<br/><b>NEXT</b>"]
    CG["Code Generation<br/><b>LATER</b>"]
    BT["Build and Test<br/><b>LATER</b>"]
    End(["Proposal Ready"])

    Start --> WD
    WD --> RE
    WD --> RA
    RE --> RA
    RA --> US
    US --> WP
    WP --> AD
    AD --> UG
    UG --> FD
    FD --> NFRA
    NFRA --> NFRD
    NFRD --> ID
    ID --> CG
    CG --> BT
    BT --> End
```

Text alternative: requirements move from workspace detection to requirements, stories, workflow planning, application design, units, then construction-stage detailed designs before any code generation.

## Next Recommended Action

Review the answered assumptions in `aidlc-docs/inception/requirements/requirement-verification-questions.md`, finalize any changes to the proposal pack, then proceed to wireframes when explicitly requested. Construction-stage functional/NFR/infrastructure design should start only after the proposal/design baseline is accepted.
