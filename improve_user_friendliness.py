#!/usr/bin/env python3
"""
사용자 친화성 개선 도구
"""

import os
import re
from pathlib import Path
from typing import Dict, List

class UserFriendlinessImprover:
    def __init__(self, knowledge_base_path: str = "mcp_knowledge_base"):
        self.knowledge_base_path = Path(knowledge_base_path)
        self.courses = ['cloud_basic', 'cloud_master', 'cloud_container']
        self.improvements_made = []
        
    def run_improvements(self):
        """사용자 친화성 개선 실행"""
        print("🚀 사용자 친화성 개선 시작")
        
        # 1. 학습 목표 추가
        self.add_learning_objectives()
        
        # 2. 사전 요구사항 추가
        self.add_prerequisites()
        
        # 3. 친절한 안내 메시지 추가
        self.add_friendly_messages()
        
        # 4. 학습 순서 명시화
        self.add_learning_order()
        
        # 5. 네비게이션 개선
        self.improve_navigation()
        
        # 6. 실습 가이드 개선
        self.improve_practice_guides()
        
        # 7. 개선 보고서 생성
        self.generate_improvement_report()
        
        print("\n🎉 사용자 친화성 개선 완료!")
    
    def add_learning_objectives(self):
        """학습 목표 추가"""
        print("\n🎯 학습 목표 추가 중...")
        
        for course in self.courses:
            course_path = self.knowledge_base_path / course
            if not course_path.exists():
                continue
            
            # 과정 메인 README에 학습 목표 추가
            main_readme = course_path / 'README.md'
            if main_readme.exists():
                self.add_learning_objectives_to_file(main_readme, course)
            
            # Day별 README에 학습 목표 추가
            textbook_path = course_path / 'textbook'
            if textbook_path.exists():
                for day_dir in textbook_path.iterdir():
                    if day_dir.is_dir() and day_dir.name.startswith('Day'):
                        day_readme = day_dir / 'README.md'
                        if day_readme.exists():
                            self.add_learning_objectives_to_file(day_readme, f"{course}_{day_dir.name}")
    
    def add_learning_objectives_to_file(self, file_path: Path, course_day: str):
        """파일에 학습 목표 추가"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 이미 학습 목표가 있는지 확인
            if re.search(r'학습\s*목표|learning\s*objective', content, re.IGNORECASE):
                return
            
            # 학습 목표 템플릿 생성
            if 'main' in course_day:
                objectives = self.get_course_learning_objectives(course_day.split('_')[0])
            else:
                objectives = self.get_day_learning_objectives(course_day)
            
            # 학습 목표 섹션 추가
            objectives_section = f"""
## 🎯 학습 목표

{objectives}

"""
            
            # 파일 시작 부분에 추가
            if content.startswith('# '):
                # 첫 번째 헤딩 다음에 추가
                lines = content.split('\n')
                insert_index = 1
                for i, line in enumerate(lines[1:], 1):
                    if line.startswith('## '):
                        insert_index = i
                        break
                lines.insert(insert_index, objectives_section.strip())
                new_content = '\n'.join(lines)
            else:
                new_content = objectives_section + content
            
            # 파일 저장
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            
            self.improvements_made.append({
                'file': str(file_path),
                'improvement': '학습 목표 추가',
                'course_day': course_day
            })
            
        except Exception as e:
            print(f"    ❌ 오류: {file_path} - {str(e)}")
    
    def get_course_learning_objectives(self, course: str) -> str:
        """과정별 학습 목표 템플릿"""
        objectives = {
            'cloud_basic': """이 과정을 통해 다음을 달성할 수 있습니다:

- **AWS와 GCP의 기본 서비스 이해**: 클라우드 컴퓨팅의 핵심 개념과 주요 서비스들을 체계적으로 학습
- **실무 중심의 실습 경험**: 이론과 실습을 결합한 체계적인 학습을 통해 실무 능력 향상
- **비용 효율적인 클라우드 활용**: 각 서비스의 특징과 비용 구조를 이해하여 최적의 선택 가능
- **문제해결 능력 향상**: 실습 중 발생하는 문제들을 스스로 해결할 수 있는 능력 개발
- **다음 단계 학습 준비**: Cloud Master 과정으로의 자연스러운 연결을 위한 기초 다지기""",
            
            'cloud_master': """이 과정을 통해 다음을 달성할 수 있습니다:

