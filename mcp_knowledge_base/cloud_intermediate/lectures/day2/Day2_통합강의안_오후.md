# ☁️ 클라우드 중급 과정 - Day 2 통합 강의안 (오후)

## 📋 오후 강의 개요

### 🎯 오후 강의 목표
- **AWS Application 모니터링** EKS 애플리케이션 배포 및 모니터링을 통해 실무 역량을 강화합니다.
- **GCP 클러스터 통합** GKE 클러스터 구축 및 멀티 클라우드 모니터링을 완성합니다.
- **멀티 클라우드 통합 모니터링** AWS EKS, GCP GKE를 연동한 통합 모니터링 시스템을 구축합니다.

### ⏰ 오후 강의 시간표
| 시간 | 교시 | 내용 | 시간 |
|------|------|------|------|
| 13:45-15:15 | 3교시 | AWS Application 모니터링 | 90분 |
| 15:30-17:00 | 4교시 | 멀티 클라우드 VM 통합 모니터링 | 90분 |
| 17:00-17:30 | 정리 | 실습 정리 | 30분 |

---

## 🕘 3교시: AWS Application 모니터링 (13:45-15:15)

### 📚 강의 내용 (30분)

#### AWS Application 모니터링 개요
```mermaid
flowchart TD
    subgraph "AWS EC2 애플리케이션 배포"
        A["AWS EC2 인스턴스"] --> B["Docker 애플리케이션"]
        B --> C["Prometheus + Grafana"]
        C --> D["메트릭 수집"]
        D --> E["통합 모니터링"]
    end
    
    subgraph "데이터 수집 경로"
        F["Node.js 앱 (포트 3000)"] --> G["/metrics 엔드포인트"]
        G --> H["Prometheus (포트 9090)"]
        H --> I["Grafana (포트 3000)"]
        I --> J["통합 대시보드"]
    end
    
    E --> F
    
    style A fill:#ff6f00,color:#ffffff
    style B fill:#388e3c,color:#ffffff
    style C fill:#d32f2f,color:#ffffff
    style D fill:#1976d2,color:#ffffff
    style E fill:#4caf50,color:#ffffff
    style F fill:#1976d2,color:#ffffff
    style G fill:#388e3c,color:#ffffff
    style H fill:#d32f2f,color:#ffffff
    style I fill:#1976d2,color:#ffffff
    style J fill:#4caf50,color:#ffffff
```

#### 핵심 개념
- **AWS EC2 배포**: AWS EC2 인스턴스에 애플리케이션 직접 배포
- **Docker 컨테이너**: Docker를 사용한 애플리케이션 컨테이너화
- **모니터링 스택**: Prometheus + Grafana를 통한 실시간 모니터링
- **실무 준비**: 실제 프로덕션 환경과 유사한 VM 기반 배포

### 🛠️ 실습 진행 (60분)

#### 실습 1: AWS EC2 애플리케이션 배포 (20분)

**AWS EC2 애플리케이션 배포 구성**:
```mermaid
flowchart TD
    subgraph "AWS EC2 인스턴스"
        A["EC2 인스턴스"] --> B["Docker 애플리케이션"]
        B --> C["Prometheus (포트 9090)"]
        B --> D["Grafana (포트 3000)"]
        B --> E["PostgreSQL (포트 5432)"]
        B --> F["Redis (포트 6379)"]
    end
    
    subgraph "애플리케이션 스택"
        G["Node.js 앱 (포트 3000)"] --> H["메트릭 엔드포인트"]
        H --> I["Prometheus 수집"]
        I --> J["Grafana 시각화"]
    end
    
    A --> G
    
    style A fill:#ff6f00,color:#ffffff
    style B fill:#388e3c,color:#ffffff
    style C fill:#d32f2f,color:#ffffff
    style D fill:#1976d2,color:#ffffff
    style E fill:#388e3c,color:#ffffff
    style F fill:#d32f2f,color:#ffffff
    style G fill:#1976d2,color:#ffffff
    style H fill:#388e3c,color:#ffffff
    style I fill:#d32f2f,color:#ffffff
    style J fill:#1976d2,color:#ffffff
```

