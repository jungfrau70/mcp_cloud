import pytest
from utils.json_utils import parse_llm_json


@pytest.mark.unit
@pytest.mark.parametrize(
    "text,expected,error",
    [
        ("Some intro\n```json\n{\n  \"key\": \"value\"\n}\n```\nMore text", {"key": "value"}, False),
        ("Random preface {\n  \"a\": 1, \n  \"b\": 2\n} trailing words", {"a": 1, "b": 2}, False),
        ("", None, True),
        ("There is no json here", None, True),
        ("```json { invalid json } ```", None, True),
    ],
)
def test_parse_llm_json_cases(text, expected, error):
    parsed = parse_llm_json(text)
    if error:
        assert "error" in parsed
    else:
        for k, v in expected.items():
            assert parsed.get(k) == v