- **고급 클라우드 아키텍처 설계**: 확장 가능하고 안정적인 클라우드 시스템 설계 능력 개발
- **DevOps 도구 활용**: Docker, GitHub Actions 등 현대적인 개발 도구의 실무 활용
- **CI/CD 파이프라인 구축**: 자동화된 배포와 지속적 통합/배포 시스템 구축
- **비용 최적화 전략**: 클라우드 비용을 효율적으로 관리하고 최적화하는 방법 학습
- **모니터링 및 운영**: 시스템 상태를 실시간으로 모니터링하고 운영하는 능력 개발""",
            
            'cloud_container': """이 과정을 통해 다음을 달성할 수 있습니다:

- **Kubernetes 마스터**: 컨테이너 오케스트레이션의 핵심인 Kubernetes의 고급 기능 활용
- **고가용성 아키텍처**: 장애에 강하고 확장 가능한 시스템 아키텍처 설계
- **고급 로드 밸런싱**: 트래픽 분산과 성능 최적화를 위한 고급 로드 밸런싱 기술
- **모니터링 시스템 구축**: 포괄적인 모니터링 시스템을 통한 시스템 상태 관리
- **실전 프로젝트 경험**: 실제 업무 환경과 유사한 종합 프로젝트를 통한 실무 경험"""
        }
        
        return objectives.get(course, "이 과정을 통해 클라우드 기술을 체계적으로 학습할 수 있습니다.")
    
    def get_day_learning_objectives(self, course_day: str) -> str:
        """Day별 학습 목표 템플릿"""
        if 'cloud_basic' in course_day:
            if 'Day1' in course_day:
                return """이 Day를 통해 다음을 학습합니다:

- **AWS와 GCP 계정 설정**: 클라우드 서비스 사용을 위한 기본 환경 구축
- **IAM 기초 이해**: 사용자 권한 관리와 보안의 기본 원리 학습
- **스토리지 서비스 활용**: 다양한 스토리지 옵션의 특징과 사용법 이해
- **VM 서비스 기초**: 가상 머신 생성과 기본 관리 방법 학습
- **실습을 통한 체험**: 이론과 실습을 결합한 체계적인 학습 경험"""
            else:  # Day2
                return """이 Day를 통해 다음을 학습합니다:

- **서비스 비교 분석**: AWS와 GCP의 주요 서비스들을 체계적으로 비교
- **비용 구조 이해**: 각 서비스의 비용 모델과 최적화 방법 학습
- **실무 적용 능력**: 학습한 내용을 실제 업무에 적용할 수 있는 능력 개발
- **문제해결 능력**: 실습 중 발생하는 문제들을 해결하는 능력 향상"""
        
        elif 'cloud_master' in course_day:
            if 'Day1' in course_day:
                return """이 Day를 통해 다음을 학습합니다:

- **Docker 기초와 고급 활용**: 컨테이너 기술의 핵심인 Docker의 체계적 학습
- **Git과 GitHub 활용**: 버전 관리와 협업을 위한 Git/GitHub 사용법
- **GitHub Actions CI/CD**: 자동화된 빌드와 배포 파이프라인 구축
- **클라우드 배포 전략**: 실제 서비스를 클라우드에 배포하는 방법 학습
- **실무 도구 통합**: 개발부터 배포까지의 전체 워크플로우 경험"""
            elif 'Day2' in course_day:
                return """이 Day를 통해 다음을 학습합니다:

- **비용 최적화 전략**: 클라우드 비용을 효율적으로 관리하는 방법 학습
- **모니터링 시스템 구축**: 시스템 상태를 실시간으로 모니터링하는 방법
- **종합 실습 프로젝트**: 학습한 내용을 통합한 실전 프로젝트 경험
- **운영 최적화**: 시스템 성능과 안정성을 높이는 운영 방법 학습"""
            else:  # Day3
                return """이 Day를 통해 다음을 학습합니다:

- **자동 스케일링**: 트래픽에 따른 자동 확장/축소 시스템 구축
- **로드 밸런싱**: 고성능과 고가용성을 위한 로드 밸런싱 기술
- **재해 복구**: 장애 상황에 대비한 백업과 복구 전략 수립
- **고급 통합**: 다양한 서비스들을 통합한 복합 시스템 구축"""
        
        else:  # cloud_container
            if 'Day1' in course_day:
                return """이 Day를 통해 다음을 학습합니다:

- **Kubernetes 고급 기능**: 컨테이너 오케스트레이션의 핵심 기술 학습
- **컨테이너 보안**: 컨테이너 환경에서의 보안 정책과 모범 사례
- **비용 최적화**: 컨테이너 환경에서의 비용 효율적 운영 방법
- **자동 복구 시스템**: 장애 상황에서의 자동 복구 메커니즘 구축
- **고급 오케스트레이션**: 복잡한 컨테이너 환경의 효율적 관리"""
            else:  # Day2
                return """이 Day를 통해 다음을 학습합니다:

- **고가용성 아키텍처**: 장애에 강한 시스템 아키텍처 설계
- **고급 모니터링**: 포괄적인 모니터링 시스템 구축과 운영
- **고급 로드 밸런싱**: 트래픽 분산과 성능 최적화 기술
- **종합 프로젝트**: 실제 업무 환경과 유사한 프로젝트 경험"""
        
        return "이 Day를 통해 체계적인 학습을 진행합니다."
    
    def add_prerequisites(self):
        """사전 요구사항 추가"""
        print("\n📋 사전 요구사항 추가 중...")
        
        for course in self.courses:
            course_path = self.knowledge_base_path / course
            if not course_path.exists():
                continue
            
            # 과정 메인 README에 사전 요구사항 추가
            main_readme = course_path / 'README.md'
            if main_readme.exists():
                self.add_prerequisites_to_file(main_readme, course)
    
    def add_prerequisites_to_file(self, file_path: Path, course: str):
        """파일에 사전 요구사항 추가"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 이미 사전 요구사항이 있는지 확인
            if re.search(r'사전\s*요구사항|prerequisite|선수\s*지식', content, re.IGNORECASE):
                return
            
            # 사전 요구사항 템플릿 생성
            prerequisites = self.get_course_prerequisites(course)
            
            # 사전 요구사항 섹션 추가
            prerequisites_section = f"""
## 📋 사전 요구사항

{prerequisites}

"""
            
            # 학습 목표 다음에 추가
            if '## 🎯 학습 목표' in content:
                content = content.replace('## 🎯 학습 목표', f'## 🎯 학습 목표{prerequisites_section}')
            else:
                # 파일 시작 부분에 추가
                if content.startswith('# '):
                    lines = content.split('\n')
                    insert_index = 1
                    for i, line in enumerate(lines[1:], 1):
                        if line.startswith('## '):
                            insert_index = i
                            break
                    lines.insert(insert_index, prerequisites_section.strip())
                    new_content = '\n'.join(lines)
                else:
                    new_content = prerequisites_section + content
                
                content = new_content
            
            # 파일 저장
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            self.improvements_made.append({
                'file': str(file_path),
                'improvement': '사전 요구사항 추가',
                'course': course
            })
            
        except Exception as e:
            print(f"    ❌ 오류: {file_path} - {str(e)}")
    
    def get_course_prerequisites(self, course: str) -> str:
        """과정별 사전 요구사항 템플릿"""
        prerequisites = {
            'cloud_basic': """이 과정을 수강하기 전에 다음 사항들을 확인해주세요:

- **기본적인 컴퓨터 사용 능력**: 파일 관리, 인터넷 사용 등 기본적인 컴퓨터 활용 능력
- **인터넷 연결**: 안정적인 인터넷 연결 환경 (클라우드 서비스 사용을 위해 필요)
- **학습 시간**: 일일 2-3시간의 학습 시간 확보 (총 2일 과정)
- **학습 의지**: 새로운 기술에 대한 호기심과 학습 의지
- **선수 지식**: 특별한 선수 지식은 필요하지 않습니다. 초보자도 쉽게 따라할 수 있도록 설계되었습니다.""",
            
            'cloud_master': """이 과정을 수강하기 전에 다음 사항들을 확인해주세요:

- **Cloud Basic 과정 이수**: Cloud Basic 과정의 내용을 이해하고 있어야 합니다
- **기본적인 리눅스 명령어**: 터미널 사용과 기본적인 리눅스 명령어에 대한 이해
- **Git 기본 사용법**: 버전 관리 시스템 Git의 기본적인 사용법
- **개발 환경**: 로컬 개발 환경 구축 경험 (선택사항)
- **학습 시간**: 일일 3-4시간의 학습 시간 확보 (총 3일 과정)
- **실습 환경**: AWS와 GCP 계정 (무료 크레딧 사용 가능)""",
            
            'cloud_container': """이 과정을 수강하기 전에 다음 사항들을 확인해주세요:

- **Cloud Master 과정 이수**: Cloud Master 과정의 내용을 이해하고 있어야 합니다
- **Docker 기본 지식**: 컨테이너 기술에 대한 기본적인 이해
- **Kubernetes 기초**: Kubernetes의 기본 개념과 용어에 대한 이해
- **클라우드 경험**: AWS나 GCP에서 실제 서비스를 운영해본 경험
- **학습 시간**: 일일 4-5시간의 학습 시간 확보 (총 2일 과정)
- **고급 실습 환경**: AWS와 GCP의 고급 서비스 사용을 위한 계정과 권한"""
        }
        
        return prerequisites.get(course, "이 과정을 수강하기 전에 기본적인 컴퓨터 사용 능력이 필요합니다.")
    
    def add_friendly_messages(self):
        """친절한 안내 메시지 추가"""
        print("\n😊 친절한 안내 메시지 추가 중...")
        
        for course in self.courses:
            course_path = self.knowledge_base_path / course
            if not course_path.exists():
                continue
            
            # 과정 메인 README에 친절한 메시지 추가
            main_readme = course_path / 'README.md'
            if main_readme.exists():
                self.add_friendly_messages_to_file(main_readme, course)
    
    def add_friendly_messages_to_file(self, file_path: Path, course: str):
        """파일에 친절한 안내 메시지 추가"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 이미 친절한 메시지가 있는지 확인
            if re.search(r'안녕하세요|환영합니다|도움이 필요하시면', content, re.IGNORECASE):
                return
            
            # 친절한 메시지 템플릿
            friendly_message = f"""
