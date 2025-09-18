#!/usr/bin/env python3
"""
VS Code 마크다운 미리보기 앵커 ID 생성 방식 분석
실제 VS Code가 어떻게 앵커 ID를 생성하는지 분석합니다.
"""

import re

def analyze_vscode_anchor_generation():
    """VS Code 앵커 ID 생성 방식 분석"""
    
    # 테스트할 헤딩들
    test_headings = [
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
    
    print("🔍 VS Code 마크다운 미리보기 앵커 ID 생성 방식 분석")
    print("=" * 70)
    
    for heading in test_headings:
        print(f"\n헤딩: {heading}")
        
        # 방식 1: 이모지 완전 제거
        anchor1 = heading
        # 이모지 제거
        emoji_pattern = re.compile(
            "["
            "\U0001F600-\U0001F64F"  # emoticons
            "\U0001F300-\U0001F5FF"  # symbols & pictographs
            "\U0001F680-\U0001F6FF"  # transport & map symbols
            "\U0001F1E0-\U0001F1FF"  # flags (iOS)
            "\U00002702-\U000027B0"
            "\U000024C2-\U0001F251"
            "]+", flags=re.UNICODE
        )
        anchor1 = emoji_pattern.sub('', anchor1)
        anchor1 = re.sub(r'\s+', '-', anchor1.strip())
        anchor1 = re.sub(r'-+', '-', anchor1)
        anchor1 = anchor1.strip('-').lower()
        
        # 방식 2: 이모지 유지, 공백만 하이픈
        anchor2 = re.sub(r'\s+', '-', heading.strip()).lower()
        
        # 방식 3: 이모지 제거 후 앞에 하이픈 추가
        anchor3 = emoji_pattern.sub('', heading)
        anchor3 = re.sub(r'\s+', '-', anchor3.strip())
        anchor3 = re.sub(r'-+', '-', anchor3)
        anchor3 = anchor3.strip('-').lower()
        if anchor3:
            anchor3 = f"-{anchor3}"
        
        # 방식 4: 이모지 제거 후 앞에 하이픈 추가 (빈 문자열 처리)
        anchor4 = emoji_pattern.sub('', heading)
        anchor4 = re.sub(r'\s+', '-', anchor4.strip())
        anchor4 = re.sub(r'-+', '-', anchor4)
        anchor4 = anchor4.strip('-').lower()
        if not anchor4:  # 빈 문자열인 경우
            anchor4 = "-"
        else:
            anchor4 = f"-{anchor4}"
        
        print(f"  방식1 (이모지 제거): #{anchor1}")
        print(f"  방식2 (이모지 유지): #{anchor2}")
        print(f"  방식3 (이모지 제거 + 하이픈): #{anchor3}")
        print(f"  방식4 (빈 문자열 처리): #{anchor4}")

def test_actual_anchors():
    """실제 파일에서 발견된 앵커 ID 패턴 분석"""
    
    print("\n\n🔍 실제 파일에서 발견된 앵커 ID 패턴 분석")
    print("=" * 70)
    
    # 검증 결과에서 발견된 실제 앵커 ID들
    actual_anchors = [
        "#🎯-학습-목표",
        "#🔧-실습-환경-준비", 
        "#✅-실습-환경-확인",
        "#📚-이론-학습",
        "#🛠️-실습-학습",
        "#🧹-실습-정리",
        "#📚-문제-해결-및-참고-자료",
        "#-github-저장소-생성-및-연결",
        "#-방화벽-규칙-설정"
    ]
    
    for anchor in actual_anchors:
        print(f"실제 앵커: {anchor}")
        
        # 이 앵커가 어떤 헤딩에서 생성되었는지 추론
        if anchor.startswith("#-"):
            # 이모지가 제거된 경우
            text_part = anchor[2:]  # "#-" 제거
            print(f"  → 이모지 제거 후 생성된 앵커")
            print(f"  → 원본 텍스트: [이모지] {text_part.replace('-', ' ')}")
        else:
            # 이모지가 유지된 경우
            text_part = anchor[1:]  # "#" 제거
            print(f"  → 이모지 유지된 앵커")
            print(f"  → 원본 텍스트: {text_part.replace('-', ' ')}")

if __name__ == "__main__":
    analyze_vscode_anchor_generation()
    test_actual_anchors()
