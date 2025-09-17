
## 🛤️ 학습 순서

이 과정은 다음과 같은 순서로 진행됩니다:

### 1단계: 환경 준비 (1시간)
- Docker 설치 및 기본 설정
- Git/GitHub 계정 설정
- GitHub Actions 활성화
- 클라우드 계정 권한 설정

### 2단계: Day1 - 개발 도구 마스터 (6시간)
- Docker 기초 및 고급 활용
- Git/GitHub 협업 워크플로우
- GitHub Actions CI/CD 파이프라인
- 클라우드 배포 전략

### 3단계: Day2 - 운영 최적화 (5시간)
- 비용 최적화 전략 및 실습
- 모니터링 시스템 구축
- 종합 실습 프로젝트
- 운영 모범 사례 학습

### 4단계: Day3 - 고급 아키텍처 (6시간)
- 자동 스케일링 시스템 구축
- 고급 로드 밸런싱
- 재해 복구 전략 수립
- 통합 시스템 구축

**💡 팁**: 각 Day의 내용을 순차적으로 학습하시면 체계적인 이해가 가능합니다!

<div align="center">

## 🏠 최상위 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

## 📖 현재 위치
**Cloud Master** > **1일차** > **Cloud Master - 마스터 과정 학습 경로**

## ⬅️ 이전/다음 네비게이션
[← 이전: Cloud Master 메인](/mcp_knowledge_base/cloud_master/README.md) | [다음: Cloud Master 1일차 →](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md)

</div>

# Cloud Master - 마스터 과정 학습 경로

> 📋 **전체 개요**: [README.md](/mcp_knowledge_base/cloud_master/README.md) | [통합 커리큘럼](/mcp_knowledge_base/curriculum.md) | [통합 인덱스](/mcp_knowledge_base/index.md)에서 전체 과정 구조를 확인하세요.

<div align="center">
</div>

---

## 🎯 학습 목표

이 문서는 **Cloud Master 과정**의 모든 문서를 **누락 없이** 체계적으로 정리한 완전한 학습 경로입니다. Docker 컨테이너화부터 CI/CD 파이프라인, VM 기반 배포 자동화까지 실무 중심의 고급 기술을 단계별로 학습할 수 있도록 구성되어 있습니다.

## 📚 과정 개요

### Cloud Master - 마스터 과정 (3일)
- **교육명**: 클라우드 실무력 강화! AWS & GCP 활용법(마스터)
- **교육일정**: 9/22(월) ~ 9/24(수)
- **교육시간**: 9:00 ~ 17:00 (7시간/일)
- **교육방식**: 온라인
- **실습 환경**: AWS Free Tier + GCP Free Tier ($300 크레딧) + GitHub Free

### 과정 상세 정보
- [과정명 상세](/mcp_knowledge_base/cloud_master/과정명.md)
- [과정 상세 정보](/mcp_knowledge_base/cloud_master/과정상세.md)

### 학습 목표
- Docker 및 GitHub Actions 기반 **완전 자동화된 배포 파이프라인** 구축
- AWS/GCP 환경에서 **컨테이너 서비스(ECS, GKE)** 운영
- **고가용성 및 Auto Scaling 아키텍처** 설계와 장애 복구 시뮬레이션
- 클라우드 비용 분석 도구(AWS Cost Explorer, GCP Billing Reports) 활용
- **팀 프로젝트 수행**을 통한 실전 아키텍처 설계 및 비용 최적화 전략 수립

---

## 📅 1일차: Docker, Git/GitHub, GitHub Actions 이론 및 실습

### 📚 이론 학습 (120분)

#### 1. Docker 기초 및 컨테이너 기술 이론 (60분)

**📖 이론 학습 자료**
- [Docker 고급 가이드](/mcp_knowledge_base/cloud_master/textbook/Day1/docker-advanced-guide.md)
- [Docker Compose 가이드](/mcp_knowledge_base/cloud_master/textbook/Day1/docker-compose-guide.md)
- [Docker Hub 설정 가이드](/mcp_knowledge_base/cloud_master/textbook/Day1/docker-hub-setup-guide.md)

**🎯 이론 학습 내용**
- Docker 개념 및 아키텍처 이해
- 컨테이너 vs 가상머신 비교
- Dockerfile 작성 원칙 및 모범 사례
- Docker Compose를 활용한 다중 서비스 관리
- 컨테이너 레지스트리 및 이미지 관리

#### 2. Git/GitHub 기초 및 협업 이론 (30분)

