# ☁️ 클라우드 고급 배포 실습

> 📋 **실습 시간**: 180분 (2교시)  
> 📋 **난이도**: 중급  
> 📋 **선수 학습**: AWS ECS, GCP Cloud Run 기초, CI/CD 파이프라인  
> 📋 **실습 환경**: AWS ECS, GCP Cloud Run

## 🎯 학습 목표

### 핵심 학습 목표
- **AWS ECS 고급 배포**: Application Load Balancer, 자동 스케일링, Blue-Green 배포
- **GCP Cloud Run 고급 배포**: 도메인 매핑, 트래픽 분할, 카나리 배포
- **무중단 배포**: Blue-Green, Canary 배포 전략 구현
- **서버리스 최적화**: 비용 효율적인 서버리스 아키텍처

### 실습 후 달성할 수 있는 능력
- ✅ AWS ECS 고급 배포 전략 구현
- ✅ Application Load Balancer 설정 및 관리
- ✅ GCP Cloud Run 고급 배포 전략 구현
- ✅ 무중단 배포 전략 구현

### 예상 소요 시간
- **AWS ECS 고급 배포**: 90분
- **GCP Cloud Run 고급 배포**: 90분
- **전체 과정**: 3시간

---

## 🛠️ 실습 환경 준비

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/cloud_intermediate/repo/practice/day2/cloud-deployment/`
- **자동화 스크립트**: `/cloud_intermediate/tools/cloud/aws-ecs-helper.sh`, `/cloud_intermediate/tools/cloud/gcp-cloudrun-helper.sh` (복사 후 사용)
- **클라우드 스크립트**: `/cloud_intermediate/tools/cloud/`

### 🔧 자동화 스크립트 사용법
```bash
# 자동화 스크립트를 실습 위치로 복사
cp ../../tools/cloud/docker-helper.sh ./
chmod +x docker-helper.sh

# Docker 컨테이너 최적화
./docker-helper.sh --action optimize-image
./docker-helper.sh --action run-container

# 수동으로 AWS ECS 및 GCP Cloud Run 고급 배포 진행
# (자동화 스크립트는 추후 추가 예정)
```

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **AWS CLI**: AWS 서비스 관리
- **GCP CLI**: GCP 서비스 관리
- **Docker**: 컨테이너 이미지 빌드
- **kubectl**: Kubernetes 클러스터 관리

#### 환경 설정
```bash
# AWS CLI 설정 확인
aws sts get-caller-identity
aws configure list

# GCP CLI 설정 확인
gcloud auth list
gcloud config list

# Docker 설치 확인
docker --version

# kubectl 설치 확인
kubectl version --client
```

</details>

<details>
<summary>🔧 1단계: AWS ECS 고급 배포</summary>

#### 실습 디렉토리 생성
```bash
# 실습 디렉토리 생성
mkdir -p ~/cloud_intermediate/samples/day2/cloud-deployment/aws-ecs
cd ~/cloud_intermediate/samples/day2/cloud-deployment/aws-ecs

