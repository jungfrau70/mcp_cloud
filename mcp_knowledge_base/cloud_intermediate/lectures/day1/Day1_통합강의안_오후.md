# ☁️ 클라우드 중급 과정 - Day 1 통합 강의안 (오후)

## 📋 오후 강의 개요

### 🎯 오후 강의 목표
- **클라우드 컨테이너 서비스**: AWS ECS, GCP Cloud Run을 활용하여 클라우드 환경에 컨테이너 애플리케이션 배포
- **통합 모니터링 허브**: AWS VM 기반 Prometheus + Grafana를 구축하여 모니터링 인프라 준비
- **외부 접속 및 보안**: AWS 보안 그룹 자동 설정 및 외부 접속 테스트를 통한 실습 환경 검증

### ⏰ 오후 강의 시간표
| 시간 | 교시 | 내용 | 시간 |
|------|------|------|------|
| 13:45-15:15 | 3교시 | 클라우드 컨테이너 서비스 | 90분 |
| 15:30-17:00 | 4교시 | 통합 모니터링 허브 | 90분 |
| 17:00-17:30 | 정리 | 실습 정리 | 30분 |

---

## 🛠️ 실습 학습

### 🚀 **4교시 VM 환경 준비 완료**

#### **✅ 배포된 VM 정보**

**AWS EC2 인스턴스**
- **인스턴스 ID**: `i-09108c566c2abb37d`
- **퍼블릭 IP**: `43.200.178.26`
- **Elastic IP**: `3.37.234.110`
- **프라이빗 IP**: `172.31.47.27`
- **보안 그룹**: `sg-0c896c06c788efd8d`
- **키 페어**: `cloud-deployment-key.pem`

**GCP Compute Engine 인스턴스**
- **인스턴스명**: `cloud-intermediate-vm`
- **외부 IP**: `34.158.217.114`
- **내부 IP**: `10.178.0.22`
- **존**: `asia-northeast3-a`
- **머신 타입**: `e2-medium`

#### **🔗 VM 연결 명령어**

**AWS EKS 클러스터 연결**
```bash
# EKS 클러스터 생성 및 연결
./aws-eks-helper.sh --action cluster-create
./aws-eks-helper.sh --action kubeconfig-update
kubectl get nodes
```

**GCP GKE 클러스터 연결**
```bash
# GKE 클러스터 생성 및 연결
gcloud container clusters create cloud-intermediate-gke --zone=asia-northeast3-a
gcloud container clusters get-credentials cloud-intermediate-gke --zone=asia-northeast3-a
kubectl get nodes
```

### 🎉 **4교시 통합 모니터링 허브 구축 완료**

#### **✅ 구축된 모니터링 환경**

**🔧 설치된 모니터링 도구**
- **EKS 클러스터**: `eks-intermediate` ✅ 정상 동작
- **Kubernetes 대시보드**: 클러스터 내부 접근 ✅ 정상 동작  
- **클러스터 모니터링**: kubectl 명령어로 확인 ✅ 정상 동작

**📊 EKS 클러스터 모니터링 기능**

**1. EKS 클러스터 상태 확인**
- **명령어**: `kubectl get nodes`
- **기능**: 클러스터 노드 상태 및 리소스 확인
- **상태**: 정상 동작 확인됨

**2. 파드 및 서비스 모니터링**
- **명령어**: `kubectl get pods --all-namespaces`
- **기능**: 모든 네임스페이스의 파드 상태 확인
- **상태**: 정상 동작 확인됨

**3. 클러스터 자동 스케일링 확인**
- **명령어**: `kubectl get hpa --all-namespaces`
- **기능**: 수평적 파드 자동 스케일링 상태 확인

#### **🔗 EKS 클러스터 접속**

```bash
# EKS 클러스터 상태 확인
aws eks describe-cluster --name eks-intermediate --region ap-northeast-2

# 클러스터 노드 확인
kubectl get nodes

# 파드 상태 확인
kubectl get pods --all-namespaces

# 클러스터 자동 스케일링 확인
kubectl get hpa --all-namespaces
```

#### **📋 다음 단계**

**1. Grafana 설정**
- Prometheus를 데이터 소스로 추가
- Node Exporter 메트릭을 위한 대시보드 생성
- 알림 규칙 설정

**2. 모니터링 대시보드 구성**
- 시스템 리소스 모니터링
- 애플리케이션 성능 모니터링
- 알림 및 경고 설정

**3. 통합 모니터링 설정**
- Prometheus에서 Node Exporter 타겟 추가
- Grafana에서 Prometheus 데이터 소스 연결
- 커스텀 대시보드 생성

### 📁 실습 코드 및 자동화 (개선된 경로 구조)

#### **🎯 실습 디렉토리 구조**
```
mcp_knowledge_base/cloud_intermediate/
├── 📚 lectures/day1/                    # 강의안
├── 🛠️ repo/practice/day1/              # 실습 코드
│   ├── cloud-container-services/       # 클라우드 컨테이너 서비스
│   └── monitoring-hub/                 # 통합 모니터링 허브
├── 🤖 repo/automation/day1/            # 자동화 스크립트
└── 🛠️ repo/tools/cloud/               # 공통 도구 및 설정
```

#### **📋 실습별 정확한 경로**

**1. 클라우드 컨테이너 서비스**
- **실습 위치**: `repo/practice/day1/cloud-container-services/`
- **AWS ECS**: `./aws-ecs-helper.sh`
- **GCP Cloud Run**: `./gcp-cloudrun-helper.sh`
- **환경 파일**: `repo/tools/cloud/`에서 자동 복사

**2. 통합 모니터링 허브**
- **실습 위치**: `repo/practice/day1/monitoring-hub/`
- **실행 스크립트**: `./monitoring-hub-helper.sh`
- **설정 파일**: `repo/tools/cloud/`에서 자동 복사

### 📋 실습 진행 체크리스트
- [ ] **환경 설정**: 필수 도구 설치 및 설정 완료
  - [ ] AWS CLI 설정 및 인증 확인
  - [ ] GCP CLI 설정 및 인증 확인
  - [ ] Docker 설치 및 실행 확인
- [ ] **클라우드 컨테이너 서비스**: AWS ECS, GCP Cloud Run 배포 완료
  - [ ] `cd repo/practice/day1/cloud-container-services/` 디렉토리로 이동
  - [ ] 환경 파일 복사: `cp ../../../tools/cloud/*-environment.env ./ && cp ../../../tools/cloud/aws-ecs-helper.sh ./ && cp ../../../tools/cloud/gcp-cloudrun-helper.sh ./`
  - [ ] 환경 파일 확인: `ls -la *-environment.env aws-ecs-helper.sh gcp-cloudrun-helper.sh`
  - [ ] **환경 변수 설정**: 각 실습 시작 전 0단계 환경 변수 설정 및 확인
  - [ ] **AWS ECS 배포**: 수작업 실습 가이드 0-10단계 진행
  - [ ] **GCP Cloud Run 배포**: 수작업 실습 가이드 0-13단계 진행
  - [ ] 외부 접속 테스트 완료
- [ ] **통합 모니터링 허브**: Prometheus + Grafana 구축 완료
  - [ ] `cd repo/practice/day1/monitoring-hub/` 디렉토리로 이동
  - [ ] 환경 파일 복사: `cp ../../../tools/cloud/monitoring-hub-helper.sh ./ && cp ../../../tools/cloud/*-environment.env ./`
  - [ ] 환경 파일 확인: `ls -la monitoring-hub-helper.sh *-environment.env`
  - [ ] **모니터링 허브 구축**: `./monitoring-hub-helper.sh --action create-hub`
  - [ ] **Prometheus 설정**: `./monitoring-hub-helper.sh --action install-prometheus`
  - [ ] **Grafana 설정**: `./monitoring-hub-helper.sh --action install-grafana`
  - [ ] 모니터링 데이터 수집 확인

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **AWS CLI**: AWS 서비스 관리 도구
- **GCP CLI**: GCP 서비스 관리 도구
- **Docker**: 컨테이너 런타임 환경

#### 환경 설정
```bash
# AWS CLI 설정 확인
aws sts get-caller-identity

# GCP CLI 설정 확인
gcloud auth list

# Docker 설치 확인
docker --version
```

#### AWS ECS 사전 설정 (문제 방지)
```bash
# 사용자 IAM 정책 확인
aws iam list-attached-user-policies --user-name $(aws sts get-caller-identity --query User --output text | cut -d'/' -f2)

# ECS 관련 정책 추가 (없는 경우)
aws iam attach-user-policy \
    --user-name $(aws sts get-caller-identity --query User --output text | cut -d'/' -f2) \
    --policy-arn arn:aws:iam::aws:policy/AmazonECS_FullAccess

# IAM 역할 생성 권한 추가 (필요시)
aws iam attach-user-policy \
    --user-name $(aws sts get-caller-identity --query User --output text | cut -d'/' -f2) \
    --policy-arn arn:aws:iam::aws:policy/IAMFullAccess

# ECS Task Execution Role 생성 (사전 생성)
aws iam create-role \
    --role-name ecsTaskExecutionRole \
    --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "ecs-tasks.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }' 2>/dev/null || echo "IAM 역할이 이미 존재합니다."

# ECS Task Execution Role에 정책 연결
aws iam attach-role-policy \
    --role-name ecsTaskExecutionRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

# IAM 역할 생성 확인
aws iam get-role --role-name ecsTaskExecutionRole
```

