# 🐳 Cloud Intermediate - 클라우드 중급 실무 과정

## 👋 안녕하세요!

**Cloud Intermediate 과정에 오신 것을 환영합니다!** 🚀

이 과정은 클라우드 기초를 완료한 분들을 위해 특별히 설계된 중급 실무 과정입니다. 
컨테이너 기술, Kubernetes, CI/CD 파이프라인을 통해 실무에서 바로 활용할 수 있는 
고급 클라우드 기술을 학습합니다.

실무 중심의 체계적인 학습으로 클라우드 전문가로 성장해보세요!

**궁금한 점이 있으시면 언제든 문의해주세요!** 
문제가 발생하거나 도움이 필요하시면 언제든 연락주시면 친절하게 도와드리겠습니다.

## 📋 사전 요구사항

이 과정을 수강하기 전에 다음 사항들을 확인해주세요:

- **Cloud Basic 과정 이수**: Cloud Basic 과정의 내용을 이해하고 있어야 합니다
- **Docker 기본 지식**: 컨테이너 기술에 대한 기본적인 이해
- **Git/GitHub 경험**: 버전 관리 및 협업 도구 사용 경험
- **클라우드 경험**: AWS나 GCP에서 기본 서비스를 사용해본 경험
- **학습 시간**: 일일 4-5시간의 학습 시간 확보 ["총 2일 과정"]
- **개발 환경**: 안정적인 개발 환경 ["WSL2, Docker Desktop 등"]

## 🎯 과정 소개

**Cloud Intermediate**는 컨테이너 기술과 Kubernetes를 중심으로 한 중급 실무 과정입니다. 
Prometheus + Grafana 모니터링 스택과 함께 실제 프로덕션 환경에서 사용되는 기술들을 단계별로 학습하며, 
CI/CD 파이프라인과 클라우드 배포까지 완전한 실무 역량을 기를 수 있습니다.

### 📋 과정 정보
- **대상자**: Cloud Basic 완료자, DevOps 엔지니어, 클라우드 개발자, 시스템 관리자
- **예상 소요시간**: 2일 ["총 16시간"]
- **난이도**: 중급 [Intermediate]
- **선수 요구사항**: 
  - Cloud Basic 과정 완료 또는 동등한 수준
  - Docker 기본 사용법 숙지
  - Git/GitHub 기본 사용법 이해
  - 기본적인 Linux 명령어 이해

## 📚 학습 목표

이 과정을 완료하면 다음과 같은 전문적인 능력을 갖추게 됩니다:

### 🎯 핵심 목표
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

## 📋 과정 개요

### 📅 Day 1: 컨테이너 및 Kubernetes 기초 ["8시간"]
**목표**: Docker 고급 활용과 Kubernetes 기초를 학습합니다

#### 🌅 오전 ["4시간"]
- **09:00-10:00**: Docker 고급 활용 ["Dockerfile 최적화, 멀티스테이지 빌드"]
- **10:00-11:00**: Docker Compose 고급 활용 및 컨테이너 보안
- **11:00-12:00**: Kubernetes 기초 개념 및 아키텍처 이해

#### 🌆 오후 ["4시간"]
- **13:00-14:00**: Kubernetes 기본 리소스 [Pod, Service, Deployment]
- **14:00-15:00**: ConfigMap, Secret, 네트워킹 실습
- **15:00-16:00**: 클라우드 Kubernetes [EKS, GKE] 기초
- **16:00-17:00**: 종합 실습 및 정리

### 📅 Day 2: CI/CD, 클라우드 배포 및 모니터링 ["8시간"]
**목표**: CI/CD 파이프라인, 클라우드 배포, Prometheus + Grafana 모니터링을 학습합니다

#### 🌅 오전 ["4시간"]
- **09:00-10:00**: GitHub Actions 고급 워크플로우
- **10:00-11:00**: 자동화된 Docker 이미지 빌드 및 푸시
- **11:00-12:00**: 환경별 배포 전략 및 보안 스캔
- **12:00-13:00**: Prometheus + Grafana 모니터링 스택 구축

#### 🌆 오후 ["4시간"]
- **13:00-14:00**: AWS ECS, GCP Cloud Run 배포 실습
- **14:00-15:00**: 로드 밸런싱, 도메인, SSL 설정
- **15:00-16:00**: AWS CloudWatch, GCP Cloud Monitoring 설정
- **16:00-17:00**: 종합 프로젝트 및 다음 단계 안내

## 🚀 시작하기

### 1️⃣ 사전 준비
다음 항목들을 미리 준비해주세요:

- **Cloud Basic 완료**: 이전 과정의 내용을 숙지하고 있어야 합니다
- **개발 환경**: WSL2, Docker Desktop, VS Code
- **클라우드 계정**: AWS Free Tier, GCP Free Tier 계정
- **GitHub 계정**: 코드 저장소 및 CI/CD 사용

### 2️⃣ 환경 설정
```bash
# Docker Desktop 설치 확인
docker --version
docker-compose --version

# kubectl 설치
curl -LO "https://dl.k8s.io/release/$[curl -L -s https://dl.k8s.io/release/stable.txt]/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# AWS CLI 설정 확인
aws --version
aws configure list

# GCP CLI 설정 확인
gcloud --version
gcloud auth list
```

