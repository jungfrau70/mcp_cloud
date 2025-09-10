import json
import re
import logging
from typing import Any, Dict

logger = logging.getLogger(__name__)

JSON_BLOCK_RE = re.compile(r"```json\s*(\{[\s\S]*?\})\s*```", re.IGNORECASE)
LONE_JSON_RE = re.compile(r"\{[\s\S]*\}")

def parse_llm_json(response_text: str) -> Dict[str, Any]:
    """Extract JSON from an LLM response robustly.
    Priority: fenced ```json blocks → any JSON-looking block.
    Returns a dict with 'error' key on failure.
    """
    try:
        if not response_text or not response_text.strip():
            raise ValueError("빈 응답")
        m = JSON_BLOCK_RE.search(response_text)
        if m:
            return json.loads(m.group(1))
        m = LONE_JSON_RE.search(response_text)
        if m:
            return json.loads(m.group(0))
        raise ValueError("응답에서 JSON을 찾지 못했습니다.")
    except Exception as e:
        logger.error("JSON 파싱 실패: %s", e)
        return {"error": f"JSON 파싱 실패: {e}"}
