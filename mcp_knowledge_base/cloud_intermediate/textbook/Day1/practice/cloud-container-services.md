# ☁️ 클라우드 컨테이너 서비스 실습

> 📋 **실습 시간**: 90분  
> 📋 **난이도**: 중급  
> 📋 **선수 학습**: Docker, Kubernetes 기초, AWS/GCP 계정  
> 📋 **실습 환경**: AWS ECS, GCP Cloud Run

## 🎯 학습 목표

### 핵심 학습 목표
- **AWS ECS**: Fargate를 활용한 서버리스 컨테이너 실행
- **GCP Cloud Run**: 서버리스 컨테이너 플랫폼 활용
- **클라우드 네이티브**: 클라우드 환경에 최적화된 컨테이너 배포

### 실습 후 달성할 수 있는 능력
- ✅ AWS ECS 클러스터 생성 및 관리
- ✅ Fargate를 활용한 서버리스 컨테이너 실행
- ✅ GCP Cloud Run 서비스 배포
- ✅ 클라우드 컨테이너 서비스 모니터링

### 예상 소요 시간
- **AWS ECS 환경 준비**: 15분
- **ECS 클러스터 생성**: 20분
- **태스크 정의 및 서비스**: 30분
- **GCP Cloud Run 배포**: 25분

---

## 🛠️ 실습 환경 준비

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/mcp_knowledge_base/cloud_intermediate/repos/samples/day1/cloud-container-services/`
- **자동화 스크립트**: `/mcp_knowledge_base/cloud_intermediate/repos/automation/day1/cloud-container-services-practice-automation.sh`
- **클라우드 스크립트**: `/mcp_knowledge_base/cloud_intermediate/repos/cloud-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **AWS CLI**: AWS 서비스 관리
- **GCP CLI**: Google Cloud 서비스 관리
- **Docker**: 컨테이너 이미지 빌드

#### 환경 설정
```bash
# AWS CLI 설정 확인
aws sts get-caller-identity
aws configure list

# GCP CLI 설정 확인
gcloud auth list
gcloud config list

# Docker 상태 확인
docker --version
docker ps
```

</details>

<details>
<summary>🔧 1단계: AWS ECS 환경 준비</summary>

#### 실습 디렉토리 생성
```bash
# 실습 디렉토리 생성
mkdir -p ~/cloud_intermediate/samples/day1/cloud-container-services
cd ~/cloud_intermediate/samples/day1/cloud-container-services

# 실습 샘플 코드 복사 (있는 경우)
cp -r /mcp_knowledge_base/cloud_intermediate/repos/samples/day1/cloud-container-services/* ./
```

#### AWS 리전 설정
```bash
# AWS 리전 설정
export AWS_DEFAULT_REGION=ap-northeast-2
echo "AWS 리전: $AWS_DEFAULT_REGION"

# AWS 계정 정보 확인
aws sts get-caller-identity
```

#### ECS 클러스터 생성
```bash
# ECS 클러스터 생성
aws ecs create-cluster \
  --cluster-name cloud-intermediate-cluster \
  --tags key=Environment,value=Learning \
  --capacity-providers FARGATE FARGATE_SPOT \
  --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1

# 클러스터 상태 확인
aws ecs describe-clusters --clusters cloud-intermediate-cluster
aws ecs list-clusters
```

</details>

<details>
<summary>🔧 2단계: 태스크 정의 생성 및 등록</summary>

#### CloudWatch 로그 그룹 생성
```bash
# CloudWatch 로그 그룹 생성
aws logs create-log-group \
  --log-group-name /ecs/cloud-intermediate-app \
  --region ap-northeast-2
```

#### 태스크 정의 JSON 생성
```bash
# 태스크 정의 JSON 파일 생성
cat > aws-ecs-task-definition.json << 'EOF'
{
  "family": "cloud-intermediate-app",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::YOUR_ACCOUNT_ID:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "nginx-container",
      "image": "nginx:1.21",
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/cloud-intermediate-app",
          "awslogs-region": "ap-northeast-2",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost/ || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      }
    }
  ]
}
EOF

# 태스크 정의 등록
aws ecs register-task-definition \
  --cli-input-json file://aws-ecs-task-definition.json

# 태스크 정의 확인
aws ecs list-task-definitions --family-prefix cloud-intermediate-app
aws ecs describe-task-definition --task-definition cloud-intermediate-app:1
```

</details>

<details>
<summary>🔧 3단계: ECS 서비스 생성 및 실행</summary>

#### VPC 및 네트워크 설정
```bash
# VPC 및 서브넷 정보 확인
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=is-default,Values=true" --query "Vpcs[0].VpcId" --output text)
SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[0].SubnetId" --output text)
SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --query "SecurityGroups[0].GroupId" --output text)

echo "VPC ID: $VPC_ID"
echo "Subnet ID: $SUBNET_ID"
echo "Security Group ID: $SECURITY_GROUP_ID"

# 보안 그룹 규칙 추가 (HTTP 트래픽 허용)
aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0
```

