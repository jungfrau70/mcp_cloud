# ☁️ 클라우드 중급 과정 - Day 1: 컨테이너 기초 및 클라우드 컨테이너 서비스

## 🎯 Day 1 학습 개요

### 핵심 학습 목표
- **Docker 고급 활용**: 멀티스테이지 빌드, 이미지 최적화 기법을 이해하고 적용합니다.
- **Kubernetes 기초**: Pod, Service, Deployment 등 Kubernetes 핵심 리소스를 이해하고 관리합니다.
- **클라우드 컨테이너 서비스**: AWS ECS, GCP Cloud Run을 활용하여 클라우드 환경에 컨테이너 애플리케이션을 배포합니다.
- **통합 모니터링 허브**: AWS VM 기반 Prometheus + Grafana를 구축하여 모니터링 인프라를 준비합니다.
- **외부 접속 및 보안**: AWS 보안 그룹 자동 설정 및 외부 접속 테스트를 통한 실습 환경 검증

### 실습 후 달성할 수 있는 능력
- ✅ Docker 멀티스테이지 빌드를 활용한 경량화된 이미지 생성
- ✅ Kubernetes 기본 리소스(Pod, Service, Deployment) 배포 및 관리
- ✅ AWS ECS를 활용한 컨테이너 애플리케이션 배포
- ✅ Prometheus + Grafana 기반 모니터링 시스템 구축
- ✅ AWS 보안 그룹 자동 설정 및 외부 접속 테스트
- ✅ 실습 결과 외부 공유 및 검증

### 예상 소요 시간
- **Docker 고급 활용**: 90-120분
- **Kubernetes 기초**: 90-120분
- **클라우드 컨테이너 서비스**: 90-120분
- **통합 모니터링 허브**: 90-120분
- **전체 과정**: 6-8시간

---

## 📚 실습 구성

### 🔧 1교시: Docker 고급 활용 (90분)
- **멀티스테이지 빌드**: 경량화된 이미지 생성
- **이미지 최적화**: 레이어 최적화 및 보안 강화
- **Docker Compose 고급 활용**: 복잡한 애플리케이션 스택 관리

**실습 파일**: [docker-advanced.md](./practice/docker-advanced.md)

### 🔧 2교시: Kubernetes 기초 (90분)
- **Pod, Service, Deployment 생성**: Kubernetes 핵심 리소스 이해
- **ConfigMap, Secret 관리**: 설정 및 보안 정보 관리
- **로컬 Kubernetes 환경 구축**: 개발 환경 설정

**실습 파일**: [kubernetes-basics.md](./practice/kubernetes-basics.md)

### 🔧 3교시: 클라우드 컨테이너 서비스 (90분)
- **AWS ECS 태스크 정의 및 서비스 생성**: AWS 컨테이너 서비스 활용
- **GCP Cloud Run 서비스 배포**: GCP 서버리스 컨테이너 서비스 활용
- **클라우드 네이티브 패턴 학습**: 클라우드 환경에 최적화된 배포 전략

**실습 파일**: [cloud-container-services.md](./practice/cloud-container-services.md)

### 🔧 4교시: 통합 모니터링 허브 구축 (90분)
- **Prometheus + Grafana 스택**: 모니터링 인프라 구축
- **Node Exporter, Push Gateway**: 메트릭 수집 및 전송
- **AlertManager 설정**: 알림 시스템 구성

**실습 파일**: [monitoring-hub.md](./practice/monitoring-hub.md)

### 🔧 5교시: 외부 접속 및 보안 설정 (30분)
- **AWS 보안 그룹 자동 설정**: 외부 접속을 위한 방화벽 설정
- **외부 IP 주소 확인**: 퍼블릭 IP 자동 감지 및 URL 생성
- **외부 접속 테스트**: 모든 서비스의 외부 접속 가능 여부 검증
- **실습 결과 공유**: 외부 접속 URL을 통한 실습 결과 공유

**실습 파일**: [external-access-guide.md](./practice/external-access-guide.md)

---

## 🛠️ 실습 환경 준비

### 📁 실습 코드 및 자동화 (새로운 repo 구조)
- **실습 샘플 코드**: `/cloud_intermediate/repo/practice/day1/`
- **자동화 스크립트**: `/cloud_intermediate/repo/automation/day1/`
- **클라우드 도구**: `/cloud_intermediate/tools/cloud/`

### 필수 도구
- **Docker**: 컨테이너 런타임 환경
- **kubectl**: Kubernetes 클러스터 관리 도구
- **AWS CLI**: AWS 서비스 관리 도구
- **WSL**: Windows Subsystem for Linux (Windows 사용자)

### 환경 설정
```bash
# Docker 설치 확인
docker --version

# kubectl 설치 확인
kubectl version --client

# AWS CLI 설정 확인
aws configure list
```

---

## 📋 실습 진행 순서

### 1단계: 환경 준비 (새로운 repo 구조)
```bash
# 실습 환경 자동 설정
cd cloud_intermediate/tools/cloud/
./cloud-intermediate-helper.sh --setup

# Day1 실습 자동화 실행
# 자동화 스크립트를 실습 위치로 복사
cp ../../tools/cloud/day1-practice.sh ./
chmod +x day1-practice.sh
./day1-practice.sh
```

### 2단계: 실습 진행
1. **Docker 고급 활용** → [docker-advanced.md](./docker-advanced.md)
2. **Kubernetes 기초** → [kubernetes-basics.md](./kubernetes-basics.md)
3. **클라우드 컨테이너 서비스** → [cloud-container-services.md](./cloud-container-services.md)
4. **통합 모니터링 허브** → [monitoring-hub.md](./monitoring-hub.md)
5. **외부 접속 및 보안 설정** → [external-access-guide.md](./external-access-guide.md)

### 2.5단계: 외부 접속 테스트
```bash
# 외부 접속 테스트 및 검증 실행
cd cloud_intermediate/repo/practice/day1/
./external-access-test.sh
```

### 3단계: 실습 정리
```bash
# Day1 실습 자동 정리
cd cloud_intermediate/repo/automation/day1/
./cleanup.sh
```

---

## 🎯 학습 성과 측정

### 실습 완료 체크리스트
- [ ] Docker 멀티스테이지 빌드 실습 완료
- [ ] Kubernetes 기본 리소스 생성 및 관리 완료
- [ ] AWS ECS 컨테이너 서비스 배포 완료
- [ ] GCP Cloud Run 서버리스 배포 완료
- [ ] Prometheus + Grafana 모니터링 시스템 구축 완료
- [ ] AWS 보안 그룹 자동 설정 완료
- [ ] 외부 접속 테스트 및 검증 완료
- [ ] 실습 결과 외부 공유 가능

### 다음 단계
- **Day 2 실습**으로 진행: CI/CD 및 VM 기반 배포, 멀티 클라우드 모니터링
- **통합 강의 시나리오** 확인: [../통합강의시나리오.md](../통합강의시나리오.md)
- **통합 모니터링 시나리오** 확인: [../통합모니터링시나리오.md](../통합모니터링시나리오.md)

---

## 🔗 관련 문서

- [Day 1 강의안](../lectures/day1/)
- [학습 경로](../learning-path.md)
- [과정 개요](../README.md)
- [통합 강의 시나리오](../통합강의시나리오.md)
- [통합 모니터링 시나리오](../통합모니터링시나리오.md)

---

**💡 궁금한 점이 있으시면 언제든 문의해주세요!**
**문제가 발생하거나 도움이 필요하시면 실시간으로 지원해드리겠습니다.**
