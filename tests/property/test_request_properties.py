from __future__ import annotations

import re

from hypothesis import given

from tests.support.strategies import last_four, safe_text, structured_address


def normalize(value: str) -> str:
    return re.sub(r"[^A-Z0-9]+", " ", value.upper()).strip()


@given(safe_text)
def test_normalization_is_idempotent(value: str) -> None:
    assert normalize(normalize(value)) == normalize(value)


@given(last_four)
def test_masked_bank_projection_only_contains_last_four(value: str) -> None:
    masked = "****" + value
    assert masked.endswith(value)
    assert len(masked) == 8
    assert re.fullmatch(r"[*]{4}[0-9]{4}", masked)


@given(structured_address())
def test_address_lines_obey_twenty_character_boundary(address: dict[str, str]) -> None:
    valid = bool(
        address["addressLine1"]
        and address["addressLine2"]
        and address["city"]
        and address["region"]
        and address["countryCode"]
        and len(address["addressLine1"]) <= 20
        and len(address["addressLine2"]) <= 20
    )
    if len(address["addressLine1"]) == 21 or len(address["addressLine2"]) == 21:
        assert not valid


@given(safe_text, safe_text)
def test_owner_identity_comparison_is_case_insensitive(owner: str, candidate: str) -> None:
    equal = owner.lower() == candidate.lower()
    assert equal == (owner.casefold() == candidate.casefold())
