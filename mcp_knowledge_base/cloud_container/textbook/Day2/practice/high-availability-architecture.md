<div align="center">

## 🏠 최상위 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_container/learning-path.md)

## 📖 현재 위치
**Cloud Container** > **2일차** > **고가용성 아키텍처 실습**

## ⬅️ 이전/다음 네비게이션
[← 이전: Cloud Container 메인](/mcp_knowledge_base/cloud_container/README.md) | [다음: Cloud Container 2일차 →](/mcp_knowledge_base/cloud_container/textbook/Day2/README.md)

</div>

# 고가용성 아키텍처 실습

<div align="center">

[← 이전: Cloud Container 2일차 메인](/mcp_knowledge_base/cloud_master/README.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🏠 학습 경로로 돌아가기](/mcp_knowledge_base/index.md) | [← 이전: Cloud Container 메인](/mcp_knowledge_base/cloud_master/README.md) | [📋 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>

## 🎯 실습 목표

이 실습을 통해 다음을 학습합니다:
- Multi-AZ 아키텍처 구성
- Multi-Region 아키텍처 구성
- 장애 복구 시나리오 테스트
- 고가용성 모니터링 설정

## 📋 사전 준비사항

- AWS 계정 (Free Tier 가능)
- GCP 계정 ($300 크레딧)
- 기본적인 클라우드 서비스 이해

## 🏗️ AWS Multi-AZ 아키텍처 구성

### 1단계: VPC 및 서브넷 생성

```bash
# VPC 생성
aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=ha-vpc}]'

# 가용 영역 확인
aws ec2 describe-availability-zones --region ap-northeast-2

# Public 서브넷 생성 (AZ-a)
aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.1.0/24 \
    --availability-zone ap-northeast-2a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=public-subnet-1}]'

# Public 서브넷 생성 (AZ-c)
aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.2.0/24 \
    --availability-zone ap-northeast-2c \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=public-subnet-2}]'

# Private 서브넷 생성 (AZ-a)
aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.10.0/24 \
    --availability-zone ap-northeast-2a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=private-subnet-1}]'

# Private 서브넷 생성 (AZ-c)
aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.20.0/24 \
    --availability-zone ap-northeast-2c \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=private-subnet-2}]'
```

### 2단계: 인터넷 게이트웨이 및 NAT 게이트웨이 설정

```bash
# 인터넷 게이트웨이 생성
aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=ha-igw]}'

# VPC에 인터넷 게이트웨이 연결
aws ec2 attach-internet-gateway \
    --vpc-id $VPC_ID \
    --internet-gateway-id $IGW_ID

# Elastic IP 생성 (NAT Gateway용)
aws ec2 allocate-address --domain vpc

# NAT Gateway 생성
aws ec2 create-nat-gateway \
    --subnet-id $PUBLIC_SUBNET_1 \
    --allocation-id $EIP_ALLOCATION_ID \
    --tag-specifications 'ResourceType=nat-gateway,Tags=[{Key=Name,Value=ha-nat-gateway]}'
```

### 3단계: 라우팅 테이블 설정

```bash
# Public 라우팅 테이블 생성
aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=public-rt}]'

# Private 라우팅 테이블 생성
aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=private-rt}]'

# Public 서브넷에 인터넷 게이트웨이 라우트 추가
aws ec2 create-route \
    --route-table-id $PUBLIC_RT_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $IGW_ID

# Private 서브넷에 NAT 게이트웨이 라우트 추가
aws ec2 create-route \
    --route-table-id $PRIVATE_RT_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --nat-gateway-id $NAT_GATEWAY_ID
```

## ☁️ GCP Multi-Region 아키텍처 구성

### 1단계: VPC 네트워크 생성

```bash
# VPC 네트워크 생성
gcloud compute networks create ha-vpc \
    --subnet-mode custom \
    --bgp-routing-mode global

# 서울 리전 서브넷 생성
gcloud compute networks subnets create seoul-subnet \
    --network ha-vpc \
    --range 10.0.1.0/24 \
    --region asia-northeast3

# 도쿄 리전 서브넷 생성
gcloud compute networks subnets create tokyo-subnet \
    --network ha-vpc \
    --range 10.0.2.0/24 \
    --region asia-northeast1
```

### 2단계: 방화벽 규칙 설정

```bash
# HTTP/HTTPS 허용 규칙
gcloud compute firewall-rules create allow-http-https \
    --network ha-vpc \
    --allow tcp:80,tcp:443 \
    --source-ranges 0.0.0.0/0 \
    --target-tags web-server

# SSH 허용 규칙
gcloud compute firewall-rules create allow-ssh \
    --network ha-vpc \
    --allow tcp:22 \
    --source-ranges 0.0.0.0/0 \
    --target-tags ssh-server
```

## 🔄 고가용성 테스트

### 1단계: 애플리케이션 배포

```bash
# 서울 리전에 인스턴스 생성
gcloud compute instances create seoul-app-1 \
    --zone=asia-northeast3-a \
    --machine-type=e2-micro \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --subnet=seoul-subnet \
    --tags=web-server,ssh-server

# 도쿄 리전에 인스턴스 생성
gcloud compute instances create tokyo-app-1 \
    --zone=asia-northeast1-a \
    --machine-type=e2-micro \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --subnet=tokyo-subnet \
    --tags=web-server,ssh-server
```

### 2단계: 로드 밸런서 설정

```bash
# 백엔드 서비스 생성
gcloud compute backend-services create ha-backend \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=ha-health-check \
    --global

# 인스턴스 그룹 생성 (서울)
gcloud compute instance-groups unmanaged create seoul-group \
    --zone=asia-northeast3-a

# 인스턴스 그룹 생성 (도쿄)
gcloud compute instance-groups unmanaged create tokyo-group \
    --zone=asia-northeast1-a

# 인스턴스를 그룹에 추가
gcloud compute instance-groups unmanaged add-instances seoul-group \
    --instances=seoul-app-1 \
    --zone=asia-northeast3-a

gcloud compute instance-groups unmanaged add-instances tokyo-group \
    --instances=tokyo-app-1 \
    --zone=asia-northeast1-a
```

## 📊 모니터링 설정

### 1단계: CloudWatch 알람 설정

```bash
# CPU 사용률 알람 생성
aws cloudwatch put-metric-alarm \
    --alarm-name "High CPU Utilization" \
    --alarm-description "Alarm when CPU exceeds 80%" \
    --metric-name CPUUtilization \
    --namespace AWS/EC2 \
    --statistic Average \
    --period 300 \
    --threshold 80.0 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2

# 상태 확인 실패 알람 생성
aws cloudwatch put-metric-alarm \
    --alarm-name "Status Check Failed" \
    --alarm-description "Alarm when status check fails" \
    --metric-name StatusCheckFailed \
    --namespace AWS/EC2 \
    --statistic Maximum \
    --period 60 \
    --threshold 1.0 \
    --comparison-operator GreaterThanOrEqualToThreshold \
    --evaluation-periods 2
```

### 2단계: GCP 모니터링 설정

```bash
# 알림 정책 생성
gcloud alpha monitoring policies create \
    --policy-from-file=alert-policy.yaml

# 대시보드 생성
gcloud alpha monitoring dashboards create \
    --config-from-file=dashboard-config.yaml
```

## 🧪 장애 복구 테스트

### 1단계: 인스턴스 중지 테스트

```bash
# 서울 리전 인스턴스 중지
gcloud compute instances stop seoul-app-1 --zone=asia-northeast3-a

# 로드 밸런서가 도쿄 리전으로 트래픽 전환하는지 확인
curl -I http://LOAD_BALANCER_IP
```

### 2단계: 자동 복구 테스트

```bash
# 인스턴스 재시작
gcloud compute instances start seoul-app-1 --zone=asia-northeast3-a

# Health Check 통과 후 트래픽 분산 확인
curl -I http://LOAD_BALANCER_IP
```

## 📝 실습 결과 확인

### 체크리스트

- [ ] Multi-AZ VPC 구성 완료
- [ ] Multi-Region GCP 구성 완료
- [ ] 로드 밸런서 설정 완료
- [ ] 모니터링 알람 설정 완료
- [ ] 장애 복구 테스트 성공

### 성능 지표

- **가용성**: 99.9% 이상
- **복구 시간**: 5분 이내
- **응답 시간**: 200ms 이내

## 🔧 문제 해결

### 자주 발생하는 문제

1. **Health Check 실패**
   - 보안 그룹/방화벽 규칙 확인
   - 애플리케이션 포트 확인

2. **로드 밸런서 502 오류**
   - 백엔드 서비스 상태 확인
   - 인스턴스 그룹 설정 확인

3. **모니터링 데이터 없음**
   - CloudWatch 에이전트 설치 확인
   - IAM 권한 확인

## 📚 추가 학습 자료

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [GCP Architecture Center](https://cloud.google.com/architecture)
- [고가용성 모범 사례](https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/high-availability.html)

---

<div align="center">

## 🔗 관련 과정 및 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_container/learning-path.md)

## 📖 현재 위치
**Cloud Container** > **2일차** > **고가용성 아키텍처 실습**

## ⬅️ 이전/다음 네비게이션
[← 이전: Cloud Container 메인](/mcp_knowledge_base/cloud_container/README.md) | [다음: Cloud Container 2일차 →](/mcp_knowledge_base/cloud_container/textbook/Day2/README.md)

## 🔗 관련 과정
[Cloud Master 3일차](/mcp_knowledge_base/cloud_master/textbook/Day3/README.md) | [Cloud Basic 1일차](/mcp_knowledge_base/cloud_basic/textbook/Day1/README.md)

</div>

### 📧 연락처
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: [프로젝트 저장소](https://github.com/jungfrau70/aws_gcp.git)
