# 3교시: 클라우드 배포 기초 실습

## 📋 목차
1. [클라우드 배포 개념](#클라우드-배포-개념)
2. [배포 방식 비교](#배포-방식-비교)
3. [실습 목표](#실습-목표)
4. [실습 절차](#실습-절차)
5. [실습 코드 예시](#실습-코드-예시)
6. [예상 결과](#예상-결과)
7. [혼자 해보기](#혼자-해보기)

---

## ☁️ 클라우드 배포 개념

### 클라우드 배포란?

클라우드 배포는 **개발한 애플리케이션을 클라우드 환경에서 실행할 수 있도록 배치하는 과정**입니다.

### 배포의 필요성

#### 로컬 개발의 한계
- 다른 사람이 접근할 수 없음
- 24시간 실행 불가능
- 확장성 부족
- 보안 취약

#### 클라우드 배포의 장점
- **전 세계 접근 가능**: 인터넷이 있는 곳 어디서나 접근
- **24시간 가동**: 서버가 계속 실행되어 서비스 제공
- **자동 확장**: 트래픽 증가 시 자동으로 리소스 확장
- **보안 강화**: 클라우드 제공업체의 보안 인프라 활용

### 주요 배포 방식

| 배포 방식 | 설명 | 장점 | 단점 | 적합한 경우 |
|-----------|------|------|------|-------------|
| **가상머신** | VM에 애플리케이션 배포 | 완전한 제어 가능 | 관리 복잡 | 전통적인 애플리케이션 |
| **컨테이너** | Docker 컨테이너로 배포 | 이식성, 일관성 | 오케스트레이션 필요 | 마이크로서비스 |
| **서버리스** | 함수 단위로 배포 | 비용 효율적, 관리 불필요 | 제한적 | 이벤트 기반 애플리케이션 |
| **PaaS** | 플랫폼에서 직접 배포 | 간단한 배포 | 제한적 커스터마이징 | 웹 애플리케이션 |

---

## 🚀 가상머신 생성 스크립트 사용법

### 스크립트 파일 구조
```
scripts/
├── aws-ec2-create.sh      # AWS EC2 인스턴스 자동 생성
├── gcp-compute-create.sh  # GCP Compute Engine 인스턴스 자동 생성
user-data.sh               # AWS EC2 초기화 스크립트
startup-script.sh          # GCP Compute Engine 초기화 스크립트
```

### 스크립트 특징
- **자동화**: 복잡한 CLI 명령어를 자동으로 실행
- **오류 처리**: 각 단계별 오류 검증 및 처리
- **색상 출력**: 진행 상황을 시각적으로 표시
- **설정 가능**: 변수 수정으로 환경에 맞게 조정 가능
- **안전성**: 기존 리소스 중복 생성 방지

### 사용 전 준비사항
1. **AWS 사용 시:**
   - AWS CLI 설치 및 설정 (`aws configure`)
   - 적절한 IAM 권한 보유
   - 기본 VPC 존재 확인

2. **GCP 사용 시:**
   - Google Cloud CLI 설치 및 설정 (`gcloud auth login`)
   - 프로젝트 설정 (`gcloud config set project PROJECT_ID`)
   - Compute Engine API 활성화

---

## ⚖️ 배포 방식 비교

### 1. AWS 배포 옵션

#### (옵션) AWS EC2 가상머신 생성

**자동화 스크립트 사용 (권장):**

```bash
# 스크립트 실행 권한 부여 (Linux/macOS)
chmod +x scripts/aws-ec2-create.sh

# AWS EC2 인스턴스 자동 생성
./scripts/aws-ec2-create.sh
```

**수동 명령어 실행:**

```bash
# 1. AWS CLI 설정 확인
aws configure list
aws sts get-caller-identity

# 2. 기본 VPC 및 서브넷 확인
aws ec2 describe-vpcs --query 'Vpcs[?IsDefault==`true`]'
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-xxxxxxxx" --query 'Subnets[*].[SubnetId,AvailabilityZone,CidrBlock]'

# 3. 보안 그룹 생성
aws ec2 create-security-group \
    --group-name mcp-cloud-sg \
    --description "Security group for MCP Cloud deployment" \
    --vpc-id vpc-xxxxxxxx

# 4. 보안 그룹 규칙 추가 (SSH, HTTP, HTTPS)
aws ec2 authorize-security-group-ingress \
    --group-id sg-xxxxxxxx \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id sg-xxxxxxxx \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id sg-xxxxxxxx \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

# 5. 키 페어 생성 (없는 경우)
aws ec2 create-key-pair \
    --key-name mcp-cloud-key \
    --query 'KeyMaterial' \
    --output text > mcp-cloud-key.pem

chmod 400 mcp-cloud-key.pem

# 6. EC2 인스턴스 생성
aws ec2 run-instances \
    --image-id ami-0c02fb55956c7d316 \
    --count 1 \
    --instance-type t3.medium \
    --key-name mcp-cloud-key \
    --security-group-ids sg-xxxxxxxx \
    --subnet-id subnet-xxxxxxxx \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=mcp-cloud-server},{Key=Environment,Value=production}]' \
    --user-data file://user-data.sh

# 7. 인스턴스 상태 확인
aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=mcp-cloud-server" \
    --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,PrivateIpAddress]'

# 8. Elastic IP 할당 (선택사항)
aws ec2 allocate-address --domain vpc
aws ec2 associate-address \
    --instance-id i-xxxxxxxx \
    --allocation-id eipalloc-xxxxxxxx

# 9. 인스턴스 연결
ssh -i mcp-cloud-key.pem ec2-user@your-public-ip

# 10. 인스턴스 종료 (정리용)
aws ec2 terminate-instances --instance-ids i-xxxxxxxx
```

**추가 유용한 AWS CLI 명령어들:**
```bash
# 인스턴스 목록 조회
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,PrivateIpAddress,Tags[?Key==`Name`].Value|[0]]' --output table

# 특정 인스턴스 상세 정보
aws ec2 describe-instances --instance-ids i-xxxxxxxx

# 인스턴스 시작/중지
aws ec2 start-instances --instance-ids i-xxxxxxxx
aws ec2 stop-instances --instance-ids i-xxxxxxxx

# 스냅샷 생성
aws ec2 create-snapshot --volume-id vol-xxxxxxxx --description "MCP Cloud backup"

# AMI 생성
aws ec2 create-image --instance-id i-xxxxxxxx --name "mcp-cloud-ami" --description "MCP Cloud AMI"
```

#### AWS CLI 설정 및 인증
```bash
# AWS CLI 설치 (Linux)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# AWS CLI 설정
aws configure
# AWS Access Key ID: [입력]
# AWS Secret Access Key: [입력]
# Default region name: ap-northeast-2 (서울)
# Default output format: json

# 프로필별 설정
aws configure --profile mcp-cloud
aws configure list-profiles

# 환경 변수로 설정
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
export AWS_DEFAULT_REGION=ap-northeast-2

# IAM 역할 사용 (EC2에서 권장)
# 인스턴스에 IAM 역할을 연결하면 별도 설정 불필요
aws sts get-caller-identity
```


#### AWS EC2 (가상머신) - Docker 배포
```bash
# EC2 인스턴스에 Docker로 배포
ssh ec2-user@your-instance.com

# Docker 이미지 다운로드 및 실행
docker pull your-registry/your-app:latest
docker stop your-app || true
docker rm your-app || true
docker run -d -p 80:3000 --name your-app your-registry/your-app:latest

# 또는 Docker Compose 사용
docker-compose up -d
```

#### AWS EC2 (가상머신) - 직접 배포
```bash
# EC2 인스턴스에 직접 배포
ssh ec2-user@your-instance.com
git clone https://github.com/your-repo.git
npm install
npm start
```

#### AWS Elastic Beanstalk (PaaS)
```bash
# EB CLI로 간단 배포
eb init
eb create production
eb deploy
```

#### AWS ECS (컨테이너)
```bash
# ECS에 컨테이너 배포
aws ecs create-service --cluster my-cluster --service-name my-app
```

### 2. GCP 배포 옵션

#### (옵션) GCP Compute Engine 가상머신 생성

**자동화 스크립트 사용 (권장):**

```bash
# 스크립트 실행 권한 부여 (Linux/macOS)
chmod +x scripts/gcp-compute-create.sh

# GCP Compute Engine 인스턴스 자동 생성
./scripts/gcp-compute-create.sh
```

**수동 명령어 실행:**

```bash
# 1. GCP CLI 설정 확인
gcloud auth list
gcloud config list
gcloud projects list

# 2. 프로젝트 설정
gcloud config set project your-project-id
gcloud config set compute/region asia-northeast3
gcloud config set compute/zone asia-northeast3-a

# 3. VPC 네트워크 생성 (선택사항)
gcloud compute networks create mcp-cloud-vpc --subnet-mode custom

# 4. 서브넷 생성
gcloud compute networks subnets create mcp-cloud-subnet \
    --network mcp-cloud-vpc \
    --range 10.0.0.0/24 \
    --region asia-northeast3

# 5. 방화벽 규칙 생성
gcloud compute firewall-rules create allow-ssh \
    --network mcp-cloud-vpc \
    --allow tcp:22 \
    --source-ranges 0.0.0.0/0 \
    --description "Allow SSH access"

gcloud compute firewall-rules create allow-http \
    --network mcp-cloud-vpc \
    --allow tcp:80 \
    --source-ranges 0.0.0.0/0 \
    --description "Allow HTTP access"

gcloud compute firewall-rules create allow-https \
    --network mcp-cloud-vpc \
    --allow tcp:443 \
    --source-ranges 0.0.0.0/0 \
    --description "Allow HTTPS access"

# 6. SSH 키 생성
gcloud compute os-login ssh-keys add --key-file ~/.ssh/id_rsa.pub

# 7. Compute Engine 인스턴스 생성
gcloud compute instances create mcp-cloud-server \
    --zone=asia-northeast3-a \
    --machine-type=e2-medium \
    --network-interface=network-tier=PREMIUM,subnet=mcp-cloud-subnet \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account=your-service-account@your-project.iam.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --create-disk=auto-delete=yes,boot=yes,device-name=mcp-cloud-server,image=projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20231213,mode=rw,size=20,type=projects/your-project/zones/asia-northeast3-a/diskTypes/pd-standard \
    --metadata-from-file startup-script=startup-script.sh \
    --tags=mcp-cloud

# 8. 인스턴스 상태 확인
gcloud compute instances list
gcloud compute instances describe mcp-cloud-server --zone=asia-northeast3-a

# 9. 외부 IP 할당 (선택사항)
gcloud compute addresses create mcp-cloud-ip --region=asia-northeast3
gcloud compute instances add-access-config mcp-cloud-server \
    --zone=asia-northeast3-a \
    --address=mcp-cloud-ip

# 10. 인스턴스 연결
gcloud compute ssh mcp-cloud-server --zone=asia-northeast3-a

# 11. 인스턴스 삭제 (정리용)
gcloud compute instances delete mcp-cloud-server --zone=asia-northeast3-a --quiet
```

#### GCP CLI 설정 및 인증
```bash
# GCP CLI 설치 (Linux)
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# GCP CLI 설치 (macOS)
brew install google-cloud-sdk

# GCP CLI 설치 (Windows)
# https://cloud.google.com/sdk/docs/install-sdk#windows

# 인증 설정
gcloud auth login
gcloud auth application-default login

# 프로젝트 설정
gcloud projects list
gcloud config set project your-project-id

# 서비스 계정 키 사용
gcloud auth activate-service-account --key-file=path/to/service-account-key.json

# 환경 변수로 설정
export GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account-key.json"
export GOOGLE_CLOUD_PROJECT="your-project-id"
```

#### Google Compute Engine (가상머신) - Docker 배포
```bash
# GCE 인스턴스에 Docker로 배포
gcloud compute ssh mcp-cloud-server --zone=asia-northeast3-a

# Docker 이미지 다운로드 및 실행
docker pull your-registry/your-app:latest
docker stop your-app || true
docker rm your-app || true
docker run -d -p 80:3000 --name your-app your-registry/your-app:latest

# 또는 Docker Compose 사용
docker-compose up -d
```

#### Google Compute Engine (가상머신) - 직접 배포
```bash
# GCE 인스턴스에 직접 배포
gcloud compute ssh my-instance
git clone https://github.com/your-repo.git
npm install && npm start
```

#### Google App Engine (PaaS)
```bash
# App Engine에 배포
gcloud app deploy
```

#### Google Cloud Run (서버리스 컨테이너)
```bash
# Cloud Run에 컨테이너 배포
gcloud run deploy --source .

# 추가 유용한 GCP CLI 명령어들
# 인스턴스 목록 조회
gcloud compute instances list --format="table(name,zone,machineType,status,EXTERNAL_IP)"

# 특정 인스턴스 상세 정보
gcloud compute instances describe mcp-cloud-server --zone=asia-northeast3-a

# 인스턴스 시작/중지
gcloud compute instances start mcp-cloud-server --zone=asia-northeast3-a
gcloud compute instances stop mcp-cloud-server --zone=asia-northeast3-a

# 스냅샷 생성
gcloud compute disks snapshot mcp-cloud-server \
    --snapshot-names=mcp-cloud-backup \
    --zone=asia-northeast3-a

# 이미지 생성
gcloud compute images create mcp-cloud-image \
    --source-disk=mcp-cloud-server \
    --source-disk-zone=asia-northeast3-a

# 방화벽 규칙 목록
gcloud compute firewall-rules list

# 네트워크 목록
gcloud compute networks list

# 서브넷 목록
gcloud compute networks subnets list
```

#### 추가 유용한 클라우드 CLI 명령어들

##### AWS S3 관리
```bash
# S3 버킷 생성
aws s3 mb s3://mcp-cloud-bucket

# 파일 업로드
aws s3 cp local-file.txt s3://mcp-cloud-bucket/

# 파일 다운로드
aws s3 cp s3://mcp-cloud-bucket/file.txt ./

# 버킷 목록
aws s3 ls

# 버킷 내용 조회
aws s3 ls s3://mcp-cloud-bucket/

# 버킷 삭제
aws s3 rb s3://mcp-cloud-bucket --force
```

##### GCP Cloud Storage 관리
```bash
# Cloud Storage 버킷 생성
gsutil mb gs://mcp-cloud-bucket

# 파일 업로드
gsutil cp local-file.txt gs://mcp-cloud-bucket/

# 파일 다운로드
gsutil cp gs://mcp-cloud-bucket/file.txt ./

# 버킷 목록
gsutil ls

# 버킷 내용 조회
gsutil ls gs://mcp-cloud-bucket/

# 버킷 삭제
gsutil rm -r gs://mcp-cloud-bucket
```

##### Docker 및 컨테이너 관리
```bash
# Docker 이미지 빌드
docker build -t mcp-cloud-app .

# Docker 이미지 태그 지정
docker tag mcp-cloud-app:latest your-registry/mcp-cloud-app:latest

# Docker 이미지 푸시
docker push your-registry/mcp-cloud-app:latest

# 실행 중인 컨테이너 목록
docker ps

# 모든 컨테이너 목록
docker ps -a

# 컨테이너 로그 확인
docker logs container-name

# 컨테이너 실행
docker run -d -p 3000:3000 --name mcp-app mcp-cloud-app

# 컨테이너 중지 및 삭제
docker stop mcp-app
docker rm mcp-app

# Docker Compose 사용
docker-compose up -d
docker-compose down
docker-compose logs
```

##### Kubernetes 관리 (kubectl)
```bash
# 클러스터 정보 확인
kubectl cluster-info

# 노드 목록
kubectl get nodes

# 파드 목록
kubectl get pods

# 서비스 목록
kubectl get services

# 배포 목록
kubectl get deployments

# 파드 로그 확인
kubectl logs pod-name

# 파드에 접속
kubectl exec -it pod-name -- /bin/bash

# 매니페스트 적용
kubectl apply -f deployment.yaml

# 매니페스트 삭제
kubectl delete -f deployment.yaml
```

---

## 🎯 실습 목표

이 실습을 통해 다음을 달성합니다:

1. **배포 개념 이해**: 클라우드 배포의 기본 개념과 필요성을 이해합니다.

2. **간단한 배포 실습**: GitHub Actions를 통해 간단한 배포를 자동화합니다.

3. **배포 결과 확인**: 배포된 애플리케이션이 정상 동작하는지 확인합니다.

4. **배포 방식 비교**: 다양한 배포 방식의 특징을 이해합니다.

---

## 📝 실습 절차

### 1단계: 배포 환경 준비

#### GitHub Actions 워크플로우 수정
기존 `deploy.yml` 파일을 수정하여 실제 배포 시뮬레이션을 추가합니다.

```yaml
# .github/workflows/deploy.yml
name: Deploy to Cloud

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    name: Deploy Application
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run tests
        run: npm test
      
      - name: Build application
        run: npm run build
      
      # 배포 시뮬레이션
      - name: Deploy to AWS EC2 with Docker (Simulation)
        run: |
          echo "🚀 Deploying to AWS EC2 with Docker..."
          echo "📦 Application: actions-demo"
          echo "🌍 Environment: production"
          echo "📊 Version: ${{ github.sha }}"
          echo "🐳 Building Docker image..."
          echo "🐳 Pushing to Docker Hub..."
          echo "🖥️  Connecting to EC2 instance..."
          echo "🐳 Pulling Docker image on EC2..."
          echo "🚀 Starting container on EC2..."
          echo "✅ AWS EC2 Docker deployment completed successfully!"
      
      - name: Deploy to GCP GCE with Docker (Simulation)
        run: |
          echo "🚀 Deploying to GCP GCE with Docker..."
          echo "📦 Application: actions-demo"
          echo "🌍 Environment: production"
          echo "📊 Version: ${{ github.sha }}"
          echo "🐳 Building Docker image..."
          echo "🐳 Pushing to Docker Hub..."
          echo "🖥️  Connecting to GCE instance..."
          echo "🐳 Pulling Docker image on GCE..."
          echo "🚀 Starting container on GCE..."
          echo "✅ GCP GCE Docker deployment completed successfully!"
      
      - name: Health Check
        run: |
          echo "🔍 Performing health check..."
          echo "✅ Application is running successfully!"
          echo "🌐 Service URL: https://your-app.com"
          echo "📈 Status: Healthy"
      
      - name: Deployment Summary
        run: |
          echo "=== 🎉 Deployment Summary ==="
          echo "Application: actions-demo"
          echo "Version: ${{ github.sha }}"
          echo "AWS Status: ✅ Success"
          echo "GCP Status: ✅ Success"
          echo "Health Check: ✅ Passed"
          echo "Deployment Time: $(date)"
```

### 2단계: 배포 워크플로우 실행

#### 코드 커밋 및 푸시
```bash
# 변경사항 커밋
git add .
git commit -m "Add cloud deployment simulation"
git push origin main
```

#### GitHub Actions 실행 확인
1. GitHub 저장소 → Actions 탭
2. "Deploy to Cloud" 워크플로우 실행 확인
3. 각 단계별 로그 확인

### 3단계: 배포 결과 분석

#### 성공적인 배포 확인
- ✅ AWS 배포 시뮬레이션 완료
- ✅ GCP 배포 시뮬레이션 완료
- ✅ 헬스체크 통과
- ✅ 배포 요약 출력

---

## 💻 실습 코드 예시

### 배포 상태 확인 스크립트

```bash
#!/bin/bash
# deploy-check.sh

echo "🔍 Checking deployment status..."

# 애플리케이션 상태 확인
echo "📊 Application Status:"
echo "  - Name: actions-demo"
echo "  - Version: $GITHUB_SHA"
echo "  - Environment: production"
echo "  - Status: Running"

# 서비스 엔드포인트 확인
echo "🌐 Service Endpoints:"
echo "  - AWS: https://aws.your-app.com"
echo "  - GCP: https://gcp.your-app.com"

# 헬스체크
echo "🔍 Health Check:"
curl -f https://your-app.com/health && echo "✅ Healthy" || echo "❌ Unhealthy"

echo "✅ Deployment check completed!"
```

### 배포 알림 스크립트

```bash
#!/bin/bash
# notify-deployment.sh

DEPLOYMENT_STATUS=$1
APPLICATION_NAME="actions-demo"
VERSION=$GITHUB_SHA

if [ "$DEPLOYMENT_STATUS" = "success" ]; then
    echo "🎉 Deployment Successful!"
    echo "📦 Application: $APPLICATION_NAME"
    echo "📊 Version: $VERSION"
    echo "🌍 Environment: production"
    echo "⏰ Time: $(date)"
else
    echo "❌ Deployment Failed!"
    echo "📦 Application: $APPLICATION_NAME"
    echo "📊 Version: $VERSION"
    echo "🔍 Check logs for details"
fi
```

---

## 📊 예상 결과

### 성공적인 배포 시

```
🚀 Deploying to AWS EC2 with Docker...
📦 Application: actions-demo
🌍 Environment: production
📊 Version: abc123def456
🐳 Building Docker image...
🐳 Pushing to Docker Hub...
🖥️  Connecting to EC2 instance...
🐳 Pulling Docker image on EC2...
🚀 Starting container on EC2...
✅ AWS EC2 Docker deployment completed successfully!

🚀 Deploying to GCP GCE with Docker...
📦 Application: actions-demo
🌍 Environment: production
📊 Version: abc123def456
🐳 Building Docker image...
🐳 Pushing to Docker Hub...
🖥️  Connecting to GCE instance...
🐳 Pulling Docker image on GCE...
🚀 Starting container on GCE...
✅ GCP GCE Docker deployment completed successfully!

🔍 Performing health check...
✅ Application is running successfully!
🌐 Service URL: https://your-app.com
📈 Status: Healthy

=== 🎉 Deployment Summary ===
Application: actions-demo
Version: abc123def456
AWS EC2 Docker Status: ✅ Success
GCP GCE Docker Status: ✅ Success
Health Check: ✅ Passed
Deployment Time: 2024-01-15 14:30:25
```

### GitHub Actions 실행 결과

- **워크플로우 상태**: ✅ Success
- **실행 시간**: 약 2-3분
- **배포 단계**: 모두 성공
- **알림**: Slack 또는 이메일 발송 (설정된 경우)

---

## 🏃‍♂️ 혼자 해보기

### 기본 실습
1. **배포 시뮬레이션 확장**: 더 많은 배포 단계 추가
2. **환경별 배포**: staging, production 환경 구분
3. **배포 롤백**: 실패 시 이전 버전으로 복구

### 고급 실습
1. **실제 VM 배포**: AWS EC2/GCP GCE에 Docker로 실제 배포
2. **배포 전략**: Blue-Green, Canary 배포 구현
3. **모니터링 연동**: 배포 후 자동 모니터링 설정
4. **Docker Compose 활용**: 복잡한 애플리케이션 스택 배포

### 실무 적용
1. **팀 프로젝트**: 실제 프로젝트에 배포 파이프라인 적용
2. **CI/CD 완성**: 테스트 → 빌드 → 배포 전체 자동화
3. **배포 최적화**: 배포 시간 단축 및 안정성 향상

---

## 🔧 문제 해결

### 배포 실패 시
```bash
# 로그 확인
# GitHub Actions → 해당 워크플로우 → 실패한 Job 클릭

# 일반적인 문제들
1. 권한 부족: GitHub 시크릿 설정 확인
2. 네트워크 문제: 인터넷 연결 확인
3. 코드 오류: 테스트 실패 시 코드 수정
4. SSH 연결 실패: VM 접근 권한 및 키 확인
5. Docker 이미지 푸시 실패: Docker Hub 토큰 확인
```

### VM Docker 배포 문제 해결

#### SSH 연결 문제
```bash
# SSH 키 권한 확인
chmod 600 ~/.ssh/id_rsa

# SSH 연결 테스트
ssh -i ~/.ssh/id_rsa user@your-vm-ip

# GitHub 시크릿 확인
# AWS_EC2_HOST, AWS_EC2_USER, AWS_EC2_SSH_KEY
# GCP_GCE_HOST, GCP_GCE_USER, GCP_GCE_SSH_KEY
```

#### Docker 이미지 문제
```bash
# Docker Hub 로그인 확인
docker login

# 이미지 존재 확인
docker pull your-registry/your-app:tag

# 컨테이너 상태 확인
docker ps -a
docker logs container-name
```

### 성능 최적화
```bash
# 배포 시간 단축
1. 캐시 활용: npm cache, Docker layer cache
2. 병렬 실행: 여러 Job을 동시에 실행
3. 불필요한 단계 제거: 최소한의 단계만 실행
```

---

## 📚 다음 단계

이 3교시를 완료하면 다음을 학습할 수 있습니다:

- **4교시**: 전체 자동 배포 파이프라인 구성
- **Advanced 과정**: 실제 클라우드 오케스트레이션 (ECS/GKE)
- **실무 적용**: 팀 프로젝트에 VM Docker 배포 적용

## 🔗 관련 파일

- **VM Docker 배포 워크플로우**: `actions-demo/.github/workflows/vm-docker-deploy.yml`
- **Docker Compose 예시**: `actions-demo/docker-compose.yml`
- **SSH 키 설정 가이드**: `aws-gcp-permissions-setup.md`

**🎯 목표**: 클라우드 배포의 기본 개념을 이해하고, GitHub Actions를 통한 자동 배포 파이프라인을 구축할 수 있습니다.
