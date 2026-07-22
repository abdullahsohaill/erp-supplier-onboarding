from __future__ import annotations

import json

import pytest

from tests.e2e.helpers import create_request
from tests.support.db import execute


@pytest.mark.runtime
def test_us002_targeted_correction_edit_and_resubmit(requester_a) -> None:
    request = create_request(requester_a)
    request_id = request["requestId"]
    envelope = json.dumps(
        {
            "schemaVersion": "1.0",
            "comment": "Clarify the business requirement.",
            "selectedRiskFactorCodes": ["VAGUE_JUSTIFICATION"],
            "correctionItems": [
                {
                    "fieldName": "businessJustification",
                    "reasonCode": "WEAK_JUSTIFICATION",
                    "message": "Provide scope and expected outcome.",
                }
            ],
        }
    ).replace("'", "''")
    source = (
        "update supplier_request set status='Correction Requested' "  # noqa: S608
        f"where request_id={request_id};\n"
        "insert into status_history(request_id,from_status,to_status,action_code,"
        "actor_user,action_comment,action_timestamp) values("
        f"{request_id},'Under Review','Correction Requested','REQUEST_CORRECTION',"
        f"'reviewer_test','{envelope}',systimestamp);\ncommit;"
    )
    execute(  # noqa: S608 - request ID is server-generated and envelope is escaped test data.
        source,
        "reviewer_test",
    )
    patch = requester_a.request(
        "PATCH",
        f"/requests/{request_id}",
        json={
            "businessJustification": (
                "Expanded scope, operating need, ownership, budget, and expected "
                "outcome for the supplier."
            )
        },
    )
    assert patch.status_code == 200, patch.text
    response = requester_a.request("POST", f"/requests/{request_id}/submit")
    assert response.status_code == 200, response.text
    assert response.json()["data"]["status"] == "Under Review"
