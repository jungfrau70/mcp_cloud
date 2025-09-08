# AWS/GCP 실전 마스터 2일차 교안

## 📋 목차
1. [실습 환경 준비](#실습-환경-준비)
2. [1교시: 고가용성 및 로드 밸런싱](./load-balancing-guide.md)
3. [2교시: 오토 스케일링](./auto-scaling-guide.md)
4. [3교시: 로드 밸런서 + 오토스케일링 연동](./integration-guide.md)
5. [4교시: 장애 시뮬레이션 및 복구](./disaster-recovery-guide.md)
6. [트러블슈팅 가이드](./troubleshooting-guide.md)

---

## 🎯 학습 목표

이 2일차 과정을 통해 다음을 학습합니다:

- **고가용성(High Availability)** 개념과 구현 방법
- **로드 밸런싱**을 통한 트래픽 분산 및 장애 대응
- **오토 스케일링**을 통한 자동 리소스 관리
- **장애 복구** 및 **자가 치유(Self-Healing)** 시스템 구축

---

## ⏰ 일정 및 소요 시간

| 교시 | 내용 | 소요 시간 |
|------|------|-----------|
| 1교시 | 고가용성 및 로드 밸런싱 | 60분 |
| 2교시 | 오토 스케일링 기본 개념 및 실습 | 60분 |
| 3교시 | 로드 밸런서 + 오토스케일링 연동 | 60분 |
| 4교시 | 장애 시뮬레이션 및 복구 실습 | 60분 |
| **총 소요 시간** | | **4시간** |

---

## 🔧 실습 환경 준비

### 필수 소프트웨어 설치

#### 1. AWS CLI 설치 및 설정
```bash
# AWS CLI 설치 확인
aws --version

# AWS 자격증명 설정
aws configure
```

#### 2. Google Cloud SDK 설치 및 설정
```bash
# gcloud CLI 설치 확인
gcloud --version

# GCP 인증
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

#### 3. 부하 테스트 도구 설치
```bash
# Apache Bench (ab) 설치
# Ubuntu/Debian
sudo apt-get install apache2-utils

# CentOS/RHEL
sudo yum install httpd-tools

# macOS
brew install httpd
```

### 클라우드 계정 준비

#### AWS 계정 설정
- [ ] AWS 계정 생성 (무료 티어 가능)
- [ ] EC2, ELB, Auto Scaling 서비스 접근 권한 확인
- [ ] VPC 및 서브넷 설정 확인

#### Google Cloud Platform 계정 설정
- [ ] GCP 계정 생성 ($300 크레딧)
- [ ] Compute Engine, Load Balancing, Instance Groups 서비스 접근 권한 확인
- [ ] VPC 네트워크 설정 확인

### 실습 전 체크리스트

#### 환경 확인
- [ ] AWS CLI가 정상 설정되어 있는가?
```bash
aws sts get-caller-identity
```

- [ ] Google Cloud SDK가 정상 설정되어 있는가?
```bash
gcloud auth list
```

- [ ] 부하 테스트 도구가 설치되어 있는가?
```bash
ab -V
```

#### 계정 준비
- [ ] AWS 계정에 EC2, ELB, Auto Scaling 서비스 접근 권한이 있는가?
- [ ] GCP 계정에 Compute Engine, Load Balancing, Instance Groups 서비스 접근 권한이 있는가?
- [ ] 충분한 할당량(Quota)이 있는가?

---

## 📚 학습 자료

### 참고 문서
- [AWS ELB 공식 문서](https://docs.aws.amazon.com/elasticloadbalancing/)
- [AWS Auto Scaling 공식 문서](https://docs.aws.amazon.com/autoscaling/)
- [GCP Load Balancing 공식 문서](https://cloud.google.com/load-balancing/docs)
- [GCP Managed Instance Groups 공식 문서](https://cloud.google.com/compute/docs/instance-groups)

### 유용한 링크
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Google Cloud Architecture Center](https://cloud.google.com/architecture)
- [부하 테스트 도구 비교](https://www.blazemeter.com/blog/open-source-load-testing-tools-which-one-should-you-choose)

---

## 🚀 시작하기

실습을 시작하기 전에 위의 체크리스트를 모두 확인하세요. 모든 준비가 완료되면 [1교시: 고가용성 및 로드 밸런싱](./load-balancing-guide.md)부터 시작하세요.

### 문제가 있나요?
실습 중 문제가 발생하면 [트러블슈팅 가이드](./troubleshooting-guide.md)를 참고하세요.

---

## 💡 핵심 개념 미리보기

### 고가용성(High Availability)
- **정의**: 시스템이 장애 발생 시에도 서비스를 계속 제공할 수 있도록 하는 설계 원칙
- **구현 방법**: 다중 가용 영역(AZ) 배치, 로드 밸런싱, 자동 복구

### 로드 밸런싱
- **목적**: 트래픽을 여러 서버에 고르게 분산하여 특정 서버의 과부하 방지
- **알고리즘**: Round Robin, Least Connections, Weighted 등

### 오토 스케일링
- **개념**: 서버 부하나 트래픽 변화에 따라 인스턴스 수를 자동으로 증감
- **메트릭**: CPU 사용률, 메모리 사용률, 네트워크 트래픽 등

### 자가 치유(Self-Healing)
- **기능**: 장애가 발생한 인스턴스를 자동으로 감지하고 새로운 인스턴스로 교체
- **구현**: 헬스체크와 오토 스케일링의 연동
