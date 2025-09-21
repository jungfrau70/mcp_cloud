# Cloud Master - 학습 경로

## 📚 과정 개요

**Cloud Master**는 AWS와 GCP를 활용한 클라우드 마스터 과정입니다. Docker, CI/CD, 모니터링, 비용 최적화까지 클라우드 운영의 전 과정을 실습으로 학습합니다.

> 📌 **상세 정보**: [과정상세.md](과정상세.md)에서 전체 과정 개요, 학습 목표, 커리큘럼을 확인하세요.

## 🎯 학습 목표

- **Docker 컨테이너화**: 애플리케이션 컨테이너화 및 최적화
- **고급 CI/CD**: GitHub Actions를 활용한 자동화 파이프라인 구축
- **클라우드 모니터링**: Prometheus, Grafana를 활용한 모니터링 시스템 구축
- **비용 최적화**: 클라우드 리소스 최적화 및 비용 절감 전략

## 🛤️ 체계적 학습 순서

### 1단계: 환경 설정
- [AWS Free Tier 계정](https://aws.amazon.com/free/) 생성
- [GCP Free Tier 계정](https://cloud.google.com/free) 생성
- [WSL 설치 및 설정](cloud_master/repos/cloud-scripts/wsl-install.md)
- [필수 도구 설치](cloud_master/repos/install/install-all-wsl.sh)
- [AWS 계정 가입](cloud_master/accounts/AWS계정가입.md)
- [GCP 계정 가입](cloud_master/accounts/GCP_개인계정가입.md)

### 1.5단계: 전문 분야별 가이드
- [인프라 관리 가이드](infra-guide.md) - WSL 환경 설정, 클라우드 계정 구성, VM 배포, Kubernetes 클러스터 구축
- [CI/CD 파이프라인 가이드](cicd-guide.md) - GitHub Actions, Docker, 자동 배포, 모니터링 시스템
- [전체 실습 가이드](execuise-guide.md) - 전체 과정 개요, 학습 자료 구조, 실습 진행 방법

### 2단계: Day별 학습

<details>
<summary>📅 Day 1: Docker & Git/GitHub & GitHub Actions & VM 배포</summary>

#### 🎯 학습 목표
- Docker 컨테이너화 기초
- Git/GitHub 협업 워크플로우
- GitHub Actions CI/CD 파이프라인
- VM 기반 애플리케이션 배포

#### 📖 이론 학습
- [Docker 기초 개념](cloud_master/textbook/Day1/README.md#docker-기초)
- [Git/GitHub 워크플로우](cloud_master/textbook/Day1/README.md#gitgithub-기초)
- [GitHub Actions 개념](cloud_master/textbook/Day1/README.md#github-actions-기초)
- [VM 배포 전략](cloud_master/textbook/Day1/README.md#vm-배포)

#### 🛠️ 실습 가이드
- [Docker 실습](cloud_master/textbook/Day1/README.md#docker-기초-실습)
- [Git/GitHub 실습](cloud_master/textbook/Day1/README.md#gitgithub-협업-실습)
- [GitHub Actions 실습](cloud_master/textbook/Day1/README.md#github-actions-cicd-실습)
- [VM 배포 실습](cloud_master/textbook/Day1/README.md#vm-배포-자동화-실습)

#### 💻 실습 코드
- [Docker 샘플 코드](cloud_master/repos/samples/day1/docker/)
- [GitHub Actions 워크플로우](cloud_master/repos/samples/day1/github-actions/)
- [VM 배포 스크립트](cloud_master/repos/cloud-scripts/day1/)

#### 🔧 자동화 도구
- [Docker 실습 자동화](cloud_master/repos/automation/day1/docker-practice-automation.sh)
- [GitHub Actions 실습 자동화](cloud_master/repos/automation/day1/github-actions-practice-automation.sh)
- [VM 배포 자동화](cloud_master/repos/automation/day1/vm-deployment-automation.sh)

</details>

<details>
<summary>📅 Day 2: 고급 CI/CD & VM 기반 컨테이너 배포</summary>

#### 🎯 학습 목표
- 고급 Docker 기술 (멀티스테이지 빌드, 최적화)
- 고급 GitHub Actions (매트릭스 빌드, 환경별 배포)
- Kubernetes 기초
- 자동화된 컨테이너 배포

#### 📖 이론 학습
- [고급 Docker 기술](cloud_master/textbook/Day2/README.md#고급-docker)
- [고급 GitHub Actions](cloud_master/textbook/Day2/README.md#고급-github-actions)
- [Kubernetes 기초](cloud_master/textbook/Day2/README.md#kubernetes-기초)
- [자동화된 배포](cloud_master/textbook/Day2/README.md#자동화된-배포)

#### 🛠️ 실습 가이드
- [고급 Docker 실습](cloud_master/textbook/Day2/README.md#고급-docker-실습)
- [고급 GitHub Actions 실습](cloud_master/textbook/Day2/README.md#고급-github-actions-실습)
- [Kubernetes 실습](cloud_master/textbook/Day2/README.md#kubernetes-실습)
- [자동화된 배포 실습](cloud_master/textbook/Day2/README.md#자동화된-배포-실습)

#### 💻 실습 코드
- [고급 Docker 샘플](cloud_master/repos/samples/day2/advanced-docker/)
- [고급 GitHub Actions 워크플로우](cloud_master/repos/samples/day2/advanced-github-actions/)
- [Kubernetes 매니페스트](cloud_master/repos/samples/day2/kubernetes/)

#### 🔧 자동화 도구
- [고급 Docker 실습 자동화](cloud_master/repos/automation/day2/advanced-docker-practice-automation.sh)
- [고급 GitHub Actions 실습 자동화](cloud_master/repos/automation/day2/advanced-github-actions-practice-automation.sh)
- [Kubernetes 실습 자동화](cloud_master/repos/automation/day2/kubernetes-practice-automation.sh)

</details>

<details>
<summary>📅 Day 3: 로드밸런싱 & 모니터링 & 비용 최적화</summary>

#### 🎯 학습 목표
- 로드밸런싱 및 오토스케일링
- 클라우드 모니터링 시스템 구축
- 비용 최적화 전략
- 재해 복구 계획

#### 📖 이론 학습
- [로드밸런싱](cloud_master/textbook/Day3/README.md#로드밸런싱)
- [오토스케일링](cloud_master/textbook/Day3/README.md#오토스케일링)
- [모니터링](cloud_master/textbook/Day3/README.md#모니터링)
- [비용 최적화](cloud_master/textbook/Day3/README.md#비용-최적화)

#### 🛠️ 실습 가이드
- [로드밸런싱 실습](cloud_master/textbook/Day3/README.md#로드-밸런싱-실습)
- [오토스케일링 실습](cloud_master/textbook/Day3/README.md#오토스케일링-실습)
- [모니터링 실습](cloud_master/textbook/Day3/README.md#모니터링-실습)
- [비용 최적화 실습](cloud_master/textbook/Day3/README.md#비용-최적화-실습)

#### 💻 실습 코드
- [로드밸런싱 설정](cloud_master/repos/samples/day3/load-balancing/)
- [모니터링 설정](cloud_master/repos/samples/day3/monitoring/)
- [비용 최적화 스크립트](cloud_master/repos/samples/day3/cost-optimization/)

#### 🔧 자동화 도구
- [로드밸런싱 실습 자동화](cloud_master/repos/automation/day3/load-balancing-practice-automation.sh)
- [모니터링 실습 자동화](cloud_master/repos/automation/day3/monitoring-practice-automation.sh)
- [비용 최적화 실습 자동화](cloud_master/repos/automation/day3/cost-optimization-practice-automation.sh)

</details>

## 📚 학습 자료 구조

### 📖 교재 (textbook/)
- **README.md**: 각 Day별 메인 교재
- **practices/**: 상세 실습 가이드
- **guides/**: 설치 및 설정 가이드

### 💻 실습 코드 (repos/)
- **samples/**: 실습용 샘플 코드
- **automation/**: 실습 자동화 스크립트
- **cloud-scripts/**: 클라우드 리소스 관리 도구

## ✅ 학습 체크리스트

### 사전 준비
- [ ] AWS Free Tier 계정 생성
- [ ] GCP Free Tier 계정 생성
- [ ] Docker 설치 및 설정
- [ ] Git 설치 및 GitHub 계정 연동
- [ ] AWS CLI 설치 및 설정
- [ ] GCP CLI 설치 및 설정

### Day별 학습 완료
- [ ] **Day 1**: Docker & Git/GitHub & GitHub Actions & VM 배포
- [ ] **Day 2**: 고급 CI/CD & VM 기반 컨테이너 배포
- [ ] **Day 3**: 로드밸런싱 & 모니터링 & 비용 최적화

### 최종 평가
- [ ] **실습 완료율**: 80% 이상
- [ ] **최종 프로젝트**: 개인별 클라우드 인프라 구축
- [ ] **평가**: 실습 결과물 및 최종 프로젝트 평가

## 🚀 다음 단계

### Cloud Container 과정 준비
- [Cloud Container 과정 상세](cloud_master/cloud_container/과정상세.md)
- [Cloud Container 1일차 실습 가이드](cloud_master/cloud_container/README.md)

### 통합 학습 경로
- [전체 커리큘럼](cloud_master/curriculum.md)
- [통합 인덱스](cloud_master/index.md)

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

## 💡 문제 해결

### 자주 발생하는 문제
1. **Docker 이미지 빌드 실패**: Dockerfile 문법 및 의존성 확인
2. **GitHub Actions 워크플로우 실패**: 시크릿 설정 및 권한 확인
3. **VM 배포 실패**: 보안 그룹 및 네트워크 설정 확인
4. **CI/CD 파이프라인 오류**: 워크플로우 파일 문법 및 단계별 실행 확인

### 지원 및 연락처
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: [프로젝트 저장소](https://github.com/jungfrau70/aws_gcp.git)

---

<div align="center">

[← 이전: Cloud Container 과정](cloud_master/cloud_container/README.md) | 
[📚 전체 커리큘럼](cloud_master/curriculum.md) | 
[🏠 학습 경로로 돌아가기](cloud_master/index.md) | 
[다음: 과정 상세 정보 →](cloud_master/과정상세.md)

</div>