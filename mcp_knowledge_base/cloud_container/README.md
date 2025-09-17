# 🐳 Cloud Container - 컨테이너 오케스트레이션 마스터 과정

## 👋 안녕하세요!

**Cloud Container 과정에 오신 것을 환영합니다!** 🐳

이 과정은 컨테이너 오케스트레이션의 최고봉인 Kubernetes를 중심으로 
고가용성과 확장성을 갖춘 시스템을 구축하는 방법을 학습합니다.

Kubernetes, 고가용성 아키텍처, 고급 모니터링 등 
엔터프라이즈급 시스템 구축에 필요한 모든 기술을 
실습을 통해 체험해보세요!

**궁금한 점이 있으시면 언제든 문의해주세요!** 
문제가 발생하거나 도움이 필요하시면 언제든 연락주시면 친절하게 도와드리겠습니다.
## 📋 사전 요구사항

이 과정을 수강하기 전에 다음 사항들을 확인해주세요:

- **Cloud Master 과정 이수**: Cloud Master 과정의 내용을 이해하고 있어야 합니다
- **Docker 기본 지식**: 컨테이너 기술에 대한 기본적인 이해
- **Kubernetes 기초**: Kubernetes의 기본 개념과 용어에 대한 이해
- **클라우드 경험**: AWS나 GCP에서 실제 서비스를 운영해본 경험
- **학습 시간**: 일일 4-5시간의 학습 시간 확보 (총 2일 과정)
- **고급 실습 환경**: AWS와 GCP의 고급 서비스 사용을 위한 계정과 권한
## 🎯 과정 소개

**Cloud Container**는 Kubernetes와 고급 컨테이너 오케스트레이션 기술을 학습하는 과정입니다. 
대규모 컨테이너 환경을 관리하고 고가용성 시스템을 구축하는 데 필요한 전문적인 역량을 기를 수 있습니다.

### 📋 과정 정보
- **대상자**: Cloud Master 완료자, DevOps 엔지니어, 클라우드 아키텍트, SRE
- **예상 소요시간**: 2일 (총 16시간)
- **난이도**: 고급 (Advanced)
- **선수 요구사항**: 
  - Cloud Master 과정 완료 또는 동등한 수준
  - Docker 기본 사용법 숙지
  - Git/GitHub 기본 사용법 이해
  - 기본적인 YAML 문법 이해

## 📚 학습 목표

이 과정을 완료하면 다음과 같은 전문적인 능력을 갖추게 됩니다:

### 🎯 핵심 목표
- **Kubernetes 마스터**: Kubernetes 클러스터를 완전히 이해하고 관리할 수 있습니다
- **고가용성 아키텍처**: Multi-AZ, Multi-Region 환경을 구축할 수 있습니다
- **고급 모니터링**: Prometheus, Grafana를 활용한 고급 모니터링 시스템을 구축할 수 있습니다
- **보안 정책**: 컨테이너 보안과 네트워크 정책을 구현할 수 있습니다
- **자동화**: CI/CD 파이프라인과 자동 배포를 구현할 수 있습니다

### 🚀 실무 적용 목표
- **프로덕션 환경**: 대규모 프로덕션 환경을 안정적으로 운영할 수 있습니다
- **팀 리딩**: 컨테이너 기반 개발팀을 리딩할 수 있습니다
- **문제 해결**: 복잡한 클러스터 문제를 분석하고 해결할 수 있습니다
- **아키텍처 설계**: 확장 가능하고 안정적인 컨테이너 아키텍처를 설계할 수 있습니다

## 📋 과정 개요

### 📅 Day 1: Kubernetes 및 GKE 고급 오케스트레이션 (8시간)
**목표**: Kubernetes의 고급 기능을 학습하고 GKE를 활용한 클러스터를 구축합니다

#### 🌅 오전 (4시간)
- **09:00-10:00**: Kubernetes 고급 개념 및 아키텍처
- **10:00-11:00**: GKE 클러스터 생성 및 설정
- **11:00-12:00**: Pod, Service, Ingress 고급 설정

#### 🌆 오후 (4시간)
- **13:00-14:00**: ConfigMap, Secret, PersistentVolume 관리
- **14:00-15:00**: 네트워크 정책 및 보안 설정
- **15:00-16:00**: 고급 스케줄링 및 리소스 관리
- **16:00-17:00**: 종합 실습 및 정리

### 📅 Day 2: 고가용성 및 확장성 아키텍처 (8시간)
**목표**: 고가용성과 확장성을 갖춘 고급 아키텍처를 구축합니다

#### 🌅 오전 (4시간)
- **09:00-10:00**: Multi-AZ 클러스터 구성
- **10:00-11:00**: 고급 로드 밸런싱 및 트래픽 관리
- **11:00-12:00**: 자동 스케일링 및 HPA 설정

#### 🌆 오후 (4시간)
- **13:00-14:00**: 고급 모니터링 시스템 구축
- **14:00-15:00**: 로그 수집 및 분석 시스템
- **15:00-16:00**: 종합 프로젝트
- **16:00-17:00**: 다음 단계 안내 및 정리

## 🚀 시작하기

### 1️⃣ 사전 준비
다음 항목들을 미리 준비해주세요:

- **Cloud Master 완료**: Docker, CI/CD 기본 지식
- **개발 환경**: kubectl, Helm, VS Code
- **클라우드 계정**: GCP 계정 (GKE 사용)
- **GitHub 계정**: 코드 저장 및 협업용

### 2️⃣ 환경 설정
```bash
# kubectl 설치
# https://kubernetes.io/docs/tasks/tools/install-kubectl/

# Helm 설치
# https://helm.sh/docs/intro/install/

# GCP CLI 설치 (이미 설치되어 있다면 생략)
# https://cloud.google.com/sdk/docs/install
```

### 3️⃣ 첫 번째 실습 시작
1. Day 1 실습 가이드로 이동
2. [Kubernetes 기초](/mcp_knowledge_base/cloud_container/textbook/Day1/kubernetes-basics.md) 따라하기
3. [GKE 클러스터 생성](/mcp_knowledge_base/cloud_container/textbook/Day1/container-orchestration-guide.md) 따라하기

## 📚 학습 자료

### 📖 교재
- Day 1: Kubernetes 및 GKE 고급 오케스트레이션
- Day 2: 고가용성 및 확장성 아키텍처

### 🔧 실습 가이드
- [Kubernetes 기초](/mcp_knowledge_base/cloud_container/textbook/Day1/kubernetes-basics.md)
- [컨테이너 오케스트레이션 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/container-orchestration-guide.md)
- [보안 정책 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/security-policies-guide.md)
- [고가용성 아키텍처](/mcp_knowledge_base/cloud_container/textbook/Day2/high-availability-architecture.md)
- [고급 모니터링](/mcp_knowledge_base/cloud_container/textbook/Day2/monitoring-setup.md)

### 🛠️ 설치 가이드
- [kubectl 설치](/mcp_knowledge_base/cloud_container/install/install_kubectl.md)
- [Helm 설치](/mcp_knowledge_base/cloud_container/install/install_helm.md)
- [GKE 클러스터 설정](/mcp_knowledge_base/cloud_container/install/gke-setup.md)

## ✅ 학습 체크리스트

### Day 1 완료 확인
- [ ] Kubernetes 기본 개념 이해
- [ ] GKE 클러스터 생성 및 연결 성공
- [ ] Pod, Service, Ingress 설정 완료
- [ ] ConfigMap, Secret 관리 완료
- [ ] 네트워크 정책 설정 완료

### Day 2 완료 확인
- [ ] Multi-AZ 클러스터 구성 완료
- [ ] 고급 로드 밸런싱 설정 완료
- [ ] 자동 스케일링 설정 완료
- [ ] 고급 모니터링 시스템 구축 완료
- [ ] 로그 수집 시스템 구축 완료

## ❓ 자주 묻는 질문 (FAQ)

### Q1: Cloud Master를 완료하지 않았는데 수강할 수 있나요?
**A**: Cloud Master 과정을 먼저 완료하는 것을 강력히 권장합니다. 이 과정은 고급 수준의 내용으로 구성되어 있어 기본 지식이 필요합니다.

### Q2: Kubernetes 경험이 없어도 괜찮나요?
**A**: 네, 괜찮습니다! 이 과정에서 Kubernetes 기초부터 차근차근 학습할 수 있습니다.

### Q3: 실제 프로덕션 환경에 바로 적용할 수 있나요?
**A**: 네, 가능합니다! 이 과정의 모든 내용은 실제 프로덕션 환경에서 사용되는 기술들입니다.

### Q4: 이 과정을 완료하면 어떤 자격을 얻을 수 있나요?
**A**: 이 과정을 완료하면 Kubernetes 관리자 수준의 역량을 갖추게 되며, CKA(Certified Kubernetes Administrator) 시험 준비에도 도움이 됩니다.

## 🔗 관련 과정

### 📚 전체 커리큘럼
- [전체 커리큘럼 보기](/mcp_knowledge_base/curriculum.md)
- [학습 경로 안내](/mcp_knowledge_base/cloud_container/learning-path.md)

### 🚀 이전 단계
- Cloud Basic 과정 - 클라우드 기초
- Cloud Master 과정 - Docker, CI/CD

### 🏠 홈으로
- [통합 인덱스](/mcp_knowledge_base/index.md)

## 📞 문의 및 지원

### 💬 학습 지원
- **실시간 질문**: 각 실습 가이드의 댓글 섹션 활용
- **문제 신고**: GitHub Issues를 통한 버그 신고
- **기능 요청**: 새로운 기능이나 개선사항 제안

### 📧 연락처
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: [프로젝트 저장소](https://github.com/jungfrau70/aws_gcp.git)
## 🎉 Cloud Container 과정을 시작하세요!

🚀 Day 1 실습 시작하기 |
[📚 전체 커리큘럼 보기](/mcp_knowledge_base/curriculum.md) | 
[🏠 홈으로 돌아가기](/mcp_knowledge_base/index.md)

</div>

---

## 🧭 네비게이션

<div align="center">

[🏠 홈으로 돌아가기](/mcp_knowledge_base/index.md) | 
[📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | 
[🔗 학습 경로](/mcp_knowledge_base/cloud_container/learning-path.md)

📅 Day1 시작하기 |
📅 Day2 시작하기

</div>
