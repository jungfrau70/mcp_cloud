# 🚀 클라우드 중급 과정 실습 환경 빠른 시작 가이드

## ⚡ 3분 만에 환경 설정하기

### 1단계: WSL 확인
```bash
# WSL 버전 확인
wsl --version

# WSL이 없다면 설치
wsl --install
```

### 2단계: 통합 설정 실행
```bash
# WSL 환경으로 이동
cd /mnt/c/Users/[사용자명]/githubs/mcp_cloud/mcp_knowledge_base/cloud_intermediate/repo/setup

# 실행 권한 부여
chmod +x setup-wsl-environment.sh

# 통합 설정 실행
./setup-wsl-environment.sh
```

### 3단계: 메뉴에서 "1. 전체 환경 설정" 선택
- 자동으로 모든 도구가 설치됩니다
- AWS CLI, GCP CLI, Docker, kubectl, GitHub CLI 등이 설치됩니다

## 🎯 주요 스크립트

| 스크립트 | 기능 | 사용법 |
|---------|------|--------|
| `setup-wsl-environment.sh` | **통합 설정** | `./setup-wsl-environment.sh` |
| `install-all-wsl.sh` | 전체 도구 설치 | `./install-all-wsl.sh` |
| `environment-check-wsl.sh` | 환경 체크 | `./environment-check-wsl.sh` |
| `aws-setup-helper.sh` | AWS 설정 | `./aws-setup-helper.sh` |
| `gcp-setup-helper.sh` | GCP 설정 | `./gcp-setup-helper.sh` |

## ✅ 설치 확인

설치 완료 후 다음 명령어로 확인하세요:

```bash
# AWS CLI
aws --version

# GCP CLI  
gcloud --version

# Docker
docker --version

# kubectl
kubectl version --client

# GitHub CLI
gh --version

# Git
git --version
```

## 🔧 문제 해결

### Docker 권한 오류
```bash
sudo usermod -aG docker $USER
# WSL 재시작 필요
```

### AWS CLI 설정
```bash
aws configure
```

### GCP CLI 설정
```bash
gcloud auth login
gcloud config set project [프로젝트ID]
```

### kubectl 설정
```bash
# AWS EKS 클러스터 연결
aws eks update-kubeconfig --name cluster-name --region region

# GCP GKE 클러스터 연결
gcloud container clusters get-credentials cluster-name --zone zone
```

## 🎯 클라우드 중급 과정 실습 준비

### Day 1 실습 준비
- [ ] Docker 고급 활용 환경 준비
- [ ] Kubernetes 기초 실습 환경 준비
- [ ] AWS ECS 실습 환경 준비
- [ ] GCP Cloud Run 실습 환경 준비
- [ ] 통합 모니터링 허브 구축 환경 준비

### Day 2 실습 준비
- [ ] GitHub Actions CI/CD 파이프라인 환경 준비
- [ ] 멀티 클라우드 통합 모니터링 환경 준비
- [ ] AWS EKS 클러스터 환경 준비
- [ ] GCP GKE 클러스터 환경 준비
- [ ] 고급 배포 전략 실습 환경 준비

---

**이제 클라우드 중급 과정 실습을 시작할 준비가 완료되었습니다! 🎉**