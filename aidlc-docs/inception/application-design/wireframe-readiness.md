# Wireframe Review Notes

Wireframes/mockups have now been generated. This document captures the approved baseline and the artifacts to review before moving into construction-stage design.

## Current Readiness

| Area | Status | Notes |
|---|---|---|
| Personas | Ready | Requester, Reviewer, Support/Admin User. |
| User stories | Ready for review | 14 consolidated stories with acceptance criteria and requirement mapping. |
| Requirements | Approved for wireframe baseline | 15 FRs and 8 NFRs reviewed by user. |
| Technical design | Complete for wireframe baseline | Architecture, data model/schema, ORDS APIs, OIC/Fusion boundaries, duplicate/risk/AI logic covered. |
| Answered assumptions | Approved for wireframe baseline | 34 AI-DLC questions were reviewed by user and accepted as the working baseline. |
| Wireframes/mockups | Ready for review | Specification and clickable static mockup created. |

## Wireframe Artifacts

| Artifact | Location | Purpose |
|---|---|
| Wireframe specification | `aidlc-docs/inception/wireframes/wireframe-spec.md` | Screen goals, traceability, layout notes, states, and review checklist. |
| Clickable mockup | `mockups/supplier-onboarding-wireframes.html` | Static HTML review artifact with 9 navigable screens and 10 traced WF IDs; WF-007 Review Decision Modal is embedded at the end of Request Review Detail. |

## Wireframe Screen Inventory

| Screen | Persona | Purpose |
|---|---|---|
| My Requests Dashboard | Requester | Track drafts, submitted requests, correction-needed requests, created suppliers, rejected/duplicate requests. |
| Supplier Request Form | Requester | Create/edit request, supplier details, contact, site, business justification, tax, optional bank/document metadata. |
| Request Detail and Status Timeline | Requester | View status, reviewer comments, duplicate reference, Fusion supplier number. |
| Reviewer Dashboard | Reviewer | Review queue, high-risk, duplicate-risk, pending, failed, recently created requests. |
| Request Review Detail | Reviewer | See validation, duplicate matches, risk factors, AI summary, request data, history. |
| Duplicate / Risk / AI Evidence Panel | Reviewer | Inspect duplicate candidates, risk reasons, AI advisory summary, and data minimization guardrails. |
| Review Decision Modal | Reviewer | Embedded at the end of Request Review Detail; approve, reject, request correction, and mark duplicate with required comments/reference. |
| Support/Admin Dashboard | Support/Admin | View integration failures, retry eligibility, OIC instance IDs, retry counts. |
| Integration Log Detail | Support/Admin | Inspect user-friendly and technical error detail, payload/response references. |
| Admin Settings Maintenance | Support/Admin | Maintain high-risk countries, business unit mappings, supplier types, validation controls, and scoring thresholds. |

## Wireframe Entry Criteria

- [x] Requirements reviewed.
- [x] Technical design reviewed for wireframe baseline.
- [x] Answered assumptions reviewed or changes listed.
- [x] Screen inventory approved by user command to create complete wireframes/mockups.
- [x] User explicitly asked to begin wireframes.

## Wireframe Exit Criteria

- [ ] User reviews the wireframe specification.
- [ ] User reviews the clickable static mockup.
- [ ] Requested screen/layout changes are captured.
- [ ] Wireframes are approved for construction-stage design.