#### 실습 환경 체크
```bash
# 📍 실습 환경 자동 체크
cd mcp_knowledge_base/cloud_intermediate/
./tools/cloud/environment-check.sh

# 📍 환경 설정 자동화
./tools/cloud/setup-environment.sh

# 📍 개별 실습 모듈 및 환경 파일 확인
ls -la repo/practice/day1/
# cloud-container-services/, monitoring-hub/ 등 확인

# 📍 중앙 집중식 환경 파일 확인
echo "=== 중앙 집중식 환경 파일 (tools/cloud/) ==="
ls -la tools/cloud/*-environment.env tools/cloud/*-helper.sh 2>/dev/null || echo "환경 파일이 없습니다"

# 📍 환경 파일 복사 및 확인
echo "=== 클라우드 컨테이너 서비스 실습 환경 파일 복사 ==="
cd repo/practice/day1/cloud-container-services/
cp ../../../tools/cloud/*-environment.env ./
cp ../../../tools/cloud/aws-ecs-helper.sh ./
cp ../../../tools/cloud/gcp-cloudrun-helper.sh ./
ls -la *-environment.env aws-ecs-helper.sh gcp-cloudrun-helper.sh

echo "=== 통합 모니터링 허브 실습 환경 파일 복사 ==="
cd ../monitoring-hub/
cp ../../../tools/cloud/*-environment.env ./
cp ../../../tools/cloud/monitoring-hub-helper.sh ./
ls -la *-environment.env monitoring-hub-helper.sh
```

</details>

---

## 🕘 3교시: 클라우드 컨테이너 서비스 (13:45-15:15)

### 📚 강의 내용 (30분)

#### 클라우드 컨테이너 서비스 개요
```mermaid
flowchart TD
    subgraph "클라우드 컨테이너 서비스"
        A["AWS ECS"] --> B["Fargate 서버리스"]
        C["GCP Cloud Run"] --> D["서버리스 컨테이너"]
        E["Azure Container Instances"] --> F["관리형 컨테이너"]
    end
    
    subgraph "서비스 특징"
        G["자동 스케일링"] --> H["로드 밸런싱"]
        H --> I["보안 관리"]
        I --> J["모니터링 통합"]
    end
    
    A --> G
    C --> G
    E --> G
    
    style A fill:#ff6f00,color:#ffffff
    style B fill:#ff6f00,color:#ffffff
    style C fill:#1976d2,color:#ffffff
    style D fill:#1976d2,color:#ffffff
    style E fill:#4caf50,color:#ffffff
    style F fill:#4caf50,color:#ffffff
    style G fill:#4caf50,color:#ffffff
    style H fill:#4caf50,color:#ffffff
    style I fill:#4caf50,color:#ffffff
    style J fill:#4caf50,color:#ffffff
```

#### 컨테이너 서비스 비교 분석

**🔄 EKS vs ECS vs Cloud Run vs GKE 비교**

| 구분 | **AWS EKS** | **AWS ECS** | **GCP GKE** | **GCP Cloud Run** |
|------|-------------|-------------|-------------|-------------------|
| **서비스 유형** | 관리형 Kubernetes | AWS 네이티브 오케스트레이션 | 관리형 Kubernetes | 서버리스 컨테이너 |
| **복잡도** | 높음 (Kubernetes 지식 필요) | 중간 (AWS 특화) | 높음 (Kubernetes 지식 필요) | 낮음 (서버리스) |
| **관리 부담** | 중간 (노드 관리 필요) | 낮음 (Fargate 사용 시) | 중간 (노드 관리 필요) | 없음 (완전 서버리스) |
| **스케일링** | 수동/자동 설정 | 자동 (Fargate) | 수동/자동 설정 | 자동 (0에서 무한대) |
| **비용 모델** | 노드 + 리소스 사용량 | 태스크 기반 | 노드 + 리소스 사용량 | 요청 기반 |
| **학습 곡선** | 가파름 | 완만함 | 가파름 | 완만함 |
| **사용 사례** | 복잡한 마이크로서비스 | 중간 규모 애플리케이션 | 복잡한 마이크로서비스 | 간단한 웹 서비스 |

**🎯 실습에서 배울 서비스 선택 이유**

```mermaid
flowchart TD
    subgraph "실습 서비스 선택 기준"
        A["ECS 선택 이유"] --> B["AWS 네이티브 서비스"]
        B --> C["Fargate 서버리스"]
        C --> D["관리 부담 최소화"]
        
        E["Cloud Run 선택 이유"] --> F["완전 서버리스"]
        F --> G["자동 스케일링"]
        G --> H["비용 최적화"]
    end
    
    subgraph "vs 오케스트레이션 서비스"
        I["EKS/GKE"] --> J["복잡한 설정"]
        J --> K["노드 관리 필요"]
        K --> L["높은 학습 곡선"]
    end
    
    D --> M["실습 목표 달성"]
    H --> M
    L --> N["고급 과정에서 학습"]
    
    style A fill:#ff6f00,color:#ffffff
    style E fill:#1976d2,color:#ffffff
    style I fill:#9c27b0,color:#ffffff
    style M fill:#4caf50,color:#ffffff
    style N fill:#f57c00,color:#ffffff
```

**📊 서비스별 특징 비교**

| 특징 | **ECS (Fargate)** | **Cloud Run** | **EKS** | **GKE** |
|------|-------------------|---------------|---------|---------|
| **시작 시간** | 30-60초 | 1-3초 | 2-5분 | 2-5분 |
| **최소 리소스** | 0.25 vCPU, 0.5GB | 0.1 vCPU, 0.1GB | 1 vCPU, 1GB | 1 vCPU, 1GB |
| **최대 인스턴스** | 10,000 | 무제한 | 클러스터 크기에 따라 | 클러스터 크기에 따라 |
| **네트워킹** | VPC 통합 | 자동 관리 | 복잡한 설정 | 복잡한 설정 |
| **모니터링** | CloudWatch 통합 | 자동 메트릭 | 수동 설정 | 수동 설정 |

#### 핵심 개념
- **AWS ECS**: 컨테이너 오케스트레이션 서비스
- **GCP Cloud Run**: 서버리스 컨테이너 플랫폼
- **클라우드 네이티브**: 클라우드 환경에 최적화된 배포 전략

### 🛠️ 실습 진행 (60분)

> **💡 실습 방법**: 아래의 수작업 실습 가이드를 따라 단계별로 진행하세요. 각 단계는 상세한 명령어와 설명을 포함하고 있어 원활한 학습이 가능합니다.
> 
> **🤖 자동화 옵션**: 수동 가이드와 동일한 결과를 보장하는 자동화 스크립트도 제공됩니다.

#### 🚀 **자동화 스크립트 사용법**

**GCP Cloud Run 자동화**
```bash
# 1. 서비스 배포
./gcp-cloudrun-helper.sh --action deploy-service

# 2. 상태 확인
./gcp-cloudrun-helper.sh --action status

# 3. 트래픽 관리
./gcp-cloudrun-helper.sh --action manage-traffic
```

**AWS ECS 자동화**
```bash
# 1. 클러스터 생성
./aws-ecs-helper.sh --action cluster-create

# 2. 태스크 정의 생성
./aws-ecs-helper.sh --action task-definition

# 3. 서비스 생성
./aws-ecs-helper.sh --action service-create
```

**통합 실행**
```bash
# 전체 클라우드 컨테이너 서비스 실습
./day1-practice.sh --action cloud-services
```

#### 실습 1: AWS ECS 배포 (30분)

**🔄 EKS vs ECS 실습 비교**

| 구분 | **EKS (오전 실습)** | **ECS (오후 실습)** |
|------|---------------------|---------------------|
| **복잡도** | 높음 (Kubernetes YAML) | 중간 (AWS CLI/콘솔) |
| **설정 파일** | 복잡한 YAML 매니페스트 | 간단한 JSON 태스크 정의 |
| **네트워킹** | Service, Ingress 설정 | VPC, 보안 그룹 설정 |
| **스케일링** | HPA, VPA 설정 | Auto Scaling 설정 |
| **학습 목표** | Kubernetes 마스터 | AWS 네이티브 서비스 |

**변경 전 시스템 아키텍처**:
```mermaid
flowchart TD
    subgraph "기존 컨테이너 배포"
        A["로컬 Docker"] --> B["수동 배포"]
        B --> C["수동 스케일링"]
        C --> D["로드 밸런서 없음"]
        D --> E["관리 복잡성"]
    end
    
    style A fill:#1976d2,color:#ffffff
    style B fill:#388e3c,color:#ffffff
    style C fill:#f57c00,color:#ffffff
    style D fill:#d32f2f,color:#ffffff
    style E fill:#9c27b0,color:#ffffff
```

**🔧 실행 전 AWS 환경 확인**:
```bash
# AWS CLI 설정 확인
aws sts get-caller-identity
# 예상 결과: AWS 계정 정보 출력

# ECS 클러스터 목록 확인
aws ecs list-clusters
# 예상 결과: 기존 클러스터 목록 (없을 수도 있음)

# VPC 및 서브넷 확인
aws ec2 describe-vpcs --query 'Vpcs[?IsDefault==`true`]'
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-xxxxx"
# 예상 결과: 기본 VPC 및 서브넷 정보

# 보안 그룹 확인
aws ec2 describe-security-groups --filters "Name=group-name,Values=default"
# 예상 결과: 기본 보안 그룹 정보
```

