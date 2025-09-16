# VM 기반 웹 애플리케이션 배포 실습 가이드

<div align="center">

[← 이전: GitHub Actions 기초 실습](/mcp_knowledge_base/cloud_master/textbook/Day1/practice/github-actions-basics.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🏠 학습 경로로 돌아가기](/mcp_knowledge_base/index.md) | [다음: Cloud Master 2일차 →](/mcp_knowledge_base/cloud_master/textbook/Day2/README.md) | [← 이전: Cloud Master 메인](/mcp_knowledge_base/cloud_master/README.md) | [📋 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>

## 🎯 실습 목표
- AWS EC2와 GCP Compute Engine을 활용한 VM 배포
- Docker 컨테이너를 VM에 배포하는 방법 학습
- 자동화된 배포 파이프라인 구축
- 도메인 연결 및 기본 모니터링 설정

## 📋 실습 환경 준비

### 필수 계정 및 도구
- **AWS 계정**: Free Tier 계정 (Cloud Basic에서 생성)
- **GCP 계정**: $300 크레딧 계정 (Cloud Basic에서 생성)
- **GitHub 계정**: 코드 저장소 및 Actions 사용
- **도메인**: 배포된 애플리케이션 접근용 (선택사항)

### 필수 도구 설치
```bash
# AWS CLI 설치 확인
aws --version

# gcloud CLI 설치 확인
gcloud --version

# Docker 설치 확인
docker --version
docker-compose --version
```

## ☁️ 실습 1: AWS EC2 배포

### 1. EC2 인스턴스 생성

**AWS CLI를 사용한 인스턴스 생성**
```bash
# 키 페어 생성
aws ec2 create-key-pair --key-name my-web-app-key --query 'KeyMaterial' --output text > my-web-app-key.pem
chmod 400 my-web-app-key.pem

# 보안 그룹 생성
aws ec2 create-security-group \
  --group-name my-web-app-sg \
  --description "Security group for web application"

# 보안 그룹 규칙 추가
aws ec2 authorize-security-group-ingress \
  --group-name my-web-app-sg \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-name my-web-app-sg \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-name my-web-app-sg \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0

# EC2 인스턴스 생성
aws ec2 run-instances \
  --image-id ami-0ae2c887094315bed \
  --count 1 \
  --instance-type t3.micro \
  --key-name my-web-app-key \
  --security-groups my-web-app-sg \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=my-web-app}]'
```

### 2. EC2 인스턴스 설정

**SSH로 인스턴스 접속**
```bash
# 인스턴스 IP 확인
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=my-web-app" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text

# SSH 접속
ssh -i my-web-app-key.pem ec2-user@<PUBLIC_IP>
```

**인스턴스에서 Docker 설치**
```bash
# Docker 설치
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Docker Compose 설치
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Git 설치
sudo yum install -y git
```

### 3. 애플리케이션 배포

**애플리케이션 클론 및 실행**
```bash
# 애플리케이션 클론
git clone https://github.com/username/github-actions-practice.git
cd github-actions-practice

# Docker Compose로 실행
docker-compose up -d

# 실행 상태 확인
docker ps
docker-compose logs
```

## ☁️ 실습 2: GCP Compute Engine 배포

### 1. Compute Engine 인스턴스 생성

**gcloud CLI를 사용한 인스턴스 생성**
```bash
# 프로젝트 설정
gcloud config set project YOUR_PROJECT_ID

# 인스턴스 생성
gcloud compute instances create my-web-app \
  --zone=asia-northeast3-a \
  --machine-type=e2-micro \
  --image-family=ubuntu-2004-lts \
  --image-project=ubuntu-os-cloud \
  --tags=http-server,https-server \
  --metadata-from-file startup-script=startup-script.sh

# 방화벽 규칙 생성
gcloud compute firewall-rules create allow-http \
  --allow tcp:80 \
  --source-ranges 0.0.0.0/0 \
  --target-tags http-server

gcloud compute firewall-rules create allow-https \
  --allow tcp:443 \
  --source-ranges 0.0.0.0/0 \
  --target-tags https-server

gcloud compute firewall-rules create allow-ssh \
  --allow tcp:22 \
  --source-ranges 0.0.0.0/0 \
  --target-tags ssh-server
```

**startup-script.sh**
```bash
#!/bin/bash
# Docker 설치
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu

# Docker Compose 설치
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Git 설치
sudo apt-get update
sudo apt-get install -y git

# 애플리케이션 클론
cd /home/ubuntu
git clone https://github.com/username/github-actions-practice.git
cd github-actions-practice

# Docker Compose로 실행
sudo docker-compose up -d
```

### 2. Compute Engine 인스턴스 설정

**SSH로 인스턴스 접속**
```bash
# 인스턴스 IP 확인
gcloud compute instances describe my-web-app \
  --zone=asia-northeast3-a \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)'

# SSH 접속
gcloud compute ssh my-web-app --zone=asia-northeast3-a
```

## ☁️ 실습 3: 자동화된 배포 파이프라인

### 1. GitHub Actions 워크플로우 생성

**.github/workflows/deploy-vm.yml**
```yaml
name: Deploy to VM

on:
  push:
    branches: [ main ]

jobs:
  deploy-aws:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Deploy to AWS EC2
      uses: appleboy/ssh-action@v1.0.3
      with:
        host: ${{ secrets.AWS_HOST }}
        username: ${{ secrets.AWS_USERNAME }}
        key: ${{ secrets.AWS_SSH_KEY }}
        script: |
          cd /home/ec2-user/github-actions-practice
          git pull origin main
          docker-compose down
          docker-compose up -d --build
          
  deploy-gcp:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Deploy to GCP Compute Engine
      uses: appleboy/ssh-action@v1.0.3
      with:
        host: ${{ secrets.GCP_HOST }}
        username: ${{ secrets.GCP_USERNAME }}
        key: ${{ secrets.GCP_SSH_KEY }}
        script: |
          cd /home/ubuntu/github-actions-practice
          git pull origin main
          sudo docker-compose down
          sudo docker-compose up -d --build
```

### 2. GitHub Secrets 설정

**필요한 시크릿들:**
- `AWS_HOST`: AWS EC2 퍼블릭 IP
- `AWS_USERNAME`: ec2-user
- `AWS_SSH_KEY`: EC2 키 페어 내용
- `GCP_HOST`: GCP Compute Engine 외부 IP
- `GCP_USERNAME`: ubuntu
- `GCP_SSH_KEY`: GCP SSH 키 내용

## ☁️ 실습 4: 도메인 연결 및 SSL 설정

### 1. 도메인 연결

**AWS Route 53 설정**
```bash
# 호스팅 영역 생성
aws route53 create-hosted-zone \
  --name example.com \
  --caller-reference $(date +%s)

# A 레코드 생성
aws route53 change-resource-record-sets \
  --hosted-zone-id Z123456789 \
  --change-batch file://dns-record.json
```

**dns-record.json**
```json
{
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "app.example.com",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "YOUR_EC2_IP"
          }
        ]
      }
    }
  ]
}
```

### 2. SSL 인증서 설정

**Let's Encrypt를 사용한 SSL 설정**
```bash
# Certbot 설치
sudo yum install -y certbot

# SSL 인증서 발급
sudo certbot certonly --standalone -d app.example.com

# Nginx 설정
sudo yum install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

**Nginx 설정 파일**
```nginx
server {
    listen 80;
    server_name app.example.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name app.example.com;
    
    ssl_certificate /etc/letsencrypt/live/app.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/app.example.com/privkey.pem;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## ☁️ 실습 5: 기본 모니터링 설정

### 1. 로그 관리

**Docker 로그 설정**
```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    restart: unless-stopped
```

**로그 로테이션 설정**
```bash
# logrotate 설정
sudo nano /etc/logrotate.d/docker
```

**logrotate 설정**
```
/var/lib/docker/containers/*/*.log {
  rotate 7
  daily
  compress
  size=1M
  missingok
  delaycompress
  copytruncate
}
```

### 2. 헬스체크 설정

**애플리케이션 헬스체크**
```javascript
// app.js에 추가
app.get('/health', (req, res) => {
  const healthcheck = {
    uptime: process.uptime(),
    message: 'OK',
    timestamp: Date.now()
  };
  
  try {
    res.status(200).send(healthcheck);
  } catch (error) {
    healthcheck.message = error;
    res.status(503).send(healthcheck);
  }
});
```

**Docker 헬스체크**
```dockerfile
# Dockerfile에 추가
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
```

### 3. 기본 모니터링 스크립트

**monitor.sh**
```bash
#!/bin/bash

# 애플리케이션 상태 확인
check_app() {
  if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    echo "✅ Application is healthy"
  else
    echo "❌ Application is down"
    # 알림 전송 로직
  fi
}

# Docker 컨테이너 상태 확인
check_containers() {
  if docker ps | grep -q "my-web-app"; then
    echo "✅ Docker containers are running"
  else
    echo "❌ Docker containers are down"
    # 컨테이너 재시작 로직
  fi
}

# 디스크 사용량 확인
check_disk() {
  usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
  if [ $usage -gt 80 ]; then
    echo "⚠️ Disk usage is high: ${usage}%"
  else
    echo "✅ Disk usage is normal: ${usage}%"
  fi
}

# 메모리 사용량 확인
check_memory() {
  usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
  if [ $usage -gt 80 ]; then
    echo "⚠️ Memory usage is high: ${usage}%"
  else
    echo "✅ Memory usage is normal: ${usage}%"
  fi
}

# 모든 체크 실행
check_app
check_containers
check_disk
check_memory
```

**Cron 작업 설정**
```bash
# 모니터링 스크립트를 5분마다 실행
echo "*/5 * * * * /home/ec2-user/monitor.sh >> /var/log/monitor.log 2>&1" | crontab -
```

## ☁️ 실습 6: 배포 자동화 고도화

### 1. Blue-Green 배포

**blue-green-deploy.sh**
```bash
#!/bin/bash

# 현재 실행 중인 컨테이너 확인
if docker ps | grep -q "my-web-app-blue"; then
  CURRENT="blue"
  NEW="green"
else
  CURRENT="green"
  NEW="blue"
fi

echo "Current: $CURRENT, Deploying: $NEW"

# 새 버전 빌드
docker build -t my-web-app:$NEW .

# 새 버전 실행
docker run -d --name my-web-app-$NEW -p 3001:3000 my-web-app:$NEW

# 헬스체크
sleep 10
if curl -f http://localhost:3001/health > /dev/null 2>&1; then
  echo "New version is healthy, switching traffic"
  
  # Nginx 설정 업데이트
  sed -i "s/my-web-app-$CURRENT/my-web-app-$NEW/g" /etc/nginx/nginx.conf
  nginx -s reload
  
  # 이전 버전 중지
  docker stop my-web-app-$CURRENT
  docker rm my-web-app-$CURRENT
  
  echo "Deployment successful"
else
  echo "New version failed health check, rolling back"
  docker stop my-web-app-$NEW
  docker rm my-web-app-$NEW
  exit 1
fi
```

### 2. 롤백 스크립트

**rollback.sh**
```bash
#!/bin/bash

# 이전 버전으로 롤백
if docker ps | grep -q "my-web-app-green"; then
  CURRENT="green"
  NEW="blue"
else
  CURRENT="blue"
  NEW="green"
fi

echo "Rolling back from $CURRENT to $NEW"

# 이전 버전 실행
docker start my-web-app-$NEW

# Nginx 설정 업데이트
sed -i "s/my-web-app-$CURRENT/my-web-app-$NEW/g" /etc/nginx/nginx.conf
nginx -s reload

# 현재 버전 중지
docker stop my-web-app-$CURRENT

echo "Rollback completed"
```

## 🎯 실습 완료 체크리스트

- [ ] AWS EC2 인스턴스 생성 및 설정
- [ ] GCP Compute Engine 인스턴스 생성 및 설정
- [ ] Docker 컨테이너를 VM에 배포
- [ ] GitHub Actions로 자동 배포 파이프라인 구축
- [ ] 도메인 연결 및 SSL 설정
- [ ] 기본 모니터링 및 로그 관리
- [ ] Blue-Green 배포 구현
- [ ] 롤백 전략 구현

## 📚 추가 학습 자료

- [AWS EC2 공식 문서](https://docs.aws.amazon.com/ec2/)
- [GCP Compute Engine 공식 문서](https://cloud.google.com/compute/docs)
- [Docker 공식 문서](https://docs.docker.com/)
- [Nginx 공식 문서](https://nginx.org/en/docs/)

## 🚀 다음 단계

- **Cloud Master 2일차**: Docker 고급 기법, GitHub Actions 고급 워크플로우
- **로드 밸런싱**: 여러 VM에 트래픽 분산
- **자동 스케일링**: 트래픽에 따른 자동 확장/축소
- **모니터링**: 고급 모니터링 및 알림 시스템
