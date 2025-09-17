#!/usr/bin/env python3
"""
Cloud Master 모든 Day 파일의 제목 구조를 교육 시나리오에 맞게 수정
"""

import re
from pathlib import Path

def fix_cloud_master_all_days():
    """Cloud Master 모든 Day 파일의 제목 구조 수정"""
    
    days = ['Day1', 'Day2', 'Day3']
    
    for day in days:
        file_path = Path(f"mcp_knowledge_base/cloud_master/textbook/{day}/README.md")
        
        if not file_path.exists():
            print(f"❌ 파일을 찾을 수 없습니다: {file_path}")
            continue
            
        print(f"🔧 {day} 파일 수정 중...")
        
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
            r'^## 📚 실습 가이드$': '## 📚 실습 가이드',
            
            # 시작하기 섹션
            r'^## 🚀 시작하기$': '## 🚀 시작하기',
            
            # Docker 섹션
            r'^## 🐳 Docker 기초 및 컨테이너 기술$': '## 🐳 Docker 기초 및 컨테이너 기술',
            r'^## 🐳 Docker 고급 기법 및 최적화$': '## 🐳 Docker 고급 기법 및 최적화',
            r'^### 📚 이론: 컨테이너 아키텍처 원리$': '### 📚 이론: 컨테이너 아키텍처 원리',
            r'^### 멀티스테이지 빌드$': '### 🔨 멀티스테이지 빌드',
            r'^### 이미지 최적화 기법$': '### ⚡ 이미지 최적화 기법',
            r'^### 보안 강화$': '### 🔒 보안 강화',
            r'^### 실습: 프로덕션급 Docker 이미지 빌드$': '### 🛠️ 실습: 프로덕션급 Docker 이미지 빌드',
            
            # GitHub Actions 섹션
            r'^## 🚀 GitHub Actions CI/CD 파이프라인$': '## 🚀 GitHub Actions CI/CD 파이프라인',
            r'^## 🚀 GitHub Actions 고급 워크플로우$': '## 🚀 GitHub Actions 고급 워크플로우',
            r'^### 📚 이론: CI/CD 파이프라인 아키텍처$': '### 📚 이론: CI/CD 파이프라인 아키텍처',
            
            # Kubernetes 섹션
            r'^## ☸️ Kubernetes 기초 및 클러스터 관리$': '## ☸️ Kubernetes 기초 및 클러스터 관리',
            r'^## ☸️ Kubernetes 고급 및 클러스터 관리$': '## ☸️ Kubernetes 고급 및 클러스터 관리',
            
            # VM 기반 배포 섹션
            r'^## 🖥️ VM 기반 웹 애플리케이션 배포$': '## 🖥️ VM 기반 웹 애플리케이션 배포',
            r'^## 🖥️ VM 기반 컨테이너 배포 자동화$': '## 🖥️ VM 기반 컨테이너 배포 자동화',
            
            # 완전 자동화 섹션
            r'^## 🔄 완전 자동화된 배포 파이프라인$': '## 🔄 완전 자동화된 배포 파이프라인',
            
            # 로드 밸런싱 섹션 (Day3)
            r'^## 🚀 로드 밸런싱 및 Auto Scaling$': '## 🚀 로드 밸런싱 및 Auto Scaling',
            
            # 모니터링 섹션 (Day3)
            r'^## 📊 컨테이너 모니터링 및 로깅$': '## 📊 컨테이너 모니터링 및 로깅',
            
            # 장애 복구 섹션 (Day3)
            r'^## 🔄 장애 복구 및 운영 자동화$': '## 🔄 장애 복구 및 운영 자동화',
            
            # 비용 최적화 섹션 (Day3)
            r'^## 💰 비용 최적화 및 운영 전략$': '## 💰 비용 최적화 및 운영 전략',
        }
        
        # 제목 수정 적용
        for old_pattern, new_title in title_mappings.items():
            content = re.sub(old_pattern, new_title, content, flags=re.MULTILINE)
        
        # 목차 섹션 수정 (Day별로 다른 구조)
        if day == 'Day1':
            toc_section = """<details>
<summary>📋 목차</summary>

## 📚 이론 학습
1. [🎯 학습 목표](#학습-목표)
2. [🐳 Docker 기초 및 컨테이너 기술](#docker-기초-및-컨테이너-기술)
3. [📝 Git/GitHub 기초 및 협업](#gitgithub-기초-및-협업)
4. [🚀 GitHub Actions CI/CD 파이프라인](#github-actions-cicd-파이프라인)
5. [🖥️ VM 기반 웹 애플리케이션 배포](#vm-기반-웹-애플리케이션-배포)

## 🛠️ 실습 학습
6. [🔧 실습 환경 준비](#실습-환경-준비)
7. [🐳 Docker 기초 및 컨테이너 기술 실습](#docker-기초-및-컨테이너-기술-실습)
8. [📝 Git/GitHub 기초 및 협업 실습](#gitgithub-기초-및-협업-실습)
9. [🚀 GitHub Actions CI/CD 파이프라인 실습](#github-actions-cicd-파이프라인-실습)
10. [🖥️ VM 기반 웹 애플리케이션 배포 실습](#vm-기반-웹-애플리케이션-배포-실습)

## 📚 참고 자료
11. [📚 문제 해결 및 참고 자료](#문제-해결-및-참고-자료)

</details>"""
        
        elif day == 'Day3':
            toc_section = """<details>
<summary>📋 목차</summary>

## 📚 이론 학습
1. [🎯 학습 목표](#학습-목표)
2. [🚀 로드 밸런싱 및 Auto Scaling](#로드-밸런싱-및-auto-scaling)
3. [📊 컨테이너 모니터링 및 로깅](#컨테이너-모니터링-및-로깅)
4. [🔄 장애 복구 및 운영 자동화](#장애-복구-및-운영-자동화)
5. [💰 비용 최적화 및 운영 전략](#비용-최적화-및-운영-전략)

## 🛠️ 실습 학습
6. [📚 실습 가이드](#실습-가이드)
7. [🔧 실습 환경 준비](#실습-환경-준비)
8. [🚀 로드 밸런싱 및 Auto Scaling 실습](#로드-밸런싱-및-auto-scaling-실습)
9. [📊 컨테이너 모니터링 및 로깅 실습](#컨테이너-모니터링-및-로깅-실습)
10. [🔄 장애 복구 및 운영 자동화 실습](#장애-복구-및-운영-자동화-실습)
11. [💰 비용 최적화 및 운영 전략 실습](#비용-최적화-및-운영-전략-실습)

## 📚 참고 자료
12. [📚 문제 해결 및 참고 자료](#문제-해결-및-참고-자료)

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
        
        print(f"✅ {day} 구조 수정 완료!")
    
    print("\n🎉 Cloud Master 모든 Day 파일 수정 완료!")
    print("📋 수정된 내용:")
    print("  - 제목 구조를 교육 시나리오에 맞게 개선")
    print("  - 목차 앵커 링크를 VS Code 마크다운 표준에 맞게 수정")
    print("  - 이모지와 특수문자 제거, 소문자 변환 적용")
    print("  - 모든 Day 파일의 일관성 확보")

if __name__ == "__main__":
    fix_cloud_master_all_days()