**변경 후 시스템 아키텍처**:
```mermaid
flowchart TD
    subgraph "AWS ECS 아키텍처"
        A["ECS 클러스터"] --> B["Task Definition"]
        B --> C["ECS Service"]
        C --> D["Application Load Balancer"]
        D --> E["Auto Scaling"]
    end
    
    subgraph "Fargate 서버리스"
        F["컨테이너 실행"] --> G["자동 스케일링"]
        G --> H["관리형 인프라"]
    end
    
    E --> F
    
    style A fill:#ff6f00,color:#ffffff
    style B fill:#ff6f00,color:#ffffff
    style C fill:#ff6f00,color:#ffffff
    style D fill:#ff6f00,color:#ffffff
    style E fill:#ff6f00,color:#ffffff
    style F fill:#4caf50,color:#ffffff
    style G fill:#4caf50,color:#ffffff
    style H fill:#4caf50,color:#ffffff
```

**📊 실행 후 AWS ECS 변화 확인**:
```bash
# ECS 클러스터 생성 확인
aws ecs describe-clusters --clusters my-cluster
# 예상 결과: 클러스터 상태 ACTIVE

# ECS 서비스 상태 확인
aws ecs describe-services --cluster my-cluster --services my-service
# 예상 결과: 서비스 상태 ACTIVE, 실행 중인 태스크 수

# ALB DNS 이름 확인
aws elbv2 describe-load-balancers --names my-alb --query 'LoadBalancers[0].DNSName' --output text
# 예상 결과: my-alb-1234567890.us-west-2.elb.amazonaws.com

# 태스크 실행 상태 확인
aws ecs list-tasks --cluster my-cluster --service-name my-service
# 예상 결과: 실행 중인 태스크 ARN 목록
```

**🌐 웹브라우저 접속 가이드**:
1. **ALB DNS 이름 확인**:
   ```bash
   ALB_DNS=$(aws elbv2 describe-load-balancers --names my-alb --query 'LoadBalancers[0].DNSName' --output text)
   echo "ALB 접속 주소: http://$ALB_DNS"
   ```

2. **애플리케이션 접속 테스트**:
   - 접속 URL: `http://[ALB-DNS-NAME]`
   - 예상 화면: "Hello from ECS Fargate!"
   - 응답 시간: 약 100-200ms

3. **AWS 콘솔에서 확인**:
   - ECS 콘솔: https://console.aws.amazon.com/ecs/
   - 클러스터: my-cluster
   - 서비스: my-service
   - 태스크: 실행 중인 컨테이너 확인

#### 수작업 실습 가이드 (AWS ECS 배포)

**1단계: AWS CLI 설정 및 IAM 사전 설정**
```bash
# AWS CLI 설정 확인
aws configure list
aws sts get-caller-identity

# 사용자 IAM 정책 확인
aws iam list-attached-user-policies --user-name $(aws sts get-caller-identity --query User --output text | cut -d'/' -f2)

# ECS 관련 정책 추가 (없는 경우)
aws iam attach-user-policy \
    --user-name $(aws sts get-caller-identity --query User --output text | cut -d'/' -f2) \
    --policy-arn arn:aws:iam::aws:policy/AmazonECS_FullAccess

# IAM 역할 생성 권한 추가 (필요시)
aws iam attach-user-policy \
    --user-name $(aws sts get-caller-identity --query User --output text | cut -d'/' -f2) \
    --policy-arn arn:aws:iam::aws:policy/IAMFullAccess

# ECS Task Execution Role 생성 (사전 생성)
aws iam create-role \
    --role-name ecsTaskExecutionRole \
    --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "ecs-tasks.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }' 2>/dev/null || echo "IAM 역할이 이미 존재합니다."

# ECS Task Execution Role에 정책 연결
aws iam attach-role-policy \
    --role-name ecsTaskExecutionRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

# IAM 역할 생성 확인
aws iam get-role --role-name ecsTaskExecutionRole
```

**0단계: 환경 변수 설정**
```bash
# 환경 변수 설정 (실습 효율성을 위해)
export CLUSTER_NAME="ecs-intermediate"
export SERVICE_NAME="cloud-intermediate-service"
export TASK_FAMILY="nginx-task"
export LOG_GROUP="/ecs/cloud-intermediate-app"
export ALB_NAME="cloud-intermediate-alb"
export TG_NAME="cloud-intermediate-tg"
export SECURITY_GROUP="ecs-security-group"

# 환경 변수 설정 확인 (중요!)
echo "=== 환경 변수 확인 ==="
echo "클러스터: $CLUSTER_NAME"
echo "서비스: $SERVICE_NAME"
echo "태스크 패밀리: $TASK_FAMILY"
echo "로그 그룹: $LOG_GROUP"
echo "ALB 이름: $ALB_NAME"
echo "타겟 그룹: $TG_NAME"
echo "보안 그룹: $SECURITY_GROUP"

# 변수가 비어있으면 오류 발생
if [ -z "$CLUSTER_NAME" ] || [ -z "$SERVICE_NAME" ] || [ -z "$TASK_FAMILY" ] || [ -z "$LOG_GROUP" ]; then
    echo "❌ 환경 변수가 설정되지 않았습니다. 0단계를 다시 실행하세요."
    exit 1
fi
echo "✅ 모든 환경 변수가 설정되었습니다."
```

**1단계: ECS 클러스터 생성**
```bash
# ECS 클러스터 생성
aws ecs create-cluster \
    --cluster-name $CLUSTER_NAME \
    --capacity-providers FARGATE \
    --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1

# 클러스터 상태 확인
aws ecs describe-clusters --clusters $CLUSTER_NAME
```

**2단계: CloudWatch Log Group 생성**
```bash
# CloudWatch Log Group 생성
aws logs create-log-group \
    --log-group-name $LOG_GROUP

# Log Group 정책 설정
aws logs put-retention-policy \
    --log-group-name $LOG_GROUP \
    --retention-in-days 7
```

**3단계: VPC 및 네트워크 설정**
```bash
# 기본 VPC 정보 확인
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=is-default,Values=true" --query 'Vpcs[0].VpcId' --output text)
echo "VPC ID: $VPC_ID"

# 서브넷 정보 확인
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID"

# 보안 그룹 생성
SECURITY_GROUP_ID=$(aws ec2 create-security-group \
    --group-name $SECURITY_GROUP \
    --description "Security group for ECS tasks" \
    --vpc-id $VPC_ID \
    --query 'GroupId' --output text)
echo "보안 그룹 ID: $SECURITY_GROUP_ID"

# 보안 그룹 규칙 추가 (HTTP)
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

# 보안 그룹 규칙 추가 (HTTPS)
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0
```

**4단계: Task Definition 생성**
```bash
# Account ID 가져오기
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "Account ID: $ACCOUNT_ID"

# Task Definition JSON 파일 생성
cat > task-definition.json << EOF
{
  "family": "$TASK_FAMILY",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::$ACCOUNT_ID:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "nginx",
      "image": "nginx:1.21",
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "$LOG_GROUP",
          "awslogs-region": "ap-northeast-2",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": [
          "CMD-SHELL",
          "curl -f http://localhost:80 || exit 1"
        ],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      }
    }
  ]
}
EOF

# Task Definition 등록
aws ecs register-task-definition --cli-input-json file://task-definition.json

# Task Definition 확인
aws ecs describe-task-definition --task-definition $TASK_FAMILY
```

**5단계: Application Load Balancer 생성**
```bash
# 서브넷 정보 가져오기
SUBNET_IDS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[].SubnetId' --output text)
echo "서브넷 IDs: $SUBNET_IDS"

# ALB 생성
aws elbv2 create-load-balancer \
    --name $ALB_NAME \
    --subnets $SUBNET_IDS \
    --security-groups $SECURITY_GROUP_ID \
    --scheme internet-facing \
    --type application \
    --ip-address-type ipv4

# ALB ARN 저장
ALB_ARN=$(aws elbv2 describe-load-balancers --names $ALB_NAME --query 'LoadBalancers[0].LoadBalancerArn' --output text)
echo "ALB ARN: $ALB_ARN"

# Target Group 생성
aws elbv2 create-target-group \
    --name $TG_NAME \
    --protocol HTTP \
    --port 80 \
    --vpc-id $VPC_ID \
    --target-type ip \
    --health-check-path / \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 5 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3

# Target Group ARN 저장
TG_ARN=$(aws elbv2 describe-target-groups --names $TG_NAME --query 'TargetGroups[0].TargetGroupArn' --output text)
echo "Target Group ARN: $TG_ARN"

# Listener 생성
aws elbv2 create-listener \
    --load-balancer-arn $ALB_ARN \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$TG_ARN
```

**6단계: ECS 서비스 생성**
```bash
# ECS 서비스 생성
aws ecs create-service \
    --cluster $CLUSTER_NAME \
    --service-name $SERVICE_NAME \
    --task-definition $TASK_FAMILY:1 \
    --desired-count 2 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNET_IDS],securityGroups=[$SECURITY_GROUP_ID],assignPublicIp=ENABLED}" \
    --load-balancers "targetGroupArn=$TG_ARN,containerName=nginx,containerPort=80"

# 서비스 상태 확인
aws ecs describe-services \
    --cluster $CLUSTER_NAME \
    --services $SERVICE_NAME
```