## 👋 안녕하세요!

{self.get_course_friendly_message(course)}

**궁금한 점이 있으시면 언제든 문의해주세요!** 
문제가 발생하거나 도움이 필요하시면 언제든 연락주시면 친절하게 도와드리겠습니다.

"""
            
            # 파일 시작 부분에 추가
            if content.startswith('# '):
                lines = content.split('\n')
                insert_index = 1
                for i, line in enumerate(lines[1:], 1):
                    if line.startswith('## '):
                        insert_index = i
                        break
                lines.insert(insert_index, friendly_message.strip())
                new_content = '\n'.join(lines)
            else:
                new_content = friendly_message + content
            
            # 파일 저장
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            
            self.improvements_made.append({
                'file': str(file_path),
                'improvement': '친절한 안내 메시지 추가',
                'course': course
            })
            
        except Exception as e:
            print(f"    ❌ 오류: {file_path} - {str(e)}")
    
    def get_course_friendly_message(self, course: str) -> str:
        """과정별 친절한 메시지 템플릿"""
        messages = {
            'cloud_basic': """**Cloud Basic 과정에 오신 것을 환영합니다!** 🎉

이 과정은 클라우드 컴퓨팅을 처음 접하는 분들을 위해 특별히 설계되었습니다. 
AWS와 GCP의 기본 서비스들을 차근차근 배워보며, 실무에서 바로 활용할 수 있는 
실습 중심의 학습을 진행합니다.

초보자도 쉽게 따라할 수 있도록 단계별로 안내해드리겠습니다!""",
            
            'cloud_master': """**Cloud Master 과정에 오신 것을 환영합니다!** 🚀

이 과정은 Cloud Basic을 마스터한 분들을 위한 고급 과정입니다. 
Docker, GitHub Actions, CI/CD 파이프라인 등 현대적인 개발 도구들을 
실무 중심으로 학습하며, 실제 프로젝트에 바로 적용할 수 있는 
고급 기술들을 습득하게 됩니다.

함께 클라우드 마스터가 되어보세요!""",
            
            'cloud_container': """**Cloud Container 과정에 오신 것을 환영합니다!** 🐳

이 과정은 컨테이너 오케스트레이션의 최고봉인 Kubernetes를 중심으로 
고가용성과 확장성을 갖춘 시스템을 구축하는 방법을 학습합니다.

