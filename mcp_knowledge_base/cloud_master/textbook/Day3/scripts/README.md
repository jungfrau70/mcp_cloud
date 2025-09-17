# AWS/GCP 자동화 스크립트 모음

<div align="center">

[← 이전: Cloud Master 2일차](/mcp_knowledge_base/cloud_master/textbook/Day2/README.md) | [다음: Cloud Master 3일차 →](/mcp_knowledge_base/cloud_master/textbook/Day3/README.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🏠 학습 경로로 돌아가기](/mcp_knowledge_base/index.md) | [📋 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>

이 디렉토리는 AWS와 GCP 클라우드 서비스를 자동화하는 스크립트들을 포함합니다.

## 📋 스크립트 개요

### 목적
- 클라우드 리소스 자동 생성 및 관리
- 배포 프로세스 자동화
- 모니터링 및 로깅 설정 자동화
- 비용 최적화 및 관리

### 지원 클라우드
- **AWS**: EC2, S3, RDS, ELB, Auto Scaling
- **GCP**: Compute Engine, Cloud Storage, Cloud SQL, Load Balancing

## 📁 스크립트 구조

```
scripts/
├── aws-setup-helper.sh          # AWS 기본 설정
├── gcp-setup-helper.sh          # GCP 기본 설정
├── aws-ec2-create.sh            # EC2 인스턴스 생성
├── aws-resource-cleanup.sh      # AWS 리소스 정리
├── gcp-compute-create.sh        # Compute Engine 인스턴스 생성
├── gcp-project-cleanup.sh       # GCP 프로젝트 정리
├── PROJECT_SETUP.md             # 프로젝트 설정 가이드
└── README.md                    # 스크립트 문서
```

## 🚀 사용 방법

### 1. AWS 설정 및 리소스 생성

#### AWS 기본 설정
```bash
# AWS CLI 설정
./aws-setup-helper.sh

# EC2 인스턴스 생성
./aws-ec2-create.sh

# 리소스 정리
./aws-resource-cleanup.sh
```

#### AWS 스크립트 상세
- **aws-setup-helper.sh**: AWS CLI 설정, IAM 역할 생성, 보안 그룹 설정
- **aws-ec2-create.sh**: EC2 인스턴스 생성, 키 페어 생성, 보안 그룹 설정
- **aws-resource-cleanup.sh**: 생성된 리소스 정리, 비용 최적화

### 2. GCP 설정 및 리소스 생성

#### GCP 기본 설정
```bash
# GCP CLI 설정
./gcp-setup-helper.sh

# Compute Engine 인스턴스 생성
./gcp-compute-create.sh

# 프로젝트 정리
./gcp-project-cleanup.sh
```

#### GCP 스크립트 상세
- **gcp-setup-helper.sh**: gcloud CLI 설정, 서비스 계정 생성, API 활성화
- **gcp-compute-create.sh**: Compute Engine 인스턴스 생성, 방화벽 규칙 설정
- **gcp-project-cleanup.sh**: 생성된 리소스 정리, 비용 최적화

## 🔧 스크립트 상세 설명

### AWS 스크립트

#### aws-setup-helper.sh
```bash
#!/bin/bash
# AWS 기본 설정 스크립트

# AWS CLI 설치 확인
if ! command -v aws &> /dev/null; then
    echo "AWS CLI가 설치되지 않았습니다. 설치를 진행합니다..."
    # AWS CLI 설치 로직
fi

# AWS 자격 증명 설정
aws configure

# IAM 역할 생성
aws iam create-role --role-name EC2Role --assume-role-policy-document file://trust-policy.json

# 보안 그룹 생성
aws ec2 create-security-group --group-name MySecurityGroup --description "My Security Group"
```

#### aws-ec2-create.sh
```bash
#!/bin/bash
# EC2 인스턴스 생성 스크립트

# 변수 설정
INSTANCE_TYPE="t3.micro"
IMAGE_ID="ami-0ae2c887094315bed"
KEY_NAME="my-key"
SECURITY_GROUP="MySecurityGroup"

# EC2 인스턴스 생성
aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --security-groups $SECURITY_GROUP \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=MyInstance}]'
```

### GCP 스크립트

#### gcp-setup-helper.sh
```bash
#!/bin/bash
# GCP 기본 설정 스크립트

# gcloud CLI 설치 확인
if ! command -v gcloud &> /dev/null; then
    echo "gcloud CLI가 설치되지 않았습니다. 설치를 진행합니다..."
    # gcloud CLI 설치 로직
fi

# gcloud 초기화
gcloud init

# 프로젝트 설정
gcloud config set project YOUR_PROJECT_ID

# 서비스 계정 생성
gcloud iam service-accounts create my-service-account \
    --display-name="My Service Account"
```

#### gcp-compute-create.sh
```bash
#!/bin/bash
# Compute Engine 인스턴스 생성 스크립트

# 변수 설정
INSTANCE_NAME="my-instance"
MACHINE_TYPE="e2-micro"
ZONE="asia-northeast3-a"
IMAGE_FAMILY="ubuntu-2004-lts"

# Compute Engine 인스턴스 생성
gcloud compute instances create $INSTANCE_NAME \
    --zone=$ZONE \
    --machine-type=$MACHINE_TYPE \
    --image-family=$IMAGE_FAMILY \
    --image-project=ubuntu-os-cloud \
    --tags=http-server,https-server
```

## 📊 모니터링 및 로깅

### CloudWatch 설정 (AWS)
```bash
# CloudWatch 로그 그룹 생성
aws logs create-log-group --log-group-name /aws/ec2/my-app

# CloudWatch 알람 생성
aws cloudwatch put-metric-alarm \
    --alarm-name "High CPU Utilization" \
    --alarm-description "Alarm when CPU exceeds 80%" \
    --metric-name CPUUtilization \
    --namespace AWS/EC2 \
    --statistic Average \
    --period 300 \
    --threshold 80.0 \
    --comparison-operator GreaterThanThreshold
```

### Cloud Monitoring 설정 (GCP)
```bash
# Cloud Monitoring 알림 정책 생성
gcloud alpha monitoring policies create \
    --policy-from-file=alert-policy.yaml

# 로그 기반 메트릭 생성
gcloud logging metrics create high_error_rate \
    --description="High error rate metric" \
    --log-filter="severity>=ERROR"
```

## 💰 비용 최적화

### AWS 비용 최적화
```bash
# 사용하지 않는 리소스 식별
aws ec2 describe-instances --query 'Reservations[*].Instances[?State.Name==`stopped`]'

# 사용하지 않는 볼륨 식별
aws ec2 describe-volumes --query 'Volumes[?State==`available`]'

# 비용 분석
aws ce get-cost-and-usage \
    --time-period Start=2024-01-01,End=2024-01-31 \
    --granularity MONTHLY \
    --metrics BlendedCost
```

### GCP 비용 최적화
```bash
# 사용하지 않는 리소스 식별
gcloud compute instances list --filter="status=TERMINATED"

# 사용하지 않는 디스크 식별
gcloud compute disks list --filter="status=UNATTACHED"

# 비용 분석
gcloud alpha billing budgets list --billing-account=YOUR_BILLING_ACCOUNT
```

## 🔒 보안 설정

### AWS 보안 설정
```bash
# 보안 그룹 규칙 설정
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

# IAM 정책 생성
aws iam create-policy \
    --policy-name MyPolicy \
    --policy-document file://policy.json
```

### GCP 보안 설정
```bash
# 방화벽 규칙 생성
gcloud compute firewall-rules create allow-ssh \
    --allow tcp:22 \
    --source-ranges 0.0.0.0/0 \
    --target-tags ssh

# 서비스 계정 권한 설정
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:my-service-account@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/compute.instanceAdmin"
```

## 🧪 테스트

### 스크립트 테스트
```bash
# 스크립트 문법 검사
bash -n script-name.sh

# 스크립트 실행 테스트
bash -x script-name.sh

# 단위 테스트 실행
./test-scripts.sh
```

### 통합 테스트
```bash
# 전체 워크플로우 테스트
./integration-test.sh

# 클라우드 리소스 생성 테스트
./test-resource-creation.sh

# 정리 스크립트 테스트
./test-cleanup.sh
```

## 📚 추가 자료

- [AWS CLI 공식 문서](https://docs.aws.amazon.com/cli/)
- [gcloud CLI 공식 문서](https://cloud.google.com/sdk/docs)
- [Bash 스크립팅 가이드](https://www.gnu.org/software/bash/manual/)
- [Terraform 공식 문서](https://www.terraform.io/docs/)

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingScript`)
3. Commit your Changes (`git commit -m 'Add some AmazingScript'`)
4. Push to the Branch (`git push origin feature/AmazingScript`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 📞 문의

스크립트에 대한 문의사항이 있으시면 이슈를 생성해 주세요.

---

**🎯 이 스크립트들을 통해 AWS와 GCP 클라우드 서비스를 자동화할 수 있습니다.**

---

<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>

### 📧 연락처
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: [프로젝트 저장소](https://github.com/jungfrau70/aws_gcp.git)

---

<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>
