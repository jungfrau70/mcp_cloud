# Master 과정 연계 가이드

<div align="center">

[← 이전: Cloud Container 메인](/mcp_knowledge_base/cloud_master/README.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🏠 학습 경로로 돌아가기](/mcp_knowledge_base/index.md) | [📋 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>

## 🔗 Master 과정과의 연계

### Master 과정에서 학습한 내용
- ✅ **Docker 기초**: 컨테이너 이미지 빌드 및 실행
- ✅ **GitHub Actions**: CI/CD 파이프라인 구축
- ✅ **클라우드 배포 기초**: 배포 개념 및 시뮬레이션
- ✅ **자동 배포 파이프라인**: 테스트 → 빌드 → 배포 자동화

### Container 과정에서 확장하는 내용
- 🚀 **실제 클라우드 배포**: 시뮬레이션을 넘어 실제 AWS/GCP 환경에 배포
- 🚀 **컨테이너 오케스트레이션**: 다수의 컨테이너를 대규모로 관리
- 🚀 **고급 배포 전략**: 무중단 배포, 롤백, 트래픽 분산
- 🚀 **운영 자동화**: 모니터링, 알림, 자동 복구

### 학습 경로
```
Master 과정 (기초) → Container 과정 (고급)
     ↓                    ↓
시뮬레이션 배포    →    실제 클라우드 배포
단일 컨테이너     →    컨테이너 오케스트레이션
기본 CI/CD       →    고급 배포 전략
```

---

## 📦 actions-demo 프로젝트 활용

### 프로젝트 구조
```
actions-demo/
├── .github/workflows/     # GitHub Actions 워크플로우
├── tests/                 # 테스트 파일
├── app.js                 # Node.js 애플리케이션
├── package.json           # 의존성 관리
├── Dockerfile             # Docker 이미지 빌드
└── README.md              # 프로젝트 문서
```

### Master 과정에서 배포한 내용
- **Docker 이미지**: `actions-demo:latest`
- **GitHub Actions**: CI/CD 파이프라인
- **Docker Hub**: 이미지 레지스트리

### Container 과정에서 확장할 내용
- **AWS ECS**: Fargate 서비스로 배포
- **GCP GKE**: Kubernetes 클러스터에 배포
- **고급 모니터링**: Prometheus + Grafana
- **자동 확장**: HPA (Horizontal Pod Autoscaler)

---

## 🚀 Container 과정 실습 준비

### 1단계: Master 과정 프로젝트 복사
```bash
# Master 과정에서 사용한 프로젝트 복사
cp -r ../cloud_master/textbook/Day1/actions-demo ./container-demo
cd container-demo
```

### 2단계: Container 과정용 설정 추가
```bash
# Kubernetes 매니페스트 디렉토리 생성
mkdir k8s
mkdir k8s/aws-ecs
mkdir k8s/gcp-gke
```

### 3단계: 고급 워크플로우 활성화
```bash
# AWS ECS 배포 워크플로우 활성화
mv .github/workflows/aws-deploy.yml.disabled .github/workflows/aws-deploy.yml

# GCP GKE 배포 워크플로우 활성화
mv .github/workflows/gcp-deploy.yml.disabled .github/workflows/gcp-deploy.yml

# 멀티클라우드 배포 워크플로우 활성화
mv .github/workflows/multi-cloud-deploy.yml.disabled .github/workflows/multi-cloud-deploy.yml
```

---

## 📋 Container 과정 실습 순서

### Day 1: 컨테이너 기술 심화
1. **Docker 최적화**
   - Master 과정의 Dockerfile 개선
   - 멀티스테이지 빌드 적용
   - 이미지 크기 최적화

2. **GitHub Actions 고급 기능**
   - Master 과정의 워크플로우 확장
   - 매트릭스 빌드 추가
   - 보안 스캔 통합

3. **클라우드 컨테이너 서비스**
   - AWS ECS (Fargate) 배포
   - GCP Cloud Run 배포
   - GCP GKE 배포

### Day 2: 고가용성 아키텍처
1. **고가용성 아키텍처**
   - Multi-AZ 구성
   - 로드 밸런싱 설정
   - Auto Scaling 구성

2. **모니터링 및 로깅**
   - Prometheus + Grafana 설정
   - CloudWatch 통합
   - 알림 시스템 구성

3. **운영 자동화**
   - 자동 복구 시나리오
   - 보안 정책 적용
   - 비용 최적화

---

## 🔧 필요한 권한 및 설정

### AWS 권한
- ECS 서비스 접근 권한
- ECR 이미지 푸시 권한
- CloudWatch 로그 권한

### GCP 권한
- GKE 클러스터 관리 권한
- Cloud Run 배포 권한
- Container Registry 권한

### GitHub Secrets
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `GCP_PROJECT_ID`
- `GCP_SA_KEY`

---

## 📚 참고 자료

- [Master 과정: Docker 기초](/mcp_knowledge_base/cloud_master/textbook/Day1/docker-compose-guide.md)
- [Master 과정: GitHub Actions](/mcp_knowledge_base/cloud_master/textbook/Day1/github-actions-guide.md)
- [Master 과정: 클라우드 배포](/mcp_knowledge_base/cloud_master/textbook/Day1/cloud-deployment-guide.md)
- [Container 과정: 오케스트레이션 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/container-orchestration-guide.md)


---

<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_container/learning-path.md)

</div>

---

<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_container/learning-path.md)

</div>
