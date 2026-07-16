# Wireframe Reviewer Actions Amendment Plan

## Scope

Make the existing Request Review Detail decision controls usable without changing any other mockup screen or layout.

## Execution Checklist

- [x] Read the current AI-DLC state and applicable content-validation rules.
- [x] Inspect the Request Review Detail controls, decision modal, and event handling.
- [x] Enable the Approve action while preserving Request Correction, Reject, and Mark Duplicate.
- [x] Make each action open the decision modal with the matching decision selected.
- [x] Validate HTML/JavaScript structure and verify all reviewer actions in the local browser.
- [x] Record the completed amendment and validation results in `aidlc-docs/audit.md`.

## Validation Criteria

- Approve, Request Correction, and Reject are visible and enabled in Request Review Detail.
- Each button opens the review decision modal.
- The modal selection matches the button used.
- Mark Duplicate continues to work unchanged.
- No other mockup screen or layout is modified.
