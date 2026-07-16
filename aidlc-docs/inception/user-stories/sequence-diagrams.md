# User Story Sequence Diagrams

## Purpose and Scope

This document provides a sequence diagram for every user story in `stories.md`. The diagrams are interaction views of the approved story behavior; the user stories, acceptance criteria, requirements, and technical design remain the source of truth.

## Shared Architectural Guardrails

- Oracle Visual Builder communicates with Oracle ATP only through versioned ORDS APIs.
- Oracle ATP stores request workflow state, rule outputs, audit history, reference data, and integration logs.
- OIC owns Fusion ERP or mock Fusion integration; Visual Builder never creates suppliers in Fusion directly.
- AI explains deterministic validation, duplicate, and risk facts but never approves, rejects, marks duplicate, routes, or creates a supplier.
- Bank data used in matching is masked or tokenized; full bank account values are not sent to AI or exposed in logs.

## Sequence Diagrams

### US-001: Create and submit supplier request

```mermaid
sequenceDiagram
    participant Requester
    participant VB as Oracle Visual Builder
    participant ORDS as ORDS API
    participant ATP as Oracle ATP
    participant Rules as Validation Duplicate and Risk Services
    Requester->>VB: Enter supplier request details
    Requester->>VB: Save draft
    VB->>ORDS: POST or PATCH request
    ORDS->>ATP: Persist draft and audit metadata
    ATP-->>ORDS: Return request number and Draft status
    ORDS-->>VB: Return saved request
    VB-->>Requester: Show draft confirmation
    Requester->>VB: Submit request
    VB->>ORDS: POST request submit
    ORDS->>ATP: Set status to Submitted
    ORDS->>Rules: Run validation duplicate check and risk score
    Rules->>ATP: Store findings and assessments
    alt Blocking validation exists
        ATP->>ATP: Set status to Validation Failed
        ORDS-->>VB: Return actionable validation findings
    else Request is review-ready
        ATP->>ATP: Set status to Under Review
        ORDS-->>VB: Return submission confirmation
    end
    VB-->>Requester: Show current status
```

Text alternative: The requester saves a guided draft through Visual Builder and ORDS into ATP. On submission, deterministic validation, duplicate, and risk checks run; ATP records either Validation Failed with findings or Under Review.

### US-002: Correct returned request

```mermaid
sequenceDiagram
    participant Requester
    participant VB as Oracle Visual Builder
    participant ORDS as ORDS API
    participant ATP as Oracle ATP
    participant Rules as Validation Duplicate and Risk Services
    Requester->>VB: Open Correction Requested item
    VB->>ORDS: GET request detail
    ORDS->>ATP: Read request reviewer comment and history
    ATP-->>ORDS: Return editable request and guidance
    ORDS-->>VB: Return correction details
    VB-->>Requester: Show comment and editable fields
    Requester->>VB: Update fields and resubmit
    VB->>ORDS: PATCH request
    ORDS->>ATP: Save changes and changed-field audit
    VB->>ORDS: POST request submit
    ORDS->>Rules: Re-run validation
    opt Material duplicate or risk fields changed
        ORDS->>Rules: Re-run duplicate and risk checks
    end
    Rules->>ATP: Store current findings and supersede prior results
    ATP->>ATP: Append resubmission status history
    ORDS-->>VB: Return new status and findings
    VB-->>Requester: Show resubmission outcome
```

Text alternative: A requester opens a returned request, sees the reviewer comment, edits the existing record, and resubmits it. The system reruns validation and, for material changes, duplicate and risk checks, while preserving status history.

### US-003: Track request status and outcome

```mermaid
sequenceDiagram
    participant Requester
    participant VB as Oracle Visual Builder
    participant ORDS as ORDS API
    participant ATP as Oracle ATP
    Requester->>VB: Open request status
    VB->>ORDS: GET request detail
    ORDS->>ATP: Read current status and timeline
    ATP-->>ORDS: Return status history and role-safe outcome
    alt Correction or rejection outcome
        ATP-->>ORDS: Include reviewer guidance
    else Marked Duplicate outcome
        ATP-->>ORDS: Include existing supplier reference
    else Created in Fusion outcome
        ATP-->>ORDS: Include Fusion supplier number
    else Integration Failed outcome
        ATP-->>ORDS: Include business-safe failure status
    end
    ORDS-->>VB: Return request status response
    VB-->>Requester: Display status timeline and next action
```

