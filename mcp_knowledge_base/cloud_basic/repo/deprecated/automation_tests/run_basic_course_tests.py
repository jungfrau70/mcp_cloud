#!/usr/bin/env python3
"""
Basic 과정 자동화 테스트 실행기
"""

import subprocess
import sys
from pathlib import Path

def run_tests():
    """테스트 실행"""
    print("Basic 과정 자동화 테스트 시작...")
    
    try:
        # pytest 실행
        result = subprocess.run([
            sys.executable, "-m", "pytest", 
            "test_basic_course_automation.py",
            "-v", "--tb=short"
        ], capture_output=True, text=True)
        
        print("테스트 결과:")
        print(result.stdout)
        
        if result.stderr:
            print("오류:")
            print(result.stderr)
        
        if result.returncode == 0:
            print("\n모든 테스트가 성공적으로 완료되었습니다!")
        else:
            print(f"\n테스트 실패: {result.returncode}")
            
    except Exception as e:
        print(f"테스트 실행 중 오류 발생: {e}")

if __name__ == "__main__":
    run_tests()
