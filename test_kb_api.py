#!/usr/bin/env python3
import requests
import json
from pathlib import Path

# API 설정
api_base = "http://localhost:8000"
api_key = "my_mcp_eagle_tiger"
headers = {"X-API-Key": api_key}

# 테스트할 파일 경로
test_path = "cloud_basic/과정상세.md"

print(f"Testing KB API with path: {test_path}")
print(f"API URL: {api_base}/api/v1/knowledge-base/item?path={test_path}")

# 파일 존재 확인
kb_root = Path("mcp_knowledge_base")
full_path = kb_root / test_path
print(f"Full file path: {full_path}")
print(f"File exists: {full_path.exists()}")
print(f"File size: {full_path.stat().st_size if full_path.exists() else 'N/A'} bytes")

# API 호출
try:
    response = requests.get(
        f"{api_base}/api/v1/knowledge-base/item",
        params={"path": test_path},
        headers=headers
    )
    
    print(f"\nResponse status: {response.status_code}")
    print(f"Response headers: {dict(response.headers)}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"Response data: {json.dumps(data, ensure_ascii=False, indent=2)}")
    else:
        print(f"Error response: {response.text}")
        
except Exception as e:
    print(f"Request failed: {e}")
