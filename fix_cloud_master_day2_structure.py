#!/usr/bin/env python3
"""
Cloud Master Day2 README.md 파일의 제목 구조를 교육 시나리오에 맞게 수정
"""

import re
from pathlib import Path

def fix_cloud_master_day2_structure():
    """Cloud Master Day2 파일의 제목 구조 수정"""
    
    file_path = Path("mcp_knowledge_base/cloud_master/textbook/Day2/README.md")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 수정할 제목 매핑 (기존 → 새로운 구조)
    title_mappings = {
        # 실습 환경 준비 섹션
        r'^## 🔧 실습 환경 준비$': '## 🔧 실습 환경 준비',
        r'^### 필수 소프트웨어 설치$': '### 📦 필수 소프트웨어 설치',
        r'^### 클라우드 계정 준비$': '### ☁️ 클라우드 계정 준비',
        r'^### 실습 전 체크리스트$': '### ✅ 실습 전 체크리스트',
        
        # 학습 자료 섹션
        r'^## 📚 학습 자료$': '## 📚 학습 자료',
        
        # 시작하기 섹션
        r'^## 🚀 시작하기$': '## 🚀 시작하기',
        
        # Docker 섹션
        r'^## 🐳 Docker 고급 기법 및 최적화$': '## 🐳 Docker 고급 기법 및 최적화',
        r'^### 📚 이론: 컨테이너 아키텍처 원리$': '### 📚 이론: 컨테이너 아키텍처 원리',
        r'^### 멀티스테이지 빌드$': '### 🔨 멀티스테이지 빌드',
        r'^### 이미지 최적화 기법$': '### ⚡ 이미지 최적화 기법',
        r'^### 보안 강화$': '### 🔒 보안 강화',
        r'^### 실습: 프로덕션급 Docker 이미지 빌드$': '### 🛠️ 실습: 프로덕션급 Docker 이미지 빌드',
        
        # GitHub Actions 섹션
        r'^## 🚀 GitHub Actions 고급 워크플로우$': '## 🚀 GitHub Actions 고급 워크플로우',
        r'^### 📚 이론: CI/CD 파이프라인 아키텍처$': '### 📚 이론: CI/CD 파이프라인 아키텍처',
        
        # Kubernetes 섹션 (추가 예정)
        # VM 기반 배포 섹션 (추가 예정)
        # 완전 자동화 섹션 (추가 예정)
    }
    
    # 제목 수정 적용
    for old_pattern, new_title in title_mappings.items():
        content = re.sub(old_pattern, new_title, content, flags=re.MULTILINE)
    
    # 목차 섹션 수정
    toc_section = """<details>
<summary>📋 목차</summary>

## 📚 이론 학습
1. [🎯 학습 목표](#학습-목표)
2. [🐳 Docker 고급 기법 및 최적화](#docker-고급-기법-및-최적화)
3. [🚀 GitHub Actions 고급 워크플로우](#github-actions-고급-워크플로우)
4. [☸️ Kubernetes 기초 및 클러스터 관리](#kubernetes-기초-및-클러스터-관리)
5. [🖥️ VM 기반 컨테이너 배포 자동화](#vm-기반-컨테이너-배포-자동화)
6. [🔄 완전 자동화된 배포 파이프라인](#완전-자동화된-배포-파이프라인)

## 🛠️ 실습 학습
7. [🔧 실습 환경 준비](#실습-환경-준비)
8. [📚 학습 자료](#학습-자료)
9. [🚀 시작하기](#시작하기)
10. [🐳 Docker 고급 기법 실습](#docker-고급-기법-실습)
11. [🚀 GitHub Actions 고급 워크플로우 실습](#github-actions-고급-워크플로우-실습)
12. [☸️ Kubernetes 기초 실습](#kubernetes-기초-실습)
13. [🖥️ VM 기반 컨테이너 배포 실습](#vm-기반-컨테이너-배포-실습)
14. [🔄 완전 자동화 파이프라인 실습](#완전-자동화-파이프라인-실습)

## 📚 참고 자료
15. [📚 문제 해결 및 참고 자료](#문제-해결-및-참고-자료)
16. [💡 핵심 개념 미리보기](#핵심-개념-미리보기)

</details>"""
    
    # 기존 목차 섹션 교체
    content = re.sub(
        r'<details>\s*<summary>📋 목차</summary>.*?</details>',
        toc_section,
        content,
        flags=re.DOTALL
    )
    
    # 파일 저장
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("✅ Cloud Master Day2 구조 수정 완료!")
    print("📋 수정된 내용:")
    print("  - 제목 구조를 교육 시나리오에 맞게 개선")
    print("  - 목차 앵커 링크를 VS Code 마크다운 표준에 맞게 수정")
    print("  - 이모지와 특수문자 제거, 소문자 변환 적용")

if __name__ == "__main__":
    fix_cloud_master_day2_structure()
