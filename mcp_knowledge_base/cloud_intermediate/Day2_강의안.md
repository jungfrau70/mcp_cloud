# Cloud Intermediate - 2일차 강의안

> 📋 **강의 일시**: 2024년 10월 2일 ["목"] 9:00~17:00  
> 📋 **강의 방식**: 온라인 실습 중심  
> 📋 **선수 학습**: Day1 완료 ["Docker, Kubernetes, 클라우드 컨테이너 서비스"]  
> 📋 **WSL 환경설정**: [mcp_knowledge_base/cloud_intermediate/_setup_wsl/README.md](../_setup_wsl/README.md)
> 📋 **실습 코드**: `git clone https://github.com/jungfrau70/cloud-intermediate.git cloud_intermediate`

---

## 🎯 2일차 학습 목표

### 핵심 목표
- **CI/CD 파이프라인**: GitHub Actions를 활용한 자동화된 배포
- **클라우드 배포**: AWS ECS, GCP Cloud Run 고급 배포 전략
- **모니터링 스택**: Prometheus + Grafana 통합 모니터링 시스템
- **실무 중심**: 프로덕션 환경에서 사용되는 DevOps 패턴 학습
- **자동화**: 실습 자동화 스크립트를 통한 효율적 학습

## ⚠️ 실습 전 필수 준비사항

### 🔧 **사전 요구사항 확인**
```bash
# 1. 필수 도구 설치 확인
echo "=== 필수 도구 확인 ==="
command -v aws && echo "✅ AWS CLI 설치됨" || echo "❌ AWS CLI 설치 필요"
command -v gcloud && echo "✅ GCP CLI 설치됨" || echo "❌ GCP CLI 설치 필요"
command -v docker && echo "✅ Docker 설치됨" || echo "❌ Docker 설치 필요"
command -v docker-compose && echo "✅ Docker Compose 설치됨" || echo "❌ Docker Compose 설치 필요"
command -v jq && echo "✅ jq 설치됨" || echo "❌ jq 설치 필요"
command -v curl && echo "✅ curl 설치됨" || echo "❌ curl 설치 필요"
command -v git && echo "✅ Git 설치됨" || echo "❌ Git 설치 필요"

# 2. 클라우드 계정 설정 확인
echo "=== 클라우드 계정 설정 확인 ==="
aws sts get-caller-identity && echo "✅ AWS 계정 설정됨" || echo "❌ AWS 계정 설정 필요"
gcloud auth list && echo "✅ GCP 계정 설정됨" || echo "❌ GCP 계정 설정 필요"

# 3. GitHub 설정 확인
echo "=== GitHub 설정 확인 ==="
git config --global user.name && echo "✅ Git 사용자명 설정됨" || echo "❌ Git 사용자명 설정 필요"
git config --global user.email && echo "✅ Git 이메일 설정됨" || echo "❌ Git 이메일 설정 필요"
```

### 📋 **실습 전 체크리스트**

#### **자동 체크 ["권장"]**
```bash
# 환경 체크 스크립트 실행
cd ./cloud_intermediate/scripts
./cloud-intermediate-helper.sh check-environment
```

#### **수동 체크**
- [ ] **AWS CLI 설정**: `aws sts get-caller-identity` 성공
- [ ] **GCP CLI 설정**: `gcloud auth list` 성공  
- [ ] **Docker 실행**: `docker --version` 확인
- [ ] **Git 설정**: GitHub 계정 연결 및 권한 확인
- [ ] **Day1 완료**: Docker, Kubernetes, 클라우드 서비스 실습 완료
- [ ] **권한 확인**: AWS/GCP 리소스 생성 권한
- [ ] **네트워크 확인**: 인터넷 연결 및 방화벽 설정
- [ ] **GitHub Repository**: 실습용 저장소 생성 및 설정

## 📁 **2일차 강의 자료 구조**

