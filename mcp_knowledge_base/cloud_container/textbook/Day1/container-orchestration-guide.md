# Advanced 3교시: AWS ECS / GCP GKE로 실제 배포 실습


## 📋 목차

["📋 목차"]["#목차"]
1. ["Master 과정과의 연계"]["#master-과정과의-연계"]
2. ["컨테이너 오케스트레이션 개념"]["#컨테이너-오케스트레이션-개념"]
3. ["AWS ECS vs GCP GKE 비교"]["#aws-ecs-vs-gcp-gke-비교"]
4. ["AWS ECS 아키텍처"]["#aws-ecs-아키텍처"]
5. ["GCP GKE 아키텍처"]["#gcp-gke-아키텍처"]
6. ["실습 목표"]["#실습-목표"]
7. ["실습 절차"]["#실습-절차"]
8. ["실습 코드 예시"]["#실습-코드-예시"]
9. ["예상 결과"]["#예상-결과"]
10. ["혼자 해보기"]["#혼자-해보기"]

---

## 🔗 Master 과정과의 연계

### Master 과정에서 학습한 내용

["Master 과정에서 학습한 내용"]["#master-과정에서-학습한-내용"]
- ✅ **Docker 기초**: 컨테이너 이미지 빌드 및 실행
- ✅ **GitHub Actions**: CI/CD 파이프라인 구축
- ✅ **클라우드 배포 기초**: 배포 개념 및 시뮬레이션
- ✅ **자동 배포 파이프라인**: 테스트 → 빌드 → 배포 자동화

### Container 과정에서 확장하는 내용

["Container 과정에서 확장하는 내용"]["#container-과정에서-확장하는-내용"]
- 🚀 **실제 클라우드 배포**: 시뮬레이션을 넘어 실제 AWS/GCP 환경에 배포
- 🚀 **컨테이너 오케스트레이션**: 다수의 컨테이너를 대규모로 관리
- 🚀 **고급 배포 전략**: 무중단 배포, 롤백, 트래픽 분산
- 🚀 **운영 자동화**: 모니터링, 알림, 자동 복구

### 학습 경로

["학습 경로"]["#학습-경로"]
```
Master 과정 ["기초"] → Container 과정 ["고급"]
     ↓                    ↓
시뮬레이션 배포    →    실제 클라우드 배포
단일 컨테이너     →    컨테이너 오케스트레이션
기본 CI/CD       →    고급 배포 전략
```

### 📦 actions-demo 프로젝트 활용

["📦 actions-demo 프로젝트 활용"]["#actionsdemo-프로젝트-활용"]
Container 과정에서는 Master 과정의 actions-demo 프로젝트를 기반으로 고급 컨테이너 기술을 학습합니다.

#### 프로젝트 설정

["프로젝트 설정"]["#프로젝트-설정"]
```bash
# Container 과정용 환경 설정
./container-demo-setup.sh
```

#### 생성되는 파일들

["생성되는 파일들"]["#생성되는-파일들"]
- `k8s/aws-ecs/task-definition.json`: AWS ECS 태스크 정의
- `k8s/gcp-gke/deployment.yaml`: GCP GKE 배포 매니페스트
- `k8s/monitoring/`: Prometheus + Grafana 설정
- `scripts/`: 배포 자동화 스크립트
- `Dockerfile.container`: 최적화된 Dockerfile

---

## 🎼 컨테이너 오케스트레이션 개념

### 컨테이너 오케스트레이션이란?

["컨테이너 오케스트레이션이란?"]["#컨테이너-오케스트레이션이란"]

컨테이너 오케스트레이션은 **다수의 컨테이너를 대규모로 배포·관리하기 위해 네트워킹, 스케줄링, 확장 등을 자동화**하는 기술입니다.

### 오케스트레이션의 필요성

["오케스트레이션의 필요성"]["#오케스트레이션의-필요성"]

#### 단일 컨테이너의 한계

["단일 컨테이너의 한계"]["#단일-컨테이너의-한계"]
- 수동 관리의 복잡성
- 확장성 부족
- 고가용성 보장 어려움
- 로드 밸런싱 복잡

#### 오케스트레이션의 장점

["오케스트레이션의 장점"]["#오케스트레이션의-장점"]
- **자동 스케줄링**: 컨테이너를 최적의 노드에 배치
- **자동 확장**: 트래픽에 따른 컨테이너 수 조정
- **서비스 디스커버리**: 컨테이너 간 통신 자동화
- **로드 밸런싱**: 트래픽 분산
- **롤링 업데이트**: 무중단 배포
- **헬스체크**: 장애 컨테이너 자동 복구

