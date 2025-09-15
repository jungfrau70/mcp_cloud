#!/usr/bin/env python3
"""
누락된 파일 생성 도구
검증에서 발견된 누락 파일들을 생성합니다.
"""

import os
import argparse
from pathlib import Path

def create_curriculum_md():
    """curriculum.md 파일 생성"""
    content = """# 📚 전체 커리큘럼

## 🎯 과정 개요

이 커리큘럼은 클라우드 컴퓨팅의 기초부터 고급까지 체계적으로 학습할 수 있도록 구성되었습니다.

## 📖 과정 구성

### 1. Cloud Basic - 클라우드 기초
- **기간**: 2일
- **목표**: AWS/GCP 기초 실습
- **내용**: 계정 설정, IAM, 스토리지, 네트워킹, 데이터베이스

### 2. Cloud Master - 클라우드 마스터
- **기간**: 3일
- **목표**: 고급 CI/CD 및 VM 기반 컨테이너 배포
- **내용**: Docker, Kubernetes, GitHub Actions, 고가용성

### 3. Cloud Container - 클라우드 컨테이너
- **기간**: 2일
- **목표**: 컨테이너 심화 과정
- **내용**: 고급 컨테이너 오케스트레이션, 모니터링, 보안

## 🔗 관련 링크

- [Cloud Basic 학습 경로](./cloud_basic/learning-path.md)
- [Cloud Master 학습 경로](./cloud_master/learning-path.md)
- [Cloud Container 학습 경로](./cloud_container/learning-path.md)
- [통합 인덱스](./index.md)

## 📞 문의

문의사항이 있으시면 언제든 연락주세요.
"""
    
    file_path = "mcp_knowledge_base/curriculum.md"
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✅ {file_path} 생성 완료")

def create_index_md():
    """index.md 파일 생성"""
    content = """# 🏠 통합 인덱스

## 📚 전체 과정

### 1. Cloud Basic
- [학습 경로](./cloud_basic/learning-path.md)
- [1일차 실습](./cloud_basic/textbook/Day1/README.md)
- [2일차 실습](./cloud_basic/textbook/Day2/README.md)

### 2. Cloud Master
- [학습 경로](./cloud_master/learning-path.md)
- [1일차 실습](./cloud_master/textbook/Day1/README.md)
- [2일차 실습](./cloud_master/textbook/Day2/README.md)
- [3일차 실습](./cloud_master/textbook/Day3/README.md)

### 3. Cloud Container
- [학습 경로](./cloud_container/learning-path.md)
- [1일차 실습](./cloud_container/textbook/Day1/README.md)
- [2일차 실습](./cloud_container/textbook/Day2/README.md)

## 🔗 관련 링크

- [전체 커리큘럼](./curriculum.md)
- [GitHub 저장소](https://github.com/your-repo/mcp_cloud)

## 📞 문의

문의사항이 있으시면 언제든 연락주세요.
"""
    
    file_path = "mcp_knowledge_base/index.md"
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✅ {file_path} 생성 완료")

def create_missing_day3_files():
    """Day3 누락 파일들 생성"""
    # Cloud Master Day3 누락 파일들
    day3_files = [
        "mcp_knowledge_base/cloud_master/textbook/Day3/monitoring-setup-guide.md",
        "mcp_knowledge_base/cloud_master/textbook/Day3/cost-optimization-guide.md"
    ]
    
    for file_path in day3_files:
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        
        if "monitoring-setup-guide" in file_path:
            content = """# 📊 모니터링 설정 가이드

## 🎯 목표
고급 모니터링 시스템 구축 및 관리

## 📚 내용
- Prometheus 설정
- Grafana 대시보드 구성
- 알림 설정
- 로그 수집 및 분석

## 🔧 실습
1. Prometheus 설치 및 설정
2. Grafana 연결
3. 대시보드 생성
4. 알림 규칙 설정
"""
        elif "cost-optimization-guide" in file_path:
            content = """# 💰 비용 최적화 가이드

## 🎯 목표
클라우드 비용 최적화 전략 및 실습

## 📚 내용
- 비용 분석 도구 사용
- 리소스 최적화
- 예약 인스턴스 활용
- 자동 스케일링 설정

## 🔧 실습
1. 비용 분석 대시보드 구성
2. 리소스 사용량 모니터링
3. 자동 스케일링 정책 설정
4. 비용 알림 설정
"""
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"✅ {file_path} 생성 완료")

def main():
    parser = argparse.ArgumentParser(description='누락된 파일 생성 도구')
    parser.add_argument('--all', action='store_true', help='모든 누락 파일 생성')
    parser.add_argument('--curriculum', action='store_true', help='curriculum.md 생성')
    parser.add_argument('--index', action='store_true', help='index.md 생성')
    parser.add_argument('--day3', action='store_true', help='Day3 누락 파일들 생성')
    
    args = parser.parse_args()
    
    if args.all or args.curriculum:
        create_curriculum_md()
    
    if args.all or args.index:
        create_index_md()
    
    if args.all or args.day3:
        create_missing_day3_files()
    
    if not any([args.all, args.curriculum, args.index, args.day3]):
        print("사용법: python create_missing_files.py --all")
        print("옵션:")
        print("  --all        모든 누락 파일 생성")
        print("  --curriculum curriculum.md 생성")
        print("  --index      index.md 생성")
        print("  --day3       Day3 누락 파일들 생성")

if __name__ == "__main__":
    main()