### **새로운 디렉토리 구조**
```
./cloud_intermediate/
├── samples/day2/
│   ├── cicd-pipeline/             # CI/CD 파이프라인 실습
│   ├── cloud-deployment/          # 클라우드 배포 실습
│   └── monitoring-basics/         # 멀티 클라우드 통합 모니터링 실습
├── scripts/
│   ├── day2-practice.sh           # Day2 실습 자동화
│   ├── monitoring-stack.sh        # 모니터링 스택 자동화
│   └── cloud-intermediate-helper.sh # 통합 헬퍼
└── textbook/Day2/
    ├── README.md                     # Day2 개요
    └── practice/                     # 실습 가이드
        ├── cicd-pipeline.md
        ├── cloud-deployment.md
        └── monitoring-basics.md
```

## 📅 **2일차 강의 일정**

### 🌅 **오전 ["4시간"] - CI/CD 및 모니터링**

#### **1교시: GitHub Actions CI/CD 파이프라인 ["90분"]**
- **목표**: 자동화된 빌드, 테스트, 배포 파이프라인 구축
- **실습**: GitHub Actions 워크플로우 작성 및 실행

**🔍 실습 코드 위치**
- **샘플 코드**: `cloud_intermediate/samples/day2/cicd-pipeline/`
- **자동화 스크립트**: `cloud_intermediate/scripts/day2-practice.sh`

**📋 실습 단계**
```bash
# 1. 실습 환경 준비
cd ./cloud_intermediate/scripts
./day2-practice.sh

# 2. CI/CD 파이프라인 실습 선택
# 메뉴에서 "1. CI/CD 파이프라인 실습" 선택

# 3. GitHub Actions 워크플로우 생성
# .github/workflows/ci-cd.yml 파일 생성

# 4. 로컬 테스트 실행
npm install
npm test
npm run lint

# 5. Docker 이미지 빌드 테스트
docker build -t cicd-practice-app:latest .
```

**🎯 학습 결과**
- ✅ GitHub Actions 워크플로우 작성
- ✅ 자동화된 테스트 및 빌드 파이프라인
- ✅ 보안 스캔 및 품질 검증 자동화

#### **2교시: 멀티 클라우드 통합 모니터링 시스템 ["90분"]**
- **목표**: AWS/GCP 멀티 클라우드 환경에서의 통합 모니터링 시스템 구축
- **실습**: Phase 1-2 (통합 모니터링 허브 + AWS 클러스터 모니터링)

**🔍 실습 코드 위치**
- **통합 시나리오**: `cloud_intermediate/통합모니터링시나리오.md`
- **자동화 스크립트**: `cloud_intermediate/scripts/monitoring-stack.sh`

**📋 실습 단계**
```bash
# 1. 통합 모니터링 시나리오 확인
cat cloud_intermediate/통합모니터링시나리오.md

# 2. Phase 1: 통합 모니터링 허브 구축
# AWS VM 생성 및 Global Prometheus + Grafana 설정

# 3. Phase 2: AWS 클러스터 모니터링
# AWS EKS 클러스터 구축 및 Infrastructure/Platform 모니터링

# 4. 통합 대시보드 구성
# 멀티 클라우드 환경 모니터링 시각화
```

**🎯 학습 결과**
- ✅ 멀티 클라우드 통합 모니터링 시스템 구축
- ✅ Infrastructure/Platform 3계층 모니터링
- ✅ Global Dashboard를 통한 통합 시각화
- ✅ 실제 운영 환경 수준의 모니터링 시스템

### 🌆 **오후 ["4시간"] - 애플리케이션 모니터링 및 GCP 통합**

#### **3교시: AWS Application 모니터링 ["90분"]**
- **목표**: GitHub Actions를 통한 AWS EKS 애플리케이션 배포 및 Application 모니터링
- **실습**: Phase 3 (AWS Application 모니터링)

