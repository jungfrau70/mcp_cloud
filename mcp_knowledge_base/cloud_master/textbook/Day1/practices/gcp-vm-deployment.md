# 🚀 GCP Compute Engine VM 배포 실습

## 🎯 실습 목표

### 핵심 학습 목표
- **GCP Compute Engine**: GCP VM 인스턴스 생성 및 관리
- **Docker 설치 및 설정**: GCP VM에 Docker 환경 구축
- **SSH 키 관리**: GCP VM 접속을 위한 SSH 키 설정
- **GitHub Actions 배포**: 자동화된 GCP VM 배포 파이프라인 구축

### 실습 후 달성할 수 있는 능력
- ✅ GCP Compute Engine VM 생성 및 관리
- ✅ GCP VM에 Docker 환경 구축
- ✅ SSH를 통한 GCP VM 접속 및 관리
- ✅ GitHub Actions를 통한 GCP VM 자동 배포
- ✅ 멀티 클라우드 환경에서의 애플리케이션 배포

### 예상 소요 시간
- **GCP VM 생성**: 30-45분
- **Docker 환경 구축**: 30-45분
- **GitHub Actions 설정**: 45-60분
- **배포 테스트**: 30-45분
- **전체 과정**: 2-3시간

---

## 🛠️ 실습 환경 준비

### 필수 도구
- **GCP CLI**: GCP 서비스 관리
- **SSH 클라이언트**: VM 접속
- **Git**: 코드 관리
- **Docker**: 컨테이너 실행

### 환경 설정
```bash
# GCP CLI 설치 확인
gcloud --version

# GCP 프로젝트 설정
gcloud config set project YOUR_PROJECT_ID

# GCP 인증
gcloud auth login
```

---

## 🚀 단계별 실습

### 1단계: GCP VM 인스턴스 생성

#### 방법 1: 자동화 스크립트 사용 (권장)
```bash
# GCP 설정 도우미 실행
chmod +x cloud-scripts/gcp-setup-helper.sh
./cloud-scripts/gcp-setup-helper.sh

# GCP Compute Engine 인스턴스 자동 생성
chmod +x cloud-scripts/gcp-compute-create.sh
./cloud-scripts/gcp-compute-create.sh
```

#### 방법 2: 수동 명령어 실행
```bash
# GCP Compute Engine 인스턴스 생성
gcloud compute instances create github-actions-demo-gcp \
    --zone=us-central1-a \
    --machine-type=e2-medium \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=20GB \
    --tags=github-actions-demo

# 방화벽 규칙 설정
gcloud compute firewall-rules create allow-http \
    --allow tcp:3000 \
    --source-ranges 0.0.0.0/0 \
    --target-tags github-actions-demo

gcloud compute firewall-rules create allow-ssh \
    --allow tcp:22 \
    --source-ranges 0.0.0.0/0 \
    --target-tags github-actions-demo
```

### 2단계: SSH 키 설정

#### SSH 키 생성
```bash
# SSH 키 생성
ssh-keygen -t rsa -b 4096 -f ~/.ssh/gcp-deployment-key -C "github-actions-demo"

# 공개키를 GCP VM에 추가
gcloud compute instances add-metadata github-actions-demo-gcp \
    --zone=us-central1-a \
    --metadata-from-file ssh-keys=<(echo "ubuntu:$(cat ~/.ssh/gcp-deployment-key.pub)")
```

#### SSH 접속 테스트
```bash
# SSH 접속 테스트
ssh -i ~/.ssh/gcp-deployment-key ubuntu@[GCP_VM_IP]
```

### 3단계: GCP VM에 Docker 설치

#### Docker 설치 스크립트
```bash
# GCP VM에 SSH 접속하여 Docker 설치
ssh -i ~/.ssh/gcp-deployment-key ubuntu@[GCP_VM_IP] << 'EOF'
# Docker 설치
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Docker 서비스 시작
sudo systemctl start docker
sudo systemctl enable docker

# ubuntu 사용자를 docker 그룹에 추가
sudo usermod -aG docker ubuntu

# Docker 설치 확인
docker --version
EOF
```

### 4단계: GitHub Secrets 설정

#### 필요한 GitHub Secrets
GitHub Repository → Settings → Secrets and variables → Actions에서 다음 Secrets를 추가:

- **`GCP_VM_HOST`**: GCP VM의 외부 IP 주소
- **`GCP_VM_USERNAME`**: `ubuntu`
- **`GCP_VM_SSH_KEY`**: SSH 개인키 전체 내용
- **`DOCKER_USERNAME`**: Docker Hub 사용자명
- **`DOCKER_PASSWORD`**: Docker Hub Personal Access Token