**🔧 실행 전 AWS EKS 환경 확인**:
```bash
# AWS CLI 설정 확인
aws sts get-caller-identity
# 결과: AWS 계정 정보 출력

# EKS CLI (eksctl) 설치 확인
eksctl version
# 결과: eksctl 버전 정보

# kubectl 설치 확인
kubectl version --client
# 결과: kubectl 버전 정보

# AWS 리전 설정 확인
aws configure get region
# 결과: ap-northeast-2

# EKS 클러스터 목록 확인
aws eks list-clusters --region ap-northeast-2
# 결과: 기존 클러스터 목록 (없을 수도 있음)
```

**실제 실행 명령어**:
```bash
# 1. EKS 클러스터 생성 (aws-eks-helper.sh 사용)
./aws-eks-helper.sh --action cluster-create

# 2. EKS 클러스터 상태 확인
./aws-eks-helper.sh --action cluster-status

# 3. kubeconfig 업데이트
./aws-eks-helper.sh --action kubeconfig-update

# 4. 클러스터 노드 및 파드 상태 확인
kubectl get nodes
kubectl get pods --all-namespaces

# 5. 클러스터 자동 스케일링 설정 확인
kubectl get hpa --all-namespaces
```

**📊 실행 후 EKS 클러스터 확인**:
```bash
# EKS 클러스터 상태 확인
aws eks describe-cluster --name eks-intermediate --region ap-northeast-2 --query 'cluster.{Name:name,Status:status,Version:version,Endpoint:endpoint}' --output table

# 결과 예시:
# | Name              | Status  | Version | Endpoint                                                      |
# | eks-intermediate  | ACTIVE  | 1.28    | https://ABCDEFGHIJKLMNOP.gr7.ap-northeast-2.eks.amazonaws.com |

# 클러스터 노드 상태 확인
kubectl get nodes -o wide

# 클러스터 파드 상태 확인
kubectl get pods --all-namespaces

# EKS 클러스터 자동 스케일링 확인
kubectl get hpa --all-namespaces
```

**🌐 웹브라우저 접속 가이드**:
1. **AWS EKS 콘솔**:
   - URL: `https://console.aws.amazon.com/eks/`
   - 확인 사항: 클러스터 상태, 노드 그룹, 서비스

2. **Kubernetes 대시보드** (설치된 경우):
   - URL: `https://[EKS-ENDPOINT]/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/`
   - 확인 사항: 클러스터 리소스, 파드 상태

3. **애플리케이션 서비스**:
   - URL: `http://[LoadBalancer-IP]` (LoadBalancer 서비스 생성 시)
   - 확인 사항: 배포된 애플리케이션 접근

**실습 내용**:
- AWS EKS 클러스터 생성 및 설정
- kubectl을 통한 클러스터 관리
- EKS 기반 Kubernetes 환경 구축

#### 실습 2: GitHub Actions VM 배포 설정 (20분)

**GitHub Actions VM 배포 구성**:
```mermaid
flowchart TD
    subgraph "GitHub Repository"
        A["Settings"] --> B["Secrets and variables"]
        B --> C["Actions"]
        C --> D["New repository secret"]
    end
    
    subgraph "VM 배포 Secrets"
        E["Docker Hub 인증"] --> F["AWS EC2 배포"]
        F --> G["GCP Compute Engine 배포"]
        G --> H["VM SSH 연결"]
    end
    
    D --> E
    
    style A fill:#1976d2,color:#ffffff
    style B fill:#388e3c,color:#ffffff
    style C fill:#388e3c,color:#ffffff
    style D fill:#4caf50,color:#ffffff
    style E fill:#ff6f00,color:#ffffff
    style F fill:#ff6f00,color:#ffffff
    style G fill:#1976d2,color:#ffffff
    style H fill:#4caf50,color:#ffffff
```