### 주요 오케스트레이션 도구

["주요 오케스트레이션 도구"]["#주요-오케스트레이션-도구"]

| 도구 | 특징 | 사용 사례 |
|------|------|-----------|
| **Kubernetes** | 가장 인기 있는 오픈소스 | 대규모 마이크로서비스 |
| **Docker Swarm** | Docker 네이티브 | 중소규모 애플리케이션 |
| **AWS ECS** | AWS 관리형 서비스 | AWS 생태계 통합 |
| **GCP GKE** | Google 관리형 Kubernetes | Google Cloud 통합 |

---

## ⚖️ AWS ECS vs GCP GKE 비교

### 기능 비교표

["기능 비교표"]["#기능-비교표"]

| 구분 | AWS ECS | GCP GKE |
|------|---------|---------|
| **기반 기술** | AWS 자체 오케스트레이션 | Kubernetes |
| **관리 복잡도** | 낮음 | 중간 |
| **학습 곡선** | 완만함 | 가파름 |
| **확장성** | 높음 | 매우 높음 |
| **비용** | 중간 | 낮음 |
| **AWS 통합** | 완벽 | 제한적 |
| **GCP 통합** | 제한적 | 완벽 |
| **멀티 클라우드** | 어려움 | 쉬움 |
| **커뮤니티** | 중간 | 매우 활발 |

### 장단점 비교

["장단점 비교"]["#장단점-비교"]

#### AWS ECS 장점

["AWS ECS 장점"]["#aws-ecs-장점"]
- ✅ AWS 서비스와 완벽한 통합
- ✅ 간단한 설정과 관리
- ✅ Fargate를 통한 서버리스 옵션
- ✅ 빠른 시작 시간

#### AWS ECS 단점

["AWS ECS 단점"]["#aws-ecs-단점"]
- ❌ AWS에 종속적
- ❌ Kubernetes 생태계 활용 불가
- ❌ 제한적인 커스터마이징

#### GCP GKE 장점

["GCP GKE 장점"]["#gcp-gke-장점"]
- ✅ Kubernetes 표준 준수
- ✅ 풍부한 생태계
- ✅ 멀티 클라우드 지원
- ✅ 강력한 확장성

#### GCP GKE 단점

["GCP GKE 단점"]["#gcp-gke-단점"]
- ❌ 복잡한 학습 곡선
- ❌ Kubernetes 지식 필요
- ❌ 초기 설정 복잡

---

## 🏗️ AWS ECS 아키텍처

```mermaid
flowchart TB
    subgraph "AWS ECS Architecture"
        A[Application Load Balancer] -->> B[ECS Cluster]
        B -->> C[Task Definition]
        C -->> D[Service]
        D -->> E[Tasks/Containers]
        
        F[ECR Registry] -->> C
        G[CloudWatch] -->> B
        H[Auto Scaling] -->> D
        I[VPC] -->> B
    end
    
    subgraph "ECS Components"
        J[Cluster]
        K[Task Definition]
        L[Service]
        M[Task]
    end
```

### ECS 핵심 구성요소

["ECS 핵심 구성요소"]["#ecs-핵심-구성요소"]

#### 1. **Cluster ["클러스터"]**

[1. **Cluster ["클러스터"]**]["#1-cluster-클러스터"]
- ECS 태스크를 실행하는 인프라
- EC2 인스턴스 또는 Fargate로 구성

#### 2. **Task Definition ["태스크 정의"]**

[2. **Task Definition ["태스크 정의"]**]["#2-task-definition-태스크-정의"]
- 컨테이너 실행을 위한 템플릿
- CPU, 메모리, 포트, 환경변수 등 정의

#### 3. **Service ["서비스"]**

[3. **Service ["서비스"]**]["#3-service-서비스"]
- 태스크 정의를 기반으로 태스크 실행
- 로드 밸런싱, 자동 확장, 헬스체크 관리

#### 4. **Task ["태스크"]**

[4. **Task ["태스크"]**]["#4-task-태스크"]
- Task Definition의 실행 인스턴스
- 하나 이상의 컨테이너 포함

### ECS 실행 모드

["ECS 실행 모드"]["#ecs-실행-모드"]

| 모드 | 설명 | 장점 | 단점 |
|------|------|------|------|
| **EC2** | EC2 인스턴스에서 실행 | 비용 효율적, 제어 가능 | 인프라 관리 필요 |
| **Fargate** | 서버리스 실행 | 관리 불필요, 간단 | 비용 높음, 제한적 |

---

