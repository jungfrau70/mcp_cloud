# Cloud Master Day1 - Docker & VM 배포 실습

## 🎯 실습 목표
- Docker를 활용한 웹 애플리케이션 컨테이너화
- AWS EC2, GCP Compute Engine을 활용한 VM 배포
- GitHub Actions를 통한 CI/CD 파이프라인 구축

## 🚀 빠른 시작

### 1. 클라우드 환경 설정
```bash
# AWS 환경 설정
chmod +x .../.repos/cloud-scripts/aws-setup-helper.sh
../.../repos/cloud-scripts/aws-setup-helper.sh

# GCP 환경 설정
chmod +x .../.repos/cloud-scripts/gcp-setup-helper.sh
../.../repos/cloud-scripts/gcp-setup-helper.sh
```

### 2. VM 자동 생성
```bash
# AWS EC2 인스턴스 자동 생성
chmod +x .../.repos/cloud-scripts/aws-ec2-create.sh
../.../repos/cloud-scripts/aws-ec2-create.sh

# GCP Compute Engine 인스턴스 자동 생성
chmod +x .../.repos/cloud-scripts/gcp-compute-create.sh
../.../repos/cloud-scripts/gcp-compute-create.sh
```

### 3. 애플리케이션 배포
```bash
# Docker 이미지 빌드
docker build -t my-app .

# 로컬에서 테스트
docker run -d -p 3000:3000 my-app

# VM에 배포 ["SSH 연결 후"]
docker run -d -p 3000:3000 my-app
```

## 📁 파일 구조
```
my-app/
├── README.md           # 이 파일
├── app.js             # Node.js 애플리케이션
├── package.json       # Node.js 의존성
├── Dockerfile         # Docker 이미지 정의
└── docker-compose.yml # Docker Compose 설정
```

## 🔧 실습 단계

### 1단계: 애플리케이션 개발
```bash
# 의존성 설치
npm install

# 애플리케이션 실행
node app.js
```

### 2단계: Docker 컨테이너화
```bash
# Docker 이미지 빌드
docker build -t my-app .

# 컨테이너 실행
docker run -d -p 3000:3000 my-app

# 컨테이너 상태 확인
docker ps
```

### 3단계: VM 배포
```bash
# AWS EC2에 SSH 연결
ssh -i your-ssh-key.pem ubuntu@YOUR_EC2_IP

# GCP VM에 SSH 연결
gcloud compute ssh cloud-deployment-server --zone=asia-northeast3-a
```

## 🧹 정리
```bash
# AWS 리소스 정리
chmod +x .../.repos/cloud-scripts/aws-resource-cleanup.sh
../.../repos/cloud-scripts/aws-resource-cleanup.sh

# GCP 리소스 정리
chmod +x .../.repos/cloud-scripts/gcp-project-cleanup.sh
../.../repos/cloud-scripts/gcp-project-cleanup.sh
```

## 📚 참고 자료
- ["Cloud Master Day1 가이드"](../cloud_master/textbook/Day1/README.md)
- ["Docker 기초 실습"](../cloud_master/textbook/Day1/practices/docker-basics.md)
- ["VM 배포 실습"](../cloud_master/textbook/Day1/practices/vm-deployment.md)
- ["cloud-scripts 가이드"](../cloud_master/repos/cloud-scripts/README.md)