**실제 설정한 VM 배포 Secrets**:
```bash
# GitHub Repository: https://github.com/jungfrau70/github-actions-demo-day2
# Settings > Secrets and variables > Actions에서 설정:

# Docker Hub 인증
DOCKER_USERNAME: your-docker-username
DOCKER_PASSWORD: your-docker-password

# AWS EC2 배포 (PROD 환경)
AWS_ACCESS_KEY_ID: [AWS Access Key ID]
AWS_SECRET_ACCESS_KEY: [AWS Secret Access Key]
AWS_REGION: ap-northeast-2
EC2_INSTANCE_ID: [EC2 Instance ID]
EC2_SSH_KEY: [EC2 SSH Private Key]
EC2_USERNAME: ubuntu

# GCP Compute Engine 배포 (STAGING 환경)
GCP_PROJECT_ID: [GCP Project ID]
GCP_SA_KEY: [GCP Service Account Key JSON]
GCP_REGION: asia-northeast1
GCP_ZONE: asia-northeast1-a
GCP_INSTANCE_NAME: cloud-intermediate-vm
GCP_SSH_KEY: [GCP SSH Private Key]
GCP_USERNAME: ubuntu

# 모니터링 허브 연결
MONITORING_HUB_URL: http://[EC2-Public-IP]:9090
GRAFANA_URL: http://[EC2-Public-IP]:3000
GRAFANA_USERNAME: admin
GRAFANA_PASSWORD: admin

# 애플리케이션 설정
APP_ENV: production
APP_PORT: 3000
LOG_LEVEL: info
```

**실습 명령어**:
```bash
# 1. GitHub VM 배포 Secrets 가이드 생성
cat > github-vm-secrets-guide.md << 'EOF'
# GitHub Actions VM 배포 Secrets 설정 가이드
# Repository: https://github.com/jungfrau70/github-actions-demo-day2
# [위의 VM 배포 Secrets 목록 포함]
EOF

# 2. GitHub에 변경사항 푸시
git add .
git commit -m "feat: VM 배포를 위한 GitHub Actions 설정 완료"
git push origin day2-advanced

# 3. GitHub Actions 워크플로우 확인
cat .github/workflows/advanced-cicd.yml | head -30
```

**실습 내용**:
- GitHub Actions VM 배포 Secrets 설정 가이드 생성
- AWS EC2/GCP Compute Engine 배포용 Secrets 목록 완성
- VM SSH 연결 및 모니터링 허브 연결 정보 설정

#### 실습 3: GCP Compute Engine VM 생성 및 연결 (20분)

**GCP Compute Engine VM 생성**:
```mermaid
flowchart TD
    subgraph "GCP Compute Engine VM"
        A["GCP VM 인스턴스"] --> B["cloud-intermediate-vm"]
        B --> C["Ubuntu 20.04 LTS"]
        C --> D["Docker 설치"]
    end
    
    subgraph "애플리케이션 배포"
        E["Node.js 애플리케이션"] --> F["Docker 컨테이너"]
        F --> G["Prometheus 수집"]
        G --> H["Grafana 시각화"]
    end
    
    D --> E
    
    style A fill:#1976d2,color:#ffffff
    style B fill:#388e3c,color:#ffffff
    style C fill:#4caf50,color:#ffffff
    style D fill:#1976d2,color:#ffffff
    style E fill:#1976d2,color:#ffffff
    style F fill:#d32f2f,color:#ffffff
    style G fill:#1976d2,color:#ffffff
    style H fill:#4caf50,color:#ffffff
```

