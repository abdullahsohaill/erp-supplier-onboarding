# Components

| Component | Purpose | Key Responsibilities |
|---|---|---|
| Request UI | Visual Builder requester experience | Create drafts, submit requests, view status. |
| Review UI | Visual Builder reviewer experience | Review queues, duplicate candidates, risk summaries, approve/reject/correct/duplicate actions. |
| Support/Admin UI | Visual Builder support and admin experience | Integration logs, retry, failure diagnostics, reference data maintenance. |
| ORDS Request API | REST layer | Expose ATP request data and actions to Visual Builder. |
| Validation Component | Business validation | Load active governed validation rules, evaluate request data, and persist each failed result with its validation-rule identifier. |
| Duplicate Component | Matching engine | Load `DUPLICATE` scoring rules, normalize input, compare with reference suppliers, score candidates, and persist explanations. |
| Risk Component | Risk scoring | Load `RISK` scoring rules from the shared catalog, apply configurable weights, and assign risk level. |
| AI Summary Component | AI explanation | Generate and store summaries without making decisions. |
| OIC Submit Component | Fusion creation | Transform and submit approved requests to Fusion/mock endpoint. |
| OIC Sync Component | Reference data sync | Load existing suppliers from Fusion/mock data into ATP. |
