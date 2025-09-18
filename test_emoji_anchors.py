#!/usr/bin/env python3
"""
이모지 포함 앵커 링크 테스트 도구
VS Code 마크다운 미리보기에서 이모지가 포함된 헤딩의 실제 앵커 ID를 확인합니다.
"""

import re

def test_vscode_anchor_generation():
    """VS Code 마크다운 미리보기 앵커 ID 생성 테스트"""
    
    # 테스트할 헤딩들
    test_headings = [
        "🎯 학습 목표",
        "🔧 실습 환경 준비", 
        "✅ 실습 환경 확인",
        "📚 이론 학습",
        "🛠️ 실습 학습",
        "🧹 실습 정리"
    ]
    
    print("🔍 VS Code 마크다운 미리보기 앵커 ID 생성 테스트")
    print("=" * 60)
    
    for heading in test_headings:
        # VS Code 방식 1: 이모지 제거
        anchor_v1 = heading.replace('🎯', '').replace('🔧', '').replace('✅', '').replace('📚', '').replace('🛠️', '').replace('🧹', '')
        anchor_v1 = re.sub(r'\s+', '-', anchor_v1.strip()).lower()
        
        # VS Code 방식 2: 특수문자만 제거 (이모지 유지)
        anchor_v2 = re.sub(r'[^\w\s가-힣🎯🔧✅📚🛠️🧹]', '', heading)
        anchor_v2 = re.sub(r'\s+', '-', anchor_v2.strip()).lower()
        
        # VS Code 방식 3: 공백만 하이픈으로 변환 (이모지 유지)
        anchor_v3 = re.sub(r'\s+', '-', heading.strip()).lower()
        
        print(f"헤딩: {heading}")
        print(f"  방식1 (이모지 제거): #{anchor_v1}")
        print(f"  방식2 (특수문자 제거): #{anchor_v2}")
        print(f"  방식3 (공백만 변환): #{anchor_v3}")
        print()

def test_actual_vscode_behavior():
    """실제 VS Code 동작 테스트"""
    print("🧪 실제 VS Code 마크다운 미리보기 동작 테스트")
    print("=" * 60)
    
    # 실제 마크다운 파일에서 헤딩 추출
    test_markdown = """
## 🎯 학습 목표
## 🔧 실습 환경 준비
## ✅ 실습 환경 확인
## 📚 이론 학습
## 🛠️ 실습 학습
## 🧹 실습 정리
"""
    
    # VS Code가 실제로 생성하는 앵커 ID (이모지 유지)
    headings = re.findall(r'^## (.+)$', test_markdown, re.MULTILINE)
    
    for heading in headings:
        # VS Code 실제 동작: 이모지 유지, 공백을 하이픈으로 변환
        anchor = re.sub(r'\s+', '-', heading.strip()).lower()
        print(f"헤딩: {heading}")
        print(f"예상 앵커: #{anchor}")
        print()

if __name__ == "__main__":
    test_vscode_anchor_generation()
    test_actual_vscode_behavior()
