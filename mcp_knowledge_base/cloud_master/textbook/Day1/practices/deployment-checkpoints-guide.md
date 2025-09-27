# 배포 후 체크포인트 및 확인 가이드

## 🎯 개요

이 가이드는 Cloud Master 과정에서 배포한 인프라와 애플리케이션을 확인하는 방법을 단계별로 안내합니다. 각 일차별로 배포 후 확인해야 할 체크포인트와 친절한 안내를 포함합니다.

---

## 📋 Day 1: 기본 CI/CD 파이프라인 배포 후 확인

### 1단계: GitHub Actions 워크플로우 확인

#### 체크포인트 1: 워크플로우 실행 상태 확인
```bash
# GitHub 저장소에서 확인
echo "🔍 GitHub Actions 워크플로우 확인 방법:"
echo "1. GitHub 저장소 페이지에서 'Actions' 탭 클릭"
echo "2. 'CI Pipeline' 워크플로우 클릭"
echo "3. 최신 실행 결과 확인 ["초록색 체크마크 = 성공"]"
```

**수동 확인 방법:**
1. GitHub 저장소 페이지에서 'Actions' 탭 클릭
2. 'CI Pipeline' 워크플로우 클릭
3. 최신 실행 결과 확인 ["초록색 체크마크 = 성공"]

#### 체크포인트 2: 워크플로우 로그 확인
```bash
# 자동화 스크립트로 로그 확인
scripts/check-github-actions-logs.sh

# 수동 확인 방법
echo "📊 워크플로우 로그 확인 방법:"
echo "1. Actions 탭에서 실행 중인 워크플로우 클릭"
echo "2. 각 Job [test, build, security-scan] 클릭"
echo "3. 실패한 경우 빨간색 X 표시와 함께 오류 메시지 확인"
```

**수동 확인 방법:**
1. Actions 탭에서 실행 중인 워크플로우 클릭
2. 각 Job [test, build, security-scan] 클릭
3. 실패한 경우 빨간색 X 표시와 함께 오류 메시지 확인

### 2단계: Docker 이미지 빌드 확인

#### 체크포인트 3: Docker Hub 이미지 확인
```bash
# Docker Hub에서 이미지 확인
echo "🐳 Docker 이미지 확인 방법:"
echo "1. Docker Hub [https://hub.docker.com] 로그인"
echo "2. 저장소 목록에서 'YOUR_USERNAME/app' 확인"
echo "3. 최신 태그 [latest, main-COMMIT_SHA] 확인"

# 로컬에서 이미지 테스트
docker pull YOUR_USERNAME/app:latest
docker run -d -p 3000:3000 --name test-app YOUR_USERNAME/app:latest
curl http://localhost:3000
```

