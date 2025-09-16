<div align="center">

## 🏠 최상위 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

## 📖 현재 위치
**Cloud Master** > **1일차** > **AWS & GCP 권한 설정 가이드**

## ⬅️ 이전/다음 네비게이션
[← 이전: Cloud Master 메인](/mcp_knowledge_base/cloud_master/README.md) | [다음: Cloud Master 1일차 →](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md)

</div>


# AWS & GCP 권한 설정 가이드



## 📋 목차
1. [AWS 권한 설정](#aws-권한-설정)
2. [GCP 권한 설정](#gcp-권한-설정)
3. [GitHub 시크릿 설정](#github-시크릿-설정)
4. [권한 테스트](#권한-테스트)
5. [문제 해결](#문제-해결)

---

## 🔐 AWS 권한 설정

### 1. AWS IAM 사용자 생성

#### AWS CLI를 사용한 방법
```bash
# IAM 사용자 생성
aws iam create-user --user-name github-actions-deploy

# 액세스 키 생성
aws iam create-access-key --user-name github-actions-deploy
```

#### AWS 콘솔을 사용한 방법
1. AWS 콘솔 → IAM → 사용자 → 사용자 생성
2. 사용자 이름: `github-actions-deploy`
3. 액세스 유형: 프로그래밍 방식 액세스
4. 액세스 키 ID와 시크릿 액세스 키 저장

### 2. 필요한 IAM 정책 생성

#### ECS 배포를 위한 정책
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecs:UpdateService",
                "ecs:DescribeServices",
                "ecs:DescribeTaskDefinition",
                "ecs:RegisterTaskDefinition",
                "ecs:ListTasks",
                "ecs:DescribeTasks",
                "ecs:RunTask",
                "ecs:StopTask"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams"
            ],
            "Resource": "*"
        }
    ]
}
```

#### 정책 생성 및 연결
```bash
# 정책 생성
aws iam create-policy \
    --policy-name GitHubActionsECSPolicy \
    --policy-document file://ecs-policy.json

# 사용자에게 정책 연결
aws iam attach-user-policy \
    --user-name github-actions-deploy \
    --policy-arn arn:aws:iam::ACCOUNT_ID:policy/GitHubActionsECSPolicy
```

### 3. ECS 리소스 생성

#### ECS 클러스터 생성
```bash
# Fargate 클러스터 생성
aws ecs create-cluster \
    --cluster-name actions-demo-cluster \
    --capacity-providers FARGATE \
    --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1
```

#### 태스크 실행 역할 생성
```bash
# 태스크 실행 역할 생성
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
    }'

# AmazonECSTaskExecutionRolePolicy 연결
aws iam attach-role-policy \
    --role-name ecsTaskExecutionRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
```

#### 태스크 정의 생성
```json
{
    "family": "actions-demo",
    "networkMode": "awsvpc",
    "requiresCompatibilities": ["FARGATE"],
    "cpu": "256",
    "memory": "512",
    "executionRoleArn": "arn:aws:iam::ACCOUNT_ID:role/ecsTaskExecutionRole",
    "containerDefinitions": [
        {
            "name": "actions-demo",
            "image": "nginx:latest",
            "portMappings": [
                {
                    "containerPort": 3000,
                    "protocol": "tcp"
                }
            ],
            "essential": true,
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/actions-demo",
                    "awslogs-region": "ap-northeast-2",
                    "awslogs-stream-prefix": "ecs"
                }
            }
        }
    ]
}
```

```bash
# 태스크 정의 등록
aws ecs register-task-definition --cli-input-json file://task-definition.json

# CloudWatch 로그 그룹 생성
aws logs create-log-group --log-group-name /ecs/actions-demo
```

#### ECS 서비스 생성
```bash
# 서브넷과 보안 그룹 ID 확인
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-12345" --query 'Subnets[0].SubnetId'
aws ec2 describe-security-groups --filters "Name=group-name,Values=default" --query 'SecurityGroups[0].GroupId'