**7단계: Auto Scaling 설정**
```bash
# Auto Scaling Target 생성
aws application-autoscaling register-scalable-target \
    --service-namespace ecs \
    --resource-id service/$CLUSTER_NAME/$SERVICE_NAME \
    --scalable-dimension ecs:service:DesiredCount \
    --min-capacity 1 \
    --max-capacity 10

# Auto Scaling Policy 생성 (CPU 기반)
aws application-autoscaling put-scaling-policy \
    --service-namespace ecs \
    --resource-id service/$CLUSTER_NAME/$SERVICE_NAME \
    --scalable-dimension ecs:service:DesiredCount \
    --policy-name cpu-scaling-policy \
    --policy-type TargetTrackingScaling \
    --target-tracking-scaling-policy-configuration '{
        "TargetValue": 70.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ECSServiceAverageCPUUtilization"
        },
        "ScaleOutCooldown": 300,
        "ScaleInCooldown": 300
    }'

# Auto Scaling Policy 생성 (메모리 기반)
aws application-autoscaling put-scaling-policy \
    --service-namespace ecs \
    --resource-id service/$CLUSTER_NAME/$SERVICE_NAME \
    --scalable-dimension ecs:service:DesiredCount \
    --policy-name memory-scaling-policy \
    --policy-type TargetTrackingScaling \
    --target-tracking-scaling-policy-configuration '{
        "TargetValue": 80.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ECSServiceAverageMemoryUtilization"
        },
        "ScaleOutCooldown": 300,
        "ScaleInCooldown": 300
    }'
```

**8단계: 배포 테스트**
```bash
# ALB DNS 이름 확인
ALB_DNS=$(aws elbv2 describe-load-balancers --names $ALB_NAME --query 'LoadBalancers[0].DNSName' --output text)
echo "ALB DNS: $ALB_DNS"

# ALB 접근 테스트
curl -I http://$ALB_DNS

# ECS 태스크 상태 확인
aws ecs list-tasks --cluster $CLUSTER_NAME --service-name $SERVICE_NAME

# CloudWatch 로그 확인
aws logs describe-log-streams --log-group-name $LOG_GROUP

# 로그 내용 확인 (로그 스트림이 있는 경우)
LOG_STREAMS=$(aws logs describe-log-streams --log-group-name $LOG_GROUP --query 'logStreams[].logStreamName' --output text)
if [ -n "$LOG_STREAMS" ]; then
    echo "로그 스트림 발견:"
    for stream in $LOG_STREAMS; do
        echo "  - $stream"
        aws logs get-log-events --log-group-name $LOG_GROUP --log-stream-name $stream --query 'events[].message' --output text
    done
else
    echo "로그 스트림이 없습니다."
fi
```

**9단계: 모니터링 설정**
```bash
# CloudWatch 대시보드 생성
aws cloudwatch put-dashboard \
    --dashboard-name ECS-Monitoring \
    --dashboard-body '{
        "widgets": [
            {
                "type": "metric",
                "x": 0,
                "y": 0,
                "width": 12,
                "height": 6,
                "properties": {
                    "metrics": [
                        ["AWS/ECS", "CPUUtilization", "ServiceName", "$SERVICE_NAME", "ClusterName", "$CLUSTER_NAME"]
                    ],
                    "period": 300,
                    "stat": "Average",
                    "region": "ap-northeast-2",
                    "title": "ECS CPU Utilization"
                }
            },
            {
                "type": "metric",
                "x": 12,
                "y": 0,
                "width": 12,
                "height": 6,
                "properties": {
                    "metrics": [
                        ["AWS/ECS", "MemoryUtilization", "ServiceName", "cloud-intermediate-service", "ClusterName", "ecs-intermediate"]
                    ],
                    "period": 300,
                    "stat": "Average",
                    "region": "ap-northeast-2",
                    "title": "ECS Memory Utilization"
                }
            }
        ]
    }'

# CloudWatch 알람 생성
aws cloudwatch put-metric-alarm \
    --alarm-name "ECS-High-CPU" \
    --alarm-description "Alarm when CPU exceeds 80%" \
    --metric-name CPUUtilization \
    --namespace AWS/ECS \
    --statistic Average \
    --period 300 \
    --threshold 80 \
    --comparison-operator GreaterThanThreshold \
    --dimensions Name=ServiceName,Value=cloud-intermediate-service Name=ClusterName,Value=ecs-intermediate \
    --evaluation-periods 2
```

**10단계: 정리**
```bash
# ECS 서비스 삭제
aws ecs update-service \
    --cluster ecs-intermediate \
    --service cloud-intermediate-service \
    --desired-count 0

aws ecs delete-service \
    --cluster ecs-intermediate \
    --service cloud-intermediate-service

# Task Definition 삭제
aws ecs deregister-task-definition --task-definition cloud-intermediate-app:1

# ALB 및 Target Group 삭제
aws elbv2 delete-load-balancer --load-balancer-arn $ALB_ARN
aws elbv2 delete-target-group --target-group-arn $TG_ARN

# ECS 클러스터 삭제
aws ecs delete-cluster --cluster ecs-intermediate

# IAM 역할 삭제
aws iam detach-role-policy --role-name ecsTaskExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
aws iam delete-role --role-name ecsTaskExecutionRole
aws iam delete-role --role-name ecsTaskRole

# CloudWatch Log Group 삭제
aws logs delete-log-group --log-group-name /ecs/cloud-intermediate-app

# 보안 그룹 삭제
aws ec2 delete-security-group --group-id $(aws ec2 describe-security-groups --filters 'Name=group-name,Values=ecs-security-group' --query 'SecurityGroups[0].GroupId' --output text)
```

#### 실습 2: GCP Cloud Run 배포 (30분)

> **💡 실습 방법**: 아래의 수작업 실습 가이드를 따라 단계별로 진행하세요. Cloud Run은 서버리스 컨테이너 플랫폼으로 간단한 배포가 가능합니다.

**🔄 GKE vs Cloud Run 실습 비교**

| 구분 | **GKE (오전 실습)** | **Cloud Run (오후 실습)** |
|------|---------------------|---------------------------|
| **복잡도** | 높음 (Kubernetes YAML) | 낮음 (gcloud 명령어) |
| **설정 파일** | 복잡한 YAML 매니페스트 | 간단한 Dockerfile |
| **네트워킹** | Service, Ingress 설정 | 자동 관리 |
| **스케일링** | HPA, VPA 설정 | 자동 스케일링 (0→무한대) |
| **학습 목표** | Kubernetes 마스터 | 서버리스 컨테이너 |

**변경 전 시스템 아키텍처**:
```mermaid
flowchart TD
    subgraph "기존 서버리스 배포"
        A["수동 배포"] --> B["서버 관리 필요"]
        B --> C["스케일링 설정 어려움"]
        C --> D["비용 최적화 어려움"]
    end
    
    style A fill:#1976d2,color:#ffffff
    style B fill:#388e3c,color:#ffffff
    style C fill:#f57c00,color:#ffffff
    style D fill:#d32f2f,color:#ffffff
```


**변경 후 시스템 아키텍처**:
```mermaid
flowchart TD
    subgraph "GCP Cloud Run 아키텍처"
        A["Container Image"] --> B["Cloud Run Service"]
        B --> C["Auto Scaling"]
        C --> D["Traffic Management"]
        D --> E["Security Settings"]
    end
    
    subgraph "서버리스 이점"
        F["Zero Server Management"] --> G["Pay per Use"]
        G --> H["Automatic Scaling"]
        H --> I["Global Distribution"]
    end
    
    E --> F
    
    style A fill:#1976d2,color:#ffffff
    style B fill:#1976d2,color:#ffffff
    style C fill:#1976d2,color:#ffffff
    style D fill:#1976d2,color:#ffffff
    style E fill:#1976d2,color:#ffffff
    style F fill:#4caf50,color:#ffffff
    style G fill:#4caf50,color:#ffffff
    style H fill:#4caf50,color:#ffffff
    style I fill:#4caf50,color:#ffffff
```


#### 수작업 실습 가이드 (GCP Cloud Run 배포)

**0단계: 환경 변수 설정**
```bash
# 환경 변수 설정 (실습 효율성을 위해)
export PROJECT_ID=$(gcloud config get-value project)
export REGION="asia-northeast3"
export SERVICE_NAME="cloud-run-demo"
export IMAGE_NAME="gcr.io/$PROJECT_ID/cloud-run-demo:latest"

# 환경 변수 설정 확인 (중요!)
echo "=== 환경 변수 확인 ==="
echo "프로젝트 ID: $PROJECT_ID"
echo "리전: $REGION"
echo "서비스명: $SERVICE_NAME"
echo "이미지명: $IMAGE_NAME"

# 변수가 비어있으면 오류 발생
if [ -z "$SERVICE_NAME" ] || [ -z "$REGION" ] || [ -z "$IMAGE_NAME" ] || [ -z "$PROJECT_ID" ]; then
    echo "❌ 환경 변수가 설정되지 않았습니다. 0단계를 다시 실행하세요."
    exit 1
fi
echo "✅ 모든 환경 변수가 설정되었습니다."
```

**1단계: Docker 이미지 빌드 및 푸시**
```bash
# Cloud Build를 사용한 이미지 빌드 및 푸시
gcloud builds submit --tag $IMAGE_NAME .

# 빌드 완료 확인
echo "✅ 이미지 빌드 및 푸시 완료: $IMAGE_NAME"
```

**2단계: Cloud Run 서비스 배포**
```bash
# Cloud Run 서비스 배포
gcloud run deploy $SERVICE_NAME \
  --image $IMAGE_NAME \
  --region $REGION \
  --platform managed \
  --allow-unauthenticated \
  --port 8080

# 배포 완료 확인
echo "✅ Cloud Run 서비스 배포 완료"
```

**3단계: 서비스 상태 확인**
```bash
# 서비스 정보 확인
gcloud run services describe $SERVICE_NAME \
  --region $REGION \
  --format="table(metadata.name,status.url,status.conditions[0].status,spec.template.spec.containers[0].image)"

# 서비스 URL 확인
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region $REGION --format="value(status.url)")
echo "서비스 URL: $SERVICE_URL"
```