## ☸️ GCP GKE 아키텍처

```mermaid
flowchart TB
    subgraph "GCP GKE Architecture"
        A[Load Balancer] -->> B[Ingress]
        B -->> C[Service]
        C -->> D[Deployment]
        D -->> E[ReplicaSet]
        E -->> F[Pods]
        
        G[GCR Registry] -->> D
        H[Cloud Monitoring] -->> F
        I[Horizontal Pod Autoscaler] -->> D
        J[VPC Network] -->> F
    end
    
    subgraph "Kubernetes Components"
        K[Master Node]
        L[Worker Nodes]
        M[Pods]
        N[Services]
    end
```

### Kubernetes 핵심 구성요소

["Kubernetes 핵심 구성요소"]["#kubernetes-핵심-구성요소"]

#### 1. **Deployment ["배포"]**

[1. **Deployment ["배포"]**]["#1-deployment-배포"]
- 애플리케이션의 배포 상태 관리
- 롤링 업데이트, 롤백 지원

#### 2. **Service ["서비스"]**

[2. **Service ["서비스"]**]["#2-service-서비스"]
- Pod 집합에 대한 네트워크 엔드포인트
- 로드 밸런싱, 서비스 디스커버리

#### 3. **Pod ["파드"]**

[3. **Pod ["파드"]**]["#3-pod-파드"]
- 하나 이상의 컨테이너 그룹
- Kubernetes의 최소 실행 단위

#### 4. **ReplicaSet ["레플리카셋"]**

[4. **ReplicaSet ["레플리카셋"]**]["#4-replicaset-레플리카셋"]
- Pod의 복제본 수 관리
- 자동 복구, 확장 지원

---

## 🎯 실습 목표

이 실습을 통해 다음을 달성합니다:

1. **AWS ECS 배포**: AWS ECS 환경에서 동일한 컨테이너 애플리케이션을 배포합니다.

2. **GCP GKE 배포**: GCP GKE 환경에서 동일한 컨테이너 애플리케이션을 배포합니다.

3. **클러스터 관리**: 클러스터 생성, 컨테이너 레지스트리 등록, 애플리케이션 배포 과정을 익힙니다.

4. **비교 분석**: 두 플랫폼의 차이점과 장단점을 실제 경험을 통해 이해합니다.

---

## 📝 실습 절차

### 1단계: 컨테이너 이미지 준비

["1단계: 컨테이너 이미지 준비"]["#1단계-컨테이너-이미지-준비"]

#### Docker 이미지 빌드

["Docker 이미지 빌드"]["#docker-이미지-빌드"]
```bash
# 프로젝트 디렉토리에서
docker build -t my-app:latest .

# 이미지 태그 지정
docker tag my-app:latest my-app:v1.0.0
```

### 2단계: AWS ECS 배포

["2단계: AWS ECS 배포"]["#2단계-aws-ecs-배포"]

#### AWS ECR 리포지토리 생성

["AWS ECR 리포지토리 생성"]["#aws-ecr-리포지토리-생성"]
```bash
# ECR 리포지토리 생성
aws ecr create-repository --repository-name my-app

# ECR 로그인
aws ecr get-login-password --region us-west-1 | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.us-west-1.amazonaws.com

# 이미지 태그 및 푸시
docker tag my-app:latest <AWS_ACCOUNT_ID>.dkr.ecr.us-west-1.amazonaws.com/my-app:latest
docker push <AWS_ACCOUNT_ID>.dkr.ecr.us-west-1.amazonaws.com/my-app:latest
```

#### ECS 클러스터 생성

["ECS 클러스터 생성"]["#ecs-클러스터-생성"]
```bash
# ECS 클러스터 생성 [Fargate]
aws ecs create-cluster --cluster-name my-cluster

# 또는 EC2 기반 클러스터
aws ecs create-cluster --cluster-name my-cluster --capacity-providers EC2
```

#### Task Definition 생성

["Task Definition 생성"]["#task-definition-생성"]
```json
{
  "family": "my-app-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::<ACCOUNT_ID>:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "my-app",
      "image": "<AWS_ACCOUNT_ID>.dkr.ecr.us-west-1.amazonaws.com/my-app:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/my-app",
          "awslogs-region": "us-west-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

#### ECS 서비스 생성

["ECS 서비스 생성"]["#ecs-서비스-생성"]
```bash
# CloudWatch 로그 그룹 생성
aws logs create-log-group --log-group-name /ecs/my-app