Text alternative: The requester retrieves a role-safe status view through ORDS. ATP supplies the timeline plus the relevant outcome details, such as reviewer guidance, an existing supplier reference, a Fusion supplier number, or a business-safe failure message.

### US-004: Review validation and duplicate evidence

```mermaid
sequenceDiagram
    participant Reviewer
    participant VB as Oracle Visual Builder
    participant ORDS as ORDS API
    participant ATP as Oracle ATP
    participant Rules as Validation and Duplicate Services
    Reviewer->>VB: Open request review
    VB->>ORDS: GET request detail and validation results
    ORDS->>ATP: Read request and current validation findings
    VB->>ORDS: GET duplicate matches
    ORDS->>ATP: Read persisted duplicate candidates
    opt Formal checks are stale or missing
        ORDS->>Rules: Run validation and persisted duplicate check
        Rules->>ATP: Store refreshed findings and candidates
    end
    ATP-->>ORDS: Return blocking warnings and match evidence
    ORDS-->>VB: Return combined review evidence
    VB-->>Reviewer: Highlight critical tax or bank token matches
    VB-->>Reviewer: Show candidate score level and matched fields
```

Text alternative: The reviewer opens a combined evidence view. ORDS reads or refreshes validation and formal duplicate results in ATP, then Visual Builder highlights blocking findings, candidate details, scores, matched fields, and critical tax or bank-token matches.

### US-005: Review risk score and reasons

```mermaid
sequenceDiagram
    participant Reviewer
    participant VB as Oracle Visual Builder
    participant ORDS as ORDS API
    participant ATP as Oracle ATP
    participant Risk as Risk Assessment Service
    Reviewer->>VB: Open risk assessment
    VB->>ORDS: GET risk assessment
    ORDS->>ATP: Read current score level reasons and version
    ATP-->>ORDS: Return explainable assessment
    ORDS-->>VB: Return business-language risk details
    VB-->>Reviewer: Show score level and reasons
    opt Reviewer recalculates after correction
        Reviewer->>VB: Recalculate risk
        VB->>ORDS: POST risk score
        ORDS->>Risk: Calculate from current facts and reference rules
        Risk->>ATP: Persist new assessment and version
        ATP-->>ORDS: Return refreshed assessment
        ORDS-->>VB: Return refreshed score and reasons
        VB-->>Reviewer: Show recalculated risk
    end
```

Text alternative: The reviewer views the current explainable risk result. A recalculation reads current validation, duplicate, country, bank, address, justification, spend, document, and mapping facts, applies ATP-configured rules, and stores a versioned assessment.

### US-006: Use AI explanation safely

```mermaid
sequenceDiagram
    participant Reviewer
    participant VB as Oracle Visual Builder
    participant ORDS as ORDS API
    participant ATP as Oracle ATP
    participant AI as AI Explanation Service
    Reviewer->>VB: Request AI explanation
    VB->>ORDS: POST AI summary
    ORDS->>ATP: Read deterministic validation duplicate and risk facts
    ATP-->>ORDS: Return curated facts and masked bank indicators
    Note over ORDS,AI: Full bank account values are excluded
    ORDS->>AI: Generate schema-constrained explanation
    AI-->>ORDS: Return summary reasons missing data and actions
    ORDS->>ORDS: Validate approved output schema
    ORDS->>ATP: Store output timestamp version and provider metadata
    ATP-->>ORDS: Confirm saved summary
    ORDS-->>VB: Return advisory explanation
    VB-->>Reviewer: Show AI recommendation-only guardrail
    Note over Reviewer,VB: Reviewer retains every business decision
```

Text alternative: ORDS assembles curated deterministic facts with masked bank indicators, sends them to the AI explanation service, validates the structured response, and stores its metadata. The reviewer sees advisory guidance only and remains responsible for the decision.

### US-007: Make review decision

