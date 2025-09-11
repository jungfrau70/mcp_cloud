#!/usr/bin/env python3
import requests
import json

# API 설정
api_base = "http://localhost:8000"
api_key = "my_mcp_eagle_tiger"
headers = {"X-API-Key": api_key}

print("Testing Knowledge Base Tree API...")

try:
    response = requests.get(
        f"{api_base}/api/v1/knowledge-base/tree",
        params={"show_hidden": True},
        headers=headers
    )
    
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Response keys: {list(data.keys()) if isinstance(data, dict) else 'Not a dict'}")
        print(f"Response structure:")
        print(json.dumps(data, ensure_ascii=False, indent=2)[:1000] + "...")
    else:
        print(f"Error: {response.text}")
        
except Exception as e:
    print(f"Request failed: {e}")