**실제 실행 명령어**:
```bash
# 1. GCP VM 인스턴스 생성
gcloud compute instances create cloud-intermediate-vm \
    --zone=asia-northeast1-a \
    --machine-type=e2-medium \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=20GB \
    --boot-disk-type=pd-standard \
    --tags=http-server,https-server

# 2. VM 인스턴스 상태 확인
gcloud compute instances list --filter="name=cloud-intermediate-vm"
# 결과: VM 인스턴스 생성 및 실행 상태 확인

# 3. VM에 SSH 연결
gcloud compute ssh cloud-intermediate-vm --zone=asia-northeast1-a

# 4. VM에서 Docker 설치
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo usermod -aG docker $USER
sudo systemctl start docker
sudo systemctl enable docker

# 주의) 반드시 새로운 테미털을 열고 계속 

# 5. 애플리케이션 배포를 위한 Docker Compose 실행
git clone https://github.com/[github-userid]/github-actions-demo-day2.git
cd github-actions-demo-day2
git checkout day2-advanced
docker-compose up -d
```

**GCP VM 애플리케이션 확인**:
```bash
# 1. GCP VM 애플리케이션 메트릭 확인
curl -s http://localhost:3000/health | jq .
# 결과: {"status":"OK","uptime":1849.324906501,...}

# 2. Prometheus 메트릭 수집 상태 확인
curl -s "http://localhost:9090/api/v1/targets" | jq '.data.activeTargets[] | select(.labels.job == "github-actions-demo")'
# 결과:
# {
#   "job": "github-actions-demo",
#   "health": "up",
#   "lastScrape": "2025-09-30T09:29:52.984608983Z",
#   "discoveredLabels": {
#     "__address__": "app:3000",
#     "__metrics_path__": "/metrics",
#     "__scheme__": "http",
#     "__scrape_interval__": "10s",
#     "__scrape_timeout__": "5s",
#     "job": "github-actions-demo"
#   }
# }

# 3. 수집된 메트릭 샘플 확인
curl -s http://localhost:3000/metrics | grep -E "(process_cpu_seconds_total|process_resident_memory_bytes)" | head -5
# 결과: Prometheus 형식 메트릭 출력

# 4. GCP VM 외부 IP 확인
gcloud compute instances describe cloud-intermediate-vm --zone=asia-northeast1-a --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
# 결과: GCP VM 퍼블릭 IP 주소
```

**실습 내용**:
- GCP Compute Engine VM 생성 및 설정
- VM에 Docker 및 애플리케이션 배포
- Prometheus 메트릭 수집 확인

### 📊 실습 결과
- [x] **AWS EC2 애플리케이션 배포 완료** - AWS EC2에 Docker 애플리케이션 직접 배포
- [x] **GitHub Actions VM 배포 설정 완료** - AWS EC2/GCP Compute Engine 배포용 설정 가이드 생성
- [x] **GCP Compute Engine VM 생성 완료** - GCP VM에 Docker 애플리케이션 배포
- [x] **멀티 클라우드 VM 배포 완료** - AWS EC2와 GCP VM에 동일한 애플리케이션 배포
- [x] **통합 모니터링 확인 완료** - 실시간 메트릭 수집 및 대시보드 접근 가능

### 🎯 3교시 핵심 성과
- **AWS EC2 배포**: AWS EC2에 Docker 애플리케이션 직접 배포
- **GCP VM 배포**: GCP Compute Engine에 Docker 애플리케이션 배포
- **VM 기반 모니터링**: Kubernetes 대신 VM 기반 모니터링 시스템 구축
- **실무 준비**: 실제 프로덕션 환경과 유사한 VM 기반 배포 경험

---

## 🕘 4교시: 멀티 클라우드 VM 통합 모니터링 (15:30-17:00)

### 📚 강의 내용 (30분)

