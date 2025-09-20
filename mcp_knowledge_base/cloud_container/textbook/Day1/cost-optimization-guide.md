# 비용 최적화 전략 가이드


## 🎯 학습 목표

[🎯 학습 목표](#학습-목표)

이 가이드를 통해 다음을 학습합니다:
- 클라우드 비용 구조 이해
- 리소스 사용량 모니터링 및 분석
- 자동 스케일링을 통한 비용 절감
- 스팟 인스턴스 및 예약 인스턴스 활용
- 실제 비용 최적화 시나리오 구현

---

## 📋 목차

[📋 목차](#목차)

1. [클라우드 비용 구조](#클라우드-비용-구조)
2. [리소스 모니터링 및 분석](#리소스-모니터링-및-분석)
3. [자동 스케일링 최적화](#자동-스케일링-최적화)
4. [인스턴스 타입 최적화](#인스턴스-타입-최적화)
5. [스토리지 비용 최적화](#스토리지-비용-최적화)
6. [네트워크 비용 최적화](#네트워크-비용-최적화)
7. [실습 시나리오](#실습-시나리오)

---

## 💰 클라우드 비용 구조

### AWS 비용 구조

[AWS 비용 구조](#aws-비용-구조)

#### EC2 비용 요소

[EC2 비용 요소](#ec2-비용-요소)
- **인스턴스 비용**: 인스턴스 타입, 리전, 사용 시간
- **스토리지 비용**: EBS 볼륨, 스냅샷, 데이터 전송
- **네트워크 비용**: 데이터 전송, 로드 밸런서, NAT Gateway
- **기타 서비스**: RDS, ElastiCache, CloudWatch

#### EKS 비용 요소

[EKS 비용 요소](#eks-비용-요소)
- **클러스터 비용**: $0.10/시간 (제어 평면)
- **워커 노드 비용**: EC2 인스턴스 비용
- **스토리지 비용**: EBS 볼륨, EFS
- **네트워크 비용**: ALB, NLB, 데이터 전송

### GCP 비용 구조

[GCP 비용 구조](#gcp-비용-구조)

#### GKE 비용 요소

[GKE 비용 요소](#gke-비용-요소)
- **클러스터 비용**: $0.10/시간 (제어 평면)
- **워커 노드 비용**: Compute Engine 인스턴스 비용
- **스토리지 비용**: Persistent Disk, Cloud Storage
- **네트워크 비용**: Load Balancer, Cloud NAT

#### Cloud Run 비용 요소

[Cloud Run 비용 요소](#cloud-run-비용-요소)
- **CPU 비용**: vCPU-초 단위
- **메모리 비용**: GB-초 단위
- **요청 비용**: 요청 수 단위
- **네트워크 비용**: 데이터 전송

---

## 📊 리소스 모니터링 및 분석

### AWS Cost Explorer 설정

[AWS Cost Explorer 설정](#aws-cost-explorer-설정)

#### 비용 분석 대시보드

[비용 분석 대시보드](#비용-분석-대시보드)
```yaml
# cost-analysis-dashboard.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cost-analysis-dashboard
  namespace: container-demo
data:
  cost-analysis.json: |
    {
      "dashboard": {
        "title": "Cost Analysis Dashboard",
        "panels": [
          {
            "title": "Daily Cost Trend",
            "type": "graph",
            "targets": [
              {
                "expr": "aws_billing_estimated_charges_usd",
                "legendFormat": "Daily Cost"
              }
            ]
          },
          {
            "title": "Service Cost Breakdown",
            "type": "piechart",
            "targets": [
              {
                "expr": "aws_billing_estimated_charges_by_service",
                "legendFormat": "{{service}}"
              }
            ]
          },
          {
            "title": "Resource Utilization",
            "type": "graph",
            "targets": [
              {
                "expr": "rate(container_cpu_usage_seconds_total[5m])",
                "legendFormat": "CPU Usage"
              },
              {
                "expr": "container_memory_usage_bytes",
                "legendFormat": "Memory Usage"
              }
            ]
          }
        ]
      }
    }
```

### GCP Cost Management 설정

[GCP Cost Management 설정](#gcp-cost-management-설정)

#### 비용 분석 쿼리

[비용 분석 쿼리](#비용-분석-쿼리)
```sql
-- GCP BigQuery 비용 분석 쿼리
SELECT
  service.description as service_name,
  sku.description as sku_name,
  location.location as location,
  SUM(cost) as total_cost,
  SUM(usage_amount) as total_usage
FROM
  `project-id.billing_export.gcp_billing_export_v1_BILLING_ACCOUNT_ID`
WHERE
  _PARTITIONTIME >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
GROUP BY
  service_name,
  sku_name,
  location
ORDER BY
  total_cost DESC
```

### Prometheus 비용 메트릭

[Prometheus 비용 메트릭](#prometheus-비용-메트릭)

#### 비용 메트릭 수집

[비용 메트릭 수집](#비용-메트릭-수집)
```yaml
# cost-metrics.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cost-metrics
  namespace: container-demo
data:
  cost-metrics.yml: |
    groups:
    - name: cost_optimization
      rules:
      - alert: HighCostUsage
        expr: aws_billing_estimated_charges_usd > 100
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High cost usage detected"
          description: "Daily cost is {{ $value }} USD"
      
      - alert: ResourceWaste
        expr: container_cpu_usage_seconds_total < 0.1 and container_memory_usage_bytes < 100000000
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Resource waste detected"
          description: "Pod {{ $labels.pod }} has low resource utilization"
```

---

## 📈 자동 스케일링 최적화

### HPA 최적화 설정

[HPA 최적화 설정](#hpa-최적화-설정)

#### 비용 효율적인 HPA

[비용 효율적인 HPA](#비용-효율적인-hpa)
```yaml
# cost-optimized-hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: cost-optimized-hpa
  namespace: container-demo
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: container-demo
  minReplicas: 2
  maxReplicas: 20
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
      - type: Pods
        value: 2
        periodSeconds: 60
      selectPolicy: Max
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
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: "100"
```

### VPA 최적화 설정

[VPA 최적화 설정](#vpa-최적화-설정)

#### 리소스 최적화 VPA

[리소스 최적화 VPA](#리소스-최적화-vpa)
```yaml
# cost-optimized-vpa.yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: cost-optimized-vpa
  namespace: container-demo
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: container-demo
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: container-demo
      minAllowed:
        cpu: 100m
        memory: 128Mi
      maxAllowed:
        cpu: 1000m
        memory: 1Gi
      controlledResources: ["cpu", "memory"]
      controlledValues: RequestsAndLimits
```

---

## 🖥️ 인스턴스 타입 최적화

### 스팟 인스턴스 활용

[스팟 인스턴스 활용](#스팟-인스턴스-활용)

#### AWS Spot Instance 설정

[AWS Spot Instance 설정](#aws-spot-instance-설정)
```yaml
# spot-instance-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: container-demo-spot
  namespace: container-demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: container-demo
  template:
    metadata:
      labels:
        app: container-demo
        node-type: spot
    spec:
      nodeSelector:
        node.kubernetes.io/instance-type: "spot"
      containers:
      - name: container-demo
        image: gcr.io/PROJECT_ID/container-demo:latest
        ports:
        - containerPort: 3000
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        # 스팟 인스턴스 종료 대비
        env:
        - name: SPOT_INSTANCE
          value: "true"
        - name: GRACEFUL_SHUTDOWN
          value: "true"
```

#### GCP Preemptible Instance 설정

[GCP Preemptible Instance 설정](#gcp-preemptible-instance-설정)
```yaml
# preemptible-instance-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: container-demo-preemptible
  namespace: container-demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: container-demo
  template:
    metadata:
      labels:
        app: container-demo
        node-type: preemptible
    spec:
      nodeSelector:
        cloud.google.com/gke-preemptible: "true"
      containers:
      - name: container-demo
        image: gcr.io/PROJECT_ID/container-demo:latest
        ports:
        - containerPort: 3000
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        env:
        - name: PREEMPTIBLE_INSTANCE
          value: "true"
        - name: GRACEFUL_SHUTDOWN
          value: "true"
```

### 예약 인스턴스 활용

[예약 인스턴스 활용](#예약-인스턴스-활용)

#### AWS Reserved Instance 설정

[AWS Reserved Instance 설정](#aws-reserved-instance-설정)
```bash
# Reserved Instance 구매 (CLI)
aws ec2 purchase-reserved-instances-offering /
  --reserved-instances-offering-id <offering-id> /
  --instance-count 3 /
  --instance-type t3.medium
```

#### GCP Committed Use Discount 설정

[GCP Committed Use Discount 설정](#gcp-committed-use-discount-설정)
```bash
# Committed Use Discount 생성
gcloud compute commitments create container-demo-commitment /
  --plan 12-month /
  --resources vcpu=6,memory=24 /
  --region asia-northeast3
```

---

## 💾 스토리지 비용 최적화

### 스토리지 클래스 최적화

[스토리지 클래스 최적화](#스토리지-클래스-최적화)

#### AWS EBS 최적화

[AWS EBS 최적화](#aws-ebs-최적화)
```yaml
# ebs-optimized-storage.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: container-demo-pvc
  namespace: container-demo
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: gp3
  resources:
    requests:
      storage: 20Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: container-demo-pvc-io1
  namespace: container-demo
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: io1
  resources:
    requests:
      storage: 10Gi
      iops: "1000"
```

#### GCP Persistent Disk 최적화

[GCP Persistent Disk 최적화](#gcp-persistent-disk-최적화)
```yaml
# gcp-optimized-storage.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: container-demo-pvc
  namespace: container-demo
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: pd-standard
  resources:
    requests:
      storage: 20Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: container-demo-pvc-ssd
  namespace: container-demo
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: pd-ssd
  resources:
    requests:
      storage: 10Gi
```

### 스토리지 라이프사이클 관리

[스토리지 라이프사이클 관리](#스토리지-라이프사이클-관리)

#### AWS S3 라이프사이클 설정

[AWS S3 라이프사이클 설정](#aws-s3-라이프사이클-설정)
```json
{
  "Rules": [
    {
      "ID": "ContainerDemoLifecycle",
      "Status": "Enabled",
      "Transitions": [
        {
          "Days": 30,
          "StorageClass": "STANDARD_IA"
        },
        {
          "Days": 90,
          "StorageClass": "GLACIER"
        },
        {
          "Days": 365,
          "StorageClass": "DEEP_ARCHIVE"
        }
      ]
    }
  ]
}
```

#### GCP Cloud Storage 라이프사이클 설정

[GCP Cloud Storage 라이프사이클 설정](#gcp-cloud-storage-라이프사이클-설정)
```yaml
# gcp-lifecycle.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: gcp-lifecycle-config
  namespace: container-demo
data:
  lifecycle.json: |
    {
      "lifecycle": {
        "rule": [
          {
            "action": {
              "type": "SetStorageClass",
              "storageClass": "NEARLINE"
            },
            "condition": {
              "age": 30
            }
          },
          {
            "action": {
              "type": "SetStorageClass",
              "storageClass": "COLDLINE"
            },
            "condition": {
              "age": 90
            }
          },
          {
            "action": {
              "type": "SetStorageClass",
              "storageClass": "ARCHIVE"
            },
            "condition": {
              "age": 365
            }
          }
        ]
      }
    }
```

---

## 🌐 네트워크 비용 최적화

### 네트워크 최적화 설정

[네트워크 최적화 설정](#네트워크-최적화-설정)

#### AWS 네트워크 최적화

[AWS 네트워크 최적화](#aws-네트워크-최적화)
```yaml
# aws-network-optimization.yaml
apiVersion: v1
kind: Service
metadata:
  name: container-demo-service
  namespace: container-demo
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
spec:
  type: LoadBalancer
  selector:
    app: container-demo
  ports:
  - port: 80
    targetPort: 3000
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: container-demo-ingress
  namespace: container-demo
  annotations:
    kubernetes.io/ingress.class: "alb"
    alb.ingress.kubernetes.io/scheme: "internal"
    alb.ingress.kubernetes.io/target-type: "ip"
spec:
  rules:
  - host: container-demo.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: container-demo-service
            port:
              number: 80
```

#### GCP 네트워크 최적화

[GCP 네트워크 최적화](#gcp-네트워크-최적화)
```yaml
# gcp-network-optimization.yaml
apiVersion: v1
kind: Service
metadata:
  name: container-demo-service
  namespace: container-demo
  annotations:
    cloud.google.com/neg: '{"ingress": true}'
spec:
  type: LoadBalancer
  selector:
    app: container-demo
  ports:
  - port: 80
    targetPort: 3000
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: container-demo-ingress
  namespace: container-demo
  annotations:
    kubernetes.io/ingress.class: "gce"
    kubernetes.io/ingress.global-static-ip-name: "container-demo-ip"
spec:
  rules:
  - host: container-demo.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: container-demo-service
            port:
              number: 80
```

---

## 🚀 실습 시나리오

### 시나리오 1: 기본 비용 최적화

[시나리오 1: 기본 비용 최적화](#시나리오-1-기본-비용-최적화)

#### 1단계: 리소스 모니터링 설정

[1단계: 리소스 모니터링 설정](#1단계-리소스-모니터링-설정)
```bash
# 비용 분석 대시보드 배포
kubectl apply -f cost-optimization-guide/cost-analysis-dashboard.yaml

# Prometheus 비용 메트릭 설정
kubectl apply -f cost-optimization-guide/cost-metrics.yaml
```

#### 2단계: HPA 최적화

[2단계: HPA 최적화](#2단계-hpa-최적화)
```bash
# 비용 효율적인 HPA 배포
kubectl apply -f cost-optimization-guide/cost-optimized-hpa.yaml

# HPA 상태 확인
kubectl get hpa -n container-demo
```

#### 3단계: VPA 최적화

[3단계: VPA 최적화](#3단계-vpa-최적화)
```bash
# VPA 배포
kubectl apply -f cost-optimization-guide/cost-optimized-vpa.yaml

# VPA 상태 확인
kubectl get vpa -n container-demo
```

### 시나리오 2: 스팟 인스턴스 활용

[시나리오 2: 스팟 인스턴스 활용](#시나리오-2-스팟-인스턴스-활용)

#### 1단계: 스팟 인스턴스 노드 그룹 생성

[1단계: 스팟 인스턴스 노드 그룹 생성](#1단계-스팟-인스턴스-노드-그룹-생성)
```bash
# AWS EKS 스팟 인스턴스 노드 그룹 생성
eksctl create nodegroup /
  --cluster=container-demo-cluster /
  --name=spot-nodes /
  --node-type=t3.medium /
  --nodes=3 /
  --nodes-min=1 /
  --nodes-max=10 /
  --spot /
  --asg-access

# GCP GKE 스팟 인스턴스 노드 풀 생성
gcloud container node-pools create spot-pool /
  --cluster=container-demo-cluster /
  --zone=asia-northeast3-a /
  --num-nodes=3 /
  --spot /
  --machine-type=e2-medium
```

#### 2단계: 스팟 인스턴스 배포

[2단계: 스팟 인스턴스 배포](#2단계-스팟-인스턴스-배포)
```bash
# 스팟 인스턴스에 Pod 배포
kubectl apply -f cost-optimization-guide/spot-instance-deployment.yaml

# Pod 분산 확인
kubectl get pods -o wide -n container-demo
```

### 시나리오 3: 스토리지 비용 최적화

[시나리오 3: 스토리지 비용 최적화](#시나리오-3-스토리지-비용-최적화)

#### 1단계: 스토리지 클래스 최적화

[1단계: 스토리지 클래스 최적화](#1단계-스토리지-클래스-최적화)
```bash
# AWS EBS 최적화 스토리지 배포
kubectl apply -f cost-optimization-guide/ebs-optimized-storage.yaml

# GCP Persistent Disk 최적화 스토리지 배포
kubectl apply -f cost-optimization-guide/gcp-optimized-storage.yaml
```

#### 2단계: 스토리지 라이프사이클 설정

[2단계: 스토리지 라이프사이클 설정](#2단계-스토리지-라이프사이클-설정)
```bash
# AWS S3 라이프사이클 설정
aws s3api put-bucket-lifecycle-configuration /
  --bucket container-demo-bucket /
  --lifecycle-configuration file://lifecycle.json

# GCP Cloud Storage 라이프사이클 설정
gsutil lifecycle set lifecycle.json gs://container-demo-bucket
```

---

## 📊 비용 최적화 모니터링

[📊 비용 최적화 모니터링](#비용-최적화-모니터링)

### 비용 알림 설정

[비용 알림 설정](#비용-알림-설정)

#### AWS Cost Anomaly Detection

[AWS Cost Anomaly Detection](#aws-cost-anomaly-detection)
```yaml
# cost-anomaly-detection.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cost-anomaly-detection
  namespace: container-demo
data:
  anomaly-detection.json: |
    {
      "AnomalyDetector": {
        "AnomalyDetectorName": "container-demo-anomaly",
        "MonitorType": "DIMENSIONAL",
        "Dimension": "SERVICE",
        "MatchOptions": ["EQUALS"],
        "Values": ["Amazon Elastic Compute Cloud - Compute"]
      }
    }
```

#### GCP Cost Alert 설정

[GCP Cost Alert 설정](#gcp-cost-alert-설정)
```yaml
# gcp-cost-alert.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: gcp-cost-alert
  namespace: container-demo
data:
  cost-alert.json: |
    {
      "budget": {
        "displayName": "Container Demo Budget",
        "budgetFilter": {
          "projects": ["projects/PROJECT_ID"]
        },
        "amount": {
          "specifiedAmount": {
            "currencyCode": "USD",
            "units": "100"
          }
        },
        "thresholdRules": [
          {
            "thresholdPercent": 0.5,
            "spendBasis": "CURRENT_SPEND"
          },
          {
            "thresholdPercent": 0.8,
            "spendBasis": "CURRENT_SPEND"
          }
        ]
      }
    }
```

---

## ✅ 체크리스트

[✅ 체크리스트](#체크리스트)

### 기본 비용 최적화

[기본 비용 최적화](#기본-비용-최적화)
- [ ] 리소스 모니터링 설정
- [ ] HPA 최적화
- [ ] VPA 최적화
- [ ] 비용 분석 대시보드 구성

### 고급 비용 최적화

[고급 비용 최적화](#고급-비용-최적화)
- [ ] 스팟 인스턴스 활용
- [ ] 예약 인스턴스 활용
- [ ] 스토리지 클래스 최적화
- [ ] 네트워크 비용 최적화

### 비용 모니터링

[비용 모니터링](#비용-모니터링)
- [ ] 비용 알림 설정
- [ ] 비용 분석 쿼리 작성
- [ ] 비용 최적화 리포트 생성
- [ ] 비용 예측 모델 구축

---

## 📚 참고 자료

[📚 참고 자료](#참고-자료)

### 공식 문서

[공식 문서](#공식-문서)
- [AWS Cost Optimization 공식 문서](https:///aws.amazon.com/pricing/cost-optimization/)
- [GCP Cost Optimization 공식 문서](https:///cloud.google.com/cost-optimization)
- [Kubernetes Resource Management 공식 문서](https:///kubernetes.io/docs/concepts/configuration/manage-resources-containers/)

### 추가 학습 자료

[추가 학습 자료](#추가-학습-자료)
- [자동 복구 가이드](cloud_container/textbook/Day1/auto-recovery-guide.md)
- [보안 정책 가이드](cloud_container/textbook/Day1/security-policies-guide.md)
- [종합 실습 가이드](cloud_container/textbook/Day1/comprehensive-practice-guide.md)

---

**💡 팁**: 비용 최적화는 지속적인 모니터링과 조정이 필요합니다. 정기적으로 비용을 분석하고 최적화 전략을 업데이트하여 효율적인 클라우드 운영을 유지하세요!


---


### 📧 연락처

[📧 연락처](#연락처)
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: [프로젝트 저장소](https:///github.com/jungfrau70/aws_gcp.git)

---



<div align="center">

[← 이전: Cloud Container 1일차 메인](README.md) | [📚 전체 커리큘럼](curriculum.md) | [🏠 학습 경로로 돌아가기](index.md) | [📋 학습 경로](learning-path.md)

</div>