# ECS 서비스 생성
aws ecs create-service \
    --cluster actions-demo-cluster \
    --service-name actions-demo-service \
    --task-definition actions-demo:1 \
    --desired-count 1 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[subnet-12345],securityGroups=[sg-12345],assignPublicIp=ENABLED}"
```

---

## ☁️ GCP 권한 설정

### 1. GCP 프로젝트 설정

#### 프로젝트 ID 확인
```bash
# 현재 프로젝트 확인
gcloud config get-value project

# 프로젝트 설정 (필요한 경우)
gcloud config set project YOUR_PROJECT_ID
```

### 2. 서비스 계정 생성

#### 서비스 계정 생성
```bash
# 서비스 계정 생성
gcloud iam service-accounts create github-actions-deploy \
    --display-name="GitHub Actions Deploy" \
    --description="Service account for GitHub Actions deployment"
```

#### 필요한 권한 부여
```bash
# Cloud Run Admin 권한
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:github-actions-deploy@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/run.admin"

# Storage Admin 권한 (Container Registry용)
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:github-actions-deploy@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

# Service Account User 권한
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:github-actions-deploy@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountUser"

# Cloud Build 권한 (이미지 빌드용)
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:github-actions-deploy@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/cloudbuild.builds.builder"
```

### 3. 서비스 계정 키 생성

#### JSON 키 파일 생성
```bash
# 서비스 계정 키 생성
gcloud iam service-accounts keys create key.json \
    --iam-account=github-actions-deploy@YOUR_PROJECT_ID.iam.gserviceaccount.com

# 키 파일 내용 확인
cat key.json
```

### 4. 필요한 API 활성화

#### API 활성화
```bash
# Cloud Run API 활성화
gcloud services enable run.googleapis.com

# Container Registry API 활성화
gcloud services enable containerregistry.googleapis.com

# Cloud Build API 활성화
gcloud services enable cloudbuild.googleapis.com
```

### 5. Cloud Run 서비스 초기 생성

#### 첫 번째 배포 (서비스 생성)
```bash
# Cloud Run 서비스 생성
gcloud run deploy actions-demo \
    --image nginx:latest \
    --region asia-northeast1 \
    --platform managed \
    --allow-unauthenticated \
    --port 3000 \
    --memory 512Mi \
    --cpu 1 \
    --min-instances 0 \
    --max-instances 10
```

---

## 🔑 GitHub 시크릿 설정

### 1. GitHub 시크릿 설정 방법

#### 저장소 시크릿 설정
1. GitHub 저장소 → Settings → Secrets and variables → Actions
2. "New repository secret" 클릭
3. Name과 Value 입력 후 "Add secret" 클릭

### 2. AWS 관련 시크릿

```
AWS_ACCESS_KEY_ID: AKIA...
AWS_SECRET_ACCESS_KEY: ...
AWS_REGION: ap-northeast-2
AWS_ECS_CLUSTER: actions-demo-cluster
AWS_ECS_SERVICE: actions-demo-service
AWS_ECS_TASK_DEFINITION: actions-demo
```

### 3. GCP 관련 시크릿

```
GCP_PROJECT_ID: your-project-id
GCP_SA_KEY: {"type":"service_account",...}
GCP_REGION: asia-northeast1
GCP_SERVICE_NAME: actions-demo
```

### 4. 공통 시크릿

```
DOCKERHUB_TOKEN: your-dockerhub-token
SLACK_WEBHOOK_URL: https://hooks.slack.com/... (선택사항)
```

---

## 🧪 권한 테스트

### 1. AWS 권한 테스트

#### AWS CLI 테스트
```bash
# AWS 자격 증명 설정
export AWS_ACCESS_KEY_ID=AKIA...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=ap-northeast-2

# ECS 클러스터 확인
aws ecs describe-clusters --clusters actions-demo-cluster

# ECS 서비스 확인
aws ecs describe-services \
    --cluster actions-demo-cluster \
    --services actions-demo-service

# ECR 로그인 테스트
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.ap-northeast-2.amazonaws.com
```

### 2. GCP 권한 테스트

#### gcloud CLI 테스트
```bash
# 서비스 계정 인증
gcloud auth activate-service-account \
    --key-file=key.json \
    --project=YOUR_PROJECT_ID

