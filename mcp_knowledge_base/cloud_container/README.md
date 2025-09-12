# AWS/GCP Advanced 과정

> 📋 **전체 개요**: [README.md](../README.md) | [통합 커리큘럼](../curriculum.md) | [통합 인덱스](../index.md)에서 전체 과정 구조를 확인하세요.

> 📋 **과정 개요**: [과정명.md](./과정명.md) | [과정상세.md](./과정상세.md)에서 상세한 교육 정보를 확인하세요.

## 📋 개요

이 Advanced 과정은 **Master 과정을 완료한 학습자**를 대상으로 한 고급 클라우드 기술 교육입니다.

### 🎯 대상 학습자
- Master 과정을 완료한 학습자
- 실제 클라우드 오케스트레이션 경험이 필요한 개발자
- 대규모 서비스 운영 경험을 원하는 DevOps 엔지니어

---

## 📚 과정 구성

### Day 1: 고급 컨테이너 오케스트레이션
- **3교시**: AWS ECS / GCP GKE로 배포 실습
  - 컨테이너 오케스트레이션 개념
  - AWS ECS vs GCP GKE 비교
  - 실제 클러스터 배포 및 관리
  - 고급 배포 전략 (Blue-Green, Canary)

### Day 2: 고급 인프라 관리
- **1교시**: Kubernetes 심화
- **2교시**: 서비스 메시 (Istio)
- **3교시**: 모니터링 및 로깅 고급
- **4교시**: 보안 및 컴플라이언스

### Day 3: 실무 프로젝트
- **1교시**: 대규모 아키텍처 설계
- **2교시**: 성능 최적화
- **3교시**: 재해 복구 전략
- **4교시**: 프로젝트 발표 및 피드백

---

## 🔗 Master 과정과의 연계

### Master 과정에서 학습한 내용
- ✅ Docker 기초
- ✅ GitHub Actions CI/CD
- ✅ 클라우드 배포 기초
- ✅ 자동 배포 파이프라인

### Advanced 과정에서 확장하는 내용
- 🚀 **컨테이너 오케스트레이션**: ECS, GKE 실제 운영
- 🚀 **고급 배포 전략**: 무중단 배포, 롤백 전략
- 🚀 **대규모 아키텍처**: 마이크로서비스, 서비스 메시
- 🚀 **운영 자동화**: 모니터링, 알림, 자동 복구

---

## 📖 학습 자료

### Day 1
- [3교시: AWS ECS / GCP GKE로 배포 실습](./textbook/Day1/container-orchestration-guide.md)
- [Kubernetes 고급 가이드](./textbook/Day1/kubernetes-advanced-guide.md)
- [자동 복구 가이드](./textbook/Day1/auto-recovery-guide.md)
- [보안 정책 가이드](./textbook/Day1/security-policies-guide.md)
- [비용 최적화 가이드](./textbook/Day1/cost-optimization-guide.md)

### Day 2
- [고가용성 아키텍처 가이드](./textbook/Day2/high-availability-architecture.md)
- [모니터링 설정 가이드](./textbook/Day2/monitoring-setup.md)
- [종합 프로젝트 실습](./textbook/Day2/practice/comprehensive-project.md)

> 📚 **전체 실습 가이드**: [Day1 README](./textbook/Day1/README.md) | [Day2 README](./textbook/Day2/README.md)

---

## 🎯 학습 목표

이 Advanced 과정을 통해 다음을 달성합니다:

1. **실제 클라우드 운영**: Master 과정의 시뮬레이션을 넘어 실제 클라우드 환경에서 서비스 운영
2. **고급 배포 전략**: 무중단 배포, 롤백, 트래픽 분산 등 고급 배포 기법
3. **대규모 아키텍처**: 마이크로서비스, 서비스 메시 등 확장 가능한 아키텍처 설계
4. **운영 자동화**: 모니터링, 알림, 자동 복구 등 운영 자동화 구현

---

## 🚀 시작하기

Advanced 과정을 시작하기 전에 다음을 확인하세요:

### 필수 선수 과정
- [ ] [Master 과정 완료](../cloud_master/textbook/Day1/README.md)
- [ ] Docker 기초 이해
- [ ] GitHub Actions 경험
- [ ] 클라우드 배포 기초 이해

> 🔗 **관련 과정**: [Cloud Master 과정](../cloud_master/textbook/Day1/README.md) | [전체 커리큘럼](../curriculum.md)

### 환경 준비
- [ ] AWS 계정 (ECS, ECR 권한)
- [ ] GCP 계정 (GKE, GCR 권한)
- [ ] kubectl 설치 및 설정
- [ ] AWS CLI, gcloud CLI 설정

### 권장 사항
- Master 과정의 실습 코드를 다시 한번 복습
- 클라우드 계정의 비용 한도 설정
- 실습용 프로젝트 준비

---

## 📞 지원

Advanced 과정에서 문제가 발생하면:
1. [Master 과정의 트러블슈팅 가이드](../cloud_master/textbook/Day1/README.md) 참고
2. [각 교시별 문제 해결 섹션](./textbook/Day2/troubleshooting/multi-az-issues.md) 확인
3. 실습 환경 및 권한 설정 재확인

> 🆘 **지원 채널**: [과정명.md](./과정명.md)에서 문의 정보를 확인하세요.

**🎯 목표**: Master 과정에서 학습한 기초를 바탕으로 실제 프로덕션 환경에서 사용할 수 있는 고급 클라우드 기술을 습득합니다.