```mermaid
sequenceDiagram
    participant Reviewer
    participant VB as Oracle Visual Builder
    participant ORDS as ORDS API
    participant ATP as Oracle ATP
    Reviewer->>VB: Choose review action
    VB->>ORDS: POST approve reject correction or mark duplicate
    ORDS->>ORDS: Authorize Reviewer role and validate action payload
    ORDS->>ATP: Read status blocking findings and duplicate evidence
    alt Approve with unresolved blocking validation
        ORDS-->>VB: Reject action with conflict response
        VB-->>Reviewer: Show blocking findings
    else Approve with all controls satisfied
        ORDS->>ATP: Set status to Approved
        ATP->>ATP: Append decision history
        ORDS-->>VB: Confirm approval
    else Reject or request correction
        ORDS->>ORDS: Require reviewer comment
        ORDS->>ATP: Store comment and target status
        ATP->>ATP: Append decision history
        ORDS-->>VB: Confirm decision
    else Mark duplicate
        ORDS->>ORDS: Require comment and existing supplier reference
        ORDS->>ATP: Set status to Marked Duplicate
        ATP->>ATP: Append decision history
        ORDS-->>VB: Confirm duplicate outcome
    end
    VB-->>Reviewer: Display recorded outcome
```

Text alternative: ORDS authorizes and validates the reviewer action. Approval is blocked by unresolved validations; rejection and correction require comments; duplicate marking requires both a comment and an existing supplier reference. ATP records every valid decision in status history.

### US-008: See decision guidance

```mermaid
sequenceDiagram
    participant Requester
    participant VB as Oracle Visual Builder
    participant ORDS as ORDS API
    participant ATP as Oracle ATP
    Requester->>VB: Open decided request
    VB->>ORDS: GET request detail
    ORDS->>ATP: Read outcome comments and allowed actions
    alt Correction Requested
        ATP-->>ORDS: Return reviewer comment and editable flag
        ORDS-->>VB: Enable correction and resubmission
    else Rejected
        ATP-->>ORDS: Return rejection comment and closed flag
        ORDS-->>VB: Disable Fusion submission
    else Marked Duplicate
        ATP-->>ORDS: Return comment and existing supplier reference
        ORDS-->>VB: Disable Fusion submission
    end
    VB-->>Requester: Show guidance and permitted next action
```

Text alternative: The requester receives guidance appropriate to the recorded decision. Correction Requested remains editable and resubmittable, while Rejected and Marked Duplicate are closed to Fusion submission; duplicate outcomes include the supplier reference to use.

### US-009: Use business dashboards

```mermaid
sequenceDiagram
    participant User as Requester or Reviewer
    participant VB as Oracle Visual Builder
    participant ORDS as ORDS API
    participant ATP as Oracle ATP
    User->>VB: Open dashboard with filters
    VB->>ORDS: GET role-specific dashboard summary
    ORDS->>ORDS: Resolve authenticated role and data scope
    alt Requester role
        ORDS->>ATP: Count and list only owned requests by status
    else Reviewer role
        ORDS->>ATP: Count and list review queue by selected filters
    end
    ATP-->>ORDS: Return counts and filtered request rows
    ORDS->>ORDS: Verify counts use the same filter criteria
    ORDS-->>VB: Return summary and result set
    VB-->>User: Display role-appropriate dashboard
    User->>VB: Change filters
    VB->>ORDS: GET scoped request list with filters
    ORDS->>ATP: Execute filtered query
    ATP-->>ORDS: Return matching rows and count
    ORDS-->>VB: Return refreshed dashboard
```

Text alternative: ORDS applies the authenticated role and identical filters to dashboard counts and result rows. Requesters see only their requests, while reviewers see the review queue with business filters such as BU, country, status, risk, duplicate risk, spend, and category.

### US-010: Troubleshoot integrations

```mermaid
sequenceDiagram
    participant Admin as Support Admin User
    participant VB as Oracle Visual Builder
    participant ORDS as ORDS API
    participant ATP as Oracle ATP
    participant OIC as Oracle Integration Cloud
    Admin->>VB: Open support dashboard
    VB->>ORDS: GET support summary and integration logs
    ORDS->>ORDS: Authorize Support Admin role
    ORDS->>ATP: Query failed integrations and retry metadata
    ATP-->>ORDS: Return OIC ID errors retry count and eligibility
    ORDS-->>VB: Return technical support view
    VB-->>Admin: Show diagnostic details and retry controls
    Admin->>VB: Retry selected failure
    VB->>ORDS: POST request retry
    ORDS->>ATP: Verify status eligibility and correlation state
    alt Retry is eligible
        ORDS->>ATP: Increment retry count and log attempt
        ORDS->>OIC: Trigger retry with request correlation ID
        OIC-->>ORDS: Accept retry trigger
        ORDS-->>VB: Confirm retry started
    else Rejected Marked Duplicate or ineligible
        ORDS-->>VB: Reject retry with reason
    end
    VB-->>Admin: Display current retry outcome
```