Kubernetes, 고가용성 아키텍처, 고급 모니터링 등 
엔터프라이즈급 시스템 구축에 필요한 모든 기술을 
실습을 통해 체험해보세요!"""
        }
        
        return messages.get(course, "이 과정에 오신 것을 환영합니다!")
    
    def add_learning_order(self):
        """학습 순서 명시화"""
        print("\n🛤️ 학습 순서 명시화 중...")
        
        for course in self.courses:
            learning_path = self.knowledge_base_path / course / 'learning-path.md'
            if learning_path.exists():
                self.add_learning_order_to_file(learning_path, course)
    
    def add_learning_order_to_file(self, file_path: Path, course: str):
        """파일에 학습 순서 추가"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 이미 학습 순서가 있는지 확인
            if re.search(r'학습\s*순서|learning\s*order|진행\s*순서', content, re.IGNORECASE):
                return
            
            # 학습 순서 템플릿 생성
            learning_order = self.get_course_learning_order(course)
            
            # 학습 순서 섹션 추가
            learning_order_section = f"""
## 🛤️ 학습 순서

{learning_order}

"""
            
            # 파일 시작 부분에 추가
            if content.startswith('# '):
                lines = content.split('\n')
                insert_index = 1
                for i, line in enumerate(lines[1:], 1):
                    if line.startswith('## '):
                        insert_index = i
                        break
                lines.insert(insert_index, learning_order_section.strip())
                new_content = '\n'.join(lines)
            else:
                new_content = learning_order_section + content
            
            # 파일 저장
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            
            self.improvements_made.append({
                'file': str(file_path),
                'improvement': '학습 순서 명시화',
                'course': course
            })
            
        except Exception as e:
            print(f"    ❌ 오류: {file_path} - {str(e)}")
    
    def get_course_learning_order(self, course: str) -> str:
        """과정별 학습 순서 템플릿"""
        orders = {
            'cloud_basic': """이 과정은 다음과 같은 순서로 진행됩니다:

### 1단계: 환경 준비 (30분)
- AWS 계정 생성 및 설정
- GCP 계정 생성 및 설정
- 기본 도구 설치 및 설정

### 2단계: Day1 - 기초 서비스 학습 (4시간)
- IAM 기초 및 사용자 관리
- 스토리지 서비스 이해 및 실습
- VM 서비스 기초 및 실습
- 문제해결 및 정리

### 3단계: Day2 - 서비스 비교 및 분석 (3시간)
- 컴퓨팅 서비스 비교 분석
- 데이터베이스 서비스 비교 분석
- 네트워킹 서비스 비교 분석
- 스토리지 서비스 비교 분석
- 종합 정리 및 다음 단계 준비

**💡 팁**: 각 단계를 순서대로 진행하시면 더 효과적으로 학습할 수 있습니다!""",
            
            'cloud_master': """이 과정은 다음과 같은 순서로 진행됩니다:

### 1단계: 환경 준비 (1시간)
- Docker 설치 및 기본 설정
- Git/GitHub 계정 설정
- GitHub Actions 활성화
- 클라우드 계정 권한 설정

### 2단계: Day1 - 개발 도구 마스터 (6시간)
- Docker 기초 및 고급 활용
- Git/GitHub 협업 워크플로우
- GitHub Actions CI/CD 파이프라인
- 클라우드 배포 전략

### 3단계: Day2 - 운영 최적화 (5시간)
- 비용 최적화 전략 및 실습
- 모니터링 시스템 구축
- 종합 실습 프로젝트
- 운영 모범 사례 학습

### 4단계: Day3 - 고급 아키텍처 (6시간)
- 자동 스케일링 시스템 구축
- 고급 로드 밸런싱
- 재해 복구 전략 수립
- 통합 시스템 구축

**💡 팁**: 각 Day의 내용을 순차적으로 학습하시면 체계적인 이해가 가능합니다!""",
            
            'cloud_container': """이 과정은 다음과 같은 순서로 진행됩니다:

### 1단계: 환경 준비 (1시간)
- Kubernetes 클러스터 설정
- Helm 설치 및 설정
- 모니터링 도구 준비
- 보안 정책 설정

### 2단계: Day1 - Kubernetes 고급 활용 (8시간)
- Kubernetes 고급 기능 학습
- 컨테이너 보안 정책 적용
- 비용 최적화 전략
- 자동 복구 시스템 구축
- 고급 오케스트레이션 실습

### 3단계: Day2 - 고가용성 아키텍처 (8시간)
- 고가용성 아키텍처 설계
- 고급 모니터링 시스템 구축
- 고급 로드 밸런싱 구현
- 종합 프로젝트 실습

**💡 팁**: 이 과정은 고급 과정이므로 이전 과정들을 충분히 학습한 후 진행하세요!"""
        }
        
        return orders.get(course, "이 과정은 단계별로 체계적으로 진행됩니다.")
    
    def improve_navigation(self):
        """네비게이션 개선"""
        print("\n🧭 네비게이션 개선 중...")
        
        for course in self.courses:
            course_path = self.knowledge_base_path / course
            if not course_path.exists():
                continue
            
            # 과정 메인 README 네비게이션 개선
            main_readme = course_path / 'README.md'
            if main_readme.exists():
                self.improve_navigation_in_file(main_readme, course)
    
    def improve_navigation_in_file(self, file_path: Path, course: str):
        """파일의 네비게이션 개선"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 이미 네비게이션이 있는지 확인
            if re.search(r'이전.*다음|previous.*next|←.*→', content, re.IGNORECASE):
                return
            
            # 네비게이션 섹션 생성
            navigation = self.get_course_navigation(course)
            
            # 파일 끝에 네비게이션 추가
            if not content.endswith('\n'):
                content += '\n'
            
            content += f"""
