# Container 과정 자동화 시스템

## 🎯 학습 목표

### 핵심 학습 목표
- **Cloud Container 기초** 클라우드 서비스 이해 및 활용
- **Cloud Container 실무** 실제 프로젝트 적용 능력 향상

### 실습 후 달성할 수 있는 능력
- ✅ 클라우드 서비스 기본 개념 이해
- ✅ 실제 환경에서 서비스 배포 및 관리
- ✅ 문제 해결 및 최적화 능력

### 예상 소요 시간
- **기초 학습**: 90-120분
- **실습 진행**: 60-90분
- **전체 과정**: 3-4시간


Kubernetes, ECS, Fargate, 고가용성 아키텍처 실습을 위한 자동화 스크립트 생성 시스템입니다.

## 📋 개요

Container 과정은 2일간의 심화 과정으로, 다음과 같은 내용을 다룹니다:

- **Day 1**: Kubernetes 및 GKE 고급 오케스트레이션
- **Day 2**: 고가용성 및 확장성 아키텍처

## 🛠️ 필수 도구

다음 도구들이 설치되어 있어야 합니다:

- **Docker** - 컨테이너 기술
- **Git** - 버전 관리
- **GitHub CLI** - GitHub 연동
- **AWS CLI** - AWS 서비스 연동
- **GCP CLI** - GCP 서비스 연동
- **kubectl** - Kubernetes 클러스터 관리
- **Helm** - Kubernetes 패키지 관리

## 🚀 사용법

### 1. 환경 설정

```bash
# 필수 도구 설치 확인
docker --version
kubectl version --client
helm version
aws --version
gcloud --version
```

### 2. 자동화 실행

```bash
# Container 과정 자동화 실행
python container_course_automation.py
```

### 3. 테스트 실행

```bash
# 단위 테스트 실행
python run_container_course_tests.py

# 또는 직접 pytest 실행
pytest test_container_course_automation.py -v
```

## 📁 생성되는 파일 구조

```
mcp_knowledge_base/cloud_container/automation/
├── day1/
│   ├── kubernetes_advanced.sh      # Kubernetes 고급 실습
│   ├── gke_cluster.sh             # GKE 클러스터 관리
│   ├── ecs_fargate.sh             # ECS Fargate 실습
│   └── advanced_cicd.sh           # 고급 CI/CD 파이프라인
├── day2/
│   ├── high_availability.sh       # 고가용성 아키텍처
│   ├── monitoring.sh              # 모니터링 및 로깅
│   └── comprehensive_project.sh   # 종합 프로젝트
├── scripts/                       # 추가 스크립트
├── templates/                     # 템플릿 파일
└── results/
    └── automation_results.json    # 자동화 결과
```

## 📚 실습 내용

### Day 1: Kubernetes 및 GKE 고급 오케스트레이션

1. **Kubernetes 고급 아키텍처**
   - 클러스터 아키텍처 및 컴포넌트
   - Deployment, Service, Ingress 설정
   - ConfigMap, Secret, PersistentVolume 관리

2. **GKE 클러스터 관리**
   - GKE 클러스터 생성 및 설정
   - 자동 스케일링 구성
   - 워크로드 배포 및 관리

3. **AWS ECS 및 Fargate**
   - ECS 클러스터 구성
   - Fargate 서버리스 컨테이너 실행
   - 태스크 정의 및 서비스 배포

4. **고급 CI/CD 파이프라인**
   - Multi-stage 배포 파이프라인
   - 환경별 배포 전략
   - GitOps 기반 배포 자동화

### Day 2: 고가용성 및 확장성 아키텍처

1. **고가용성 아키텍처 설계**
   - AWS Multi-AZ / GCP Multi-Region
   - 장애 복구 및 재해 복구 전략
   - Multi-AZ RDS 및 EC2 구성

2. **로드 밸런싱 및 Auto Scaling**
   - AWS ELB / GCP Cloud Load Balancing
   - Auto Scaling 정책 및 메트릭 기반 확장
   - Auto Scaling + Load Balancer 연동

3. **모니터링 및 로깅 시스템**
   - AWS CloudWatch / GCP Monitoring
   - Prometheus + Grafana 설정
   - 커스텀 메트릭 대시보드 구축

4. **종합 프로젝트**
   - 고가용성 웹 서비스 아키텍처 설계
   - 성능 최적화 및 비용 효율성 분석
   - 실제 서비스 시나리오 구현

## 🔧 환경 변수

다음 환경 변수를 설정할 수 있습니다:

```bash
export PROJECT_ID="your-gcp-project-id"
export AWS_REGION="us-west-2"
export COURSE_NAME="Cloud Container Course"
```

## 🐛 문제 해결

### 일반적인 문제

1. **kubectl 연결 오류**
   ```bash
   # GKE 클러스터 인증 정보 가져오기
   gcloud container clusters get-credentials CLUSTER_NAME --zone=ZONE
   ```

2. **AWS CLI 인증 오류**
   ```bash
   # AWS 자격 증명 설정
   aws configure
   ```

3. **Docker 권한 오류**
   ```bash
   # Docker 그룹에 사용자 추가
   sudo usermod -aG docker $USER
   ```

### 로그 확인

```bash
# 자동화 로그 확인
tail -f container_course_automation.log
```

## 📞 지원

문제가 발생하면 다음을 확인하세요:

1. 필수 도구가 모두 설치되어 있는지 확인
2. 환경 변수가 올바르게 설정되어 있는지 확인
3. 로그 파일에서 오류 메시지 확인
4. 테스트를 실행하여 문제 진단

## 📄 라이선스

이 프로젝트는 교육 목적으로 제작되었습니다.


---


---



<div align="center">

["📚 전체 커리큘럼"][curriculum.md] | ["🏠 학습 경로로 돌아가기"][index.md] | ["📋 학습 경로"][learning-path.md]

</div>