# Cloud Master - 2일차: 고급 CI/CD 및 VM 기반 컨테이너 배포

<div align="center">

[← 이전: Cloud Master 1일차](../Day1/README) | [📚 전체 커리큘럼](../../../curriculum) | [다음: Cloud Master 3일차 →](../Day3/README)

</div>

<details>
<summary>📋 목차</summary>

1. [🎯 학습 목표](#-학습-목표)
2. [📚 실습 가이드](#-실습-가이드)
3. [🔧 실습 환경 준비](#-실습-환경-준비)
4. [🐳 Docker 고급 기법 및 최적화](#-docker-고급-기법-및-최적화)
5. [🚀 GitHub Actions 고급 워크플로우](#-github-actions-고급-워크플로우)
6. [☁️ VM 기반 컨테이너 배포 자동화](#-vm-기반-컨테이너-배포-자동화)
7. [🔄 완전 자동화된 배포 파이프라인](#-완전-자동화된-배포-파이프라인)
8. [📚 문제 해결 및 참고 자료](#-문제-해결-및-참고-자료)

</details>

---

## 🎯 학습 목표

### 핵심 학습 목표
- **Docker 고급 기법** 멀티스테이지 빌드, 이미지 최적화
- **GitHub Actions 고급** 매트릭스 빌드, 환경별 배포
- **VM 컨테이너 배포** 고가용성 컨테이너 오케스트레이션
- **완전 자동화** CI/CD 파이프라인 고도화

### 실습 후 달성할 수 있는 능력
- ✅ 프로덕션급 Docker 이미지 빌드 및 최적화
- ✅ 고급 GitHub Actions 워크플로우 구축
- ✅ VM 기반 고가용성 컨테이너 배포
- ✅ 완전 자동화된 배포 파이프라인 운영

### 예상 소요 시간
- **Docker 고급**: 120-150분
- **GitHub Actions 고급**: 90-120분
- **VM 컨테이너 배포**: 120-150분
- **완전 자동화**: 90-120분
- **전체 과정**: 6-8시간

---

## 🔧 실습 환경 준비

### 필수 소프트웨어 설치

#### 1. AWS CLI 설치 및 설정
```bash
# AWS CLI 설치 확인
aws --version

# AWS 자격증명 설정
aws configure

# 비용 관리 권한 확인
aws ce get-cost-and-usage --time-period Start=2024-01-01,End=2024-01-02 --granularity MONTHLY --metrics BlendedCost
```

#### 2. Google Cloud SDK 설치 및 설정
```bash
# gcloud CLI 설치 확인
gcloud --version

# GCP 인증
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

# 비용 관리 권한 확인
gcloud alpha billing budgets list --billing-account=YOUR_BILLING_ACCOUNT
```

#### 3. Kubernetes 도구 설치
```bash
# kubectl 설치
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# eksctl 설치 (AWS EKS용)
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
```

### 클라우드 계정 준비

#### AWS 계정 설정
- [ ] AWS 계정 생성 (무료 티어 가능)
- [ ] Cost Explorer 활성화
- [ ] Budgets 서비스 접근 권한 확인
- [ ] EKS 서비스 접근 권한 확인

#### Google Cloud Platform 계정 설정
- [ ] GCP 계정 생성 ($300 크레딧)
- [ ] Billing 계정 설정
- [ ] Cloud Monitoring API 활성화
- [ ] GKE 서비스 접근 권한 확인

### 실습 전 체크리스트

#### 환경 확인
- [ ] AWS CLI가 정상 설정되어 있는가?
```bash
aws sts get-caller-identity
```

- [ ] Google Cloud SDK가 정상 설정되어 있는가?
```bash
gcloud auth list
```

- [ ] kubectl이 정상 설치되어 있는가?
```bash
kubectl version --client
```

#### 계정 준비
- [ ] AWS 계정에 Cost Explorer, Budgets, EKS 서비스 접근 권한이 있는가?
- [ ] GCP 계정에 Billing, Monitoring, GKE 서비스 접근 권한이 있는가?
- [ ] 충분한 할당량(Quota)이 있는가?

---

## 📚 학습 자료

### 참고 문서
- [AWS 비용 관리 공식 문서](https://docs.aws.amazon.com/cost-management/)
- [AWS CloudWatch 공식 문서](https://docs.aws.amazon.com/cloudwatch/)
- [GCP 비용 관리 공식 문서](https://cloud.google.com/cost-management/docs)
- [GCP Cloud Monitoring 공식 문서](https://cloud.google.com/monitoring/docs)

### 유용한 링크
- [AWS Pricing Calculator](https://calculator.aws/)
- [Google Cloud Pricing Calculator](https://cloud.google.com/products/calculator)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Google Cloud Architecture Center](https://cloud.google.com/architecture)

---

## 🚀 시작하기

실습을 시작하기 전에 위의 체크리스트를 모두 확인하세요. 모든 준비가 완료되면 [1교시: 클라우드 비용 구조와 서비스 과금 체계](./cost-structure-guide)부터 시작하세요.

### 문제가 있나요?
실습 중 문제가 발생하면 [트러블슈팅 가이드](./troubleshooting-guide)를 참고하세요.

---

## 💡 핵심 개념 미리보기

### 클라우드 비용 구조
- **종량제(Pay-as-you-go)**: 사용한 만큼만 비용 지불
- **예약 인스턴스**: 장기 약정을 통한 할인 혜택
- **프리 티어**: 신규 사용자 대상 무료 혜택

### 비용 최적화 전략
- **리소스 최적화**: 사용하지 않는 리소스 식별 및 제거
- **자동 스케일링**: 트래픽에 따른 자동 리소스 조정
- **예산 관리**: 비용 한도 설정 및 알림

### 모니터링 및 알림
- **메트릭 수집**: CPU, 메모리, 네트워크 등 시스템 지표
- **알림 설정**: 임계값 초과 시 자동 알림
- **대시보드**: 실시간 모니터링 화면

### 종합 아키텍처
- **컨테이너 오케스트레이션**: Kubernetes 기반 서비스 관리
- **로드 밸런싱**: 트래픽 분산 및 고가용성
- **자동 복구**: 장애 발생 시 자동 복구 시스템
