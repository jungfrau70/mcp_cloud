# 🎯 Cloud Intermediate - 클라우드 중급 과정

> 📋 **과정 개요**: 클라우드 컨테이너 서비스와 DevOps 실무 역량 강화  
> 📋 **교육 기간**: 2일 (16시간)  
> 📋 **교육 방식**: 100% 자동화 실습 중심  
> 📋 **선수 학습**: Cloud Basic 완료 (AWS/GCP 기초 서비스)  

---

## 🎯 학습 목표

### 핵심 역량
- **Docker 고급 활용**: 멀티스테이지 빌드, 최적화 기법
- **Kubernetes 기초**: Pod, Service, Deployment, ConfigMap, Secret
- **클라우드 컨테이너 서비스**: AWS ECS, GCP Cloud Run, AWS EKS, GCP GKE
- **CI/CD 파이프라인**: GitHub Actions 자동화된 배포
- **모니터링 스택**: Prometheus + Grafana 통합 모니터링
- **DevOps 실무**: 프로덕션 환경 패턴 학습

### 자동화 특징
- **🤖 100% 자동화**: 모든 실습이 자동화 스크립트로 완주
- **📊 실시간 모니터링**: 강의 진행 상황 실시간 추적
- **🔄 Interactive & Parameter 모드**: 사용자 편의성 극대화
- **🧹 자동 리소스 정리**: 실습 후 깔끔한 환경 복원

---

## 📚 과정 구성

### **Day 1: 컨테이너 기초 및 클라우드 서비스**
- **1교시**: Docker 고급 활용 (90분)
- **2교시**: Kubernetes 기초 (90분)
- **3교시**: AWS ECS 기초 (90분)
- **4교시**: 통합 모니터링 허브 구축 (90분)

### **Day 2: CI/CD 및 고급 배포**
- **1교시**: GitHub Actions CI/CD 파이프라인 (90분)
- **2교시**: 멀티 클라우드 통합 모니터링 시스템 (90분)
- **3교시**: AWS Application 모니터링 (90분)
- **4교시**: GCP 클러스터 통합 모니터링 (90분)

---

## 🛠️ 실습 환경

### **권장 환경**
- **AWS EC2**: t3.medium (2vCPU, 4GB RAM)
- **GCP GKE**: e2-medium 노드 3개
- **로컬 환경**: WSL2 또는 macOS/Linux

### **필수 도구**
- Docker & Docker Compose
- kubectl (Kubernetes CLI)
- AWS CLI & GCP CLI
- Git & GitHub

---

## 🚀 빠른 시작

### **1. 실습 환경 설정**
```bash
# 실습 코드 다운로드
git clone https://github.com/jungfrau70/cloud-intermediate.git
cd cloud-intermediate

# 환경 설정 (새로운 repo 구조)
cd repo/setup/
chmod +x install-all-wsl.sh
./install-all-wsl.sh
```

### **2. 자동화 실행**
```bash
# 전체 과정 자동화 실행 (새로운 구조)
cd repo/automation/
./cloud-intermediate-helper.sh

# 개별 Day 실행
cd automation/day1/
./day1-practice.sh

cd automation/day2/
./day2-practice.sh
```

### **3. 실시간 모니터링**
```bash
# 강의 진행 상황 모니터링 (새로운 구조)
cd repo/tools/monitoring/
./lecture-monitor.sh --dashboard
```

---

## 📊 학습 성과

### **완료 후 달성 능력**
- ✅ 멀티스테이지 빌드로 Docker 이미지 크기 50% 이상 감소
- ✅ Kubernetes 기본 리소스 생성 및 관리
- ✅ AWS ECS 클러스터 생성 및 Fargate 태스크 실행
- ✅ GCP Cloud Run 서비스 배포 및 관리
- ✅ GitHub Actions CI/CD 파이프라인 구축
- ✅ 통합 모니터링 허브 구축 및 운영

### **실무 적용**
- **프로덕션 환경**: 학습한 패턴을 실제 업무에 적용
- **팀 협업**: DevOps 문화 정착 및 자동화 확산
- **지속적 학습**: 최신 기술 트렌드 지속적 학습

---

## 📚 관련 문서

- [Day1 강의안](./Day1_강의안.md) - 1일차 상세 가이드
- [Day2 강의안](./Day2_강의안.md) - 2일차 상세 가이드
- [학습 경로](./learning-path.md) - 전체 학습 경로
- [통합 강의 시나리오](./통합강의시나리오.md) - 전체 과정 시나리오
- [통합 모니터링 시나리오](./통합모니터링시나리오.md) - 모니터링 구축 가이드

---

## 🎓 다음 단계

### **Cloud Master 과정 준비**
- **고급 Kubernetes**: Helm, Operator, Service Mesh
- **멀티 클라우드**: AWS + GCP + Azure 통합 관리
- **DevSecOps**: 보안 통합 CI/CD 파이프라인
- **AI/ML Ops**: 머신러닝 모델 배포 및 관리

---

## 💡 지원 및 문의

**💡 궁금한 점이 있으시면 언제든 문의해주세요!**  
**문제가 발생하거나 도움이 필요하시면 실시간으로 지원해드리겠습니다.**

---

**🎯 Cloud Intermediate 과정을 통해 현대적인 클라우드 네이티브 개발 역량을 완성하세요!**
