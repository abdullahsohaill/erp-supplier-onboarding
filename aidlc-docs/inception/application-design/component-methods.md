# Component Methods

## ORDS Request API

- `createRequest(payload) -> requestId`
- `updateRequest(requestId, payload) -> request`
- `submitRequest(requestId) -> status`
- `getRequest(requestId) -> requestDetail`
- `listRequests(filters) -> requestSummary[]`

## Validation Component

- `validateRequest(requestId) -> validationResult[]`
- `classifyValidationError(error) -> business|technical`
- `persistValidationResults(requestId, results) -> void`

## Duplicate Component

- `normalizeSupplier(requestId) -> normalizedSupplier`
- `findDuplicateCandidates(requestId) -> duplicateCandidate[]`
- `scoreDuplicateCandidate(request, candidate) -> duplicateScore`
- `persistDuplicateMatches(requestId, matches) -> void`

## Risk Component

- `calculateRisk(requestId) -> riskAssessment`
- `getRiskReasons(requestId) -> riskReason[]`
- `persistRiskAssessment(requestId, assessment) -> void`

## AI Summary Component

- `buildRiskPrompt(requestId) -> prompt`
- `generateSummary(requestId) -> aiSummary`
- `persistSummary(requestId, summary) -> void`

## OIC Submit Component

- `buildFusionSupplierPayload(requestId) -> fusionPayload`
- `submitSupplier(payload) -> fusionResponse`
- `handleFusionSuccess(requestId, response) -> void`
- `handleFusionFailure(requestId, error) -> void`

## OIC Sync Component

- `fetchFusionSuppliers(criteria) -> fusionSupplier[]`
- `transformSupplierReference(fusionSupplier) -> supplierRef`
- `upsertSupplierReference(supplierRef) -> void`
- `logSyncResult(result) -> void`