**4단계: 서비스 테스트**
```bash
# 서비스 응답 테스트
curl -s $SERVICE_URL | jq '.'

# 여러 번 테스트하여 트래픽 분산 확인
for i in {1..3}; do
  echo "요청 $i:"
  curl -s $SERVICE_URL | jq -r '.timestamp'
  sleep 1
done
```

**5단계: 트래픽 관리 (리비전 관리)**
```bash
# 현재 리비전 목록 확인
gcloud run revisions list \
  --service $SERVICE_NAME \
  --region $REGION \
  --format="table(metadata.name,status.conditions[0].status,spec.containers[0].image)"

# 최신 리비전과 이전 리비전 확인
LATEST_REVISION=$(gcloud run revisions list --service $SERVICE_NAME --region $REGION --limit 1 --format="value(metadata.name)")
PREVIOUS_REVISION=$(gcloud run revisions list --service $SERVICE_NAME --region $REGION --limit 2 | tail -1 | awk '{print $1}')

echo "최신 리비전: $LATEST_REVISION"
echo "이전 리비전: $PREVIOUS_REVISION"
```

**6단계: 트래픽 분할 설정**
```bash
# 트래픽을 50:50으로 분할
gcloud run services update-traffic $SERVICE_NAME \
  --region $REGION \
  --to-revisions $LATEST_REVISION=50,$PREVIOUS_REVISION=50

# 트래픽 분할 확인
echo "✅ 트래픽 분할 설정 완료: 50% 최신, 50% 이전"
```

**7단계: 로그 확인**
```bash
# Cloud Run 로그 확인
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=$SERVICE_NAME" \
  --limit 5 \
  --format="table(timestamp,severity,textPayload)"

echo "✅ 로그 확인 완료"
```

**8단계: 정리 및 확인**
```bash
# 서비스 상태 최종 확인
gcloud run services describe $SERVICE_NAME --region $REGION --format="table(metadata.name,status.url,status.conditions[0].status)"

# 트래픽 분할 상태 확인
gcloud run services describe $SERVICE_NAME --region $REGION --format="table(spec.traffic[].revisionName,spec.traffic[].percent)"

echo "✅ GCP Cloud Run 실습 완료!"
echo "서비스 URL: $(gcloud run services describe $SERVICE_NAME --region $REGION --format='value(status.url)')"
```

### 🧹 **실습 정리**

**Cloud Run 서비스 삭제**
```bash
# Cloud Run 서비스 삭제
gcloud run services delete $SERVICE_NAME --region $REGION --quiet

# Container Registry 이미지 삭제
gcloud container images delete $IMAGE_NAME --quiet

echo "✅ GCP Cloud Run 실습 정리 완료"
```

## 🚨 문제 해결 가이드

### **환경 변수 관련 오류**
```bash
# 오류: argument --region: expected one argument
# 해결: 환경 변수 재설정
export PROJECT_ID=$(gcloud config get-value project)
export REGION="asia-northeast3"
export SERVICE_NAME="cloud-run-demo"
export IMAGE_NAME="gcr.io/$PROJECT_ID/cloud-run-demo:latest"
```

### **GCP Cloud Run 트래픽 관리 오류**
```bash
# 오류: Revision does not exist
# 해결: 실제 리비전 이름 확인 후 사용
LATEST_REVISION=$(gcloud run revisions list --service $SERVICE_NAME --region $REGION --limit 1 --format="value(metadata.name)")
PREVIOUS_REVISION=$(gcloud run revisions list --service $SERVICE_NAME --region $REGION --limit 2 | tail -1 | awk '{print $1}')

gcloud run services update-traffic $SERVICE_NAME \
  --region $REGION \
  --to-revisions $LATEST_REVISION=50,$PREVIOUS_REVISION=50
```

### 📊 실습 결과

#### **수동 실습 완료 체크리스트**
- [ ] AWS ECS 컨테이너 서비스 배포 완료
- [ ] GCP Cloud Run 서버리스 배포 완료
- [ ] 자동 스케일링 설정 완료
- [ ] 로드 밸런서 연결 완료

#### **🤖 자동화 스크립트 검증**
```bash
# AWS ECS 상태 확인
./aws-ecs-helper.sh --action status

# GCP Cloud Run 상태 확인
./gcp-cloudrun-helper.sh --action status

# 통합 상태 확인
./day1-practice.sh --action status
```

#### **✅ 성공 지표**
- **AWS ECS**: 클러스터 활성, 서비스 실행 중, 태스크 정상 동작
- **GCP Cloud Run**: 서비스 배포 완료, 트래픽 분할 설정, 로그 수집 정상
- **자동화 스크립트**: 수동 가이드와 동일한 결과 보장


### 🔄 전체 서비스 비교 요약

**📈 학습 곡선 및 복잡도 비교**

```mermaid
flowchart TD
    subgraph "학습 난이도"
        A["Cloud Run<br/>(가장 쉬움)"] --> B["ECS Fargate<br/>(쉬움)"]
        B --> C["GKE<br/>(어려움)"]
        C --> D["EKS<br/>(가장 어려움)"]
    end
    
    subgraph "관리 부담"
        E["Cloud Run<br/>(없음)"] --> F["ECS Fargate<br/>(낮음)"]
        F --> G["GKE<br/>(중간)"]
        G --> H["EKS<br/>(높음)"]
    end
    
    subgraph "비용 효율성"
        I["Cloud Run<br/>(최고)"] --> J["ECS Fargate<br/>(높음)"]
        J --> K["GKE<br/>(중간)"]
        K --> L["EKS<br/>(낮음)"]
    end
    
    style A fill:#4caf50,color:#ffffff
    style B fill:#8bc34a,color:#ffffff
    style C fill:#ff9800,color:#ffffff
    style D fill:#f44336,color:#ffffff
    style E fill:#4caf50,color:#ffffff
    style F fill:#8bc34a,color:#ffffff
    style G fill:#ff9800,color:#ffffff
    style H fill:#f44336,color:#ffffff
    style I fill:#4caf50,color:#ffffff
    style J fill:#8bc34a,color:#ffffff
    style K fill:#ff9800,color:#ffffff
    style L fill:#f44336,color:#ffffff
```

**🎯 실습을 통한 핵심 학습 포인트**

| 서비스 | **핵심 학습 내용** | **실무 적용 시나리오** |
|--------|-------------------|----------------------|
| **EKS** | Kubernetes 마스터, 복잡한 마이크로서비스 | 대규모 엔터프라이즈 애플리케이션 |
| **ECS** | AWS 네이티브 서비스, Fargate 서버리스 | AWS 생태계 내 컨테이너 서비스 |
| **GKE** | Kubernetes 마스터, GCP 통합 | GCP 생태계 내 복잡한 워크로드 |
| **Cloud Run** | 서버리스 컨테이너, 비용 최적화 | 간단한 웹 서비스, API 서버 |

---

## 🕘 4교시: 통합 모니터링 허브 (15:30-17:00)

### 📚 강의 내용 (30분)

#### 통합 모니터링 시스템 개요
```mermaid
flowchart TD
    subgraph "통합 모니터링 스택"
        A["Prometheus"] --> B["메트릭 수집"]
        B --> C["Grafana"]
        C --> D["시각화 대시보드"]
        D --> E["AlertManager"]
        E --> F["알림 발송"]
    end
    
    subgraph "모니터링 대상"
        G["애플리케이션"] --> H["인프라"]
        H --> I["클라우드 리소스"]
        I --> J["사용자 경험"]
    end
    
    A --> G
    
    style A fill:#d32f2f,color:#ffffff
    style B fill:#d32f2f,color:#ffffff
    style C fill:#1976d2,color:#ffffff
    style D fill:#1976d2,color:#ffffff
    style E fill:#f57c00,color:#ffffff
    style F fill:#f57c00,color:#ffffff
    style G fill:#4caf50,color:#ffffff
    style H fill:#4caf50,color:#ffffff
    style I fill:#4caf50,color:#ffffff
    style J fill:#4caf50,color:#ffffff
```

#### 핵심 개념
- **Prometheus**: 메트릭 수집 및 저장
- **Grafana**: 데이터 시각화 및 대시보드
- **Node Exporter**: 시스템 메트릭 수집
- **AlertManager**: 알림 관리

### 🛠️ 실습 진행 (60분)

#### 실습 1: 모니터링 허브 인프라 구축 (20분)

**변경 전 시스템 아키텍처**:
```mermaid
flowchart TD
    subgraph "기존 모니터링 환경"
        A["애플리케이션"] --> B["로그 파일"]
        B --> C["수동 모니터링"]
        C --> D["알림 없음"]
        D --> E["문제 발견 지연"]
    end
    
    style A fill:#1976d2,color:#ffffff
    style B fill:#388e3c,color:#ffffff
    style C fill:#f57c00,color:#ffffff
    style D fill:#d32f2f,color:#ffffff
    style E fill:#9c27b0,color:#ffffff
```

**자동화 도구 실행**:
```bash
# 📍 실습 위치: mcp_knowledge_base/cloud_intermediate/repo/practice/day1/monitoring-hub/
cd mcp_knowledge_base/cloud_intermediate/repo/practice/day1/monitoring-hub/

# 📍 VM 생성성
cp ../../../tools/cloud/aws-setup-helper.sh ./
cp ../../../tools/cloud/aws-environment.env ./
cp ../../../tools/cloud/aws-ec2-create ./

# 📍 환경 파일 갱신 (필수)
./aws-setup-helper.sh

# 📍 환경 파일 갱신 (필수)
./ls -la aws-environment.env
./cat aws-environment.env

# 📍 환경 파일 갱신 (필수)
./ls -la aws-environment.env


# 📍 환경 파일 복사 (중앙 집중식 관리)
cp ../../../tools/cloud/monitoring-hub-helper.sh ./
cp ../../../tools/cloud/aws-environment.env ./
cp ../../../tools/cloud/monitoring-environment.env ./

# 📍 환경 파일 확인 (필수)
ls -la monitoring-hub-helper.sh *-environment.env

# 📍 모니터링 허브 인프라 구축 (자동화)
./monitoring-hub-helper.sh --action create-hub

# 📍 Prometheus 설치 및 설정
./monitoring-hub-helper.sh --action install-prometheus

# 📍 Grafana 설치 및 설정
./monitoring-hub-helper.sh --action install-grafana
```

