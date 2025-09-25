
# 2교시: 클라우드 과금 예측 및 리소스 비용 최적화 실습



## 📋 목차

["📋 목차"]["#목차"]
1. ["비용 예측 개념 이해"]["#비용-예측-개념-이해"]
2. ["비용 관리 도구 활용"]["#비용-관리-도구-활용"]
3. ["비용 최적화 전략"]["#비용-최적화-전략"]
4. ["권장사항 도구 활용"]["#권장사항-도구-활용"]
5. ["실습 목표"]["#실습-목표"]
6. ["실습 절차"]["#실습-절차"]
7. ["실습 코드 예시"]["#실습-코드-예시"]
8. ["예상 결과"]["#예상-결과"]
9. ["혼자 해보기"]["#혼자-해보기"]

---

## 📊 비용 예측 개념 이해

### 비용 예측의 중요성

["비용 예측의 중요성"]["#비용-예측의-중요성"]

클라우드 사용량과 비용을 정확히 예측하고 관리하는 것은 **운영 비용 절감과 서비스 안정성 확보에 필수적**입니다.

#### 1. **과거 데이터 분석**

["1. **과거 데이터 분석**"]["#1-과거-데이터-분석"]
- 지난 12개월의 비용과 사용 데이터 분석
- 계절성 및 트렌드 파악
- 비정상적인 비용 증가 패턴 식별

#### 2. **미래 지출 예측**

["2. **미래 지출 예측**"]["#2-미래-지출-예측"]
- 향후 12개월 예측치 제공
- 서비스 확장에 따른 비용 증가 예측
- 예산 계획 수립 지원

#### 3. **비용 최적화 기회**

["3. **비용 최적화 기회**"]["#3-비용-최적화-기회"]
- 불필요한 리소스 식별
- 할인 옵션 적용 기회 발견
- 비용 효율적인 아키텍처 설계

### 비용 예측 프로세스

["비용 예측 프로세스"]["#비용-예측-프로세스"]

```mermaid
flowchart TB
    A["과거 데이터 수집"] -->> B["데이터 분석"]
    B -->> C["트렌드 파악"]
    C -->> D["예측 모델 생성"]
    D -->> E["미래 비용 예측"]
    E -->> F["예산 계획 수립"]
    F -->> G["비용 최적화 실행"]
    G -->> H["성과 모니터링"]
    H -->> A
```

---

## 🛠️ 비용 관리 도구 활용

### AWS Cost Explorer