Text alternative: A support/admin user retrieves protected integration diagnostics and retry metadata. ORDS permits retries only after status, eligibility, and correlation checks, records the attempt, and triggers OIC; rejected, duplicate, or otherwise ineligible requests remain blocked.

### US-011: Submit approved supplier to Fusion

```mermaid
sequenceDiagram
    participant Trigger as System Trigger
    participant OIC as Oracle Integration Cloud
    participant ORDS as ORDS API
    participant ATP as Oracle ATP
    participant Fusion as Fusion ERP or Mock Fusion
    Trigger->>OIC: Start approved supplier submission
    OIC->>ORDS: GET approved request and related data
    ORDS->>ATP: Read request site contact and rule state
    ATP-->>ORDS: Return staged data and Approved status
    ORDS-->>OIC: Return approved submission payload facts
    OIC->>OIC: Verify status and transform Fusion payload
    OIC->>Fusion: POST supplier header
    alt Supplier creation succeeds
        Fusion-->>OIC: Return supplier ID and number
        OIC->>Fusion: POST supplier site
        Fusion-->>OIC: Return site result
        OIC->>ORDS: Update Created in Fusion with response reference
        ORDS->>ATP: Store supplier number status and integration log
        ATP-->>ORDS: Confirm committed result
        ORDS-->>OIC: Confirm success update
    else Fusion or mock call fails
        Fusion-->>OIC: Return business or technical error
        OIC->>ORDS: Update Integration Failed with safe details
        ORDS->>ATP: Store failure retry eligibility and OIC instance ID
        ATP-->>ORDS: Confirm failure state
        ORDS-->>OIC: Confirm failure update
    end
```

Text alternative: A system trigger starts OIC, which retrieves only an approved staged request through ORDS, transforms it, and calls Fusion or the mock. Success stores the supplier number and Created in Fusion status; failure stores Integration Failed details and retry metadata in ATP.

### US-012: Load supplier reference data

```mermaid
sequenceDiagram
    participant Trigger as Scheduler or Admin Trigger
    participant OIC as Oracle Integration Cloud
    participant Fusion as Fusion ERP or Mock Data Source
    participant ORDS as ORDS API
    participant ATP as Oracle ATP
    Trigger->>OIC: Start supplier reference load
    OIC->>Fusion: GET suppliers and relevant sites
    alt Source query succeeds
        Fusion-->>OIC: Return supplier master records
        loop Each supplier record
            OIC->>OIC: Transform and normalize duplicate fields
            OIC->>ORDS: Upsert supplier and site reference
            ORDS->>ATP: Upsert reference rows
            ATP-->>ORDS: Confirm upsert
            ORDS-->>OIC: Confirm record processed
        end
        OIC->>ORDS: Write successful sync summary
        ORDS->>ATP: Store integration log
    else Source or load fails
        Fusion-->>OIC: Return source error or timeout
        OIC->>ORDS: Write failed sync summary
        ORDS->>ATP: Store error and diagnostic reference
    end
```

Text alternative: A scheduled or administrative OIC flow reads suppliers and sites from Fusion or mock data, normalizes duplicate-relevant fields, upserts ATP reference rows through ORDS, and records a success or failure summary for support visibility.

### US-013: Maintain reference and sensitive-data controls

```mermaid
sequenceDiagram
    participant Admin as Support Admin User
    participant VB as Oracle Visual Builder
    participant ORDS as ORDS API
    participant ATP as Oracle ATP
    participant Duplicate as Duplicate Detection Service
    participant AI as AI Explanation Service
    Admin->>VB: Open reference configuration
    VB->>ORDS: GET risk duplicate country and BU rules
    ORDS->>ORDS: Authorize Support Admin role
    ORDS->>ATP: Read active reference configuration
    ATP-->>ORDS: Return governed rule values
    ORDS-->>VB: Return configuration
    Admin->>VB: Update an allowed reference value
    VB->>ORDS: PUT reference rule
    ORDS->>ATP: Validate persist and audit change
    ATP-->>ORDS: Confirm versioned update
    ORDS-->>VB: Return saved configuration
    Note over ORDS,ATP: Bank display remains masked and logs remain redacted
    Duplicate->>ATP: Compare bank token or hash only
    ATP-->>Duplicate: Return token-match indicator
    ORDS->>AI: Send curated facts without full bank value
    AI-->>ORDS: Return advisory explanation
```

