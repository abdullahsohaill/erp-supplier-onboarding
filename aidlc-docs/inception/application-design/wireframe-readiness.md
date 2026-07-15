# Wireframe Readiness Notes

Wireframes are intentionally not generated yet. This document captures what must be true before the wireframe phase starts.

## Current Readiness

| Area | Status | Notes |
|---|---|---|
| Personas | Ready | Requester, Reviewer, Support/Admin User. |
| User stories | Ready for review | 14 consolidated stories with acceptance criteria and requirement mapping. |
| Requirements | Ready for review | Functional/NFR tables with detailed acceptance criteria. |
| Technical design | Ready for review | Complete for proposal and wireframe preparation; final build details depend on review of answered assumptions and customer tenancy validation. |
| Answered assumptions | Answered, needs review | 34 AI-DLC questions are answered with rationale in `requirement-verification-questions.md`. |

## What We Need Before Wireframing

| Need | Why It Matters |
|---|---|
| Approval of three-persona model | Determines navigation, permissions, and screen variants. |
| Approval of request statuses | Drives status chips, timeline, queues, and filters. |
| Confirm real-time duplicate preview assumption | Current assumption: optional only, if schedule allows. |
| Confirm attachment metadata assumption | Current assumption: metadata and missing-document flags only; no upload. |
| Confirm AI runtime/mock assumption | Current assumption: customer-approved enterprise AI service or mock if unavailable. |
| Confirm bank handling assumption | Current assumption: optional capture, mask display, token/hash for duplicate checks, no Fusion bank creation. |
| Confirm dashboard scope | Current assumption: requester dashboard, reviewer dashboard, support/admin dashboard. |
| Confirm demo scenarios | Current assumption: duplicate-risk, clean supplier creation, high-risk incomplete request, integration failure with retry. |

## Likely Wireframe Screen Inventory

| Screen | Persona | Purpose |
|---|---|---|
| My Requests Dashboard | Requester | Track drafts, submitted requests, correction-needed requests, created suppliers, rejected/duplicate requests. |
| Supplier Request Form | Requester | Create/edit request, supplier details, contact, site, business justification, tax, optional bank/document metadata. |
| Request Detail and Status Timeline | Requester | View status, reviewer comments, duplicate reference, Fusion supplier number. |
| Reviewer Dashboard | Reviewer | Review queue, high-risk, duplicate-risk, pending, failed, recently created requests. |
| Request Review Detail | Reviewer | See validation, duplicate matches, risk factors, AI summary, request data, history. |
| Review Decision Modal | Reviewer | Approve, reject, request correction, mark duplicate with required comments/reference. |
| Support/Admin Dashboard | Support/Admin | View integration failures, retry eligibility, OIC instance IDs, retry counts. |
| Integration Log Detail | Support/Admin | Inspect user-friendly and technical error detail, payload/response references. |
| Reference Data Maintenance | Support/Admin | Maintain high-risk countries, business unit mappings, supplier types, thresholds if included. |

## Wireframe Entry Criteria

- [ ] Requirements reviewed.
- [ ] Technical design reviewed.
- [ ] Answered assumptions reviewed or changes listed.
- [ ] Screen inventory approved.
- [ ] User explicitly asks to begin wireframes.
