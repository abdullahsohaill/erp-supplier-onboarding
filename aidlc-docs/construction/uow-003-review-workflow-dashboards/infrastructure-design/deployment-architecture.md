# UOW-003 Deployment Architecture

## Operations

| Method | Path | Role |
|---|---|---|
| GET | `/requests` | Reviewer/Support plus existing Requester scope |
| GET | `/requests/{requestId}` | Reviewer/Support plus owner-safe Requester scope |
| POST | `/requests/{requestId}/approve` | Reviewer |
| POST | `/requests/{requestId}/reject` | Reviewer |
| POST | `/requests/{requestId}/request-correction` | Reviewer |
| POST | `/requests/{requestId}/mark-duplicate` | Reviewer |
| GET | `/dashboard/reviewer-summary` | Reviewer |

The requester summary/list/detail routes from UOW-001 supply the requester dashboard and guidance. All ingress remains loopback HTTPS; ORDS stays private. There is no additional deployment unit or public network path.