---

## 🧭 네비게이션

{navigation}

"""
            
            # 파일 저장
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            self.improvements_made.append({
                'file': str(file_path),
                'improvement': '네비게이션 개선',
                'course': course
            })
            
        except Exception as e:
            print(f"    ❌ 오류: {file_path} - {str(e)}")
    
    def get_course_navigation(self, course: str) -> str:
        """과정별 네비게이션 템플릿"""
        navigations = {
            'cloud_basic': """<div align="center">

[🏠 홈으로 돌아가기](/mcp_knowledge_base/index.md) | 
[📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | 
[🔗 학습 경로](/mcp_knowledge_base/cloud_basic/learning-path.md)

[📅 Day1 시작하기](/mcp_knowledge_base/cloud_basic/textbook/Day1/README.md) | 
[📅 Day2 시작하기](/mcp_knowledge_base/cloud_basic/textbook/Day2/README.md)

</div>""",
            
            'cloud_master': """<div align="center">

[🏠 홈으로 돌아가기](/mcp_knowledge_base/index.md) | 
[📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | 
[🔗 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

[📅 Day1 시작하기](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md) | 
[📅 Day2 시작하기](/mcp_knowledge_base/cloud_master/textbook/Day2/README.md) | 
[📅 Day3 시작하기](/mcp_knowledge_base/cloud_master/textbook/Day3/README.md)

</div>""",
            
            'cloud_container': """<div align="center">

[🏠 홈으로 돌아가기](/mcp_knowledge_base/index.md) | 
[📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | 
[🔗 학습 경로](/mcp_knowledge_base/cloud_container/learning-path.md)

[📅 Day1 시작하기](/mcp_knowledge_base/cloud_container/textbook/Day1/README.md) | 
[📅 Day2 시작하기](/mcp_knowledge_base/cloud_container/textbook/Day2/README.md)

</div>"""
        }
        
        return navigations.get(course, "네비게이션을 추가해주세요.")
    
    def improve_practice_guides(self):
        """실습 가이드 개선"""
        print("\n💻 실습 가이드 개선 중...")
        
        for course in self.courses:
            course_path = self.knowledge_base_path / course
            if not course_path.exists():
                continue
            
            # practice 디렉토리 점검
            practice_dirs = [
                course_path / 'textbook' / 'Day1' / 'practice',
                course_path / 'textbook' / 'Day2' / 'practice',
                course_path / 'textbook' / 'Day3' / 'practice'
            ]
            
            for practice_dir in practice_dirs:
                if practice_dir.exists():
                    for practice_file in practice_dir.glob('*.md'):
                        self.improve_practice_guide(practice_file, course)
    
    def improve_practice_guide(self, practice_file: Path, course: str):
        """실습 가이드 개선"""
        try:
            with open(practice_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 이미 실습 목표가 있는지 확인
            if re.search(r'실습\s*목표|practice\s*objective', content, re.IGNORECASE):
                return
            
            # 실습 목표 추가
            practice_objective = f"""
## 🎯 실습 목표

이 실습을 통해 다음을 달성할 수 있습니다:

- **이론과 실습의 결합**: 학습한 이론을 실제로 적용해보는 경험
- **문제해결 능력 향상**: 실습 중 발생하는 문제를 해결하는 능력 개발
- **실무 적용 능력**: 학습한 내용을 실제 업무에 적용할 수 있는 능력 향상
- **자신감 향상**: 성공적인 실습 완료를 통한 학습 자신감 증진

**💡 팁**: 실습 중 문제가 발생하면 문제해결 가이드를 참고하세요!

"""
            
            # 파일 시작 부분에 추가
            if content.startswith('# '):
                lines = content.split('\n')
                insert_index = 1
                for i, line in enumerate(lines[1:], 1):
                    if line.startswith('## '):
                        insert_index = i
                        break
                lines.insert(insert_index, practice_objective.strip())
                new_content = '\n'.join(lines)
            else:
                new_content = practice_objective + content
            
            # 파일 저장
            with open(practice_file, 'w', encoding='utf-8') as f:
                f.write(new_content)
            
            self.improvements_made.append({
                'file': str(practice_file),
                'improvement': '실습 가이드 개선',
                'course': course
            })
            
        except Exception as e:
            print(f"    ❌ 오류: {practice_file} - {str(e)}")
    
    def generate_improvement_report(self):
        """개선 보고서 생성"""
        report = f"""# 사용자 친화성 개선 보고서

## 🎉 개선 완료 사항

### 총 개선된 파일 수: {len(self.improvements_made)}개

### 개선 항목별 통계
"""
        
        # 개선 항목별 통계
        improvement_stats = {}
        for improvement in self.improvements_made:
            improvement_type = improvement['improvement']
            if improvement_type not in improvement_stats:
                improvement_stats[improvement_type] = 0
            improvement_stats[improvement_type] += 1
        
        for improvement_type, count in improvement_stats.items():
            report += f"- **{improvement_type}**: {count}개 파일\n"
        
        report += f"""
## 📋 상세 개선 내역

"""
        
        for improvement in self.improvements_made:
            report += f"### {improvement['improvement']}\n"
            report += f"- **파일**: {improvement['file']}\n"
            if 'course' in improvement:
                report += f"- **과정**: {improvement['course']}\n"
            elif 'course_day' in improvement:
                report += f"- **과정/일차**: {improvement['course_day']}\n"
            report += "\n"
        
        report += f"""
## 🎯 개선 효과

### 1. 초보자 접근성 향상
- ✅ **학습 목표 명시화**: 각 과정과 Day별로 명확한 학습 목표 제시
- ✅ **사전 요구사항 추가**: 학습자가 미리 준비해야 할 사항들 명시
- ✅ **친절한 안내 메시지**: 환영 메시지와 도움말 추가

### 2. 학습 경로 명확화
- ✅ **학습 순서 명시화**: 단계별 학습 순서와 예상 소요 시간 제시
- ✅ **네비게이션 개선**: 직관적인 이동 경로와 링크 구조 개선

### 3. 실습 가이드 품질 향상
- ✅ **실습 목표 추가**: 각 실습의 목표와 기대 효과 명시
- ✅ **단계별 가이드**: 체계적인 실습 진행을 위한 단계별 안내

## 🚀 다음 단계 권장사항

### 1. 사용자 피드백 수집
- 학습자들의 실제 사용 경험 수집
- 개선된 내용에 대한 만족도 조사
- 추가 개선이 필요한 부분 파악

### 2. 지속적인 모니터링
- 정기적인 사용자 친화성 점검
- 새로운 이슈 발생 시 즉시 대응
- 사용자 요청사항 반영

### 3. 고급 기능 추가
- 진행률 표시 기능
- 학습 진도 추적 시스템
- 개인화된 학습 경로 제안

## 🎉 결론

**총 {len(self.improvements_made)}개의 파일이 개선**되어 교육 과정의 사용자 친화성과 
초보자 접근성이 크게 향상되었습니다.

이제 학습자들이 더 쉽고 친근하게 교육 과정에 접근할 수 있으며, 
체계적인 학습을 통해 교육 목표를 달성할 수 있을 것입니다.

**함께 더 나은 교육 경험을 만들어가요!** 🚀
"""
        
        with open("user_friendliness_improvement_report.md", "w", encoding="utf-8") as f:
            f.write(report)
        
        print(f"\n📋 개선 보고서 생성: user_friendliness_improvement_report.md")

def main():
    """메인 함수"""
    improver = UserFriendlinessImprover()
    improver.run_improvements()

if __name__ == "__main__":
    main()
