# 🏗️ Kubernetes 아키텍처 진화 과정

## 📊 아키텍처 변화 단계별 다이어그램

### 🔧 1단계: 기본 Pod 배포

```mermaid
flowchart TD
    subgraph "Kubernetes Cluster"
        subgraph "day1-practice Namespace"
            P1["Pod: myapp-pod<br/>nginx:1.21<br/>Port: 80"]
        end
    end
    
    subgraph "External"
        U1["사용자"]
    end
    
    U1 -.->|"접근 불가"| P1
    
    style P1 fill:#ff9999,color:#000000
    style U1 fill:#e1f5fe,color:#000000
```

**특징**: 
- 단일 Pod만 존재
- 외부 접근 불가능
- Pod 재시작 시 데이터 손실 가능

### 🔧 2단계: Deployment + ClusterIP Service

```mermaid
flowchart TD
    subgraph "Kubernetes Cluster"
        subgraph "day1-practice Namespace"
            D1["Deployment: myapp-deployment<br/>Replicas: 3"]
            P1["Pod: myapp-xxx-1<br/>nginx:1.21"]
            P2["Pod: myapp-xxx-2<br/>nginx:1.21"]
            P3["Pod: myapp-xxx-3<br/>nginx:1.21"]
            S1["Service: myapp-service<br/>Type: ClusterIP<br/>Port: 80"]
        end
    end
    
    subgraph "External"
        U1["사용자"]
    end
    
    D1 --> P1
    D1 --> P2
    D1 --> P3
    S1 --> P1
    S1 --> P2
    S1 --> P3
    
    U1 -.->|"접근 불가"| S1
    
    style D1 fill:#4caf50,color:#ffffff
    style P1 fill:#81c784,color:#000000
    style P2 fill:#81c784,color:#000000
    style P3 fill:#81c784,color:#000000
    style S1 fill:#ff9800,color:#000000
    style U1 fill:#e1f5fe,color:#000000
```

**특징**:
- 고가용성 (3개 Pod)
- 클러스터 내부에서만 접근 가능
- 로드 밸런싱 제공

### 🔧 3단계: NodePort Service 추가

```mermaid
flowchart TD
    subgraph "Kubernetes Cluster"
        subgraph "day1-practice Namespace"
            D1["Deployment: myapp-deployment<br/>Replicas: 3"]
            P1["Pod: myapp-xxx-1<br/>nginx:1.21"]
            P2["Pod: myapp-xxx-2<br/>nginx:1.21"]
            P3["Pod: myapp-xxx-3<br/>nginx:1.21"]
            S1["Service: myapp-service<br/>Type: ClusterIP<br/>Port: 80"]
            S2["Service: myapp-service-np<br/>Type: NodePort<br/>Port: 30080"]
        end
        
        subgraph "Worker Nodes"
            N1["Node 1<br/>IP: 10.0.1.10"]
            N2["Node 2<br/>IP: 10.0.1.11"]
            N3["Node 3<br/>IP: 10.0.1.12"]
        end
    end
    
    subgraph "External"
        U1["사용자"]
    end
    
    D1 --> P1
    D1 --> P2
    D1 --> P3
    S1 --> P1
    S1 --> P2
    S1 --> P3
    S2 --> P1
    S2 --> P2
    S2 --> P3
    
    P1 --> N1
    P2 --> N2
    P3 --> N3
    
    U1 -->|"http://NODE_IP:30080"| N1
    U1 -->|"http://NODE_IP:30080"| N2
    U1 -->|"http://NODE_IP:30080"| N3
    
    style D1 fill:#4caf50,color:#ffffff
    style P1 fill:#81c784,color:#000000
    style P2 fill:#81c784,color:#000000
    style P3 fill:#81c784,color:#000000
    style S1 fill:#ff9800,color:#000000
    style S2 fill:#ff5722,color:#ffffff
    style N1 fill:#9c27b0,color:#ffffff
    style N2 fill:#9c27b0,color:#ffffff
    style N3 fill:#9c27b0,color:#ffffff
    style U1 fill:#e1f5fe,color:#000000
```

**특징**:
- 노드 IP를 통한 외부 접근 가능
- 모든 노드에서 동일한 포트로 접근
- 방화벽 설정 필요

### 🔧 4단계: EKS ALB LoadBalancer