**🔍 실습 코드 위치**
- **통합 시나리오**: `cloud_intermediate/통합모니터링시나리오.md`
- **GitHub Actions**: `.github/workflows/deploy-aws-app.yml`

**📋 실습 단계**
```bash
# 1. Phase 3: AWS Application 모니터링
# GitHub Actions 워크플로우 생성

# 2. 애플리케이션 배포 매니페스트 생성
# Kubernetes Deployment, Service, ServiceMonitor 설정

# 3. 애플리케이션 배포 및 모니터링 확인
# Prometheus에서 애플리케이션 메트릭 수집 확인

# 4. Application Dashboard 구성
# 애플리케이션 성능 모니터링 시각화
```

**🎯 학습 결과**
- ✅ GitHub Actions CI/CD 파이프라인 구축
- ✅ AWS EKS 애플리케이션 자동 배포
- ✅ Application 모니터링 설정
- ✅ 실시간 애플리케이션 성능 모니터링

#### **4교시: GCP 클러스터 통합 모니터링 ["90분"]**
- **목표**: GCP GKE 클러스터 구축 및 멀티 클라우드 통합 모니터링 완성
- **실습**: Phase 4 (GCP 클러스터 모니터링)

**🔍 실습 코드 위치**
- **통합 시나리오**: `cloud_intermediate/통합모니터링시나리오.md`
- **GCP 설정**: GCP Console 및 gcloud CLI

**📋 실습 단계**
```bash
# 1. Phase 4: GCP 클러스터 모니터링
# GCP GKE 클러스터 생성

# 2. GCP Infrastructure/Platform 모니터링 설정
# Prometheus 스택 배포 및 메트릭 수집

# 3. Global Prometheus에 GCP 클러스터 연동
# 멀티 클라우드 통합 모니터링 완성

# 4. 통합 모니터링 대시보드 구성
# AWS + GCP 통합 시각화
```

**🎯 학습 결과**
- ✅ GCP GKE 클러스터 구축
- ✅ GCP Infrastructure/Platform 모니터링
- ✅ 멀티 클라우드 통합 모니터링 시스템 완성
- ✅ Global Dashboard를 통한 통합 시각화

#### **5교시: AWS ECS 고급 배포 ["90분"]**
- **목표**: AWS ECS를 활용한 프로덕션 배포 전략
- **실습**: ECS 서비스, 로드밸런서, 자동 스케일링 설정

**🔍 실습 코드 위치**
- **샘플 코드**: `cloud_intermediate/samples/day2/cloud-deployment/aws-ecs-deploy.sh`

**📋 실습 단계**
```bash
# 1. 클라우드 배포 실습 선택
# 메뉴에서 "2. 클라우드 배포 실습" 선택

# 2. ECS 클러스터 생성
./aws-ecs-deploy.sh deploy

# 3. Application Load Balancer 설정
# ALB, 타겟 그룹, 리스너 생성

# 4. 서비스 배포 및 상태 확인
./aws-ecs-deploy.sh status

# 5. 로그 확인
./aws-ecs-deploy.sh logs
```

**🎯 학습 결과**
- ✅ AWS ECS 고급 배포 전략
- ✅ Application Load Balancer 설정
- ✅ 자동 스케일링 및 헬스 체크

#### **4교시: GCP Cloud Run 고급 배포 ["90분"]**
- **목표**: GCP Cloud Run을 활용한 서버리스 배포 전략
- **실습**: Cloud Run 서비스, 도메인 매핑, 트래픽 분할

**🔍 실습 코드 위치**
- **샘플 코드**: `cloud_intermediate/samples/day2/cloud-deployment/gcp-cloud-run-deploy.sh`

**📋 실습 단계**
```bash
# 1. GCP Cloud Run 실습 선택
# 메뉴에서 "2. 클라우드 배포 실습" 선택

# 2. Docker 이미지 빌드 및 푸시
./gcp-cloud-run-deploy.sh deploy

# 3. 도메인 매핑 설정
./gcp-cloud-run-deploy.sh domain

# 4. 트래픽 분할 설정
./gcp-cloud-run-deploy.sh traffic

# 5. 서비스 상태 및 메트릭 확인
./gcp-cloud-run-deploy.sh status
./gcp-cloud-run-deploy.sh metrics
```