# Cloud Run 서비스 확인
gcloud run services list --region=asia-northeast1

# Container Registry 접근 테스트
gcloud auth configure-docker
docker pull gcr.io/YOUR_PROJECT_ID/actions-demo:latest
```

---

## 🔧 문제 해결

### AWS 문제 해결

#### 1. ECS 서비스 업데이트 실패
```bash
# 서비스 상태 확인
aws ecs describe-services \
    --cluster actions-demo-cluster \
    --services actions-demo-service \
    --query 'services[0].{Status:status,RunningCount:runningCount,DesiredCount:desiredCount}'

# 태스크 상태 확인
aws ecs list-tasks \
    --cluster actions-demo-cluster \
    --service-name actions-demo-service
```

#### 2. IAM 권한 문제
```bash
# 사용자 정책 확인
aws iam list-attached-user-policies --user-name github-actions-deploy

# 정책 내용 확인
aws iam get-policy --policy-arn arn:aws:iam::ACCOUNT_ID:policy/GitHubActionsECSPolicy
aws iam get-policy-version \
    --policy-arn arn:aws:iam::ACCOUNT_ID:policy/GitHubActionsECSPolicy \
    --version-id v1
```

#### 3. ECR 접근 문제
```bash
# ECR 리포지토리 확인
aws ecr describe-repositories

# ECR 리포지토리 생성 (필요한 경우)
aws ecr create-repository --repository-name actions-demo
```

### GCP 문제 해결

#### 1. Cloud Run 배포 실패
```bash
# 서비스 상태 확인
gcloud run services describe actions-demo \
    --region asia-northeast1 \
    --format "value(status.conditions[0].status)"

# 로그 확인
gcloud logging read "resource.type=cloud_run_revision" \
    --limit 50 \
    --format json
```

#### 2. 서비스 계정 권한 문제
```bash
# 서비스 계정 권한 확인
gcloud projects get-iam-policy YOUR_PROJECT_ID \
    --flatten="bindings[].members" \
    --format="table(bindings.role)" \
    --filter="bindings.members:github-actions-deploy@YOUR_PROJECT_ID.iam.gserviceaccount.com"
```

#### 3. Container Registry 접근 문제
```bash
# Container Registry 권한 확인
gsutil iam get gs://artifacts.YOUR_PROJECT_ID.appspot.com

# Docker 인증 확인
gcloud auth configure-docker
docker pull gcr.io/YOUR_PROJECT_ID/actions-demo:latest
```

### 일반적인 문제들

| 문제 | 원인 | 해결 방법 |
|------|------|-----------|
| AWS ECS 업데이트 실패 | IAM 권한 부족 | ECS 관련 권한 추가 |
| GCP Cloud Run 배포 실패 | 서비스 계정 권한 부족 | Cloud Run Admin 권한 추가 |
| Docker 이미지 푸시 실패 | 인증 문제 | Docker Hub 토큰 또는 GCR 인증 확인 |
| 워크플로우 실행 안됨 | 시크릿 설정 누락 | 모든 필요한 시크릿 확인 |

---

## 📚 추가 자료

- [AWS ECS IAM 권한 가이드](https://docs.aws.amazon.com/ecs/latest/developerguide/security-iam.html)
- [GCP Cloud Run IAM 가이드](https://cloud.google.com/run/docs/iam)
- [GitHub Actions 시크릿 관리](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Docker Hub 액세스 토큰](https://docs.docker.com/docker-hub/access-tokens/)

---



---

<div align="center">

## 🔗 관련 과정 및 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

## 📖 현재 위치
**Cloud Master** > **1일차** > **AWS & GCP 권한 설정 가이드**

## ⬅️ 이전/다음 네비게이션
[← 이전: Cloud Master 메인](/mcp_knowledge_base/cloud_master/README.md) | [다음: Cloud Master 1일차 →](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md)

## 🔗 관련 과정
[Cloud Basic 2일차](/mcp_knowledge_base/cloud_basic/textbook/Day2/README.md) | [Cloud Container 1일차](/mcp_knowledge_base/cloud_container/textbook/Day1/README.md)

</div>