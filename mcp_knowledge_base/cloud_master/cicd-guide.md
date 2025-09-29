# GitHub Actions CI/CD 가이드

> 📋 **Cloud Master 과정**: GitHub Actions CI/CD 실습 가이드  
> 📋 **대상**: Day1 (기초), Day2 (고급)  
> 📋 **저장소**: Day1 기본, Day2 고급 저장소 분리 사용

---

## 🎯 GitHub Actions 실습 저장소 구조

### **Day1: 기본 CI/CD 실습**
- **저장소**: `https://github.com/jungfrau70/github-actions-demo.git`
- **목적**: 기본 GitHub Actions 워크플로우 학습
- **내용**: 
  - 기본 Docker 이미지 빌드
  - AWS/GCP VM 배포
  - Repository Secrets 활용
  - 멀티 클라우드 배포

### **Day2: 고급 CI/CD 실습**
- **저장소**: `https://github.com/jungfrau70/github-actions-demo-day2.git`
- **목적**: 고급 CI/CD 파이프라인 및 프로덕션 환경 구축
- **내용**:
  - 멀티 환경 배포 (staging/production)
  - 매트릭스 빌드 (Node.js 16, 18, 20)
  - 보안 스캔 (Trivy + CodeQL)
  - 데이터베이스 연동 (PostgreSQL + Redis)
  - 모니터링 시스템 (Prometheus + Grafana)

---

## 🛠️ 실습 환경 설정

### **필수 요구사항**
- **GitHub 계정**: 실습용 저장소 Fork 필요
- **Docker Hub 계정**: 이미지 푸시용
- **AWS 계정**: EC2 인스턴스 생성용
- **GCP 계정**: Compute Engine 인스턴스 생성용

### **Repository Secrets 설정**
각 저장소의 Settings > Secrets and variables > Actions에서 다음 설정:

#### **공통 Secrets**
```
DOCKER_USERNAME: your-docker-username
DOCKER_PASSWORD: your-docker-password
```

#### **Day1 Secrets**
```
GCP_VM_HOST: gcp-vm-public-ip
GCP_VM_SSH_KEY: gcp-vm-ssh-private-key
GCP_VM_USERNAME: ubuntu
AWS_VM_HOST: aws-vm-public-ip
AWS_VM_SSH_KEY: aws-vm-ssh-private-key
AWS_VM_USERNAME: ubuntu
```

#### **Day2 Secrets**
```
# AWS 프로덕션 환경
PROD_VM_HOST: aws-vm-public-ip
PROD_VM_USERNAME: ubuntu
PROD_VM_SSH_KEY: aws-vm-ssh-private-key
PROD_DB_PASSWORD: aws-db-password
PROD_REDIS_PASSWORD: aws-redis-password

# GCP 스테이징 환경
STAGING_VM_HOST: gcp-vm-public-ip
STAGING_VM_USERNAME: ubuntu
STAGING_VM_SSH_KEY: gcp-vm-ssh-private-key
STAGING_DB_PASSWORD: gcp-db-password
STAGING_REDIS_PASSWORD: gcp-redis-password
```

---

## 📚 실습 진행 방법

### **Day1: 기본 CI/CD 실습**
1. **저장소 Fork**: `https://github.com/jungfrau70/github-actions-demo.git`
2. **로컬 클론**: `git clone https://github.com/YOUR_USERNAME/github-actions-demo.git`
3. **Secrets 설정**: 위의 Day1 Secrets 설정
4. **코드 푸시**: `git push origin main`
5. **Actions 확인**: GitHub Actions 탭에서 워크플로우 실행 확인

### **Day2: 고급 CI/CD 실습**
1. **저장소 Fork**: `https://github.com/jungfrau70/github-actions-demo-day2.git`
2. **로컬 클론**: `git clone https://github.com/YOUR_USERNAME/github-actions-demo-day2.git`
3. **브랜치 생성**: `git checkout -b day2-advanced`
4. **Secrets 설정**: 위의 Day2 Secrets 설정
5. **코드 푸시**: `git push origin day2-advanced`
6. **Actions 확인**: 고급 CI/CD 파이프라인 실행 확인

---

## 🔧 문제 해결 가이드

### **일반적인 문제**
1. **Secrets 설정 오류**: Repository Settings에서 정확한 이름으로 설정
2. **SSH 키 형식 오류**: OpenSSH 형식으로 변환 필요
3. **Docker 로그인 실패**: Docker Hub Personal Access Token 사용
4. **VM 연결 실패**: 보안 그룹/방화벽 설정 확인

### **Day2 특화 문제**
1. **데이터베이스 연결 실패**: 환경 변수 및 네트워크 설정 확인
2. **보안 스캔 실패**: Trivy 설정 및 권한 확인
3. **매트릭스 빌드 실패**: Node.js 버전 호환성 확인
4. **배포 실패**: VM 리소스 및 서비스 상태 확인

---

## 📊 성과 측정

### **Day1 목표**
- ✅ 기본 GitHub Actions 워크플로우 이해
- ✅ Docker 이미지 자동 빌드
- ✅ 멀티 클라우드 배포 성공
- ✅ Repository Secrets 활용

### **Day2 목표**
- ✅ 고급 CI/CD 파이프라인 구축
- ✅ 멀티 환경 배포 (staging/production)
- ✅ 보안 스캔 통합
- ✅ 데이터베이스 연동
- ✅ 모니터링 시스템 구축

---

## 🚀 다음 단계

### **Day3: 로드밸런싱 & 모니터링**
- 클라우드 로드밸런서 설정
- 고급 모니터링 스택 구축
- 비용 최적화 및 자동 스케일링

### **실무 적용**
- 회사 프로젝트에 CI/CD 적용
- 보안 스캔 정책 수립
- 모니터링 대시보드 구축
- 자동화 파이프라인 확장

---

**가이드 작성일**: 2024년 12월 19일  
**대상 과정**: Cloud Master Day1, Day2  
**실습 저장소**: 
- Day1: `https://github.com/jungfrau70/github-actions-demo.git`
- Day2: `https://github.com/jungfrau70/github-actions-demo-day2.git`
