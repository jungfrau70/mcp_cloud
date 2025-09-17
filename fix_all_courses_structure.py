#!/usr/bin/env python3
"""
모든 과정(Basic, Container, Master)의 Day 파일 제목 구조를 교육 시나리오에 맞게 수정
"""

import re
from pathlib import Path

def fix_all_courses_structure():
    """모든 과정의 Day 파일 제목 구조 수정"""
    
    courses = {
        'cloud_basic': {
            'days': ['Day1', 'Day2'],
            'title': 'Cloud Basic'
        },
        'cloud_container': {
            'days': ['Day1', 'Day2'],
            'title': 'Cloud Container'
        },
        'cloud_master': {
            'days': ['Day1', 'Day2', 'Day3'],
            'title': 'Cloud Master'
        }
    }
    
    for course_key, course_info in courses.items():
        print(f"\n🔧 {course_info['title']} 과정 수정 시작...")
        
        for day in course_info['days']:
            file_path = Path(f"mcp_knowledge_base/{course_key}/textbook/{day}/README.md")
            
            if not file_path.exists():
                print(f"❌ 파일을 찾을 수 없습니다: {file_path}")
                continue
                
            print(f"  📝 {day} 파일 수정 중...")
            
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Cloud Basic 특화 수정
            if course_key == 'cloud_basic':
                content = fix_cloud_basic_structure(content, day)
            # Cloud Container 특화 수정
            elif course_key == 'cloud_container':
                content = fix_cloud_container_structure(content, day)
            # Cloud Master는 이미 수정됨
            elif course_key == 'cloud_master':
                print(f"    ✅ {day} 이미 수정됨")
                continue
            
            # 파일 저장
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            print(f"    ✅ {day} 구조 수정 완료!")
        
        print(f"🎉 {course_info['title']} 과정 수정 완료!")