#### SSH 키 내용 확인
```bash
# SSH 키 내용 확인
cat ~/.ssh/gcp-deployment-key
```

### 5단계: GitHub Actions 워크플로우 생성

#### GCP 배포 워크플로우 생성
```bash
# GCP VM 배포 워크플로우 생성
cat > .github/workflows/deploy-gcp.yml << 'EOF'
name: Deploy to GCP VM

on:
  push:
    branches: [ master ]
  workflow_dispatch:

env:
  REGISTRY: docker.io
  IMAGE_NAME: github-actions-demo

jobs:
  deploy-gcp:
    name: GCP VM 배포
    runs-on: ubuntu-latest
    
    steps:
    - name: 코드 체크아웃
      uses: actions/checkout@v4
      
    - name: Docker Hub에서 이미지 풀
      run: |
        echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
        docker pull ${{ env.REGISTRY }}/${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:latest
        
    - name: GCP VM에 SSH 연결 및 배포
      uses: appleboy/ssh-action@v1.0.0
      with:
        host: ${{ secrets.GCP_VM_HOST }}
        username: ${{ secrets.GCP_VM_USERNAME }}
        key: ${{ secrets.GCP_VM_SSH_KEY }}
        script: |
          # 기존 컨테이너 중지 및 제거
          docker stop github-actions-demo || true
          docker rm github-actions-demo || true
          
          # Docker Hub에서 최신 이미지 풀
          echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
          docker pull ${{ env.REGISTRY }}/${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:latest
          
          # 새 컨테이너 실행
          docker run -d \
            --name github-actions-demo \
            --restart unless-stopped \
            -p 3000:3000 \
            -e NODE_ENV=production \
            ${{ env.REGISTRY }}/${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:latest
          
          # 헬스 체크
          sleep 10
          curl -f http://localhost:3000/health || exit 1
          
          echo "✅ GCP VM 배포가 성공적으로 완료되었습니다!"
EOF
```

### 6단계: 배포 테스트

#### GitHub Actions 실행
```bash
# 변경사항 커밋 및 푸시
git add .
git commit -m "feat: GCP VM 배포 워크플로우 추가"
git push origin master
```

#### 배포 확인
```bash
# GCP VM에 SSH 접속하여 배포 상태 확인
ssh -i ~/.ssh/gcp-deployment-key ubuntu@[GCP_VM_IP] << 'EOF'
# 실행 중인 컨테이너 확인
docker ps

# 애플리케이션 로그 확인
docker logs github-actions-demo

# 헬스 체크
curl http://localhost:3000/health
EOF
```

---

## ✅ 배포 확인

### 애플리케이션 접속
- **메인 페이지**: `http://[GCP_VM_IP]:3000`
- **헬스 체크**: `http://[GCP_VM_IP]:3000/health`
- **메트릭**: `http://[GCP_VM_IP]:3000/metrics`

### 컨테이너 상태 확인
```bash
# GCP VM에 SSH 접속
ssh -i ~/.ssh/gcp-deployment-key ubuntu@[GCP_VM_IP]

# 실행 중인 컨테이너 확인
docker ps

# 애플리케이션 로그 확인
docker logs github-actions-demo
```

---

## 🔧 문제 해결

### 1. SSH 연결 실패
- 방화벽 규칙 확인
- SSH 키 권한 확인 (`chmod 600 ~/.ssh/gcp-deployment-key`)
- GCP VM 상태 확인

### 2. Docker 권한 문제
```bash
# ubuntu 사용자를 docker 그룹에 추가
sudo usermod -aG docker ubuntu

# Docker 서비스 재시작
sudo systemctl restart docker

# 새 세션에서 테스트
newgrp docker
```

### 3. 애플리케이션 접속 불가
- 방화벽 규칙 확인 (포트 3000)
- 컨테이너 실행 상태 확인
- 애플리케이션 로그 확인

---

## 🧹 실습 정리

### 자동 정리
```bash
# GCP VM 인스턴스 삭제
gcloud compute instances delete github-actions-demo-gcp --zone=us-central1-a

# 방화벽 규칙 삭제
gcloud compute firewall-rules delete allow-http
gcloud compute firewall-rules delete allow-ssh
```

### 수동 정리
```bash
# SSH 키 정리
rm ~/.ssh/gcp-deployment-key*

# GCP 프로젝트 정리
gcloud projects delete YOUR_PROJECT_ID
```

---

## 📚 참고 자료

- [GCP Compute Engine 문서](https://cloud.google.com/compute/docs)
- [Docker 설치 가이드](https://docs.docker.com/engine/install/ubuntu/)
- [GitHub Actions 문서](https://docs.github.com/en/actions)
- [SSH 키 관리 가이드](https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys)
