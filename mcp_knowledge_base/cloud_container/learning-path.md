# Cloud Container - 컨테이너 심화 학습 경로

> 📋 **전체 개요**: [README.md](/mcp_knowledge_base/cloud_master/README.md) | [통합 커리큘럼](/mcp_knowledge_base/curriculum.md) | [통합 인덱스](/mcp_knowledge_base/index.md)에서 전체 과정 구조를 확인하세요.

<div align="center">
</div>

---

## 🎯 학습 목표

이 문서는 **Cloud Container 과정**의 모든 문서를 **누락 없이** 체계적으로 정리한 완전한 학습 경로입니다. Kubernetes 오케스트레이션부터 고가용성 아키텍처, 엔터프라이즈급 운영까지 고급 컨테이너 기술을 단계별로 학습할 수 있도록 구성되어 있습니다.

## 📚 과정 개요

### Cloud Container - 컨테이너 심화 (2일)
- **교육명**: 클라우드 실무력 강화! AWS & GCP 활용법(컨테이너 심화)
- **교육일정**: 10/1(수) ~ 10/2(목)
- **교육시간**: 9:00 ~ 17:00 (7시간/일)
- **교육방식**: 오프라인
- **실습 환경**: AWS Free Tier + GCP Free Tier ($300 크레딧) + GitHub Free

### 과정 상세 정보
- [과정명 상세](/mcp_knowledge_base/cloud_container/과정명.md)
- [과정 상세 정보](/mcp_knowledge_base/cloud_container/과정상세.md)

### 학습 목표
- Docker 컨테이너 기술의 심화 활용 및 최적화
- GitHub Actions 기반 **CI/CD 파이프라인 완전 자동화** 구현
- AWS/GCP **고가용성 및 확장성 아키텍처 설계**
- 클라우드 **모니터링 및 로깅 시스템** 구축
- **실무 프로젝트 수행**을 통한 종합적인 클라우드 역량 강화

---

## 📅 1일차: Kubernetes 및 GKE 고급 오케스트레이션

### 1. Kubernetes 고급 아키텍처 (150분)

#### 핵심 문서
- [Kubernetes 고급 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/kubernetes-advanced-guide.md)
- [컨테이너 오케스트레이션 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/container-orchestration-guide.md)
- [Kubernetes 기본 실습](/mcp_knowledge_base/cloud_container/textbook/Day1/practice/kubernetes-basics.md)

#### 학습 내용
- Kubernetes 클러스터 아키텍처 및 컴포넌트
- GKE 클러스터 생성 및 고급 설정
- 실습: GKE 클러스터 생성 및 애플리케이션 배포

### 2. 컨테이너 오케스트레이션 고급 기법 (150분)

