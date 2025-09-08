# AWS/GCP 실전 마스터 3일차 교안

## 📋 목차
1. [실습 환경 준비](#실습-환경-준비)
2. [1교시: 클라우드 비용 구조와 서비스 과금 체계](./cost-structure-guide.md)
3. [2교시: 클라우드 과금 예측 및 리소스 비용 최적화](./cost-optimization-guide.md)
4. [3교시: CloudWatch / Cloud Monitoring을 활용한 서비스 모니터링](./monitoring-guide.md)
5. [4교시: 종합 실습 - 컨테이너 자동 배포 + 로드밸런싱 + 오토스케일링](./comprehensive-practice-guide.md)
6. [트러블슈팅 가이드](./troubleshooting-guide.md)

---

## 🎯 학습 목표

이 3일차 과정을 통해 다음을 학습합니다:

- **클라우드 비용 구조** 이해 및 과금 체계 분석
- **비용 예측 및 최적화** 전략 수립
- **서비스 모니터링** 및 알림 시스템 구축
- **종합적인 클라우드 아키텍처** 설계 및 운영

---

## ⏰ 일정 및 소요 시간

| 교시 | 내용 | 소요 시간 |
|------|------|-----------|
| 1교시 | 클라우드 비용 구조와 서비스 과금 체계 이해 | 60분 |
| 2교시 | 클라우드 과금 예측 및 리소스 비용 최적화 실습 | 60분 |
| 3교시 | CloudWatch / Cloud Monitoring을 활용한 서비스 모니터링 | 60분 |
| 4교시 | 종합 실습 - 컨테이너 자동 배포 + 로드밸런싱 + 오토스케일링 | 90분 |
| **총 소요 시간** | | **4시간 30분** |

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

실습을 시작하기 전에 위의 체크리스트를 모두 확인하세요. 모든 준비가 완료되면 [1교시: 클라우드 비용 구조와 서비스 과금 체계](./cost-structure-guide.md)부터 시작하세요.

### 문제가 있나요?
실습 중 문제가 발생하면 [트러블슈팅 가이드](./troubleshooting-guide.md)를 참고하세요.

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
