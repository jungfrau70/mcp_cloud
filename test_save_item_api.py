#!/usr/bin/env python3
import requests
import json

# API 설정
api_base = "http://localhost:8000"
api_key = "my_mcp_eagle_tiger"
headers = {"X-API-Key": api_key, "Content-Type": "application/json"}

print("Testing Knowledge Base Save Item API...")

# 테스트할 파일 경로와 내용
test_path = "cloud_master/과정명.md"
test_content = """# 테스트 파일

이것은 테스트 내용입니다.

## 테스트 섹션

- 항목 1
- 항목 2
- 항목 3
"""

print(f"Testing save item with path: {test_path}")

try:
    response = requests.put(
        f"{api_base}/api/v1/knowledge-base/item",
        headers=headers,
        json={
            "path": test_path,
            "content": test_content,
            "message": "테스트 저장"
        }
    )
    
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Success: {json.dumps(data, ensure_ascii=False, indent=2)}")
    else:
        print(f"Error: {response.text}")
        
except Exception as e:
    print(f"Request failed: {e}")

# 저장된 파일 확인
print(f"\nVerifying saved file...")
try:
    response = requests.get(
        f"{api_base}/api/v1/knowledge-base/item",
        params={"path": test_path},
        headers={"X-API-Key": api_key}
    )
    
    print(f"Get status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"File content length: {len(data.get('content', ''))}")
        print(f"File content preview: {data.get('content', '')[:100]}...")
    else:
        print(f"Get error: {response.text}")
        
except Exception as e:
    print(f"Get request failed: {e}")