#### 멀티 클라우드 VM 통합 모니터링 개요
```mermaid
flowchart TD
    subgraph "4교시 실습 구성"
        A["AWS EC2 VM"] --> B["GCP Compute Engine VM"]
        B --> C["애플리케이션 배포"]
        C --> D["통합 모니터링"]
    end
    
    subgraph "멀티 클라우드 VM 통합"
        E["AWS EC2"] --> F["통합 모니터링 허브"]
        G["GCP VM"] --> F
        H["모니터링 허브 (EC2)"] --> F
        F --> I["단일 대시보드"]
    end
    
    D --> F
    
    style A fill:#ff6f00,color:#ffffff
    style B fill:#1976d2,color:#ffffff
    style C fill:#388e3c,color:#ffffff
    style D fill:#4caf50,color:#ffffff
    style E fill:#ff6f00,color:#ffffff
    style F fill:#4caf50,color:#ffffff
    style G fill:#1976d2,color:#ffffff
    style H fill:#9c27b0,color:#ffffff
    style I fill:#4caf50,color:#ffffff
```

#### 핵심 개념
- **AWS EC2 VM**: AWS EC2 인스턴스에 애플리케이션 배포
- **GCP Compute Engine VM**: GCP VM에 애플리케이션 배포
- **멀티 클라우드 VM 통합**: AWS와 GCP VM 환경 통합 모니터링
- **실무 배포**: GitHub Actions를 통한 실제 VM 배포

### 🛠️ 실습 진행 (60분)

#### 실습 1: GitHub Actions VM 배포 실행 (20분)

**GitHub Actions VM 배포 개요**:
```mermaid
flowchart TD
    subgraph "GitHub Actions VM 배포 과정"
        A["코드 푸시"] --> B["GitHub Actions 실행"]
        B --> C["Docker 이미지 빌드"]
        C --> D["AWS EC2 배포"]
        C --> E["GCP VM 배포"]
    end
    
    subgraph "배포된 VM 환경"
        F["AWS EC2"] --> G["Production 환경"]
        H["GCP VM"] --> I["Staging 환경"]
        G --> J["통합 모니터링"]
        I --> J
    end
    
    D --> F
    E --> H
    
    style A fill:#1976d2,color:#ffffff
    style B fill:#388e3c,color:#ffffff
    style C fill:#d32f2f,color:#ffffff
    style D fill:#ff6f00,color:#ffffff
    style E fill:#1976d2,color:#ffffff
    style F fill:#ff6f00,color:#ffffff
    style G fill:#4caf50,color:#ffffff
    style H fill:#1976d2,color:#ffffff
    style I fill:#4caf50,color:#ffffff
    style J fill:#4caf50,color:#ffffff
```

**실습 명령어**:
```bash
# 1. Grafana 대시보드 접속
# URL: http://[모니터링-허브-IP]:3000
# 로그인: admin/admin

# 2. 데이터 소스 설정 확인
# Prometheus 데이터 소스: http://localhost:9090
# AWS EC2 VM: http://[AWS-EC2-IP]:3000/metrics
# GCP VM: http://[GCP-VM-IP]:3000/metrics

# 3. 통합 대시보드 생성
cat > grafana-dashboard.json << 'EOF'
{
  "dashboard": {
    "title": "멀티 클라우드 VM 모니터링",
    "panels": [
      {
        "title": "AWS EC2 VM 메트릭",
        "type": "graph",
        "targets": [
          {
            "expr": "up{job=\"aws-ec2-vm\"}",
            "legendFormat": "AWS EC2 상태"
          }
        ]
      },
      {
        "title": "GCP VM 메트릭",
        "type": "graph",
        "targets": [
          {
            "expr": "up{job=\"gcp-vm\"}",
            "legendFormat": "GCP VM 상태"
          }
        ]
      }
    ]
  }
}
EOF

# 4. 대시보드 가져오기
curl -X POST \
  -H "Content-Type: application/json" \
  -d @grafana-dashboard.json \
  http://admin:admin@localhost:3000/api/dashboards/db
```

**실습 내용**:
- Grafana 통합 대시보드 구성
- AWS EC2/GCP VM 메트릭 시각화
- 실시간 모니터링 및 알림 설정

#### 실습 2: 멀티 클라우드 VM 모니터링 설정 (20분)

