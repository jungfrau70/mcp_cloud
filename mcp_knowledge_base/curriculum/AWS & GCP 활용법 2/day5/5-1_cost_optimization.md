# 5-1. 비용 최적화 전략 및 도구

## 학습 목표
- 클라우드 비용 구조 이해
- AWS와 GCP의 비용 최적화 전략
- 비용 모니터링 및 알림 설정
- 자동화된 비용 최적화 도구 활용

---

## 클라우드 비용 구조

### 주요 비용 요소
```
컴퓨팅 비용:
├── 인스턴스 시간
├── 스토리지 용량
├── 데이터 전송
└── API 호출

네트워킹 비용:
├── 인터넷 데이터 전송
├── 리전 간 데이터 전송
└── 로드 밸런서

관리 서비스:
├── 데이터베이스
├── 모니터링
└── 로깅
```

---

## AWS 비용 최적화

### 컴퓨팅 최적화
```bash
# Spot 인스턴스 사용
aws ec2 run-instances \
    --instance-type c5.large \
    --spot-price 0.05

# Reserved Instance 구매
aws ec2 describe-reserved-instances-offerings \
    --instance-type c5.large \
    --offering-type All Upfront

# Auto Scaling 구성
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name my-asg \
    --min-size 1 \
    --max-size 10 \
    --desired-capacity 2
```

### 스토리지 최적화
```bash
# S3 수명 주기 정책
aws s3api put-bucket-lifecycle-configuration \
    --bucket my-bucket \
    --lifecycle-configuration file://lifecycle-policy.json

# EBS 스냅샷 정리
aws ec2 describe-snapshots \
    --owner-ids self \
    --query 'Snapshots[?StartTime<`2023-01-01`].SnapshotId'
```

---

## GCP 비용 최적화

### 컴퓨팅 최적화
```bash
# Preemptible 인스턴스 사용
gcloud compute instances create preemptible-instance \
    --machine-type=e2-standard-2 \
    --preemptible

# Committed Use Discounts
gcloud compute commitments create \
    --resources=machineType=e2-standard-2,count=1 \
    --region=asia-northeast3

# Instance Groups
gcloud compute instance-groups managed create my-group \
    --base-instance-name=web \
    --template=web-template \
    --size=2
```

### 스토리지 최적화
```bash
# Cloud Storage 수명 주기
gsutil lifecycle set lifecycle-policy.json gs://my-bucket

# Persistent Disk 스냅샷 정리
gcloud compute snapshots list \
    --filter="creationTimestamp<2023-01-01T00:00:00Z"
```

---

## 비용 모니터링

### AWS Cost Explorer
```bash
# 비용 및 사용량 분석
aws ce get-cost-and-usage \
    --time-period Start=2023-01-01,End=2023-02-01 \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=DIMENSION,Key=SERVICE

# 비용 예측
aws ce get-cost-forecast \
    --time-period Start=2023-02-01,End=2023-03-01 \
    --metric BlendedCost \
    --granularity MONTHLY
```

### GCP Cost Management
```bash
# 비용 분석
gcloud billing accounts list

# 예산 및 알림
gcloud billing budgets create \
    --billing-account=ACCOUNT_ID \
    --display-name="Monthly Budget" \
    --budget-amount=100USD \
    --threshold-rule=percent=0.5 \
    --threshold-rule=percent=0.9
```

---

## 자동화된 비용 최적화

### AWS Lambda 함수
```python
import boto3
import json

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    
    # 사용하지 않는 EBS 볼륨 찾기
    response = ec2.describe_volumes(
        Filters=[
            {'Name': 'status', 'Values': ['available']}
        ]
    )
    
    for volume in response['Volumes']:
        if volume['State'] == 'available':
            print(f"Unused volume: {volume['VolumeId']}")
    
    return {
        'statusCode': 200,
        'body': json.dumps('Cost optimization check completed')
    }
```

### GCP Cloud Functions
```python
from google.cloud import compute_v1
from google.cloud import billing_v1

def cost_optimization_check(event, context):
    compute_client = compute_v1.InstancesClient()
    
    # 사용하지 않는 인스턴스 찾기
    request = compute_v1.ListInstancesRequest(
        project="my-project",
        zone="asia-northeast3-a"
    )
    
    for instance in compute_client.list(request=request):
        if instance.status == "STOPPED":
            print(f"Stopped instance: {instance.name}")
    
    return "Cost optimization check completed"
```

---

## 비용 최적화 모범 사례

### 컴퓨팅 최적화
- [ ] **Right Sizing**: 워크로드에 맞는 인스턴스 크기 선택
- [ ] **Auto Scaling**: 수요에 따른 자동 확장/축소
- [ ] **Spot/Preemptible**: 비용이 중요한 워크로드 활용
- [ ] **Reserved Instances**: 안정적인 워크로드 장기 약정

### 스토리지 최적화
- [ ] **수명 주기 정책**: 자동 계층화 및 삭제
- [ ] **압축**: 데이터 압축으로 용량 절약
- [ ] **중복 제거**: 중복 데이터 제거
- [ ] **백업 전략**: 비용 효율적인 백업

### 네트워킹 최적화
- [ ] **CDN 활용**: 정적 콘텐츠 캐싱
- [ ] **리전 선택**: 가까운 리전 사용
- [ ] **데이터 전송 최소화**: 불필요한 전송 방지
- [ ] **VPC 엔드포인트**: 프라이빗 네트워크 활용

---

## 실습 과제

### 기본 실습
1. **비용 모니터링 대시보드 구성**
2. **비용 알림 설정**
3. **수명 주기 정책 구성**

### 고급 실습
1. **자동화된 비용 최적화 스크립트 작성**
2. **비용 분석 리포트 생성**
3. **예산 관리 및 예측**

---

## 다음 단계
- CI/CD 파이프라인 구축
- 컨테이너 및 고급 배포 전략
- 보안 및 규정 준수