#### 핵심 문서
- [Deployment, Service, Ingress 설정](./textbook/Day1/README.md#deployment-service-ingress-설정)
- [ConfigMap, Secret, PersistentVolume 관리](./textbook/Day1/README.md#configmap-secret-persistentvolume-관리)

#### 학습 내용
- Deployment, Service, Ingress 고급 설정
- ConfigMap, Secret, PersistentVolume 관리
- 실습: 마이크로서비스 아키텍처 구성

### 3. AWS ECS 및 Fargate 심화 (120분)

#### 핵심 문서
- [ECS 클러스터 구성 및 태스크 정의](./textbook/Day2/README.md#ecs-클러스터-구성-및-태스크-정의)
- [Fargate 서버리스 컨테이너 실행](./textbook/Day2/README.md#fargate-서버리스-컨테이너-실행)

#### 학습 내용
- ECS 클러스터 구성 및 태스크 정의
- Fargate 서버리스 컨테이너 실행
- 실습: ECS Fargate 서비스 배포

### 4. 고급 CI/CD 파이프라인 (90분)

#### 핵심 문서
- [GitOps 기반 배포 자동화](./textbook/Day2/README.md#gitops-기반-배포-자동화)

#### 학습 내용
- Multi-stage 배포 파이프라인
- 환경별 배포 전략 (Dev, Staging, Production)
- 실습: GitOps 기반 배포 자동화

### 📚 1일차 실습 자료

#### 실습 가이드
- [1일차 실습 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/README.md)
- [컨테이너 기본 실습](/mcp_knowledge_base/cloud_container/textbook/Day1/practice/container-basics.md)
- [Kubernetes 기본 실습](/mcp_knowledge_base/cloud_container/textbook/Day1/practice/kubernetes-basics.md)
- [종합 실습 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/comprehensive-practice-guide.md)
- [Master 연계 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/master-integration-guide.md)

#### 고급 가이드
- [Kubernetes 고급 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/kubernetes-advanced-guide.md)
- [컨테이너 오케스트레이션 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/container-orchestration-guide.md)
- [자동 복구 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/auto-recovery-guide.md)
- [비용 최적화 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/cost-optimization-guide.md)
- [보안 정책 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/security-policies-guide.md)

#### 고급 설정 파일
- [Docker Compose 설정](./textbook/Day1/docker-compose.yml)
- [컨테이너 데모 설정](./textbook/Day1/container-demo-setup.sh)
- [Helm 차트 템플릿](./textbook/Day1/helm-chart-templates/)
- [Istio 설정](./textbook/Day1/istio-config/)
- [Nginx 설정](./textbook/Day1/nginx/)
- [Prometheus 설정](./textbook/Day1/monitoring-advanced/)

#### 자동화 스크립트
- [AWS 설정 도우미](./textbook/Day1/scripts/aws-setup-helper.sh)
- [GCP 설정 도우미](./textbook/Day1/scripts/gcp-setup-helper.sh)
- [컨테이너 종합 배포](./textbook/Day1/scripts/container-comprehensive-deploy.sh)
- [고급 배포](./textbook/Day1/scripts/deploy-advanced.sh)

#### 고급 가이드
- [자동 복구 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/auto-recovery-guide.md)
- [비용 최적화 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/cost-optimization-guide.md)
- [보안 정책 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/security-policies-guide.md)

---

## 📅 2일차: 고가용성 및 확장성 아키텍처

### 1. 고가용성 아키텍처 설계 (120분)

#### 핵심 문서
- [고가용성 아키텍처 가이드](/mcp_knowledge_base/cloud_container/textbook/Day2/high-availability-architecture.md)
- [고가용성 아키텍처 실습](/mcp_knowledge_base/cloud_container/textbook/Day2/practice/high-availability-architecture.md)

#### 학습 내용
- AWS Multi-AZ / GCP Multi-Region
- 장애 복구 및 재해 복구 전략(DR)
- 실습: Multi-AZ RDS 및 EC2 구성, GCP Multi-Region 배포

### 2. 로드 밸런싱 및 Auto Scaling (90분)

#### 핵심 문서
- [고급 로드 밸런싱 실습](/mcp_knowledge_base/cloud_container/textbook/Day2/practice/advanced-load-balancing.md)

#### 학습 내용
- AWS ELB 심화 / GCP Cloud Load Balancing
- Auto Scaling 정책 및 메트릭 기반 확장
- 실습: Auto Scaling + Load Balancer 연동

### 3. 모니터링 및 로깅 시스템 (90분)

#### 핵심 문서
- [모니터링 설정 가이드](/mcp_knowledge_base/cloud_container/textbook/Day2/monitoring-setup.md)
- [모니터링 시스템 설정 실습](/mcp_knowledge_base/cloud_container/textbook/Day2/practice/monitoring-system-setup.md)

#### 학습 내용
- AWS CloudWatch / GCP Monitoring & Logging
- 경보 및 이벤트 기반 자동화
- 실습: 커스텀 메트릭 대시보드 및 로그 기반 알림 구축

### 4. 종합 프로젝트 및 최적화 (90분)

#### 핵심 문서
- [종합 프로젝트 실습](/mcp_knowledge_base/cloud_container/textbook/Day2/practice/comprehensive-project.md)

#### 학습 내용
- 고가용성 웹 서비스 아키텍처 설계
- 성능 최적화 및 비용 효율성 분석
- 실습: 실제 서비스 시나리오 아키텍처 구현 및 발표

### 📚 2일차 실습 자료

#### 실습 가이드
- [2일차 실습 가이드](/mcp_knowledge_base/cloud_container/textbook/Day2/README.md)
- [고가용성 아키텍처 실습](/mcp_knowledge_base/cloud_container/textbook/Day2/practice/high-availability-architecture.md)
- [고급 로드 밸런싱 실습](/mcp_knowledge_base/cloud_container/textbook/Day2/practice/advanced-load-balancing.md)
- [모니터링 시스템 설정 실습](/mcp_knowledge_base/cloud_container/textbook/Day2/practice/monitoring-system-setup.md)
- [종합 프로젝트 실습](/mcp_knowledge_base/cloud_container/textbook/Day2/practice/comprehensive-project.md)

#### 고급 가이드
- [고가용성 아키텍처 가이드](/mcp_knowledge_base/cloud_container/textbook/Day2/high-availability-architecture.md)
- [모니터링 설정 가이드](/mcp_knowledge_base/cloud_container/textbook/Day2/monitoring-setup.md)

#### 자동화 스크립트
- [AWS 설정 도우미](./textbook/Day2/scripts/aws-setup-helper.sh)
- [GCP 설정 도우미](./textbook/Day2/scripts/gcp-setup-helper.sh)

#### 문제 해결
- [Multi-AZ 문제 해결](/mcp_knowledge_base/cloud_container/textbook/Day2/troubleshooting/multi-az-issues.md)

---

## 🛠️ 설치 및 도구 가이드

### 필수 도구 설치
- [AWS CLI 설치](/mcp_knowledge_base/cloud_container/install/install_aws_cli.md)
- [Azure CLI 설치](/mcp_knowledge_base/cloud_container/install/install_azure_cli.md)
- [GCP CLI 설치](/mcp_knowledge_base/cloud_container/install/install_glcoud_cli.md)
- [Docker 설치](/mcp_knowledge_base/cloud_container/install/install_docker.md)
- [Docker Compose 설치](/mcp_knowledge_base/cloud_container/install/install_docker_compose.md)
- [Git 설치](/mcp_knowledge_base/cloud_container/install/install_git.md)
- [GitHub Actions 완전 가이드](/mcp_knowledge_base/cloud_container/install/github-actions-complete-guide.md)
- [Helm 설치](./install/get_helm.sh)

### 클라우드별 설치 스크립트
- [AWS Docker Compose 설치](./install/install_docker_compose_aws.sh)
- [Azure Docker Compose 설치](./install/install_docker_compose_azure.sh)
- [GCP Docker Compose 설치](./install/install_docker_compose_gcp.sh)
- [AWS Git 설치](./install/install_git_aws.sh)
- [Azure Git 설치](./install/install_git_azure.sh)
- [GCP Git 설치](./install/install_git_gcp.sh)

### 컨테이너 과정 특화 도구
- [GitHub Actions 가이드](/mcp_knowledge_base/cloud_container/github-actions.md)

---

## 🤖 자동화 및 테스트

### 자동화 가이드
- [자동화 README](/mcp_knowledge_base/cloud_container/automation/README.md)
- [자동화 테스트 README](/mcp_knowledge_base/cloud_container/automation_tests/README.md)

### 자동화 스크립트
- [1일차 자동화 스크립트](./automation/day1/)
- [2일차 자동화 스크립트](./automation/day2/)
- [자동화 결과](./automation/results/)

### 자동화 테스트
- [컨테이너 과정 자동화](./automation_tests/container_course_automation.py)
- [2일차 스크립트 자동화](./automation_tests/container_course_day2_scripts.py)
- [자동화 테스트 실행](./automation_tests/run_container_course_tests.py)
- [자동화 테스트 검증](./automation_tests/test_container_course_automation.py)
- [사용자 가이드](/mcp_knowledge_base/cloud_container/automation_tests/USER_GUIDE.md)

### 도구 설치 스크립트
- [Helm 설치](./automation_tests/get_helm.sh)
- [도구 설치 (Windows)](./automation_tests/install_tools_simple.ps1)
- [도구 설치 (Linux/Mac)](./automation_tests/install_tools.sh)

---

## 🎯 학습 체크리스트

### Cloud Container 필수 체크리스트
- [ ] Kubernetes 클러스터 아키텍처 이해
- [ ] GKE 클러스터 생성 및 관리
- [ ] Deployment, Service, Ingress 설정
- [ ] ConfigMap, Secret, PersistentVolume 관리
- [ ] ECS 클러스터 구성 및 태스크 정의
- [ ] Fargate 서버리스 컨테이너 실행
- [ ] GitOps 기반 배포 자동화
- [ ] 고가용성 아키텍처 설계
- [ ] 로드 밸런싱 및 Auto Scaling
- [ ] 모니터링 및 로깅 시스템 구축

### 실습 완료 확인
- [ ] GKE 클러스터 생성 및 애플리케이션 배포
- [ ] 마이크로서비스 아키텍처 구성
- [ ] ECS Fargate 서비스 배포
- [ ] GitOps 기반 배포 자동화
- [ ] Multi-AZ RDS 및 EC2 구성
- [ ] GCP Multi-Region 배포
- [ ] Auto Scaling + Load Balancer 연동
- [ ] 커스텀 메트릭 대시보드 구축
- [ ] 로그 기반 알림 구축
- [ ] 실제 서비스 시나리오 아키텍처 구현

---

## 🚀 다음 단계

### 실무 적용
- [통합 자동화 시스템](/mcp_knowledge_base/integrated_automation/README.md)
- [전체 커리큘럼](/mcp_knowledge_base/curriculum.md)
- [통합 인덱스](/mcp_knowledge_base/index.md)

### 고급 학습
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [AWS ECS 공식 문서](https://docs.aws.amazon.com/ecs/)
- [GKE 공식 문서](https://cloud.google.com/kubernetes-engine/docs)

---

## 💡 추가 학습 자료

### 공식 문서
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [AWS ECS 공식 문서](https://docs.aws.amazon.com/ecs/)
- [AWS Fargate 공식 문서](https://docs.aws.amazon.com/fargate/)
- [GKE 공식 문서](https://cloud.google.com/kubernetes-engine/docs)
- [Docker 공식 문서](https://docs.docker.com/)
- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)

### 유용한 리소스
- [Kubernetes 샘플 프로젝트](https://github.com/kubernetes/examples)
- [Docker 샘플 프로젝트](https://github.com/docker/awesome-compose)
- [AWS 샘플 프로젝트](https://github.com/aws-samples)
- [GCP 샘플 프로젝트](https://github.com/GoogleCloudPlatform)

### 도구 및 유틸리티
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)

---

## 🆘 문제 해결

### 자주 발생하는 문제
1. **Kubernetes 클러스터 생성 실패**: GCP 프로젝트 권한 및 할당량 확인
2. **ECS 태스크 실행 실패**: 태스크 정의 및 IAM 역할 확인
3. **Fargate 서비스 배포 실패**: 서브넷 및 보안 그룹 설정 확인
4. **모니터링 설정 실패**: IAM 권한 및 메트릭 네임스페이스 확인

### 지원 및 문의
- **이메일 문의**: cloud-training@example.com
- **슬랙 채널**: #cloud-container-support
- **오피스 아워**: 매주 화요일, 목요일 14:00-16:00

---

[← 이전: [과정명] [일차] 메인](/mcp_knowledge_base/cloud_container/README.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🏠 학습 경로로 돌아가기](/mcp_knowledge_base/index.md)

</div>

#### 계정 관련 문서
- [AWS계정가입](/mcp_knowledge_base/cloud_container/accounts/AWS계정가입.md)
- [Azure계정가입](/mcp_knowledge_base/cloud_container/accounts/Azure계정가입.md)
- [GCP_개인계정가입](/mcp_knowledge_base/cloud_container/accounts/GCP_개인계정가입.md)
- [GCP_계정유형비교](/mcp_knowledge_base/cloud_container/accounts/GCP_계정유형비교.md)
- [GCP_조직계정가입](/mcp_knowledge_base/cloud_container/accounts/GCP_조직계정가입.md)
- [클라우드계정관리비교](/mcp_knowledge_base/cloud_container/accounts/클라우드계정관리비교.md)