### 3️⃣ 자동화 스크립트
Cloud Intermediate 과정의 통합 스크립트들을 활용하세요:

- ["통합 컨테이너 도우미"][repo/scripts/cloud-intermediate-helper.sh] - 모든 컨테이너 실습 통합 관리
- ["Day1 실습 스크립트"][repo/scripts/day1-practice.sh] - Docker, Kubernetes 실습
- ["Day2 실습 스크립트"][repo/scripts/day2-practice.sh] - CI/CD, 클라우드 배포 실습
- ["환경 체크"][_setup_wsl/environment-check.sh] - 실습 환경 자동 검증

### 4️⃣ 첫 번째 실습 시작
1. Day 1 실습 가이드로 이동
2. ["Docker 고급 활용"](textbook/Day1/practice/docker-advanced.md) 따라하기
3. ["Kubernetes 기초"](textbook/Day1/practice/kubernetes-basics.md) 따라하기

## 📚 학습 자료

### 📖 교재
- Day 1: 컨테이너 및 Kubernetes 기초
- Day 2: CI/CD 및 클라우드 배포

### 🔧 실습 가이드
- ["Docker 고급 활용"](textbook/Day1/practice/docker-advanced.md)
- ["Kubernetes 기초"](textbook/Day1/practice/kubernetes-basics.md)
- ["클라우드 컨테이너 서비스"](textbook/Day1/practice/cloud-container-services.md)
- ["CI/CD 파이프라인"](textbook/Day2/practice/cicd-pipeline.md)
- ["클라우드 배포"](textbook/Day2/practice/cloud-deployment.md)
- ["모니터링 기초"](textbook/Day2/practice/monitoring-basics.md) ["Prometheus + Grafana 포함"]

### 🛠️ 설치 가이드
- ["Docker Desktop 설치"][_setup_wsl/install-docker-wsl.sh]
- ["kubectl 설치"][_setup_wsl/install-kubectl-wsl.sh]
- ["AWS CLI 설정"][_setup_wsl/install-aws-cli-wsl.sh]
- ["GCP CLI 설정"][_setup_wsl/install-gcp-cli-wsl.sh]

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
- [ ] Prometheus + Grafana 모니터링 스택 구축
- [ ] AWS ECS, GCP Cloud Run 배포 완료
- [ ] 로드 밸런싱 및 SSL 설정 완료
- [ ] AWS CloudWatch, GCP Cloud Monitoring 설정 완료
- [ ] 모니터링 및 로깅 시스템 구축 완료

## ❓ 자주 묻는 질문 [FAQ]

### Q1: Cloud Basic을 완료하지 않았는데 수강할 수 있나요?
**A**: Cloud Basic 과정을 먼저 완료하는 것을 강력히 권장합니다. 이 과정은 중급 수준의 내용으로 구성되어 있어 기본 지식이 필요합니다.

### Q2: Docker 경험이 없어도 괜찮나요?
**A**: Docker 기본 사용법을 숙지하고 있어야 합니다. Cloud Basic 과정에서 Docker 기초를 학습하거나, 별도로 Docker 기초를 학습한 후 수강하세요.

### Q3: Kubernetes를 처음 배우는데 따라갈 수 있나요?
**A**: 네, 괜찮습니다! 이 과정에서 Kubernetes 기초부터 차근차근 학습할 수 있습니다.

### Q4: 실제 프로덕션 환경에 바로 적용할 수 있나요?
**A**: 네, 가능합니다! 이 과정의 모든 내용은 실제 프로덕션 환경에서 사용되는 기술들입니다.

### Q5: 이 과정을 완료하면 어떤 자격을 얻을 수 있나요?
**A**: 이 과정을 완료하면 컨테이너 및 Kubernetes 중급 수준의 역량을 갖추게 되며, CKA[Certified Kubernetes Administrator] 시험 준비에도 도움이 됩니다.

## 🔗 관련 과정

### 📚 전체 커리큘럼
- ["전체 커리큘럼 보기"](curriculum.md)
- ["학습 경로 안내"](learning-path.md)

### 🚀 이전 단계
- Cloud Basic 과정 - 클라우드 기초

### 🏠 다음 단계
- Cloud Master 과정 - 고급 CI/CD 및 모니터링
- Cloud Container 과정 - 고급 컨테이너 오케스트레이션

### 🏠 홈으로
- ["통합 인덱스"](index.md)

## 📞 문의 및 지원

### 💬 학습 지원
- **실시간 질문**: 각 실습 가이드의 댓글 섹션 활용
- **문제 신고**: GitHub Issues를 통한 버그 신고
- **기능 요청**: 새로운 기능이나 개선사항 제안

### 📧 연락처
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: ["프로젝트 저장소"][https://github.com/jungfrau70/aws_gcp.git]

## 🎉 Cloud Intermediate 과정을 시작하세요!

<div align="center">

["🚀 Day 1 실습 시작하기"](textbook/Day1/README.md) | 
["📚 전체 커리큘럼 보기"](curriculum.md) | 
["🏠 홈으로 돌아가기"](index.md)

</div>

---

## 🧭 네비게이션

<div align="center">

["🏠 홈으로 돌아가기"](index.md) | ["📚 전체 커리큘럼"](curriculum.md) | ["🔗 학습 경로"](learning-path.md)

</div>
