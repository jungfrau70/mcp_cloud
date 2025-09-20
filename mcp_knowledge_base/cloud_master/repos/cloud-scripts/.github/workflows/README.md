# GitHub Actions CI/CD 파이프라인

## 🚀 개요

MCP Cloud Master Day1 실습을 위한 GitHub Actions CI/CD 파이프라인입니다.

### 파이프라인 흐름
1. **코드 푸시** → GitHub Actions 트리거
2. **Docker 이미지 빌드** → Docker Hub에 푸시
3. **VM 배포** → AWS EC2 또는 GCP Compute Engine에 자동 배포
4. **헬스체크** → 배포 상태 확인

## 🔧 설정 방법

### 1. GitHub Secrets 설정

Repository Settings → Secrets and variables → Actions에서 다음 시크릿을 설정하세요:

#### Docker Hub 설정
```
DOCKERHUB_USERNAME: your-dockerhub-username
DOCKERHUB_TOKEN: your-dockerhub-access-token
```

#### AWS 설정
```
AWS_ACCESS_KEY_ID: your-aws-access-key
AWS_SECRET_ACCESS_KEY: your-aws-secret-key
AWS_SSH_PRIVATE_KEY: your-aws-ssh-private-key
```

#### GCP 설정
```
GCP_PROJECT_ID: your-gcp-project-id
GCP_SA_KEY: your-gcp-service-account-key-json
GCP_SSH_PRIVATE_KEY: your-gcp-ssh-private-key
```

### 2. SSH 키 생성 및 설정

#### AWS EC2용 SSH 키
```bash
# AWS EC2용 SSH 키 생성
ssh-keygen -t rsa -b 4096 -f aws-key -C "mcp-cloud-master-aws"
# aws-key.pem을 AWS_SSH_PRIVATE_KEY에 설정
```

#### GCP Compute Engine용 SSH 키
```bash
# GCP용 SSH 키 생성
ssh-keygen -t rsa -b 4096 -f gcp-key -C "mcp-cloud-master-gcp"
# gcp-key.pem을 GCP_SSH_PRIVATE_KEY에 설정
```

### 3. Docker Hub 토큰 생성

1. Docker Hub 로그인
2. Account Settings → Security → New Access Token
3. 토큰 이름: `github-actions`
4. 권한: `Read, Write, Delete`
5. 생성된 토큰을 `DOCKERHUB_TOKEN`에 설정

## 🎯 워크플로우 트리거

### 자동 트리거
- `main` 또는 `develop` 브랜치에 푸시
- Pull Request 생성
- 다음 경로 변경 시:
  - `mcp_knowledge_base/cloud_master/repos/samples/day1/my-app/**`
  - `mcp_knowledge_base/cloud_master/repos/cloud-scripts/**`

### 수동 트리거
- Actions 탭 → "Cloud Master CI/CD Pipeline" → "Run workflow"
- 환경 선택: `aws` 또는 `gcp`
- 액션 선택: `deploy`, `build-only`, `cleanup`

## 📋 워크플로우 단계

### 1. Environment Check
- AWS/GCP VM IP 주소 확인
- 배포 대상 환경 검증

### 2. Build and Push
- Docker 이미지 빌드
- Docker Hub에 푸시
- 캐시 최적화

### 3. Deploy to AWS/GCP
- SSH를 통한 VM 접속
- 기존 컨테이너 정리
- 새 이미지 풀 및 실행
- 헬스체크 수행

### 4. Post Deployment Test
- 배포 상태 확인
- 애플리케이션 동작 테스트

### 5. Notification
- 성공/실패 알림
- 배포 상태 보고

## 🔍 모니터링

### 로그 확인
- Actions 탭에서 워크플로우 실행 로그 확인
- 각 단계별 상세 로그 제공

### 배포 상태 확인
```bash
# AWS VM에서 확인
ssh -i aws-key.pem ubuntu@[AWS-VM-IP] "docker ps"

# GCP VM에서 확인
ssh -i gcp-key.pem ubuntu@[GCP-VM-IP] "docker ps"
```

### 애플리케이션 접속
```bash
# AWS VM
curl http://[AWS-VM-IP]/health

# GCP VM
curl http://[GCP-VM-IP]/health
```

## 🐛 문제 해결

### 일반적인 문제

#### 1. Docker Hub 인증 실패
- `DOCKERHUB_USERNAME`과 `DOCKERHUB_TOKEN` 확인
- 토큰 권한 확인

#### 2. SSH 연결 실패
- SSH 키 형식 확인 (PEM 형식)
- VM 보안 그룹/방화벽 규칙 확인
- SSH 키가 VM에 등록되었는지 확인

#### 3. VM IP 조회 실패
- AWS/GCP 자격 증명 확인
- VM 태그 이름 확인
- VM이 실행 중인지 확인

#### 4. Docker 이미지 빌드 실패
- Dockerfile 문법 확인
- package.json 의존성 확인
- 빌드 컨텍스트 경로 확인

### 로그 분석
```bash
# GitHub Actions 로그에서 확인할 항목
- Environment Check: VM IP 조회 성공 여부
- Build and Push: Docker 이미지 빌드 및 푸시 성공 여부
- Deploy: SSH 연결 및 배포 성공 여부
- Post Deployment Test: 헬스체크 성공 여부
```

## 📚 추가 자료

- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [Docker Hub 공식 문서](https://docs.docker.com/docker-hub/)
- [AWS EC2 공식 문서](https://docs.aws.amazon.com/ec2/)
- [GCP Compute Engine 공식 문서](https://cloud.google.com/compute/docs)
