from __future__ import annotations

import string

from hypothesis import strategies as st

safe_text = st.text(alphabet=string.ascii_letters + string.digits + " -", min_size=1, max_size=80)
address_line = st.text(
    alphabet=string.ascii_letters + string.digits + " -", min_size=0, max_size=21
)
country_code = st.sampled_from(["PK", "AE", "US", "AF", "IR"])
last_four = st.text(alphabet=string.digits, min_size=4, max_size=4)


@st.composite
def structured_address(draw: st.DrawFn) -> dict[str, str]:
    return {
        "addressLine1": draw(address_line),
        "addressLine2": draw(address_line),
        "city": draw(safe_text),
        "region": draw(safe_text),
        "countryCode": draw(country_code),
    }
