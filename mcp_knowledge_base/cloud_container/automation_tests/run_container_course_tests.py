#!/usr/bin/env python3
"""
Container 과정 자동화 테스트 실행 스크립트
"""

import subprocess
import sys
from pathlib import Path

def run_tests():
    """테스트 실행"""
    print("Container 과정 자동화 테스트 시작...")
    
    # 테스트 파일 경로
    test_file = Path(__file__).parent / "test_container_course_automation.py"
    
    # pytest 실행
    cmd = [
        sys.executable, "-m", "pytest",
        str(test_file),
        "-v",
        "--tb=short",
        "--color=yes"
    ]
    
    try:
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        print("테스트 결과:")
        print(result.stdout)
        print("모든 테스트가 성공적으로 완료되었습니다!")
        return True
    except subprocess.CalledProcessError as e:
        print("테스트 실패:")
        print(e.stdout)
        print(e.stderr)
        return False

if __name__ == "__main__":
    success = run_tests()
    sys.exit(0 if success else 1)
