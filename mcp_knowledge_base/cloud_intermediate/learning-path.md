# 🐳 Cloud Intermediate - 학습 경로

## 📚 과정 개요

**Cloud Intermediate**는 컨테이너 기술과 Kubernetes를 중심으로 한 중급 실무 과정입니다. 
실제 프로덕션 환경에서 사용되는 기술들을 단계별로 학습하며, 
CI/CD 파이프라인과 클라우드 배포까지 완전한 실무 역량을 기를 수 있습니다.

## 🎯 학습 목표

### 📋 핵심 목표
- **Docker 고급 활용**: Dockerfile 최적화, 멀티스테이지 빌드, 컨테이너 보안
- **Kubernetes 기초**: Pod, Service, Deployment, ConfigMap, Secret 관리
- **클라우드 컨테이너 서비스**: AWS ECS, GCP Cloud Run, EKS, GKE 활용
- **CI/CD 파이프라인**: GitHub Actions를 활용한 자동화된 배포 시스템
- **모니터링 기초**: CloudWatch, Cloud Monitoring을 활용한 기본 모니터링

### 🚀 실무 적용 목표
- **컨테이너 기반 개발**: 실제 프로젝트에서 컨테이너 기술 활용
- **자동화된 배포**: CI/CD 파이프라인을 통한 효율적인 배포
- **클라우드 네이티브**: 클라우드 환경에 최적화된 애플리케이션 개발
- **문제 해결**: 컨테이너 및 클라우드 관련 문제 해결 능력

## 📅 2일 커리큘럼

### 📅 Day 1: 컨테이너 및 Kubernetes 기초 ["8시간"]

#### 🌅 오전 ["4시간"]
- **09:00-10:00**: Docker 고급 활용 ["Dockerfile 최적화, 멀티스테이지 빌드"]
- **10:00-11:00**: Docker Compose 고급 활용 및 컨테이너 보안
- **11:00-12:00**: Kubernetes 기초 개념 및 아키텍처 이해

#### 🌆 오후 ["4시간"]
- **13:00-14:00**: Kubernetes 기본 리소스 [Pod, Service, Deployment]
- **14:00-15:00**: ConfigMap, Secret, 네트워킹 실습
- **15:00-16:00**: 클라우드 Kubernetes [EKS, GKE] 기초
- **16:00-17:00**: 종합 실습 및 정리

### 📅 Day 2: CI/CD 및 클라우드 배포 ["8시간"]

#### 🌅 오전 ["4시간"]
- **09:00-10:00**: GitHub Actions 고급 워크플로우
- **10:00-11:00**: 자동화된 Docker 이미지 빌드 및 푸시
- **11:00-12:00**: 환경별 배포 전략 및 보안 스캔

#### 🌆 오후 ["4시간"]
- **13:00-14:00**: AWS ECS, GCP Cloud Run 배포 실습
- **14:00-15:00**: 로드 밸런싱, 도메인, SSL 설정
- **15:00-16:00**: 모니터링 및 로깅 시스템 구축
- **16:00-17:00**: 종합 프로젝트 및 다음 단계 안내

## 🗂️ 학습 자료 구조

### 📖 Day 1: 컨테이너 및 Kubernetes 기초
- ["Docker 고급 활용"][textbook/Day1/practice/docker-advanced.md]
- ["Kubernetes 기초"][textbook/Day1/practice/kubernetes-basics.md]
- ["클라우드 컨테이너 서비스"][textbook/Day1/practice/cloud-container-services.md]

### 📖 Day 2: CI/CD 및 클라우드 배포
- ["CI/CD 파이프라인"][textbook/Day2/practice/cicd-pipeline.md]
- ["클라우드 배포"][textbook/Day2/practice/cloud-deployment.md]
- ["모니터링 기초"][textbook/Day2/practice/monitoring-basics.md]

## 🛠️ 실습 환경

### 필수 도구
- **Docker Desktop**: 컨테이너 실행 환경
- **kubectl**: Kubernetes 클러스터 관리
- **Git**: 버전 관리
- **GitHub**: 코드 저장소 및 CI/CD
- **AWS CLI**: AWS 서비스 관리
- **GCP CLI**: GCP 서비스 관리

### 클라우드 계정
- **AWS**: Free Tier 계정 ["12개월 무료"]
- **GCP**: Free Tier 계정 ["$300 크레딧"]

## 🚀 시작하기

### 1️⃣ 사전 준비
- ["Cloud Basic 과정 완료"][cloud_basic/README.md]
- ["Docker Desktop 설치"][_setup_wsl/install-docker-wsl.sh]
- ["kubectl 설치"][_setup_wsl/install-kubectl-wsl.sh]
- ["AWS CLI 설정"][_setup_wsl/install-aws-cli-wsl.sh]
- ["GCP CLI 설정"][_setup_wsl/install-gcp-cli-wsl.sh]

### 2️⃣ 환경 검증
```bash
# 환경 체크 스크립트 실행
./_setup_wsl/environment-check.sh
```

### 3️⃣ Day 1 시작
- ["Docker 고급 활용"][textbook/Day1/practice/docker-advanced.md]
- ["Kubernetes 기초"][textbook/Day1/practice/kubernetes-basics.md]
- ["클라우드 컨테이너 서비스"][textbook/Day1/practice/cloud-container-services.md]

### 4️⃣ Day 2 시작
- ["CI/CD 파이프라인"][textbook/Day2/practice/cicd-pipeline.md]
- ["클라우드 배포"][textbook/Day2/practice/cloud-deployment.md]
- ["모니터링 기초"][textbook/Day2/practice/monitoring-basics.md]

## ✅ 학습 체크리스트

### Day 1 완료 확인
- [ ] Docker 고급 활용 ["Dockerfile 최적화, 멀티스테이지 빌드"]
- [ ] Docker Compose 고급 활용 및 컨테이너 보안
- [ ] Kubernetes 기본 개념 이해
- [ ] Pod, Service, Deployment 실습 완료
- [ ] ConfigMap, Secret 관리 완료
- [ ] EKS, GKE 클러스터 생성 및 연결 성공

### Day 2 완료 확인
- [ ] GitHub Actions 고급 워크플로우 구축
- [ ] 자동화된 Docker 이미지 빌드 및 푸시
- [ ] 환경별 배포 전략 구현
- [ ] AWS ECS, GCP Cloud Run 배포 완료
- [ ] 로드 밸런싱 및 SSL 설정 완료
- [ ] 모니터링 및 로깅 시스템 구축 완료

## 🔗 관련 과정

### 📚 전체 커리큘럼
- ["전체 커리큘럼 보기"][curriculum.md]
- ["학습 경로 안내"][learning-path.md]

### 🚀 이전 단계
- Cloud Basic 과정 - 클라우드 기초

### 🏠 다음 단계
- Cloud Master 과정 - 고급 CI/CD 및 모니터링
- Cloud Container 과정 - 고급 컨테이너 오케스트레이션

### 🏠 홈으로
- ["통합 인덱스"][index.md]

## 🧭 네비게이션

<div align="center">

["🏠 홈으로 돌아가기"][index.md] | ["📚 전체 커리큘럼"][curriculum.md] | ["🔗 학습 경로"][learning-path.md]

</div>
