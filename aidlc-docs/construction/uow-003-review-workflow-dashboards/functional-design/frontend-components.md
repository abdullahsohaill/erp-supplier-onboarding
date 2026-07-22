# UOW-003 Frontend Components

| Component | State and Interaction | API |
|---|---|---|
| Reviewer dashboard | Queue counts, bounded filters, pagination, selected request | `GET /requests`, `GET /dashboard/reviewer-summary` |
| Review detail | Request plus validation/duplicate/risk/AI/document evidence tabs | role-safe detail/evidence GETs |
| Decision modal | Command, comment, factor checkboxes, correction items, supplier reference | approve/reject/request-correction/mark-duplicate POST |
| Requester dashboard | Owner list and derived Actions column | `GET /requests`, requester summary |
| Requester guidance | Latest safe comment/corrections/duplicate reference | `GET /requests/{requestId}` |

Every future interactive control requires stable `data-testid` values. Automatic baseline weights remain hidden; Reviewer sees named factor checkboxes only.
