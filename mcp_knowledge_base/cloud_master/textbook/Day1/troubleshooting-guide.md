# 트러블슈팅 가이드

<div align="center">

[← 이전: Cloud Master 메인](../README.md) | [📚 전체 커리큘럼](/curriculum.md) | [🏠 학습 경로로 돌아가기](/index.md) | [📋 학습 경로](../../learning-path.md)

</div>

<div align="center">

[← 이전: Cloud Master 1일차 메인](../README.md) | [📚 전체 커리큘럼](/curriculum.md) | [🏠 학습 경로로 돌아가기](/index.md)

</div>

## 📋 목차
1. [Docker 관련 문제](#docker-관련-문제)
2. [GitHub Actions 관련 문제](#github-actions-관련-문제)
3. [AWS ECS 관련 문제](#aws-ecs-관련-문제)
4. [GCP Cloud Run 관련 문제](#gcp-cloud-run-관련-문제)
5. [멀티클라우드 배포 문제](#멀티클라우드-배포-문제)
6. [권한 및 인증 문제](#권한-및-인증-문제)
7. [네트워크 및 연결 문제](#네트워크-및-연결-문제)
8. [성능 및 최적화 문제](#성능-및-최적화-문제)
9. [일반적인 오류 코드](#일반적인-오류-코드)

---

## 🐳 Docker 관련 문제

### 문제 1: Docker 빌드 실패

#### 증상
```bash
ERROR: failed to solve: failed to compute cache key: failed to calculate checksum of ref
```

#### 원인
- Dockerfile 문법 오류
- 베이스 이미지가 존재하지 않음
- 네트워크 연결 문제

#### 해결 방법
```bash
# 1. Dockerfile 문법 확인
docker build --no-cache -t my-app .

# 2. 베이스 이미지 확인
docker pull node:18

# 3. 네트워크 연결 확인
docker run --rm alpine ping -c 3 google.com
```

### 문제 2: 컨테이너 시작 실패

#### 증상
```bash
ERROR: container exited with code 1
```

#### 원인
- 애플리케이션 코드 오류
- 환경변수 설정 문제
- 포트 충돌

#### 해결 방법
```bash
# 1. 컨테이너 로그 확인
docker logs <container_id>

# 2. 컨테이너 내부 접속
docker exec -it <container_id> /bin/bash

# 3. 환경변수 확인
docker run -e DEBUG=1 my-app
```

### 문제 3: Docker Compose 서비스 시작 실패

#### 증상
```bash
ERROR: for web  Cannot start service web: driver failed programming external connectivity
```

#### 원인
- 포트 충돌
- 네트워크 설정 문제
- 볼륨 마운트 오류

#### 해결 방법
```bash
# 1. 포트 사용 확인
netstat -tulpn | grep :3000

# 2. Docker Compose 로그 확인
docker-compose logs web

# 3. 서비스 재시작
docker-compose down
docker-compose up -d
```

---

## ⚡ GitHub Actions 관련 문제

### 문제 1: 워크플로우 실행 실패

#### 증상
```yaml
Error: Process completed with exit code 1
```

#### 원인
- 시크릿 설정 누락
- 권한 부족
- 워크플로우 문법 오류

#### 해결 방법
```bash
# 1. 시크릿 확인
# GitHub Repository → Settings → Secrets and variables → Actions

# 2. 워크플로우 문법 검사
# GitHub Actions 탭에서 오류 메시지 확인

# 3. 권한 확인
# Repository Settings → Actions → General
```

### 문제 2: Docker Hub 푸시 실패

#### 증상
```bash
Error: denied: requested access to the resource is denied
```

#### 원인
- Docker Hub 토큰 누락 또는 만료
- 저장소 권한 부족

#### 해결 방법
```bash
# 1. Docker Hub 토큰 재생성
# Docker Hub → Account Settings → Security → New Access Token

# 2. GitHub 시크릿 업데이트
# DOCKERHUB_TOKEN 시크릿 업데이트
```

---

## 🔐 권한 및 인증 문제

### 문제 1: AWS ECS 배포 실패

#### 증상
```bash
Error: User is not authorized to perform: ecs:UpdateService
```

#### 원인
- IAM 권한 부족
- 액세스 키 만료

#### 해결 방법
```bash
# 1. IAM 정책 확인
aws iam list-attached-user-policies --user-name github-actions-deploy

# 2. 필요한 권한 추가
# ECS: UpdateService, DescribeServices, RegisterTaskDefinition
# ECR: GetAuthorizationToken, BatchGetImage
```

### 문제 2: GCP Cloud Run 배포 실패

#### 증상
```bash
Error: Permission 'run.services.create' denied
```

#### 원인
- 서비스 계정 권한 부족
- API 미활성화

#### 해결 방법
```bash
# 1. 서비스 계정 권한 확인
gcloud projects get-iam-policy PROJECT_ID

# 2. 필요한 권한 부여
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:github-actions-deploy@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/run.admin"

# 3. API 활성화
gcloud services enable run.googleapis.com
```

---

## 🌐 멀티클라우드 배포 문제

### 문제 1: AWS와 GCP 동시 배포 실패

#### 증상
```bash
# AWS 배포는 성공, GCP 배포는 실패
AWS ECS Status: success
GCP Cloud Run Status: failure
```

#### 원인
- 클라우드별 독립적인 권한 문제
- 네트워크 연결 문제

#### 해결 방법
```bash
# 1. 각 클라우드별 권한 독립 확인
# AWS: IAM 정책 확인
# GCP: 서비스 계정 권한 확인

# 2. 워크플로우에서 continue-on-error: true 사용
# 한 클라우드 실패 시 다른 클라우드는 계속 진행
```

### 문제 2: Docker 이미지 태그 불일치

#### 증상
```bash
Error: image not found in registry
```

#### 원인
- 이미지 태그 불일치
- 레지스트리 동기화 문제

#### 해결 방법
```bash
# 1. 이미지 태그 확인
docker images | grep actions-demo

# 2. 레지스트리 동기화 확인
# Docker Hub와 GCR 모두에 동일한 태그로 푸시되었는지 확인
```

---

## ⚡ GitHub Actions 관련 문제

### 문제 1: 워크플로우 실행 실패

#### 증상
```yaml
Error: Process completed with exit code 1
```

#### 원인
- YAML 문법 오류
- Secrets 설정 누락
- 권한 부족

#### 해결 방법
```yaml
# 1. YAML 문법 검증
name: Test Workflow
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Test step
        run: echo "Hello World"

# 2. Secrets 확인
- name: Use secret
  run: echo "Using secret"
  env:
    MY_SECRET: ${{ secrets.MY_SECRET }}

# 3. 권한 확인
permissions:
  contents: read
  actions: write
```

### 문제 2: Docker 이미지 빌드 실패

#### 증상
```bash
ERROR: failed to solve: failed to compute cache key
```

#### 원인
- Dockerfile 경로 오류
- 컨텍스트 문제
- 캐시 문제

#### 해결 방법
```yaml
# 1. 올바른 컨텍스트 설정
- name: Build Docker image
  run: docker build -t my-app .
  working-directory: ./app

# 2. 캐시 사용
- name: Build with cache
  uses: docker/build-push-action@v5
  with:
    context: .
    push: false
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

### 문제 3: AWS/GCP 인증 실패

#### 증상
```bash
ERROR: The security token included in the request is invalid
```

#### 원인
- 잘못된 자격증명
- 만료된 토큰
- 권한 부족

#### 해결 방법
```yaml
# 1. AWS 자격증명 확인
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: us-west-1

# 2. GCP 서비스 계정 확인
- name: Setup Google Cloud SDK
  uses: google-github-actions/setup-gcloud@v1
  with:
    project_id: ${{ secrets.GCP_PROJECT_ID }}
    service_account_key: ${{ secrets.GCP_SA_KEY }}
    export_default_credentials: true
```

---

## ☁️ AWS ECS 관련 문제

### 문제 1: ECS 서비스 시작 실패

#### 증상
```bash
ERROR: Service was unable to place a task
```

#### 원인
- 리소스 부족
- 보안 그룹 설정 문제
- 서브넷 설정 문제

#### 해결 방법
```bash
# 1. 클러스터 용량 확인
aws ecs describe-clusters --clusters my-cluster

# 2. 보안 그룹 확인
aws ec2 describe-security-groups --group-ids sg-12345

# 3. 서브넷 확인
aws ec2 describe-subnets --subnet-ids subnet-12345
```

### 문제 2: ECR 이미지 푸시 실패

#### 증상
```bash
ERROR: no basic auth credentials
```

#### 원인
- ECR 로그인 실패
- 권한 부족
- 리포지토리 존재하지 않음

#### 해결 방법
```bash
# 1. ECR 로그인
aws ecr get-login-password --region us-west-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-west-1.amazonaws.com

# 2. 리포지토리 생성
aws ecr create-repository --repository-name my-app

# 3. 권한 확인
aws ecr describe-repositories --repository-names my-app
```

### 문제 3: ECS 태스크 중지

#### 증상
```bash
ERROR: Task stopped with exit code 1
```

#### 원인
- 애플리케이션 오류
- 환경변수 문제
- 헬스체크 실패

#### 해결 방법
```bash
# 1. 태스크 로그 확인
aws logs get-log-events --log-group-name /ecs/my-app --log-stream-name ecs/my-app/<task-id>

# 2. 태스크 정의 확인
aws ecs describe-task-definition --task-definition my-app-task

# 3. 헬스체크 설정 확인
aws ecs describe-services --cluster my-cluster --services my-app-service
```

---

## ☸️ GCP GKE 관련 문제

### 문제 1: GKE 클러스터 생성 실패

#### 증상
```bash
ERROR: (gcloud.container.clusters.create) ResponseError: code=400, message=Insufficient regional quota
```

#### 원인
- 할당량 초과
- 권한 부족
- 리전 설정 문제

#### 해결 방법
```bash
# 1. 할당량 확인
gcloud compute project-info describe --project=YOUR_PROJECT_ID

# 2. 권한 확인
gcloud projects get-iam-policy YOUR_PROJECT_ID

# 3. 다른 리전 시도
gcloud container clusters create my-cluster --zone us-central1-b
```

### 문제 2: Pod 시작 실패

#### 증상
```bash
ERROR: ImagePullBackOff
```

#### 원인
- 이미지 경로 오류
- GCR 권한 문제
- 이미지 존재하지 않음

#### 해결 방법
```bash
# 1. 이미지 확인
gcloud container images list --repository=gcr.io/YOUR_PROJECT_ID

# 2. Pod 상세 정보 확인
kubectl describe pod <pod-name>

# 3. 이미지 다시 푸시
docker push gcr.io/YOUR_PROJECT_ID/my-app:latest
```

### 문제 3: Service 외부 IP 할당 실패

#### 증상
```bash
EXTERNAL-IP: <pending>
```

#### 원인
- LoadBalancer 할당량 초과
- 방화벽 규칙 문제
- 네트워크 설정 문제

#### 해결 방법
```bash
# 1. Service 상세 정보 확인
kubectl describe service my-app-service

# 2. 방화벽 규칙 확인
gcloud compute firewall-rules list

# 3. 네트워크 확인
gcloud compute networks list
```

---

## 🌐 네트워크 및 연결 문제

### 문제 1: 컨테이너 간 통신 실패

#### 증상
```bash
ERROR: Connection refused
```

#### 원인
- 네트워크 설정 문제
- 포트 매핑 오류
- 방화벽 차단

#### 해결 방법
```yaml
# docker-compose.yml에서 네트워크 설정
version: '3.8'
services:
  web:
    build: .
    ports:
      - "3000:3000"
    networks:
      - app-network
  db:
    image: mongo
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

### 문제 2: 외부 접속 불가

#### 증상
```bash
ERROR: Connection timeout
```

#### 원인
- 보안 그룹 설정
- 로드 밸런서 설정
- DNS 문제

#### 해결 방법
```bash
# 1. 보안 그룹 확인 (AWS)
aws ec2 describe-security-groups --group-ids sg-12345

# 2. 로드 밸런서 확인
kubectl get services

# 3. DNS 확인
nslookup <domain-name>
```

---

## ⚡ 성능 및 최적화 문제

### 문제 1: 빌드 시간이 너무 오래 걸림

#### 원인
- 캐시 미사용
- 불필요한 의존성
- 네트워크 지연

#### 해결 방법
```dockerfile
# 1. 멀티스테이지 빌드 사용
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
CMD ["npm", "start"]

# 2. .dockerignore 파일 사용
node_modules
npm-debug.log
.git
.gitignore
```

### 문제 2: 컨테이너 메모리 사용량 과다

#### 원인
- 메모리 누수
- 리소스 제한 없음
- 비효율적인 코드

#### 해결 방법
```yaml
# Kubernetes 리소스 제한
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

---

## 🚨 일반적인 오류 코드

### Docker 오류 코드

| 오류 코드 | 의미 | 해결 방법 |
|-----------|------|-----------|
| **125** | Docker 데몬 오류 | Docker 서비스 재시작 |
| **126** | 컨테이너 명령어 실행 불가 | 실행 권한 확인 |
| **127** | 명령어를 찾을 수 없음 | PATH 확인 |
| **128** | 잘못된 종료 인수 | 종료 코드 확인 |

### Kubernetes 오류 코드

| 오류 코드 | 의미 | 해결 방법 |
|-----------|------|-----------|
| **0** | 성공 | 정상 종료 |
| **1** | 일반 오류 | 로그 확인 |
| **2** | 잘못된 사용법 | 명령어 문법 확인 |
| **126** | 명령어 실행 불가 | 권한 확인 |
| **127** | 명령어를 찾을 수 없음 | 이미지 확인 |

### AWS ECS 오류 코드

| 오류 코드 | 의미 | 해결 방법 |
|-----------|------|-----------|
| **1** | 애플리케이션 오류 | 애플리케이션 로그 확인 |
| **2** | 잘못된 사용법 | 태스크 정의 확인 |
| **125** | Docker 데몬 오류 | ECS 에이전트 재시작 |
| **126** | 컨테이너 실행 불가 | 이미지 및 권한 확인 |

---

## 🔧 디버깅 도구 및 명령어

### Docker 디버깅
```bash
# 컨테이너 로그 확인
docker logs <container_id>

# 컨테이너 내부 접속
docker exec -it <container_id> /bin/bash

# 컨테이너 상세 정보
docker inspect <container_id>

# Docker 시스템 정보
docker system df
docker system prune
```

### Kubernetes 디버깅
```bash
# Pod 로그 확인
kubectl logs <pod_name>

# Pod 상세 정보
kubectl describe pod <pod_name>

# Pod 내부 접속
kubectl exec -it <pod_name> -- /bin/bash

# 이벤트 확인
kubectl get events --sort-by=.metadata.creationTimestamp
```

### AWS ECS 디버깅
```bash
# 서비스 상태 확인
aws ecs describe-services --cluster my-cluster --services my-app-service

# 태스크 상태 확인
aws ecs describe-tasks --cluster my-cluster --tasks <task_arn>

# 로그 확인
aws logs get-log-events --log-group-name /ecs/my-app --log-stream-name <stream_name>
```

### GCP GKE 디버깅
```bash
# 클러스터 상태 확인
gcloud container clusters describe my-cluster --zone us-central1-a

# 노드 상태 확인
kubectl get nodes

# 리소스 사용량 확인
kubectl top nodes
kubectl top pods
```

---

## 📞 지원 및 도움말

### 공식 문서
- [Docker 공식 문서](https://docs.docker.com/)
- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [AWS ECS 공식 문서](https://docs.aws.amazon.com/ecs/)
- [GCP GKE 공식 문서](https://cloud.google.com/kubernetes-engine/docs)

### 커뮤니티 지원
- [Docker Community](https://forums.docker.com/)
- [GitHub Community](https://github.community/)
- [AWS Developer Forums](https://forums.aws.amazon.com/)
- [Google Cloud Community](https://cloud.google.com/community)

### 문제 보고
문제가 지속되면 다음 정보와 함께 이슈를 생성하세요:
- 오류 메시지 전체
- 실행 환경 정보
- 재현 단계
- 로그 파일

---

## ✅ 체크리스트

### 문제 해결 전 확인사항
- [ ] 최신 버전 사용 중인가요?
- [ ] 권한 설정이 올바른가요?
- [ ] 네트워크 연결이 정상인가요?
- [ ] 리소스 할당량이 충분한가요?
- [ ] 로그를 확인했나요?

### 문제 해결 후 확인사항
- [ ] 문제가 해결되었나요?
- [ ] 다른 기능에 영향을 주지 않나요?
- [ ] 성능이 정상인가요?
- [ ] 모니터링이 정상 작동하나요?

이 가이드를 통해 대부분의 문제를 해결할 수 있습니다. 추가 도움이 필요하면 언제든 문의하세요! 🚀

---

<div align="center">

[← 이전: CI/CD 파이프라인 가이드](./cicd-pipeline-guide) | [📚 전체 커리큘럼](../../../curriculum) | [다음: Cloud Master 2일차 →](../Day2/README)

</div>

## GCP Cloud Run 관련 문제
