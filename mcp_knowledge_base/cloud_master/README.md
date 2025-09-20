# 🎯 Cloud Master 과정

## 📚 과정 소개

**Cloud Master**는 AWS와 GCP를 활용한 클라우드 마스터 과정입니다. Docker, CI/CD, 모니터링, 비용 최적화까지 클라우드 운영의 전 과정을 실습으로 학습합니다.

> 📌 **상세 정보**: [과정상세.md](과정상세.md)에서 전체 과정 개요, 학습 목표, 커리큘럼을 확인하세요.

## 🚀 빠른 시작

### 1단계: 환경 준비
- [AWS Free Tier 계정](https://aws.amazon.com/free/) 생성
- [GCP Free Tier 계정](https://cloud.google.com/free) 생성
- [Docker 설치](cloud_basic/textbook/Day1/guides/install_docker.md)
- [Git 설정](cloud_basic/textbook/Day1/guides/install_git.md)

### 2단계: 학습 시작
- [Day 1: Docker & Git/GitHub & GitHub Actions](textbook/Day1/README.md)
- [Day 2: 고급 CI/CD & VM 기반 컨테이너 배포](textbook/Day2/README.md)
- [Day 3: 로드밸런싱 & 모니터링 & 비용 최적화](textbook/Day3/README.md)

### 3단계: 체계적 학습
- [학습 경로](learning-path.md) - 단계별 학습 가이드
- [과정명](과정명.md) - 간단한 과정 요약

## 🎯 핵심 학습 목표

- **Docker 컨테이너화**: 애플리케이션 컨테이너화 및 최적화
- **고급 CI/CD**: GitHub Actions를 활용한 자동화 파이프라인 구축
- **클라우드 모니터링**: Prometheus, Grafana를 활용한 모니터링 시스템 구축
- **비용 최적화**: 클라우드 리소스 최적화 및 비용 절감 전략

## 📋 선수 요구사항

- **기본 지식**: Linux 명령어, 네트워킹 기초
- **계정**: AWS Free Tier, GCP Free Tier 계정
- **도구**: Docker, Git, GitHub 계정

## 🗓️ 3일 커리큘럼

| Day | 주제 | 예상 시간 | 핵심 내용 |
|-----|------|-----------|-----------|
| **Day 1** | Docker & Git/GitHub & GitHub Actions | 8시간 | 컨테이너화, 버전 관리, CI/CD 파이프라인 |
| **Day 2** | 고급 CI/CD & VM 기반 컨테이너 배포 | 8시간 | 멀티스테이지 빌드, Kubernetes, 자동 배포 |
| **Day 3** | 로드밸런싱 & 모니터링 & 비용 최적화 | 8시간 | 로드밸런싱, 모니터링, 비용 최적화 |

## 🔧 실습 환경

### 필수 도구
- **Docker**: 컨테이너 실행 환경
- **Git**: 버전 관리
- **GitHub**: 코드 저장소 및 CI/CD
- **AWS CLI**: AWS 서비스 관리
- **GCP CLI**: GCP 서비스 관리

### 클라우드 계정
- **AWS**: Free Tier 계정 (12개월 무료)
- **GCP**: Free Tier 계정 ($300 크레딧)

## 📚 학습 자료

### 📖 이론 학습
- [과정상세.md](과정상세.md) - 전체 과정 상세 정보
- [학습경로.md](learning-path.md) - 체계적인 학습 순서
- [과정명.md](과정명.md) - 간단한 과정 요약

### 🛠️ 실습 가이드
- [Day 1 실습](textbook/Day1/README.md) - Docker & Git/GitHub & GitHub Actions
- [Day 2 실습](textbook/Day2/README.md) - 고급 CI/CD & VM 기반 컨테이너 배포
- [Day 3 실습](textbook/Day3/README.md) - 로드밸런싱 & 모니터링 & 비용 최적화

### 🔧 환경 설정 가이드
- [WSL 자동 설정](repos/cloud-scripts/wsl-auto-setup.sh) - WSL 환경 원클릭 구축
- [WSL 추가 생성 가이드](repos/cloud-scripts/wsl-setup-guide.md) - 상세한 WSL 환경 구축 가이드
- [환경 체크 도구](repos/cloud-scripts/environment-check-wsl.sh) - 실습 환경 자동 검증
- [Docker 설치 가이드](cloud_basic/textbook/Day1/guides/install_docker.md)
- [Git 설정 가이드](cloud_basic/textbook/Day1/guides/install_git.md)
- [AWS CLI 설정 가이드](cloud_basic/textbook/Day1/guides/install_aws_cli.md)
- [GCP CLI 설정 가이드](cloud_basic/textbook/Day1/guides/install_gcp_cli.md)

### 🧹 정리 도구
- [통합 클러스터 정리](repos/cloud-scripts/cluster-cleanup-interactive.sh) - EKS/GKE 클러스터 선택적 정리
- [통합 VM 정리](repos/cloud-scripts/vm-cleanup-interactive.sh) - GCP/AWS VM 인스턴스 선택적 정리
- [VPC 정리 스크립트](repos/cloud-scripts/cleanup-vpcs.sh) - AWS VPC 선택적 삭제
- [VPC 진단 스크립트](repos/cloud-scripts/diagnose-vpc.sh) - VPC 종속성 진단
- [리소스 정리 가이드](repos/cloud-scripts/README.md) - 전체 정리 도구 사용법

## ✅ 학습 체크리스트

### 사전 준비
- [ ] WSL 환경 구축 (Windows 사용자)
- [ ] AWS Free Tier 계정 생성
- [ ] GCP Free Tier 계정 생성
- [ ] Docker 설치 및 설정
- [ ] Git 설치 및 GitHub 계정 연동
- [ ] AWS CLI 설치 및 설정
- [ ] GCP CLI 설치 및 설정
- [ ] 환경 체크 도구 실행 및 검증

### Day별 학습
- [ ] **Day 1**: Docker & Git/GitHub & GitHub Actions 실습 완료
- [ ] **Day 2**: 고급 CI/CD & VM 기반 컨테이너 배포 실습 완료
- [ ] **Day 3**: 로드밸런싱 & 모니터링 & 비용 최적화 실습 완료

### 최종 평가
- [ ] **실습 완료율**: 80% 이상
- [ ] **리소스 정리**: 생성된 모든 리소스 정리 완료
- [ ] **환경 정리**: 로컬 환경 및 클라우드 리소스 정리 완료
- [ ] **최종 프로젝트**: 개인별 클라우드 인프라 구축
- [ ] **평가**: 실습 결과물 및 최종 프로젝트 평가

## 🎓 수료 기준

- **실습 완료율**: 80% 이상
- **최종 프로젝트**: 개인별 클라우드 인프라 구축
- **평가**: 실습 결과물 및 최종 프로젝트 평가

## 📞 지원 및 문의

- **기술 지원**: [GitHub Issues](https://github.com/your-repo/issues)
- **학습 지원**: [Discord 채널](https://discord.gg/your-channel)
- **문서 개선**: [Pull Request](https://github.com/your-repo/pulls)

---

<div align="center">

[← 이전: Cloud Container 과정](cloud_container/README.md) | 
[📚 전체 커리큘럼](curriculum.md) | 
[🏠 학습 경로로 돌아가기](index.md) | 
[다음: 과정 상세 정보 →](과정상세.md)

</div>