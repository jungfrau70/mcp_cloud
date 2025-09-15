#!/usr/bin/env python3
"""
자동화 설정 파일 테스트 스크립트
의존성 없이 설정 파일 로드만 테스트
"""

import json
import sys
from pathlib import Path

def test_automation_config():
    """자동화 설정 파일 테스트"""
    print("🧪 자동화 설정 파일 테스트 시작...")
    
    # 설정 파일 경로
    config_path = Path("mcp_knowledge_base/shared_configs/automation_config.json")
    
    try:
        # JSON 파일 로드 테스트
        with open(config_path, 'r', encoding='utf-8') as f:
            config = json.load(f)
        
        print("✅ 설정 파일 로드 성공")
        
        # 기본 구조 검증
        required_sections = ['version', 'automation', 'cloud_providers', 'courses']
        for section in required_sections:
            if section in config:
                print(f"✅ {section} 섹션 존재")
            else:
                print(f"❌ {section} 섹션 누락")
                return False
        
        # 자동화 설정 검증
        automation = config.get('automation', {})
        required_automation = ['base_directory', 'results_directory', 'logs_directory', 'project_prefix']
        for key in required_automation:
            if key in automation:
                print(f"✅ automation.{key}: {automation[key]}")
            else:
                print(f"❌ automation.{key} 누락")
                return False
        
        # 클라우드 프로바이더 검증
        providers = config.get('cloud_providers', {})
        for provider in ['aws', 'gcp']:
            if provider in providers:
                print(f"✅ {provider} 설정 존재")
            else:
                print(f"❌ {provider} 설정 누락")
                return False
        
        # 과정 설정 검증
        courses = config.get('courses', {})
        course_list = ['cloud_basic', 'cloud_master', 'cloud_container']
        for course in course_list:
            if course in courses:
                course_config = courses[course]
                print(f"✅ {course} 과정 설정 존재")
                print(f"   - 활성화: {course_config.get('enabled', False)}")
                print(f"   - 경로: {course_config.get('path', 'N/A')}")
                print(f"   - 일차: {course_config.get('days', 0)}")
            else:
                print(f"❌ {course} 과정 설정 누락")
                return False
        
        print("\n🎉 모든 테스트 통과!")
        return True
        
    except FileNotFoundError:
        print(f"❌ 설정 파일을 찾을 수 없습니다: {config_path}")
        return False
    except json.JSONDecodeError as e:
        print(f"❌ JSON 파싱 오류: {e}")
        return False
    except Exception as e:
        print(f"❌ 예상치 못한 오류: {e}")
        return False

def test_script_config_loading():
    """자동화 스크립트의 설정 로드 테스트"""
    print("\n🔍 자동화 스크립트 설정 로드 테스트...")
    
    # Cloud Basic 스크립트 테스트
    script_path = Path("mcp_knowledge_base/cloud_basic/automation_tests/improved_basic_automation.py")
    if script_path.exists():
        print("✅ Cloud Basic 자동화 스크립트 존재")
        
        # 스크립트 내용에서 설정 파일 경로 확인
        with open(script_path, 'r', encoding='utf-8') as f:
            content = f.read()
            if "automation_config.json" in content:
                print("✅ automation_config.json 참조 확인")
            else:
                print("❌ automation_config.json 참조 누락")
                return False
    else:
        print("❌ Cloud Basic 자동화 스크립트 없음")
        return False
    
    return True

if __name__ == "__main__":
    print("=" * 60)
    print("🚀 자동화 설정 파일 테스트")
    print("=" * 60)
    
    # 테스트 실행
    config_test = test_automation_config()
    script_test = test_script_config_loading()
    
    print("\n" + "=" * 60)
    if config_test and script_test:
        print("🎉 모든 테스트 성공!")
        sys.exit(0)
    else:
        print("❌ 일부 테스트 실패")
        sys.exit(1)
