# AI-DLC Audit Log

## Workflow Start
**Timestamp**: 2026-07-15T11:41:29Z
**User Input**: "i need to work on this integrations erp project attached as customer requirements pdf
now the thing is i want to use ai dlc workflows to produce a proper fully fledged proposal functional requirements and technical design (technical design includes stuff like konsi rest apis as well etc)
i want to use the aidlc worklfow which is this (attached): [awslabs/aidlc-workflows](https://github.com/awslabs/aidlc-workflows)
how do i integrate this workflow here in this project to get started and then we can get through this entire phase of proposal please do everything and explain to me the ai dlc stuff how to integrate how to use, then do it for me, then detail me on the customer equroements erp like thoriughly then lemme know what to do next"
**AI Response**: "Installed AI-DLC v1.0.1 rules using AGENTS.md and .aidlc-rule-details. Extracted the ERP PDF transcript and generated Inception draft artifacts."
**Context**: Workspace detection, AI-DLC setup, requirements extraction, proposal artifact generation.

---

## Workspace Detection
**Timestamp**: 2026-07-15T11:41:29Z
**User Input**: "Use customer requirements PDF and AI-DLC workflow to produce proposal, functional requirements, and technical design."
**AI Response**: "Workspace contains only customer requirement PDFs and no application source code. Classified as greenfield."
**Context**: AI-DLC Inception - Workspace Detection.

---

## Requirements Analysis
**Timestamp**: 2026-07-15T11:41:29Z
**User Input**: "Customer requirement source is Integration ERP.pdf and Integration ERP - highlighted.pdf."
**AI Response**: "Extracted 14 pages of text from both PDFs. Highlighted and non-highlighted versions have the same extractable transcript text."
**Context**: AI-DLC Inception - Requirements Analysis.

---

## User Story Correction
**Timestamp**: 2026-07-15T11:54:40Z
**User Input**: "there were supposed to be only 3 personas as there's only a single reviewer"
**AI Response**: "Collapsed reviewer variants into a single Reviewer persona and kept the system role model to three personas: Requester, Reviewer, and Support/Admin User. Updated stories, requirements, proposal, and technical design references."
**Context**: AI-DLC Inception - User Stories and Requirements correction.

---

## Requirements Clarification Audit
**Timestamp**: 2026-07-15T11:58:26Z
**User Input**: "also why didnt you ask me detailed questions around everything?

make sure you correctly understoof and followed all the customer requirements"
**AI Response**: "Re-audited the customer transcript against the generated artifacts, added a 54-item traceability matrix, patched under-represented requirements, and replaced the thin question file with 34 detailed AI-DLC requirement verification questions."
**Context**: AI-DLC Inception - Requirements Analysis correction and clarification gate.

---

## Requirements and Technical Design Hardening
**Timestamp**: 2026-07-15T12:03:12Z
**User Input**: "Using AI-DLC, be thorough and robust. also make sure the requirements.md and the technical design md are thorough and complete, like for isntance functional requirement suusally have acceptance criteria and stuff etc

also make sure you thoroughly generate everything until the point we have solid requirments and design ready and then once i command we will move on to a complete wireframe for the project (not now, a little later once ive reviewed the generated contents)"
**AI Response**: "Rewrote requirements.md into a detailed requirements specification with acceptance criteria and verification methods. Rewrote technical-design.md into a robust technical design covering architecture, roles, ATP data model, ORDS API contracts, validation, duplicate detection, risk scoring, AI design, OIC flows, Fusion candidate APIs, error handling, security, NFRs, and test strategy. Added requirements-design-review-checklist.md and kept wireframes deferred."
**Context**: AI-DLC Inception - Requirements and Application Design hardening.

---

## Requirements Table and Story Refinement
**Timestamp**: 2026-07-15T12:25:39Z
**User Input**: "can you improve on the requiremenents md file please and maybe convert into a tabular format all the functional requirmeents and acceptance criteria and make sure theyre a little detailed

reflect changes in other files asw


is the tchnical design md complete?

and maie sure personas and user stories are completel and thorough and nciely formatted as well

also lmk what we need to move forward with the wireframe"
**AI Response**: "Converted requirements.md into table-first functional and non-functional requirements with detailed acceptance criteria. Rewrote personas.md and stories.md into polished tabular product artifacts with 22 stories mapped to requirements. Added technical design completeness assessment and wireframe-readiness.md. Updated unit story map, review checklist, state, and audit."
**Context**: AI-DLC Inception - Requirements, personas, user stories, and wireframe readiness refinement.

---

## Requirements and Story Consolidation
**Timestamp**: 2026-07-15T12:45:00Z
**User Input**: "i think there should be lesser user stories. like max 15. and maybe lesser functional reequirements as well

answer the requirment verification questions md on your own using your own knowledge and the customer requirments document thoroughly"
**AI Response**: "Consolidated the requirements into 15 functional requirements and 8 non-functional requirements, reduced user stories to 14, answered all 34 requirement verification questions with rationale, and synchronized traceability, unit mapping, review checklist, state, technical design assumptions, and wireframe readiness."
**Context**: AI-DLC Inception - Consolidated requirements, user stories, and answered assumptions.

---

## Requirements Format Refinement
**Timestamp**: 2026-07-15T13:05:00Z
**User Input**: "i think the requirmenets md stuff might be way too tabular now, get a middle ground"
**AI Response**: "Reworked requirements.md from large functional/NFR tables into a mixed narrative and structured format with grouped requirement sections, stable FR/NFR IDs, acceptance criteria bullets, and verification notes. Updated the review checklist to match the new format."
**Context**: AI-DLC Inception - Requirements readability and customer-review formatting.

---

## User Story Traceability Cleanup
**Timestamp**: 2026-07-15T13:10:00Z
**User Input**: "shuoldnt veeyr user story be mapped to functional requirment? idk"
**AI Response**: "Confirmed every user story maps to at least one functional requirement, renamed the story mapping column to Related Functional Requirements, removed the NFR reference from the FR mapping column, and documented NFR coverage separately."
**Context**: AI-DLC Inception - User story to functional requirement traceability.

---

## Technical Design Schema Completion
**Timestamp**: 2026-07-15T13:25:00Z
**User Input**: "ive reviewed verification question md it looks perfect! and the requirements.md looks perfect as well except just remove this part from the end:\"**## Answered Assumptions**

The detailed question gate has been answered in `requirement-verification-questions.md` using conservative prototype assumptions from the customer transcript. These answers should be reviewed by the user/customer before final sign-off.\"

as for technical design, make sure it containsd architectural and data models (and database schema stuff)

once u let me know about completeness then we can move forward with wireframes / mockups"
**AI Response**: "Removed the trailing Answered Assumptions section from requirements.md, updated review-state wording to reflect accepted verification questions, and expanded technical-design.md with an ERD-style data relationship model, database schema constraints, indexes, relationships, and schema implementation notes."
**Context**: AI-DLC Inception - Requirements cleanup and technical design completeness for wireframe readiness.

---

## User Story Diagram Enhancement
**Timestamp**: 2026-07-15T13:40:00Z
**User Input**: "my friend gave me this:\"ye dekh le if this looks useful. is mein se 2 3 pictures utha ke stories.md file ke end pe daal dete\""
**AI Response**: "Reviewed the supplied use-case diagram document, selected three representative diagrams covering requester intake, reviewer duplicate/validation review, and Fusion submission, added them as user-story assets, and appended them to stories.md."
**Context**: AI-DLC Inception - User story visual companion diagrams.

---

## Wireframes and Mockups
**Timestamp**: 2026-07-15T14:05:00Z
**User Input**: "Using AI-DLC, create complete wireframes/mockups for the ERP supplier onboarding project based on the approved requirements, user stories, and technical design."
**AI Response**: "Created a wireframe specification with 10 traceable screens and a clickable static HTML mockup covering Requester, Reviewer, and Support/Admin flows. Updated AI-DLC state, wireframe review notes, and README to point to the new artifacts."
**Context**: AI-DLC Inception - Wireframes/mockups first pass.

---

## DBML Schema Refinement
**Timestamp**: 2026-07-15T14:30:00Z
**User Input**: "can you then correct the code and give me updated one that is perfect?"
**AI Response**: "Created an updated DBML schema artifact with Fusion result fields, retry history, rerun/current tracking, clearer duplicate candidate modeling, reference-data audit fields, and indexes. Updated technical-design.md and README to reference the corrected schema."
**Context**: AI-DLC Inception - ATP database schema refinement.

---

## User Story Sequence Diagram Amendment
**Timestamp**: 2026-07-16T05:21:49Z
**User Input**: "in the [stories.md](aidlc-docs/inception/user-stories/stories.md) there are 14 user stories. In the same @aidlc-docs/inception/user-stories/ folder I want you to create an md file which will have sequence diagrams for all these user stories"
**AI Response**: "Resumed the existing AI-DLC project and began a focused documentation amendment to create and validate one sequence diagram plus a text alternative for each of US-001 through US-014."
**Context**: AI-DLC Inception - User Stories documentation amendment.

---

## User Story Sequence Diagram Amendment Completion
**Timestamp**: 2026-07-16T05:25:10Z
**User Input**: "in the [stories.md](aidlc-docs/inception/user-stories/stories.md) there are 14 user stories. In the same @aidlc-docs/inception/user-stories/ folder I want you to create an md file which will have sequence diagrams for all these user stories"
**AI Response**: "Created sequence-diagrams.md with one Mermaid sequence diagram and one text alternative for each of US-001 through US-014. Verified exact story ID/title coverage, 14 Mermaid blocks, 14 text alternatives, balanced control blocks, declared participants, Markdown fences, architectural guardrails, and clean git diff whitespace. Added a completed execution checklist and recorded the supplemental artifact in aidlc-state.md without changing the active wireframe review gate."
**Context**: AI-DLC Inception - User Stories documentation amendment completed and validated.

---

## Database Schema Design Diagram Amendment
**Timestamp**: 2026-07-16T05:26:30Z
**User Input**: "in section 7 of [technical-design.md](aidlc-docs/inception/application-design/technical-design.md) file, there is a whole database schema. I want you to create this schema design in an .md file showing all tables and their connections. I have attached a simple image of a database schema design as well."
**AI Response**: "Resumed the existing AI-DLC project, inspected the reference image, and began a focused application-design amendment to create a complete ATP database ERD companion from Section 7 and the implementation-ready DBML source."
**Context**: AI-DLC Inception - Application Design database schema visualization amendment.

---

## Database Schema Design Diagram Amendment Completion
**Timestamp**: 2026-07-16T05:30:23Z
**User Input**: "in section 7 of [technical-design.md](aidlc-docs/inception/application-design/technical-design.md) file, there is a whole database schema. I want you to create this schema design in an .md file showing all tables and their connections. I have attached a simple image of a database schema design as well."
**AI Response**: "Created database-schema-design.md with a table-box Mermaid ERD containing all 20 ATP tables, 198 columns, primary/foreign/unique key markers, and all 20 DBML foreign-key relationships. Added a 20-row physical relationship catalog, nullable/required cardinalities, text alternatives, standalone configuration usage, schema rules, and source traceability. Linked the companion from technical-design.md Section 7, completed the execution checklist, and recorded the artifact in aidlc-state.md. Validation passed for entity balance, source table coverage, relationship coverage, composite keys, sensitive bank fields, Mermaid/Markdown structure, and diff whitespace."
**Context**: AI-DLC Inception - Application Design database schema visualization amendment completed and validated.

---

## Wireframe Reviewer Actions Amendment
**Timestamp**: 2026-07-16T06:26:22Z
**User Input**: "Need you to make one small edit in [supplier-onboarding-wireframes.html](mockups/supplier-onboarding-wireframes.html). As of now there is no way for the reviewer to approve, reject or ask for corrections in a submitted supplier form. I think you should add it in Request Review Detail tab. Rest is perfectly fine so leave it as it is"
**AI Response**: "Resumed the existing wireframe review gate and began a narrowly scoped amendment to make the existing Request Review Detail decision controls functional while leaving all other screens and layout unchanged."
**Context**: AI-DLC Inception - Wireframes/mockups reviewer-action amendment.

---

## Wireframe Reviewer Actions Amendment Completion
**Timestamp**: 2026-07-16T06:28:18Z
**User Input**: "Need you to make one small edit in [supplier-onboarding-wireframes.html](mockups/supplier-onboarding-wireframes.html). As of now there is no way for the reviewer to approve, reject or ask for corrections in a submitted supplier form. I think you should add it in Request Review Detail tab. Rest is perfectly fine so leave it as it is"
**AI Response**: "Enabled Approve in Request Review Detail and connected Approve, Request Correction, Reject, and Mark Duplicate to the existing decision modal with the matching decision preselected. Left every other mockup screen and layout unchanged. Verified the four enabled actions, modal visibility and selected values, visual layout, HTML/JavaScript execution, and clean diff whitespace in the local browser."
**Context**: AI-DLC Inception - Wireframes/mockups reviewer-action amendment completed and validated.

---

## Requester Risk Visibility Amendment
**Timestamp**: 2026-07-16T06:40:38Z
**User Input**:
```text
GET	/requests/{requestId}/risk-assessment	Requester owner summary, Reviewer, Support/Admin	Retrieve risk assessment.

why do we need this api and what is it used for?

This API exists because calculating a risk assessment and retrieving a risk assessment are two different operations.

Notice there are actually two APIs:

API	Purpose
POST /requests/{requestId}/risk-score	Run the risk engine and calculate/update the risk assessment.
GET /requests/{requestId}/risk-assessment	Retrieve the already-calculated risk assessment.
Why not just calculate it every time?

Imagine this workflow.

User submits a supplier
Submit Request
       │
       ▼
Validation
       │
       ▼
Duplicate Detection
       │
       ▼
Risk Scoring
       │
       ▼
Save to RISK_ASSESSMENT table

Now the reviewer opens the request 10 minutes later.

Should the system:

recalculate everything?
rerun duplicate matching?
rerun all risk rules?

No.

It simply reads what was already calculated.

GET /requests/123/risk-assessment

returns

{
  "riskScore": 55,
  "riskLevel": "Medium",
  "reasons": [
    "Missing tax registration",
    "Bank country mismatch"
  ]
}

The calculation has already been done and stored in the RISK_ASSESSMENT table.

Who uses this API?
1. Reviewer screen

When a reviewer opens a request, the UI needs to show something like:

Risk Assessment

Medium Risk

Reasons
---------
✓ Missing tax registration
✓ Bank country differs from supplier country
✓ High expected spend

The frontend calls

GET /requests/123/risk-assessment
2. Requester

Notice the endpoint permissions:

Requester owner summary
Reviewer
Support/Admin

The requester is only allowed to see a summary, not all the internal details.

So the requester may see:

Status:
Under Review

Risk:
Medium

Please provide Tax Registration.

while the reviewer sees the complete factor breakdown.

3. AI

The AI explanation service also needs the risk assessment.

Instead of recalculating risk itself, it simply reads:

GET risk-assessment

then generates

Medium risk due to missing tax registration and weak business justification.

This matches the design, where AI explains the structured risk findings rather than making decisions.

4. Dashboard

The reviewer dashboard may show:

Requests

High Risk      5
Medium Risk   18
Low Risk      42

Clicking a request opens the details, and the UI calls:

GET /requests/123/risk-assessment
Why is it a GET instead of POST?

REST convention is:

GET = retrieve existing data
POST = perform an action or create/update something

So:

POST /risk-score

means

"Run the scoring engine."

Whereas

GET /risk-assessment

means

"Show me the results."

An analogy

Think about a university exam.

Teacher grades exam

That's like

POST /risk-score

Once graded, the result is stored.

Later, a student checks their marks.

That's like

GET /risk-assessment

The teacher doesn't re-grade the paper every time the student opens the portal—they simply retrieve the stored result.

One thing I'd improve

Since this API is just returning the latest stored assessment, I would consider making it even clearer by naming it:

GET /requests/{requestId}/risk

or

GET /requests/{requestId}/risk-summary

Functionally, though, GET /requests/{requestId}/risk-assessment is perfectly valid and accurately reflects that it's retrieving the persisted assessment rather than recalculating it.

but the requester shoudn't be allowed to get his own risk assessment tho?

I actually agree with you. Based on the discovery call, I would not expose the risk assessment endpoint to the requester.

The transcript consistently describes risk as something that helps the reviewer make a decision:

AI should explain the risk to the reviewer and recommend what they should verify.
Risky suppliers require manual review.
The requester's responsibility is to submit a request and track its status.

In fact, the persona model also says:

Requester: View own request status
Reviewer: View duplicate/risk details
Support/Admin: View duplicate/risk details

Notice it doesn't explicitly say the requester should see the detailed risk assessment.

What I would change

Instead of:

GET /requests/{requestId}/risk-assessment
Roles:
Requester owner summary, Reviewer, Support/Admin

I would split it into two concepts.

Option 1 (my preferred design)
GET /requests/{requestId}

The requester gets:

{
  "status": "Under Review",
  "statusMessage": "Awaiting reviewer decision."
}

or, if corrections are needed:

{
  "status": "Correction Requested",
  "message": "Please provide a tax registration certificate."
}

No risk score is exposed.

The reviewer, however, calls:

GET /requests/{requestId}/risk-assessment

and receives:

{
  "riskScore": 82,
  "riskLevel": "High",
  "reasons": [
    ...
    ...
  ]
}
Option 2

Keep the same endpoint but make the response role-aware:

Requester:

{
    "riskSummary":
    "Additional information required."
}

Reviewer:

{
    "riskScore":82,
    "riskLevel":"High",
    "reasons":[...]
}

I don't like this approach because the same endpoint returns fundamentally different data depending on the caller, which can make the API harder to understand and document.

Why hide the risk?

Imagine I'm a requester.

If I immediately see:

Risk: HIGH

I might:

panic,
argue with Procurement,
or try to game the system by tweaking the justification until the score drops.

The reviewer is the one who should interpret the score, request additional information, or approve/reject based on the organization's policies.

So I would recommend changing the API catalog to:
Endpoint	Roles
GET /requests/{requestId}	Requester (own), Reviewer, Support/Admin
GET /requests/{requestId}/risk-assessment	Reviewer, Support/Admin only
GET /requests/{requestId}/duplicate-matches	Reviewer, Support/Admin only

The requester should receive only the workflow status and any actionable messages (such as "Correction Requested" with reviewer comments), not the internal risk score or duplicate analysis.

I think the current API catalog is slightly inconsistent with the overall design intent expressed in the discovery call and persona model.
```
**AI Response**: "Interpreted the attached decision as an explicit access-control correction: Requesters must not access persisted risk assessments, while Reviewers and Support/Admin users retain risk visibility and Requesters receive only status and actionable business guidance."
**Context**: AI-DLC Inception - Requirements, application design, and wireframe requester-risk visibility amendment.

---

## Requester Risk Visibility Amendment Completion
**Timestamp**: 2026-07-16T06:42:48Z
**User Input**:
```text
GET	/requests/{requestId}/risk-assessment	Requester owner summary, Reviewer, Support/Admin	Retrieve risk assessment.

why do we need this api and what is it used for?

This API exists because calculating a risk assessment and retrieving a risk assessment are two different operations.

Notice there are actually two APIs:

API	Purpose
POST /requests/{requestId}/risk-score	Run the risk engine and calculate/update the risk assessment.
GET /requests/{requestId}/risk-assessment	Retrieve the already-calculated risk assessment.
Why not just calculate it every time?

Imagine this workflow.

User submits a supplier
Submit Request
       │
       ▼
Validation
       │
       ▼
Duplicate Detection
       │
       ▼
Risk Scoring
       │
       ▼
Save to RISK_ASSESSMENT table

Now the reviewer opens the request 10 minutes later.

Should the system:

recalculate everything?
rerun duplicate matching?
rerun all risk rules?

No.

It simply reads what was already calculated.

GET /requests/123/risk-assessment

returns

{
  "riskScore": 55,
  "riskLevel": "Medium",
  "reasons": [
    "Missing tax registration",
    "Bank country mismatch"
  ]
}

The calculation has already been done and stored in the RISK_ASSESSMENT table.

Who uses this API?
1. Reviewer screen

When a reviewer opens a request, the UI needs to show something like:

Risk Assessment

Medium Risk

Reasons
---------
✓ Missing tax registration
✓ Bank country differs from supplier country
✓ High expected spend

The frontend calls

GET /requests/123/risk-assessment
2. Requester

Notice the endpoint permissions:

Requester owner summary
Reviewer
Support/Admin

The requester is only allowed to see a summary, not all the internal details.

So the requester may see:

Status:
Under Review

Risk:
Medium

Please provide Tax Registration.

while the reviewer sees the complete factor breakdown.

3. AI

The AI explanation service also needs the risk assessment.

Instead of recalculating risk itself, it simply reads:

GET risk-assessment

then generates

Medium risk due to missing tax registration and weak business justification.

This matches the design, where AI explains the structured risk findings rather than making decisions.

4. Dashboard

The reviewer dashboard may show:

Requests

High Risk      5
Medium Risk   18
Low Risk      42

Clicking a request opens the details, and the UI calls:

GET /requests/123/risk-assessment
Why is it a GET instead of POST?

REST convention is:

GET = retrieve existing data
POST = perform an action or create/update something

So:

POST /risk-score

means

"Run the scoring engine."

Whereas

GET /risk-assessment

means

"Show me the results."

An analogy

Think about a university exam.

Teacher grades exam

That's like

POST /risk-score

Once graded, the result is stored.

Later, a student checks their marks.

That's like

GET /risk-assessment

The teacher doesn't re-grade the paper every time the student opens the portal—they simply retrieve the stored result.

One thing I'd improve

Since this API is just returning the latest stored assessment, I would consider making it even clearer by naming it:

GET /requests/{requestId}/risk

or

GET /requests/{requestId}/risk-summary

Functionally, though, GET /requests/{requestId}/risk-assessment is perfectly valid and accurately reflects that it's retrieving the persisted assessment rather than recalculating it.

but the requester shoudn't be allowed to get his own risk assessment tho?

I actually agree with you. Based on the discovery call, I would not expose the risk assessment endpoint to the requester.

The transcript consistently describes risk as something that helps the reviewer make a decision:

AI should explain the risk to the reviewer and recommend what they should verify.
Risky suppliers require manual review.
The requester's responsibility is to submit a request and track its status.

In fact, the persona model also says:

Requester: View own request status
Reviewer: View duplicate/risk details
Support/Admin: View duplicate/risk details

Notice it doesn't explicitly say the requester should see the detailed risk assessment.

What I would change

Instead of:

GET /requests/{requestId}/risk-assessment
Roles:
Requester owner summary, Reviewer, Support/Admin

I would split it into two concepts.

Option 1 (my preferred design)
GET /requests/{requestId}

The requester gets:

{
  "status": "Under Review",
  "statusMessage": "Awaiting reviewer decision."
}

or, if corrections are needed:

{
  "status": "Correction Requested",
  "message": "Please provide a tax registration certificate."
}

No risk score is exposed.

The reviewer, however, calls:

GET /requests/{requestId}/risk-assessment

and receives:

{
  "riskScore": 82,
  "riskLevel": "High",
  "reasons": [
    ...
    ...
  ]
}
Option 2

Keep the same endpoint but make the response role-aware:

Requester:

{
    "riskSummary":
    "Additional information required."
}

Reviewer:

{
    "riskScore":82,
    "riskLevel":"High",
    "reasons":[...]
}

I don't like this approach because the same endpoint returns fundamentally different data depending on the caller, which can make the API harder to understand and document.

Why hide the risk?

Imagine I'm a requester.

If I immediately see:

Risk: HIGH

I might:

panic,
argue with Procurement,
or try to game the system by tweaking the justification until the score drops.

The reviewer is the one who should interpret the score, request additional information, or approve/reject based on the organization's policies.

So I would recommend changing the API catalog to:
Endpoint	Roles
GET /requests/{requestId}	Requester (own), Reviewer, Support/Admin
GET /requests/{requestId}/risk-assessment	Reviewer, Support/Admin only
GET /requests/{requestId}/duplicate-matches	Reviewer, Support/Admin only

The requester should receive only the workflow status and any actionable messages (such as "Correction Requested" with reviewer comments), not the internal risk score or duplicate analysis.

I think the current API catalog is slightly inconsistent with the overall design intent expressed in the discovery call and persona model.
```
**AI Response**: "Removed Requester authorization from GET /requests/{requestId}/risk-assessment and defined the Requester projection of GET /requests/{requestId} as status and actionable business guidance only. Synchronized FR-002, NFR-002, the Requester persona, US-003, technical access/API/security design, wireframe specification, and requester mockup. Removed the requester dashboard risk column and replaced the requester detail risk card with Next Action. Verified in the local browser that requester screens expose no risk score/reasons while reviewer dashboard and evidence views retain risk assessment and AI explanation details."
**Context**: AI-DLC Inception - Requirements, application design, and wireframe requester-risk visibility amendment completed and validated.

---