# 실습 샘플 코드 복사 (있는 경우)
cp -r /cloud_intermediate/repo/examples/day2/cloud-deployment/aws-ecs/* ./
```

#### ECS 클러스터 생성
```bash
# ECS 클러스터 생성
aws ecs create-cluster \
    --cluster-name production-cluster \
    --capacity-providers FARGATE \
    --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1

# 클러스터 상태 확인
aws ecs describe-clusters --clusters production-cluster
```

#### Application Load Balancer 설정
```bash
# ALB 생성
aws elbv2 create-load-balancer \
    --name production-alb \
    --subnets subnet-12345 subnet-67890 \
    --security-groups sg-12345

# 타겟 그룹 생성
aws elbv2 create-target-group \
    --name production-targets \
    --protocol HTTP \
    --port 80 \
    --vpc-id vpc-12345 \
    --target-type ip

# 리스너 생성
aws elbv2 create-listener \
    --load-balancer-arn arn:aws:elasticloadbalancing:region:account:loadbalancer/app/production-alb/1234567890123456 \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:region:account:targetgroup/production-targets/1234567890123456
```

#### 태스크 정의 생성
```bash
# 태스크 정의 JSON 생성
cat > task-definition.json << 'EOF'
{
  "family": "production-app",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::ACCOUNT:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "production-app",
      "image": "nginx:1.21",
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost/ || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3
      }
    }
  ]
}
EOF

# 태스크 정의 등록
aws ecs register-task-definition --cli-input-json file://task-definition.json
```

#### ECS 서비스 배포
```bash
# ECS 서비스 생성
aws ecs create-service \
    --cluster production-cluster \
    --service-name production-service \
    --task-definition production-app:1 \
    --desired-count 3 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[subnet-12345,subnet-67890],securityGroups=[sg-12345],assignPublicIp=ENABLED}" \
    --load-balancers "targetGroupArn=arn:aws:elasticloadbalancing:region:account:targetgroup/production-targets/1234567890123456,containerName=production-app,containerPort=80"

# 서비스 상태 확인
aws ecs describe-services --cluster production-cluster --services production-service
```

#### 자동 스케일링 설정
```bash
# Auto Scaling 그룹 생성
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name production-asg \
    --launch-template LaunchTemplateName=production-template,Version=1 \
    --min-size 1 \
    --max-size 10 \
    --desired-capacity 3 \
    --target-group-arns arn:aws:elasticloadbalancing:region:account:targetgroup/production-targets/1234567890123456

# 스케일링 정책 생성
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name production-asg \
    --policy-name scale-up-policy \
    --policy-type TargetTrackingScaling \
    --target-tracking-configuration '{
        "TargetValue": 70.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ASGAverageCPUUtilization"
        }
    }'
```

</details>

<details>
<summary>🔧 2단계: GCP Cloud Run 고급 배포</summary>

#### 실습 디렉토리 생성
```bash
# 실습 디렉토리 생성
mkdir -p ~/cloud_intermediate/samples/day2/cloud-deployment/gcp-cloud-run
cd ~/cloud_intermediate/samples/day2/cloud-deployment/gcp-cloud-run

# 실습 샘플 코드 복사 (있는 경우)
cp -r /cloud_intermediate/repo/examples/day2/cloud-deployment/gcp-cloud-run/* ./
```

#### Docker 이미지 빌드 및 푸시
```bash
# Docker 이미지 빌드
docker build -t gcr.io/PROJECT_ID/cloud-run-app:latest .

# GCP Container Registry에 푸시
docker push gcr.io/PROJECT_ID/cloud-run-app:latest

# 이미지 푸시 확인
gcloud container images list --repository gcr.io/PROJECT_ID
```

#### Cloud Run 서비스 배포
```bash
# Cloud Run 서비스 배포
gcloud run deploy cloud-run-app \
    --image gcr.io/PROJECT_ID/cloud-run-app:latest \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --memory 512Mi \
    --cpu 1 \
    --max-instances 10 \
    --min-instances 1

# 서비스 상태 확인
gcloud run services describe cloud-run-app --region us-central1
```

#### 도메인 매핑 설정
```bash
# 도메인 매핑
gcloud run domain-mappings create \
    --service cloud-run-app \
    --domain your-domain.com \
    --region us-central1

# SSL 인증서 자동 생성 확인
gcloud run domain-mappings describe your-domain.com --region us-central1
```

#### 트래픽 분할 설정
```bash
# 트래픽 분할 설정
gcloud run services update-traffic cloud-run-app \
    --to-latest \
    --region us-central1

# 카나리 배포 설정
gcloud run services update-traffic cloud-run-app \
    --to-revisions cloud-run-app-00001-abc=90,cloud-run-app-00002-def=10 \
    --region us-central1
```

#### 환경 변수 및 시크릿 설정
```bash
# 환경 변수 설정
gcloud run services update cloud-run-app \
    --set-env-vars "ENVIRONMENT=production,DATABASE_URL=mysql://localhost:3306/mydb" \
    --region us-central1

# 시크릿 설정
gcloud run services update cloud-run-app \
    --set-secrets "API_KEY=api-key-secret:latest,DATABASE_PASSWORD=db-password-secret:latest" \
    --region us-central1
```

</details>

<details>
<summary>🔧 3단계: Blue-Green 배포 구현</summary>

#### Blue-Green 배포 스크립트 생성
```bash
# Blue-Green 배포 스크립트 생성
cat > blue-green-deploy.sh << 'EOF'
#!/bin/bash

# Blue-Green 배포 스크립트
SERVICE_NAME="production-service"
CLUSTER_NAME="production-cluster"
TASK_DEFINITION="production-app"

# 현재 서비스 상태 확인
CURRENT_TASK_DEF=$(aws ecs describe-services \
    --cluster $CLUSTER_NAME \
    --services $SERVICE_NAME \
    --query 'services[0].taskDefinition' \
    --output text)

echo "Current task definition: $CURRENT_TASK_DEF"

# 새 태스크 정의 등록
NEW_TASK_DEF=$(aws ecs register-task-definition \
    --cli-input-json file://task-definition.json \
    --query 'taskDefinition.taskDefinitionArn' \
    --output text)

echo "New task definition: $NEW_TASK_DEF"

# Blue-Green 배포 실행
aws ecs update-service \
    --cluster $CLUSTER_NAME \
    --service $SERVICE_NAME \
    --task-definition $NEW_TASK_DEF \
    --deployment-configuration '{
        "maximumPercent": 200,
        "minimumHealthyPercent": 50
    }'

# 배포 상태 모니터링
aws ecs wait services-stable \
    --cluster $CLUSTER_NAME \
    --services $SERVICE_NAME

echo "Blue-Green 배포 완료"
EOF

chmod +x blue-green-deploy.sh
```

#### Canary 배포 구현
```bash
# Canary 배포 스크립트 생성
cat > canary-deploy.sh << 'EOF'
#!/bin/bash

# Canary 배포 스크립트
SERVICE_NAME="production-service"
CLUSTER_NAME="production-cluster"

# 1단계: 10% 트래픽으로 Canary 배포
aws ecs update-service \
    --cluster $CLUSTER_NAME \
    --service $SERVICE_NAME \
    --task-definition production-app:2 \
    --deployment-configuration '{
        "maximumPercent": 110,
        "minimumHealthyPercent": 90
    }'

# 5분 대기
sleep 300

# 2단계: 50% 트래픽으로 확장
aws ecs update-service \
    --cluster $CLUSTER_NAME \
    --service $SERVICE_NAME \
    --task-definition production-app:2 \
    --deployment-configuration '{
        "maximumPercent": 150,
        "minimumHealthyPercent": 50
    }'

# 5분 대기
sleep 300

# 3단계: 100% 트래픽으로 완전 전환
aws ecs update-service \
    --cluster $CLUSTER_NAME \
    --service $SERVICE_NAME \
    --task-definition production-app:2 \
    --deployment-configuration '{
        "maximumPercent": 200,
        "minimumHealthyPercent": 0
    }'

echo "Canary 배포 완료"
EOF

chmod +x canary-deploy.sh
```

</details>

---

## 📚 참고 자료

### 유용한 명령어
```bash
# AWS ECS 관리
aws ecs list-clusters
aws ecs list-services --cluster production-cluster
aws ecs describe-tasks --cluster production-cluster --tasks TASK_ARN

# GCP Cloud Run 관리
gcloud run services list
gcloud run services describe cloud-run-app --region us-central1
gcloud logging read "resource.type=cloud_run_revision" --limit 50

# Docker 관리
docker images
docker ps -a
docker system prune -a
```

### 문제 해결
1. **AWS ECS 서비스 시작 실패**
   - IAM 역할 권한 확인
   - 서브넷 및 보안 그룹 설정 확인
   - 태스크 정의 문법 확인

2. **GCP Cloud Run 배포 실패**
   - 이미지 푸시 상태 확인
   - 서비스 계정 권한 확인
   - 리전 및 리소스 제한 확인

3. **로드 밸런서 연결 실패**
   - 타겟 그룹 상태 확인
   - 보안 그룹 규칙 확인
   - 헬스체크 설정 확인

---

## 🧹 실습 정리

### 자동 정리
```bash
# Day2 클라우드 배포 실습 자동 정리
./cloud_intermediate/repo/automation/day2/cloud-deployment-practice-automation.sh --cleanup
```

### 수동 정리
```bash
# AWS ECS 리소스 정리
aws ecs delete-service --cluster production-cluster --service production-service
aws ecs delete-cluster --cluster production-cluster

# GCP Cloud Run 리소스 정리
gcloud run services delete cloud-run-app --region us-central1

# Docker 리소스 정리
docker system prune -a
```

### 정리 확인
- [ ] AWS ECS 리소스 정리 완료
- [ ] GCP Cloud Run 리소스 정리 완료
- [ ] Docker 리소스 정리 완료
- [ ] 로드 밸런서 정리 완료

---

## 🎯 학습 성과 확인

### 실습 완료 체크리스트
- [ ] AWS ECS 고급 배포 전략 구현 완료
- [ ] Application Load Balancer 설정 완료
- [ ] 자동 스케일링 및 헬스 체크 설정 완료
- [ ] GCP Cloud Run 고급 배포 전략 구현 완료
- [ ] 도메인 매핑 및 SSL 인증서 설정 완료
- [ ] 트래픽 분할 및 카나리 배포 구현 완료
- [ ] Blue-Green 배포 전략 구현 완료

### 다음 단계
- **멀티 클라우드 통합 모니터링** 실습으로 진행
- **실무 프로젝트**에 고급 배포 전략 적용
- **DevOps 문화** 정착 및 자동화 확산

---

**💡 궁금한 점이 있으시면 언제든 문의해주세요!**
**문제가 발생하거나 도움이 필요하시면 실시간으로 지원해드리겠습니다.**
