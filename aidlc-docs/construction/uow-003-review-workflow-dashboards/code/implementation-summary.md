# UOW-003 Implementation Summary

UOW-003 implements US-007 through US-009 and FR-009/FR-010. `ERP_REVIEW_PKG` provides Reviewer dashboard and atomic Approve, Reject, Request Correction, and Mark Duplicate decisions.

Rules enforce role, state, comments, targeted correction items, and supplier references. Selected factor codes are decision evidence and never alter the score. Evidence uses the approved versioned JSON envelope in `STATUS_HISTORY.action_comment`.

Requester responses expose safe guidance only. Dashboard rows show `Edit and Resubmit` only for Correction Requested and non-clickable `None` otherwise. Reviewer views omit internal weight configuration.
