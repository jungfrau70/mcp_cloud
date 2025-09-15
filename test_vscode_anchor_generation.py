#!/usr/bin/env python3
"""
VS Code 마크다운 미리보기 앵커 생성 테스트
"""

import re

def vscode_anchor_generation(text):
    """VS Code 마크다운 미리보기와 동일한 앵커 ID 생성"""
    # VS Code의 실제 구현을 시뮬레이션
    # 1. 앞뒤 공백 제거
    text = text.strip()
    
    # 2. 이모지와 특수문자 제거 (VS Code는 이모지를 제거함)
    text = re.sub(r'[^\w\s가-힣]', '', text)
    
    # 3. 공백을 하이픈으로 변환
    text = re.sub(r'\s+', '-', text)
    
    # 4. 연속된 하이픈을 하나로 변환
    text = re.sub(r'-+', '-', text)
    
    # 5. 앞뒤 하이픈 제거
    text = text.strip('-')
    
    # 6. 소문자로 변환
    text = text.lower()
    
    return text

def test_vscode_anchors():
    """VS Code 앵커 생성 테스트"""
    
    print("🔍 VS Code 마크다운 미리보기 앵커 생성 테스트")
    print("=" * 60)
    
    # 테스트 케이스들
    test_cases = [
        "🎯 학습 목표",
        "📚 실습 개요", 
        "🔧 실습 환경 준비",
        "🚀 1단계: AWS 계정 생성 및 설정",
        "👥 2단계: IAM 사용자 및 권한 관리",
        "💻 3단계: EC2 인스턴스 생성 및 관리",
        "🗂️ 4단계: S3 스토리지 서비스 활용",
        "📚 문제 해결 및 참고 자료"
    ]
    
    print("📊 VS Code 스타일 앵커 ID 생성:")
    print("-" * 50)
    
    for heading in test_cases:
        anchor_id = vscode_anchor_generation(heading)
        print(f"헤딩: '{heading}'")
        print(f"VS Code ID: '#{anchor_id}'")
        print()
    
    print("📋 목차의 앵커 링크들과 비교:")
    print("-" * 50)
    
    # 목차의 실제 링크들
    expected_links = [
        "학습-목표",
        "실습-개요",
        "실습-환경-준비", 
        "1단계-aws-계정-생성-및-설정",
        "2단계-iam-사용자-및-권한-관리",
        "3단계-ec2-인스턴스-생성-및-관리",
        "4단계-s3-스토리지-서비스-활용",
        "문제-해결-및-참고-자료"
    ]
    
    for i, heading in enumerate(test_cases):
        generated_id = vscode_anchor_generation(heading)
        expected_id = expected_links[i]
        
        if generated_id == expected_id:
            print(f"✅ '{heading}' → '#{generated_id}' 매칭됨")
        else:
            print(f"❌ '{heading}' → '#{generated_id}' ≠ '#{expected_id}'")
            print(f"   차이점: '{generated_id}' vs '{expected_id}'")

if __name__ == "__main__":
    test_vscode_anchors()