# 서비스 생성
aws ecs create-service /
  --cluster my-cluster /
  --service-name my-app-service /
  --task-definition my-app-task /
  --desired-count 2 /
  --launch-type FARGATE /
  --network-configuration "awsvpcConfiguration={subnets=[subnet-12345],securityGroups=[sg-12345],assignPublicIp=ENABLED}"
```

### 3단계: GCP GKE 배포

["3단계: GCP GKE 배포"]["#3단계-gcp-gke-배포"]

#### GCP 프로젝트 설정

["GCP 프로젝트 설정"]["#gcp-프로젝트-설정"]
```bash
# GCP 프로젝트 설정
gcloud config set project YOUR_PROJECT_ID

# GKE API 활성화
gcloud services enable container.googleapis.com
```

#### GKE 클러스터 생성

["GKE 클러스터 생성"]["#gke-클러스터-생성"]
```bash
# GKE 클러스터 생성
gcloud container clusters create my-cluster /
  --zone us-central1-a /
  --num-nodes 3 /
  --machine-type e2-medium /
  --enable-autoscaling /
  --min-nodes 1 /
  --max-nodes 5

# 클러스터 인증
gcloud container clusters get-credentials my-cluster --zone us-central1-a
```

#### GCR에 이미지 푸시

["GCR에 이미지 푸시"]["#gcr에-이미지-푸시"]
```bash
# GCR 인증
gcloud auth configure-docker

# 이미지 태그 및 푸시
docker tag my-app:latest gcr.io/YOUR_PROJECT_ID/my-app:latest
docker push gcr.io/YOUR_PROJECT_ID/my-app:latest
```

#### Kubernetes 매니페스트 작성

["Kubernetes 매니페스트 작성"]["#kubernetes-매니페스트-작성"]
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-deployment
  labels:
    app: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: gcr.io/YOUR_PROJECT_ID/my-app:latest
        ports:
        - containerPort: 3000
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
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
---
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
  selector:
    app: my-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  type: LoadBalancer
```

#### GKE에 배포

["GKE에 배포"]["#gke에-배포"]
```bash
# 배포 실행
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# 배포 상태 확인
kubectl get deployments
kubectl get services
kubectl get pods
```

---

## 💻 실습 코드 예시

### AWS ECS Task Definition ["상세 버전"]

["AWS ECS Task Definition ["상세 버전"]"]["#aws-ecs-task-definition-상세-버전"]
```json
{
  "family": "my-app-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::<ACCOUNT_ID>:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::<ACCOUNT_ID>:role/ecsTaskRole",
  "containerDefinitions": [
    {
      "name": "my-app",
      "image": "<AWS_ACCOUNT_ID>.dkr.ecr.us-west-1.amazonaws.com/my-app:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        },
        {
          "name": "PORT",
          "value": "3000"
        }
      ],
      "secrets": [
        {
          "name": "DATABASE_URL",
          "valueFrom": "arn:aws:ssm:us-west-1:<ACCOUNT_ID>:parameter/my-app/database-url"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/my-app",
          "awslogs-region": "us-west-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": [
          "CMD-SHELL",
          "curl -f http://localhost:3000/health || exit 1"
        ],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      }
    }
  ]
}
```

### GCP GKE 매니페스트 ["고급 버전"]

["GCP GKE 매니페스트 ["고급 버전"]"]["#gcp-gke-매니페스트-고급-버전"]
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-deployment
  labels:
    app: my-app
    version: v1.0.0
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
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
        image: gcr.io/YOUR_PROJECT_ID/my-app:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        - name: PORT
          value: "3000"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: my-app-secrets
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
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
        volumeMounts:
        - name: config-volume
          mountPath: /app/config
      volumes:
      - name: config-volume
        configMap:
          name: my-app-config
---
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
  labels:
    app: my-app
spec:
  selector:
    app: my-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  type: LoadBalancer
  sessionAffinity: None
---
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-app-config
data:
  app.properties: |
    server.port=3000
    logging.level=INFO
---
# secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-app-secrets
type: Opaque
data:
  database-url: <base64-encoded-database-url>
