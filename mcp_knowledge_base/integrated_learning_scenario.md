# 🎯 통합 학습 시나리오 가이드

<div align="center">

## 🏠 최상위 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/index.md)

## 📖 현재 위치
**통합 학습 시나리오 가이드**

## 🔗 관련 과정
[Cloud Basic 1일차](/mcp_knowledge_base/cloud_basic/textbook/Day1/README.md) | [Cloud Master 1일차](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md) | [Cloud Container 1일차](/mcp_knowledge_base/cloud_container/textbook/Day1/README.md)

</div>

## 🎯 학습 시나리오 개요

이 가이드는 **Cloud Basic → Cloud Master → Cloud Container** 과정을 체계적으로 학습할 수 있도록 설계된 통합 학습 시나리오입니다. 각 과정 간의 연계성을 강화하고, 실무 중심의 프로젝트를 통해 종합적인 클라우드 역량을 기를 수 있습니다.

## 📚 과정별 학습 시나리오

### 🟢 Cloud Basic (2일) - 클라우드 기초
**목표**: 클라우드 컴퓨팅의 기본 개념과 AWS/GCP 서비스 기초 습득

#### 1일차: AWS & GCP 기초 서비스 실습
- **학습 시나리오**: "첫 번째 클라우드 애플리케이션 배포"
- **핵심 실습**: 
  - AWS/GCP 계정 생성 및 기본 설정
  - IAM 사용자 및 권한 관리
  - EC2/Compute Engine 인스턴스 생성
  - S3/Cloud Storage 버킷 생성 및 파일 관리
- **실습 결과물**: 간단한 정적 웹사이트를 클라우드에 배포

#### 2일차: 네트워크, 보안 및 데이터베이스 실습
- **학습 시나리오**: "데이터베이스가 있는 웹 애플리케이션 구축"
- **핵심 실습**:
  - VPC/서브넷 구성
  - 보안 그룹/방화벽 설정
  - RDS/Cloud SQL 데이터베이스 생성
  - 웹 서버 + 데이터베이스 연동
- **실습 결과물**: 데이터베이스와 연동된 웹 애플리케이션

### 🟡 Cloud Master (3일) - 고급 CI/CD 및 VM 기반 컨테이너 배포
**목표**: Docker 컨테이너화와 CI/CD 파이프라인을 통한 자동화된 배포 시스템 구축

#### 1일차: Docker, Git/GitHub, GitHub Actions 기초
- **학습 시나리오**: "컨테이너화된 애플리케이션의 자동 배포"
- **핵심 실습**:
  - Docker 컨테이너화
  - Git/GitHub 버전 관리
  - GitHub Actions CI/CD 파이프라인
  - VM 기반 웹 애플리케이션 배포
- **실습 결과물**: 자동화된 배포 파이프라인이 있는 컨테이너화된 애플리케이션

#### 2일차: Docker 고급 기법 및 GitHub Actions 고급 워크플로우
- **학습 시나리오**: "마이크로서비스 아키텍처의 컨테이너 오케스트레이션"
- **핵심 실습**:
  - Docker Compose를 활용한 다중 서비스 관리
  - 멀티스테이지 빌드 및 이미지 최적화
  - 고급 GitHub Actions 워크플로우
  - 환경별 배포 전략
- **실습 결과물**: 마이크로서비스 아키텍처의 컨테이너화된 애플리케이션

#### 3일차: 고가용성 및 Auto Scaling 아키텍처
- **학습 시나리오**: "엔터프라이즈급 고가용성 시스템 구축"
- **핵심 실습**:
  - Multi-AZ, Multi-Region 아키텍처
  - 로드 밸런싱 및 Auto Scaling
  - 모니터링 및 로깅 시스템
  - 장애 복구 시뮬레이션
- **실습 결과물**: 고가용성 아키텍처의 프로덕션 레디 시스템

### 🔵 Cloud Container (2일) - 컨테이너 심화 과정
**목표**: Kubernetes 오케스트레이션과 고급 컨테이너 기술을 통한 엔터프라이즈급 시스템 구축