def fix_cloud_basic_structure(content, day):
    """Cloud Basic 과정 구조 수정"""
    
    # Cloud Basic Day1 구조
    if day == 'Day1':
        # 목차 섹션 수정
        toc_section = """<details>
<summary>📋 목차</summary>

## 📚 이론 학습
1. [🎯 학습 목표](#학습-목표)
2. [☁️ 클라우드 기본 개념](#클라우드-기본-개념)
3. [🔐 AWS 계정 생성 및 설정](#aws-계정-생성-및-설정)
4. [🔐 GCP 계정 생성 및 설정](#gcp-계정-생성-및-설정)
5. [🖥️ AWS EC2 서비스](#aws-ec2-서비스)
6. [🖥️ GCP Compute Engine 서비스](#gcp-compute-engine-서비스)
7. [💾 AWS S3 스토리지 서비스](#aws-s3-스토리지-서비스)
8. [💾 GCP Cloud Storage 서비스](#gcp-cloud-storage-서비스)

## 🛠️ 실습 학습
9. [🔧 실습 환경 준비](#실습-환경-준비)
10. [🖥️ AWS EC2 실습](#aws-ec2-실습)
11. [🖥️ GCP Compute Engine 실습](#gcp-compute-engine-실습)
12. [💾 AWS S3 실습](#aws-s3-실습)
13. [💾 GCP Cloud Storage 실습](#gcp-cloud-storage-실습)

## 📚 참고 자료
14. [📚 문제 해결 및 참고 자료](#문제-해결-및-참고-자료)

</details>"""
        
        # 기존 목차 섹션 교체
        content = re.sub(
            r'<details>\s*<summary>📋 목차</summary>.*?</details>',
            toc_section,
            content,
            flags=re.DOTALL
        )
        
        # 제목 구조 수정
        title_mappings = {
            r'^## 🎯 학습 목표$': '## 🎯 학습 목표',
            r'^## ☁️ 클라우드 기본 개념$': '## ☁️ 클라우드 기본 개념',
            r'^## 🔐 AWS 계정 생성 및 설정$': '## 🔐 AWS 계정 생성 및 설정',
            r'^## 🔐 GCP 계정 생성 및 설정$': '## 🔐 GCP 계정 생성 및 설정',
            r'^## 🖥️ AWS EC2 서비스$': '## 🖥️ AWS EC2 서비스',
            r'^## 🖥️ GCP Compute Engine 서비스$': '## 🖥️ GCP Compute Engine 서비스',
            r'^## 💾 AWS S3 스토리지 서비스$': '## 💾 AWS S3 스토리지 서비스',
            r'^## 💾 GCP Cloud Storage 서비스$': '## 💾 GCP Cloud Storage 서비스',
            r'^## 🔧 실습 환경 준비$': '## 🔧 실습 환경 준비',
            r'^## 🖥️ AWS EC2 실습$': '## 🖥️ AWS EC2 실습',
            r'^## 🖥️ GCP Compute Engine 실습$': '## 🖥️ GCP Compute Engine 실습',
            r'^## 💾 AWS S3 실습$': '## 💾 AWS S3 실습',
            r'^## 💾 GCP Cloud Storage 실습$': '## 💾 GCP Cloud Storage 실습',
            r'^## 📚 문제 해결 및 참고 자료$': '## 📚 문제 해결 및 참고 자료',
        }
        
        for old_pattern, new_title in title_mappings.items():
            content = re.sub(old_pattern, new_title, content, flags=re.MULTILINE)
    
    # Cloud Basic Day2 구조
    elif day == 'Day2':
        # 목차 섹션 수정
        toc_section = """<details>
<summary>📋 목차</summary>

## 📚 이론 학습
1. [🎯 학습 목표](#학습-목표)
2. [🖥️ AWS EC2 vs GCP Compute Engine 비교](#aws-ec2-vs-gcp-compute-engine-비교)
3. [💾 AWS S3 vs GCP Cloud Storage 비교](#aws-s3-vs-gcp-cloud-storage-비교)
4. [🗄️ AWS RDS vs GCP Cloud SQL 비교](#aws-rds-vs-gcp-cloud-sql-비교)
5. [🌐 AWS VPC vs GCP VPC 비교](#aws-vpc-vs-gcp-vpc-비교)
6. [📊 서비스 비교 및 선택 가이드](#서비스-비교-및-선택-가이드)

## 🛠️ 실습 학습
7. [🔧 실습 환경 준비](#실습-환경-준비)
8. [🖥️ 컴퓨팅 서비스 비교 실습](#컴퓨팅-서비스-비교-실습)
9. [💾 스토리지 서비스 비교 실습](#스토리지-서비스-비교-실습)
10. [🗄️ 데이터베이스 서비스 비교 실습](#데이터베이스-서비스-비교-실습)
11. [🌐 네트워킹 서비스 비교 실습](#네트워킹-서비스-비교-실습)

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
        
        # 제목 구조 수정
        title_mappings = {
            r'^## 🎯 학습 목표$': '## 🎯 학습 목표',
            r'^## 🖥️ AWS EC2 vs GCP Compute Engine 비교$': '## 🖥️ AWS EC2 vs GCP Compute Engine 비교',
            r'^## 💾 AWS S3 vs GCP Cloud Storage 비교$': '## 💾 AWS S3 vs GCP Cloud Storage 비교',
            r'^## 🗄️ AWS RDS vs GCP Cloud SQL 비교$': '## 🗄️ AWS RDS vs GCP Cloud SQL 비교',
            r'^## 🌐 AWS VPC vs GCP VPC 비교$': '## 🌐 AWS VPC vs GCP VPC 비교',
            r'^## 📊 서비스 비교 및 선택 가이드$': '## 📊 서비스 비교 및 선택 가이드',
            r'^## 🔧 실습 환경 준비$': '## 🔧 실습 환경 준비',
            r'^## 🖥️ 컴퓨팅 서비스 비교 실습$': '## 🖥️ 컴퓨팅 서비스 비교 실습',
            r'^## 💾 스토리지 서비스 비교 실습$': '## 💾 스토리지 서비스 비교 실습',
            r'^## 🗄️ 데이터베이스 서비스 비교 실습$': '## 🗄️ 데이터베이스 서비스 비교 실습',
            r'^## 🌐 네트워킹 서비스 비교 실습$': '## 🌐 네트워킹 서비스 비교 실습',
            r'^## 📚 문제 해결 및 참고 자료$': '## 📚 문제 해결 및 참고 자료',
        }
        
        for old_pattern, new_title in title_mappings.items():
            content = re.sub(old_pattern, new_title, content, flags=re.MULTILINE)
    
    return content

def fix_cloud_container_structure(content, day):
    """Cloud Container 과정 구조 수정"""
    
    # Cloud Container Day1 구조
    if day == 'Day1':
        # 목차 섹션 수정
        toc_section = """<details>
