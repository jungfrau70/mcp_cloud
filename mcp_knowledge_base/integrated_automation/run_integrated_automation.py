#!/usr/bin/env python3
"""
통합 자동화 실행 스크립트
"""

import sys
import os
from pathlib import Path

# 현재 디렉토리를 Python 경로에 추가
current_dir = Path(__file__).parent
sys.path.insert(0, str(current_dir))

from integrated_course_automation import main

if __name__ == "__main__":
    main()