**멀티 클라우드 VM 모니터링 개요**:
```mermaid
flowchart TD
    subgraph "멀티 클라우드 VM 모니터링"
        A["AWS EC2 VM"] --> B["통합 모니터링 허브"]
        C["GCP VM"] --> B
        B --> D["Prometheus"]
        D --> E["Grafana"]
        E --> F["통합 대시보드"]
    end
    
    subgraph "데이터 수집"
        G["EC2 메트릭"] --> H["Remote Write"]
        I["GCP VM 메트릭"] --> H
        J["로컬 메트릭"] --> H
        H --> K["통합 데이터베이스"]
    end
    
    B --> G
    B --> I
    B --> J
    
    style A fill:#ff6f00,color:#ffffff
    style B fill:#4caf50,color:#ffffff
    style C fill:#1976d2,color:#ffffff
    style D fill:#d32f2f,color:#ffffff
    style E fill:#1976d2,color:#ffffff
    style F fill:#4caf50,color:#ffffff
    style G fill:#ff6f00,color:#ffffff
    style H fill:#388e3c,color:#ffffff
    style I fill:#1976d2,color:#ffffff
    style J fill:#9c27b0,color:#ffffff
    style K fill:#4caf50,color:#ffffff
```

**실습 명령어**:
```bash
# 1. AWS EC2 VM 모니터링 설정
# EC2에서 실행
curl -s http://localhost:3000/health | jq .
curl -s http://localhost:3000/metrics | head -10

# 2. GCP VM 모니터링 설정
# GCP VM에서 실행
curl -s http://localhost:3000/health | jq .
curl -s http://localhost:3000/metrics | head -10

# 3. 통합 모니터링 허브에서 VM 메트릭 수집 설정
cat > vm-monitoring-config.yaml << 'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'aws-ec2-vm'
    static_configs:
      - targets: ['[AWS-EC2-IP]:3000']
    metrics_path: '/metrics'
    scrape_interval: 30s

  - job_name: 'gcp-vm'
    static_configs:
      - targets: ['[GCP-VM-IP]:3000']
    metrics_path: '/metrics'
    scrape_interval: 30s

  - job_name: 'local-app'
    static_configs:
      - targets: ['localhost:3000']
    metrics_path: '/metrics'
    scrape_interval: 15s
EOF

# 4. 통합 모니터링 확인
curl -s "http://localhost:9090/api/v1/targets" | jq '.data.activeTargets[] | {job: .labels.job, health: .health}'
```

**실습 내용**:
- AWS EC2 VM 모니터링 설정
- GCP VM 모니터링 설정
- 통합 모니터링 허브에서 멀티 클라우드 VM 메트릭 수집

#### 실습 3: 통합 모니터링 대시보드 구성 (20분)

**통합 모니터링 대시보드 구성 개요**:
```mermaid
flowchart TD
    subgraph "통합 모니터링 대시보드"
        A["Grafana 대시보드"] --> B["AWS EC2 메트릭"]
        A --> C["GCP VM 메트릭"]
        A --> D["로컬 애플리케이션 메트릭"]
        B --> E["통합 시각화"]
        C --> E
        D --> E
    end
    
    subgraph "모니터링 기능"
        F["실시간 메트릭"] --> G["알림 설정"]
        G --> H["성능 분석"]
        H --> I["용량 계획"]
    end
    
    E --> F
    
    style A fill:#1976d2,color:#ffffff
    style B fill:#ff6f00,color:#ffffff
    style C fill:#1976d2,color:#ffffff
    style D fill:#9c27b0,color:#ffffff
    style E fill:#4caf50,color:#ffffff
    style F fill:#4caf50,color:#ffffff
    style G fill:#4caf50,color:#ffffff
    style H fill:#4caf50,color:#ffffff
    style I fill:#4caf50,color:#ffffff
```