```

### 자동 확장 설정

["자동 확장 설정"]["#자동-확장-설정"]

#### AWS ECS Auto Scaling

[AWS ECS Auto Scaling][#aws-ecs-auto-scaling]
```json
{
  "serviceName": "my-app-service",
  "clusterName": "my-cluster",
  "scalableDimension": "ecs:service:DesiredCount",
  "minCapacity": 1,
  "maxCapacity": 10,
  "roleARN": "arn:aws:iam::<ACCOUNT_ID>:role/ecsAutoscaleRole",
  "targetTrackingScalingPolicies": [
    {
      "targetValue": 70.0,
      "scaleOutCooldown": 300,
      "scaleInCooldown": 300,
      "metricType": "ECSServiceAverageCPUUtilization"
    }
  ]
}
```

#### GCP GKE Horizontal Pod Autoscaler

[GCP GKE Horizontal Pod Autoscaler][#gcp-gke-horizontal-pod-autoscaler]
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app-deployment
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

---

## ✅ 예상 결과

### AWS ECS 배포 결과

["AWS ECS 배포 결과"]["#aws-ecs-배포-결과"]
- ECS 콘솔에서 새로 생성한 클러스터와 서비스가 "ACTIVE" 상태로 표시
- 각 태스크[Task]가 실행 중임을 확인
- 서비스에 연결한 ALB의 도메인 이름 또는 퍼블릭 IP로 웹 브라우저 접속 시 애플리케이션 정상 실행

### GCP GKE 배포 결과

["GCP GKE 배포 결과"]["#gcp-gke-배포-결과"]
- `kubectl get pods` 명령으로 3개의 파드가 정상 기동되었음을 확인
- `kubectl get svc` 명령으로 생성된 LoadBalancer 서비스의 External IP 확인
- 해당 IP로 접속하면 애플리케이션 화면이 나타남

### 성능 비교

["성능 비교"]["#성능-비교"]
- **배포 시간**: ECS ["2-3분"] vs GKE ["3-5분"]
- **관리 복잡도**: ECS ["낮음"] vs GKE ["중간"]
- **확장성**: ECS ["좋음"] vs GKE ["매우 좋음"]

---

## 🚀 혼자 해보기

### 기본 과제

["기본 과제"]["#기본-과제"]
1. **ECS 서비스 스케일 조정**: ECS 서비스의 Desired count를 늘려보거나 CLI로 update-service를 사용해 보세요.

2. **GKE 파드 확장**: `kubectl scale deployment/my-app-deployment --replicas=5` 명령으로 복제 수를 변경해 보세요.

3. **로드 밸런싱 테스트**: 여러 요청을 보내서 로드 밸런싱이 정상 작동하는지 확인해 보세요.

### 고급 과제

["고급 과제"]["#고급-과제"]
1. **롤링 업데이트**: 새로운 이미지 버전으로 무중단 업데이트를 수행해 보세요.

2. **헬스체크 설정**: 애플리케이션에 헬스체크 엔드포인트를 추가하고 오케스트레이션 플랫폼에서 모니터링하도록 설정해 보세요.

3. **자동 확장**: CPU 사용률 기반으로 자동 확장이 작동하는지 테스트해 보세요.

---

## ❓ 퀴즈

["❓ 퀴즈"]["#퀴즈"]

1. **AWS ECS에서 Task Definition은 무엇을 설명하나요?**

2. **GKE에서 ReplicaSet과 Deployment의 관계는 무엇인가요?**

3. **ECS와 EKS, GKE 중 Kubernetes 기반이 아닌 서비스는 무엇인가요?**

4. **Fargate와 EC2 실행 모드의 차이점은 무엇인가요?**

---

## ✅ 체크리스트

["✅ 체크리스트"]["#체크리스트"]

- [ ] AWS ECR에 이미지를 정상 푸시했나요?
- [ ] ECS 클러스터와 서비스가 생성되었나요?
- [ ] GKE 클러스터가 생성되고 인증되었나요?
- [ ] Deployment와 Service로 애플리케이션이 실행되었나요?
- [ ] 두 플랫폼에서 애플리케이션이 정상 접속되나요?
- [ ] 로드 밸런싱이 정상 작동하나요?

---

## 📚 추가 학습 자료

["📚 추가 학습 자료"]["#추가-학습-자료"]

- ["AWS ECS 공식 문서"][https:///docs.aws.amazon.com/ecs/]
- ["GCP GKE 공식 문서"][https:///cloud.google.com/kubernetes-engine/docs]
- ["Kubernetes 공식 문서"][https:///kubernetes.io/docs/]
- ["컨테이너 오케스트레이션 가이드"][https:///www.redhat.com/en/topics/containers/what-is-container-orchestration]

다음 단계: ["4교시: 전체 자동 배포 파이프라인 구성"](cloud_master/textbook/Day1/guides/cicd-pipeline-guide.md)


---


---



<div align="center">

["← 이전: Cloud Container 1일차 메인"](README.md) | ["📚 전체 커리큘럼"](curriculum.md) | ["🏠 학습 경로로 돌아가기"](index.md) | ["📋 학습 경로"](learning-path.md)

</div>