**변경 후 시스템 아키텍처**:
```mermaid
flowchart TD
    subgraph "통합 모니터링 허브"
        A["AWS EC2 인스턴스"] --> B["Prometheus"]
        B --> C["Grafana"]
        C --> D["통합 대시보드"]
    end
    
    subgraph "모니터링 기능"
        E["메트릭 수집"] --> F["알림 관리"]
        F --> G["로그 분석"]
        G --> H["성능 분석"]
        H --> I["자동 스케일링"]
    end
    
    D --> E
    
    style A fill:#ff6f00,color:#ffffff
    style B fill:#d32f2f,color:#ffffff
    style C fill:#1976d2,color:#ffffff
    style D fill:#4caf50,color:#ffffff
    style E fill:#4caf50,color:#ffffff
    style F fill:#4caf50,color:#ffffff
    style G fill:#4caf50,color:#ffffff
    style H fill:#4caf50,color:#ffffff
    style I fill:#4caf50,color:#ffffff
```

**실습 명령어**:
```bash
# AWS EC2 인스턴스 생성 (모니터링 허브)
aws ec2 run-instances \
    --image-id ami-0c02fb55956c7d316 \
    --instance-type t3.medium \
    --key-name my-key \
    --security-group-ids sg-12345 \
    --subnet-id subnet-12345 \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=monitoring-hub}]'

# 인스턴스 상태 확인
aws ec2 describe-instances --filters "Name=tag:Name,Values=monitoring-hub"
```

**실습 내용**:
- AWS EC2 모니터링 허브 인스턴스 생성
- 보안 그룹 설정
- 네트워크 구성

#### 수작업 실습 가이드 (모니터링 허브 인프라 구축)

**1단계: AWS CLI 설정 및 VPC 확인**
```bash
# AWS CLI 설정 확인
aws configure list
aws sts get-caller-identity

# 기본 VPC 정보 확인
aws ec2 describe-vpcs --filters "Name=is-default,Values=true"

# 서브넷 정보 확인
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$(aws ec2 describe-vpcs --filters 'Name=is-default,Values=true' --query 'Vpcs[0].VpcId' --output text)"
```

**2단계: 보안 그룹 생성**
```bash
# 모니터링 허브용 보안 그룹 생성
aws ec2 create-security-group \
    --group-name monitoring-hub-sg \
    --description "Security group for monitoring hub" \
    --vpc-id $(aws ec2 describe-vpcs --filters 'Name=is-default,Values=true' --query 'Vpcs[0].VpcId' --output text)

# 보안 그룹 ID 저장
SG_ID=$(aws ec2 describe-security-groups --filters 'Name=group-name,Values=monitoring-hub-sg' --query 'SecurityGroups[0].GroupId' --output text)

# SSH 접근 허용 (22번 포트)
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

# Prometheus 접근 허용 (9090번 포트)
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 9090 \
    --cidr 0.0.0.0/0

# Grafana 접근 허용 (3000번 포트)
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 3000 \
    --cidr 0.0.0.0/0

# Node Exporter 접근 허용 (9100번 포트)
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 9100 \
    --cidr 0.0.0.0/0

# HTTP 접근 허용 (80번 포트)
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

# HTTPS 접근 허용 (443번 포트)
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0
```

**3단계: Key Pair 생성 (없는 경우)**
```bash
# Key Pair 확인
aws ec2 describe-key-pairs --key-names monitoring-key

# Key Pair가 없으면 생성
if [ $? -ne 0 ]; then
    aws ec2 create-key-pair --key-name monitoring-key --query 'KeyMaterial' --output text > monitoring-key.pem
    chmod 400 monitoring-key.pem
    echo "Key pair created: monitoring-key.pem"
fi
```

**4단계: EC2 인스턴스 생성**
```bash
# 최신 Amazon Linux 2 AMI ID 가져오기
AMI_ID=$(aws ec2 describe-images \
    --owners amazon \
    --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" "Name=state,Values=available" \
    --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
    --output text)

# EC2 인스턴스 생성
aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.medium \
    --key-name monitoring-key \
    --security-group-ids $SG_ID \
    --subnet-id $(aws ec2 describe-subnets --filters 'Name=vpc-id,Values='$(aws ec2 describe-vpcs --filters 'Name=is-default,Values=true' --query 'Vpcs[0].VpcId' --output text) --query 'Subnets[0].SubnetId' --output text) \
    --associate-public-ip-address \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=monitoring-hub},{Key=Environment,Value=production}]'

# 인스턴스 ID 저장
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=monitoring-hub" "Name=instance-state-name,Values=running" --query 'Reservations[0].Instances[0].InstanceId' --output text)

# 인스턴스 상태 확인
aws ec2 describe-instances --instance-ids $INSTANCE_ID

# Public IP 확인
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
echo "Monitoring Hub Public IP: $PUBLIC_IP"
```

**5단계: 인스턴스 접속 및 기본 설정**
```bash
# 인스턴스 접속
ssh -i monitoring-key.pem ec2-user@$PUBLIC_IP

# 인스턴스 내에서 실행할 명령어들
sudo yum update -y
sudo yum install -y wget curl git htop

# Docker 설치
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Docker Compose 설치
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

**6단계: Prometheus 설치 및 설정**
```bash
# Prometheus 사용자 생성
sudo useradd --no-create-home --shell /bin/false prometheus

# Prometheus 디렉토리 생성
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

# Prometheus 다운로드 및 설치
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
tar xzf prometheus-2.45.0.linux-amd64.tar.gz
cd prometheus-2.45.0.linux-amd64

sudo cp prometheus /usr/local/bin/
sudo cp promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

sudo cp -r consoles /etc/prometheus
sudo cp -r console_libraries /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries

# Prometheus 설정 파일 생성
sudo tee /etc/prometheus/prometheus.yml > /dev/null << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'grafana'
    static_configs:
      - targets: ['localhost:3000']
EOF

sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

# Prometheus systemd 서비스 파일 생성
sudo tee /etc/systemd/system/prometheus.service > /dev/null << 'EOF'
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.listen-address=0.0.0.0:9090 \
    --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
EOF

# Prometheus 서비스 시작
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
sudo systemctl status prometheus
```

**7단계: Node Exporter 설치**
```bash
# Node Exporter 다운로드 및 설치
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar xzf node_exporter-1.6.1.linux-amd64.tar.gz
cd node_exporter-1.6.1.linux-amd64

sudo cp node_exporter /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/node_exporter

# Node Exporter systemd 서비스 파일 생성
sudo tee /etc/systemd/system/node_exporter.service > /dev/null << 'EOF'
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Node Exporter 서비스 시작
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
sudo systemctl status node_exporter
```

**8단계: Grafana 설치 및 설정**
```bash
# Grafana 저장소 추가
sudo tee /etc/yum.repos.d/grafana.repo > /dev/null << 'EOF'
[grafana]
name=grafana
baseurl=https://rpm.grafana.com
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF

# Grafana 설치
sudo yum install -y grafana

# Grafana 설정 파일 수정
sudo sed -i 's/;http_port = 3000/http_port = 3000/' /etc/grafana/grafana.ini
sudo sed -i 's/;http_addr =/http_addr = 0.0.0.0/' /etc/grafana/grafana.ini

# Grafana 서비스 시작
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
sudo systemctl status grafana-server

# Grafana 초기 설정
sudo systemctl restart grafana-server
```

**9단계: 서비스 상태 확인**
```bash
# 모든 서비스 상태 확인
sudo systemctl status prometheus node_exporter grafana-server

# 포트 확인
sudo netstat -tlnp | grep -E ':(3000|9090|9100)'

# 서비스 접근 테스트
curl -s http://localhost:9090/api/v1/query?query=up | jq
curl -s http://localhost:3000/api/health

# 방화벽 설정 (필요한 경우)
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --permanent --add-port=9090/tcp
sudo firewall-cmd --permanent --add-port=9100/tcp
sudo firewall-cmd --reload
```

**10단계: Grafana 데이터 소스 설정**
```bash
# Grafana API를 통한 데이터 소스 추가
curl -X POST \
  http://admin:admin@localhost:3000/api/datasources \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://localhost:9090",
    "access": "proxy",
    "isDefault": true
  }'

# 기본 관리자 비밀번호 변경
curl -X PUT \
  http://admin:admin@localhost:3000/api/admin/users/1/password \
  -H 'Content-Type: application/json' \
  -d '{
    "oldPassword": "admin",
    "newPassword": "admin123",
    "confirmNew": "admin123"
  }'
```

**11단계: 모니터링 대시보드 생성**
```bash
# Node Exporter 대시보드 가져오기
DASHBOARD_ID=1860
curl -X POST \
  http://admin:admin123@localhost:3000/api/dashboards/db \
  -H 'Content-Type: application/json' \
  -d "{
    \"dashboard\": $(curl -s https://grafana.com/api/dashboards/$DASHBOARD_ID/revisions/1/download | jq '.dashboard'),
    \"overwrite\": true
  }"

