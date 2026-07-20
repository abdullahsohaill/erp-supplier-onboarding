# Component Methods

## ORDS Request API

- `createRequest(payload) -> requestId`
- `updateRequest(requestId, payload) -> request`
- `submitRequest(requestId) -> {status, submitted, findings}`; a blocked attempt preserves Draft or Correction Requested
- `getRequest(requestId) -> requestDetail`
- `listRequests(filters) -> requestSummary[]`

## Validation Component

- `getActiveValidationRules() -> validationRule[]`
- `validateRequest(requestId) -> validationResult[]`
- `classifyValidationError(error) -> business|technical`
- `persistValidationResults(requestId, resultsWithRuleIds) -> void`

## Duplicate Component

- `normalizeSupplier(requestId) -> normalizedSupplier`
- `getScoringRules(ruleType = DUPLICATE) -> scoringRule[]`
- `findDuplicateCandidates(requestId) -> duplicateCandidate[]`
- `scoreDuplicateCandidate(request, candidate) -> duplicateScore`
- `persistDuplicateMatches(requestId, matches) -> void`

## Risk Component

- `getScoringRules(ruleType = RISK) -> scoringRule[]`
- `calculateRisk(requestId) -> riskAssessment`
- `getRiskReasons(requestId) -> riskReason[]`
- `persistRiskAssessment(requestId, assessment) -> void`

## Review Workflow Component

- `buildDecisionEnvelope(comment, selectedRiskFactorCodes, correctionItems, existingSupplierNumber) -> actionCommentJson`
- `recordDecision(requestId, actionCode, targetStatus, actionCommentJson, actorUser) -> statusHistory`
- `parseDecisionEnvelope(statusHistory, roleScope) -> decisionGuidance`; Requester scope omits Reviewer-only factor selections
- `getCurrentCorrectionGuidance(requestId, roleScope) -> correctionGuidance`

## AI Summary Component

- `buildRiskPrompt(requestId) -> prompt`
- `generateSummary(requestId) -> aiSummary`
- `persistSummary(requestId, summary) -> void`

## OIC Submit Component

- `buildFusionSupplierPayload(requestId) -> fusionPayload`
- `submitSupplier(payload) -> fusionResponse`
- `retrySupplier(logId, actorUser) -> integrationResult`; resolves and verifies the required request from the originating log
- `recordRetryAttempt(logId, retryEntry) -> integrationLog`
- `handleFusionSuccess(requestId, response) -> void`
- `handleFusionFailure(requestId, error) -> void`

## OIC Sync Component

- `fetchFusionSuppliers(criteria) -> fusionSupplier[]`
- `transformSupplierReference(fusionSupplier) -> supplierRef`
- `upsertSupplierReference(supplierRef) -> void`
- `recordSyncOutcomeInOicMonitoring(oicInstanceId, result) -> void`
