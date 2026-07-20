# Demo Script

## Scenario 1: Duplicate Controls And Reviewer Decision

1. Requester first attempts a request with an exact tax-registration match; automatic submit validation blocks submission and explains that the duplicate identifier must be corrected or the existing supplier used.
2. Requester submits a separate request with no critical identifier match but strong fuzzy evidence such as similar normalized name, same country, address similarity, or matching email domain.
3. System validates mandatory fields and persists the non-blocking duplicate candidate.
4. Risk score becomes Medium or High from the explainable fuzzy signals.
5. AI summary explains the duplicate reasons and recommends verification.
6. Reviewer confirms the applicable risk factors, marks the request duplicate, and references the existing supplier.
7. Requester sees Marked Duplicate status and the existing supplier reference.

## Scenario 2: Clean Supplier Creation

1. Requester submits complete supplier data with one site.
2. Validation passes.
3. Duplicate risk is Low.
4. Risk score is Low.
5. Reviewer approves.
6. OIC submits supplier to Fusion or mock endpoint.
7. Fusion/mock returns supplier number.
8. Status changes to Created in Fusion.

## Scenario 3: High-Risk Incomplete Request

1. Requester submits supplier with missing tax registration, vague justification, and high expected spend.
2. Validation flags missing/weak information.
3. Risk score becomes Medium or High.
4. AI summary recommends requesting tax certificate and improved business justification.
5. Reviewer requests correction.

## Scenario 4: Integration Failure and Retry

1. Reviewer approves otherwise clean request.
2. OIC submits to Fusion/mock endpoint.
3. Fusion/mock returns failure due to invalid business unit mapping or missing site mapping.
4. Status changes to Integration Failed.
5. Support/admin dashboard shows request ID, OIC instance ID, error message, timestamp, retry count, payload reference, and embedded retry history.
6. Support/admin user fixes mapping and retries.
7. Retry succeeds and status changes to Created in Fusion.