# Prometheus Stats 대시보드 가져오기
DASHBOARD_ID=2
curl -X POST \
  http://admin:admin123@localhost:3000/api/dashboards/db \
  -H 'Content-Type: application/json' \
  -d "{
    \"dashboard\": $(curl -s https://grafana.com/api/dashboards/$DASHBOARD_ID/revisions/1/download | jq '.dashboard'),
    \"overwrite\": true
  }"
```

**12단계: 외부 접근 테스트**
```bash
# 인스턴스에서 나가기
exit

# 로컬에서 외부 접근 테스트
echo "Prometheus: http://$PUBLIC_IP:9090"
echo "Grafana: http://$PUBLIC_IP:3000 (admin/admin123)"
echo "Node Exporter: http://$PUBLIC_IP:9100"

# 접근 테스트
curl -I http://$PUBLIC_IP:9090
curl -I http://$PUBLIC_IP:3000
curl -I http://$PUBLIC_IP:9100
```

**13단계: 정리**
```bash
# EC2 인스턴스 종료
aws ec2 terminate-instances --instance-ids $INSTANCE_ID

# 보안 그룹 삭제
aws ec2 delete-security-group --group-id $SG_ID

# Key Pair 삭제 (선택사항)
aws ec2 delete-key-pair --key-name monitoring-key
rm -f monitoring-key.pem
```

#### 실습 2: Prometheus 설치 및 설정 (20분)

**변경 전 시스템 아키텍처**:
```mermaid
flowchart TD
    subgraph "기존 모니터링"
        A["애플리케이션"] --> B["로그 파일"]
        B --> C["수동 확인"]
        C --> D["알림 없음"]
    end
    
    style A fill:#1976d2,color:#ffffff
    style B fill:#388e3c,color:#ffffff
    style C fill:#f57c00,color:#ffffff
    style D fill:#d32f2f,color:#ffffff
```

**자동화 도구 실행**:
```bash
# 📍 Prometheus 설치 및 설정 (자동화)
./monitoring-hub-helper.sh --action install-prometheus

# 📍 Prometheus 서비스 상태 확인
./monitoring-hub-helper.sh --action check-prometheus

# 📍 Prometheus 메트릭 수집 확인
./monitoring-hub-helper.sh --action test-prometheus
```

**변경 후 시스템 아키텍처**:
```mermaid
flowchart TD
    subgraph "Prometheus 모니터링"
        A["애플리케이션"] --> B["메트릭 수집"]
        B --> C["Prometheus Server"]
        C --> D["메트릭 저장"]
        D --> E["쿼리 엔진"]
    end
    
    subgraph "모니터링 기능"
        F["실시간 메트릭"] --> G["알림 규칙"]
        G --> H["자동 알림"]
        H --> I["문제 조기 발견"]
    end
    
    E --> F
    
    style A fill:#1976d2,color:#ffffff
    style B fill:#388e3c,color:#ffffff
    style C fill:#d32f2f,color:#ffffff
    style D fill:#d32f2f,color:#ffffff
    style E fill:#d32f2f,color:#ffffff
    style F fill:#4caf50,color:#ffffff
    style G fill:#4caf50,color:#ffffff
    style H fill:#4caf50,color:#ffffff
    style I fill:#4caf50,color:#ffffff
```

**실습 명령어**:
```bash
# Prometheus 설치
wget https://github.com/prometheus/prometheus/releases/download/v2.40.0/prometheus-2.40.0.linux-amd64.tar.gz
tar xzf prometheus-2.40.0.linux-amd64.tar.gz
sudo mv prometheus-2.40.0.linux-amd64 /opt/prometheus

# Prometheus 설정 파일 생성
cat > /opt/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
EOF

# Prometheus 서비스 시작
sudo systemctl start prometheus
sudo systemctl enable prometheus
```

**실습 내용**:
- Prometheus 서버 설치
- 설정 파일 구성
- 서비스 시작 및 확인

#### 수작업 실습 가이드 (Prometheus 설치 및 설정)

**1단계: Prometheus 사용자 및 디렉토리 설정**
```bash
# Prometheus 사용자 생성
sudo useradd --no-create-home --shell /bin/false prometheus

# Prometheus 디렉토리 생성
sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/prometheus
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus
```

**2단계: Prometheus 바이너리 다운로드 및 설치**
```bash
# Prometheus 최신 버전 다운로드
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz

# 압축 해제
tar xzf prometheus-2.45.0.linux-amd64.tar.gz
cd prometheus-2.45.0.linux-amd64

# 바이너리 파일 복사
sudo cp prometheus /usr/local/bin/
sudo cp promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

# 설정 파일 및 웹 UI 파일 복사
sudo cp -r consoles /etc/prometheus
sudo cp -r console_libraries /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
```

**3단계: Prometheus 설정 파일 생성**
```bash
# Prometheus 설정 파일 생성
sudo tee /etc/prometheus/prometheus.yml > /dev/null << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'grafana'
    static_configs:
      - targets: ['localhost:3000']

  - job_name: 'docker'
    static_configs:
      - targets: ['localhost:9323']
EOF

# 설정 파일 권한 설정
sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml
```

**4단계: Prometheus systemd 서비스 파일 생성**
```bash
# systemd 서비스 파일 생성
sudo tee /etc/systemd/system/prometheus.service > /dev/null << 'EOF'
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.listen-address=0.0.0.0:9090 \
    --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
EOF
```

**5단계: Prometheus 서비스 시작 및 확인**
```bash
# systemd 데몬 리로드
sudo systemctl daemon-reload

# Prometheus 서비스 시작
sudo systemctl start prometheus

# 서비스 활성화 (부팅 시 자동 시작)
sudo systemctl enable prometheus

# 서비스 상태 확인
sudo systemctl status prometheus

# Prometheus 웹 UI 접근 테스트
curl -s http://localhost:9090/api/v1/query?query=up | jq
```

**6단계: Prometheus 설정 검증**
```bash
# 설정 파일 문법 검증
sudo -u prometheus /usr/local/bin/promtool check config /etc/prometheus/prometheus.yml

# Prometheus 메트릭 확인
curl -s http://localhost:9090/metrics | head -20

# 타겟 상태 확인
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health}'
```

**7단계: Prometheus 로그 확인**
```bash
# Prometheus 로그 확인
sudo journalctl -u prometheus -f

# 최근 로그 확인
sudo journalctl -u prometheus --since "10 minutes ago"
```

**8단계: Prometheus 웹 UI 접근**
```bash
# 웹 브라우저에서 접근
echo "Prometheus Web UI: http://$(curl -s ifconfig.me):9090"
echo "Status -> Targets에서 수집 대상 확인"
echo "Graph에서 메트릭 쿼리 가능"
```

#### 실습 3: Grafana 설치 및 설정 (20분)

**변경 전 시스템 아키텍처**:
```mermaid
flowchart TD
    subgraph "기존 데이터 시각화"
        A["Prometheus 데이터"] --> B["텍스트 기반 확인"]
        B --> C["수동 분석"]
        C --> D["시각화 부족"]
    end
    
    style A fill:#1976d2,color:#ffffff
    style B fill:#388e3c,color:#ffffff
    style C fill:#f57c00,color:#ffffff
    style D fill:#d32f2f,color:#ffffff
```

**자동화 도구 실행**:
```bash
# 📍 Grafana 설치 및 설정 (자동화)
./monitoring-hub-helper.sh --action install-grafana

# 📍 Grafana 서비스 상태 확인
./monitoring-hub-helper.sh --action check-grafana

# 📍 Grafana 데이터 소스 설정
./monitoring-hub-helper.sh --action setup-grafana-datasource

# 📍 Grafana 대시보드 설정
./monitoring-hub-helper.sh --action setup-grafana-dashboard
```

**변경 후 시스템 아키텍처**:
```mermaid
flowchart TD
    subgraph "Grafana 시각화"
        A["Prometheus"] --> B["Grafana Server"]
        B --> C["대시보드"]
        C --> D["차트 및 그래프"]
        D --> E["실시간 모니터링"]
    end
    
    subgraph "시각화 기능"
        F["대시보드 템플릿"] --> G["알림 설정"]
        G --> H["사용자 권한 관리"]
        H --> I["데이터 소스 통합"]
    end
    
    E --> F
    
    style A fill:#d32f2f,color:#ffffff
    style B fill:#1976d2,color:#ffffff
    style C fill:#1976d2,color:#ffffff
    style D fill:#1976d2,color:#ffffff
    style E fill:#1976d2,color:#ffffff
    style F fill:#4caf50,color:#ffffff
    style G fill:#4caf50,color:#ffffff
    style H fill:#4caf50,color:#ffffff
    style I fill:#4caf50,color:#ffffff
```

**실습 명령어**:
```bash
# Grafana 설치
wget https://dl.grafana.com/oss/release/grafana-9.3.0.linux-amd64.tar.gz
tar xzf grafana-9.3.0.linux-amd64.tar.gz
sudo mv grafana-9.3.0 /opt/grafana

# Grafana 서비스 시작
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# Grafana 접속 확인
curl http://localhost:3000
```

**실습 내용**:
- Grafana 서버 설치
- Prometheus 데이터 소스 연결
- 기본 대시보드 생성

#### 실습 4: Node Exporter 설치 (20분)

**변경 전 시스템 아키텍처**:
```mermaid
flowchart TD
    subgraph "기존 시스템 모니터링"
        A["시스템 리소스"] --> B["수동 확인"]
        B --> C["로그 기반 모니터링"]
        C --> D["통합 모니터링 부족"]
    end
    
    style A fill:#1976d2,color:#ffffff
    style B fill:#388e3c,color:#ffffff
    style C fill:#f57c00,color:#ffffff
    style D fill:#d32f2f,color:#ffffff