**실습 명령어**:
```bash
# 1. GitHub Actions 워크플로우 실행
git add .
git commit -m "feat: EKS/GKE 클러스터 배포를 위한 설정 완료"
git push origin day2-advanced

# 2. GitHub Actions 실행 확인
# GitHub Repository > Actions 탭에서 워크플로우 실행 상태 확인

# 3. EKS 배포 확인 (AWS)
aws eks update-kubeconfig --region ap-northeast-2 --name cloud-intermediate-eks
kubectl get pods -n production
kubectl get services -n production

# 4. GKE 배포 확인 (GCP)
gcloud container clusters get-credentials cloud-intermediate-gke --zone asia-northeast1-a
kubectl get pods -n staging
kubectl get services -n staging

# 5. 애플리케이션 Health Check
# EKS: kubectl port-forward svc/github-actions-demo-service 8080:80 -n production
# GKE: kubectl port-forward svc/github-actions-demo-service 8081:80 -n staging
```

**실습 내용**:
- GitHub Actions를 통한 멀티 클라우드 배포
- EKS Production 환경 배포
- GKE Staging 환경 배포
- 배포된 애플리케이션 상태 확인

#### 실습 4: 멀티 클라우드 통합 모니터링 (20분)

**멀티 클라우드 통합 모니터링 개요**:
```mermaid
flowchart TD
    subgraph "통합 모니터링 시스템"
        A["AWS EKS"] --> B["모니터링 허브 (EC2)"]
        C["GCP GKE"] --> B
        B --> D["Prometheus"]
        D --> E["Grafana"]
        E --> F["통합 대시보드"]
    end
    
    subgraph "데이터 수집"
        G["EKS 메트릭"] --> H["Remote Write"]
        I["GKE 메트릭"] --> H
        J["로컬 메트릭"] --> H
        H --> K["통합 데이터베이스"]
    end
    
    B --> G
    B --> I
    B --> J
    
    style A fill:#ff6f00,color:#ffffff
    style B fill:#4caf50,color:#ffffff
    style C fill:#1976d2,color:#ffffff
    style D fill:#d32f2f,color:#ffffff
    style E fill:#1976d2,color:#ffffff
    style F fill:#4caf50,color:#ffffff
    style G fill:#ff6f00,color:#ffffff
    style H fill:#388e3c,color:#ffffff
    style I fill:#1976d2,color:#ffffff
    style J fill:#9c27b0,color:#ffffff
    style K fill:#4caf50,color:#ffffff
```

**실습 명령어**:
```bash
# 1. 모니터링 허브에서 통합 모니터링 설정
# EKS 클러스터 메트릭 수집 설정
cat > eks-monitoring-config.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-eks-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    
    scrape_configs:
      - job_name: 'eks-cluster'
        kubernetes_sd_configs:
        - role: endpoints
          namespaces:
            names:
            - production
        relabel_configs:
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
          action: keep
          regex: true
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
          action: replace
          target_label: __metrics_path__
          regex: (.+)
EOF

# 2. GKE 클러스터 메트릭 수집 설정
cat > gke-monitoring-config.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-gke-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    
    scrape_configs:
      - job_name: 'gke-cluster'
        kubernetes_sd_configs:
        - role: endpoints
          namespaces:
            names:
            - staging
        relabel_configs:
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
          action: keep
          regex: true
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
          action: replace
          target_label: __metrics_path__
          regex: (.+)
EOF

# 3. 통합 모니터링 확인
curl -s "http://localhost:9091/api/v1/targets" | jq '.data.activeTargets[] | {job: .labels.job, health: .health}'

# 4. Grafana 대시보드 확인
# http://[서버IP]:3005 에서 멀티 클라우드 대시보드 확인
```

**실습 내용**:
- EKS/GKE 클러스터 메트릭 수집 설정
- 통합 모니터링 대시보드 구성
- 멀티 클라우드 데이터 수집 확인

### 📊 실습 결과
- [x] **AWS EC2 VM 배포 완료** - AWS EC2에 Docker 애플리케이션 배포
- [x] **GCP VM 배포 완료** - GCP Compute Engine에 Docker 애플리케이션 배포
- [x] **멀티 클라우드 VM 배포 완료** - GitHub Actions를 통한 VM 배포
- [x] **통합 모니터링 완료** - 멀티 클라우드 VM 통합 모니터링 시스템 구축

