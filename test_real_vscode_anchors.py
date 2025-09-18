#!/usr/bin/env python3
"""
실제 VS Code 마크다운 미리보기 앵커 ID 테스트
"""

import re

def test_vscode_anchor_generation():
    """VS Code 실제 앵커 ID 생성 테스트"""
    
    # 실제 헤딩들
    headings = [
        "🎯 학습 목표",
        "🔧 실습 환경 준비", 
        "✅ 실습 환경 확인",
        "📚 이론 학습",
        "🛠️ 실습 학습",
        "🧹 실습 정리",
        "📚 문제 해결 및 참고 자료",
        "GitHub 저장소 생성 및 연결",
        "방화벽 규칙 설정"
    ]
    
    print("🔍 VS Code 실제 앵커 ID 생성 테스트")
    print("=" * 60)
    
    for heading in headings:
        # VS Code 방식: 이모지 유지, 공백을 하이픈으로 변환, 소문자
        anchor = re.sub(r'\s+', '-', heading.strip()).lower()
        
        print(f"헤딩: {heading}")
        print(f"VS Code 앵커: #{anchor}")
        print()

def test_anchor_matching():
    """앵커 매칭 테스트"""
    
    print("\n🔗 앵커 매칭 테스트")
    print("=" * 60)
    
    # 실제 헤딩과 현재 사용 중인 앵커 링크
    test_cases = [
        ("🎯 학습 목표", "#-학습-목표", "#🎯-학습-목표"),
        ("🔧 실습 환경 준비", "#-실습-환경-준비", "#🔧-실습-환경-준비"),
        ("✅ 실습 환경 확인", "#-실습-환경-확인", "#✅-실습-환경-확인"),
        ("📚 이론 학습", "#-이론-학습", "#📚-이론-학습"),
        ("🛠️ 실습 학습", "#-실습-학습", "#🛠️-실습-학습"),
        ("🧹 실습 정리", "#-실습-정리", "#🧹-실습-정리"),
    ]
    
    for heading, current_anchor, expected_anchor in test_cases:
        # VS Code가 실제로 생성하는 앵커 ID
        vscode_anchor = re.sub(r'\s+', '-', heading.strip()).lower()
        
        print(f"헤딩: {heading}")
        print(f"  VS Code 앵커: #{vscode_anchor}")
        print(f"  현재 앵커: {current_anchor}")
        print(f"  예상 앵커: {expected_anchor}")
        print(f"  매칭: {'✅' if f'#{vscode_anchor}' == expected_anchor else '❌'}")
        print()

if __name__ == "__main__":
    test_vscode_anchor_generation()
    test_anchor_matching()
