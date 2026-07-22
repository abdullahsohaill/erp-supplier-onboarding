# UOW-001 API Summary

UOW-001 owns 11 of 42 protected OpenAPI operations: request create/list/get/update/submit, validation-result and attachment reads, attachment metadata maintenance, Requester dashboard, and two authenticated reference reads.

ORDS handlers are thin package calls. OAuth2 privileges authenticate first; package authorization enforces Requester ownership. Payload, string, collection, pagination, and body-size bounds are validated. Envelopes carry a transient trace ID and safe errors.

There is no Requester duplicate-preview route. Duplicate detection runs automatically during submit/resubmit. The edge publishes only OAuth and the versioned API on loopback HTTPS; all other paths return 404.