```

**자동화 도구 실행**:
```bash
# 📍 Node Exporter 설치 및 설정 (자동화)
./monitoring-hub-helper.sh --action install-node-exporter

# 📍 Node Exporter 서비스 상태 확인
./monitoring-hub-helper.sh --action check-node-exporter

# 📍 시스템 메트릭 수집 확인
./monitoring-hub-helper.sh --action test-node-exporter
```

**변경 후 시스템 아키텍처**:
```mermaid
flowchart TD
    subgraph "통합 모니터링 시스템"
        A["Node Exporter"] --> B["시스템 메트릭"]
        B --> C["Prometheus"]
        C --> D["Grafana"]
        D --> E["통합 대시보드"]
    end
    
    subgraph "모니터링 범위"
        F["CPU/메모리"] --> G["디스크/네트워크"]
        G --> H["애플리케이션 메트릭"]
        H --> I["인프라 메트릭"]
    end
    
    E --> F
    
    style A fill:#388e3c,color:#ffffff
    style B fill:#388e3c,color:#ffffff
    style C fill:#d32f2f,color:#ffffff
    style D fill:#1976d2,color:#ffffff
    style E fill:#1976d2,color:#ffffff
    style F fill:#4caf50,color:#ffffff
    style G fill:#4caf50,color:#ffffff
    style H fill:#4caf50,color:#ffffff
    style I fill:#4caf50,color:#ffffff
```

**실습 명령어**:
```bash
# Node Exporter 설치
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar xzf node_exporter-1.5.0.linux-amd64.tar.gz
sudo mv node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin/

# Node Exporter 서비스 시작
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
```

**실습 내용**:
- Node Exporter 설치
- Push Gateway 설정
- 메트릭 수집 확인

### 📊 실습 결과
- [ ] Prometheus 서버 정상 작동
- [ ] Grafana 대시보드 접근 가능
- [ ] Node Exporter 메트릭 수집 확인
- [ ] AlertManager 알림 설정 완료

---

## 🧹 실습 정리 (17:00-17:30)

### 🎯 **4교시 모니터링 허브 정리**

#### **Docker 컨테이너 정리**
```bash
# SSH로 모니터링 인스턴스 접속
ssh -i cloud-deployment-key.pem ec2-user@3.37.234.110

# 실행 중인 컨테이너 확인
docker ps

# 컨테이너 중지 및 삭제
docker stop prometheus grafana node-exporter
docker rm prometheus grafana node-exporter

# Docker 이미지 정리 (선택사항)
docker image prune -f
```

#### **AWS 리소스 정리**
```bash
# EC2 인스턴스 중지 (비용 절약)
aws ec2 stop-instances --instance-ids i-09108c566c2abb37d

# EC2 인스턴스 삭제 (완전 정리)
aws ec2 terminate-instances --instance-ids i-09108c566c2abb37d

# Elastic IP 해제 (할당 ID 확인 후)
aws ec2 describe-addresses --query 'Addresses[?InstanceId==`i-09108c566c2abb37d`].AllocationId' --output text
aws ec2 release-address --allocation-id <ALLOCATION_ID>
```

#### **GCP 리소스 정리**
```bash
# GCP Compute Engine 인스턴스 삭제
gcloud compute instances delete cloud-intermediate-vm --zone=asia-northeast3-a --quiet
```

### 🤖 **자동화 스크립트 정리 (권장)**

**통합 정리 실행**
```bash
# 전체 실습 환경 정리
./day1-practice.sh --action cleanup
```

**개별 서비스 정리**
```bash
# AWS ECS 정리
./aws-ecs-helper.sh --action cleanup

# GCP Cloud Run 정리  
./gcp-cloudrun-helper.sh --action cleanup

# 모니터링 허브 정리
./monitoring-hub-helper.sh --action cleanup

# 상태 확인
./day1-practice.sh --action status
```

### 📋 **정리 내용 확인**

#### **3교시: 클라우드 컨테이너 서비스**
- [ ] AWS ECS 클러스터 삭제
- [ ] GCP Cloud Run 서비스 삭제
- [ ] Container Registry 이미지 삭제
- [ ] 로드 밸런서 및 보안 그룹 정리
- [ ] CloudWatch 로그 그룹 정리

#### **4교시: 통합 모니터링 허브**
- [ ] Docker 컨테이너 중지 및 삭제
- [ ] Prometheus, Grafana, Node Exporter 정리
- [ ] AWS EC2 인스턴스 중지/삭제
- [ ] GCP Compute Engine 인스턴스 삭제
- [ ] Elastic IP 해제
- [ ] 보안 그룹 정리

---

## 📊 학습 성과 확인

### **🤖 자동화 스크립트 검증**
```bash
# 전체 실습 상태 확인
./day1-practice.sh --action status

# 개별 서비스 상태 확인
./aws-ecs-helper.sh --action status
./gcp-cloudrun-helper.sh --action status
./monitoring-hub-helper.sh --action status
```

### **✅ 실습 완료 체크리스트**

#### **3교시: 클라우드 컨테이너 서비스**
- [ ] AWS ECS 컨테이너 서비스 배포 완료
- [ ] GCP Cloud Run 서버리스 배포 완료
- [ ] 자동 스케일링 설정 완료
- [ ] 트래픽 관리 설정 완료
- [ ] 모니터링 및 로깅 설정 완료

#### **4교시: 통합 모니터링 허브**
- [ ] Prometheus 메트릭 수집 시스템 구축 완료
- [ ] Grafana 대시보드 접근 가능
- [ ] Node Exporter 시스템 메트릭 수집 확인
- [ ] Docker 컨테이너 기반 모니터링 환경 구축
- [ ] 웹 인터페이스를 통한 모니터링 도구 접근 확인

### **🎯 학습 목표 달성 확인**

#### **3교시: 클라우드 컨테이너 서비스**
- [ ] **AWS ECS**: Fargate 서버리스 컨테이너 배포 이해
- [ ] **GCP Cloud Run**: 서버리스 컨테이너 플랫폼 활용
- [ ] **자동화**: 수동 가이드와 자동화 스크립트 동기화 이해
- [ ] **비교 분석**: ECS vs Cloud Run vs EKS vs GKE 차이점 파악

#### **4교시: 통합 모니터링 허브**
- [ ] **Prometheus**: 메트릭 수집 및 저장 시스템 이해
- [ ] **Grafana**: 시각화 대시보드 구축 및 활용
- [ ] **Node Exporter**: 시스템 메트릭 수집 도구 이해
- [ ] **Docker**: 컨테이너 기반 모니터링 환경 구축
- [ ] **통합 모니터링**: Prometheus + Grafana + Node Exporter 연동

### **🚀 다음 단계**
- **Day 2 실습**으로 진행: CI/CD 및 고급 클라우드 배포
- **자동화 스크립트 활용**: 수동 가이드와 자동화 스크립트 조합 활용

---

## 🎯 강의 성공 지표

### 정량적 지표
- **실습 완료율**: 95% 이상
- **환경 설정 성공률**: 90% 이상
- **LoadBalancer 접근 성공률**: 85% 이상
- **모니터링 시스템 구축 성공률**: 90% 이상
- **Docker 컨테이너 실행 성공률**: 95% 이상
- **웹 인터페이스 접근 성공률**: 90% 이상

### 정성적 지표
- **수강생 만족도**: 4.5/5.0 이상
- **실습 이해도**: 90% 이상
- **문제 해결 능력**: 향상 확인
- **다음 단계 준비도**: 85% 이상

---

## 🔗 관련 자동화 도구

### Docker 관련 도구
- `./tools/cloud/docker-helper.sh` - Docker 멀티스테이지 빌드, 이미지 최적화, 보안 스캔

### Kubernetes 관련 도구
- `./tools/cloud/k8s-helper.sh` - 클러스터 Context 설정, Workload 배포, 외부 접근 구성

### 클라우드 서비스 도구
- `./tools/cloud/aws-ecs-helper.sh` - ECS 클러스터, 태스크 정의, 서비스 관리
- `./tools/cloud/gcp-cloudrun-helper.sh` - Cloud Run 서비스 배포 및 관리

### 모니터링 도구
- `./tools/cloud/monitoring-hub-helper.sh` - 통합 모니터링 허브 구축 (Prometheus, Grafana, Node Exporter)
- `./tools/cloud/environment-check.sh` - 실습 환경 자동 체크
- `./tools/cloud/setup-environment.sh` - 환경 설정 자동화

---

## 📚 추가 학습 자료

### 공식 문서
- [Docker 공식 문서](https://docs.docker.com/)
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [AWS ECS 공식 문서](https://docs.aws.amazon.com/ecs/)
- [GCP Cloud Run 공식 문서](https://cloud.google.com/run/docs)
- [Prometheus 공식 문서](https://prometheus.io/docs/)
- [Grafana 공식 문서](https://grafana.com/docs/)

### 실습 샘플 코드
- `repo/practice/day1/cloud-container-services/` - AWS ECS, GCP Cloud Run 배포 예제
- `repo/practice/day1/monitoring-hub/` - Prometheus, Grafana 모니터링 설정 예제
- `tools/cloud/` - 공통 환경 설정 및 헬퍼 스크립트

---

**💡 강의 진행 중 문제가 발생하면 실시간으로 지원해드리겠습니다!**  
**수강생의 학습 성과를 최대화하기 위해 지속적으로 모니터링하겠습니다.**
