# Cloud Master - 2일차: 고급 CI/CD 및 VM 기반 컨테이너 배포 이론 및 실습

<details>
<summary>📋 목차</summary>

## 🎯 강의 시나리오 (표준 순서)

1. [🎯 학습 목표](#-학습-목표)
2. [🔧 실습 환경 준비](#-실습-환경-준비)
3. [✅ 실습 환경 확인](#-실습-환경-확인)
4. [📚 이론 학습](#-이론-학습)
5. [🛠️ 실습 학습](#-실습-학습)
6. [🧹 실습 정리](#-실습-정리)

## 📚 참고 자료

1. [📚 문제 해결 및 참고 자료](#-문제-해결-및-참고-자료)

</details>


## 🎯 학습 목표

### 핵심 학습 목표

- **Docker 고급 기법** 멀티스테이지 빌드, 이미지 최적화
- **GitHub Actions 고급** 매트릭스 빌드, 환경별 배포
- **Kubernetes 기초** kubectl 명령어, EKS/GKE 클러스터 생성, 기본 배포
- **VM 컨테이너 배포** 고가용성 컨테이너 오케스트레이션
- **완전 자동화** CI/CD 파이프라인 고도화

### 실습 후 달성할 수 있는 능력

- ✅ 프로덕션급 Docker 이미지 빌드 및 최적화
- ✅ 고급 GitHub Actions 워크플로우 구축
- ✅ Kubernetes 기초 명령어 및 클러스터 관리
- ✅ VM 기반 고가용성 컨테이너 배포
- ✅ 완전 자동화된 배포 파이프라인 운영

### 예상 소요 시간

- **Docker 고급**: 120-150분
- **GitHub Actions 고급**: 90-120분
- **Kubernetes 기초**: 90-120분
- **VM 컨테이너 배포**: 120-150분
- **완전 자동화**: 90-120분
- **전체 과정**: 7-9시간

---

## 🔧 실습 환경 준비

### 필수 도구 설치

#### AWS CLI 설치 및 설정
```bash
# AWS CLI 설치 확인
aws --version

# AWS CLI 설정
aws configure
```

#### gcloud CLI 설치 및 설정
```bash
# gcloud CLI 설치 확인
gcloud --version

# gcloud CLI 설정
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

#### Docker 및 Docker Compose 설치
```bash
# Docker 설치 확인
docker --version
docker-compose --version

# Docker 서비스 시작
sudo systemctl start docker
sudo systemctl enable docker
```

#### Git 설치 및 설정
```bash
# Git 설치 확인
git --version

# Git 설정
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

#### kubectl 설치 (Kubernetes 실습용)
```bash
# kubectl 설치 확인
kubectl version --client

# kubectl 설치 (Linux)
curl -LO "https:///dl.k8s.io/release/$(curl -L -s https:///dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

### 클라우드 계정 설정

#### AWS 계정 설정
- [AWS 계정 생성 및 설정](/mcp_knowledge_base/cloud_basic/accounts/AWS계정가입.md)
- IAM 사용자 생성 및 권한 설정
- EC2 키 페어 생성

#### GCP 계정 설정
- [GCP 계정 생성 및 설정](/mcp_knowledge_base/cloud_basic/accounts/GCP_개인계정가입.md)
- 프로젝트 생성 및 활성화
- 서비스 계정 생성 및 키 다운로드

---

## 📚 이론 학습

<details>
<summary>🐳 Docker 고급 기법 및 최적화</summary>

#### 멀티스테이지 빌드란?

하나의 Dockerfile에서 여러 단계의 빌드를 수행하여 최종 이미지 크기를 최적화하는 기법입니다.

#### 멀티스테이지 빌드 장점

- **이미지 크기 최적화**: 빌드 도구를 최종 이미지에서 제거
- **보안 강화**: 불필요한 빌드 도구 제거로 공격 표면 감소
- **빌드 효율성**: 캐시를 활용한 빠른 빌드
- **레이어 최적화**: 필요한 레이어만 포함

#### Docker 이미지 최적화 기법

- **Alpine Linux 사용**: 경량화된 베이스 이미지
- **레이어 최소화**: RUN 명령어 통합
- **.dockerignore 사용**: 불필요한 파일 제외
- **특권 사용자 제거**: 보안 강화

#### Docker Compose 고급 기능

- **환경 변수**: .env 파일을 통한 설정 관리
- **볼륨 마운트**: 데이터 영속성 보장
- **네트워크 설정**: 서비스 간 통신 제어
- **헬스 체크**: 서비스 상태 모니터링

</details>

<details>
<summary>🚀 GitHub Actions 고급 워크플로우</summary>

#### 매트릭스 빌드란?

여러 환경, 버전, 플랫폼에서 동시에 빌드를 실행하는 GitHub Actions 기능입니다.

#### 매트릭스 빌드 장점

- **병렬 실행**: 여러 환경에서 동시 빌드
- **테스트 커버리지**: 다양한 환경에서 테스트
- **효율성**: 시간 절약 및 리소스 활용
- **일관성**: 동일한 코드로 모든 환경 테스트

#### 환경별 배포 전략

- **Development**: 개발 환경, 빠른 피드백
- **Staging**: 프로덕션과 유사한 환경
- **Production**: 실제 서비스 환경
- **Feature**: 기능별 임시 환경

#### 고급 워크플로우 패턴

- **조건부 실행**: 특정 조건에서만 실행
- **의존성 관리**: 작업 간 의존성 설정
- **시크릿 관리**: 민감한 정보 보안 관리
- **아티팩트 관리**: 빌드 결과물 관리

</details>

<details>
<summary>☸️ Kubernetes 기초 및 클러스터 관리</summary>

#### Kubernetes란?

컨테이너화된 애플리케이션의 배포, 확장, 관리를 자동화하는 오픈소스 플랫폼입니다.

#### Kubernetes 핵심 개념

- **클러스터**: 노드들의 집합
- **노드**: 워커 머신
- **Pod**: 배포 가능한 최소 단위
- **서비스**: Pod 집합에 대한 네트워크 접근
- **네임스페이스**: 리소스의 논리적 분할

#### EKS vs GKE 비교

| 특징 | EKS | GKE |
|------|-----|-----|
| **관리 복잡도** | 높음 | 낮음 |
| **비용** | 높음 | 중간 |
| **통합성** | AWS 중심 | Google 중심 |
| **업데이트** | 수동 | 자동 |

#### 클러스터 관리 모범 사례

- **리소스 제한**: CPU, 메모리 제한 설정
- **헬스 체크**: Pod 상태 모니터링
- **로깅**: 중앙화된 로그 관리
- **모니터링**: 메트릭 수집 및 알림

</details>

<details>
<summary>🔄 완전 자동화된 배포 파이프라인</summary>

#### VM 기반 컨테이너 배포란?

가상머신에 컨테이너를 배포하여 고가용성과 확장성을 확보하는 방식입니다.

#### VM 기반 배포 장점

- **기존 인프라 활용**: 기존 VM 인프라 재사용
- **비용 효율성**: 컨테이너 오케스트레이션 도구 없이도 확장 가능
- **단순성**: 복잡한 클러스터 관리 불필요
- **유연성**: 다양한 배포 전략 적용 가능

#### 고가용성 설계

- **로드 밸런싱**: 트래픽 분산
- **자동 스케일링**: 워크로드에 따른 확장/축소
- **헬스 체크**: 서비스 상태 모니터링
- **장애 복구**: 자동 장애 감지 및 복구

#### 컨테이너 오케스트레이션 도구

- **Docker Swarm**: 간단한 컨테이너 오케스트레이션
- **Docker Compose**: 다중 컨테이너 애플리케이션 관리
- **Portainer**: Docker 관리 UI
- **Traefik**: 동적 로드 밸런서

</details>

<details>
<summary>🔄 완전 자동화된 배포 파이프라인 이론</summary>

#### 완전 자동화란?

코드 커밋부터 프로덕션 배포까지 모든 과정이 자동으로 수행되는 시스템입니다.

#### 자동화 파이프라인 단계

1. **코드 커밋**: 개발자가 코드 변경
2. **자동 빌드**: CI 시스템이 자동으로 빌드
3. **자동 테스트**: 단위 테스트, 통합 테스트 실행
4. **자동 배포**: 테스트 통과 시 자동 배포
5. **모니터링**: 배포 후 상태 모니터링

#### GitOps 모델

- **선언적 설명**: 시스템 상태를 코드로 관리
- **버전 관리**: Git을 통한 모든 변경사항 추적
- **자동화**: 변경사항을 자동으로 클러스터에 적용
- **지속적 모니터링**: 실제 상태와 원하는 상태 비교

#### 배포 전략

- **Blue-Green**: 두 환경을 번갈아가며 배포
- **Rolling**: 점진적으로 인스턴스 교체
- **Canary**: 소규모 트래픽으로 테스트 후 전체 배포
- **A/B Testing**: 사용자 그룹별 다른 버전 배포

</details>

---

## 🛠️ 실습 학습

### 📁 실습 자료 구조
- **실습 가이드**: `practices/` - 이론적 실습 가이드 (마크다운)
- **실습 코드**: `repos/samples/day2/` - 실제 실행 가능한 코드
- **자동화 스크립트**: `repos/automation/day2/` - 실습 자동화 도구
- **클라우드 스크립트**: `repos/cloud-scripts/` - 클라우드 리소스 관리

<details>
<summary>🔧 실습 환경 준비</summary>

### 📦 필수 소프트웨어 설치

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

#### 3. 컨테이너 관리 도구 설치

```bash
# Docker Compose 설치 (VM 기반 컨테이너 오케스트레이션용)
sudo curl -L "https:///github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# kubectl 설치 (Kubernetes 클러스터 관리용)
curl -LO "https:///dl.k8s.io/release/$(curl -L -s https:///dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# eksctl 설치 (AWS EKS 클러스터 관리용)
curl --silent --location "https:///github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Docker Swarm 초기화 (선택사항)
docker swarm init
```

### ☁️ 클라우드 계정 준비

#### AWS 계정 설정

- [ ] AWS 계정 생성 (무료 티어 가능)
- [ ] Cost Explorer 활성화
- [ ] Budgets 서비스 접근 권한 확인
- [ ] ECS 서비스 접근 권한 확인 (선택사항)

#### Google Cloud Platform 계정 설정

- [ ] GCP 계정 생성 ($300 크레딧)
- [ ] Billing 계정 설정
- [ ] Cloud Monitoring API 활성화
- [ ] GKE 서비스 접근 권한 확인

### ✅ 실습 전 체크리스트

### ✅ 실습 환경 확인

#### 자동 환경 체크 (권장)
```bash
# 통합 환경 체크 스크립트 실행 (Kubernetes 포함)
./mcp_knowledge_base/cloud_master/repos/cloud-scripts/environment-check.sh day2
```

#### 수동 환경 확인
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

#### 환경 체크 결과 해석
- **90% 이상**: 실습 준비 완료 ✅
- **70-89%**: 일부 실습 제한 가능 ⚠️
- **70% 미만**: 환경 설정 필요 ❌

#### 계정 준비

- [ ] AWS 계정에 Cost Explorer, Budgets, EKS 서비스 접근 권한이 있는가?
- [ ] GCP 계정에 Billing, Monitoring, GKE 서비스 접근 권한이 있는가?
- [ ] 충분한 할당량(Quota)이 있는가?

---
</details>


<details>
<summary>🔧 실습 가이드</summary>


### 🚀 시작하기

실습을 시작하기 전에 위의 체크리스트를 모두 확인하세요. 모든 준비가 완료되면 [1교시: 클라우드 비용 구조 가이드](/mcp_knowledge_base/cloud_master/textbook/Day2/guides/cost-structure-guide.md)부터 시작하세요.


### 📖 상세 실습 가이드

- 🔗 [클라우드 비용 구조 가이드](/mcp_knowledge_base/cloud_master/textbook/Day2/guides/cost-structure-guide.md) - AWS/GCP 과금 모델 이해
- 🔗 [비용 최적화 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/cost-optimization-guide.md) - 비용 예측 및 최적화
- 🔗 [모니터링 가이드](/mcp_knowledge_base/cloud_master/textbook/Day2/guides/monitoring-guide.md) - CloudWatch/Cloud Monitoring 설정
- 🔗 [종합 실습 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/comprehensive-practice-guide.md) - EKS/GKE 컨테이너 오케스트레이션

### ⚠️ 실습 주의사항 및 문제 해결

#### 환경 요구사항
- **최소 사양**: 16GB RAM, 100GB 디스크 공간, 8코어 CPU
- **네트워크**: 안정적인 인터넷 연결 (Kubernetes 이미지 다운로드용)
- **OS**: Windows 10/11, macOS 10.15+, Ubuntu 20.04+

#### 자주 발생하는 문제
1. **Docker 멀티스테이지 빌드 실패**
   - 해결방법: Dockerfile 문법 확인, 빌드 컨텍스트 확인
   - 명령어: `docker build --no-cache -t 이미지명 .`

2. **Kubernetes 클러스터 구성 실패**
   - 해결방법: minikube 또는 kind 설치 확인, 리소스 할당 확인
   - 명령어: `kubectl cluster-info`로 클러스터 상태 확인

3. **GitHub Actions 시크릿 사용 실패**
   - 해결방법: 저장소 시크릿 설정 확인, 워크플로우 파일 문법 검사
   - 확인: Settings > Secrets and variables > Actions

4. **VM 컨테이너 배포 실패**
   - 해결방법: Docker 설치 확인, 포트 설정 확인, 방화벽 규칙 확인
   - 명령어: `docker ps`, `netstat -tlnp`로 상태 확인

#### 실습 검증 방법
- **Docker**: `docker images`, `docker system df`로 이미지 최적화 확인
- **Kubernetes**: `kubectl get pods`, `kubectl get services`로 배포 상태 확인
- **GitHub Actions**: Actions 탭에서 워크플로우 실행 상태 확인
- **VM 배포**: `curl http://VM_IP:포트`로 서비스 접속 확인

### 🛠️ 문제 해결 가이드

- 🔗 [트러블슈팅 가이드](/mcp_knowledge_base/cloud_basic/textbook/Day1/troubleshooting-guide.md) - 비용 관리, 모니터링, Kubernetes 문제 해결

### 🔗 관련 과정 링크

- 🔗 [Cloud Basic 과정](/mcp_knowledge_base/README.md) - AWS/GCP 기초 과정
- 🔗 [Cloud Container 과정](/mcp_knowledge_base/README.md) - Kubernetes 고급 과정
- 🔗 [전체 커리큘럼](/mcp_knowledge_base/curriculum.md) - 전체 과정 구조 및 학습 경로
- 🔗 [통합 인덱스](/mcp_knowledge_base/index.md) - 전체 과정 인덱스
- 🔗 [학습 경로로 돌아가기](/mcp_knowledge_base/learning-path.md) - Cloud Master 학습 경로

### 참고 문서

- [AWS 비용 관리 공식 문서](https:///docs.aws.amazon.com/cost-management/)
- [AWS CloudWatch 공식 문서](https:///docs.aws.amazon.com/cloudwatch/)
- [GCP 비용 관리 공식 문서](https:///cloud.google.com/cost-management/docs)
- [GCP Cloud Monitoring 공식 문서](https:///cloud.google.com/monitoring/docs)

### 유용한 링크

- [AWS Pricing Calculator](https:///calculator.aws/)
- [Google Cloud Pricing Calculator](https:///cloud.google.com/products/calculator)
- [AWS Well-Architected Framework](https:///aws.amazon.com/architecture/well-architected/)
- [Google Cloud Architecture Center](https:///cloud.google.com/architecture)

---

### 문제가 있나요?

실습 중 문제가 발생하면 [트러블슈팅 가이드](/mcp_knowledge_base/cloud_basic/textbook/Day1/troubleshooting-guide.md)를 참고하세요.

</details>

---

<details>
<summary>🐳 Docker 고급 기법 및 최적화 실습</summary>

### 📚 이론: 컨테이너 아키텍처 원리

#### 컨테이너 기술의 핵심 개념

- **네임스페이스(Namespaces)**: 프로세스, 네트워크, 파일시스템 격리
- **cgroups**: CPU, 메모리, I/O 리소스 제한 및 관리
- **Union File System**: 레이어드 파일시스템으로 효율적인 이미지 관리
- **컨테이너 런타임**: containerd, runc 등 컨테이너 실행 엔진

#### 멀티스테이지 빌드의 원리

- **빌드 컨텍스트 최적화**: 불필요한 파일 제외로 빌드 속도 향상
- **레이어 캐싱**: 변경되지 않은 레이어 재사용으로 효율성 증대
- **보안 강화**: 최종 이미지에 빌드 도구 미포함으로 공격 표면 감소
- **이미지 크기 최적화**: 런타임에 필요한 파일만 포함

### 🔨 멀티스테이지 빌드

```dockerfile
# 멀티스테이지 빌드 예제
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine AS runtime
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

### ⚡ 이미지 최적화 기법

- **Alpine Linux 사용**: 경량화된 베이스 이미지
- **레이어 캐싱**: 자주 변경되지 않는 레이어를 먼저 복사
- **불필요한 파일 제거**: .dockerignore 활용
- **멀티스테이지 빌드**: 빌드 도구와 런타임 분리

### 🔒 보안 강화

```dockerfile
# 보안 강화 예제
FROM node:18-alpine
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs
```

### 🛠️ 실습: 프로덕션급 Docker 이미지 빌드

1. **기존 Dockerfile 분석**
2. **멀티스테이지 빌드 적용**
3. **이미지 크기 최적화**
4. **보안 취약점 스캔**

</details>

<details>
<summary>🚀 GitHub Actions 고급 워크플로우 실습</summary>

### 📚 이론: CI/CD 파이프라인 아키텍처

#### CI/CD의 핵심 원리

- **지속적 통합(CI)**: 코드 변경사항을 자주 통합하고 자동화된 테스트 실행
- **지속적 배포(CD)**: 검증된 코드를 자동으로 프로덕션 환경에 배포
- **피드백 루프**: 빠른 피드백을 통한 품질 향상 및 배포 위험 감소
- **DevOps 문화**: 개발과 운영의 경계를 허물고 협업 강화

#### GitHub Actions 아키텍처

- **워크플로우**: YAML 파일로 정의된 자동화 작업 집합
- **이벤트 기반**: push, pull request 등 Git 이벤트에 반응
- **매트릭스 빌드**: 여러 환경/버전에서 동시 테스트
- **시크릿 관리**: 민감한 정보의 안전한 저장 및 사용

### 매트릭스 빌드

```yaml
strategy:
  matrix:
    node-version: [16, 18, 20]
    os: [ubuntu-latest, windows-latest]
```

### 환경별 배포

```yaml
jobs:
  deploy:
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
      - name: Deploy to Production
        run: echo "Deploying to production"
```

### 시크릿 관리

- **Repository Secrets**: 민감한 정보 저장
- **Environment Secrets**: 환경별 시크릿 관리
- **Organization Secrets**: 조직 레벨 시크릿

### 고급 워크플로우 패턴

- **조건부 실행**: 특정 조건에서만 작업 실행
- **병렬 처리**: 여러 작업 동시 실행
- **의존성 관리**: 작업 간 의존성 설정
- **캐싱**: 빌드 시간 단축

### 실습: 고급 CI/CD 파이프라인 구축

1. **매트릭스 빌드 설정**
2. **환경별 배포 자동화**
3. **시크릿 관리 구현**
4. **성능 최적화**

</details>

<details>
<summary>☸️ Kubernetes 기초 및 클러스터 관리 실습</summary>

### 📚 이론: Kubernetes 기초 개념

#### Kubernetes란?

- **정의**: 컨테이너 오케스트레이션 플랫폼으로 컨테이너화된 애플리케이션의 배포, 확장, 관리를 자동화
- **핵심 기능**: 자동 배포, 스케일링, 로드 밸런싱, 자가 치유, 서비스 디스커버리
- **클라우드 네이티브**: 마이크로서비스 아키텍처와 클라우드 환경에 최적화

#### Kubernetes 기본 구성 요소

!Kubernetes Architecture

- **Pod**: 가장 작은 배포 단위, 하나 이상의 컨테이너 그룹
- **Deployment**: Pod의 선언적 관리 및 업데이트
- **Service**: Pod들에 대한 안정적인 네트워크 엔드포인트
- **Namespace**: 클러스터 내 리소스 격리 및 관리

### kubectl 기본 명령어

#### 1단계: kubectl 설치 및 설정
```bash
# kubectl 설치 (Linux)
curl -LO "https:///dl.k8s.io/release/$(curl -L -s https:///dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# kubectl 설치 확인
kubectl version --client

# 클러스터 연결 확인
kubectl cluster-info
kubectl get nodes
```

#### 2단계: 기본 리소스 관리
```bash
# Pod 관리
kubectl get pods
kubectl get pods -o wide
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl logs -f <pod-name>  # 실시간 로그 확인

# Pod 생성 및 삭제
kubectl run nginx-pod --image=nginx
kubectl delete pod nginx-pod

# Deployment 관리
kubectl get deployments
kubectl create deployment nginx --image=nginx
kubectl scale deployment nginx --replicas=3
kubectl rollout status deployment/nginx
kubectl rollout history deployment/nginx

# Service 관리
kubectl get services
kubectl expose deployment nginx --port=80 --type=LoadBalancer
kubectl get endpoints
```

#### 3단계: 고급 명령어
```bash
# 네임스페이스 관리
kubectl get namespaces
kubectl create namespace my-namespace
kubectl config set-context --current --namespace=my-namespace

# 리소스 상세 정보
kubectl get all
kubectl get all -o wide
kubectl describe node <node-name>

# 리소스 편집
kubectl edit deployment nginx
kubectl patch deployment nginx -p '{"spec":{"replicas":5}}'

# 포트 포워딩
kubectl port-forward deployment/nginx 8080:80
```

### EKS 클러스터 생성 (AWS)

```bash
# EKS 클러스터 생성
eksctl create cluster /
  --name my-cluster /
  --version 1.28 /
  --region us-west-2 /
  --nodegroup-name standard-workers /
  --node-type t3.medium /
  --nodes 3 /
  --nodes-min 1 /
  --nodes-max 4

# kubeconfig 설정
aws eks update-kubeconfig --region us-west-2 --name my-cluster
```

### GKE 클러스터 생성 (GCP)

```bash
# GKE 클러스터 생성
gcloud container clusters create my-cluster /
  --zone us-central1-a /
  --machine-type e2-medium /
  --num-nodes 3 /
  --enable-autoscaling /
  --min-nodes 1 /
  --max-nodes 5

# kubeconfig 설정
gcloud container clusters get-credentials my-cluster --zone us-central1-a
```

### 기본 애플리케이션 배포

!Kubernetes Resources

```yaml
# nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
```

### 배포 및 관리

```bash
# 애플리케이션 배포
kubectl apply -f nginx-deployment.yaml

# 배포 상태 확인
kubectl get deployments
kubectl get pods
kubectl get services

# 애플리케이션 스케일링
kubectl scale deployment nginx-deployment --replicas=5

# 롤링 업데이트
kubectl set image deployment/nginx-deployment nginx=nginx:1.22

# 롤백
kubectl rollout undo deployment/nginx-deployment
```

### ConfigMap과 Secret 관리

```bash
# ConfigMap 생성
kubectl create configmap app-config /
  --from-literal=database_url=mysql://localhost:3306/mydb /
  --from-literal=debug=true

# Secret 생성
kubectl create secret generic app-secret /
  --from-literal=username=admin /
  --from-literal=password=secretpassword

# ConfigMap과 Secret 확인
kubectl get configmaps
kubectl get secrets
```

### 실습: Kubernetes 기초 배포

1. **EKS/GKE 클러스터 생성**
2. **기본 애플리케이션 배포**
3. **서비스 노출 및 접근**
4. **스케일링 및 업데이트**
5. **ConfigMap/Secret 활용**

### 🔧 Kubernetes 실습 환경 설정 가이드

#### 1. 로컬 Kubernetes 환경 구축

**Minikube 설치 및 설정**
```bash
# Minikube 설치 (macOS)
brew install minikube

# Minikube 설치 (Linux)
curl -LO https:///storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Minikube 시작
minikube start --driver=docker --memory=4096 --cpus=2

# 클러스터 상태 확인
minikube status
kubectl get nodes
```

**Kind (Kubernetes in Docker) 설정**
```bash
# Kind 설치
go install sigs.k8s.io/kind@v0.20.0

# 클러스터 생성
kind create cluster --name cloud-master-cluster

# 클러스터 목록 확인
kind get clusters

# kubectl 컨텍스트 설정
kubectl cluster-info --context kind-cloud-master-cluster
```

#### 2. 클라우드 Kubernetes 서비스 설정

**AWS EKS 클러스터 생성**
```bash
# EKS CLI 설치
curl --silent --location "https:///github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# EKS 클러스터 생성
eksctl create cluster /
  --name cloud-master-eks /
  --region ap-northeast-2 /
  --nodegroup-name workers /
  --node-type t3.medium /
  --nodes 2 /
  --nodes-min 1 /
  --nodes-max 3 /
  --managed

# 클러스터 연결 확인
aws eks update-kubeconfig --region ap-northeast-2 --name cloud-master-eks
kubectl get nodes
```

**Google GKE 클러스터 생성**
```bash
# GKE 클러스터 생성
gcloud container clusters create cloud-master-gke /
  --zone=asia-northeast3-a /
  --num-nodes=2 /
  --machine-type=e2-medium /
  --enable-autoscaling /
  --min-nodes=1 /
  --max-nodes=3

# 클러스터 연결
gcloud container clusters get-credentials cloud-master-gke --zone=asia-northeast3-a
kubectl get nodes
```

#### 3. 필수 도구 설치 및 설정

**kubectl 설치**
```bash
# kubectl 설치 (macOS)
brew install kubectl

# kubectl 설치 (Linux)
curl -LO "https:///dl.k8s.io/release/$(curl -L -s https:///dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# kubectl 버전 확인
kubectl version --client
```

**Helm 설치**
```bash
# Helm 설치
curl https:///raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Helm 버전 확인
helm version

# Helm 저장소 추가
helm repo add stable https:///charts.helm.sh/stable
helm repo update
```

**k9s (Kubernetes CLI 도구) 설치**
```bash
# k9s 설치 (macOS)
brew install k9s

# k9s 설치 (Linux)
wget https:///github.com/derailed/k9s/releases/download/v0.27.4/k9s_Linux_amd64.tar.gz
tar -xzf k9s_Linux_amd64.tar.gz
sudo mv k9s /usr/local/bin/

# k9s 실행
k9s
```

#### 4. 네임스페이스 및 리소스 설정

**개발 환경 네임스페이스 생성**
```bash
# 네임스페이스 생성
kubectl create namespace development
kubectl create namespace staging
kubectl create namespace production

# 네임스페이스 확인
kubectl get namespaces

# 기본 네임스페이스 설정
kubectl config set-context --current --namespace=development
```

**리소스 할당량 설정**
```yaml
# resource-quota.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: development
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    limits.cpu: "4"
    limits.memory: 8Gi
    pods: "10"
    services: "5"
    persistentvolumeclaims: "4"
```

```bash
# 리소스 할당량 적용
kubectl apply -f resource-quota.yaml

# 할당량 확인
kubectl describe quota dev-quota -n development
```

#### 5. 모니터링 및 로깅 설정

**Prometheus 설치**
```bash
# Prometheus Helm 차트 설치
helm repo add prometheus-community https:///prometheus-community.github.io/helm-charts
helm repo update

# Prometheus 설치
helm install prometheus prometheus-community/kube-prometheus-stack /
  --namespace monitoring /
  --create-namespace /
  --set grafana.adminPassword=admin123

# 설치 상태 확인
kubectl get pods -n monitoring
```

**Grafana 접근 설정**
```bash
# Grafana 서비스 포트 포워딩
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# 브라우저에서 http://localhost:3000 접속
# 사용자명: admin, 비밀번호: admin123
```

#### 6. 실습 환경 검증

**클러스터 상태 확인**
```bash
# 노드 상태 확인
kubectl get nodes -o wide

# 클러스터 정보 확인
kubectl cluster-info

# API 리소스 목록 확인
kubectl api-resources

# 네임스페이스별 리소스 확인
kubectl get all --all-namespaces
```

**테스트 애플리케이션 배포**
```yaml
# test-app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-app
  namespace: development
spec:
  replicas: 2
  selector:
    matchLabels:
      app: test-app
  template:
    metadata:
      labels:
        app: test-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: test-app-service
  namespace: development
spec:
  selector:
    app: test-app
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
```

```bash
# 테스트 애플리케이션 배포
kubectl apply -f test-app.yaml

# 배포 상태 확인
kubectl get pods -n development
kubectl get services -n development

# 애플리케이션 접근 테스트
kubectl port-forward -n development svc/test-app-service 8080:80
# 브라우저에서 http://localhost:8080 접속
```

#### 7. 문제 해결 가이드

**자주 발생하는 문제와 해결방법**

1. **Pod가 Pending 상태인 경우**
```bash
# Pod 상세 정보 확인
kubectl describe pod <pod-name> -n <namespace>

# 노드 리소스 확인
kubectl top nodes
kubectl describe node <node-name>
```

2. **서비스 접근 불가**
```bash
# 서비스 엔드포인트 확인
kubectl get endpoints -n <namespace>

# Pod 로그 확인
kubectl logs <pod-name> -n <namespace>
```

3. **네트워크 정책 문제**
```bash
# 네트워크 정책 확인
kubectl get networkpolicies -n <namespace>

# DNS 해결 테스트
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup kubernetes.default
```

</details>

<details>
<summary>🔄 완전 자동화된 배포 파이프라인 실습</summary>

### 📚 이론: 클라우드 인프라 아키텍처

#### 가상화 기술의 원리

- **하이퍼바이저**: 물리적 하드웨어를 가상화하는 소프트웨어 계층
- **가상머신 격리**: 각 VM이 독립적인 운영체제와 리소스를 가짐
- **리소스 할당**: CPU, 메모리, 스토리지의 동적 할당 및 관리
- **네트워크 가상화**: 가상 네트워크를 통한 VM 간 통신

#### 컨테이너 vs 가상머신

- **컨테이너**: OS 커널 공유, 빠른 시작, 경량화
- **가상머신**: 완전한 격리, 다양한 OS 지원, 높은 보안
- **하이브리드 접근**: VM 위에 컨테이너 실행으로 장점 결합
- **오케스트레이션**: 다수의 컨테이너를 효율적으로 관리

#### 고가용성 설계 원칙

- **다중 가용 영역**: 장애 격리를 위한 지리적 분산
- **로드 밸런싱**: 트래픽 분산으로 성능 향상 및 장애 대응
- **자동 복구**: Health Check 기반 자동 교체 및 복구
- **백업 전략**: 데이터 보호 및 재해 복구 계획

### VM 인스턴스 생성 (이론 적용)

```bash
# AWS EC2 인스턴스 생성 - 고가용성 설계 원리 적용
# 다중 가용 영역 배치를 위한 서브넷 지정
aws ec2 run-instances /
  --image-id ami-0c02fb55956c7d316 /
  --instance-type t3.medium /
  --key-name my-key /
  --security-groups my-sg /
  --subnet-id subnet-12345 /
  --associate-public-ip-address /
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-server-1}]'

# 로드 밸런서 생성을 위한 추가 인스턴스
aws ec2 run-instances /
  --image-id ami-0c02fb55956c7d316 /
  --instance-type t3.medium /
  --key-name my-key /
  --security-groups my-sg /
  --subnet-id subnet-67890 /
  --associate-public-ip-address /
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-server-2}]'
```

### Docker 설치 및 설정 (컨테이너 오케스트레이션 구현)
```bash
# Docker 설치 - 컨테이너 런타임 환경 구축
curl -fsSL https:///get.docker.com -o get-docker.sh
sh get-docker.sh

# Docker Compose 설치 - 멀티 컨테이너 오케스트레이션
sudo curl -L "https:///github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Docker Swarm 초기화 - 클러스터 오케스트레이션
docker swarm init --advertise-addr $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# 워커 노드 조인 토큰 생성
docker swarm join-token worker
```

### 컨테이너 오케스트레이션

- **Docker Swarm**: 간단한 클러스터링
- **Kubernetes**: 고급 오케스트레이션
- **Docker Compose**: 로컬 개발 환경

### 고가용성 설정

- **로드 밸런서**: 트래픽 분산
- **헬스 체크**: 서비스 상태 모니터링
- **자동 복구**: 장애 시 자동 재시작
- **백업 전략**: 데이터 보호

### 실습: VM 기반 컨테이너 배포

1. **VM 인스턴스 생성**
2. **Docker 환경 구축**
3. **컨테이너 배포**
4. **고가용성 설정**

</details>

<details>
<summary>🔄 완전 자동화된 배포 파이프라인 실습</summary>

### 📚 이론: DevOps 및 자동화 원리

#### DevOps 문화와 원칙

- **협업 강화**: 개발팀과 운영팀 간의 소통 및 협업 증진
- **자동화 우선**: 반복 작업의 자동화를 통한 효율성 향상
- **지속적 개선**: 피드백 루프를 통한 지속적인 프로세스 개선
- **문화적 변화**: 실패를 학습 기회로 보는 문화 조성

#### 자동화 파이프라인의 핵심 요소

- **소스 코드 관리**: Git 기반 버전 관리 및 협업
- **자동 빌드**: 코드 변경 시 자동으로 애플리케이션 빌드
- **자동 테스트**: 단위, 통합, E2E 테스트 자동 실행
- **자동 배포**: 검증된 코드의 자동 배포 및 롤백
- **모니터링**: 배포 후 상태 모니터링 및 알림

#### 배포 전략의 종류

- **Blue-Green 배포**: 무중단 배포를 위한 이중 환경 운영
- **Canary 배포**: 점진적 배포로 위험 최소화
- **Rolling 배포**: 단계적 교체를 통한 서비스 중단 최소화
- **Feature Flag**: 기능 단위 배포 제어

### 파이프라인 구성 요소

- **소스 코드 관리**: Git 기반 버전 관리
- **자동 빌드**: 코드 변경 시 자동 빌드
- **테스트 자동화**: 단위/통합 테스트
- **배포 자동화**: 환경별 자동 배포
- **모니터링**: 배포 후 상태 모니터링

### GitHub Actions 워크플로우 (DevOps 원리 적용)

```yaml
name: Complete CI/CD Pipeline
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  # 지속적 통합(CI) - 코드 품질 검증
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16, 18, 20]
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
      - name: Install dependencies
        run: npm ci
      - name: Run tests
        run: npm test
      - name: Run security scan
        run: npm audit

  # 자동 빌드 - 멀티스테이지 빌드 적용
  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build Docker image
        run: |
          docker build -t myapp:${{ github.sha }} .
          docker tag myapp:${{ github.sha }} myapp:latest
      - name: Push to registry
        run: |
          echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
          docker push myapp:${{ github.sha }}
          docker push myapp:latest

  # 지속적 배포(CD) - Blue-Green 배포 전략
  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
      - name: Deploy to production (Blue-Green)
        run: |
          # Blue-Green 배포 구현
          kubectl apply -f k8s/blue-deployment.yaml
          kubectl rollout status deployment/blue-deployment
          kubectl patch service myapp-service -p '{"spec":{"selector":{"version":"blue"}}}'
```

### 환경별 배포 전략

- **Development**: 개발 환경 자동 배포
- **Staging**: 테스트 환경 수동 승인 후 배포
- **Production**: 프로덕션 환경 수동 승인 후 배포

### 롤백 전략

- **Blue-Green 배포**: 무중단 배포
- **Canary 배포**: 점진적 배포
- **자동 롤백**: 장애 시 자동 복구

### 실습: 완전 자동화 파이프라인 구축 (DevOps 원리 적용)

1. **CI/CD 파이프라인 설계** - 지속적 통합/배포 원리 적용
2. **자동화 스크립트 작성** - Blue-Green 배포 전략 구현
3. **환경별 배포 설정** - Development → Staging → Production 파이프라인
4. **모니터링 및 알림 설정** - Health Check 및 자동 롤백 구현
5. **협업 워크플로우 구축** - PR 기반 코드 리뷰 및 승인 프로세스

</details>

---

## 📚 문제 해결 및 참고 자료

### 📊 학습 평가 기준

#### 실습 완료 기준
1. **Docker 고급 실습 (25점)**
   - ✅ 멀티스테이지 빌드 구현 (10점)
   - ✅ 이미지 최적화 및 보안 스캔 (10점)
   - ✅ Docker Compose 고급 구성 (5점)

2. **GitHub Actions 고급 실습 (25점)**
   - ✅ 복잡한 워크플로우 작성 (10점)
   - ✅ 시크릿 및 환경 변수 관리 (10점)
   - ✅ 조건부 실행 및 병렬 처리 (5점)

3. **Kubernetes 실습 (30점)**
   - ✅ 클러스터 구성 및 관리 (15점)
   - ✅ 애플리케이션 배포 및 스케일링 (10점)
   - ✅ 서비스 및 인그레스 설정 (5점)

4. **VM 컨테이너 배포 실습 (20점)**
   - ✅ 완전 자동화된 배포 파이프라인 구축 (15점)
   - ✅ 모니터링 및 로깅 설정 (5점)

#### 학습 목표 달성 평가
- **90점 이상**: 모든 고급 학습 목표 달성, 전문가 수준
- **80-89점**: 고급 학습 목표 달성, 실무 적용 가능
- **70-79점**: 기본 고급 목표 달성, 추가 학습 권장
- **70점 미만**: 중급 개념 재학습 필요

#### 실습 결과물 제출
1. **최적화된 Docker 이미지**: 멀티스테이지 빌드, 보안 스캔 결과
2. **고급 GitHub Actions**: 복잡한 워크플로우, 시크릿 관리
3. **Kubernetes 매니페스트**: 배포, 서비스, 인그레스 설정 파일
4. **자동화 스크립트**: 완전 자동화된 배포 파이프라인

### 📖 용어 사전

#### Docker 고급 용어
- **멀티스테이지 빌드(Multi-stage Build)**: 여러 단계로 나누어 이미지 크기 최적화
- **레이어 캐싱(Layer Caching)**: Docker 레이어 재사용으로 빌드 속도 향상
- **이미지 스캔(Image Scanning)**: 보안 취약점 검사 및 해결
- **레지스트리 미러(Registry Mirror)**: 이미지 다운로드 속도 향상

#### Kubernetes 용어
- **파드(Pod)**: Kubernetes의 최소 배포 단위
- **디플로이먼트(Deployment)**: 파드의 배포 및 관리
- **서비스(Service)**: 파드에 대한 네트워크 접근 제공
- **인그레스(Ingress)**: 외부에서 클러스터 내 서비스 접근
- **네임스페이스(Namespace)**: 리소스 격리 및 관리

#### CI/CD 고급 용어
- **매트릭스 빌드(Matrix Build)**: 여러 환경에서 동시 빌드
- **의존성 캐싱(Dependency Caching)**: 빌드 속도 향상을 위한 캐시
- **아티팩트 관리(Artifact Management)**: 빌드 결과물 저장 및 관리
- **롤백(Rollback)**: 문제 발생 시 이전 버전으로 복구

### 일반적인 문제 해결

#### Docker 관련 문제

- **이미지 빌드 실패**: Dockerfile 문법 확인
- **컨테이너 실행 오류**: 포트 충돌, 권한 문제 확인
- **네트워크 연결 문제**: 방화벽 설정 확인

#### GitHub Actions 관련 문제

- **워크플로우 실행 실패**: YAML 문법, 권한 확인
- **시크릿 접근 오류**: 시크릿 이름, 권한 확인
- **빌드 타임아웃**: 리소스 사용량 최적화

#### Kubernetes 관련 문제

- **클러스터 연결 실패**: kubeconfig 설정 확인
- **Pod 생성 실패**: 리소스 부족, 이미지 풀 오류 확인
- **Service 접근 불가**: 네트워크 정책, 보안 그룹 확인
- **ConfigMap/Secret 오류**: 네임스페이스, 권한 확인

#### VM 배포 관련 문제

- **인스턴스 생성 실패**: 할당량, 권한 확인
- **SSH 연결 실패**: 보안 그룹, 키 페어 확인
- **서비스 시작 실패**: 로그 확인, 의존성 설치

### 디버깅 도구

- **Docker 로그**: `docker logs <container_id>`
- **GitHub Actions 로그**: Actions 탭에서 확인
- **VM 로그**: CloudWatch, Cloud Logging 활용

### 성능 최적화

- **이미지 크기 최적화**: 멀티스테이지 빌드
- **빌드 시간 단축**: 캐싱 활용
- **배포 속도 향상**: 병렬 처리

### 보안 체크리스트

- [ ] Docker 이미지 보안 스캔
- [ ] 시크릿 정보 암호화
- [ ] 네트워크 보안 설정
- [ ] 접근 권한 최소화

### 추가 학습 자료

- [Docker 공식 문서](https:///docs.docker.com/)
- [GitHub Actions 문서](https:///docs.github.com/en/actions)
- [AWS EC2 문서](https:///docs.aws.amazon.com/ec2/)
- [Google Compute Engine 문서](https:///cloud.google.com/compute/docs)

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

## 📚 관련 가이드 문서

### Docker 고급 기법
- 🔗 [Docker 고급 가이드](/mcp_knowledge_base/cloud_master/textbook/Day1/guides/docker-advanced-guide.md) - 멀티스테이지 빌드, 이미지 최적화
- 🔗 [Docker Compose 가이드](/mcp_knowledge_base/cloud_master/textbook/Day1/guides/docker-compose-guide.md) - 다중 서비스 관리

### GitHub Actions 고급 워크플로우
- 🔗 [GitHub Actions 가이드](/mcp_knowledge_base/cloud_master/textbook/Day1/guides/github-actions-guide.md) - CI/CD 파이프라인 구축
- 🔗 [매트릭스 빌드 가이드](/mcp_knowledge_base/cloud_master/textbook/Day2/guides/comprehensive-practice-guide.md) - 다중 환경 빌드

### Kubernetes 및 컨테이너 오케스트레이션
- 🔗 [Kubernetes 가이드](/mcp_knowledge_base/cloud_master/textbook/Day2/guides/comprehensive-practice-guide.md) - 컨테이너 오케스트레이션
- 🔗 [Kubernetes 실습 환경 설정](/mcp_knowledge_base/cloud_master/textbook/Day2/guides/comprehensive-practice-guide.md) - 클러스터 구축

### 완전 자동화된 배포 파이프라인
- 🔗 [자동화 배포 가이드](/mcp_knowledge_base/cloud_master/textbook/Day2/guides/comprehensive-practice-guide.md) - 완전 자동화된 배포
- 🔗 [인프라 as 코드 가이드](/mcp_knowledge_base/cloud_master/textbook/Day2/guides/comprehensive-practice-guide.md) - Terraform, CloudFormation

### 모니터링 및 비용 관리
- 🔗 [모니터링 가이드](/mcp_knowledge_base/cloud_master/textbook/Day2/guides/monitoring-guide.md) - Prometheus, Grafana 설정
- 🔗 [비용 최적화 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/cost-optimization-guide.md) - 클라우드 비용 관리
- 🔗 [비용 구조 가이드](/mcp_knowledge_base/cloud_master/textbook/Day2/guides/cost-structure-guide.md) - 비용 분석 및 예측

### 종합 실습
- 🔗 [종합 실습 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/comprehensive-practice-guide.md) - 전체 과정 통합 실습

### 실습 프로젝트
- 🔗 [My App 프로젝트](/mcp_knowledge_base/cloud_master/repos/samples/day1/my-app/.dockerignore) - 고급 Docker 및 Kubernetes 애플리케이션
- 🔗 [Actions Demo 프로젝트](/mcp_knowledge_base/cloud_master/repos/samples/day2/actions-demo/README.md) - 고급 CI/CD 파이프라인

### 자동화 스크립트
- 🔗 [AWS 설정 스크립트](/mcp_knowledge_base/cloud_master/repos/cloud-scripts/aws-ec2-create.sh) - 고급 AWS 리소스 자동 생성
- 🔗 [GCP 설정 스크립트](/mcp_knowledge_base/cloud_master/repos/cloud-scripts/aws-ec2-create.sh) - 고급 GCP 리소스 자동 생성
- 🔗 [프로젝트 설정 가이드](/mcp_knowledge_base/cloud_master/repos/cloud-scripts/PROJECT_SETUP.md) - 전체 환경 설정

### 문제 해결
- 🔗 [트러블슈팅 가이드](/mcp_knowledge_base/cloud_basic/textbook/Day1/troubleshooting-guide.md) - 고급 문제 해결

---


## 🧹 실습 정리

### 자동 정리 (권장)
```bash
# Day2 실습 자동 정리
./mcp_knowledge_base/cloud_master/repos/automation/day2/kubernetes-practice-automation.sh --cleanup

# 또는 수동 정리
kubectl delete namespace k8s-practice 2>/dev/null || true
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true
docker system prune -f
```

### 정리 확인
- [ ] Kubernetes 리소스 정리
- [ ] 모든 컨테이너 중지 및 삭제
- [ ] 사용하지 않는 이미지 정리
- [ ] Docker 볼륨 정리

---

## 🎉 완료!

[🎉 완료!](#🎉-완료)

축하합니다! Cloud Master 2일차 학습을 완료했습니다.

### 🚀 다음 단계

- **Cloud Master 3일차**: 로드 밸런싱, 모니터링, 비용 최적화
- **실제 프로젝트 적용**: 자신의 프로젝트에 학습한 기술 적용
- **고급 기능 학습**: 모니터링, 로드 밸런싱, 자동 스케일링

---

*🎯 이제 고급 CI/CD 및 VM 기반 컨테이너 배포의 기본기를 갖추었습니다! Cloud Master 3일차로 진행하세요.**

- [**Day 1**](mcp_knowledge_base\cloud_master\textbook\Day1\README.md): Docker, Git/GitHub, GitHub Actions 기초
- [**Day 2**](mcp_knowledge_base\cloud_master\textbook\Day2\README.md): 고급 CI/CD 및 VM 기반 컨테이너 배포
- [**Day 3**](mcp_knowledge_base\cloud_master\textbook\Day3\README.md): 로드 밸런싱, 모니터링, 비용 최적화

## 🧭 네비게이션

<div align="center">

[🏠 홈으로 돌아가기](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/learning-path.md)

</div>