# Cloud Master - 2일차: 고급 CI/CD 및 VM 기반 컨테이너 배포

<div align="center">

[← 이전: Cloud Master 1일차](../Day1/README.md) | [다음: Cloud Master 2일차 →](../Day2/README.md) | [📚 전체 커리큘럼](../curriculum.md) | [🏠 학습 경로로 돌아가기](../index.md) | [📋 학습 경로](../learning-path.md)

</div>


<details>
<summary>📋 목차</summary>

1. [🎯 학습 목표](#학습-목표)
2. [🔧 실습 환경 준비](#실습-환경-준비)
3. [📚 학습 자료](#학습-자료)
4. [🚀 시작하기](#시작하기)
5. [🐳 Docker 고급 기법 및 최적화](#docker-고급-기법-및-최적화)
6. [🚀 GitHub Actions 고급 워크플로우](#github-actions-고급-워크플로우)
7. [🚀 Kubernetes 기초 및 클러스터 관리](#kubernetes-기초-및-클러스터-관리)
8. [🚀 VM 기반 컨테이너 배포 자동화](#vm-기반-컨테이너-배포-자동화)
9.  [🔄 완전 자동화된 배포 파이프라인](#완전-자동화된-배포-파이프라인)
10. [📚 문제 해결 및 참고 자료](#문제-해결-및-참고-자료)
11. [💡 핵심 개념 미리보기](#핵심-개념-미리보기)

</details>
---

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

#### 3. 컨테이너 관리 도구 설치
```bash
# Docker Compose 설치 (VM 기반 컨테이너 오케스트레이션용)
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# kubectl 설치 (Kubernetes 클러스터 관리용)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# eksctl 설치 (AWS EKS 클러스터 관리용)
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Docker Swarm 초기화 (선택사항)
docker swarm init
```

### 클라우드 계정 준비

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

<details>
<summary>🔗 관련 실습 가이드</summary>

### 📖 상세 실습 가이드
- 🔗 [클라우드 비용 구조 가이드](./cost-structure-guide.md) - AWS/GCP 과금 모델 이해
- 🔗 [비용 최적화 가이드](./cost-optimization-guide.md) - 비용 예측 및 최적화
- 🔗 [모니터링 가이드](./monitoring-guide.md) - CloudWatch/Cloud Monitoring 설정
- 🔗 [종합 실습 가이드](./comprehensive-practice-guide.md) - EKS/GKE 컨테이너 오케스트레이션

### 🛠️ 문제 해결 가이드
- 🔗 [트러블슈팅 가이드](./troubleshooting-guide.md) - 비용 관리, 모니터링, Kubernetes 문제 해결

### 🔗 관련 과정 링크
- 🔗 [Cloud Basic 과정](../../../cloud_basic/textbook/Day1/README.md) - AWS/GCP 기초 과정
- 🔗 [Cloud Container 과정](../../../cloud_container/textbook/Day1/README.md) - Kubernetes 고급 과정
- 🔗 [전체 커리큘럼](../curriculum.md) - 전체 과정 구조 및 학습 경로
- 🔗 [통합 인덱스](../index.md) - 전체 과정 인덱스
- 🔗 [학습 경로로 돌아가기](../learning-path.md) - Cloud Master 학습 경로

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
실습 중 문제가 발생하면 [트러블슈팅 가이드](troubleshooting-guide.md)를 참고하세요.

---

## 🐳 Docker 고급 기법 및 최적화

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

### 멀티스테이지 빌드
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

### 이미지 최적화 기법
- **Alpine Linux 사용**: 경량화된 베이스 이미지
- **레이어 캐싱**: 자주 변경되지 않는 레이어를 먼저 복사
- **불필요한 파일 제거**: .dockerignore 활용
- **멀티스테이지 빌드**: 빌드 도구와 런타임 분리

### 보안 강화
```dockerfile
# 보안 강화 예제
FROM node:18-alpine
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs
```

### 실습: 프로덕션급 Docker 이미지 빌드
1. **기존 Dockerfile 분석**
2. **멀티스테이지 빌드 적용**
3. **이미지 크기 최적화**
4. **보안 취약점 스캔**

---

## 🚀 GitHub Actions 고급 워크플로우

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

---

## 🚀 Kubernetes 기초 및 클러스터 관리

### 📚 이론: Kubernetes 기초 개념

#### Kubernetes란?
- **정의**: 컨테이너 오케스트레이션 플랫폼으로 컨테이너화된 애플리케이션의 배포, 확장, 관리를 자동화
- **핵심 기능**: 자동 배포, 스케일링, 로드 밸런싱, 자가 치유, 서비스 디스커버리
- **클라우드 네이티브**: 마이크로서비스 아키텍처와 클라우드 환경에 최적화

#### Kubernetes 기본 구성 요소
- **Pod**: 가장 작은 배포 단위, 하나 이상의 컨테이너 그룹
- **Deployment**: Pod의 선언적 관리 및 업데이트
- **Service**: Pod들에 대한 안정적인 네트워크 엔드포인트
- **Namespace**: 클러스터 내 리소스 격리 및 관리

### kubectl 기본 명령어
```bash
# 클러스터 정보 확인
kubectl cluster-info
kubectl get nodes

# Pod 관리
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>

# Deployment 관리
kubectl get deployments
kubectl create deployment nginx --image=nginx
kubectl scale deployment nginx --replicas=3

# Service 관리
kubectl get services
kubectl expose deployment nginx --port=80 --type=LoadBalancer
```

### EKS 클러스터 생성 (AWS)
```bash
# EKS 클러스터 생성
eksctl create cluster \
  --name my-cluster \
  --version 1.28 \
  --region us-west-2 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 4

# kubeconfig 설정
aws eks update-kubeconfig --region us-west-2 --name my-cluster
```

### GKE 클러스터 생성 (GCP)
```bash
# GKE 클러스터 생성
gcloud container clusters create my-cluster \
  --zone us-central1-a \
  --machine-type e2-medium \
  --num-nodes 3 \
  --enable-autoscaling \
  --min-nodes 1 \
  --max-nodes 5

# kubeconfig 설정
gcloud container clusters get-credentials my-cluster --zone us-central1-a
```

### 기본 애플리케이션 배포
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
kubectl create configmap app-config \
  --from-literal=database_url=mysql://localhost:3306/mydb \
  --from-literal=debug=true

# Secret 생성
kubectl create secret generic app-secret \
  --from-literal=username=admin \
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

---

## 🚀 VM 기반 컨테이너 배포 자동화

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
aws ec2 run-instances \
  --image-id ami-0c02fb55956c7d316 \
  --instance-type t3.medium \
  --key-name my-key \
  --security-groups my-sg \
  --subnet-id subnet-12345 \
  --associate-public-ip-address \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-server-1}]'

# 로드 밸런서 생성을 위한 추가 인스턴스
aws ec2 run-instances \
  --image-id ami-0c02fb55956c7d316 \
  --instance-type t3.medium \
  --key-name my-key \
  --security-groups my-sg \
  --subnet-id subnet-67890 \
  --associate-public-ip-address \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-server-2}]'
```

### Docker 설치 및 설정 (컨테이너 오케스트레이션 구현)
```bash
# Docker 설치 - 컨테이너 런타임 환경 구축
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Docker Compose 설치 - 멀티 컨테이너 오케스트레이션
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
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

---

## 🔄 완전 자동화된 배포 파이프라인

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

---

## 📚 문제 해결 및 참고 자료

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
- [Docker 공식 문서](https://docs.docker.com/)
- [GitHub Actions 문서](https://docs.github.com/en/actions)
- [AWS EC2 문서](https://docs.aws.amazon.com/ec2/)
- [Google Compute Engine 문서](https://cloud.google.com/compute/docs)

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

<div align="center">

[← 이전: Cloud Master 1일차](../Day1/README.md) | [📚 전체 커리큘럼](../curriculum.md) | [🏠 학습 경로로 돌아가기](../index.md) | [다음: Cloud Master 3일차 →](../Day3/README.md)

</div>