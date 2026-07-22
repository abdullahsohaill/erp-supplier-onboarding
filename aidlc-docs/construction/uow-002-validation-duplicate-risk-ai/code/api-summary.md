# UOW-002 API Summary

UOW-002 owns seven operations: run/read validation, run/read duplicate analysis, calculate/read risk, and generate/read AI summaries. Requester submission invokes analysis internally and exposes no manual preview. Explicit reruns require privileged roles. Risk, candidates, and AI evidence are absent from Requester projections. HTTP 422 represents blockers while preserving Draft or Correction Requested.