**수동 확인 방법:**
1. Docker Hub [https://hub.docker.com] 로그인
2. 저장소 목록에서 'YOUR_USERNAME/app' 확인
3. 최신 태그 [latest, main-COMMIT_SHA] 확인

#### 체크포인트 4: Docker 이미지 품질 확인
```bash
# 이미지 보안 스캔
docker scan YOUR_USERNAME/app:latest

# 이미지 크기 확인
docker images YOUR_USERNAME/app

# 이미지 히스토리 확인
docker history YOUR_USERNAME/app:latest
```

### 3단계: VM 배포 확인

#### 체크포인트 5: AWS EC2 인스턴스 확인
```bash
# AWS CLI로 인스턴스 상태 확인
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,InstanceType]' --output table

# SSH 연결 테스트
ssh -i ~/.ssh/your-key.pem ec2-user@YOUR_EC2_IP

# 애플리케이션 상태 확인
curl http://YOUR_EC2_IP:3000
curl http://YOUR_EC2_IP:3000/health
```

**수동 확인 방법:**
1. AWS Management Console → EC2 → Instances
2. 인스턴스 상태 확인 [running]
3. 퍼블릭 IP 주소 확인
4. 웹 브라우저에서 `http://YOUR_EC2_IP:3000` 접속

#### 체크포인트 6: GCP Compute Engine 확인
```bash
# GCP CLI로 인스턴스 상태 확인
gcloud compute instances list --format="table[name,zone,machineType,status,EXTERNAL_IP]"

# SSH 연결 테스트
gcloud compute ssh YOUR_INSTANCE_NAME --zone=YOUR_ZONE

# 애플리케이션 상태 확인
curl http://YOUR_GCP_IP:3000
curl http://YOUR_GCP_IP:3000/health
```

**수동 확인 방법:**
1. GCP Console → Compute Engine → VM instances
2. 인스턴스 상태 확인 [running]
3. 외부 IP 주소 확인
4. 웹 브라우저에서 `http://YOUR_GCP_IP:3000` 접속

### Day 1 자동 확인 스크립트
```bash
#!/bin/bash
# day1-check.sh

echo "🎯 Day 1 배포 후 자동 확인 시작..."

# 1. GitHub Actions 상태 확인
echo "1️⃣ GitHub Actions 워크플로우 확인"
cloud-scripts/check-github-actions.sh

# 2. Docker 이미지 확인
echo "2️⃣ Docker 이미지 확인"
cloud-scripts/check-docker-images.sh

# 3. VM 배포 확인
echo "3️⃣ VM 배포 확인"
cloud-scripts/check-vm-deployment.sh

# 4. 애플리케이션 상태 확인
echo "4️⃣ 애플리케이션 상태 확인"
cloud-scripts/check-application-health.sh

echo "✅ Day 1 확인 완료!"
```

---

## 📋 Day 2: 고급 CI/CD 파이프라인 배포 후 확인

### 1단계: 매트릭스 빌드 확인

#### 체크포인트 7: 다중 환경 빌드 결과 확인
```bash
# 매트릭스 빌드 결과 확인
echo "🔧 매트릭스 빌드 확인 방법:"
echo "1. GitHub Actions에서 'Advanced CI/CD Pipeline' 워크플로우 확인"
echo "2. 각 Node.js 버전 [16, 18, 20]별 빌드 결과 확인"
echo "3. 각 OS [Ubuntu, Windows, macOS]별 빌드 결과 확인"
echo "4. 모든 조합이 성공했는지 확인"
```

#### 체크포인트 8: 빌드 아티팩트 확인
```bash
# 빌드 아티팩트 다운로드 및 확인
gh run download --repo YOUR_USERNAME/YOUR_REPO
ls -la artifacts/

# 각 환경별 빌드 결과 확인
echo "📦 빌드 아티팩트 확인:"
echo "1. Actions 탭에서 'Advanced CI/CD Pipeline' 실행 클릭"
echo "2. 'Artifacts' 섹션에서 다운로드 가능한 파일 확인"
echo "3. 각 환경별 빌드 결과 다운로드하여 확인"
```

### 2단계: 환경별 배포 확인

#### 체크포인트 9: Staging 환경 확인
```bash
# Staging 환경 확인
echo "🧪 Staging 환경 확인:"
echo "1. develop 브랜치 푸시 시 Staging 환경 배포 확인"
echo "2. Staging URL 접속: http://staging.your-domain.com"
echo "3. 애플리케이션 기능 테스트"
echo "4. 로그 확인: kubectl logs -f deployment/my-app-staging"
```

#### 체크포인트 10: Production 환경 확인
```bash
# Production 환경 확인
echo "🚀 Production 환경 확인:"
echo "1. main 브랜치 푸시 시 Production 환경 배포 확인"
echo "2. Production URL 접속: http://your-domain.com"
echo "3. 애플리케이션 기능 테스트"
echo "4. 로그 확인: kubectl logs -f deployment/my-app-production"
```

### 3단계: Kubernetes 배포 확인

#### 체크포인트 11: EKS 클러스터 확인
```bash
# EKS 클러스터 상태 확인
aws eks describe-cluster --name my-cluster --region us-west-2

# 클러스터 연결 및 상태 확인
aws eks update-kubeconfig --region us-west-2 --name my-cluster
kubectl cluster-info
kubectl get nodes
kubectl get pods -A
```

#### 체크포인트 12: GKE 클러스터 확인
```bash
# GKE 클러스터 상태 확인
gcloud container clusters describe my-cluster --zone us-central1-a

# 클러스터 연결 및 상태 확인
gcloud container clusters get-credentials my-cluster --zone us-central1-a
kubectl cluster-info
kubectl get nodes
kubectl get pods -A
```

#### 체크포인트 13: 애플리케이션 배포 확인
```bash
# 애플리케이션 배포 상태 확인
kubectl get deployments
kubectl get services
kubectl get ingress

# 애플리케이션 로그 확인
kubectl logs -f deployment/my-app

# 애플리케이션 접속 테스트
kubectl port-forward service/my-app-service 3000:80
curl http://localhost:3000
```

### Day 2 자동 확인 스크립트
```bash
#!/bin/bash
# day2-check.sh

echo "🎯 Day 2 배포 후 자동 확인 시작..."

# 1. 매트릭스 빌드 확인
echo "1️⃣ 매트릭스 빌드 확인"
cloud-scripts/check-matrix-build.sh

# 2. 환경별 배포 확인
echo "2️⃣ 환경별 배포 확인"
cloud-scripts/check-environment-deployment.sh

# 3. Kubernetes 클러스터 확인
echo "3️⃣ Kubernetes 클러스터 확인"
cloud-scripts/check-k8s-clusters.sh

# 4. 애플리케이션 배포 확인
echo "4️⃣ 애플리케이션 배포 확인"
cloud-scripts/check-k8s-deployment.sh

echo "✅ Day 2 확인 완료!"
```

---

## 📋 Day 3: 모니터링 및 최적화 CI/CD 배포 후 확인

### 1단계: 모니터링 스택 확인

#### 체크포인트 14: Prometheus 확인
```bash
# Prometheus 상태 확인
kubectl get pods -n monitoring
kubectl get services -n monitoring

# Prometheus 접속 확인
kubectl port-forward service/prometheus 9090:9090 -n monitoring
echo "📊 Prometheus 접속: http://localhost:9090"
echo "1. Prometheus 웹 UI 접속"
echo "2. Status > Targets에서 모든 타겟이 UP 상태인지 확인"
echo "3. Graph에서 메트릭 쿼리 테스트"
```

#### 체크포인트 15: Grafana 확인
```bash
# Grafana 상태 확인
kubectl get pods -n monitoring
kubectl get services -n monitoring

# Grafana 접속 확인
kubectl port-forward service/grafana 3000:3000 -n monitoring
echo "📈 Grafana 접속: http://localhost:3000"
echo "1. Grafana 웹 UI 접속 [admin/admin]"
echo "2. Data Sources에서 Prometheus 연결 확인"
echo "3. 대시보드에서 메트릭 시각화 확인"
```

### 2단계: 로드밸런서 확인

#### 체크포인트 16: AWS ALB 확인
```bash
# ALB 상태 확인
aws elbv2 describe-load-balancers --query 'LoadBalancers[*].[LoadBalancerName,State.Code,DNSName]' --output table

# 타겟 그룹 상태 확인
aws elbv2 describe-target-groups --query 'TargetGroups[*].[TargetGroupName,HealthCheckPath,Port]' --output table

# 로드밸런서 접속 테스트
ALB_DNS=$[aws elbv2 describe-load-balancers --query 'LoadBalancers[0].DNSName' --output text]
curl http://$ALB_DNS
```

#### 체크포인트 17: GCP Load Balancer 확인
```bash
# GCP Load Balancer 상태 확인
gcloud compute forwarding-rules list --global
gcloud compute backend-services list --global

# 로드밸런서 접속 테스트
LB_IP=$[gcloud compute forwarding-rules describe my-forwarding-rule --global --format="value[IPAddress]"]
curl http://$LB_IP
```

### 3단계: 비용 최적화 확인

#### 체크포인트 18: AWS 비용 확인
```bash
# AWS 비용 확인
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost

# 사용하지 않는 리소스 확인
aws ec2 describe-instances --query 'Reservations[*].Instances[?State.Name==`stopped`].[InstanceId,State.Name]' --output table
```

#### 체크포인트 19: GCP 비용 확인
```bash
# GCP 비용 확인
gcloud billing budgets list
gcloud compute instances list --filter="status=TERMINATED"

# 비용 최적화 권장사항 확인
gcloud compute instances list --format="table[name,machineType,status,zone]"
```

### Day 3 자동 확인 스크립트
```bash
#!/bin/bash
# day3-check.sh

echo "🎯 Day 3 배포 후 자동 확인 시작..."

# 1. 모니터링 스택 확인
echo "1️⃣ 모니터링 스택 확인"
cloud-scripts/check-monitoring-stack.sh

# 2. 로드밸런서 확인
echo "2️⃣ 로드밸런서 확인"
cloud-scripts/check-load-balancers.sh

# 3. 비용 최적화 확인
echo "3️⃣ 비용 최적화 확인"
cloud-scripts/check-cost-optimization.sh

# 4. 통합 대시보드 확인
echo "4️⃣ 통합 대시보드 확인"
cloud-scripts/check-integrated-dashboard.sh

echo "✅ Day 3 확인 완료!"
```

---

## 🔧 통합 확인 스크립트

### 전체 과정 통합 확인
```bash
#!/bin/bash
# integrated-check.sh

echo "🎯 Cloud Master 전체 배포 후 통합 확인 시작..."

# Day 1 확인
echo "📅 Day 1: 기본 CI/CD 파이프라인 확인"
cloud-scripts/day1-check.sh

# Day 2 확인
echo "📅 Day 2: 고급 CI/CD 파이프라인 확인"
cloud-scripts/day2-check.sh

# Day 3 확인
echo "📅 Day 3: 모니터링 및 최적화 CI/CD 확인"
cloud-scripts/day3-check.sh

# 전체 상태 요약
echo "📊 전체 상태 요약"
cloud-scripts/generate-status-report.sh

echo "✅ 전체 확인 완료!"
```

### 문제 해결 가이드
```bash
#!/bin/bash
# troubleshooting-guide.sh

echo "🔧 문제 해결 가이드"

# 일반적인 문제 해결
echo "1️⃣ 일반적인 문제 해결:"
echo "- GitHub Actions 실패: 워크플로우 로그 확인"
echo "- Docker 빌드 실패: Dockerfile 문법 확인"
echo "- VM 연결 실패: 보안 그룹 설정 확인"
echo "- K8s 배포 실패: 매니페스트 파일 확인"

# 로그 확인 명령어
echo "2️⃣ 로그 확인 명령어:"
echo "- GitHub Actions: gh run view --log"
echo "- Docker: docker logs CONTAINER_NAME"
echo "- Kubernetes: kubectl logs -f deployment/APP_NAME"
echo "- AWS: aws logs describe-log-groups"

# 리소스 정리
echo "3️⃣ 리소스 정리:"
echo "- AWS: cloud-scripts/cleanup-aws.sh"
echo "- GCP: cloud-scripts/cleanup-gcp.sh"
echo "- Kubernetes: cloud-scripts/cleanup-k8s.sh"
```

---

## 📚 체크포인트 체크리스트

### Day 1 체크리스트
- [ ] GitHub Actions 워크플로우 실행 성공
- [ ] Docker 이미지 빌드 및 푸시 성공
- [ ] AWS EC2 인스턴스 실행 중
- [ ] GCP Compute Engine 인스턴스 실행 중
- [ ] 애플리케이션 접속 가능
- [ ] 헬스 체크 엔드포인트 응답

### Day 2 체크리스트
- [ ] 매트릭스 빌드 모든 조합 성공
- [ ] 환경별 배포 정상 작동
- [ ] Kubernetes 클러스터 정상 작동
- [ ] 애플리케이션 Pod 실행 중
- [ ] 서비스 및 인그레스 정상 작동

### Day 3 체크리스트
- [ ] Prometheus 메트릭 수집 정상
- [ ] Grafana 대시보드 정상 작동
- [ ] 로드밸런서 트래픽 분산 정상
- [ ] 비용 최적화 권장사항 확인
- [ ] 알림 시스템 정상 작동

---

## 🚨 문제 해결

### 일반적인 문제와 해결 방법

#### 1. GitHub Actions 실패
**문제**: 워크플로우 실행 실패
**해결 방법**:
1. Actions 탭에서 실패한 워크플로우 클릭
2. 실패한 Job 클릭하여 로그 확인
3. 오류 메시지에 따라 수정
4. 시크릿 설정 확인

#### 2. Docker 빌드 실패
**문제**: Docker 이미지 빌드 실패
**해결 방법**:
1. Dockerfile 문법 확인
2. 의존성 설치 오류 확인
3. Docker Hub 로그인 상태 확인
4. 이미지 태그 중복 확인

#### 3. VM 연결 실패
**문제**: SSH 연결 실패
**해결 방법**:
1. 보안 그룹 설정 확인
2. SSH 키 권한 확인
3. 인스턴스 상태 확인
4. 네트워크 설정 확인

#### 4. Kubernetes 배포 실패
**문제**: Pod 실행 실패
**해결 방법**:
1. 매니페스트 파일 문법 확인
2. 리소스 제한 확인
3. 이미지 풀 정책 확인
4. 네트워크 정책 확인

---

<div align="center">

["← 이전: GitHub Actions CI/CD 완전 가이드"](github-actions-cicd-guide.md) | 
["📚 전체 커리큘럼"](.curriculum.md) | 
["🏠 학습 경로로 돌아가기"](.index.md) | 
["다음: VM 배포 실습 →"](vm-deployment.md)

</div>
