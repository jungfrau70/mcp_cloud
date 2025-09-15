#!/usr/bin/env python3
"""
링크 추출 디버깅 도구
"""

import re

def debug_link_extraction():
    """링크 추출 로직을 디버깅합니다."""
    
    # 테스트 케이스
    test_content = """
## 📋 목차
1. [GitHub Actions 소개](#github-actions-소개)
2. [Git 기초 및 GitHub 연동](#git-기초-및-github-연동)
3. [GitHub Actions 기본 개념](#github-actions-기본-개념)
4. [워크플로우 문법 및 구조](#워크플로우-문법-및-구조)
5. [실습 예제](#실습-예제)
6. [고급 기능](#고급-기능)
7. [모범 사례](#모범-사례)
"""
    
    print("🔍 링크 추출 디버깅")
    print("=" * 50)
    
    # 현재 정규식 (문제 있는 버전)
    file_link_pattern = re.compile(r'\[.*?\]\((?!https?://)(.*?)\)|<a\s+href="(?!https?://)(.*?)"')
    
    print("📊 현재 정규식으로 추출된 링크:")
    for match in file_link_pattern.finditer(test_content):
        link_path = match.group(1) or match.group(2)
        if link_path:
            print(f"  - '{link_path}' (길이: {len(link_path)})")
        else:
            print(f"  - 빈 링크 발견!")
    
    print("\n🔧 수정된 정규식으로 추출:")
    
    # 수정된 정규식
    # 1. 빈 링크 제외: `[텍스트]()` 제외
    # 2. 앵커 링크 제외: `[텍스트](#앵커)` 제외
    fixed_file_link_pattern = re.compile(r'\[.*?\]\((?!https?://|#)([^)]+)\)|<a\s+href="(?!https?://|#)([^"]+)"')
    
    for match in fixed_file_link_pattern.finditer(test_content):
        link_path = match.group(1) or match.group(2)
        if link_path:
            print(f"  - '{link_path}' (길이: {len(link_path)})")
        else:
            print(f"  - 빈 링크 발견!")
    
    print("\n📋 앵커 링크만 추출:")
    anchor_link_pattern = re.compile(r'\[.*?\]\(#(.*?)\)|<a\s+href="#(.*?)"')
    
    for match in anchor_link_pattern.finditer(test_content):
        anchor = match.group(1) or match.group(2)
        if anchor:
            print(f"  - '#{anchor}'")

if __name__ == "__main__":
    debug_link_extraction()