#### 1일차: Kubernetes 및 GKE 고급 오케스트레이션
- **학습 시나리오**: "Kubernetes 클러스터에서의 마이크로서비스 운영"
- **핵심 실습**:
  - Kubernetes 클러스터 아키텍처 이해
  - GKE 클러스터 생성 및 관리
  - Deployment, Service, Ingress 설정
  - ConfigMap, Secret, PersistentVolume 관리
- **실습 결과물**: Kubernetes에서 실행되는 마이크로서비스 애플리케이션

#### 2일차: 고가용성 및 확장성 아키텍처
- **학습 시나리오**: "엔터프라이즈급 컨테이너 플랫폼 구축"
- **핵심 실습**:
  - 고가용성 아키텍처 설계
  - 로드 밸런싱 및 Auto Scaling
  - 모니터링 및 로깅 시스템
  - 보안 및 네트워크 정책
- **실습 결과물**: 엔터프라이즈급 컨테이너 플랫폼

## 🔄 과정 간 연계성 강화

### 📈 학습 경로 연계
1. **Cloud Basic → Cloud Master**: 기초 클라우드 서비스 → 컨테이너화 및 자동화
2. **Cloud Master → Cloud Container**: VM 기반 배포 → 컨테이너 오케스트레이션
3. **전체 과정**: 점진적 복잡성 증가와 실무 중심 프로젝트

### 🎯 핵심 연계 프로젝트
- **프로젝트 1**: 정적 웹사이트 → 동적 웹 애플리케이션
- **프로젝트 2**: 단일 서비스 → 마이크로서비스 아키텍처
- **프로젝트 3**: 수동 배포 → 자동화된 CI/CD 파이프라인
- **프로젝트 4**: 단일 인스턴스 → 고가용성 클러스터

## 📊 학습 효과 측정

### 🎯 과정별 학습 목표 달성도
- **Cloud Basic**: 클라우드 기초 서비스 활용 능력
- **Cloud Master**: 컨테이너화 및 자동화 역량
- **Cloud Container**: 고급 오케스트레이션 및 운영 능력

### 📈 실무 적용도 평가
- **기초 수준**: 개인 프로젝트에 클라우드 서비스 적용
- **중급 수준**: 팀 프로젝트에 CI/CD 파이프라인 구축
- **고급 수준**: 엔터프라이즈급 시스템 아키텍처 설계

## 🛠️ 학습 지원 체계

### 📚 학습 자료
- **이론 가이드**: 각 기술의 개념 및 원리 설명
- **실습 가이드**: 단계별 실습 지침 및 예제
- **문제 해결**: 자주 발생하는 문제 및 해결 방법
- **참고 자료**: 공식 문서 및 추가 학습 자료

### 🤝 학습 지원
- **피드백 수집**: 각 과정 완료 후 학습 피드백 수집
- **질문 답변**: 실습 중 발생하는 질문에 대한 즉시 답변
- **진도 관리**: 개별 학습자 진도 추적 및 관리
- **성과 분석**: 학습 성과 분석 및 개선 방향 제시

## 🚀 다음 단계

### 📈 고급 과정
- **Cloud Advanced**: 서비스 메시, 보안, 성능 최적화
- **Cloud Expert**: 아키텍처 설계, 비용 최적화, 운영 자동화
- **Cloud Architect**: 엔터프라이즈 아키텍처 설계 및 컨설팅

### 🎯 실무 적용
- **개인 프로젝트**: 학습한 기술을 개인 프로젝트에 적용
- **팀 프로젝트**: 팀과 함께 실제 서비스 개발
- **오픈소스 기여**: 오픈소스 프로젝트에 기여
- **커뮤니티 활동**: 클라우드 커뮤니티에서 지식 공유

---

<div align="center">

## 🔗 관련 과정 및 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/index.md)

## 📖 현재 위치
**통합 학습 시나리오 가이드**

## 🔗 관련 과정
[Cloud Basic 1일차](/mcp_knowledge_base/cloud_basic/textbook/Day1/README.md) | [Cloud Master 1일차](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md) | [Cloud Container 1일차](/mcp_knowledge_base/cloud_container/textbook/Day1/README.md)

</div>