**📖 이론 학습 자료**
- [Git GitHub 기본 실습](/mcp_knowledge_base/cloud_master/textbook/Day1/practice/git-github-basics.md)

**🎯 이론 학습 내용**
- Git 기본 명령어 및 워크플로우
- GitHub 저장소 생성 및 관리
- 브랜치 전략 및 Pull Request 활용
- 협업 워크플로우 및 코드 리뷰

#### 3. GitHub Actions CI/CD 파이프라인 이론 (30분)

**📖 이론 학습 자료**
- [GitHub Actions 가이드](/mcp_knowledge_base/cloud_master/textbook/Day1/github-actions-guide.md)
- [CI/CD 파이프라인 가이드](/mcp_knowledge_base/cloud_master/textbook/Day1/cicd-pipeline-guide.md)

**🎯 이론 학습 내용**
- GitHub Actions 개념 및 워크플로우 구조
- 자동화된 테스트, 빌드, 배포 파이프라인
- Docker 이미지 자동 빌드 및 레지스트리 푸시
- CI/CD 모범 사례 및 보안 고려사항

### 🛠️ 실습 학습 (300분)

#### 1. Docker 기초 및 컨테이너 기술 실습 (120분)

**🔧 실습 가이드**
- [Docker 기본 실습](/mcp_knowledge_base/cloud_master/textbook/Day1/practice/docker-basics.md)
- [1일차 실습 가이드](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day1\README.md#docker-기초-및-컨테이너-기술)

**🎯 실습 내용**
- Node.js 웹 애플리케이션 컨테이너화
- Dockerfile 작성 및 이미지 빌드
- Docker Compose를 활용한 다중 서비스 구성
- 컨테이너 로그 및 모니터링

#### 2. Git/GitHub 기초 및 협업 실습 (90분)

**🔧 실습 가이드**
- [1일차 실습 가이드](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day1\README.md#git-github-버전-관리)

**🎯 실습 내용**
- GitHub 저장소 생성 및 초기 설정
- 브랜치 생성 및 관리
- Pull Request 생성 및 코드 리뷰
- 팀 프로젝트 기반 Git 협업

#### 3. GitHub Actions CI/CD 파이프라인 실습 (90분)

**🔧 실습 가이드**
- [GitHub Actions 기본 실습](/mcp_knowledge_base/cloud_master/textbook/Day1/practice/github-actions-basics.md)
- [Actions 데모](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day1\actions-demo)

**🎯 실습 내용**
- GitHub Actions 워크플로우 작성
- 자동화된 테스트 및 빌드 파이프라인 구축
- Docker 이미지 자동 빌드 및 푸시
- 배포 자동화 및 환경별 설정

### 🚀 VM 기반 웹 애플리케이션 배포 이론 및 실습 (90분)

#### 📚 이론 학습 (30분)

**📖 이론 학습 자료**
- [클라우드 배포 가이드](/mcp_knowledge_base/cloud_master/textbook/Day1/cloud-deployment-guide.md)
- [AWS GCP 배포 가이드](/mcp_knowledge_base/cloud_master/textbook/Day1/aws-gcp-deployment-guide.md)
- [AWS GCP 권한 설정](/mcp_knowledge_base/cloud_master/textbook/Day1/aws-gcp-permissions-setup.md)

**🎯 이론 학습 내용**
- AWS EC2 + Docker / GCP Compute Engine + Docker
- 웹 애플리케이션 배포 및 도메인 연결
- 기본 모니터링 및 로그 관리
- 실습: 완전 자동화된 VM 배포 파이프라인

### 📚 1일차 실습 자료

#### 실습 가이드
- [1일차 실습 가이드](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md)
- [Docker 기본 실습](/mcp_knowledge_base/cloud_master/textbook/Day1/practice/docker-basics.md)
- [Git/GitHub 기본 실습](/mcp_knowledge_base/cloud_master/textbook/Day1/practice/git-github-basics.md)
- [GitHub Actions 기본 실습](/mcp_knowledge_base/cloud_master/textbook/Day1/practice/github-actions-basics.md)
- [VM 배포 실습](/mcp_knowledge_base/cloud_master/textbook/Day1/practice/vm-deployment.md)
- [My App 샘플](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day1\my-app)

#### 자동화 스크립트
- [AWS EC2 생성](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day1\scripts\aws-ec2-create.sh)
- [AWS 리소스 정리](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day1\scripts\aws-resource-cleanup.sh)
- [AWS 설정 도우미](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day1\scripts\aws-setup-helper.sh)
- [GCP Compute 생성](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day1\scripts\gcp-compute-create.sh)
- [GCP 프로젝트 정리](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day1\scripts\gcp-project-cleanup.sh)
- [GCP 설정 도우미](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day1\scripts\gcp-setup-helper.sh)
- [프로젝트 설정](/mcp_knowledge_base/cloud_master/textbook/Day1/scripts/PROJECT_SETUP.md)

#### 문제 해결
- [문제 해결 가이드](/mcp_knowledge_base/cloud_master/textbook/Day1/troubleshooting-guide.md)

---

## 📅 2일차: 고급 CI/CD 및 VM 기반 컨테이너 배포

### 1. Docker 고급 기법 및 최적화 (90분)

#### 핵심 문서
- [Docker 고급 기술 및 최적화](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day2\README.md#docker-고급-기술-및-최적화)
- [멀티스테이지 빌드 및 Docker Compose](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day2\README.md#멀티스테이지-빌드-및-docker-compose)

#### 학습 내용
- Dockerfile 멀티스테이지 빌드 및 최적화
- Docker Compose 고급 설정 및 오케스트레이션
- 실습: 프로덕션급 Docker 이미지 빌드 및 최적화

### 2. GitHub Actions 고급 워크플로우 (90분)

#### 핵심 문서
- [GitHub Actions 고급 워크플로우](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day2\README.md#github-actions-고급-워크플로우)
- [환경별 배포 전략](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day2\README.md#환경별-배포-전략)

#### 학습 내용
- 매트릭스 빌드 및 환경별 배포 전략
- 시크릿 관리 및 보안 설정
- 실습: 고급 CI/CD 파이프라인 구축

### 3. VM 기반 컨테이너 배포 자동화 (90분)

#### 핵심 문서
- [VM 기반 컨테이너 배포 자동화](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day3\README.md#vm-기반-컨테이너-배포-자동화)

#### 학습 내용
- AWS EC2 + Docker / GCP Compute Engine + Docker
- 컨테이너 오케스트레이션 및 관리
- 실습: 고가용성 컨테이너 배포 환경 구성

### 4. 완전 자동화된 배포 파이프라인 (90분)

#### 핵심 문서
- [완전 자동화된 배포 파이프라인](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day2\README.md#완전-자동화된-배포-파이프라인)

#### 학습 내용
- GitHub Actions + VM 배포 자동화
- 실습: GitHub 푸시 → Docker 빌드 → VM 배포 자동화

### 📚 2일차 실습 자료

#### 실습 가이드
- [2일차 실습 가이드](/mcp_knowledge_base/cloud_master/textbook/Day2/README.md)
- [종합 실습 가이드](/mcp_knowledge_base/cloud_master/textbook/Day2/comprehensive-practice-guide.md)
- [비용 최적화 가이드](/mcp_knowledge_base/cloud_master/textbook/Day2/cost-optimization-guide.md)
- [비용 구조 가이드](/mcp_knowledge_base/cloud_master/textbook/Day2/cost-structure-guide.md)
- [모니터링 가이드](/mcp_knowledge_base/cloud_master/textbook/Day2/monitoring-guide.md)

#### 문제 해결
- [문제 해결 가이드](/mcp_knowledge_base/cloud_master/textbook/Day2/troubleshooting-guide.md)

---

## 📅 3일차: 로드 밸런싱, 모니터링, 비용 최적화

### 1. 로드 밸런싱 및 Auto Scaling (90분)

#### 핵심 문서
- [로드 밸런싱 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/load-balancing-guide.md)
- [Auto Scaling 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/auto-scaling-guide.md)
- [로드 밸런싱 및 Auto Scaling](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day3\README.md#로드-밸런싱-및-auto-scaling)

#### 학습 내용
- AWS ELB + Auto Scaling Group / GCP Cloud LB + Managed Instance Group
- 실습: VM 기반 로드 밸런싱 환경 구성

### 2. 모니터링 및 로깅 시스템 (90분)

#### 핵심 문서
- [모니터링 및 로깅 시스템](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day3\README.md#모니터링-및-로깅-시스템)

#### 학습 내용
- CloudWatch, Cloud Monitoring 설정
- Prometheus + Grafana 모니터링 구축
- 실습: 종합 모니터링 대시보드 구축

### 3. 장애 복구 및 운영 자동화 (90분)

#### 핵심 문서
- [재해 복구 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/disaster-recovery-guide.md)
- [통합 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/integration-guide.md)
- [장애 복구 및 운영 자동화](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day3\README.md#장애-복구-및-운영-자동화)

#### 학습 내용
- Health Check 기반 자동 교체 및 복구
- 실습: 장애 시뮬레이션 및 자동 복구 테스트

### 4. 비용 최적화 및 운영 전략 (90분)

#### 핵심 문서
- [비용 최적화 및 운영 전략](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day3\README.md#비용-최적화-및-운영-전략)

#### 학습 내용
- 클라우드 비용 구조 및 과금 체계 분석
- VM 기반 아키텍처 비용 분석 및 최적화
- 실습: 비용 최적화 전략 수립 및 발표

### 📚 3일차 실습 자료

#### 실습 가이드
- [3일차 실습 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/README.md)
- [로드 밸런싱 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/load-balancing-guide.md)
- [Auto Scaling 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/auto-scaling-guide.md)
- [재해 복구 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/disaster-recovery-guide.md)
- [통합 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/integration-guide.md)
- [My App 샘플](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day3\my-app)
- [Actions 데모](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day3\actions-demo)

#### 자동화 스크립트
- [AWS EC2 생성](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day3\scripts\aws-ec2-create.sh)
- [AWS 리소스 정리](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day3\scripts\aws-resource-cleanup.sh)
- [AWS 설정 도우미](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day3\scripts\aws-setup-helper.sh)
- [GCP Compute 생성](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day3\scripts\gcp-compute-create.sh)
- [GCP 프로젝트 정리](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day3\scripts\gcp-project-cleanup.sh)
- [GCP 설정 도우미](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\textbook\Day3\scripts\gcp-setup-helper.sh)
- [프로젝트 설정](/mcp_knowledge_base/cloud_master/textbook/Day3/scripts/PROJECT_SETUP.md)

#### 문제 해결
- [문제 해결 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/troubleshooting-guide.md)

---

## 🛠️ 설치 및 도구 가이드

### 필수 도구 설치
- [AWS CLI 설치](/mcp_knowledge_base/cloud_master/install/install_aws_cli.md)
- [Azure CLI 설치](/mcp_knowledge_base/cloud_master/install/install_azure_cli.md)
- [GCP CLI 설치](/mcp_knowledge_base/cloud_master/install/install_glcoud_cli.md)
- [Docker 설치](/mcp_knowledge_base/cloud_master/install/install_docker.md)
- [Docker Compose 설치](/mcp_knowledge_base/cloud_master/install/install_docker_compose.md)
- [Git 설치](/mcp_knowledge_base/cloud_master/install/install_git.md)
- [GitHub Actions 완전 가이드](/mcp_knowledge_base/cloud_master/install/github-actions-complete-guide.md)

### 클라우드별 설치 스크립트
- [AWS Docker Compose 설치](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\install\install_docker_compose_aws.sh)
- [Azure Docker Compose 설치](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\install\install_docker_compose_azure.sh)
- [GCP Docker Compose 설치](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\install\install_docker_compose_gcp.sh)
- [AWS Git 설치](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\install\install_git_aws.sh)
- [Azure Git 설치](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\install\install_git_azure.sh)
- [GCP Git 설치](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\install\install_git_gcp.sh)

---

## 🤖 자동화 및 테스트

### 자동화 스크립트
- [1일차 자동화 스크립트](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\automation\day1)
- [2일차 자동화 스크립트](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\automation\day2)
- [3일차 자동화 스크립트](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\automation\day3)
- [자동화 결과](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\automation\results)

### 자동화 테스트
- [마스터 과정 자동화](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\automation_tests\master_course_automation.py)
- [2일차 스크립트 자동화](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\automation_tests\master_course_day2_scripts.py)
- [3일차 스크립트 자동화](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\automation_tests\master_course_day3_scripts.py)
- [자동화 테스트 실행](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\automation_tests\run_master_course_tests.py)
- [자동화 테스트 검증](/mcp_knowledge_base/mcp_knowledge_base\cloud_master\automation_tests\test_master_course_automation.py)
- [사용자 가이드](/mcp_knowledge_base/cloud_master/automation_tests/USER_GUIDE.md)

---

## 🎯 학습 체크리스트

### Cloud Master 필수 체크리스트
- [ ] Docker 컨테이너 기본 사용법
- [ ] Dockerfile 작성 및 이미지 빌드
- [ ] Git/GitHub 버전 관리
- [ ] GitHub Actions CI/CD 파이프라인
- [ ] VM 기반 웹 애플리케이션 배포
- [ ] Docker 고급 기술 및 최적화
- [ ] 멀티스테이지 빌드 및 Docker Compose
- [ ] GitHub Actions 고급 워크플로우
- [ ] 환경별 배포 전략
- [ ] VM 기반 컨테이너 배포 자동화
- [ ] 로드 밸런싱 및 Auto Scaling
- [ ] 모니터링 및 로깅 시스템

### 실습 완료 확인
- [ ] Node.js 웹 애플리케이션 컨테이너화
- [ ] Docker Compose를 활용한 다중 서비스 관리
- [ ] GitHub Actions로 CI/CD 파이프라인 구축
- [ ] AWS EC2 + Docker 배포
- [ ] GCP Compute Engine + Docker 배포
- [ ] Dockerfile 멀티스테이지 빌드 및 최적화
- [ ] 매트릭스 빌드 및 환경별 배포 전략
- [ ] 고가용성 컨테이너 배포 환경 구성
- [ ] 완전 자동화된 VM 배포 파이프라인
- [ ] 로드 밸런싱 환경 구성
- [ ] Prometheus + Grafana 모니터링 구축
- [ ] 장애 시뮬레이션 및 자동 복구 테스트
- [ ] 비용 최적화 전략 수립

---

## 🚀 다음 단계

### Cloud Container 과정 준비
- [Cloud Container 과정 상세](/mcp_knowledge_base/cloud_container/과정상세.md)
- [Cloud Container 1일차 실습 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/README.md)
- [Master to Container 연계 가이드](/mcp_knowledge_base/integrated_automation/bridge_scripts/master_to_container_bridge.sh)

### 통합 학습 경로
- [전체 커리큘럼](/mcp_knowledge_base/curriculum.md)
- [통합 인덱스](/mcp_knowledge_base/index.md)
- [통합 자동화 시스템](/mcp_knowledge_base/integrated_automation/README.md)

---

## 💡 추가 학습 자료

### 공식 문서
- [Docker 공식 문서](https://docs.docker.com/)
- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [AWS 공식 문서](https://docs.aws.amazon.com/)
- [GCP 공식 문서](https://cloud.google.com/docs)

### 유용한 리소스
- [Docker Hub](https://hub.docker.com/)
- [GitHub Marketplace](https://github.com/marketplace?type=actions)
- [AWS Free Tier](https://aws.amazon.com/free/)
- [GCP Free Tier](https://cloud.google.com/free)

---

## 🆘 문제 해결

### 자주 발생하는 문제
1. **Docker 이미지 빌드 실패**: Dockerfile 문법 및 의존성 확인
2. **GitHub Actions 워크플로우 실패**: 시크릿 설정 및 권한 확인
3. **VM 배포 실패**: 보안 그룹 및 네트워크 설정 확인
4. **CI/CD 파이프라인 오류**: 워크플로우 파일 문법 및 단계별 실행 확인

### 지원 및 ### 📧 연락처
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: [프로젝트 저장소](https://github.com/jungfrau70/aws_gcp.git)
#### 계정 관련 문서
- [AWS계정가입](/mcp_knowledge_base/cloud_master/accounts/AWS계정가입.md)
- [Azure계정가입](/mcp_knowledge_base/cloud_master/accounts/Azure계정가입.md)
- [GCP_개인계정가입](/mcp_knowledge_base/cloud_master/accounts/GCP_개인계정가입.md)
- [GCP_계정유형비교](/mcp_knowledge_base/cloud_master/accounts/GCP_계정유형비교.md)
- [GCP_조직계정가입](/mcp_knowledge_base/cloud_master/accounts/GCP_조직계정가입.md)
- [클라우드계정관리비교](/mcp_knowledge_base/cloud_master/accounts/클라우드계정관리비교.md)


---

<div align="center">

## 🔗 관련 과정 및 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

## 📖 현재 위치
**Cloud Master** > **1일차** > **Cloud Master - 마스터 과정 학습 경로**

## ⬅️ 이전/다음 네비게이션
[← 이전: Cloud Master 메인](/mcp_knowledge_base/cloud_master/README.md) | [다음: Cloud Master 1일차 →](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md)

## 🔗 관련 과정
[Cloud Basic 2일차](/mcp_knowledge_base/cloud_basic/textbook/Day2/README.md) | [Cloud Container 1일차](/mcp_knowledge_base/cloud_container/textbook/Day1/README.md)

</div>