**🎯 학습 결과**
- ✅ GCP Cloud Run 고급 배포 전략
- ✅ 도메인 매핑 및 SSL 인증서 설정
- ✅ 트래픽 분할 및 카나리 배포

## 🛠️ **실습 자동화 도구**

### **통합 헬퍼 스크립트**
```bash
# 환경 체크
./cloud-intermediate-helper.sh check-environment

# CI/CD 실습
./cloud-intermediate-helper.sh cicd-practice

# 모니터링 실습
./cloud-intermediate-helper.sh monitoring-practice

# 클라우드 배포 실습
./cloud-intermediate-helper.sh cloud-deployment-practice
```

### **Day2 실습 자동화**
```bash
# 전체 Day2 실습 실행
./day2-practice.sh

# 개별 실습 실행
./day2-practice.sh cicd-pipeline
./day2-practice.sh cloud-deployment
./day2-practice.sh monitoring
```

### **모니터링 스택 자동화**
```bash
# 모니터링 스택 설정
./monitoring-stack.sh setup

# 서비스 상태 확인
./monitoring-stack.sh status

# Prometheus 타겟 확인
./monitoring-stack.sh targets

# 메트릭 쿼리 테스트
./monitoring-stack.sh test

# 정리
./monitoring-stack.sh cleanup
```

## 📊 **학습 성과 측정**

### **1교시 완료 확인**
- [ ] GitHub Actions 워크플로우 작성 완료
- [ ] 자동화된 테스트 및 빌드 파이프라인 구축
- [ ] Docker 이미지 빌드 및 푸시 자동화
- [ ] 보안 스캔 및 품질 검증 설정

### **1교시 테스트 과정**
```bash
# GitHub Actions 워크플로우 테스트
cd samples/day2/ci-cd-pipeline/
# GitHub에 푸시하여 Actions 실행 확인

# 로컬에서 워크플로우 테스트
act -j build-and-test

# Docker 이미지 빌드 테스트
docker build -t test-app:latest .

# 보안 스캔 테스트
trivy image test-app:latest
```

### **2교시 완료 확인**
- [ ] 멀티 클라우드 통합 모니터링 시스템 구축
- [ ] AWS 클러스터 Infrastructure/Platform 모니터링 설정
- [ ] Global Dashboard를 통한 통합 시각화
- [ ] 실제 운영 환경 수준의 모니터링 시스템 구축

### **2교시 테스트 과정**
```bash
# 통합 모니터링 스택 테스트
cd cloud_intermediate/repo/
bash scripts/test-monitoring-stack.sh

# Phase 2-4 클라우드 테스트
bash scripts/test-phase2-4-cloud.sh

# 모니터링 스택 상태 확인
bash scripts/monitoring-stack.sh status

# Prometheus 메트릭 확인
curl http://localhost:9090/api/v1/query?query=up

# Grafana 대시보드 확인
curl http://localhost:3000/api/health
```

### **3교시 완료 확인**
- [ ] GitHub Actions CI/CD 파이프라인 구축
- [ ] AWS EKS 애플리케이션 자동 배포
- [ ] Application 모니터링 설정
- [ ] 실시간 애플리케이션 성능 모니터링

### **3교시 테스트 과정**
```bash
# AWS EKS 클러스터 연결 확인
aws eks update-kubeconfig --name aws-monitoring-cluster --region us-west-2

# 애플리케이션 배포 테스트
kubectl apply -f samples/day2/monitoring-basics/k8s/aws-app-deployment.yml
kubectl apply -f samples/day2/monitoring-basics/k8s/aws-app-service.yml

# 배포 상태 확인
kubectl get pods
kubectl get services

# 애플리케이션 모니터링 확인
kubectl logs -l app=aws-monitoring-app
```

