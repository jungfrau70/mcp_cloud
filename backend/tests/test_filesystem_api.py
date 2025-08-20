#!/usr/bin/env python3
"""
파일 시스템 API 테스트 스크립트
"""

import requests
import json
import time

# API 설정
BASE_URL = "http://localhost:8000"
API_KEY = "my_mcp_eagle_tiger"
HEADERS = {
    "Content-Type": "application/json",
    "X-API-Key": API_KEY
}

def test_filesystem_apis():
    """파일 시스템 API들을 테스트합니다."""
    
    print("=== 파일 시스템 API 테스트 시작 ===\n")
    
    # 1. 디렉토리 구조 조회
    print("1. 디렉토리 구조 조회...")
    try:
        response = requests.get(f"{BASE_URL}/api/v1/knowledge/filesystem/structure", headers={"X-API-Key": API_KEY})
        if response.status_code == 200:
            data = response.json()
            print(f"✅ 성공: {data['message']}")
            print(f"   현재 경로: {data['path']}")
            print(f"   항목 수: {len(data['children'])}")
        else:
            print(f"❌ 실패: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"❌ 오류: {e}")
    
    print()
    
    # 2. 새 디렉토리 생성
    print("2. 새 디렉토리 생성...")
    try:
        create_dir_data = {
            "path": "test_directory",
            "refresh_vector": False
        }
        response = requests.post(f"{BASE_URL}/api/v1/knowledge/filesystem/directory", 
                               headers=HEADERS, 
                               json=create_dir_data)
        if response.status_code == 200:
            data = response.json()
            print(f"✅ 성공: {data['message']}")
            print(f"   생성된 경로: {data['path']}")
        else:
            print(f"❌ 실패: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"❌ 오류: {e}")
    
    print()
    
    # 3. 새 파일 생성
    print("3. 새 파일 생성...")
    try:
        create_file_data = {
            "path": "test_directory/test_file.md",
            "content": "# 테스트 파일\n\n이것은 테스트 파일입니다.",
            "refresh_vector": False
        }
        response = requests.post(f"{BASE_URL}/api/v1/knowledge/docs", 
                               headers=HEADERS, 
                               json=create_file_data)
        if response.status_code == 200:
            data = response.json()
            print(f"✅ 성공: {data['message']}")
            print(f"   생성된 파일: {data['path']}")
        else:
            print(f"❌ 실패: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"❌ 오류: {e}")
    
    print()
    
    # 4. 파일 검색
    print("4. 파일 검색...")
    try:
        response = requests.get(f"{BASE_URL}/api/v1/knowledge/filesystem/search?query=test", 
                              headers={"X-API-Key": API_KEY})
        if response.status_code == 200:
            data = response.json()
            print(f"✅ 성공: {data['message']}")
            if data['children']:
                for item in data['children']:
                    print(f"   - {item['name']} ({item['path']})")
            else:
                print("   검색 결과 없음")
        else:
            print(f"❌ 실패: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"❌ 오류: {e}")
    
    print()
    
    # 5. 파일 이동
    print("5. 파일 이동...")
    try:
        move_data = {
            "source_path": "test_directory/test_file.md",
            "target_path": "test_file_moved.md",
            "refresh_vector": False
        }
        response = requests.post(f"{BASE_URL}/api/v1/knowledge/filesystem/move", 
                               headers=HEADERS, 
                               json=move_data)
        if response.status_code == 200:
            data = response.json()
            print(f"✅ 성공: {data['message']}")
            print(f"   이동된 경로: {data['path']}")
        else:
            print(f"❌ 실패: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"❌ 오류: {e}")
    
    print()
    
    # 6. 업데이트된 디렉토리 구조 조회
    print("6. 업데이트된 디렉토리 구조 조회...")
    try:
        response = requests.get(f"{BASE_URL}/api/v1/knowledge/filesystem/structure", headers={"X-API-Key": API_KEY})
        if response.status_code == 200:
            data = response.json()
            print(f"✅ 성공: {data['message']}")
            print(f"   현재 경로: {data['path']}")
            print(f"   항목 수: {len(data['children'])}")
            for item in data['children']:
                print(f"   - {item['name']} ({item['type']})")
        else:
            print(f"❌ 실패: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"❌ 오류: {e}")
    
    print()
    
    # 7. 정리: 파일 삭제
    print("7. 테스트 파일 삭제...")
    try:
        delete_file_data = {
            "path": "test_file_moved.md",
            "refresh_vector": False
        }
        response = requests.delete(f"{BASE_URL}/api/v1/knowledge/docs", 
                                 headers=HEADERS, 
                                 json=delete_file_data)
        if response.status_code == 200:
            data = response.json()
            print(f"✅ 성공: {data['message']}")
        else:
            print(f"❌ 실패: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"❌ 오류: {e}")
    
    print()
    
    # 8. 정리: 디렉토리 삭제
    print("8. 테스트 디렉토리 삭제...")
    try:
        delete_dir_data = {
            "path": "test_directory",
            "refresh_vector": False
        }
        response = requests.delete(f"{BASE_URL}/api/v1/knowledge/filesystem/directory", 
                                 headers=HEADERS, 
                                 json=delete_dir_data)
        if response.status_code == 200:
            data = response.json()
            print(f"✅ 성공: {data['message']}")
        else:
            print(f"❌ 실패: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"❌ 오류: {e}")
    
    print("\n=== 파일 시스템 API 테스트 완료 ===")

if __name__ == "__main__":
    test_filesystem_apis()
