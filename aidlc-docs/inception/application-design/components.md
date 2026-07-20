# Components

| Component | Purpose | Key Responsibilities |
|---|---|---|
| Request UI | Visual Builder requester experience | Create drafts, submit requests, view status. |
| Review UI | Visual Builder reviewer experience | Review queues, duplicate candidates, risk summaries, approve/reject/correct/duplicate actions. |
| Support/Admin UI | Visual Builder support and admin experience | Integration logs, retry, failure diagnostics, and Admin Settings maintenance. |
| ORDS Request API | REST layer | Expose ATP request data and actions to Visual Builder. |
| Validation Component | Business validation | Load active governed validation rules, evaluate request data, and persist each failed result with its validation-rule identifier. |
| Duplicate Component | Matching engine | Load `DUPLICATE` scoring rules, normalize input, compare with reference suppliers, score candidates, and persist explanations. |
| Risk Component | Risk scoring | Load `RISK` scoring rules from the shared catalog, apply configurable weights, and assign risk level. |
| Review Workflow Component | Review decisions and evidence | Validate reviewer actions and write comments, selected risk-factor codes, targeted correction items, and duplicate references in the status-history decision envelope without changing the automatic risk score. |
| AI Summary Component | AI explanation | Generate and store summaries without making decisions. |
| OIC Submit Component | Fusion creation | Transform and submit approved requests, retry eligible failures, and atomically append retry audit entries to the integration log. |
| OIC Sync Component | Supplier reference sync | Load existing suppliers from Fusion/mock data into ATP, update `last_sync_at`, and use OIC-native monitoring for global run outcomes. |