### **4교시 완료 확인**
- [ ] GCP GKE 클러스터 구축
- [ ] GCP Infrastructure/Platform 모니터링
- [ ] 멀티 클라우드 통합 모니터링 시스템 완성
- [ ] Global Dashboard를 통한 통합 시각화

### **4교시 테스트 과정**
```bash
# GCP GKE 클러스터 연결 확인
gcloud container clusters get-credentials gcp-monitoring-cluster --zone us-central1-a

# GCP 애플리케이션 배포 테스트
kubectl apply -f samples/day2/monitoring-basics/k8s/gcp-app-deployment.yml
kubectl apply -f samples/day2/monitoring-basics/k8s/gcp-app-service.yml

# 배포 상태 확인
kubectl get pods
kubectl get services

# 통합 모니터링 테스트
bash scripts/run-all-tests.sh

# 최종 통합 테스트
bash scripts/test-monitoring-stack.sh
```

## 🚨 **문제 해결 가이드**

### **CI/CD 관련 문제**
```bash
# GitHub Actions 워크플로우 디버깅
# 1. Actions 탭에서 워크플로우 실행 로그 확인
# 2. 로컬에서 동일한 명령어 실행 테스트
# 3. 시크릿 및 환경 변수 설정 확인

# Docker 빌드 문제
docker system prune -a
docker build --no-cache -t test-image .
```

### **모니터링 관련 문제**
```bash
# 모니터링 스택 재시작
./monitoring-stack.sh cleanup
./monitoring-stack.sh setup

# Prometheus 설정 확인
curl http://localhost:9090/api/v1/status/config

# Grafana 연결 확인
curl http://localhost:3000/api/health
```

### **클라우드 배포 관련 문제**
```bash
# AWS ECS 문제 해결
aws ecs describe-services --cluster your-cluster --services your-service
aws logs tail /ecs/your-service --follow

# GCP Cloud Run 문제 해결
gcloud run services describe your-service --region your-region
gcloud logging read "resource.type=cloud_run_revision" --limit 50
```

## 📚 **추가 학습 자료**

### **공식 문서**
- ["GitHub Actions 공식 문서"][https://docs.github.com/en/actions]
- ["Prometheus 공식 문서"][https://prometheus.io/docs/]
- ["Grafana 공식 문서"][https://grafana.com/docs/]
- ["AWS ECS 공식 문서"][https://docs.aws.amazon.com/ecs/]
- ["GCP Cloud Run 공식 문서"][https://cloud.google.com/run/docs]

### **실습 코드 저장소**
- [GitHub Repository][https://github.com/jungfrau70/cloud-intermediate.git]
- ["실습 코드"][./cloud_intermediate/samples/day2/]
- ["자동화 스크립트"][./cloud_intermediate/scripts/]

## 🎯 **다음 단계 안내**

### **Cloud Master 과정 준비**
- [ ] Day2 실습 완료 확인
- [ ] 고급 CI/CD 파이프라인 설계
- [ ] Kubernetes 고급 활용 준비
- [ ] 모니터링 및 로깅 시스템 고도화

### **실무 적용 방안**
- [ ] 회사 프로젝트에 CI/CD 파이프라인 도입
- [ ] 클라우드 배포 전략 수립
- [ ] 모니터링 시스템 구축 계획
- [ ] DevOps 문화 정착 방안

### **심화 학습 방향**
- [ ] Kubernetes 고급 기능 학습
- [ ] 마이크로서비스 아키텍처 설계
- [ ] 클라우드 네이티브 보안
- [ ] 성능 최적화 및 비용 관리

---

**💡 궁금한 점이 있으시면 언제든 문의해주세요!**  
**문제가 발생하거나 도움이 필요하시면 실시간으로 지원해드리겠습니다.**
