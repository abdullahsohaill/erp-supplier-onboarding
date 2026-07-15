# Demo Script

## Scenario 1: Duplicate-Risk Supplier

1. Requester creates supplier request for a supplier similar to an existing Fusion supplier.
2. System validates mandatory fields.
3. Duplicate check identifies candidate supplier with similar name and matching tax ID or email domain.
4. Risk score becomes High or Critical.
5. AI summary explains duplicate reasons and recommends verification.
6. Reviewer marks the request duplicate and references the existing supplier.
7. Requester sees Marked Duplicate status and existing supplier reference.

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
5. Support/admin dashboard shows OIC instance ID, error message, timestamp, retry count, and payload reference.
6. Support/admin user fixes mapping and retries.
7. Retry succeeds and status changes to Created in Fusion.
