#!/usr/bin/env python3
"""
사용자 시나리오별 테스트 실행 스크립트

이 스크립트는 MCP AI Agent 시스템의 사용자 시나리오별 테스트를 실행합니다.
"""

import os
import sys
import subprocess
import time
import argparse
from pathlib import Path

def check_dependencies():
    """필요한 의존성 확인"""
    print("🔍 의존성 확인 중...")
    
    # Python 버전 확인
    if sys.version_info < (3, 8):
        print("❌ Python 3.8 이상이 필요합니다.")
        return False
    
    # pytest 확인
    try:
        import pytest
        print(f"✅ pytest {pytest.__version__} 설치됨")
    except ImportError:
        print("❌ pytest가 설치되지 않았습니다. 'pip install pytest'를 실행하세요.")
        return False
    
    # requests 확인
    try:
        import requests
        print(f"✅ requests {requests.__version__} 설치됨")
    except ImportError:
        print("❌ requests가 설치되지 않았습니다. 'pip install requests'를 실행하세요.")
        return False
    
    return True

def check_backend_service():
    """백엔드 서비스 상태 확인"""
    print("🔍 백엔드 서비스 상태 확인 중...")
    
    try:
        import requests
        response = requests.get("http://localhost:8000/docs", timeout=5)
        if response.status_code == 200:
            print("✅ 백엔드 서비스가 실행 중입니다.")
            return True
    except:
        pass
    
    print("❌ 백엔드 서비스가 실행되지 않았습니다.")
    print("💡 'docker-compose up -d'를 실행하여 서비스를 시작하세요.")
    return False

def run_mock_tests():
    """Mock 기반 테스트 실행"""
    print("\n🧪 Mock 기반 테스트 실행 중...")
    
    test_file = "tests/test_complete_mock.py"
    if not Path(test_file).exists():
        print(f"❌ 테스트 파일을 찾을 수 없습니다: {test_file}")
        return False
    
    try:
        result = subprocess.run([
            sys.executable, "-m", "pytest", test_file, "-v", "--tb=short"
        ], capture_output=True, text=True, timeout=600)
        
        if result.returncode == 0:
            print("✅ Mock 기반 테스트가 성공적으로 완료되었습니다.")
            return True
        else:
            print("❌ Mock 기반 테스트가 실패했습니다.")
            print(result.stdout)
            print(result.stderr)
            return False
            
    except subprocess.TimeoutExpired:
        print("❌ Mock 기반 테스트 실행 시간 초과")
        return False
    except Exception as e:
        print(f"❌ Mock 기반 테스트 실행 중 오류 발생: {e}")
        return False

def run_unit_tests():
    """기존 단위 테스트 실행"""
    print("\n🧪 기존 단위 테스트 실행 중...")
    
    test_file = "tests/test_ai_agent.py"
    if not Path(test_file).exists():
        print(f"❌ 테스트 파일을 찾을 수 없습니다: {test_file}")
        return False
    
    try:
        result = subprocess.run([
            sys.executable, "-m", "pytest", test_file, "-v", "--tb=short"
        ], capture_output=True, text=True, timeout=300)
        
        if result.returncode == 0:
            print("✅ 기존 단위 테스트가 성공적으로 완료되었습니다.")
            return True
        else:
            print("❌ 기존 단위 테스트가 실패했습니다.")
            print(result.stdout)
            print(result.stderr)
            return False
            
    except subprocess.TimeoutExpired:
        print("❌ 기존 단위 테스트 실행 시간 초과")
        return False
    except Exception as e:
        print(f"❌ 기존 단위 테스트 실행 중 오류 발생: {e}")
        return False

def run_user_scenario_tests():
    """사용자 시나리오 테스트 실행"""
    print("\n🎭 사용자 시나리오 테스트 실행 중...")
    
    test_file = "tests/test_user_scenarios.py"
    if not Path(test_file).exists():
        print(f"❌ 테스트 파일을 찾을 수 없습니다: {test_file}")
        return False
    
    try:
        result = subprocess.run([
            sys.executable, "-m", "pytest", test_file, "-v", "--tb=short"
        ], capture_output=True, text=True, timeout=600)
        
        if result.returncode == 0:
            print("✅ 사용자 시나리오 테스트가 성공적으로 완료되었습니다.")
            return True
        else:
            print("❌ 사용자 시나리오 테스트가 실패했습니다.")
            print(result.stdout)
            print(result.stderr)
            return False
            
    except subprocess.TimeoutExpired:
        print("❌ 사용자 시나리오 테스트 실행 시간 초과")
        return False
    except Exception as e:
        print(f"❌ 사용자 시나리오 테스트 실행 중 오류 발생: {e}")
        return False

def run_api_integration_tests():
    """API 통합 테스트 실행"""
    print("\n🔗 API 통합 테스트 실행 중...")
    
    test_file = "tests/test_api_integration.py"
    if not Path(test_file).exists():
        print(f"❌ 테스트 파일을 찾을 수 없습니다: {test_file}")
        return False
    
    try:
        result = subprocess.run([
            sys.executable, "-m", "pytest", test_file, "-v", "--tb=short"
        ], capture_output=True, text=True, timeout=900)
        
        if result.returncode == 0:
            print("✅ API 통합 테스트가 성공적으로 완료되었습니다.")
            return True
        else:
            print("❌ API 통합 테스트가 실패했습니다.")
            print(result.stdout)
            print(result.stderr)
            return False
            
    except subprocess.TimeoutExpired:
        print("❌ API 통합 테스트 실행 시간 초과")
        return False
    except Exception as e:
        print(f"❌ API 통합 테스트 실행 중 오류 발생: {e}")
        return False