```mermaid
flowchart TD
    subgraph "AWS EKS Cluster"
        subgraph "day1-practice Namespace"
            D1["Deployment: myapp-deployment<br/>Replicas: 3"]
            P1["Pod: myapp-xxx-1<br/>nginx:1.21"]
            P2["Pod: myapp-xxx-2<br/>nginx:1.21"]
            P3["Pod: myapp-xxx-3<br/>nginx:1.21"]
            S1["Service: myapp-service-lb<br/>Type: LoadBalancer<br/>Port: 80"]
        end
        
        subgraph "Worker Nodes"
            N1["Node 1<br/>Private IP"]
            N2["Node 2<br/>Private IP"]
            N3["Node 3<br/>Private IP"]
        end
    end
    
    subgraph "AWS Load Balancer"
        ALB["Application Load Balancer<br/>External IP<br/>Health Checks"]
    end
    
    subgraph "Security Groups"
        SG["Security Group<br/>Port 80, 443<br/>0.0.0.0/0"]
    end
    
    subgraph "External"
        U1["사용자"]
    end
    
    D1 --> P1
    D1 --> P2
    D1 --> P3
    S1 --> P1
    S1 --> P2
    S1 --> P3
    
    P1 --> N1
    P2 --> N2
    P3 --> N3
    
    ALB --> S1
    ALB --> SG
    
    U1 -->|"http://ALB-URL"| ALB
    
    style D1 fill:#4caf50,color:#ffffff
    style P1 fill:#81c784,color:#000000
    style P2 fill:#81c784,color:#000000
    style P3 fill:#81c784,color:#000000
    style S1 fill:#ff9800,color:#000000
    style ALB fill:#ff6f00,color:#ffffff
    style SG fill:#d32f2f,color:#ffffff
    style N1 fill:#9c27b0,color:#ffffff
    style N2 fill:#9c27b0,color:#ffffff
    style N3 fill:#9c27b0,color:#ffffff
    style U1 fill:#e1f5fe,color:#000000
```

**특징**:
- AWS ALB를 통한 외부 접근
- 자동 Health Check
- 보안 그룹 설정 필요
- 고가용성 및 확장성

### 🔧 5단계: GKE GLB LoadBalancer

```mermaid
flowchart TD
    subgraph "GCP GKE Cluster"
        subgraph "day1-practice Namespace"
            D1["Deployment: myapp-deployment<br/>Replicas: 3"]
            P1["Pod: myapp-xxx-1<br/>nginx:1.21"]
            P2["Pod: myapp-xxx-2<br/>nginx:1.21"]
            P3["Pod: myapp-xxx-3<br/>nginx:1.21"]
            S1["Service: myapp-service-gke-lb<br/>Type: LoadBalancer<br/>Port: 80"]
        end
        
        subgraph "Worker Nodes"
            N1["Node 1<br/>Private IP"]
            N2["Node 2<br/>Private IP"]
            N3["Node 3<br/>Private IP"]
        end
    end
    
    subgraph "GCP Load Balancer"
        GLB["Google Load Balancer<br/>External IP<br/>Global/Regional"]
    end
    
    subgraph "Firewall Rules"
        FW["Firewall Rules<br/>Port 80, 443<br/>0.0.0.0/0"]
    end
    
    subgraph "External"
        U1["사용자"]
    end
    
    D1 --> P1
    D1 --> P2
    D1 --> P3
    S1 --> P1
    S1 --> P2
    S1 --> P3
    
    P1 --> N1
    P2 --> N2
    P3 --> N3
    
    GLB --> S1
    GLB --> FW
    
    U1 -->|"http://GLB-IP"| GLB
    
    style D1 fill:#4caf50,color:#ffffff
    style P1 fill:#81c784,color:#000000
    style P2 fill:#81c784,color:#000000
    style P3 fill:#81c784,color:#000000
    style S1 fill:#ff9800,color:#000000
    style GLB fill:#1976d2,color:#ffffff
    style FW fill:#d32f2f,color:#ffffff
    style N1 fill:#9c27b0,color:#ffffff
    style N2 fill:#9c27b0,color:#ffffff
    style N3 fill:#9c27b0,color:#ffffff
    style U1 fill:#e1f5fe,color:#000000
```

**특징**:
- GCP GLB를 통한 외부 접근
- Global 또는 Regional 설정 가능
- 방화벽 규칙 설정 필요
- Google Cloud 네이티브 통합

### 🔧 6단계: Ingress 설정 (EKS ALB)