[AWS Cost Explorer][#aws-cost-explorer]

#### 1. **기본 기능**

["1. **기본 기능**"]["#1-기본-기능"]
- **비용 시각화**: 그래프와 차트로 비용 데이터 시각화
- **비용 분석**: 서비스, 리전, 인스턴스 타입별 비용 분석
- **예측 기능**: 향후 12개월 비용 예측
- **예약 인스턴스 권장**: 비용 절감을 위한 RI 권장

#### 2. **주요 메트릭**

["2. **주요 메트릭**"]["#2-주요-메트릭"]
- **Blended Cost**: 계정 전체의 평균 비용
- **Unblended Cost**: 실제 사용한 리소스의 비용
- **Net Unblended Cost**: 크레딧과 할인을 적용한 순 비용
- **Amortized Cost**: 예약 인스턴스 비용을 월별로 분할

#### 3. **비용 분석 차원**

["3. **비용 분석 차원**"]["#3-비용-분석-차원"]
- **서비스별**: EC2, RDS, S3 등 서비스별 비용
- **리전별**: 리전별 비용 분포
- **인스턴스 타입별**: 인스턴스 타입별 비용
- **태그별**: 사용자 정의 태그별 비용

### GCP Cloud Billing Reports

[GCP Cloud Billing Reports][#gcp-cloud-billing-reports]

#### 1. **기본 기능**

["1. **기본 기능**"]["#1-기본-기능"]
- **비용 시각화**: 대시보드로 비용 데이터 시각화
- **비용 분석**: 프로젝트, 서비스, 리전별 비용 분석
- **예측 기능**: 향후 비용 예측
- **권장사항**: 비용 절감을 위한 권장사항

#### 2. **주요 메트릭**

["2. **주요 메트릭**"]["#2-주요-메트릭"]
- **Total Cost**: 총 비용
- **Net Cost**: 크레딧과 할인을 적용한 순 비용
- **Credits**: 적용된 크레딧
- **Tax**: 세금

#### 3. **비용 분석 차원**

["3. **비용 분석 차원**"]["#3-비용-분석-차원"]
- **프로젝트별**: 프로젝트별 비용 분포
- **서비스별**: Compute Engine, Cloud SQL 등 서비스별 비용
- **리전별**: 리전별 비용 분포
- **라벨별**: 사용자 정의 라벨별 비용

### 비용 관리 도구 비교

["비용 관리 도구 비교"]["#비용-관리-도구-비교"]

| 기능 | AWS Cost Explorer | GCP Cloud Billing Reports |
|------|-------------------|---------------------------|
| **비용 시각화** | ✅ | ✅ |
| **예측 기능** | ✅ | ✅ |
| **예약 인스턴스 권장** | ✅ | ✅ |
| **태그/라벨 분석** | ✅ | ✅ |
| **API 지원** | ✅ | ✅ |
| **내보내기** | CSV, JSON | CSV, JSON |

---

## 💡 비용 최적화 전략

### 1. 리소스 최적화

["1. 리소스 최적화"]["#1-리소스-최적화"]

#### 미사용 리소스 식별

["미사용 리소스 식별"]["#미사용-리소스-식별"]
- **Idle EC2 인스턴스**: CPU 사용률이 낮은 인스턴스
- **미사용 EBS 볼륨**: 연결되지 않은 스토리지
- **미사용 Elastic IP**: 연결되지 않은 IP 주소
- **미사용 로드 밸런서**: 트래픽이 없는 로드 밸런서

#### 리소스 크기 최적화

["리소스 크기 최적화"]["#리소스-크기-최적화"]
- **인스턴스 타입 변경**: 더 적합한 인스턴스 타입으로 변경
- **스토리지 최적화**: 적절한 스토리지 타입 선택
- **네트워크 최적화**: 불필요한 데이터 전송 최소화

### 2. 할인 옵션 활용

["2. 할인 옵션 활용"]["#2-할인-옵션-활용"]

#### AWS 할인 옵션

["AWS 할인 옵션"]["#aws-할인-옵션"]
- **Reserved Instances**: 1년/3년 약정으로 최대 75% 할인
- **Savings Plans**: 컴퓨팅 사용량 기반 할인
- **Spot Instances**: 미사용 인스턴스 최대 90% 할인
- **Volume Discounts**: 대량 사용 시 할인

#### GCP 할인 옵션

["GCP 할인 옵션"]["#gcp-할인-옵션"]
- **Committed Use Discounts**: 1년/3년 약정으로 최대 57% 할인
- **Sustained Use Discounts**: 자동 할인 ["최대 30%"]
- **Preemptible Instances**: 미사용 인스턴스 최대 80% 할인
- **Volume Discounts**: 대량 사용 시 할인

### 3. 아키텍처 최적화

["3. 아키텍처 최적화"]["#3-아키텍처-최적화"]

#### 서버리스 아키텍처

["서버리스 아키텍처"]["#서버리스-아키텍처"]
- **AWS Lambda**: 요청 기반 과금
- **GCP Cloud Functions**: 요청 기반 과금
- **AWS API Gateway**: API 호출 기반 과금
- **GCP Cloud Endpoints**: API 호출 기반 과금

#### 컨테이너 최적화

["컨테이너 최적화"]["#컨테이너-최적화"]
- **AWS ECS Fargate**: 서버리스 컨테이너
- **GCP Cloud Run**: 서버리스 컨테이너
- **AWS EKS**: 관리형 Kubernetes
- **GCP GKE**: 관리형 Kubernetes

### 비용 최적화 전략 다이어그램

["비용 최적화 전략 다이어그램"]["#비용-최적화-전략-다이어그램"]

```mermaid
flowchart TB
    A["비용 최적화"] -->> B["리소스 최적화"]
    A -->> C["할인 옵션 활용"]
    A -->> D["아키텍처 최적화"]
    
    B -->> B1["미사용 리소스 제거"]
    B -->> B2["리소스 크기 조정"]
    B -->> B3["스토리지 최적화"]
    
    C -->> C1["예약 인스턴스"]
    C -->> C2["스팟 인스턴스"]
    C -->> C3["볼륨 할인"]
    
    D -->> D1["서버리스 아키텍처"]
    D -->> D2["컨테이너 최적화"]
    D -->> D3["자동 스케일링"]
```

---

## 🔍 권장사항 도구 활용

### AWS Trusted Advisor

[AWS Trusted Advisor][#aws-trusted-advisor]

#### 1. **비용 최적화 권장사항**

["1. **비용 최적화 권장사항**"]["#1-비용-최적화-권장사항"]
- **Idle Load Balancers**: 사용하지 않는 로드 밸런서
- **Underutilized EBS Volumes**: 사용률이 낮은 EBS 볼륨
- **Unassociated Elastic IP Addresses**: 연결되지 않은 Elastic IP
- **Idle DB Instances**: 사용하지 않는 RDS 인스턴스

#### 2. **성능 권장사항**

["2. **성능 권장사항**"]["#2-성능-권장사항"]
- **High Utilization Amazon EBS Magnetic Volumes**: 높은 사용률의 EBS 볼륨
- **Over-provisioned Amazon EBS Volumes**: 과도하게 프로비저닝된 EBS 볼륨
- **Underutilized Amazon EBS Volumes**: 사용률이 낮은 EBS 볼륨

#### 3. **보안 권장사항**

["3. **보안 권장사항**"]["#3-보안-권장사항"]
- **Security Groups**: 보안 그룹 설정
- **IAM Access**: IAM 접근 권한
- **MFA**: 다중 인증 설정

### GCP Cloud Recommender

[GCP Cloud Recommender][#gcp-cloud-recommender]

#### 1. **비용 최적화 권장사항**

["1. **비용 최적화 권장사항**"]["#1-비용-최적화-권장사항"]
- **Machine Type Recommendations**: 인스턴스 타입 권장
- **Idle VM Recommendations**: 사용하지 않는 VM 권장
- **Commitment Recommendations**: 커밋 약정 권장
- **Snapshot Recommendations**: 스냅샷 최적화 권장

#### 2. **성능 권장사항**

["2. **성능 권장사항**"]["#2-성능-권장사항"]
- **Persistent Disk Recommendations**: 영구 디스크 권장
- **Network Recommendations**: 네트워크 최적화 권장
- **Security Recommendations**: 보안 최적화 권장

#### 3. **보안 권장사항**

["3. **보안 권장사항**"]["#3-보안-권장사항"]
- **IAM Recommendations**: IAM 권한 최적화
- **Firewall Recommendations**: 방화벽 규칙 최적화
- **SSL Certificate Recommendations**: SSL 인증서 최적화

### 권장사항 도구 비교

["권장사항 도구 비교"]["#권장사항-도구-비교"]

| 기능 | AWS Trusted Advisor | GCP Cloud Recommender |
|------|---------------------|----------------------|
| **비용 최적화** | ✅ | ✅ |
| **성능 최적화** | ✅ | ✅ |
| **보안 최적화** | ✅ | ✅ |
| **가용성 최적화** | ✅ | ✅ |
| **API 지원** | ✅ | ✅ |
| **무료 제공** | Basic ["제한적"] | ✅ |

---

## 🎯 실습 목표

이 실습을 통해 다음을 달성합니다:

1. **비용 예측**: AWS Cost Explorer와 GCP 비용 관리 도구를 사용하여 비용을 예측합니다.

2. **비용 최적화**: 불필요한 리소스를 찾아 비용을 최적화합니다.

3. **권장사항 활용**: Trusted Advisor와 Cloud Recommender를 활용하여 최적화 기회를 발견합니다.

4. **예산 관리**: 예산 설정 및 알림을 통해 비용을 관리합니다.

---

## 📝 실습 절차

### 1단계: AWS Cost Explorer 활성화 및 설정

["1단계: AWS Cost Explorer 활성화 및 설정"]["#1단계-aws-cost-explorer-활성화-및-설정"]

#### Cost Explorer 활성화

["Cost Explorer 활성화"]["#cost-explorer-활성화"]
```bash
# AWS 콘솔에서 Cost Explorer 활성화
# 1. AWS 콘솔 → Billing → Cost Explorer
# 2. "Enable Cost Explorer" 클릭
# 3. 24시간 후 데이터 사용 가능

# Cost Explorer API를 통한 비용 데이터 조회
aws ce get-cost-and-usage /
  --time-period Start=2024-01-01,End=2024-01-31 /
  --granularity MONTHLY /
  --metrics BlendedCost /
  --group-by Type=DIMENSION,Key=SERVICE
```

#### 비용 예측 설정

["비용 예측 설정"]["#비용-예측-설정"]
```bash
# 향후 3개월 비용 예측
aws ce get-cost-forecast /
  --time-period Start=2024-02-01,End=2024-04-30 /
  --metric BLENDED_COST /
  --granularity MONTHLY

# 서비스별 비용 예측
aws ce get-cost-and-usage /
  --time-period Start=2024-01-01,End=2024-01-31 /
  --granularity MONTHLY /
  --metrics BlendedCost /
  --group-by Type=DIMENSION,Key=SERVICE /
  --query "ResultsByTime[0].Groups[].{Service:Keys[0],Cost:Metrics.BlendedCost.Amount}"
```

### 2단계: AWS Budgets 설정

["2단계: AWS Budgets 설정"]["#2단계-aws-budgets-설정"]

#### 예산 생성

["예산 생성"]["#예산-생성"]
```bash
# 월별 비용 예산 생성
aws budgets create-budget /
  --account-id 123456789012 /
  --budget '{
    "BudgetName": "MonthlyCostBudget",
    "BudgetLimit": {
      "Amount": "500",
      "Unit": "USD"
    },
    "TimeUnit": "MONTHLY",
    "BudgetType": "COST",
    "CostFilters": {
      "Service": ["Amazon Elastic Compute Cloud - Compute", "Amazon Relational Database Service"]
    }
  }'

# 예산 알림 설정
aws budgets create-notification /
  --account-id 123456789012 /
  --budget-name "MonthlyCostBudget" /
  --notification '{
    "NotificationType": "ACTUAL",
    "ComparisonOperator": "GREATER_THAN",
    "Threshold": 80,
    "ThresholdType": "PERCENTAGE"
  }' /
  --subscribers '[
    {
      "SubscriptionType": "EMAIL",
      "Address": "admin@example.com"
    }
  ]'
```

### 3단계: AWS Trusted Advisor 권장사항 확인

["3단계: AWS Trusted Advisor 권장사항 확인"]["#3단계-aws-trusted-advisor-권장사항-확인"]

#### 비용 최적화 권장사항 조회

["비용 최적화 권장사항 조회"]["#비용-최적화-권장사항-조회"]
```bash
# Trusted Advisor 권장사항 조회 ["API 사용"]
aws support describe-trusted-advisor-checks /
  --language en

# 특정 체크 결과 조회
aws support describe-trusted-advisor-check-result /
  --check-id "HdwQ1EXAMPLE" /
  --language en

# 권장사항 요약 조회
aws support describe-trusted-advisor-check-summaries /
  --check-ids "HdwQ1EXAMPLE"
```

#### 미사용 리소스 식별

["미사용 리소스 식별"]["#미사용-리소스-식별"]
```bash
# 미사용 EC2 인스턴스 확인
aws ec2 describe-instances /
  --filters "Name=instance-state-name,Values=running" /
  --query "Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name,LaunchTime:LaunchTime}"

# 미사용 EBS 볼륨 확인
aws ec2 describe-volumes /
  --filters "Name=status,Values=available" /
  --query "Volumes[].{VolumeId:VolumeId,Size:Size,State:State}"

# 미사용 Elastic IP 확인
aws ec2 describe-addresses /
  --query "Addresses[?AssociationId==null].{PublicIp:PublicIp,AllocationId:AllocationId}"
```

### 4단계: GCP 비용 관리 도구 설정

["4단계: GCP 비용 관리 도구 설정"]["#4단계-gcp-비용-관리-도구-설정"]

#### Cloud Billing Reports 설정

["Cloud Billing Reports 설정"]["#cloud-billing-reports-설정"]
```bash
# 프로젝트별 비용 조회
gcloud alpha billing projects list /
  --billing-account=BILLING_ACCOUNT_ID

# 서비스별 비용 조회
gcloud logging read "resource.type=gce_instance" /
  --limit=100 /
  --format="table[timestamp,resource.labels.instance_name,severity]"
```

#### GCP Budgets 설정

["GCP Budgets 설정"]["#gcp-budgets-설정"]
```bash
# 예산 생성
gcloud alpha billing budgets create /
  --billing-account=BILLING_ACCOUNT_ID /
  --display-name="Monthly Cost Budget" /
  --budget-amount=500 /
  --threshold-rule=percent=0.8 /
  --threshold-rule=percent=1.0 /
  --filter-projects="projects/PROJECT_ID"

# 예산 알림 설정
gcloud alpha billing budgets create /
  --billing-account=BILLING_ACCOUNT_ID /
  --display-name="Monthly Cost Budget" /
  --budget-amount=500 /
  --threshold-rule=percent=0.8,spend-basis=FORECASTED /
  --threshold-rule=percent=1.0,spend-basis=ACTUAL /
  --notification-rule=pubsub-topic=projects/PROJECT_ID/topics/budget-alerts
```

### 5단계: GCP Cloud Recommender 활용

["5단계: GCP Cloud Recommender 활용"]["#5단계-gcp-cloud-recommender-활용"]

#### 권장사항 조회

["권장사항 조회"]["#권장사항-조회"]
```bash
# 인스턴스 타입 권장사항 조회
gcloud recommender recommendations list /
  --project=PROJECT_ID /
  --recommender=google.compute.instance.MachineTypeRecommender

# 미사용 VM 권장사항 조회
gcloud recommender recommendations list /
  --project=PROJECT_ID /
  --recommender=google.compute.instance.IdleResourceRecommender

# 커밋 약정 권장사항 조회
gcloud recommender recommendations list /
  --project=PROJECT_ID /
  --recommender=google.compute.commitment.UsageCommitmentRecommender
```

#### 권장사항 적용

["권장사항 적용"]["#권장사항-적용"]
```bash
# 인스턴스 타입 변경
gcloud compute instances set-machine-type INSTANCE_NAME /
  --machine-type=e2-medium /
  --zone=ZONE

# 미사용 VM 삭제
gcloud compute instances delete INSTANCE_NAME /
  --zone=ZONE /
  --quiet
```

---

## 💻 실습 코드 예시

### AWS 비용 최적화 스크립트

["AWS 비용 최적화 스크립트"]["#aws-비용-최적화-스크립트"]

#### 비용 분석 및 최적화

["비용 분석 및 최적화"]["#비용-분석-및-최적화"]
```bash
#!/bin/bash
# aws-cost-optimization.sh

echo "=== AWS 비용 최적화 분석 시작 ==="

# 1. 현재 월 비용 조회
echo "1. 현재 월 비용 조회"
aws ce get-cost-and-usage /
  --time-period Start=2024-01-01,End=2024-01-31 /
  --granularity MONTHLY /
  --metrics BlendedCost /
  --query "ResultsByTime[0].Total.BlendedCost.Amount"

# 2. 서비스별 비용 분석
echo "2. 서비스별 비용 분석"
aws ce get-cost-and-usage /
  --time-period Start=2024-01-01,End=2024-01-31 /
  --granularity MONTHLY /
  --metrics BlendedCost /
  --group-by Type=DIMENSION,Key=SERVICE /
  --query "ResultsByTime[0].Groups[].{Service:Keys[0],Cost:Metrics.BlendedCost.Amount}" /
  --output table

# 3. 미사용 리소스 식별
echo "3. 미사용 리소스 식별"

# 미사용 EC2 인스턴스
echo "미사용 EC2 인스턴스:"
aws ec2 describe-instances /
  --filters "Name=instance-state-name,Values=running" /
  --query "Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name,LaunchTime:LaunchTime}" /
  --output table

# 미사용 EBS 볼륨
echo "미사용 EBS 볼륨:"
aws ec2 describe-volumes /
  --filters "Name=status,Values=available" /
  --query "Volumes[].{VolumeId:VolumeId,Size:Size,State:State}" /
  --output table

# 미사용 Elastic IP
echo "미사용 Elastic IP:"
aws ec2 describe-addresses /
  --query "Addresses[?AssociationId==null].{PublicIp:PublicIp,AllocationId:AllocationId}" /
  --output table

# 4. 비용 예측
echo "4. 향후 3개월 비용 예측"
aws ce get-cost-forecast /
  --time-period Start=2024-02-01,End=2024-04-30 /
  --metric BLENDED_COST /
  --granularity MONTHLY

echo "=== AWS 비용 최적화 분석 완료 ==="
```

#### 예산 관리 스크립트

["예산 관리 스크립트"]["#예산-관리-스크립트"]
```bash
#!/bin/bash
# aws-budget-management.sh

echo "=== AWS 예산 관리 시작 ==="

# 1. 예산 목록 조회
echo "1. 예산 목록 조회"
aws budgets describe-budgets /
  --account-id 123456789012 /
  --query "Budgets[].{BudgetName:BudgetName,BudgetLimit:BudgetLimit.Amount,TimeUnit:TimeUnit}" /
  --output table

# 2. 예산 사용률 조회
echo "2. 예산 사용률 조회"
aws budgets describe-budget-performance-history /
  --account-id 123456789012 /
  --budget-name "MonthlyCostBudget" /
  --time-period Start=2024-01-01,End=2024-01-31

# 3. 예산 알림 설정
echo "3. 예산 알림 설정"
aws budgets create-notification /
  --account-id 123456789012 /
  --budget-name "MonthlyCostBudget" /
  --notification '{
    "NotificationType": "FORECASTED",
    "ComparisonOperator": "GREATER_THAN",
    "Threshold": 90,
    "ThresholdType": "PERCENTAGE"
  }' /
  --subscribers '[
    {
      "SubscriptionType": "EMAIL",
      "Address": "admin@example.com"
    }
  ]'

echo "=== AWS 예산 관리 완료 ==="
```

### GCP 비용 최적화 스크립트

["GCP 비용 최적화 스크립트"]["#gcp-비용-최적화-스크립트"]

#### 비용 분석 및 최적화

["비용 분석 및 최적화"]["#비용-분석-및-최적화"]
```bash
#!/bin/bash
# gcp-cost-optimization.sh

echo "=== GCP 비용 최적화 분석 시작 ==="

# 1. 프로젝트별 비용 조회
echo "1. 프로젝트별 비용 조회"
gcloud alpha billing projects list /
  --billing-account=BILLING_ACCOUNT_ID /
  --format="table[projectId,billingAccountName]"

# 2. 서비스별 사용량 조회
echo "2. 서비스별 사용량 조회"
gcloud logging read "resource.type=gce_instance" /
  --limit=100 /
  --format="table[timestamp,resource.labels.instance_name,severity]"

# 3. 권장사항 조회
echo "3. 권장사항 조회"

# 인스턴스 타입 권장사항
echo "인스턴스 타입 권장사항:"
gcloud recommender recommendations list /
  --project=PROJECT_ID /
  --recommender=google.compute.instance.MachineTypeRecommender /
  --format="table[name,description,primaryImpact.costProjection.cost.units]"

# 미사용 VM 권장사항
echo "미사용 VM 권장사항:"
gcloud recommender recommendations list /
  --project=PROJECT_ID /
  --recommender=google.compute.instance.IdleResourceRecommender /
  --format="table[name,description,primaryImpact.costProjection.cost.units]"

# 4. 비용 최적화 실행
echo "4. 비용 최적화 실행"

# 미사용 VM 삭제 ["예시"]
# gcloud compute instances delete INSTANCE_NAME --zone=ZONE --quiet

echo "=== GCP 비용 최적화 분석 완료 ==="
```

#### 예산 관리 스크립트

["예산 관리 스크립트"]["#예산-관리-스크립트"]
```bash
#!/bin/bash
# gcp-budget-management.sh

echo "=== GCP 예산 관리 시작 ==="

# 1. 예산 목록 조회
echo "1. 예산 목록 조회"
gcloud alpha billing budgets list /
  --billing-account=BILLING_ACCOUNT_ID /
  --format="table[displayName,budgetFilter.projects,amount.specifiedAmount.units]"

# 2. 예산 생성
echo "2. 예산 생성"
gcloud alpha billing budgets create /
  --billing-account=BILLING_ACCOUNT_ID /
  --display-name="Monthly Cost Budget" /
  --budget-amount=500 /
  --threshold-rule=percent=0.8 /
  --threshold-rule=percent=1.0 /
  --filter-projects="projects/PROJECT_ID"

# 3. 예산 알림 설정
echo "3. 예산 알림 설정"
gcloud alpha billing budgets create /
  --billing-account=BILLING_ACCOUNT_ID /
  --display-name="Monthly Cost Budget" /
  --budget-amount=500 /
  --threshold-rule=percent=0.8,spend-basis=FORECASTED /
  --threshold-rule=percent=1.0,spend-basis=ACTUAL /
  --notification-rule=pubsub-topic=projects/PROJECT_ID/topics/budget-alerts

echo "=== GCP 예산 관리 완료 ==="
```

---

## ✅ 예상 결과

### 비용 예측 결과

["비용 예측 결과"]["#비용-예측-결과"]
- Cost Explorer에서 선택한 기간의 실제 비용 그래프와 함께 다음 달 예측 비용이 그래프로 표시
- 서비스별 비용 분석 결과를 통한 비용 구조 파악
- 향후 3개월 비용 예측을 통한 예산 계획 수립

### 비용 최적화 결과

["비용 최적화 결과"]["#비용-최적화-결과"]
- Trusted Advisor/Cloud Recommender의 권장사항 목록에 절감 가능한 리소스가 표시
- 인스턴스 타입 변경, 예약 사용 전환 등의 권장작업이 제시
- 미사용 리소스 식별을 통한 즉시 절감 가능한 비용 발견

### 예산 관리 결과

["예산 관리 결과"]["#예산-관리-결과"]
- 예산 경고 설정에 따라 예산 80% 초과 시 이메일 알림이 전송
- 예측 비용 기반 알림을 통한 사전 비용 관리
- 실시간 비용 모니터링을 통한 예산 초과 방지

---

## 🚀 혼자 해보기

### 기본 과제

["기본 과제"]["#기본-과제"]
1. **과거 데이터 분석**: 과거 한 달간의 비용 데이터를 바탕으로 AWS Cost Explorer에서 분기별 예측을 생성해 보세요.

2. **권장사항 적용**: Trusted Advisor/Cloud Recommender의 권장사항을 실제로 적용해 보세요.

3. **예산 관리**: 더 정교한 예산 관리 시스템을 구축해 보세요.

### 고급 과제

["고급 과제"]["#고급-과제"]
1. **비용 최적화 자동화**: 비용 최적화를 위한 자동화 스크립트를 작성해 보세요.

2. **멀티 클라우드 비용 관리**: AWS와 GCP의 비용을 통합 관리하는 시스템을 구축해 보세요.

3. **비용 예측 모델**: 머신러닝을 활용한 비용 예측 모델을 구축해 보세요.

---

## ❓ 퀴즈

["❓ 퀴즈"]["#퀴즈"]

1. **AWS Trusted Advisor의 Cost Optimization 카테고리에 포함되는 주요 권장사항은 무엇인가요?**

2. **GCP Cloud Recommender에서 제공하는 권장사항 종류는 어떤 것들이 있나요?**

3. **비용 예측과 예산 관리의 차이점은 무엇인가요?**

4. **미사용 리소스를 식별하는 방법은 무엇인가요?**

---

## ✅ 체크리스트

["✅ 체크리스트"]["#체크리스트"]

- [ ] 예산[Budgets]을 설정하여 초과 알림을 받도록 했나요?
- [ ] Cost Explorer나 Billing Reports로 비용 추세를 시각화했나요?
- [ ] 권장사항에서 확인된 비효율적인 자원을 반영하여 인스턴스 규격을 변경하거나 예약 사용을 적용했나요?
- [ ] 비용 예측 기능을 활용하여 향후 비용을 예측했나요?
- [ ] 미사용 리소스를 식별하고 제거했나요?

---

## 📚 추가 학습 자료

["📚 추가 학습 자료"]["#추가-학습-자료"]

- ["AWS Cost Explorer 공식 문서"][https:///docs.aws.amazon.com/cost-management/latest/userguide/ce-what-is.html]
- ["AWS Trusted Advisor 공식 문서"][https:///docs.aws.amazon.com/awssupport/latest/user/trusted-advisor.html]
- ["GCP Cloud Billing 공식 문서"][https:///cloud.google.com/billing/docs]
- ["GCP Cloud Recommender 공식 문서"][https:///cloud.google.com/recommender/docs]

다음 단계: ["3교시: CloudWatch / Cloud Monitoring을 활용한 서비스 모니터링"][cloud_master/textbook/Day2/guides/monitoring-guide.md]

---



---


### 📧 연락처

["📧 연락처"]["#연락처"]
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: ["프로젝트 저장소"][https:///github.com/jungfrau70/aws_gcp.git]

---



<div align="center">

["← 이전: Cloud Master 2일차 메인"][README.md] | ["📚 전체 커리큘럼"][curriculum.md] | ["🏠 학습 경로로 돌아가기"][index.md] | ["📋 학습 경로"][learning-path.md] | ["다음: 모니터링 가이드 →"][cloud_master/textbook/Day2/guides/monitoring-guide.md]

</div>