Text alternative: A support/admin user maintains authorized reference rules through ORDS with audit history. Across processing, ATP exposes only masked bank display values and token/hash indicators, duplicate matching uses those indicators, logs remain redacted, and AI receives no full bank value.

### US-014: Run realistic demo scenarios

```mermaid
sequenceDiagram
    participant Team as Project Team
    participant Demo as Demo Scenario Runner
    participant ORDS as ORDS API
    participant ATP as Oracle ATP
    participant Rules as Validation Duplicate and Risk Services
    participant OIC as Oracle Integration Cloud
    participant Fusion as Fusion ERP or Mock Fusion
    Team->>Demo: Start representative demo suite
    Demo->>ORDS: Seed approved customer edge-case data
    ORDS->>ATP: Store demo requests and reference data
    loop Each required scenario
        Demo->>ORDS: Submit scenario request
        ORDS->>Rules: Run validation duplicate and risk processing
        Rules->>ATP: Persist findings and expected risk outcome
        alt Duplicate-risk scenario
            ATP-->>ORDS: Return duplicate candidates and high risk
        else High-risk incomplete scenario
            ATP-->>ORDS: Return validation and risk findings
        else Clean supplier scenario
            ATP-->>ORDS: Return review-ready result
            Demo->>ORDS: Record reviewer approval
            ORDS->>OIC: Trigger approved submission
            OIC->>Fusion: Create supplier and site
            Fusion-->>OIC: Return supplier number
            OIC->>ORDS: Store successful creation result
        else Integration failure and retry scenario
            Demo->>ORDS: Record reviewer approval
            ORDS->>OIC: Trigger approved submission
            OIC->>Fusion: Attempt supplier creation
            Fusion-->>OIC: Return configured failure
            OIC->>ORDS: Store retry-eligible failure
            Demo->>ORDS: Trigger controlled retry
            ORDS->>OIC: Retry with correlation check
            OIC->>Fusion: Retry supplier creation
            Fusion-->>OIC: Return configured success
            OIC->>ORDS: Store successful retry result
        end
    end
    ORDS-->>Demo: Return scenario outcomes and audit references
    Demo-->>Team: Present expected non-happy-path evidence
```

Text alternative: The project team runs seeded scenarios for duplicate risk, high-risk incomplete data, clean supplier creation, and integration failure with controlled retry. Each scenario uses the same ORDS, ATP, deterministic rule, OIC, and Fusion/mock boundaries as the proposed solution and returns auditable outcomes.

## Coverage Summary

| Story | Sequence focus |
|---|---|
| US-001 | Draft creation, submission, validation, duplicate detection, and risk processing |
| US-002 | Correction, material-change detection, and resubmission |
| US-003 | Role-safe status timeline and outcome details |
| US-004 | Combined validation and duplicate evidence review |
| US-005 | Explainable risk retrieval and recalculation |
| US-006 | Curated AI explanation with decision and sensitive-data guardrails |
| US-007 | Controlled reviewer decision branches |
| US-008 | Requester guidance and permitted next actions |
| US-009 | Role-scoped dashboards, filters, counts, and results |
| US-010 | Protected diagnostics and controlled integration retry |
| US-011 | Approved supplier submission through OIC to Fusion or mock Fusion |
| US-012 | Fusion or mock supplier-reference synchronization into ATP |
| US-013 | Governed reference configuration and sensitive-data handling |
| US-014 | Representative happy-path and non-happy-path demo execution |

## Validation Notes

- All 14 story IDs and titles match `stories.md`.
- Each story has one Mermaid sequence diagram and one text alternative.
- Participant identifiers use alphanumeric names only.
- Mermaid control blocks are balanced and labels avoid unescaped quotation marks.
- The diagrams preserve the approved ORDS, ATP, OIC, Fusion, AI, role, and sensitive-data boundaries.