def run_specific_scenario(scenario_number):
    """특정 시나리오 테스트 실행"""
    print(f"\n🎯 시나리오 {scenario_number} 테스트 실행 중...")
    
    test_file = "tests/test_api_integration.py"
    if not Path(test_file).exists():
        print(f"❌ 테스트 파일을 찾을 수 없습니다: {test_file}")
        return False
    
    try:
        # 특정 시나리오 테스트만 실행
        test_name = f"test_scenario{scenario_number}"
        result = subprocess.run([
            sys.executable, "-m", "pytest", test_file, f"::TestUserScenarioAPIIntegration::{test_name}", "-v", "--tb=short"
        ], capture_output=True, text=True, timeout=300)
        
        if result.returncode == 0:
            print(f"✅ 시나리오 {scenario_number} 테스트가 성공적으로 완료되었습니다.")
            return True
        else:
            print(f"❌ 시나리오 {scenario_number} 테스트가 실패했습니다.")
            print(result.stdout)
            print(result.stderr)
            return False
            
    except subprocess.TimeoutExpired:
        print(f"❌ 시나리오 {scenario_number} 테스트 실행 시간 초과")
        return False
    except Exception as e:
        print(f"❌ 시나리오 {scenario_number} 테스트 실행 중 오류 발생: {e}")
        return False

def run_performance_tests():
    """성능 테스트 실행"""
    print("\n⚡ 성능 테스트 실행 중...")
    
    test_file = "tests/test_api_integration.py"
    if not Path(test_file).exists():
        print(f"❌ 테스트 파일을 찾을 수 없습니다: {test_file}")
        return False
    
    try:
        result = subprocess.run([
            sys.executable, "-m", "pytest", test_file, "::TestAPIPerformance", "-v", "--tb=short"
        ], capture_output=True, text=True, timeout=300)
        
        if result.returncode == 0:
            print("✅ 성능 테스트가 성공적으로 완료되었습니다.")
            return True
        else:
            print("❌ 성능 테스트가 실패했습니다.")
            print(result.stdout)
            print(result.stderr)
            return False
            
    except subprocess.TimeoutExpired:
        print("❌ 성능 테스트 실행 시간 초과")
        return False
    except Exception as e:
        print(f"❌ 성능 테스트 실행 중 오류 발생: {e}")
        return False

def print_test_summary(results):
    """테스트 결과 요약 출력"""
    print("\n" + "="*60)
    print("📊 테스트 결과 요약")
    print("="*60)
    
    total_tests = len(results)
    passed_tests = sum(1 for result in results.values() if result)
    failed_tests = total_tests - passed_tests
    
    print(f"총 테스트: {total_tests}")
    print(f"성공: {passed_tests} ✅")
    print(f"실패: {failed_tests} ❌")
    
    if failed_tests == 0:
        print("\n🎉 모든 테스트가 성공적으로 완료되었습니다!")
    else:
        print(f"\n⚠️  {failed_tests}개의 테스트가 실패했습니다.")
        for test_name, result in results.items():
            if not result:
                print(f"  - {test_name}: 실패 ❌")
    
    print("="*60)

def main():
    """메인 함수"""
    parser = argparse.ArgumentParser(description="MCP AI Agent 사용자 시나리오 테스트 실행")
    parser.add_argument("--scenario", type=int, choices=[1, 2, 3, 4, 5], 
                       help="특정 시나리오만 테스트 (1-5)")
    parser.add_argument("--unit-only", action="store_true", 
                       help="단위 테스트만 실행")
    parser.add_argument("--api-only", action="store_true", 
                       help="API 통합 테스트만 실행")
    parser.add_argument("--performance", action="store_true", 
                       help="성능 테스트만 실행")
    parser.add_argument("--skip-backend-check", action="store_true", 
                       help="백엔드 서비스 상태 확인 건너뛰기")
    
    args = parser.parse_args()
    
    print("🚀 MCP AI Agent 사용자 시나리오 테스트 시작")
    print("="*60)
    
    # 의존성 확인
    if not check_dependencies():
        sys.exit(1)
    
    # 백엔드 서비스 상태 확인 (건너뛰기 옵션이 아닌 경우)
    if not args.skip_backend_check and not check_backend_service():
        print("\n💡 백엔드 서비스를 시작한 후 다시 시도하세요:")
        print("   docker-compose up -d")
        sys.exit(1)
    
    results = {}
    
    try:
        if args.scenario:
            # 특정 시나리오만 테스트
            results[f"시나리오 {args.scenario}"] = run_specific_scenario(args.scenario)
        elif args.unit_only:
            # Mock 기반 테스트만 실행
            results["Mock 기반 테스트"] = run_mock_tests()
        elif args.api_only:
            # API 통합 테스트만 실행
            results["API 통합 테스트"] = run_api_integration_tests()
        elif args.performance:
            # 성능 테스트만 실행
            results["성능 테스트"] = run_performance_tests()
        else:
            # 전체 테스트 실행
            results["Mock 기반 테스트"] = run_mock_tests()
            results["기존 단위 테스트"] = run_unit_tests()
            results["사용자 시나리오 테스트"] = run_user_scenario_tests()
            results["API 통합 테스트"] = run_api_integration_tests()
            results["성능 테스트"] = run_performance_tests()
        
        # 결과 요약 출력
        print_test_summary(results)
        
        # 종료 코드 결정
        if all(results.values()):
            sys.exit(0)
        else:
            sys.exit(1)
            
    except KeyboardInterrupt:
        print("\n\n⚠️  테스트가 사용자에 의해 중단되었습니다.")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ 테스트 실행 중 예상치 못한 오류가 발생했습니다: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
