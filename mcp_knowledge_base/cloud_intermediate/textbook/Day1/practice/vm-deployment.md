# VM 기반 웹 애플리케이션 배포 실습

<details>
<summary>📋 목차</summary>

1. [🎯 학습 목표](#-학습-목표)
2. [📚 실습 개요](#-실습-개요)
3. [🔧 실습 환경 준비](#-실습-환경-준비)
4. [☁️ AWS EC2 배포](#-aws-ec2-배포)
5. [☁️ GCP Compute Engine 배포](#-gcp-compute-engine-배포)
6. [🔧 자동화된 배포](#-자동화된-배포)
7. [📚 문제 해결 및 참고 자료](#-문제-해결-및-참고-자료)

</details>

---

## 🎯 학습 목표

<details>
<summary>📖 이번 실습에서 배우게 될 내용</summary>

### 핵심 학습 목표
- **VM 기반 배포** AWS EC2, GCP Compute Engine 활용
- **Docker 컨테이너** VM 환경에서 실행
- **자동화된 배포** GitHub Actions를 통한 자동 배포
- **웹 애플리케이션** 완전한 배포 파이프라인

### 실습 후 달성할 수 있는 능력
- ✅ AWS EC2에 웹 애플리케이션 배포
- ✅ GCP Compute Engine에 웹 애플리케이션 배포
- ✅ Docker 컨테이너를 VM에서 실행
- ✅ 자동화된 배포 파이프라인 구축

### 예상 소요 시간
- **AWS EC2 배포**: 90-120분
- **GCP Compute Engine 배포**: 90-120분
- **자동화된 배포**: 60-90분
- **종합 실습**: 60-90분
- **전체 과정**: 5-7시간

</details>

---

## 📚 실습 개요

<details>
<summary>📖 실습 개요</summary>

### 실습 구성
1. **AWS EC2 배포** (120분)
2. **GCP Compute Engine 배포** (120분)
3. **자동화된 배포** (90분)
4. **종합 실습** (90분)

### 실습 방식
- **수동 배포**: CLI를 통한 단계별 배포
- **자동 배포**: GitHub Actions를 통한 자동화
- **비교 실습**: AWS와 GCP 동시 실습

### 실습 결과물
- AWS EC2에 배포된 웹 애플리케이션
- GCP Compute Engine에 배포된 웹 애플리케이션
- 자동화된 배포 파이프라인

</details>

---

## 🔧 실습 환경 준비

<details>
<summary>📋 필수 계정 및 도구</summary>

### 필수 계정
- **AWS 계정**: Free Tier 계정
- **GCP 계정**: $300 크레딧 계정
- **GitHub 계정**: 저장소 관리 및 Actions 사용
- **Docker Hub 계정**: 컨테이너 이미지 저장소

### 필수 도구
- **AWS CLI**: AWS 서비스 관리
- **gcloud CLI**: Google Cloud 서비스 관리
- **Docker**: 컨테이너 이미지 빌드
- **Git**: 버전 관리

</details>

<details>
<summary>🔧 CLI 도구 설정</summary>

### AWS CLI 설정
```bash
# AWS CLI 설정
aws configure
# AWS Access Key ID: [입력]
# AWS Secret Access Key: [입력]
# Default region name: ap-northeast-2
# Default output format: json

# 설정 확인
aws sts get-caller-identity
```

### gcloud CLI 설정
```bash
# gcloud 초기화
gcloud init

# 프로젝트 설정
gcloud config set project YOUR_PROJECT_ID

# 설정 확인
gcloud config list
```

</details>

---

## ☁️ AWS EC2 배포

<details>
<summary>📖 AWS EC2 배포 전략</summary>

### 배포 방식
- **Docker 이미지**: Docker Hub에서 이미지 풀
- **EC2 인스턴스**: t3.micro (Free Tier)
- **보안 그룹**: HTTP(80), HTTPS(443), SSH(22) 포트 열기
- **사용자 데이터**: Docker 설치 및 애플리케이션 실행

### 배포 아키텍처
```
Internet → Security Group → EC2 Instance → Docker Container
```

</details>

<details>
<summary>🔗 EC2 인스턴스 생성</summary>

### 1단계: 키 페어 생성
```bash
# 키 페어 생성
aws ec2 create-key-pair \
    --key-name my-app-key \
    --query 'KeyMaterial' \
    --output text > my-app-key.pem

# 키 파일 권한 설정
chmod 400 my-app-key.pem
```

### 2단계: 보안 그룹 생성
```bash
# VPC ID 확인
VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=is-default,Values=true" \
    --query 'Vpcs[0].VpcId' \
    --output text)

# 보안 그룹 생성
aws ec2 create-security-group \
    --group-name my-app-sg \
    --description "Security group for my app" \
    --vpc-id $VPC_ID

# HTTP 포트 열기
aws ec2 authorize-security-group-ingress \
    --group-name my-app-sg \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

# SSH 포트 열기
aws ec2 authorize-security-group-ingress \
    --group-name my-app-sg \
    --protocol tcp \
    --port 22 \
    --cidr YOUR_IP/32
```

### 3단계: EC2 인스턴스 생성
```bash
# 사용자 데이터 스크립트 생성
cat > user-data.sh << 'EOF'
#!/bin/bash
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Docker Compose 설치
curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# 애플리케이션 디렉토리 생성
mkdir -p /opt/my-app
cd /opt/my-app

# Docker Compose 파일 생성
cat > docker-compose.yml << 'DOCKERFILE'
version: '3.8'
services:
  web:
    image: your-username/my-app:latest
    ports:
      - "80:3000"
    environment:
      - NODE_ENV=production
    restart: unless-stopped
DOCKERFILE

# 애플리케이션 시작
docker-compose up -d
EOF

# EC2 인스턴스 생성
aws ec2 run-instances \
    --image-id ami-0ae2c887094315bed \
    --count 1 \
    --instance-type t3.micro \
    --key-name my-app-key \
    --security-groups my-app-sg \
    --user-data file://user-data.sh \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=my-app}]'
```

</details>

<details>
<summary>🔗 애플리케이션 배포</summary>

### 4단계: 인스턴스 상태 확인
```bash
# 인스턴스 상태 확인
aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=my-app" \
    --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]'

# 인스턴스가 실행될 때까지 대기
aws ec2 wait instance-running \
    --instance-ids i-xxxxxxxx
```

### 5단계: 애플리케이션 배포
```bash
# 퍼블릭 IP 확인
PUBLIC_IP=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=my-app" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

# SSH 접속
ssh -i my-app-key.pem ec2-user@$PUBLIC_IP

# Docker 이미지 풀
docker pull your-username/my-app:latest

# 기존 컨테이너 중지
docker stop my-app || true
docker rm my-app || true

# 새 컨테이너 실행
docker run -d \
    --name my-app \
    --restart unless-stopped \
    -p 80:3000 \
    -e NODE_ENV=production \
    your-username/my-app:latest
```

</details>

---

## ☁️ GCP Compute Engine 배포

<details>
<summary>📖 GCP Compute Engine 배포 전략</summary>

### 배포 방식
- **Docker 이미지**: Docker Hub에서 이미지 풀
- **Compute Engine**: e2-micro (Free Tier)
- **방화벽 규칙**: HTTP(80), HTTPS(443), SSH(22) 포트 열기
- **시작 스크립트**: Docker 설치 및 애플리케이션 실행

### 배포 아키텍처
```
Internet → Firewall Rules → Compute Engine → Docker Container
```

</details>

<details>
<summary>🔗 Compute Engine 인스턴스 생성</summary>

### 1단계: 방화벽 규칙 생성
```bash
# HTTP 방화벽 규칙 생성
gcloud compute firewall-rules create allow-http \
    --allow tcp:80 \
    --source-ranges 0.0.0.0/0 \
    --target-tags http-server

# SSH 방화벽 규칙 생성
gcloud compute firewall-rules create allow-ssh \
    --allow tcp:22 \
    --source-ranges 0.0.0.0/0 \
    --target-tags ssh-server
```

### 2단계: 시작 스크립트 생성
```bash
# 시작 스크립트 생성
cat > startup-script.sh << 'EOF'
#!/bin/bash
apt-get update
apt-get install -y docker.io docker-compose
systemctl start docker
systemctl enable docker
usermod -a -G docker $USER

# 애플리케이션 디렉토리 생성
mkdir -p /opt/my-app
cd /opt/my-app

# Docker Compose 파일 생성
cat > docker-compose.yml << 'DOCKERFILE'
version: '3.8'
services:
  web:
    image: your-username/my-app:latest
    ports:
      - "80:3000"
    environment:
      - NODE_ENV=production
    restart: unless-stopped
DOCKERFILE

# 애플리케이션 시작
docker-compose up -d
EOF
```

### 3단계: Compute Engine 인스턴스 생성
```bash
# 인스턴스 생성
gcloud compute instances create my-app-instance \
    --zone=asia-northeast3-a \
    --machine-type=e2-micro \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=10GB \
    --metadata-from-file startup-script=startup-script.sh \
    --tags=http-server,ssh-server
```

</details>

<details>
<summary>🔗 애플리케이션 배포</summary>

### 4단계: 인스턴스 상태 확인
```bash
# 인스턴스 상태 확인
gcloud compute instances list

# 인스턴스 상세 정보
gcloud compute instances describe my-app-instance \
    --zone=asia-northeast3-a
```

### 5단계: 애플리케이션 배포
```bash
# SSH 접속
gcloud compute ssh my-app-instance --zone=asia-northeast3-a

# Docker 이미지 풀
docker pull your-username/my-app:latest

# 기존 컨테이너 중지
docker stop my-app || true
docker rm my-app || true

# 새 컨테이너 실행
docker run -d \
    --name my-app \
    --restart unless-stopped \
    -p 80:3000 \
    -e NODE_ENV=production \
    your-username/my-app:latest
```

</details>

---

## 🔧 자동화된 배포

<details>
<summary>📖 GitHub Actions 자동 배포</summary>

### 자동 배포 파이프라인
1. **코드 푸시** → GitHub 저장소
2. **자동 빌드** → Docker 이미지 빌드
3. **이미지 푸시** → Docker Hub 업로드
4. **VM 배포** → EC2/Compute Engine 자동 배포

### 워크플로우 구성
```yaml
name: Deploy to VM

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  deploy-aws:
    runs-on: ubuntu-latest
    steps:
    - name: Deploy to AWS EC2
      uses: appleboy/ssh-action@v1.0.0
      with:
        host: ${{ secrets.AWS_EC2_HOST }}
        username: ${{ secrets.AWS_EC2_USERNAME }}
        key: ${{ secrets.AWS_EC2_SSH_KEY }}
        script: |
          docker pull ${{ secrets.DOCKERHUB_USERNAME }}/my-app:latest
          docker stop my-app || true
          docker rm my-app || true
          docker run -d \
            --name my-app \
            --restart unless-stopped \
            -p 80:3000 \
            -e NODE_ENV=production \
            ${{ secrets.DOCKERHUB_USERNAME }}/my-app:latest

  deploy-gcp:
    runs-on: ubuntu-latest
    steps:
    - name: Deploy to GCP Compute Engine
      run: |
        gcloud compute ssh my-app-instance \
          --zone=asia-northeast3-a \
          --command="
            docker pull ${{ secrets.DOCKERHUB_USERNAME }}/my-app:latest
            docker stop my-app || true
            docker rm my-app || true
            docker run -d \
              --name my-app \
              --restart unless-stopped \
              -p 80:3000 \
              -e NODE_ENV=production \
              ${{ secrets.DOCKERHUB_USERNAME }}/my-app:latest
          "
```

</details>

<details>
<summary>🔗 GitHub Secrets 설정</summary>

### 필수 Secrets
- **AWS_EC2_HOST**: EC2 인스턴스 퍼블릭 IP
- **AWS_EC2_USERNAME**: EC2 사용자명 (ec2-user)
- **AWS_EC2_SSH_KEY**: SSH 개인키
- **DOCKERHUB_USERNAME**: Docker Hub 사용자명
- **DOCKERHUB_TOKEN**: Docker Hub 액세스 토큰

### Secrets 설정 방법
1. GitHub 저장소 → Settings → Secrets and variables → Actions
2. "New repository secret" 클릭
3. 각 Secret 추가

</details>

---

## 📚 문제 해결 및 참고 자료

<details>
<summary>🐛 자주 발생하는 문제</summary>

### AWS EC2 관련 문제
<details>
<summary>❌ SSH 접속 실패</summary>

**원인**: 
- 보안 그룹 설정 문제
- 키 파일 권한 문제
- 인스턴스가 아직 시작되지 않음

**해결방법**:
```bash
# 1. 보안 그룹 확인
aws ec2 describe-security-groups --group-names my-app-sg

# 2. 키 파일 권한 확인
chmod 400 my-app-key.pem

# 3. 인스턴스 상태 확인
aws ec2 describe-instances --instance-ids i-xxxxxxxx
```

</details>

<details>
<summary>❌ 웹 애플리케이션 접속 불가</summary>

**원인**:
- 보안 그룹 HTTP 포트 미개방
- Docker 컨테이너 실행 실패
- 애플리케이션 포트 설정 오류

**해결방법**:
```bash
# 1. 보안 그룹 규칙 확인
aws ec2 describe-security-groups --group-names my-app-sg

# 2. Docker 컨테이너 상태 확인
docker ps -a

# 3. 애플리케이션 로그 확인
docker logs my-app
```

</details>

### GCP Compute Engine 관련 문제
<details>
<summary>❌ SSH 접속 실패</summary>

**원인**:
- 방화벽 규칙 설정 문제
- 인스턴스가 아직 시작되지 않음
- gcloud 인증 문제

**해결방법**:
```bash
# 1. 방화벽 규칙 확인
gcloud compute firewall-rules list

# 2. 인스턴스 상태 확인
gcloud compute instances list

# 3. gcloud 인증 확인
gcloud auth list
```

</details>

</details>

<details>
<summary>📖 추가 학습 자료</summary>

### 공식 문서
- [AWS EC2 공식 문서](https://docs.aws.amazon.com/ec2/)
- [GCP Compute Engine 공식 문서](https://cloud.google.com/compute/docs)
- [Docker 공식 문서](https://docs.docker.com/)
- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)

### 유용한 리소스
- [AWS Free Tier](https://aws.amazon.com/free/)
- [GCP Free Tier](https://cloud.google.com/free)
- [Docker Hub](https://hub.docker.com/)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)

### 관련 프로젝트
- [AWS 샘플 프로젝트](https://github.com/aws-samples)
- [GCP 샘플 프로젝트](https://github.com/GoogleCloudPlatform)

</details>

<details>
<summary>🚀 다음 단계</summary>

### Cloud Master 과정 준비
1. **고급 Docker**: 멀티스테이지 빌드, 최적화
2. **고급 GitHub Actions**: 매트릭스 빌드, 환경별 배포
3. **로드 밸런싱**: ELB, Cloud Load Balancing
4. **모니터링**: CloudWatch, Cloud Monitoring

### 실무 적용
1. **실제 프로젝트**: 자신의 프로젝트에 VM 배포 적용
2. **자동화**: 완전 자동화된 배포 파이프라인 구축
3. **모니터링**: 애플리케이션 모니터링 및 로깅
4. **보안**: 보안 정책 및 컴플라이언스 적용

</details>

---

## 🎉 완료!

축하합니다! VM 기반 웹 애플리케이션 배포 실습을 완료했습니다.

### 📚 학습 요약

이번 실습을 통해 다음을 배웠습니다:

1. **☁️ AWS EC2**: EC2 인스턴스 생성 및 애플리케이션 배포
2. **☁️ GCP Compute Engine**: Compute Engine 인스턴스 생성 및 배포
3. **🔧 자동화**: GitHub Actions를 통한 자동 배포
4. **🏗️ 배포 파이프라인**: 완전한 배포 자동화

### 🚀 다음 단계

- **Cloud Master 과정**: 고급 CI/CD, 로드 밸런싱, 모니터링
- **실제 프로젝트 적용**: 자신의 프로젝트에 VM 배포 적용
- **고급 기능 학습**: 자동화, 모니터링, 보안

### 💡 추가 학습 자료

- [AWS EC2 공식 문서](https://docs.aws.amazon.com/ec2/)
- [GCP Compute Engine 공식 문서](https://cloud.google.com/compute/docs)
- [Cloud Master 과정](../../../cloud_master/textbook/Day1/README.md)

---

**🎯 이제 VM 기반 배포의 기본기를 갖추었습니다! Cloud Master 과정으로 진행하세요.**
