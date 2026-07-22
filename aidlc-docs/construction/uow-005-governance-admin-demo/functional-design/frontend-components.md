# UOW-005 Frontend Components

| Admin Settings View | Controls | API |
|---|---|---|
| High-Risk Countries | Country/period/risk/active/effective dates | country GET/PUT |
| Validation Rules | Named active toggles, severity/blocking read-only context | validation GET/PUT |
| Risk Factors | Active toggle, weight, severity by version | scoring GET/PUT with `RISK` |
| Duplicate Rules | Active toggle, weight/critical behavior by version | scoring GET/PUT with `DUPLICATE` |
| Business Units | Name, Fusion mapping, active | BU GET/PUT |
| Supplier Types | Name, tax-required, active | type GET/PUT |
| Reference Sync | Trigger and OIC monitoring identity | sync POST |

The approved label is **Admin Settings**. Reviewer factor checkboxes remain in Review Detail, not Admin Settings. Future UI controls require stable test IDs and explicit save/error states.
