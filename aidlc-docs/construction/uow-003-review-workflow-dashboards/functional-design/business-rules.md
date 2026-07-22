# UOW-003 Business Rules

| ID | Rule |
|---|---|
| REV-BR-001 | Only Reviewer may record a business decision. |
| REV-BR-002 | Decisions are accepted only from Under Review. |
| REV-BR-003 | Approve requires no active blocking validation. |
| REV-BR-004 | Reject, Request Correction, and Mark Duplicate require a business comment. |
| REV-BR-005 | Request Correction requires at least one structured correction item. |
| REV-BR-006 | Mark Duplicate requires an existing supplier number/reference. |
| REV-BR-007 | Selected risk-factor codes are bounded decision evidence and do not change automatic score. |
| REV-BR-008 | Decision comment, selected factor codes, correction items, and duplicate reference share schema-versioned history JSON. |
| REV-BR-009 | Status update and history append are atomic and actor/timestamp are server derived. |
| REV-BR-010 | High/duplicate risk cannot bypass manual review. |
| REV-BR-011 | Requester receives targeted guidance but no protected scoring/AI/candidate evidence. |
| REV-BR-012 | Counts and queue/list results use identical filter semantics and bounded pagination. |
| REV-BR-013 | Only Correction Requested requester rows expose Edit and Resubmit; all other actions equal None. |
