#!/usr/bin/env python3
import requests
import json
from pathlib import Path

# API 설정
api_base = "http://localhost:8000"
api_key = "my_mcp_eagle_tiger"
headers = {"X-API-Key": api_key}

print("Testing Curriculum API...")

# 1. 커리큘럼 트리 API 테스트
print("\n1. Testing curriculum tree API...")
try:
    response = requests.get(
        f"{api_base}/api/v1/curriculum/tree",
        params={"show_hidden": True},
        headers=headers
    )
    
    print(f"Tree API status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Tree API response keys: {list(data.keys()) if isinstance(data, dict) else 'Not a dict'}")
        print(f"Tree API response: {json.dumps(data, ensure_ascii=False, indent=2)[:500]}...")
    else:
        print(f"Tree API error: {response.text}")
        
except Exception as e:
    print(f"Tree API request failed: {e}")

# 2. 커리큘럼 아이템 API 테스트
print("\n2. Testing curriculum item API...")
test_path = "cloud_master/textbook/Day1/README.md"
try:
    response = requests.get(
        f"{api_base}/api/v1/curriculum/item",
        params={"path": test_path},
        headers=headers
    )
    
    print(f"Item API status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Item API response: {json.dumps(data, ensure_ascii=False, indent=2)[:200]}...")
    else:
        print(f"Item API error: {response.text}")
        
except Exception as e:
    print(f"Item API request failed: {e}")

# 3. 파일 존재 확인
print("\n3. Checking file existence...")
kb_root = Path("mcp_knowledge_base")
test_file = kb_root / test_path
print(f"Test file path: {test_file}")
print(f"File exists: {test_file.exists()}")
if test_file.exists():
    print(f"File size: {test_file.stat().st_size} bytes")
