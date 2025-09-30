# ☁️ 클라우드 중급 과정 - Day 2: CI/CD 및 VM 기반 배포, 멀티 클라우드 모니터링

## 🎯 Day 2 학습 개요

### 핵심 학습 목표
- **CI/CD 파이프라인**: GitHub Actions를 활용한 자동화된 빌드, 테스트, 배포 파이프라인을 구축합니다.
- **멀티 클라우드 통합 모니터링**: AWS EC2, GCP Compute Engine을 연동한 통합 모니터링 시스템을 구축합니다.
- **AWS EC2 VM 애플리케이션 모니터링**: EC2 VM 애플리케이션 배포 및 모니터링을 통해 실무 역량을 강화합니다.
- **GCP Compute Engine VM 통합**: GCP VM 구축 및 멀티 클라우드 모니터링을 완성합니다.

### 실습 후 달성할 수 있는 능력
- ✅ GitHub Actions CI/CD 파이프라인 구축 및 운영
- ✅ 멀티 클라우드 환경에서의 통합 모니터링 시스템 구축
- ✅ AWS EC2 및 GCP Compute Engine VM 운영
- ✅ VM 기반 애플리케이션 배포 및 모니터링
- ✅ 실무 수준의 DevOps 자동화 역량

### 예상 소요 시간
- **CI/CD 파이프라인**: 90-120분
- **멀티 클라우드 통합 모니터링**: 90-120분
- **AWS EC2 VM 애플리케이션 모니터링**: 90-120분
- **GCP Compute Engine VM 통합**: 90-120분
- **전체 과정**: 6-8시간

---

## 📚 실습 구성

### 🔧 1교시: GitHub Actions CI/CD 파이프라인 (90분)
- **GitHub Actions 워크플로우**: 자동화된 빌드, 테스트, 배포 파이프라인
- **자동화된 테스트 및 배포**: 품질 보장 및 배포 자동화
- **환경별 배포 전략**: 개발, 스테이징, 프로덕션 환경 관리

**실습 파일**: [cicd-pipeline.md](./cicd-pipeline.md)

### 🔧 2교시: 멀티 클라우드 통합 모니터링 시스템 (90분)
- **AWS EC2 VM 모니터링**: Infrastructure/Platform 모니터링
- **GCP Compute Engine VM 모니터링**: 멀티 클라우드 통합 모니터링
- **Global Dashboard**: 통합 시각화 및 알림 시스템

**실습 파일**: [monitoring-basics.md](./monitoring-basics.md)

### 🔧 3교시: AWS EC2 VM 애플리케이션 모니터링 (90분)
- **GitHub Actions를 통한 AWS EC2 VM 애플리케이션 배포**: 자동화된 배포 파이프라인
- **VM 기반 Application 모니터링**: 애플리케이션 성능 및 상태 모니터링
- **실시간 알림 시스템**: 문제 발생 시 즉시 알림

**실습 파일**: [monitoring-basics.md](./monitoring-basics.md)

### 🔧 4교시: GCP Compute Engine VM 통합 모니터링 (90분)
- **GCP Compute Engine VM 구축**: GCP VM 환경 설정
- **GCP VM Infrastructure/Platform 모니터링**: GCP VM 환경 모니터링
- **멀티 클라우드 통합 모니터링**: AWS + GCP 통합 관리

**실습 파일**: [monitoring-basics.md](./monitoring-basics.md)

### 🔧 5교시: AWS ECS 고급 배포 (90분)
- **Application Load Balancer 설정**: 로드 밸런싱 및 트래픽 관리
- **자동 스케일링**: 트래픽에 따른 자동 확장/축소
- **Blue-Green, Canary 배포**: 무중단 배포 전략

**실습 파일**: [cloud-deployment.md](./cloud-deployment.md)

### 🔧 6교시: GCP Cloud Run 고급 배포 (90분)
- **도메인 매핑**: 사용자 정의 도메인 설정
- **트래픽 분할**: 카나리 배포 및 트래픽 관리
- **서버리스 최적화**: 비용 효율적인 서버리스 아키텍처

**실습 파일**: [cloud-deployment.md](./cloud-deployment.md)

---

## 🛠️ 실습 환경 준비

### 📁 실습 코드 및 자동화 (새로운 repo 구조)
- **실습 샘플 코드**: `/cloud_intermediate/repo/practice/day2/`
- **자동화 스크립트**: `/cloud_intermediate/repo/automation/day2/`
- **클라우드 도구**: `/cloud_intermediate/tools/cloud/`

### 필수 도구
- **GitHub Actions**: CI/CD 파이프라인 자동화
- **AWS CLI**: AWS 서비스 관리 도구
- **GCP CLI**: GCP 서비스 관리 도구
- **kubectl**: Kubernetes 클러스터 관리 도구

### 환경 설정
```bash
# GitHub Actions 설정 확인
gh auth status

# AWS CLI 설정 확인
aws sts get-caller-identity

# GCP CLI 설정 확인
gcloud auth list

# kubectl 설정 확인
kubectl version --client
```

---

## 📋 실습 진행 순서

### 1단계: 환경 준비
```bash
# 실습 환경 자동 설정
# 자동화 스크립트를 실습 위치로 복사
cp ../../tools/cloud/day2-practice.sh ./
chmod +x day2-practice.sh
./day2-practice.sh --action setup
```

### 2단계: 실습 진행
1. **CI/CD 파이프라인** → [cicd-pipeline.md](./cicd-pipeline.md)
2. **멀티 클라우드 통합 모니터링** → [monitoring-basics.md](./monitoring-basics.md)
3. **클라우드 고급 배포** → [cloud-deployment.md](./cloud-deployment.md)

### 3단계: 실습 정리
```bash
# Day2 실습 자동 정리
# 자동화 스크립트를 실습 위치로 복사 (이미 복사된 경우 생략 가능)
cp ../../tools/cloud/day2-practice.sh ./
chmod +x day2-practice.sh
./day2-practice.sh --action cleanup
```

---

## 🎯 학습 성과 측정

### 실습 완료 체크리스트
- [ ] GitHub Actions CI/CD 파이프라인 구축 완료
- [ ] 멀티 클라우드 통합 모니터링 시스템 구축 완료
- [ ] AWS EC2 VM 애플리케이션 배포 및 모니터링 완료
- [ ] GCP Compute Engine VM 구축 및 통합 모니터링 완료
- [ ] AWS ECS 고급 배포 전략 구현 완료
- [ ] GCP Cloud Run 고급 배포 전략 구현 완료

### 다음 단계
- **Cloud Master 과정** 준비: 고급 Kubernetes, Service Mesh, DevSecOps, VM 기반 배포
- **실무 적용**: 회사 프로젝트에 CI/CD 파이프라인 도입
- **팀 협업**: DevOps 문화 정착 및 자동화 확산

---

## 🔗 관련 문서

- [Day 2 강의안](../lectures/day2/)
- [학습 경로](../learning-path.md)
- [과정 개요](../README.md)
- [통합 강의 시나리오](../통합강의시나리오.md)
- [통합 모니터링 시나리오](../통합모니터링시나리오.md)

---

**💡 궁금한 점이 있으시면 언제든 문의해주세요!**
**문제가 발생하거나 도움이 필요하시면 실시간으로 지원해드리겠습니다.**