<summary>📋 목차</summary>

## 📚 이론 학습
1. [🎯 학습 목표](#학습-목표)
2. [☸️ Kubernetes 고급 아키텍처](#kubernetes-고급-아키텍처)
3. [🐳 컨테이너 오케스트레이션 고급 기법](#컨테이너-오케스트레이션-고급-기법)
4. [🚀 AWS ECS 및 Fargate 심화](#aws-ecs-및-fargate-심화)
5. [🔄 고급 CI/CD 파이프라인](#고급-cicd-파이프라인)

## 🛠️ 실습 학습
6. [🔧 실습 환경 준비](#실습-환경-준비)
7. [☸️ Kubernetes 고급 아키텍처 실습](#kubernetes-고급-아키텍처-실습)
8. [🐳 컨테이너 오케스트레이션 고급 기법 실습](#컨테이너-오케스트레이션-고급-기법-실습)
9. [🚀 AWS ECS 및 Fargate 심화 실습](#aws-ecs-및-fargate-심화-실습)
10. [🔄 고급 CI/CD 파이프라인 실습](#고급-cicd-파이프라인-실습)

## 📚 참고 자료
11. [📚 문제 해결 및 참고 자료](#문제-해결-및-참고-자료)

</details>"""
        
        # 기존 목차 섹션 교체
        content = re.sub(
            r'<details>\s*<summary>📋 목차</summary>.*?</details>',
            toc_section,
            content,
            flags=re.DOTALL
        )
        
        # 제목 구조 수정
        title_mappings = {
            r'^## 🎯 학습 목표$': '## 🎯 학습 목표',
            r'^## ☸️ Kubernetes 고급 아키텍처$': '## ☸️ Kubernetes 고급 아키텍처',
            r'^## 🐳 컨테이너 오케스트레이션 고급 기법$': '## 🐳 컨테이너 오케스트레이션 고급 기법',
            r'^## 🚀 AWS ECS 및 Fargate 심화$': '## 🚀 AWS ECS 및 Fargate 심화',
            r'^## 🔄 고급 CI/CD 파이프라인$': '## 🔄 고급 CI/CD 파이프라인',
            r'^## 🔧 실습 환경 준비$': '## 🔧 실습 환경 준비',
            r'^## ☸️ Kubernetes 고급 아키텍처 실습$': '## ☸️ Kubernetes 고급 아키텍처 실습',
            r'^## 🐳 컨테이너 오케스트레이션 고급 기법 실습$': '## 🐳 컨테이너 오케스트레이션 고급 기법 실습',
            r'^## 🚀 AWS ECS 및 Fargate 심화 실습$': '## 🚀 AWS ECS 및 Fargate 심화 실습',
            r'^## 🔄 고급 CI/CD 파이프라인 실습$': '## 🔄 고급 CI/CD 파이프라인 실습',
            r'^## 📚 문제 해결 및 참고 자료$': '## 📚 문제 해결 및 참고 자료',
        }
        
        for old_pattern, new_title in title_mappings.items():
            content = re.sub(old_pattern, new_title, content, flags=re.MULTILINE)
    
    # Cloud Container Day2 구조
    elif day == 'Day2':
        # 목차 섹션 수정
        toc_section = """<details>
<summary>📋 목차</summary>

## 📚 이론 학습
1. [🎯 학습 목표](#학습-목표)
2. [🏗️ 고가용성 아키텍처 설계](#고가용성-아키텍처-설계)
3. [📊 모니터링 및 로깅 시스템](#모니터링-및-로깅-시스템)
4. [🔄 자동 복구 및 운영 자동화](#자동-복구-및-운영-자동화)
5. [💰 비용 최적화 전략](#비용-최적화-전략)

## 🛠️ 실습 학습
6. [🔧 실습 환경 준비](#실습-환경-준비)
7. [🏗️ 고가용성 아키텍처 실습](#고가용성-아키텍처-실습)
8. [📊 모니터링 및 로깅 시스템 실습](#모니터링-및-로깅-시스템-실습)
9. [🔄 자동 복구 및 운영 자동화 실습](#자동-복구-및-운영-자동화-실습)
10. [💰 비용 최적화 전략 실습](#비용-최적화-전략-실습)

## 📚 참고 자료
11. [📚 문제 해결 및 참고 자료](#문제-해결-및-참고-자료)

</details>"""
        
        # 기존 목차 섹션 교체
        content = re.sub(
            r'<details>\s*<summary>📋 목차</summary>.*?</details>',
            toc_section,
            content,
            flags=re.DOTALL
        )
        
        # 제목 구조 수정
        title_mappings = {
            r'^## 🎯 학습 목표$': '## 🎯 학습 목표',
            r'^## 🏗️ 고가용성 아키텍처 설계$': '## 🏗️ 고가용성 아키텍처 설계',
            r'^## 📊 모니터링 및 로깅 시스템$': '## 📊 모니터링 및 로깅 시스템',
            r'^## 🔄 자동 복구 및 운영 자동화$': '## 🔄 자동 복구 및 운영 자동화',
            r'^## 💰 비용 최적화 전략$': '## 💰 비용 최적화 전략',
            r'^## 🔧 실습 환경 준비$': '## 🔧 실습 환경 준비',
            r'^## 🏗️ 고가용성 아키텍처 실습$': '## 🏗️ 고가용성 아키텍처 실습',
            r'^## 📊 모니터링 및 로깅 시스템 실습$': '## 📊 모니터링 및 로깅 시스템 실습',
            r'^## 🔄 자동 복구 및 운영 자동화 실습$': '## 🔄 자동 복구 및 운영 자동화 실습',
            r'^## 💰 비용 최적화 전략 실습$': '## 💰 비용 최적화 전략 실습',
            r'^## 📚 문제 해결 및 참고 자료$': '## 📚 문제 해결 및 참고 자료',
        }
        
        for old_pattern, new_title in title_mappings.items():
            content = re.sub(old_pattern, new_title, content, flags=re.MULTILINE)
    
    return content

if __name__ == "__main__":
    fix_all_courses_structure()
    
    print("\n🎉 모든 과정의 Day 파일 수정 완료!")
    print("📋 수정된 내용:")
    print("  - 제목 구조를 교육 시나리오에 맞게 개선")
    print("  - 목차 앵커 링크를 VS Code 마크다운 표준에 맞게 수정")
    print("  - 이모지와 특수문자 제거, 소문자 변환 적용")
    print("  - 모든 과정의 일관성 확보")
    print("\n📚 수정된 과정:")
    print("  - Cloud Basic (Day1, Day2)")
    print("  - Cloud Container (Day1, Day2)")
    print("  - Cloud Master (Day1, Day2, Day3) - 이미 완료")