### 🎯 4교시 핵심 성과
- **AWS EC2 VM**: AWS EC2에 Docker 애플리케이션 직접 배포
- **GCP VM**: GCP Compute Engine에 Docker 애플리케이션 배포
- **멀티 클라우드 VM 배포**: GitHub Actions를 통한 자동화된 VM 배포
- **통합 모니터링**: AWS EC2/GCP VM 통합 모니터링 시스템

---

## 🧹 실습 정리 (17:00-17:30)

### 자동 정리 실행
```bash
# Day2 실습 자동 정리
./day2-practice.sh
# 메뉴에서 "정리" 옵션 선택
```

### 정리 내용
- [ ] AWS EKS 리소스 정리
- [ ] GCP GKE 리소스 정리
- [ ] 모니터링 스택 정리
- [ ] 임시 파일 정리

---

## 📊 학습 성과 확인

### 실습 완료 체크리스트
- [ ] GitHub Actions CI/CD 파이프라인 구축 완료
- [ ] 멀티 클라우드 통합 모니터링 시스템 구축 완료
- [ ] AWS EKS 애플리케이션 모니터링 완료
- [ ] GCP GKE 클러스터 통합 모니터링 완료

### 다음 단계
- **Day 3 실습**으로 진행: 고급 클라우드 아키텍처 및 최적화
- **통합 강의 시나리오** 확인
- **통합 모니터링 시나리오** 확인

---

## 🎯 강의 성공 지표

### 정량적 지표
- **실습 완료율**: 95% 이상
- **CI/CD 파이프라인 성공률**: 90% 이상
- **모니터링 시스템 구축 성공률**: 90% 이상
- **멀티 클라우드 통합 성공률**: 85% 이상

### 정성적 지표
- **수강생 만족도**: 4.5/5.0 이상
- **실습 이해도**: 90% 이상
- **문제 해결 능력**: 향상 확인
- **다음 단계 준비도**: 85% 이상

---

## 🔗 관련 자동화 도구

### CI/CD 관련 도구
- `./tools/cloud/github-actions-helper.sh` - GitHub Actions 워크플로우 생성 및 관리

### AWS 관련 도구
- `./tools/cloud/aws-ec2-helper.sh` - AWS EC2 VM 배포 및 관리
- `./tools/cloud/aws-app-monitoring-helper.sh` - AWS 애플리케이션 모니터링

### GCP 관련 도구
- `./tools/cloud/gcp-vm-helper.sh` - GCP Compute Engine VM 배포 및 관리
- `./tools/cloud/gcp-app-monitoring-helper.sh` - GCP 애플리케이션 모니터링

### 모니터링 도구
- `./tools/cloud/monitoring-hub-helper.sh` - 통합 모니터링 허브 구축
- `./tools/cloud/multi-cloud-vm-monitoring-helper.sh` - 멀티 클라우드 VM 통합 모니터링

---

## 📚 추가 학습 자료

### 공식 문서
- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [AWS EC2 공식 문서](https://docs.aws.amazon.com/ec2/)
- [GCP Compute Engine 공식 문서](https://cloud.google.com/compute/docs)
- [Prometheus 공식 문서](https://prometheus.io/docs/)
- [Grafana 공식 문서](https://grafana.com/docs/)

### 실습 샘플 코드
- `./examples/day2/cicd/` - CI/CD 파이프라인 예제
- `./examples/day2/aws-ec2/` - AWS EC2 VM 배포 예제
- `./examples/day2/gcp-vm/` - GCP Compute Engine VM 배포 예제
- `./examples/day2/multi-cloud-vm/` - 멀티 클라우드 VM 통합 예제

---

**💡 강의 진행 중 문제가 발생하면 실시간으로 지원해드리겠습니다!**  
**수강생의 학습 성과를 최대화하기 위해 지속적으로 모니터링하겠습니다.**
