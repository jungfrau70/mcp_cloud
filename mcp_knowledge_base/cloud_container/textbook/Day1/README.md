# Cloud Container - 1일차: Kubernetes 및 GKE 고급 오케스트레이션 이론 및 실습

<details>
<summary>📋 목차</summary>

## 📚 이론 학습

[📚 이론 학습](#이론-학습)
1. [🎯 학습 목표](#학습-목표)
2. [☸️ Kubernetes 고급 아키텍처](#kubernetes-고급-아키텍처)
3. [🐳 컨테이너 오케스트레이션 고급 기법](#컨테이너-오케스트레이션-고급-기법)
4. [🚀 AWS ECS 및 Fargate 심화](#aws-ecs-및-fargate-심화)
5. [🔄 고급 CI/CD 파이프라인](#고급-cicd-파이프라인)

## 🛠️ 실습 학습

[🛠️ 실습 학습](#실습-학습)
6. [🔧 실습 환경 준비](#실습-환경-준비)
7. [☸️ Kubernetes 고급 아키텍처 실습](#kubernetes-고급-아키텍처)
8. [🐳 컨테이너 오케스트레이션 고급 기법 실습](#컨테이너-오케스트레이션-고급-기법)
9. [🚀 AWS ECS 및 Fargate 심화 실습](#aws-ecs-및-fargate-심화)
10. [🔄 고급 CI/CD 파이프라인 실습](#고급-cicd-파이프라인)

## 📚 참고 자료

[📚 참고 자료](#참고-자료)
11. [📚 문제 해결 및 참고 자료](#문제-해결-및-참고-자료)

</details>

---

## 🎯 학습 목표

### 핵심 학습 목표

[핵심 학습 목표](#핵심-학습-목표)
- **Kubernetes 고급 아키텍처** 클러스터 구성 및 컴포넌트 이해
- **GKE 클러스터 관리** 고급 설정 및 운영
- **컨테이너 오케스트레이션** Deployment, Service, Ingress 고급 설정
- **AWS ECS/Fargate** 서버리스 컨테이너 실행

### 실습 후 달성할 수 있는 능력

[실습 후 달성할 수 있는 능력](#실습-후-달성할-수-있는-능력)
- ✅ Kubernetes 클러스터 아키텍처 이해
- ✅ GKE 클러스터 생성 및 고급 설정
- ✅ 마이크로서비스 아키텍처 구성
- ✅ ECS Fargate 서비스 배포

### 예상 소요 시간

[예상 소요 시간](#예상-소요-시간)
- **Kubernetes 고급**: 120-150분
- **GKE 클러스터**: 90-120분
- **컨테이너 오케스트레이션**: 120-150분
- **ECS/Fargate**: 90-120분
- **전체 과정**: 7-9시간

---

## 📚 이론 학습

[📚 이론 학습](#이론-학습)

### 🚀 Kubernetes 고급 아키텍처 이론

[🚀 Kubernetes 고급 아키텍처 이론](#kubernetes-고급-아키텍처-이론)

<details>
<summary>🚀 Kubernetes 기본 개념</summary>

#### Kubernetes란?

Kubernetes는 컨테이너화된 애플리케이션의 배포, 확장, 관리를 자동화하는 오픈소스 컨테이너 오케스트레이션 플랫폼입니다.

#### Kubernetes 핵심 개념

- **클러스터 (Cluster)**: 노드들의 집합으로 구성된 Kubernetes 실행 환경
- **노드 (Node)**: 워커 머신으로 Pod를 실행하는 물리적 또는 가상 머신
- **Pod**: Kubernetes에서 배포 가능한 가장 작은 단위
- **서비스 (Service)**: Pod 집합에 대한 네트워크 접근을 추상화
- **네임스페이스 (Namespace)**: 클러스터 내 리소스의 논리적 분할

#### Kubernetes 아키텍처

- **Control Plane**: 클러스터의 상태를 관리하는 마스터 노드
- **Worker Node**: 실제 워크로드를 실행하는 노드
- **etcd**: 클러스터 상태를 저장하는 분산 키-값 저장소
- **API Server**: Kubernetes API를 제공하는 중앙 관리 컴포넌트

#### GKE (Google Kubernetes Engine)

- **관리형 Kubernetes**: Google이 클러스터를 관리
- **자동 업그레이드**: Kubernetes 버전 자동 업데이트
- **자동 스케일링**: 노드 자동 확장/축소
- **통합 모니터링**: Google Cloud 모니터링과 통합

</details>

<details>
<summary>🐳 컨테이너 오케스트레이션 고급 기법 이론</summary>

#### 컨테이너 오케스트레이션이란?

여러 컨테이너를 관리하고 조율하여 복잡한 애플리케이션을 구성하는 기술입니다.

#### Kubernetes 핵심 리소스

- **Deployment**: Pod의 배포 및 업데이트를 관리
- **Service**: Pod 집합에 대한 안정적인 네트워크 엔드포인트 제공
- **Ingress**: HTTP/HTTPS 트래픽을 서비스로 라우팅
- **ConfigMap**: 설정 데이터를 컨테이너에 주입
- **Secret**: 민감한 데이터를 안전하게 저장
- **PersistentVolume**: 영구 스토리지 관리

#### 마이크로서비스 아키텍처

- **서비스 분해**: 애플리케이션을 독립적인 서비스로 분할
- **API 게이트웨이**: 클라이언트와 서비스 간의 단일 진입점
- **서비스 메시**: 서비스 간 통신을 관리하는 인프라 계층
- **서비스 디스커버리**: 서비스 위치를 자동으로 찾는 메커니즘

#### 고가용성 설계

- **다중 복제본**: 동일한 서비스의 여러 인스턴스 실행
- **로드 밸런싱**: 트래픽을 여러 인스턴스에 분산
- **헬스 체크**: 서비스 상태 모니터링 및 자동 복구
- **롤링 업데이트**: 무중단 서비스 업데이트

</details>

<details>
<summary>🚀 AWS ECS 및 Fargate 심화 이론</summary>

#### ECS (Elastic Container Service)란?

AWS에서 제공하는 완전 관리형 컨테이너 오케스트레이션 서비스입니다.

#### ECS 핵심 개념

- **클러스터 (Cluster)**: 컨테이너 인스턴스의 논리적 그룹
- **태스크 정의 (Task Definition)**: 컨테이너 실행을 위한 템플릿
- **태스크 (Task)**: 태스크 정의의 실행 인스턴스
- **서비스 (Service)**: 태스크의 원하는 개수를 유지하는 관리형 서비스

#### Fargate란?

서버를 관리할 필요 없이 컨테이너를 실행할 수 있는 서버리스 컴퓨팅 엔진입니다.

#### Fargate 장점

- **서버리스**: 인프라 관리 불필요
- **자동 스케일링**: 워크로드에 따라 자동 확장/축소
- **비용 효율성**: 사용한 만큼만 비용 지불
- **보안**: 격리된 실행 환경

#### ECS vs Kubernetes 비교

| 특징 | ECS | Kubernetes |
|------|-----|------------|
| **관리 복잡도** | 낮음 | 높음 |
| **유연성** | 중간 | 높음 |
| **커뮤니티** | AWS 중심 | 오픈소스 |
| **학습 곡선** | 완만 | 가파름 |

</details>

<details>
<summary>🚀 고급 CI/CD 파이프라인 이론</summary>

#### GitOps란?

Git을 단일 진실 소스로 사용하여 인프라와 애플리케이션을 관리하는 운영 모델입니다.

#### GitOps 핵심 원칙

- **선언적 설명**: 시스템의 원하는 상태를 선언적으로 설명
- **버전 관리**: Git을 통한 모든 변경사항 추적
- **자동화**: 변경사항을 자동으로 클러스터에 적용
- **지속적 모니터링**: 실제 상태와 원하는 상태 비교

#### 고급 CI/CD 파이프라인 단계

1. **코드 빌드**: 소스 코드 컴파일 및 패키징
2. **테스트 실행**: 단위 테스트, 통합 테스트, E2E 테스트
3. **보안 스캔**: 정적 분석, 취약점 스캔, 의존성 검사
4. **이미지 빌드**: 컨테이너 이미지 생성 및 스캔
5. **배포**: 스테이징/프로덕션 환경에 자동 배포
6. **모니터링**: 배포 후 상태 모니터링 및 알림

#### 환경별 배포 전략

- **Dev**: 개발자 환경, 빠른 피드백
- **Staging**: 프로덕션과 유사한 환경, 통합 테스트
- **Production**: 실제 서비스 환경, 안정성 우선

#### 배포 패턴

- **Blue-Green**: 두 환경을 번갈아가며 배포
- **Rolling**: 점진적으로 인스턴스 교체
- **Canary**: 소규모 트래픽으로 테스트 후 전체 배포

</details>

---

## 🛠️ 실습 학습

[🛠️ 실습 학습](#실습-학습)

## 📚 실습 가이드

[📚 실습 가이드](#실습-가이드)

<details>
<summary>📖 실습 가이드 개요</summary>

### 실습 구성

[실습 구성](#실습-구성)
1. **Kubernetes 고급 아키텍처** (150분)
2. **컨테이너 오케스트레이션 고급 기법** (150분)
3. **AWS ECS 및 Fargate 심화** (120분)
4. **고급 CI/CD 파이프라인** (90분)

### 실습 방식

[실습 방식](#실습-방식)
- **Kubernetes**: 클러스터 아키텍처 및 고급 설정
- **GKE**: Google Kubernetes Engine 관리
- **ECS/Fargate**: AWS 서버리스 컨테이너 실행
- **CI/CD**: GitOps 기반 배포 자동화

### 실습 결과물

[실습 결과물](#실습-결과물)
- Kubernetes 클러스터 아키텍처 이해
- GKE 클러스터 및 마이크로서비스 구성
- ECS Fargate 서비스 배포
- GitOps 기반 CI/CD 파이프라인

</details>

<details>
<summary>🔗 관련 실습 가이드</summary>

### 📖 상세 실습 가이드

[📖 상세 실습 가이드](#상세-실습-가이드)
- 🔗 [Kubernetes 기초 실습](/mcp_knowledge_base/cloud_container/textbook/Day1/practice/kubernetes-basics.md)
- 🔗 [컨테이너 기초 실습](/mcp_knowledge_base/cloud_container/textbook/Day1/practice/container-basics.md)

### 🛠️ 문제 해결 가이드

[🛠️ 문제 해결 가이드](#문제-해결-가이드)
- 🔗 [종합 트러블슈팅 가이드](/mcp_knowledge_base/cloud_container/textbook/Day2/troubleshooting/multi-az-issues.md)

### 🔗 관련 과정 링크

[🔗 관련 과정 링크](#관련-과정-링크)
- 🔗 Cloud Basic 과정 - AWS/GCP 기초 과정
- 🔗 Cloud Master 과정 - Docker, CI/CD 심화 과정
- 🔗 [전체 커리큘럼](/mcp_knowledge_base/curriculum.md) - 전체 과정 구조 및 학습 경로
- 🔗 [통합 인덱스](/mcp_knowledge_base/index.md) - 전체 과정 인덱스
- 🔗 [학습 경로로 돌아가기](/mcp_knowledge_base/learning-path.md) - Cloud Container 학습 경로

---

## 🔧 실습 환경 준비

<details>
<summary>📋 필수 계정 및 도구</summary>

### 필수 계정

[필수 계정](#필수-계정)
- **GCP 계정**: GKE 클러스터 생성용
- **AWS 계정**: ECS/Fargate 서비스 배포용
- **GitHub 계정**: GitOps 저장소 관리용
- **Docker Hub 계정**: 컨테이너 이미지 저장소

### 필수 도구

[필수 도구](#필수-도구)
- **kubectl**: Kubernetes 클러스터 관리
- **gcloud**: Google Cloud CLI
- **aws**: AWS CLI
- **Docker**: 컨테이너 이미지 빌드
- **Helm**: Kubernetes 패키지 관리자

</details>

<details>
<summary>🔧 고급 환경 설정</summary>

### kubectl 설치 및 설정

[kubectl 설치 및 설정](#kubectl-설치-및-설정)
```bash
# kubectl 설치
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# kubectl 버전 확인
kubectl version --client
```

### gcloud CLI 설정

[gcloud CLI 설정](#gcloud-cli-설정)
```bash
# gcloud 설치
curl https://sdk.cloud.google.com | bash
source ~/.bashrc

# gcloud 초기화
gcloud init

# GKE 클러스터 인증
gcloud container clusters get-credentials CLUSTER_NAME --zone ZONE
```

### Helm 설치

[Helm 설치](#helm-설치)
```bash
# Helm 설치
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Helm 버전 확인
helm version
```

</details>

---

## 🚀 Kubernetes 고급 아키텍처

### 📚 이론: Kubernetes 아키텍처 원리

[📚 이론: Kubernetes 아키텍처 원리](#이론-kubernetes-아키텍처-원리)

#### Kubernetes의 설계 철학

- **선언적 API**: 원하는 상태를 선언하면 시스템이 자동으로 조정
- **마이크로서비스 친화적**: 작은 독립적인 서비스들의 조합
- **클라우드 네이티브**: 클라우드 환경에 최적화된 설계
- **확장 가능성**: 수평적 확장과 자동 스케일링 지원

#### 컨테이너 오케스트레이션의 필요성

- **수동 관리의 한계**: 수십, 수백 개의 컨테이너 관리의 복잡성
- **고가용성 요구**: 장애 복구, 로드 밸런싱, 자동 스케일링
- **서비스 디스커버리**: 동적으로 변하는 컨테이너 위치 관리
- **설정 관리**: 환경별 설정, 시크릿, 설정 파일 관리

#### Kubernetes의 핵심 개념

- **Pod**: 가장 작은 배포 단위, 하나 이상의 컨테이너 그룹
- **Service**: Pod들의 안정적인 네트워크 엔드포인트 제공
- **Deployment**: Pod의 선언적 업데이트 및 롤백 관리
- **ConfigMap/Secret**: 설정 데이터와 민감한 정보 관리

<details>
<summary>📖 Kubernetes 아키텍처 개요</summary>

### 클러스터 구성 요소

[클러스터 구성 요소](#클러스터-구성-요소)
- **Control Plane**: 클러스터 관리 및 제어
- **Worker Nodes**: 실제 워크로드 실행
- **etcd**: 클러스터 상태 저장
- **API Server**: 클러스터 API 제공

### Control Plane 컴포넌트

[Control Plane 컴포넌트](#control-plane-컴포넌트)
| 컴포넌트 | 역할 | 특징 |
|----------|------|------|
| **API Server** | 클러스터 API 제공 | RESTful API, 인증/인가 |
| **etcd** | 클러스터 상태 저장 | 분산 키-값 저장소 |
| **Scheduler** | Pod 스케줄링 | 리소스 요구사항 기반 |
| **Controller Manager** | 컨트롤러 실행 | 상태 관리 및 조정 |

### Worker Node 컴포넌트

[Worker Node 컴포넌트](#worker-node-컴포넌트)
| 컴포넌트 | 역할 | 특징 |
|----------|------|------|
| **kubelet** | Pod 관리 | 컨테이너 생명주기 관리 |
| **kube-proxy** | 네트워크 프록시 | 서비스 로드밸런싱 |
| **Container Runtime** | 컨테이너 실행 | Docker, containerd 등 |

</details>

<details>
<summary>📖 GKE 클러스터 아키텍처</summary>

### GKE 클러스터 구성

[GKE 클러스터 구성](#gke-클러스터-구성)
- **Managed Control Plane**: Google이 관리하는 Control Plane
- **Node Pools**: Worker Node 그룹
- **Auto Scaling**: 자동 스케일링
- **Networking**: VPC 네트워킹

### GKE 클러스터 타입

[GKE 클러스터 타입](#gke-클러스터-타입)
| 타입 | 설명 | 특징 |
|------|------|------|
| **Standard** | 일반 클러스터 | 완전 제어 가능 |
| **Autopilot** | 관리형 클러스터 | 자동 최적화 |
| **Private** | 프라이빗 클러스터 | 네트워크 격리 |

### GKE 클러스터 생성

[GKE 클러스터 생성](#gke-클러스터-생성)
```bash
# Standard 클러스터 생성
gcloud container clusters create my-cluster \
    --zone=asia-northeast3-a \
    --num-nodes=3 \
    --machine-type=e2-medium \
    --enable-autoscaling \
    --min-nodes=1 \
    --max-nodes=5 \
    --enable-autorepair \
    --enable-autoupgrade

# Autopilot 클러스터 생성
gcloud container clusters create-auto my-autopilot-cluster \
    --region=asia-northeast3 \
    --release-channel=regular

# Private 클러스터 생성
gcloud container clusters create my-private-cluster \
    --zone=asia-northeast3-a \
    --num-nodes=3 \
    --machine-type=e2-medium \
    --enable-private-nodes \
    --master-ipv4-cidr=172.16.0.0/28 \
    --enable-ip-alias
```

</details>

<details>
<summary>📖 GKE 클러스터 고급 설정</summary>

### 클러스터 업그레이드

[클러스터 업그레이드](#클러스터-업그레이드)
```bash
# 클러스터 버전 확인
gcloud container clusters describe my-cluster --zone=asia-northeast3-a

# 클러스터 업그레이드
gcloud container clusters upgrade my-cluster \
    --zone=asia-northeast3-a \
    --cluster-version=1.28.0

# Node Pool 업그레이드
gcloud container node-pools upgrade my-node-pool \
    --cluster=my-cluster \
    --zone=asia-northeast3-a \
    --node-version=1.28.0
```

### 클러스터 모니터링

[클러스터 모니터링](#클러스터-모니터링)
```bash
# 클러스터 상태 확인
kubectl cluster-info

# Node 상태 확인
kubectl get nodes -o wide

# Pod 상태 확인
kubectl get pods --all-namespaces

# 클러스터 이벤트 확인
kubectl get events --sort-by=.metadata.creationTimestamp
```

</details>

---

## 🐳 컨테이너 오케스트레이션 고급 기법

<details>
<summary>📖 Kubernetes 리소스 관리</summary>

### 핵심 리소스

[핵심 리소스](#핵심-리소스)
- **Pod**: 컨테이너 실행 단위
- **Deployment**: Pod 배포 및 관리
- **Service**: 네트워크 서비스 제공
- **Ingress**: HTTP/HTTPS 라우팅

### 고급 리소스

[고급 리소스](#고급-리소스)
- **ConfigMap**: 설정 데이터 관리
- **Secret**: 민감한 데이터 관리
- **PersistentVolume**: 영구 스토리지
- **Namespace**: 리소스 격리

</details>

<details>
<summary>📖 Deployment 고급 설정</summary>

### 고급 Deployment 설정

[고급 Deployment 설정](#고급-deployment-설정)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: production
  labels:
    app: my-app
    version: v1.0.0
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
        version: v1.0.0
    spec:
      containers:
      - name: my-app
        image: my-app:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: my-app-secret
              key: database-url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
        volumeMounts:
        - name: config-volume
          mountPath: /app/config
        - name: data-volume
          mountPath: /app/data
      volumes:
      - name: config-volume
        configMap:
          name: my-app-config
      - name: data-volume
        persistentVolumeClaim:
          claimName: my-app-pvc
      nodeSelector:
        kubernetes.io/os: linux
      tolerations:
      - key: "node-role.kubernetes.io/master"
        operator: "Exists"
        effect: "NoSchedule"
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - my-app
              topologyKey: kubernetes.io/hostname
```

</details>

<details>
<summary>📖 Service 및 Ingress 설정</summary>

### Service 설정

[Service 설정](#service-설정)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
  namespace: production
spec:
  selector:
    app: my-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  type: ClusterIP
---
apiVersion: v1
kind: Service
metadata:
  name: my-app-loadbalancer
  namespace: production
spec:
  selector:
    app: my-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  type: LoadBalancer
```

### Ingress 설정

[Ingress 설정](#ingress-설정)
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  namespace: production
  annotations:
    kubernetes.io/ingress.class: "gce"
    kubernetes.io/ingress.global-static-ip-name: "my-app-ip"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - my-app.example.com
    secretName: my-app-tls
  rules:
  - host: my-app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app-service
            port:
              number: 80
```

</details>

<details>
<summary>📖 ConfigMap 및 Secret 관리</summary>

### ConfigMap 설정

[ConfigMap 설정](#configmap-설정)
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-app-config
  namespace: production
data:
  app.properties: |
    server.port=3000
    logging.level=INFO
    database.host=postgres-service
    database.port=5432
  nginx.conf: |
    server {
        listen 80;
        server_name my-app.example.com;
        location / {
            proxy_pass http://my-app-service:80;
        }
    }
```

### Secret 설정

[Secret 설정](#secret-설정)
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-app-secret
  namespace: production
type: Opaque
data:
  database-url: cG9zdGdyZXNxbDovL3VzZXI6cGFzc3dvcmRAcG9zdGdyZXMtc2VydmljZTo1NDMyL215YXBw
  api-key: YWJjZGVmZ2hpams=
stringData:
  database-url: postgresql://user:password@postgres-service:5432/myapp
  api-key: abcdefghijk
```

</details>

<details>
<summary>📖 PersistentVolume 및 PersistentVolumeClaim</summary>

### PersistentVolume 설정

[PersistentVolume 설정](#persistentvolume-설정)
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-app-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  gcePersistentDisk:
    pdName: my-app-disk
    fsType: ext4
```

### PersistentVolumeClaim 설정

[PersistentVolumeClaim 설정](#persistentvolumeclaim-설정)
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-app-pvc
  namespace: production
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: standard
```

</details>

---

## 🚀 AWS ECS 및 Fargate 심화

<details>
<summary>📖 ECS 아키텍처 개요</summary>

### ECS 구성 요소

[ECS 구성 요소](#ecs-구성-요소)
- **Cluster**: 컨테이너 실행 환경
- **Task Definition**: 컨테이너 실행 명세
- **Service**: Task 관리 및 스케일링
- **Fargate**: 서버리스 컨테이너 실행

### ECS vs Fargate

[ECS vs Fargate](#ecs-vs-fargate)
| 구분 | ECS | Fargate |
|------|-----|---------|
| **인프라 관리** | 사용자 관리 | AWS 관리 |
| **스케일링** | 수동 설정 | 자동 스케일링 |
| **비용** | 인스턴스 기반 | 사용량 기반 |
| **제어** | 높음 | 중간 |

</details>

<details>
<summary>📖 ECS 클러스터 구성</summary>

### ECS 클러스터 생성

[ECS 클러스터 생성](#ecs-클러스터-생성)
```bash
# ECS 클러스터 생성
aws ecs create-cluster \
    --cluster-name my-ecs-cluster \
    --capacity-providers FARGATE FARGATE_SPOT \
    --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1

# 클러스터 상태 확인
aws ecs describe-clusters --clusters my-ecs-cluster
```

### Task Definition 생성

[Task Definition 생성](#task-definition-생성)
```json
{
  "family": "my-app-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::ACCOUNT:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::ACCOUNT:role/ecsTaskRole",
  "containerDefinitions": [
    {
      "name": "my-app",
      "image": "my-app:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        }
      ],
      "secrets": [
        {
          "name": "DATABASE_URL",
          "valueFrom": "arn:aws:secretsmanager:region:account:secret:my-app/database-url"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/my-app",
          "awslogs-region": "ap-northeast-2",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      }
    }
  ]
}
```

</details>

<details>
<summary>📖 Fargate 서비스 배포</summary>

### Fargate 서비스 생성

[Fargate 서비스 생성](#fargate-서비스-생성)
```bash
# Fargate 서비스 생성
aws ecs create-service \
    --cluster my-ecs-cluster \
    --service-name my-app-service \
    --task-definition my-app-task:1 \
    --desired-count 3 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[subnet-12345,subnet-67890],securityGroups=[sg-12345],assignPublicIp=ENABLED}" \
    --load-balancers "targetGroupArn=arn:aws:elasticloadbalancing:region:account:targetgroup/my-app-tg/1234567890123456,containerName=my-app,containerPort=3000" \
    --enable-execute-command

# 서비스 상태 확인
aws ecs describe-services \
    --cluster my-ecs-cluster \
    --services my-app-service
```

### Auto Scaling 설정

[Auto Scaling 설정](#auto-scaling-설정)
```bash
# Auto Scaling 정책 생성
aws application-autoscaling register-scalable-target \
    --service-namespace ecs \
    --resource-id service/my-ecs-cluster/my-app-service \
    --scalable-dimension ecs:service:DesiredCount \
    --min-capacity 1 \
    --max-capacity 10

# CPU 기반 스케일링 정책
aws application-autoscaling put-scaling-policy \
    --service-namespace ecs \
    --resource-id service/my-ecs-cluster/my-app-service \
    --scalable-dimension ecs:service:DesiredCount \
    --policy-name my-app-cpu-scaling \
    --policy-type TargetTrackingScaling \
    --target-tracking-scaling-policy-configuration '{
        "TargetValue": 70.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ECSServiceAverageCPUUtilization"
        },
        "ScaleOutCooldown": 300,
        "ScaleInCooldown": 300
    }'
```

</details>

<details>
<summary>📖 ECS 모니터링 및 로깅</summary>

### CloudWatch 로그 설정

[CloudWatch 로그 설정](#cloudwatch-로그-설정)
```bash
# 로그 그룹 생성
aws logs create-log-group \
    --log-group-name /ecs/my-app \
    --retention-in-days 30

# 로그 스트림 확인
aws logs describe-log-streams \
    --log-group-name /ecs/my-app
```

### CloudWatch 메트릭 설정

[CloudWatch 메트릭 설정](#cloudwatch-메트릭-설정)
```bash
# 커스텀 메트릭 전송
aws cloudwatch put-metric-data \
    --namespace "MyApp/ECS" \
    --metric-data MetricName=RequestCount,Value=100,Unit=Count
```

</details>

---

## 🚀 고급 CI/CD 파이프라인

<details>
<summary>📖 GitOps 기반 배포</summary>

### GitOps 개념

[GitOps 개념](#gitops-개념)
- **선언적 설정**: Git을 단일 진실 소스로 사용
- **자동 동기화**: Git 변경사항을 클러스터에 자동 적용
- **롤백 지원**: Git 히스토리를 통한 롤백
- **감사 추적**: 모든 변경사항 추적

### GitOps 도구

[GitOps 도구](#gitops-도구)
- **ArgoCD**: Kubernetes GitOps 도구
- **Flux**: GitOps 운영 도구
- **Tekton**: Kubernetes 네이티브 CI/CD

</details>

<details>
<summary>📖 ArgoCD 설정</summary>

### ArgoCD 설치

[ArgoCD 설치](#argocd-설치)
```bash
# ArgoCD 네임스페이스 생성
kubectl create namespace argocd

# ArgoCD 설치
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# ArgoCD 서비스 확인
kubectl get svc -n argocd
```

### ArgoCD 애플리케이션 설정

[ArgoCD 애플리케이션 설정](#argocd-애플리케이션-설정)
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/username/my-app-k8s
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
    - PrunePropagationPolicy=foreground
    - PruneLast=true
```

</details>

<details>
<summary>📖 Tekton 파이프라인</summary>

### Tekton 설치

[Tekton 설치](#tekton-설치)
```bash
# Tekton 설치
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

# Tekton 설치 확인
kubectl get pods --namespace tekton-pipelines
```

### Tekton 파이프라인 설정

[Tekton 파이프라인 설정](#tekton-파이프라인-설정)
```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: my-app-pipeline
spec:
  params:
  - name: git-url
    type: string
  - name: git-revision
    type: string
  - name: image-tag
    type: string
  tasks:
  - name: fetch-source
    taskRef:
      name: git-clone
    params:
    - name: url
      value: $(params.git-url)
    - name: revision
      value: $(params.git-revision)
  - name: build-image
    taskRef:
      name: buildah
    runAfter:
    - fetch-source
    params:
    - name: IMAGE
      value: my-app:$(params.image-tag)
  - name: deploy
    taskRef:
      name: kubectl
    runAfter:
    - build-image
    params:
    - name: manifest
      value: k8s/
```

</details>

---

## 📚 문제 해결 및 참고 자료

<details>
<summary>🐛 자주 발생하는 문제</summary>

### Kubernetes 관련 문제

[Kubernetes 관련 문제](#kubernetes-관련-문제)
<details>
<summary>❌ Pod 시작 실패</summary>

**원인**: 
- 이미지 없음
- 리소스 부족
- 설정 오류

**해결방법**:
```bash
# 1. Pod 상태 확인
kubectl get pods
kubectl describe pod POD_NAME

# 2. 이벤트 확인
kubectl get events --sort-by=.metadata.creationTimestamp

# 3. 로그 확인
kubectl logs POD_NAME
```

</details>

<details>
<summary>❌ 서비스 연결 실패</summary>

**원인**:
- 서비스 설정 오류
- 네트워크 정책 문제
- DNS 문제

**해결방법**:
```bash
# 1. 서비스 상태 확인
kubectl get svc
kubectl describe svc SERVICE_NAME

# 2. 엔드포인트 확인
kubectl get endpoints

# 3. 네트워크 정책 확인
kubectl get networkpolicies
```

</details>

### ECS/Fargate 관련 문제

[ECS/Fargate 관련 문제](#ecsfargate-관련-문제)
<details>
<summary>❌ Task 시작 실패</summary>

**원인**:
- Task Definition 오류
- IAM 권한 부족
- 리소스 부족

**해결방법**:
```bash
# 1. Task 상태 확인
aws ecs describe-tasks --cluster CLUSTER_NAME --tasks TASK_ARN

# 2. Task Definition 확인
aws ecs describe-task-definition --task-definition TASK_DEFINITION

# 3. 로그 확인
aws logs get-log-events --log-group-name /ecs/my-app --log-stream-name LOG_STREAM
```

</details>

</details>

<details>
<summary>📖 추가 학습 자료</summary>

### 공식 문서

[공식 문서](#공식-문서)
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [GKE 공식 문서](https://cloud.google.com/kubernetes-engine/docs)
- [ECS 공식 문서](https://docs.aws.amazon.com/ecs/)
- [Fargate 공식 문서](https://docs.aws.amazon.com/fargate/)

### 유용한 리소스

[유용한 리소스](#유용한-리소스)
- [Kubernetes 예제](https://github.com/kubernetes/examples)
- [ArgoCD 공식 문서](https://argo-cd.readthedocs.io/)
- [Tekton 공식 문서](https://tekton.dev/docs/)

### 관련 프로젝트

[관련 프로젝트](#관련-프로젝트)
- [Kubernetes 샘플 프로젝트](https://github.com/kubernetes/examples)
- [ArgoCD 샘플](https://github.com/argoproj/argo-cd)

</details>

<details>
<summary>🚀 다음 단계</summary>

### 2일차 준비

[2일차 준비](#2일차-준비)
1. **고가용성 아키텍처**: Multi-AZ, Multi-Region
2. **로드 밸런싱**: ELB, Cloud Load Balancing
3. **모니터링**: CloudWatch, Cloud Monitoring
4. **종합 프로젝트**: 실제 서비스 아키텍처 구현

### 고급 기능

[고급 기능](#고급-기능)
1. **서비스 메시**: Istio, Linkerd
2. **보안**: Pod Security Policy, Network Policy
3. **성능**: HPA, VPA, Cluster Autoscaler
4. **운영**: 백업, 재해 복구

</details>

---

## 🎉 완료!

[🎉 완료!](#완료)

축하합니다! Cloud Container 1일차 실습을 완료했습니다.

### 📚 학습 요약

[📚 학습 요약](#학습-요약)

이번 실습을 통해 다음을 배웠습니다:

1. **☸️ Kubernetes 고급**: 클러스터 아키텍처, GKE 관리
2. **🐳 컨테이너 오케스트레이션**: Deployment, Service, Ingress
3. **☁️ ECS/Fargate**: 서버리스 컨테이너 실행
4. **🚀 GitOps**: ArgoCD, Tekton 파이프라인

### 📝 학습 피드백 수집

[📝 학습 피드백 수집](#학습-피드백-수집)

#### 실습 완료 체크리스트

- [ ] Kubernetes 클러스터 아키텍처 이해 완료
- [ ] GKE 클러스터 생성 및 설정 완료
- [ ] Deployment, Service, Ingress 설정 실습 완료
- [ ] ECS Fargate 서비스 배포 실습 완료
- [ ] GitOps 기반 CI/CD 파이프라인 구축 완료

#### 학습 난이도 평가

- **매우 쉬움** ⭐
- **쉬움** ⭐⭐
- **보통** ⭐⭐⭐
- **어려움** ⭐⭐⭐⭐
- **매우 어려움** ⭐⭐⭐⭐⭐

#### 개선 제안

- 실습 중 어려웠던 부분: ________________
- 추가로 배우고 싶은 내용: ________________
- 실습 시간이 충분했는지: □ 충분함 □ 부족함 □ 과도함

### 🚀 다음 단계

[🚀 다음 단계](#다음-단계)

- **2일차 실습**: 고가용성 아키텍처, 로드 밸런싱, 모니터링
- **실제 프로젝트 적용**: 자신의 프로젝트에 컨테이너 오케스트레이션 적용
- **고급 기능 학습**: 서비스 메시, 보안, 성능 최적화

### 💡 추가 학습 자료

[💡 추가 학습 자료](#추가-학습-자료)

- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [GKE 공식 문서](https://cloud.google.com/kubernetes-engine/docs)
- Cloud Container 2일차 실습
- [피드백 제출](https://forms.gle/example)

---

<div align="center">

## 🎉 Day 1 실습을 시작하세요!

[🎉 Day 1 실습을 시작하세요!](#day-1-실습을-시작하세요)

[🚀 실습 시작하기](/mcp_knowledge_base/cloud_container/textbook/Day1/practice/container-basics.md) | 
📚 Cloud Basic 과정 전체 |
[🏠 홈으로 돌아가기](/mcp_knowledge_base/index.md)

</div>

---

<div align="center">

## ⬅️ 이전/다음 네비게이션

[⬅️ 이전/다음 네비게이션](#이전다음-네비게이션)
← 이전: Cloud Container 메인 | [다음: Cloud Container 2일차 →](/mcp_knowledge_base/cloud_container/textbook/Day2/README.md)

</div>