```mermaid
flowchart TD
    subgraph "AWS EKS Cluster"
        subgraph "day1-practice Namespace"
            D1["Deployment: myapp-deployment<br/>Replicas: 3"]
            P1["Pod: myapp-xxx-1<br/>nginx:1.21"]
            P2["Pod: myapp-xxx-2<br/>nginx:1.21"]
            P3["Pod: myapp-xxx-3<br/>nginx:1.21"]
            S1["Service: myapp-service<br/>Type: ClusterIP<br/>Port: 80"]
            I1["Ingress: myapp-ingress<br/>Host: myapp.example.com<br/>Path: /"]
        end
        
        subgraph "Worker Nodes"
            N1["Node 1<br/>Private IP"]
            N2["Node 2<br/>Private IP"]
            N3["Node 3<br/>Private IP"]
        end
    end
    
    subgraph "AWS Load Balancer"
        ALB["Application Load Balancer<br/>External IP<br/>Host-based Routing"]
    end
    
    subgraph "Security Groups"
        SG["Security Group<br/>Port 80, 443<br/>0.0.0.0/0"]
    end
    
    subgraph "External"
        U1["사용자"]
        DNS["DNS: myapp.example.com"]
    end
    
    D1 --> P1
    D1 --> P2
    D1 --> P3
    S1 --> P1
    S1 --> P2
    S1 --> P3
    I1 --> S1
    
    P1 --> N1
    P2 --> N2
    P3 --> N3
    
    ALB --> I1
    ALB --> SG
    
    DNS --> ALB
    U1 -->|"http://myapp.example.com"| DNS
    
    style D1 fill:#4caf50,color:#ffffff
    style P1 fill:#81c784,color:#000000
    style P2 fill:#81c784,color:#000000
    style P3 fill:#81c784,color:#000000
    style S1 fill:#ff9800,color:#000000
    style I1 fill:#3f51b5,color:#ffffff
    style ALB fill:#ff6f00,color:#ffffff
    style SG fill:#d32f2f,color:#ffffff
    style N1 fill:#9c27b0,color:#ffffff
    style N2 fill:#9c27b0,color:#ffffff
    style N3 fill:#9c27b0,color:#ffffff
    style U1 fill:#e1f5fe,color:#000000
    style DNS fill:#e8f5e8,color:#000000
```

**특징**:
- Host 기반 라우팅
- Path 기반 라우팅 가능
- SSL/TLS 종료 지원
- 고급 로드 밸런싱 기능

## 🔄 아키텍처 진화 요약

### 📊 단계별 비교

| 단계 | 접근 방식 | 특징 | 장점 | 단점 |
|------|-----------|------|------|------|
| 1단계 | Pod만 | 외부 접근 불가 | 단순함 | 고가용성 없음 |
| 2단계 | ClusterIP | 클러스터 내부만 | 안전함 | 외부 접근 불가 |
| 3단계 | NodePort | 노드 IP:포트 | 간단한 외부 접근 | 방화벽 설정 필요 |
| 4단계 | EKS ALB | AWS LoadBalancer | AWS 네이티브 | AWS 의존성 |
| 5단계 | GKE GLB | GCP LoadBalancer | GCP 네이티브 | GCP 의존성 |
| 6단계 | Ingress | 고급 라우팅 | 유연한 라우팅 | 복잡한 설정 |

### 🎯 선택 가이드

#### 개발 환경
- **로컬 테스트**: Pod + ClusterIP
- **팀 공유**: NodePort
- **CI/CD**: Ingress

#### 프로덕션 환경
- **AWS**: EKS + ALB + Ingress
- **GCP**: GKE + GLB + Ingress
- **멀티 클라우드**: Ingress + CDN

### 🛠️ 자동화 도구 활용

```bash
# 아키텍처 단계별 자동 배포
./day1-practice.sh

# 1. K8s 클러스터 컨텍스트 구성 및 체크
# 2. 클러스터 전환 (EKS ↔ GKE)
# 3-6. Pod, Deployment, Service, ConfigMap/Secret
# 7. 전체 K8s 리소스 배포
# 8. LoadBalancer 서비스 배포 (EKS ALB / GKE GLB)
# 9. NodePort 서비스 배포
# 10. Ingress 설정
# 11. 포트 포워딩 테스트
# 12. 리소스 상태 확인
```

### 📈 성능 및 비용 고려사항

#### 성능
- **Pod**: 단일 인스턴스, 빠른 시작
- **Deployment**: 고가용성, 자동 복구
- **LoadBalancer**: 외부 접근, 로드 밸런싱
- **Ingress**: 고급 라우팅, SSL 종료

#### 비용
- **Pod**: 무료 (클러스터 내)
- **NodePort**: 무료 (클러스터 내)
- **LoadBalancer**: 클라우드 비용 발생
- **Ingress**: 추가 리소스 비용

---

**💡 각 아키텍처 단계는 이전 단계를 기반으로 구축됩니다!**  
**요구사항에 맞는 적절한 단계를 선택하여 사용하세요.**
