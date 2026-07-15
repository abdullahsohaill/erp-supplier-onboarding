# Components

| Component | Purpose | Key Responsibilities |
|---|---|---|
| Request UI | Visual Builder requester experience | Create drafts, submit requests, view status. |
| Review UI | Visual Builder reviewer experience | Review queues, duplicate candidates, risk summaries, approve/reject/correct/duplicate actions. |
| Support/Admin UI | Visual Builder support and admin experience | Integration logs, retry, failure diagnostics, reference data maintenance. |
| ORDS Request API | REST layer | Expose ATP request data and actions to Visual Builder. |
| Validation Component | Business validation | Required fields, conditional fields, validation result persistence. |
| Duplicate Component | Matching engine | Normalize input, compare with reference suppliers, score candidates, persist explanations. |
| Risk Component | Risk scoring | Apply configurable risk rules and assign risk level. |
| AI Summary Component | AI explanation | Generate and store summaries without making decisions. |
| OIC Submit Component | Fusion creation | Transform and submit approved requests to Fusion/mock endpoint. |
| OIC Sync Component | Reference data sync | Load existing suppliers from Fusion/mock data into ATP. |
