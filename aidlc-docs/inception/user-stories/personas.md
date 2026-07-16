# Personas

## Persona Summary

| Persona | Type | Primary Goal | Success Looks Like |
|---|---|---|---|
| Requester | Business user | Submit a complete supplier onboarding request and track the outcome without email follow-up. | Request is submitted with clear guidance, corrections are easy to make, and final status is visible. |
| Reviewer | Business reviewer | Evaluate supplier request completeness, duplicate risk, risk score, AI explanation, and make the final business decision. | Reviewer can quickly decide approve, reject, request correction, or mark duplicate with clear evidence. |
| Support/Admin User | Technical support and configuration user | Keep integrations observable, retry eligible failures, and maintain reference data. | Integration failures are diagnosable, retries are controlled, and reference values stay current. |

## Requester

| Attribute | Detail |
|---|---|
| Description | Business user from a business unit who needs a new supplier created for a product or service need. |
| Responsibilities | Create supplier request, provide supplier/contact/site/business details, correct returned requests, track status. |
| Needs | Guided form, clear mandatory fields, business-friendly validation messages, status visibility, duplicate/rejection guidance. |
| Pain Points Today | Requests are sent by email, spreadsheet, or ticket; no standard intake; unclear status; repeated follow-ups. |
| Key Screens Later | My Requests dashboard, Supplier Request form, Request Detail/status timeline, Correction edit view. |
| Access Boundary | Can create and view own requests only; receives status and actionable reviewer guidance but not internal risk scores, levels, reasons, or AI review evidence; cannot approve, reject, retry, or maintain reference data. |

## Reviewer

| Attribute | Detail |
|---|---|
| Description | Single business reviewer persona for the prototype. This persona consolidates procurement, master data, finance warning, and compliance/risk review responsibilities into one review role. |
| Responsibilities | Review submitted requests, inspect validation issues, inspect duplicate candidates, inspect risk reasons, review AI summary, approve, reject, request correction, or mark duplicate. |
| Needs | Prioritized queue, filters, duplicate match reasons, risk factor explanations, AI recommendation, requester comments/history, existing supplier reference when duplicate. |
| Pain Points Today | Duplicate suppliers are created, payment/site issues appear later, risk is not explained early, review status is hard to track. |
| Key Screens Later | Reviewer dashboard, Review queue, Request Review detail, Duplicate match panel, Risk/AI panel, Decision modal. |
| Access Boundary | Can make supplier request review decisions but cannot bypass validation/risk controls silently; does not manage technical retries by default. |

## Support/Admin User

| Attribute | Detail |
|---|---|
| Description | Technical support and configuration user responsible for integration observability, retry, and reference data needed by the prototype. |
| Responsibilities | Inspect integration logs, view OIC instance details, retry eligible failures, maintain reference data such as business units, supplier types, high-risk countries, and scoring thresholds if included. |
| Needs | Failed integration queue, technical error details, payload/response references, retry count, retry eligibility, reference data maintenance. |
| Pain Points Today | Business and technical failures blur together; support lacks clean retry/error context; payload and response traces are hard to correlate. |
| Key Screens Later | Support/Admin dashboard, Integration log detail, Retry action, Reference data maintenance views. |
| Access Boundary | Can retry eligible failures and maintain reference data; cannot approve supplier creation as a business reviewer unless explicitly assigned both roles. |

## Persona Rules

| Rule | Description |
|---|---|
| PR-001 | The prototype uses exactly three application personas: Requester, Reviewer, Support/Admin User. |
| PR-002 | Customer call participants remain stakeholders, not separate app personas. |
| PR-003 | Reviewer is the only business decision-maker for approve, reject, request correction, and mark duplicate in phase one. |
| PR-004 | Support/Admin handles technical retry and reference data, not business approval by default. |
