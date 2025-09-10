# Container 과정 실습 가이드

## 🎯 과정 개요

Container 과정은 Master 과정을 수료한 학습자를 대상으로 **고급 컨테이너 기술**을 학습하는 과정입니다.

### 📋 학습 목표
- Docker 최적화 및 멀티스테이지 빌드
- GitHub Actions 고급 CI/CD 파이프라인
- AWS ECS (Fargate) 및 GCP GKE 배포
- 고가용성 아키텍처 설계
- 모니터링 및 운영 자동화

---

## 🚀 실습 환경 준비

### 1단계: Master 과정 프로젝트 확인
Container 과정은 Master 과정의 `actions-demo` 프로젝트를 기반으로 합니다.

```bash
# Master 과정 프로젝트 경로 확인
ls ../cloud_master/textbook/Day1/actions-demo/
```

### 2단계: Container 과정용 환경 설정
```bash
# Container 과정용 실습 환경 설정
./container-demo-setup.sh
```

### 3단계: 생성된 파일 확인
```bash
# 생성된 디렉토리 구조 확인
tree container-demo/
```

---

## 📚 실습 순서

### Day 1: 컨테이너 기술 심화

#### 1교시: Docker 최적화 (60분)
- [Docker 최적화 실습](./docker-optimization-guide.md)
- 멀티스테이지 빌드 적용
- 이미지 크기 최적화

#### 2교시: GitHub Actions 고급 기능 (60분)
- [고급 CI/CD 파이프라인](./advanced-cicd-guide.md)
- 매트릭스 빌드 설정
- 보안 스캔 통합

#### 3교시: 클라우드 컨테이너 서비스 (90분)
- [AWS ECS 배포](./aws-ecs-deployment.md)
- [GCP Cloud Run 배포](./gcp-cloudrun-deployment.md)
- [GCP GKE 배포](./gcp-gke-deployment.md)

#### 4교시: 자동화된 배포 전략 (90분)
- [Blue-Green 배포](./blue-green-deployment.md)
- [환경 분리 전략](./environment-separation.md)

### Day 2: 고가용성 아키텍처

#### 1교시: 고가용성 아키텍처 설계 (90분)
- [Multi-AZ 구성](./multi-az-architecture.md)
- [로드 밸런싱 설정](./load-balancing-setup.md)
- [Auto Scaling 구성](./auto-scaling-setup.md)

#### 2교시: 모니터링 및 로깅 (90분)
- [Prometheus + Grafana 설정](./monitoring-setup.md)
- [CloudWatch 통합](./cloudwatch-integration.md)
- [알림 시스템 구성](./alerting-setup.md)

#### 3교시: 운영 자동화 (90분)
- [자동 복구 시나리오](./auto-recovery.md)
- [보안 정책 적용](./security-policies.md)
- [비용 최적화](./cost-optimization.md)

---

## 🔧 필요한 권한 및 설정

### AWS 권한
- ECS 서비스 접근 권한
- ECR 이미지 푸시 권한
- CloudWatch 로그 권한
- IAM 역할 생성 권한

### GCP 권한
- GKE 클러스터 관리 권한
- Cloud Run 배포 권한
- Container Registry 권한
- Monitoring 권한

### GitHub Secrets
```bash
# AWS 관련
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION

# GCP 관련
GCP_PROJECT_ID
GCP_SA_KEY
GCP_REGION

# Docker Hub
DOCKERHUB_TOKEN
```

---

## 📋 실습 체크리스트

### Day 1 체크리스트
- [ ] Docker 최적화 완료
- [ ] GitHub Actions 고급 워크플로우 설정
- [ ] AWS ECS 배포 성공
- [ ] GCP Cloud Run 배포 성공
- [ ] GCP GKE 배포 성공
- [ ] Blue-Green 배포 테스트

### Day 2 체크리스트
- [ ] Multi-AZ 아키텍처 구성
- [ ] 로드 밸런싱 설정 완료
- [ ] Auto Scaling 테스트
- [ ] 모니터링 대시보드 구성
- [ ] 알림 시스템 설정
- [ ] 자동 복구 시나리오 테스트

---

## 🐛 문제 해결

### 자주 발생하는 문제

#### 1. Docker 이미지 빌드 실패
```bash
# 해결방법: Dockerfile 문법 확인
docker build -f Dockerfile.container -t container-demo .
```

#### 2. AWS ECS 배포 실패
```bash
# 해결방법: IAM 권한 확인
aws sts get-caller-identity
aws ecs list-clusters
```

#### 3. GCP GKE 배포 실패
```bash
# 해결방법: 프로젝트 설정 확인
gcloud config get-value project
gcloud auth list
```

#### 4. 모니터링 데이터 수집 실패
```bash
# 해결방법: Prometheus 설정 확인
kubectl get configmap prometheus-config -o yaml
```

---

## 📚 참고 자료

### Master 과정 연계
- [Master 과정 연계 가이드](./master-integration-guide.md)
- [actions-demo 프로젝트](../cloud_master/textbook/Day1/actions-demo/)

### 공식 문서
- [Docker 공식 문서](https://docs.docker.com/)
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [AWS ECS 공식 문서](https://docs.aws.amazon.com/ecs/)
- [GCP GKE 공식 문서](https://cloud.google.com/kubernetes-engine/docs)

### 추가 학습 자료
- [Container 오케스트레이션 가이드](./container-orchestration-guide.md)
- [Kubernetes 고급 가이드](./kubernetes-advanced-guide.md)
- [자동 복구 가이드](./auto-recovery-guide.md)
- [보안 정책 가이드](./security-policies-guide.md)
- [비용 최적화 가이드](./cost-optimization-guide.md)
- [종합 실습 가이드](./comprehensive-practice-guide.md)

---

## 🤝 기여하기

1. 이 저장소를 포크하세요
2. 새로운 브랜치를 생성하세요 (`git checkout -b feature/amazing-feature`)
3. 변경사항을 커밋하세요 (`git commit -m 'Add amazing feature'`)
4. 브랜치에 푸시하세요 (`git push origin feature/amazing-feature`)
5. Pull Request를 생성하세요

---

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

---

**💡 팁**: Container 과정은 Master 과정의 연장선상에 있습니다. Master 과정을 먼저 수료한 후 시작하시기 바랍니다!
