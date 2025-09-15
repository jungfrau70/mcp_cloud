#!/usr/bin/env python3
"""
앵커 ID 생성 디버깅 도구
"""

import re

def normalize_anchor_id(text):
    """VS Code 마크다운 미리보기와 동일한 앵커 ID를 생성합니다."""
    # 앞뒤 공백 제거
    text = text.strip()
    
    # 공백을 하이픈으로 변환
    text = re.sub(r'\s+', '-', text)
    
    # 연속된 하이픈을 하나로 변환
    text = re.sub(r'-+', '-', text)
    
    # 앞뒤 하이픈 제거
    text = text.strip('-')
    
    # 소문자로 변환
    text = text.lower()
    
    return text

def debug_anchor_generation():
    """앵커 ID 생성 로직을 디버깅합니다."""
    
    print("🔍 앵커 ID 생성 디버깅")
    print("=" * 50)
    
    # 실제 헤딩들
    headings = [
        "🎯 학습 목표",
        "📚 실습 개요", 
        "🔧 실습 환경 준비",
        "🚀 1단계: AWS 계정 생성 및 설정",
        "👥 2단계: IAM 사용자 및 권한 관리",
        "💻 3단계: EC2 인스턴스 생성 및 관리",
        "🗂️ 4단계: S3 스토리지 서비스 활용",
        "📚 문제 해결 및 참고 자료"
    ]
    
    # 목차의 앵커 링크들
    anchor_links = [
        "학습-목표",
        "실습-개요",
        "실습-환경-준비", 
        "1단계-aws-계정-생성-및-설정",
        "2단계-iam-사용자-및-권한-관리",
        "3단계-ec2-인스턴스-생성-및-관리",
        "4단계-s3-스토리지-서비스-활용",
        "문제-해결-및-참고-자료"
    ]
    
    print("📊 헤딩 → 앵커 ID 변환 결과:")
    print("-" * 50)
    
    for heading in headings:
        generated_id = normalize_anchor_id(heading)
        print(f"헤딩: '{heading}'")
        print(f"생성된 ID: '{generated_id}'")
        print()
    
    print("📋 목차의 앵커 링크들:")
    print("-" * 50)
    
    for link in anchor_links:
        print(f"링크: '#{link}'")
    
    print("\n🔍 매칭 검사:")
    print("-" * 50)
    
    for heading in headings:
        generated_id = normalize_anchor_id(heading)
        expected_links = [f"#{link}" for link in anchor_links]
        
        if f"#{generated_id}" in expected_links:
            print(f"✅ '{heading}' → '#{generated_id}' 매칭됨")
        else:
            print(f"❌ '{heading}' → '#{generated_id}' 매칭 안됨")
            # 가장 유사한 링크 찾기
            best_match = None
            best_score = 0
            for link in anchor_links:
                # 간단한 유사도 계산
                common_chars = len(set(generated_id) & set(link))
                score = common_chars / max(len(generated_id), len(link))
                if score > best_score:
                    best_score = score
                    best_match = link
            
            if best_match:
                print(f"   💡 가장 유사한 링크: '#{best_match}' (유사도: {best_score:.2f})")

if __name__ == "__main__":
    debug_anchor_generation()