#### ECS 서비스 생성
```bash
# ECS 서비스 생성
aws ecs create-service \
  --cluster cloud-intermediate-cluster \
  --service-name cloud-intermediate-service \
  --task-definition cloud-intermediate-app:1 \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[$SUBNET_ID],securityGroups=[$SECURITY_GROUP_ID],assignPublicIp=ENABLED}"

# 서비스 상태 확인
aws ecs describe-services \
  --cluster cloud-intermediate-cluster \
  --services cloud-intermediate-service

# 태스크 상태 확인
aws ecs list-tasks --cluster cloud-intermediate-cluster
```

#### 서비스 모니터링
```bash
# 태스크 상세 정보 확인
TASK_ARN=$(aws ecs list-tasks --cluster cloud-intermediate-cluster --query "taskArns[0]" --output text)
aws ecs describe-tasks --cluster cloud-intermediate-cluster --tasks $TASK_ARN

# CloudWatch 로그 확인
aws logs describe-log-streams --log-group-name /ecs/cloud-intermediate-app
```

</details>

<details>
<summary>🔧 4단계: GCP Cloud Run 배포</summary>

#### GCP 프로젝트 설정
```bash
# GCP 프로젝트 설정
gcloud config set project YOUR_PROJECT_ID
gcloud config set compute/region asia-northeast3

# GCP 서비스 활성화
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

#### Cloud Run 서비스 배포
```bash
# Cloud Run 서비스 배포
gcloud run deploy cloud-intermediate-app \
  --image nginx:1.21 \
  --platform managed \
  --region asia-northeast3 \
  --allow-unauthenticated \
  --port 80 \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 10

# 서비스 상태 확인
gcloud run services list --region asia-northeast3
gcloud run services describe cloud-intermediate-app --region asia-northeast3
```

#### Cloud Run 서비스 테스트
```bash
# 서비스 URL 확인
SERVICE_URL=$(gcloud run services describe cloud-intermediate-app --region asia-northeast3 --format "value(status.url)")
echo "Service URL: $SERVICE_URL"

# 서비스 접근 테스트
curl $SERVICE_URL

# 서비스 로그 확인
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=cloud-intermediate-app" --limit 10
```

</details>

---

## 📚 참고 자료

### 유용한 명령어
```bash
# AWS ECS 관리
aws ecs list-clusters
aws ecs describe-clusters --clusters <cluster-name>
aws ecs list-services --cluster <cluster-name>
aws ecs describe-services --cluster <cluster-name> --services <service-name>

# GCP Cloud Run 관리
gcloud run services list
gcloud run services describe <service-name> --region <region>
gcloud run services delete <service-name> --region <region>
```

### 문제 해결
1. **ECS 태스크가 시작되지 않음**
   - 태스크 정의 확인: `aws ecs describe-task-definition --task-definition <task-def>`
   - 로그 확인: CloudWatch Logs에서 오류 메시지 확인

2. **Cloud Run 배포 실패**
   - 이미지 존재 확인: `docker pull nginx:1.21`
   - 권한 확인: `gcloud auth list`

3. **네트워크 연결 문제**
   - 보안 그룹 규칙 확인
   - VPC 및 서브넷 설정 확인

---

## 🧹 실습 정리

### 자동 정리
```bash
# Day1 클라우드 컨테이너 서비스 실습 자동 정리
./mcp_knowledge_base/cloud_intermediate/repos/automation/day1/cloud-container-services-practice-automation.sh --cleanup
```

### 수동 정리
```bash
# AWS ECS 리소스 정리
aws ecs delete-service --cluster cloud-intermediate-cluster --service cloud-intermediate-service
aws ecs delete-cluster --cluster cloud-intermediate-cluster
aws logs delete-log-group --log-group-name /ecs/cloud-intermediate-app

# GCP Cloud Run 리소스 정리
gcloud run services delete cloud-intermediate-app --region asia-northeast3
```

### 정리 확인
- [ ] AWS ECS 클러스터 삭제 완료
- [ ] ECS 서비스 삭제 완료
- [ ] CloudWatch 로그 그룹 삭제 완료
- [ ] GCP Cloud Run 서비스 삭제 완료

---

## 🎯 학습 성과 확인

### 실습 완료 체크리스트
- [ ] AWS ECS 클러스터 생성 성공
- [ ] 태스크 정의 등록 완료
- [ ] ECS 서비스 실행 및 상태 확인
- [ ] Fargate 태스크 정상 동작
- [ ] GCP Cloud Run 서비스 배포 성공
- [ ] 클라우드 컨테이너 서비스 모니터링 확인

### 다음 단계
- **통합 모니터링 허브** 구축 실습으로 진행
- **멀티 클라우드 모니터링** 환경 준비
- **Prometheus + Grafana** 통합 설정

---

**💡 궁금한 점이 있으시면 언제든 문의해주세요!**  
**문제가 발생하거나 도움이 필요하시면 실시간으로 지원해드리겠습니다.**
