from __future__ import annotations

import copy
import re
from dataclasses import dataclass
from decimal import Decimal
from typing import Any

LEGAL_SUFFIXES = {"LTD", "LIMITED", "LLC", "INC", "INCORPORATED", "CORP", "CORPORATION", "PLC"}
REQUESTER_FORBIDDEN_KEYS = {
    "riskscore", "risklevel", "riskreasons", "riskreasonsjson", "scoringversion",
    "duplicatescore", "duplicatematches", "aisummary", "aisummaries",
    "selectedriskfactorcodes", "technicalmessage", "accounthash", "accounttoken",
}


def normalize_token(value: str | None) -> str:
    return "" if value is None else re.sub(r"[^A-Z0-9]", "", value.upper())


def normalize_name(value: str | None) -> str:
    if not value:
        return ""
    words = re.sub(r"[^A-Z0-9 ]", " ", value.upper()).split()
    return " ".join(word for word in words if word not in LEGAL_SUFFIXES)


def duplicate_level(score: int, critical: bool = False, high: int = 70, medium: int = 40) -> str:
    if critical:
        return "Critical"
    if score >= high:
        return "High"
    if score >= medium:
        return "Medium"
    return "Low"


def duplicate_score(signals: set[str], weights: dict[str, int]) -> tuple[int, str]:
    critical = bool(signals & {"DUP_EXACT_TAX", "DUP_SAME_BANK"})
    score = 100 if critical else min(100, sum(weights.get(signal, 0) for signal in signals))
    return score, duplicate_level(score, critical)


def risk_score(factors: set[str], weights: dict[str, int], high: int = 70, medium: int = 35) -> tuple[int, str]:
    score = min(100, sum(weights.get(factor, 0) for factor in factors))
    level = "High" if score >= high else "Medium" if score >= medium else "Low"
    return score, level


@dataclass(frozen=True)
class SubmissionResult:
    status: str
    history: tuple[str, ...]
    accepted: bool


def submit(status: str, has_blocker: bool) -> SubmissionResult:
    if status not in {"Draft", "Correction Requested"}:
        raise ValueError("invalid status transition")
    if has_blocker:
        return SubmissionResult(status, (), False)
    return SubmissionResult("Under Review", ("Submitted", "Under Review"), True)


def requester_projection(value: Any) -> Any:
    if isinstance(value, dict):
        return {
            key: requester_projection(item)
            for key, item in value.items()
            if key.replace("_", "").lower() not in REQUESTER_FORBIDDEN_KEYS
        }
    if isinstance(value, list):
        return [requester_projection(item) for item in value]
    return copy.deepcopy(value)


def append_retry(log: dict[str, Any], entry: dict[str, Any]) -> dict[str, Any]:
    updated = copy.deepcopy(log)
    history = list(updated.get("retryHistory", []))
    immutable_entry = copy.deepcopy(entry)
    immutable_entry["attemptNumber"] = len(history) + 1
    history.append(immutable_entry)
    updated["retryHistory"] = history
    updated["retryCount"] = len(history)
    return updated


def money(value: str | int | Decimal) -> Decimal:
    amount = Decimal(value)
    if amount < 0:
        raise ValueError("expected annual spend cannot be negative")
    return amount.quantize(Decimal("0.01"))
