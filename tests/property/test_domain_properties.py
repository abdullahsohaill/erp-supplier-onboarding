from __future__ import annotations

import json
import string
from decimal import Decimal

from hypothesis import given, settings, strategies as st

from tests.support.reference_model import (
    REQUESTER_FORBIDDEN_KEYS,
    append_retry,
    duplicate_score,
    money,
    normalize_name,
    normalize_token,
    requester_projection,
    risk_score,
    submit,
)

safe_text = st.text(alphabet=string.ascii_letters + string.digits + " .,-_", max_size=80)
status = st.sampled_from(["Draft", "Correction Requested"])
risk_codes = st.sampled_from([
    "MISSING_TAX", "HIGH_RISK_COUNTRY", "BANK_COUNTRY_MISMATCH", "INCOMPLETE_ADDRESS",
    "INCOMPLETE_BANK_DETAILS", "VAGUE_JUSTIFICATION", "HIGH_SPEND_WEAK_JUSTIFICATION",
    "MISSING_DOCUMENT_METADATA", "DUPLICATE_SCORE_HIGH", "DUPLICATE_SCORE_MEDIUM",
])
duplicate_codes = st.sampled_from([
    "DUP_EXACT_TAX", "DUP_SAME_BANK", "DUP_NAME_SIMILARITY", "DUP_SAME_COUNTRY",
    "DUP_EMAIL_DOMAIN", "DUP_PHONE", "DUP_ADDRESS", "DUP_BU_SITE",
])


@settings(max_examples=200)
@given(safe_text)
def test_normalization_is_idempotent(value: str) -> None:
    assert normalize_name(normalize_name(value)) == normalize_name(value)
    assert normalize_token(normalize_token(value)) == normalize_token(value)


@settings(max_examples=150)
@given(
    supplier_name=safe_text,
    country=st.sampled_from(["GB", "US", "AE", "XZ"]),
    spend=st.decimals(min_value=0, max_value=10_000_000, places=2, allow_nan=False, allow_infinity=False),
    sites=st.lists(st.fixed_dictionaries({"addressLine1": st.text(max_size=20), "addressLine2": st.text(max_size=20)}), max_size=5),
)
def test_request_json_round_trip(supplier_name: str, country: str, spend: Decimal, sites: list[dict[str, str]]) -> None:
    request = {"supplierName": supplier_name, "countryCode": country, "expectedAnnualSpend": str(spend), "sites": sites}
    assert json.loads(json.dumps(request, ensure_ascii=False)) == request


@settings(max_examples=200)
@given(st.sets(risk_codes), st.dictionaries(risk_codes, st.integers(min_value=0, max_value=100)))
def test_risk_score_always_in_range(factors: set[str], weights: dict[str, int]) -> None:
    score, level = risk_score(factors, weights)
    assert 0 <= score <= 100
    assert level in {"Low", "Medium", "High"}
    assert (score >= 70) == (level == "High")


@settings(max_examples=200)
@given(st.sets(duplicate_codes), st.dictionaries(duplicate_codes, st.integers(min_value=0, max_value=100)))
def test_duplicate_score_always_in_range(factors: set[str], weights: dict[str, int]) -> None:
    score, level = duplicate_score(factors, weights)
    assert 0 <= score <= 100
    assert level in {"Low", "Medium", "High", "Critical"}
    if factors & {"DUP_EXACT_TAX", "DUP_SAME_BANK"}:
        assert (score, level) == (100, "Critical")


@given(status, st.booleans())
def test_submit_preserves_or_advances_according_to_blockers(current: str, blocked: bool) -> None:
    result = submit(current, blocked)
    if blocked:
        assert result.status == current and not result.history and not result.accepted
    else:
        assert result.status == "Under Review" and result.history == ("Submitted", "Under Review") and result.accepted


@settings(max_examples=150)
@given(st.recursive(st.none() | st.booleans() | st.integers() | safe_text, lambda child: st.lists(child, max_size=4) | st.dictionaries(safe_text, child, max_size=4), max_leaves=20))
def test_requester_projection_never_contains_forbidden_keys(value: object) -> None:
    projected = requester_projection(value)

    def keys(item: object) -> list[str]:
        if isinstance(item, dict):
            return [str(k) for k in item] + [nested for v in item.values() for nested in keys(v)]
        if isinstance(item, list):
            return [nested for v in item for nested in keys(v)]
        return []

    normalized = {key.replace("_", "").lower() for key in keys(projected)}
    assert normalized.isdisjoint(REQUESTER_FORBIDDEN_KEYS)


@settings(max_examples=150)
@given(st.lists(st.fixed_dictionaries({"result": st.sampled_from(["FAILED", "SUCCEEDED"]), "message": safe_text}), max_size=20))
def test_retry_history_count_invariant(entries: list[dict[str, str]]) -> None:
    log: dict[str, object] = {"retryCount": 0, "retryHistory": []}
    for entry in entries:
        log = append_retry(log, entry)
    assert log["retryCount"] == len(log["retryHistory"])
    assert [entry["attemptNumber"] for entry in log["retryHistory"]] == list(range(1, len(entries) + 1))


@given(st.decimals(min_value=0, max_value=10**12, places=2, allow_nan=False, allow_infinity=False))
def test_money_round_trip_and_non_negative(amount: Decimal) -> None:
    normalized = money(str(amount))
    assert normalized >= 0
    assert money(str(normalized)) == normalized
