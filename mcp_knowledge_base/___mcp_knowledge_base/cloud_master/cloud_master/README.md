# Cloud Master - 3일차: 로드 밸런싱, 모니터링, 비용 최적화 이론 및 실습

<details>
<summary>📋 목차</summary>

## 🎯 강의 시나리오 (표준 순서)

1. [🎯 학습 목표](#-학습-목표)
2. [🔧 실습 환경 준비](#-실습-환경-준비)
3. [✅ 실습 환경 확인](#-실습-환경-확인)
4. [📚 이론 학습](#-이론-학습)
5. [🛠️ 실습 학습](#-실습-학습)
6. [🧹 실습 정리](#-실습-정리)

## 📚 참고 자료

1. [📚 문제 해결 및 참고 자료](#-문제-해결-및-참고-자료)

</details>

<details>
<summary>🎯 학습 목표</summary>

### 핵심 학습 목표

[핵심 학습 목표](#핵심-학습-목표)
- **로드 밸런싱** ELB, Cloud Load Balancing 구성
- **Auto Scaling** Auto Scaling Group, Managed Instance Group
- **모니터링** CloudWatch, Cloud Monitoring 설정
- **장애 복구** Health Check 기반 자동 교체

### 실습 후 달성할 수 있는 능력

[실습 후 달성할 수 있는 능력](#실습-후-달성할-수-있는-능력)
- ✅ 로드 밸런서 구성 및 트래픽 분산
- ✅ Auto Scaling 정책 설정 및 자동 확장
- ✅ 모니터링 대시보드 구축
- ✅ 장애 복구 자동화 구현

### 예상 소요 시간

[예상 소요 시간](#예상-소요-시간)
- **로드 밸런싱**: 120-150분
- **Auto Scaling**: 90-120분
- **모니터링**: 90-120분
- **장애 복구**: 60-90분
- **전체 과정**: 6-8시간

</details>

<details>
<summary>🔧 실습 환경 준비</summary>

### 필수 도구 설치

#### AWS CLI 설치 및 설정
```bash
# AWS CLI 설치 확인
aws --version

# AWS CLI 설정
aws configure
```

#### gcloud CLI 설치 및 설정
```bash
# gcloud CLI 설치 확인
gcloud --version

# gcloud CLI 설정
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

#### Docker 및 Docker Compose 설치
```bash
# Docker 설치 확인
docker --version
docker-compose --version

# Docker 서비스 시작
sudo systemctl start docker
sudo systemctl enable docker
```

#### Git 설치 및 설정
```bash
# Git 설치 확인
git --version

# Git 설정
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 클라우드 계정 설정

#### AWS 계정 설정
- [AWS 계정 생성 및 설정](/mcp_knowledge_base/cloud_basic/accounts/AWS계정가입.md)
- IAM 사용자 생성 및 권한 설정
- EC2 키 페어 생성

#### GCP 계정 설정
- [GCP 계정 생성 및 설정](/mcp_knowledge_base/cloud_basic/accounts/GCP_개인계정가입.md)
- 프로젝트 생성 및 활성화
- 서비스 계정 생성 및 키 다운로드

</details>

<details>
<summary>✅ 실습 환경 확인</summary>

### 자동 환경 체크 (권장)
```bash
# 통합 환경 체크 스크립트 실행 (Kubernetes 포함)
./mcp_knowledge_base/cloud_master/repos/cloud-scripts/environment-check.sh day3
```

### 수동 환경 확인

#### AWS CLI 설정 확인
```bash
# AWS CLI 설정 확인
aws sts get-caller-identity

# AWS 리전 설정 확인
aws configure get region

# AWS CLI 프로필 확인
aws configure list
```

#### gcloud CLI 설정 확인
```bash
# gcloud CLI 인증 확인
gcloud auth list

# 활성 프로젝트 확인
gcloud config get-value project

# gcloud CLI 설정 확인
gcloud config list
```

#### Docker 환경 확인
```bash
# Docker 설치 확인
docker --version
docker-compose --version

# Docker 서비스 상태 확인
docker info

# Docker 컨테이너 실행 테스트
docker run hello-world
```

#### Git 설정 확인
```bash
# Git 설정 확인
git config --list

# Git 연결 테스트
git clone https:///github.com/octocat/Hello-World.git
cd Hello-World
rm -rf Hello-World
```

### 환경 체크 결과 해석

#### 성공적인 환경 체크
- ✅ 모든 도구가 정상적으로 설치됨
- ✅ 클라우드 계정 인증 완료
- ✅ 네트워크 연결 정상
- ✅ 실습 준비 완료

#### 환경 체크 실패 시 대응
- ❌ 도구 설치 실패: 설치 가이드 참조
- ❌ 인증 실패: 계정 설정 재확인
- ❌ 네트워크 문제: 방화벽 설정 확인
- ❌ 권한 부족: IAM 권한 재설정

</details>

<details>
<summary>📚 이론 학습</summary>

<details>
<summary>⚖️ 로드 밸런싱 및 Auto Scaling</summary>

#### 로드 밸런싱이란?

여러 서버에 트래픽을 분산시켜 성능과 가용성을 향상시키는 기술입니다.

#### 로드 밸런싱 장점

- **고가용성**: 서버 장애 시 다른 서버로 트래픽 전환
- **성능 향상**: 트래픽 분산으로 응답 시간 단축
- **확장성**: 서버 추가로 용량 확장
- **부하 분산**: CPU, 메모리 사용량 균등 분산

#### AWS ELB (Elastic Load Balancer)

- **ALB (Application Load Balancer)**: 7계층 로드 밸런싱
- **NLB (Network Load Balancer)**: 4계층 로드 밸런싱
- **CLB (Classic Load Balancer)**: 레거시 로드 밸런서
- **Gateway Load Balancer**: 3계층 로드 밸런싱

#### GCP Cloud Load Balancing

- **HTTP(S) Load Balancing**: 글로벌 HTTP(S) 로드 밸런싱
- **TCP/UDP Load Balancing**: 지역 TCP/UDP 로드 밸런싱
- **Internal Load Balancing**: 내부 로드 밸런싱
- **Network Load Balancing**: 프리미엄 네트워크 로드 밸런싱

#### 로드 밸런싱 알고리즘

!Load Balancing Algorithms

- **Round Robin**: 순차적으로 서버 선택
- **Least Connections**: 연결 수가 가장 적은 서버 선택
- **IP Hash**: 클라이언트 IP 기반 서버 선택
- **Weighted**: 서버별 가중치 적용

</details>

<details>
<summary>📊 Auto Scaling</summary>

#### Auto Scaling이란?

워크로드에 따라 자동으로 리소스를 확장하거나 축소하는 기능입니다.

#### Auto Scaling 장점

- **비용 최적화**: 필요할 때만 리소스 사용
- **성능 보장**: 트래픽 증가 시 자동 확장
- **가용성 향상**: 장애 시 자동 복구
- **운영 효율성**: 수동 개입 최소화

#### AWS Auto Scaling

- **Auto Scaling Group**: EC2 인스턴스 자동 관리
- **Launch Template**: 인스턴스 생성 템플릿
- **Scaling Policy**: 확장/축소 정책
- **Health Check**: 인스턴스 상태 모니터링

#### GCP Managed Instance Group

- **Instance Template**: VM 생성 템플릿
- **Auto Scaling Policy**: 확장/축소 정책
- **Health Check**: VM 상태 모니터링
- **Load Balancing**: 자동 로드 밸런싱

#### Auto Scaling 정책

- **Target Tracking**: 메트릭 기반 자동 조정
- **Step Scaling**: 단계별 확장/축소
- **Simple Scaling**: 단순 확장/축소
- **Scheduled Scaling**: 시간 기반 조정

</details>

<details>
<summary>📊 컨테이너 모니터링 및 로깅</summary>

#### 모니터링이란?

시스템의 상태, 성능, 가용성을 지속적으로 관찰하고 측정하는 활동입니다.

#### 모니터링의 중요성

- **장애 예방**: 문제 발생 전 조기 감지
- **성능 최적화**: 병목 지점 식별 및 개선
- **용량 계획**: 리소스 사용량 분석
- **비용 관리**: 리소스 효율성 모니터링

#### AWS CloudWatch

- **메트릭**: 시스템 및 애플리케이션 지표
- **로그**: 애플리케이션 및 시스템 로그
- **알람**: 임계값 기반 알림
- **대시보드**: 시각화된 모니터링 화면

#### GCP Cloud Monitoring

- **메트릭**: 시스템 및 애플리케이션 지표
- **로그**: Cloud Logging 통합
- **알림**: 임계값 기반 알림
- **대시보드**: 시각화된 모니터링 화면

#### 컨테이너 모니터링 도구

- **Prometheus**: 메트릭 수집 및 저장
- **Grafana**: 시각화 및 대시보드
- **ELK Stack**: 로그 수집, 분석, 시각화
- **Jaeger**: 분산 추적

</details>

<details>
<summary>🔄 장애 복구 및 운영 자동화</summary>

#### 장애 복구란?

시스템 장애 발생 시 서비스를 정상 상태로 복구하는 과정입니다.

#### 장애 복구 전략

- **Prevention**: 장애 예방
- **Detection**: 장애 감지
- **Response**: 장애 대응
- **Recovery**: 서비스 복구

#### Health Check

- **Liveness Probe**: 컨테이너 생존 상태 확인
- **Readiness Probe**: 서비스 준비 상태 확인
- **Startup Probe**: 시작 상태 확인
- **Custom Health Check**: 사용자 정의 헬스 체크

#### 자동 복구 메커니즘

- **Auto Restart**: 자동 재시작
- **Auto Scaling**: 자동 확장
- **Load Balancing**: 트래픽 전환
- **Failover**: 장애 시 대체 시스템 활성화

#### 운영 자동화

- **Infrastructure as Code**: 인프라 코드화
- **Configuration Management**: 설정 관리 자동화
- **Deployment Automation**: 배포 자동화
- **Monitoring Automation**: 모니터링 자동화

</details>

<details>
<summary>💰 비용 최적화 및 운영 전략</summary>

#### 비용 최적화란?

클라우드 리소스 사용을 최적화하여 비용을 절감하는 활동입니다.

#### 비용 최적화 전략

- **Right Sizing**: 적절한 리소스 크기 선택
- **Reserved Instances**: 예약 인스턴스 활용
- **Spot Instances**: 스팟 인스턴스 활용
- **Auto Scaling**: 필요에 따른 자동 조정

#### AWS 비용 최적화

- **Cost Explorer**: 비용 분석 도구
- **Trusted Advisor**: 비용 최적화 권장사항
- **Reserved Instances**: 예약 인스턴스
- **Savings Plans**: 절약 플랜

#### GCP 비용 최적화

- **Billing Reports**: 비용 분석 보고서
- **Recommender**: 비용 최적화 권장사항
- **Committed Use Discounts**: 약정 사용 할인
- **Sustained Use Discounts**: 지속 사용 할인

#### 운영 전략

- **24/7 모니터링**: 24시간 모니터링
- **자동화**: 반복 작업 자동화
- **문서화**: 운영 절차 문서화
- **팀 교육**: 운영팀 역량 강화

</details>


</details>

<details>
<summary>🛠️ 실습 학습</summary>

<details>
<summary>📁 실습 자료 구조</summary>

- **실습 가이드**: `practices/` - 이론적 실습 가이드 (마크다운)
- **실습 코드**: `repos/samples/day3/` - 실제 실행 가능한 코드
- **자동화 스크립트**: `repos/automation/day3/` - 실습 자동화 도구
- **클라우드 스크립트**: `repos/cloud-scripts/` - 클라우드 리소스 관리

</details>

<details>
<summary>🔧 실습 환경 준비</summary>

### 📋 필수 계정 및 도구

#### 필수 계정

- **AWS 계정**: Free Tier 계정
- **GCP 계정**: $300 크레딧 계정
- **GitHub 계정**: 저장소 관리 및 Actions 사용
- **Docker Hub 계정**: 컨테이너 이미지 저장소

#### 필수 도구

- **AWS CLI**: AWS 서비스 관리
- **gcloud CLI**: Google Cloud 서비스 관리
- **Docker**: 컨테이너 이미지 빌드
- **kubectl**: Kubernetes 클러스터 관리 (선택사항)

</details>

<details>
<summary>🔧 실습 가이드</summary>

### 📖 상세 실습 가이드

[📖 상세 실습 가이드](#📖-상세-실습-가이드)
- 🔗 [로드 밸런싱 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/guides/load-balancing-guide.md) - ELB, Cloud Load Balancing 구성
- 🔗 [Auto Scaling 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/guides/auto-scaling-guide.md) - ASG, MIG 자동 확장 설정
- 🔗 [통합 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/guides/integration-guide.md) - 로드 밸런서 + 오토스케일링 연동
- 🔗 [장애 복구 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/guides/disaster-recovery-guide.md) - 장애 시뮬레이션 및 복구

### ⚠️ 실습 주의사항 및 문제 해결

#### 환경 요구사항
- **최소 사양**: 32GB RAM, 200GB 디스크 공간, 16코어 CPU
- **네트워크**: 안정적인 인터넷 연결 (대용량 이미지 다운로드용)
- **OS**: Windows 10/11, macOS 10.15+, Ubuntu 20.04+

#### 자주 발생하는 문제
1. **로드 밸런서 구성 실패**
   - 해결방법: 보안 그룹 규칙 확인, 서브넷 설정 확인
   - 명령어: `aws elbv2 describe-load-balancers`로 상태 확인

2. **Auto Scaling 그룹 생성 실패**
   - 해결방법: 시작 템플릿 확인, IAM 역할 권한 확인
   - 명령어: `aws autoscaling describe-auto-scaling-groups`로 상태 확인

3. **모니터링 알람 설정 실패**
   - 해결방법: CloudWatch 메트릭 확인, SNS 토픽 설정 확인
   - 명령어: `aws cloudwatch describe-alarms`로 알람 상태 확인

4. **장애 복구 테스트 실패**
   - 해결방법: 백업 정책 확인, 복구 절차 검증
   - 명령어: `aws backup describe-backup-job`로 백업 상태 확인

#### 실습 검증 방법
- **로드 밸런싱**: `curl http://로드밸런서DNS`로 트래픽 분산 확인
- **Auto Scaling**: `kubectl get hpa` 또는 `aws autoscaling describe-policies`로 스케일링 확인
- **모니터링**: CloudWatch 대시보드에서 메트릭 확인
- **장애 복구**: 백업 복원 테스트 및 RTO/RPO 측정

### 📚 데모 프로젝트

[📚 데모 프로젝트](#📚-데모-프로젝트)
- 🔗 Actions Demo 프로젝트 - GitHub Actions CI/CD 데모
- 🔗 My App 프로젝트 - Docker 기반 웹 애플리케이션
- 🔗 스크립트 모음 - AWS/GCP 자동화 스크립트

### 🛠️ 문제 해결 가이드

[🛠️ 문제 해결 가이드](#🛠️-문제-해결-가이드)
- 🔗 [트러블슈팅 가이드](/mcp_knowledge_base/cloud_basic/textbook/Day1/troubleshooting-guide.md) - 로드 밸런싱, 오토스케일링, 모니터링 문제 해결

### 🔗 관련 과정 링크

[🔗 관련 과정 링크](#관련-과정-링크)
- 🔗 Cloud Basic 과정 - AWS/GCP 기초 과정
- 🔗 Cloud Container 과정 - Kubernetes 고급 과정
- 🔗 [전체 커리큘럼](/mcp_knowledge_base/curriculum.md) - 전체 과정 구조 및 학습 경로
- 🔗 [통합 인덱스](/mcp_knowledge_base/index.md) - 전체 과정 인덱스
- 🔗 [학습 경로로 돌아가기](/mcp_knowledge_base/learning-path.md) - Cloud Master 학습 경로

---

### 🔧 실습 환경 준비

<details>
<summary>📋 필수 계정 및 도구</summary>

#### 필수 계정

- **AWS 계정**: Free Tier 계정
- **GCP 계정**: $300 크레딧 계정
- **GitHub 계정**: 저장소 관리 및 Actions 사용
- **Docker Hub 계정**: 컨테이너 이미지 저장소

#### 필수 도구

- **AWS CLI**: AWS 서비스 관리
- **gcloud CLI**: Google Cloud 서비스 관리
- **Docker**: 컨테이너 이미지 빌드
- **kubectl**: Kubernetes 클러스터 관리 (선택사항)

</details>

<details>
<summary>🔧 1일차 실습 완료 확인</summary>

#### 필수 완료 사항

- [ ] Docker 고급 기술 및 최적화 완료
- [ ] GitHub Actions 고급 워크플로우 구축
- [ ] VM 기반 컨테이너 배포 자동화
- [ ] 완전 자동화된 CI/CD 파이프라인

### 실습 환경 확인

#### 자동 환경 체크 (권장)
```bash
# 통합 환경 체크 스크립트 실행 (Kubernetes 포함)
./mcp_knowledge_base/cloud_master/repos/cloud-scripts/environment-check.sh day3
```

#### 수동 환경 확인
```bash
# AWS CLI 설정 확인
aws sts get-caller-identity

# gcloud 설정 확인
gcloud auth list

# Docker 설정 확인
docker --version
docker-compose --version
```

#### 환경 체크 결과 해석
- **90% 이상**: 실습 준비 완료 ✅
- **70-89%**: 일부 실습 제한 가능 ⚠️
- **70% 미만**: 환경 설정 필요 ❌
```

</details>

---

<details>
<summary>⚖️ 로드 밸런싱 및 Auto Scaling 실습</summary>

### 📖 실습 개요

#### 실습 구성

[실습 구성](#실습-구성)
1. **로드 밸런싱 및 Auto Scaling** (150분)
2. **컨테이너 모니터링 및 로깅** (120분)
3. **장애 복구 및 운영 자동화** (90분)
4. **비용 최적화 및 운영 전략** (60분)

#### 실습 방식

- **로드 밸런싱**: ELB, Cloud Load Balancing 구성
- **Auto Scaling**: 정책 설정 및 자동 확장 테스트
- **모니터링**: Prometheus, Grafana, CloudWatch
- **장애 복구**: Health Check 기반 자동 교체

#### 실습 결과물

- 로드 밸런서 구성
- Auto Scaling 그룹 설정
- 모니터링 대시보드
- 장애 복구 자동화

</details>

<details>
<summary>🔗 관련 실습 가이드</summary>

### 📖 상세 실습 가이드

[📖 상세 실습 가이드](#📖-상세-실습-가이드)
- 🔗 [로드 밸런싱 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/guides/load-balancing-guide.md) - ELB, Cloud Load Balancing 구성
- 🔗 [Auto Scaling 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/guides/auto-scaling-guide.md) - ASG, MIG 자동 확장 설정
- 🔗 [통합 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/guides/integration-guide.md) - 로드 밸런서 + 오토스케일링 연동
- 🔗 [장애 복구 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/guides/disaster-recovery-guide.md) - 장애 시뮬레이션 및 복구

### 📚 데모 프로젝트

[📚 데모 프로젝트](#📚-데모-프로젝트)
- 🔗 Actions Demo 프로젝트 - GitHub Actions CI/CD 데모
- 🔗 My App 프로젝트 - Docker 기반 웹 애플리케이션
- 🔗 스크립트 모음 - AWS/GCP 자동화 스크립트

### 🛠️ 문제 해결 가이드

[🛠️ 문제 해결 가이드](#🛠️-문제-해결-가이드)
- 🔗 [트러블슈팅 가이드](/mcp_knowledge_base/cloud_basic/textbook/Day1/troubleshooting-guide.md) - 로드 밸런싱, 오토스케일링, 모니터링 문제 해결

### 🔗 관련 과정 링크

[🔗 관련 과정 링크](#관련-과정-링크)
- 🔗 Cloud Basic 과정 - AWS/GCP 기초 과정
- 🔗 Cloud Container 과정 - Kubernetes 고급 과정
- 🔗 [전체 커리큘럼](/mcp_knowledge_base/curriculum.md) - 전체 과정 구조 및 학습 경로
- 🔗 [통합 인덱스](/mcp_knowledge_base/index.md) - 전체 과정 인덱스
- 🔗 [학습 경로로 돌아가기](/mcp_knowledge_base/learning-path.md) - Cloud Master 학습 경로

---

### 🔧 실습 환경 준비

<details>
<summary>📋 필수 계정 및 도구</summary>

#### 필수 계정

- **AWS 계정**: Free Tier 계정
- **GCP 계정**: $300 크레딧 계정
- **GitHub 계정**: 저장소 관리 및 Actions 사용
- **Docker Hub 계정**: 컨테이너 이미지 저장소

#### 필수 도구

- **AWS CLI**: AWS 서비스 관리
- **gcloud CLI**: Google Cloud 서비스 관리
- **Docker**: 컨테이너 이미지 빌드
- **kubectl**: Kubernetes 클러스터 관리 (선택사항)

</details>

<details>
<summary>🔧 1일차 실습 완료 확인</summary>

#### 필수 완료 사항

- [ ] Docker 고급 기술 및 최적화 완료
- [ ] GitHub Actions 고급 워크플로우 구축
- [ ] VM 기반 컨테이너 배포 자동화
- [ ] 완전 자동화된 CI/CD 파이프라인

### 실습 환경 확인

#### 자동 환경 체크 (권장)
```bash
# 통합 환경 체크 스크립트 실행 (Kubernetes 포함)
./mcp_knowledge_base/cloud_master/repos/cloud-scripts/environment-check.sh day3
```

#### 수동 환경 확인
```bash
# AWS CLI 설정 확인
aws sts get-caller-identity

# gcloud 설정 확인
gcloud auth list

# Docker 설정 확인
docker --version
docker-compose --version
```

#### 환경 체크 결과 해석
- **90% 이상**: 실습 준비 완료 ✅
- **70-89%**: 일부 실습 제한 가능 ⚠️
- **70% 미만**: 환경 설정 필요 ❌
```

</details>

---

### 🚀 로드 밸런싱 및 Auto Scaling

<details>
<summary>📖 로드 밸런싱 개념</summary>

#### 로드 밸런싱이란?

- **정의**: 여러 서버에 트래픽을 분산하는 기술
- **목적**: 가용성 향상, 성능 최적화, 장애 복구
- **유형**: Layer 4 (TCP/UDP), Layer 7 (HTTP/HTTPS)

#### AWS ELB vs GCP Cloud Load Balancing

| 구분 | AWS ELB | GCP Cloud Load Balancing |
|------|---------|--------------------------|
| **유형** | ALB, NLB, CLB | HTTP(S), TCP, UDP |
| **대상** | EC2, ECS, Lambda | Compute Engine, GKE |
| **가격** | 시간당 요금 | 시간당 요금 |
| **모니터링** | CloudWatch | Cloud Monitoring |

</details>

<details>
<summary>🔗 AWS ELB 실습</summary>

#### Application Load Balancer 생성

```bash
# VPC ID 확인
VPC_ID=$(aws ec2 describe-vpcs /
    --filters "Name=is-default,Values=true" /
    --query 'Vpcs[0].VpcId' /
    --output text)

# 서브넷 ID 확인
SUBNET_IDS=$(aws ec2 describe-subnets /
    --filters "Name=vpc-id,Values=$VPC_ID" /
    --query 'Subnets[0:2].SubnetId' /
    --output text)

# 보안 그룹 생성
aws ec2 create-security-group /
    --group-name alb-sg /
    --description "Security group for ALB" /
    --vpc-id $VPC_ID

# HTTP/HTTPS 포트 열기
aws ec2 authorize-security-group-ingress /
    --group-name alb-sg /
    --protocol tcp /
    --port 80 /
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress /
    --group-name alb-sg /
    --protocol tcp /
    --port 443 /
    --cidr 0.0.0.0/0

# ALB 생성
aws elbv2 create-load-balancer /
    --name my-app-alb /
    --subnets $SUBNET_IDS /
    --security-groups $ALB_SG_ID /
    --scheme internet-facing /
    --type application
```

#### Target Group 생성

```bash
# Target Group 생성
aws elbv2 create-target-group /
    --name my-app-targets /
    --protocol HTTP /
    --port 3000 /
    --vpc-id $VPC_ID /
    --target-type instance /
    --health-check-path /health /
    --health-check-interval-seconds 30 /
    --health-check-timeout-seconds 5 /
    --healthy-threshold-count 2 /
    --unhealthy-threshold-count 3

# Target Group에 인스턴스 등록
aws elbv2 register-targets /
    --target-group-arn $TARGET_GROUP_ARN /
    --targets Id=$INSTANCE_ID_1,Port=3000 Id=$INSTANCE_ID_2,Port=3000
```

</details>

<details>
<summary>🔗 GCP Cloud Load Balancing 실습</summary>

#### HTTP(S) Load Balancer 생성

[HTTP(S) Load Balancer 생성](#https-load-balancer-생성)-load-balancer)-load-balancer-생성)
```bash
# 백엔드 서비스 생성
gcloud compute backend-services create my-app-backend /
    --protocol=HTTP /
    --port-name=http /
    --health-checks=my-app-health-check /
    --global

# 인스턴스 그룹 생성
gcloud compute instance-groups unmanaged create my-app-group /
    --zone=asia-northeast3-a

# 인스턴스를 그룹에 추가
gcloud compute instance-groups unmanaged add-instances my-app-group /
    --instances=my-app-instance-1,my-app-instance-2 /
    --zone=asia-northeast3-a

# 백엔드 서비스에 인스턴스 그룹 추가
gcloud compute backend-services add-backend my-app-backend /
    --instance-group=my-app-group /
    --instance-group-zone=asia-northeast3-a /
    --global

# URL 맵 생성
gcloud compute url-maps create my-app-map /
    --default-service=my-app-backend

# HTTP 프록시 생성
gcloud compute target-http-proxies create my-app-proxy /
    --url-map=my-app-map

# 전역 포워딩 규칙 생성
gcloud compute forwarding-rules create my-app-rule /
    --global /
    --target-http-proxy=my-app-proxy /
    --ports=80
```

</details>

<details>
<summary>🔗 Auto Scaling 실습</summary>

### AWS Auto Scaling Group

[AWS Auto Scaling Group](#aws-auto-scaling-group)
```bash
# Launch Template 생성
aws ec2 create-launch-template /
    --launch-template-name my-app-template /
    --launch-template-data '{
        "ImageId": "ami-0ae2c887094315bed",
        "InstanceType": "t3.micro",
        "SecurityGroupIds": ["'$WEB_SG_ID'"],
        "UserData": "'$(base64 -w 0 user-data.sh)'"
    }'

# Auto Scaling Group 생성
aws autoscaling create-auto-scaling-group /
    --auto-scaling-group-name my-app-asg /
    --launch-template LaunchTemplateName=my-app-template,Version=1 /
    --min-size 1 /
    --max-size 5 /
    --desired-capacity 2 /
    --target-group-arns $TARGET_GROUP_ARN /
    --health-check-type ELB /
    --health-check-grace-period 300

# 스케일링 정책 생성
aws autoscaling put-scaling-policy /
    --auto-scaling-group-name my-app-asg /
    --policy-name my-app-scale-out /
    --policy-type TargetTrackingScaling /
    --target-tracking-configuration '{
        "TargetValue": 70.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ASGAverageCPUUtilization"
        }
    }'
```

### GCP Managed Instance Group

[GCP Managed Instance Group](#gcp-managed-instance-group)
```bash
# 인스턴스 템플릿 생성
gcloud compute instance-templates create my-app-template /
    --machine-type=e2-micro /
    --image-family=ubuntu-2004-lts /
    --image-project=ubuntu-os-cloud /
    --boot-disk-size=10GB /
    --tags=http-server /
    --metadata-from-file startup-script=startup-script.sh

# Managed Instance Group 생성
gcloud compute instance-groups managed create my-app-mig /
    --template=my-app-template /
    --size=2 /
    --zone=asia-northeast3-a

# Auto Scaling 정책 설정
gcloud compute instance-groups managed set-autoscaling my-app-mig /
    --zone=asia-northeast3-a /
    --max-num-replicas=5 /
    --min-num-replicas=1 /
    --target-cpu-utilization=0.7
```

</details>

</details>

<details>
<summary>📊 컨테이너 모니터링 및 로깅 실습</summary>

### 📖 모니터링 개념

### 모니터링의 3가지 기둥

!Monitoring Pillars

[모니터링의 3가지 기둥](#모니터링의-3가지-기둥)
- **메트릭**: CPU, 메모리, 네트워크 사용량
- **로그**: 애플리케이션 로그, 시스템 로그
- **트레이스**: 요청 추적, 성능 분석

### 모니터링 도구 비교

[모니터링 도구 비교](#모니터링-도구-비교)
| 구분 | AWS | GCP | 오픈소스 |
|------|-----|-----|----------|
| **메트릭** | CloudWatch | Cloud Monitoring | Prometheus |
| **로그** | CloudWatch Logs | Cloud Logging | ELK Stack |
| **트레이스** | X-Ray | Cloud Trace | Jaeger |

</details>

<details>
<summary>🔗 AWS CloudWatch 실습</summary>

### CloudWatch 메트릭 설정

#### 1단계: CloudWatch 기본 설정
```bash
# AWS CLI 설정 확인
aws sts get-caller-identity

# CloudWatch 서비스 상태 확인
aws cloudwatch describe-alarms --max-items 5

# 기본 메트릭 확인
aws cloudwatch list-metrics --namespace AWS/EC2
```

#### 2단계: 커스텀 메트릭 전송
```bash
# 커스텀 메트릭 전송
aws cloudwatch put-metric-data /
    --namespace "MyApp/ECS" /
    --metric-data MetricName=RequestCount,Value=100,Unit=Count

# 여러 메트릭 동시 전송
aws cloudwatch put-metric-data /
    --namespace "MyApp/ECS" /
    --metric-data /
        MetricName=RequestCount,Value=150,Unit=Count /
        MetricName=ResponseTime,Value=250,Unit=Milliseconds /
        MetricName=ErrorRate,Value=0.05,Unit=Percent
```

#### 3단계: CloudWatch 대시보드 생성
```bash
# 대시보드 JSON 파일 생성
cat > dashboard.json << 'EOF'
{
        "widgets": [
            {
                "type": "metric",
                "properties": {
                    "metrics": [
                        ["AWS/EC2", "CPUUtilization", "InstanceId", "i-1234567890abcdef0"]
                    ],
                    "period": 300,
                    "stat": "Average",
                    "region": "ap-northeast-2",
                    "title": "EC2 CPU Utilization"
                }
        },
        {
            "type": "metric",
            "properties": {
                "metrics": [
                    ["AWS/EC2", "NetworkIn", "InstanceId", "i-1234567890abcdef0"],
                    ["AWS/EC2", "NetworkOut", "InstanceId", "i-1234567890abcdef0"]
                ],
                "period": 300,
                "stat": "Sum",
                "region": "ap-northeast-2",
                "title": "Network Traffic"
            }
        }
    ]
}
EOF

# 대시보드 생성
aws cloudwatch put-dashboard /
    --dashboard-name "MyApp-Dashboard" /
    --dashboard-body file://dashboard.json
```

#### 4단계: 대시보드 확인 및 관리

!CloudWatch Dashboard

```bash
# 대시보드 목록 확인
aws cloudwatch list-dashboards

# 특정 대시보드 정보 확인
aws cloudwatch get-dashboard --dashboard-name "MyApp-Dashboard"

# 대시보드 삭제
aws cloudwatch delete-dashboards --dashboard-names "MyApp-Dashboard"
```

### CloudWatch 알람 설정

[CloudWatch 알람 설정](#cloudwatch-알람-설정)
```bash
# CPU 사용률 알람 생성
aws cloudwatch put-metric-alarm /
    --alarm-name "High CPU Utilization" /
    --alarm-description "Alarm when CPU exceeds 80%" /
    --metric-name CPUUtilization /
    --namespace AWS/EC2 /
    --statistic Average /
    --period 300 /
    --threshold 80.0 /
    --comparison-operator GreaterThanThreshold /
    --evaluation-periods 2
```

</details>

<details>
<summary>🔗 GCP Cloud Monitoring 실습</summary>

### Cloud Monitoring 설정

[Cloud Monitoring 설정](#cloud-monitoring-설정)
```bash
# 커스텀 메트릭 생성
gcloud monitoring metrics-descriptors create /
    --display-name="Request Count" /
    --type="custom.googleapis.com/myapp/request_count" /
    --metric-kind="GAUGE" /
    --value-type="INT64"

# 알림 정책 생성
gcloud alpha monitoring policies create /
    --policy-from-file=alert-policy.yaml
```

### Prometheus + Grafana 설정

[Prometheus + Grafana 설정](#prometheus-grafana-설정)
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'my-app'
    static_configs:
      - targets: ['my-app:3000']
    metrics_path: /metrics
    scrape_interval: 5s
```

### 🔧 모니터링 도구 설정 가이드 상세화

#### 1. Prometheus 고급 설정

**Prometheus 서버 설정**
```yaml
# prometheus-server.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
      external_labels:
        cluster: 'cloud-master'
        environment: 'production'
    
    rule_files:
      - "/etc/prometheus/rules/*.yml"
    
    alerting:
      alertmanagers:
        - static_configs:
            - targets:
              - alertmanager:9093
    
    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090']
      
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
            action: keep
            regex: true
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
            action: replace
            target_label: __metrics_path__
            regex: (.+)
          - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
            action: replace
            regex: ([^:]+)(?::/d+)?;(/d+)
            replacement: $1:$2
            target_label: __address__
          - action: labelmap
            regex: __meta_kubernetes_pod_label_(.+)
          - source_labels: [__meta_kubernetes_namespace]
            action: replace
            target_label: kubernetes_namespace
          - source_labels: [__meta_kubernetes_pod_name]
            action: replace
            target_label: kubernetes_pod_name
      
      - job_name: 'kubernetes-nodes'
        kubernetes_sd_configs:
          - role: node
        relabel_configs:
          - action: labelmap
            regex: __meta_kubernetes_node_label_(.+)
          - target_label: __address__
            replacement: kubernetes.default.svc:443
          - source_labels: [__meta_kubernetes_node_name]
            regex: (.+)
            target_label: __metrics_path__
            replacement: /api/v1/nodes/${1}/proxy/metrics
```

**Prometheus 서버 배포**
```yaml
# prometheus-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
      - name: prometheus
        image: prom/prometheus:v2.45.0
        args:
          - '--config.file=/etc/prometheus/prometheus.yml'
          - '--storage.tsdb.path=/prometheus/'
          - '--web.console.libraries=/etc/prometheus/console_libraries'
          - '--web.console.templates=/etc/prometheus/consoles'
          - '--storage.tsdb.retention.time=200h'
          - '--web.enable-lifecycle'
        ports:
        - containerPort: 9090
        volumeMounts:
        - name: prometheus-config-volume
          mountPath: /etc/prometheus/
        - name: prometheus-storage-volume
          mountPath: /prometheus/
      volumes:
      - name: prometheus-config-volume
        configMap:
          defaultMode: 420
          name: prometheus-config
      - name: prometheus-storage-volume
        emptyDir: {}
```

#### 2. Grafana 고급 설정

**Grafana 대시보드 설정**
```yaml
# grafana-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:10.0.0
        ports:
        - containerPort: 3000
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: "admin123"
        - name: GF_USERS_ALLOW_SIGN_UP
          value: "false"
        volumeMounts:
        - name: grafana-storage
          mountPath: /var/lib/grafana
        - name: grafana-datasources
          mountPath: /etc/grafana/provisioning/datasources
        - name: grafana-dashboards
          mountPath: /etc/grafana/provisioning/dashboards
      volumes:
      - name: grafana-storage
        emptyDir: {}
      - name: grafana-datasources
        configMap:
          name: grafana-datasources
      - name: grafana-dashboards
        configMap:
          name: grafana-dashboards
```

**Grafana 데이터소스 설정**
```yaml
# grafana-datasources.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-datasources
  namespace: monitoring
data:
  datasources.yaml: |
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      access: proxy
      url: http://prometheus:9090
      isDefault: true
      editable: true
    - name: CloudWatch
      type: cloudwatch
      access: proxy
      jsonData:
        authType: keys
        defaultRegion: ap-northeast-2
      secureJsonData:
        accessKey: ${AWS_ACCESS_KEY_ID}
        secretKey: ${AWS_SECRET_ACCESS_KEY}
```

#### 3. AlertManager 설정

**AlertManager 구성**
```yaml
# alertmanager-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: alertmanager-config
  namespace: monitoring
data:
  alertmanager.yml: |
    global:
      smtp_smarthost: 'localhost:587'
      smtp_from: 'alerts@cloud-master.com'
    
    route:
      group_by: ['alertname']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 1h
      receiver: 'web.hook'
      routes:
      - match:
          severity: critical
        receiver: 'critical-alerts'
      - match:
          severity: warning
        receiver: 'warning-alerts'
    
    receivers:
    - name: 'web.hook'
      webhook_configs:
      - url: 'http://webhook:5001/'
    
    - name: 'critical-alerts'
      email_configs:
      - to: 'admin@cloud-master.com'
        subject: 'Critical Alert: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}
    
    - name: 'warning-alerts'
      email_configs:
      - to: 'team@cloud-master.com'
        subject: 'Warning Alert: {{ .GroupLabels.alertname }}'
```

#### 4. 커스텀 메트릭 수집

**애플리케이션 메트릭 노출**
```javascript
// Node.js 애플리케이션 예제
const express = require('express');
const client = require('prom-client');

const app = express();

// 메트릭 레지스트리 생성
const register = new client.Registry();

// 기본 메트릭 수집
client.collectDefaultMetrics({ register });

// 커스텀 메트릭 정의
const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10]
});

const httpRequestTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

const activeConnections = new client.Gauge({
  name: 'active_connections',
  help: 'Number of active connections'
});

// 메트릭을 레지스트리에 등록
register.registerMetric(httpRequestDuration);
register.registerMetric(httpRequestTotal);
register.registerMetric(activeConnections);

// 미들웨어로 메트릭 수집
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const labels = {
      method: req.method,
      route: req.route ? req.route.path : req.path,
      status_code: res.statusCode
    };
    
    httpRequestDuration.observe(labels, duration);
    httpRequestTotal.inc(labels);
  });
  
  next();
});

// 메트릭 엔드포인트
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// 헬스체크 엔드포인트
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
```

#### 5. 로그 수집 및 분석

**ELK Stack 설정**
```yaml
# elasticsearch-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: elasticsearch
  namespace: logging
spec:
  replicas: 1
  selector:
    matchLabels:
      app: elasticsearch
  template:
    metadata:
      labels:
        app: elasticsearch
    spec:
      containers:
      - name: elasticsearch
        image: docker.elastic.co/elasticsearch/elasticsearch:8.8.0
        env:
        - name: discovery.type
          value: single-node
        - name: ES_JAVA_OPTS
          value: "-Xms512m -Xmx512m"
        ports:
        - containerPort: 9200
        volumeMounts:
        - name: elasticsearch-storage
          mountPath: /usr/share/elasticsearch/data
      volumes:
      - name: elasticsearch-storage
        emptyDir: {}
```

**Fluentd 로그 수집기**
```yaml
# fluentd-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
  namespace: logging
data:
  fluent.conf: |
    <source>
      @type tail
      path /var/log/containers/*.log
      pos_file /var/log/fluentd-containers.log.pos
      tag kubernetes.*
      format json
      time_key time
      time_format %Y-%m-%dT%H:%M:%S.%NZ
    </source>
    
    <filter kubernetes.**>
      @type kubernetes_metadata
    </filter>
    
    <match kubernetes.**>
      @type elasticsearch
      host elasticsearch.logging.svc.cluster.local
      port 9200
      index_name kubernetes
      type_name _doc
    </match>
```

#### 6. 모니터링 대시보드 설정

**Kubernetes 대시보드**
```yaml
# kubernetes-dashboard.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kubernetes-dashboard
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: kubernetes-dashboard
  namespace: kube-system
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kubernetes-dashboard
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kubernetes-dashboard
  template:
    metadata:
      labels:
        app: kubernetes-dashboard
    spec:
      serviceAccountName: kubernetes-dashboard
      containers:
      - name: kubernetes-dashboard
        image: kubernetesui/dashboard:v2.7.0
        ports:
        - containerPort: 9090
        args:
        - --auto-generate-certificates
        - --namespace=kubernetes-dashboard
```

#### 7. 모니터링 알림 설정

**Slack 알림 설정**
```yaml
# slack-alerts.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: slack-alerts
  namespace: monitoring
data:
  slack-alerts.yml: |
    global:
      slack_api_url: 'https:///hooks.slack.com/services/YOUR/SLACK/WEBHOOK'
    
    route:
      group_by: ['alertname', 'cluster', 'service']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 1h
      receiver: 'slack-notifications'
      routes:
      - match:
          severity: critical
        receiver: 'slack-critical'
      - match:
          severity: warning
        receiver: 'slack-warning'
    
    receivers:
    - name: 'slack-notifications'
      slack_configs:
      - channel: '#alerts'
        title: 'Cloud Master Alert'
        text: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'
    
    - name: 'slack-critical'
      slack_configs:
      - channel: '#critical-alerts'
        title: '🚨 Critical Alert'
        text: |
          {{ range .Alerts }}
          *Alert:* {{ .Annotations.summary }}
          *Description:* {{ .Annotations.description }}
          *Severity:* {{ .Labels.severity }}
          {{ end }}
    
    - name: 'slack-warning'
      slack_configs:
      - channel: '#warning-alerts'
        title: '⚠️ Warning Alert'
        text: |
          {{ range .Alerts }}
          *Alert:* {{ .Annotations.summary }}
          *Description:* {{ .Annotations.description }}
          {{ end }}
```

#### 8. 성능 모니터링 및 최적화

**애플리케이션 성능 모니터링**
```yaml
# apm-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: apm-config
  namespace: monitoring
data:
  apm.yml: |
    # APM (Application Performance Monitoring) 설정
    apm:
      enabled: true
      server:
        host: "0.0.0.0"
        port: 8200
      secret_token: "your-secret-token"
      api_key: "your-api-key"
    
    # 트레이스 수집 설정
    traces:
      enabled: true
      sampling_rate: 0.1  # 10% 샘플링
    
    # 메트릭 수집 설정
    metrics:
      enabled: true
      interval: 30s
    
    # 로그 수집 설정
    logs:
      enabled: true
      level: info
```

**리소스 사용량 모니터링**
```bash
# cAdvisor를 통한 컨테이너 메트릭 수집
kubectl apply -f https:///raw.githubusercontent.com/google/cadvisor/master/deploy/kubernetes/cadvisor-daemonset.yaml

# Node Exporter를 통한 노드 메트릭 수집
kubectl apply -f https:///raw.githubusercontent.com/prometheus/node_exporter/master/examples/k8s-daemonset.yaml

# kube-state-metrics를 통한 Kubernetes 메트릭 수집
kubectl apply -f https:///raw.githubusercontent.com/kubernetes/kube-state-metrics/master/examples/standard/kube-state-metrics.yaml
```

</details>

</details>

<details>
<summary>🔄 장애 복구 및 운영 자동화 실습</summary>

### 📖 장애 복구 전략

### Health Check 기반 복구

[Health Check 기반 복구](#health-check-기반-복구)
- **Health Check**: 애플리케이션 상태 확인
- **자동 교체**: 장애 인스턴스 자동 교체
- **롤링 업데이트**: 무중단 배포

### 복구 시간 목표 (RTO)

[복구 시간 목표 (RTO)](#복구-시간-목표-rto)))
- **RTO**: Recovery Time Objective (복구 시간 목표)
- **RPO**: Recovery Point Objective (복구 지점 목표)
- **SLA**: Service Level Agreement (서비스 수준 협약)

</details>

<details>
<summary>🔗 Health Check 설정</summary>

### AWS ELB Health Check

[AWS ELB Health Check](#aws-elb-health-check)
```bash
# Target Group Health Check 설정
aws elbv2 modify-target-group /
    --target-group-arn $TARGET_GROUP_ARN /
    --health-check-path /health /
    --health-check-interval-seconds 30 /
    --health-check-timeout-seconds 5 /
    --healthy-threshold-count 2 /
    --unhealthy-threshold-count 3
```

### GCP Health Check

[GCP Health Check](#gcp-health-check)
```bash
# Health Check 생성
gcloud compute health-checks create http my-app-health-check /
    --port=3000 /
    --request-path=/health /
    --check-interval=30s /
    --timeout=5s /
    --unhealthy-threshold=3 /
    --healthy-threshold=2
```

</details>

<details>
<summary>🔗 자동 복구 구현</summary>

### AWS Auto Recovery

[AWS Auto Recovery](#aws-auto-recovery)
```bash
# Auto Recovery 설정
aws ec2 modify-instance-attribute /
    --instance-id $INSTANCE_ID /
    --source-dest-check Value=false

# CloudWatch 알람으로 Auto Recovery
aws cloudwatch put-metric-alarm /
    --alarm-name "Instance Status Check Failed" /
    --alarm-description "Alarm when instance status check fails" /
    --metric-name StatusCheckFailed /
    --namespace AWS/EC2 /
    --statistic Maximum /
    --period 60 /
    --threshold 1.0 /
    --comparison-operator GreaterThanOrEqualToThreshold /
    --evaluation-periods 2 /
    --alarm-actions arn:aws:automate:region:ec2:recover
```

### GCP Auto Healing

[GCP Auto Healing](#gcp-auto-healing)
```bash
# Auto Healing 설정
gcloud compute instance-groups managed set-autohealing my-app-mig /
    --zone=asia-northeast3-a /
    --health-check=my-app-health-check /
    --initial-delay=300s
```

</details>

</details>

<details>
<summary>💰 비용 최적화 및 운영 전략 실습</summary>

### 📖 비용 최적화 전략

### AWS 비용 최적화

[AWS 비용 최적화](#aws-비용-최적화)
- **Reserved Instances**: 1-3년 약정으로 최대 75% 할인
- **Spot Instances**: 미사용 인스턴스 활용으로 최대 90% 할인
- **Auto Scaling**: 필요에 따른 자동 확장/축소

### GCP 비용 최적화

[GCP 비용 최적화](#gcp-비용-최적화)
- **Committed Use Discounts**: 1-3년 약정으로 최대 70% 할인
- **Preemptible Instances**: 단기 작업용으로 최대 80% 할인
- **Sustained Use Discounts**: 장기 사용 시 자동 할인

</details>

<details>
<summary>🔗 비용 모니터링 설정</summary>

### AWS Cost Explorer

[AWS Cost Explorer](#aws-cost-explorer)
```bash
# 비용 및 사용량 보고서 활성화
aws ce create-cost-category-definition /
    --name "Environment" /
    --rules '[
        {
            "Value": "Production",
            "Rule": {
                "Dimensions": {
                    "Key": "TAG",
                    "Values": ["Environment=Production"]
                }
            }
        }
    ]'
```

### GCP Billing 알림

[GCP Billing 알림](#gcp-billing-알림)
```bash
# 예산 알림 설정
gcloud billing budgets create /
    --billing-account=BILLING_ACCOUNT_ID /
    --display-name="My App Budget" /
    --budget-amount=100USD /
    --threshold-rule=percent=50 /
    --threshold-rule=percent=90 /
    --threshold-rule=percent=100
```

</details>

</details>


<details>
<summary>📚 문제 해결 및 참고 자료</summary>

### 📊 학습 평가 기준

#### 실습 완료 기준
1. **로드 밸런싱 실습 (25점)**
   - ✅ ELB/Cloud Load Balancing 구성 (10점)
   - ✅ 헬스 체크 및 라우팅 설정 (10점)
   - ✅ SSL/TLS 인증서 설정 (5점)

2. **Auto Scaling 실습 (25점)**
   - ✅ ASG/MIG 구성 및 정책 설정 (15점)
   - ✅ 스케일링 메트릭 및 알람 설정 (10점)

3. **모니터링 및 로깅 실습 (25점)**
   - ✅ CloudWatch/Cloud Monitoring 설정 (15점)
   - ✅ 대시보드 및 알람 구성 (10점)

4. **장애 복구 및 운영 자동화 실습 (25점)**
   - ✅ 백업 및 복구 절차 구현 (15점)
   - ✅ 운영 자동화 스크립트 작성 (10점)

#### 학습 목표 달성 평가
- **90점 이상**: 모든 운영 목표 달성, 시니어 엔지니어 수준
- **80-89점**: 운영 목표 달성, 실무 운영 가능
- **70-79점**: 기본 운영 목표 달성, 추가 학습 권장
- **70점 미만**: 중급 개념 재학습 필요

#### 실습 결과물 제출
1. **로드 밸런서 구성**: ELB/Cloud Load Balancing 설정 및 테스트 결과
2. **Auto Scaling 설정**: ASG/MIG 구성 및 스케일링 테스트 결과
3. **모니터링 대시보드**: CloudWatch/Cloud Monitoring 대시보드 스크린샷
4. **장애 복구 계획**: 백업 정책 및 복구 절차 문서

### 📖 용어 사전

#### 로드 밸런싱 용어
- **로드 밸런서(Load Balancer)**: 트래픽을 여러 서버에 분산하는 장치
- **헬스 체크(Health Check)**: 서버 상태를 주기적으로 확인하는 기능
- **스티키 세션(Sticky Session)**: 클라이언트를 특정 서버에 고정하는 기능
- **SSL 터미네이션(SSL Termination)**: 로드 밸런서에서 SSL 암호화를 해제하는 기능

#### Auto Scaling 용어
- **오토 스케일링 그룹(ASG)**: 자동으로 인스턴스를 관리하는 그룹
- **스케일링 정책(Scaling Policy)**: 스케일링 조건과 동작을 정의하는 정책
- **쿨다운(Cooldown)**: 스케일링 동작 후 대기하는 시간
- **스케일링 메트릭(Scaling Metric)**: 스케일링 판단 기준이 되는 지표

#### 모니터링 용어
- **메트릭(Metric)**: 시스템 상태를 나타내는 수치 데이터
- **알람(Alarm)**: 특정 조건에서 발생하는 알림
- **대시보드(Dashboard)**: 여러 메트릭을 한눈에 보는 화면
- **로그(Log)**: 시스템 동작 기록

#### 장애 복구 용어
- **RTO(Recovery Time Objective)**: 장애 발생 후 서비스 복구까지의 목표 시간
- **RPO(Recovery Point Objective)**: 장애 발생 시점에서 데이터 손실 허용 범위
- **백업(Backup)**: 데이터의 복사본을 만드는 작업
- **복구(Recovery)**: 백업에서 원본 상태로 복원하는 작업

</details>

<details>
<summary>🐛 자주 발생하는 문제</summary>

### 로드 밸런싱 관련 문제

[로드 밸런싱 관련 문제](#로드-밸런싱-관련-문제)
<details>
<summary>❌ 로드 밸런서에서 502 오류</summary>

**원인**: 
- Target Group에 인스턴스가 없음
- Health Check 실패
- 보안 그룹 설정 문제

**해결방법**:
```bash
# 1. Target Group 상태 확인
aws elbv2 describe-target-health --target-group-arn $TARGET_GROUP_ARN

# 2. Health Check 설정 확인
aws elbv2 describe-target-groups --target-group-arns $TARGET_GROUP_ARN

# 3. 보안 그룹 규칙 확인
aws ec2 describe-security-groups --group-ids $WEB_SG_ID
```

</details>

<details>
<summary>❌ Auto Scaling이 작동하지 않음</summary>

**원인**:
- 스케일링 정책 설정 오류
- CloudWatch 메트릭 부족
- 권한 문제

**해결방법**:
```bash
# 1. Auto Scaling Group 상태 확인
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names my-app-asg

# 2. 스케일링 정책 확인
aws autoscaling describe-policies --auto-scaling-group-name my-app-asg

# 3. CloudWatch 메트릭 확인
aws cloudwatch get-metric-statistics /
    --namespace AWS/EC2 /
    --metric-name CPUUtilization /
    --dimensions Name=AutoScalingGroupName,Value=my-app-asg /
    --start-time 2023-01-01T00:00:00Z /
    --end-time 2023-01-01T23:59:59Z /
    --period 300 /
    --statistics Average
```

</details>

</details>

<details>
<summary>📖 추가 학습 자료</summary>

### 공식 문서

[공식 문서](#공식-문서)
- [AWS ELB 공식 문서](https:///docs.aws.amazon.com/elasticloadbalancing/)
- [GCP Cloud Load Balancing 공식 문서](https:///cloud.google.com/load-balancing/docs)
- [AWS Auto Scaling 공식 문서](https:///docs.aws.amazon.com/autoscaling/)
- [GCP Auto Scaling 공식 문서](https:///cloud.google.com/compute/docs/autoscaler)

### 유용한 리소스

[유용한 리소스](#유용한-리소스)
- [AWS Well-Architected Framework](https:///aws.amazon.com/architecture/well-architected/)
- [GCP Architecture Center](https:///cloud.google.com/architecture)
- [Prometheus 공식 문서](https:///prometheus.io/docs/)
- [Grafana 공식 문서](https:///grafana.com/docs/)

### 관련 프로젝트

[관련 프로젝트](#관련-프로젝트)
- [AWS 샘플 프로젝트](https:///github.com/aws-samples)
- [GCP 샘플 프로젝트](https:///github.com/GoogleCloudPlatform)

</details>

<details>
<summary>🚀 다음 단계</summary>

### Cloud Container 과정 준비

[Cloud Container 과정 준비](#cloud-container-과정-준비)
1. **Kubernetes**: 컨테이너 오케스트레이션
2. **GKE**: Google Kubernetes Engine
3. **ECS/Fargate**: AWS 서버리스 컨테이너
4. **고가용성**: Multi-AZ, Multi-Region

### 실무 적용

[실무 적용](#실무-적용)
1. **실제 프로젝트**: 자신의 프로젝트에 고급 기능 적용
2. **모니터링**: 종합적인 모니터링 시스템 구축
3. **자동화**: 완전 자동화된 운영 환경
4. **비용 최적화**: 지속적인 비용 최적화

</details>


</details>

<details>
<summary>🧹 실습 정리</summary>

### 자동 정리 (권장)
```bash
# Day3 실습 자동 정리
./mcp_knowledge_base/cloud_master/repos/automation/day3/monitoring-practice-automation.sh --cleanup

# 또는 수동 정리
kubectl delete namespace monitoring 2>/dev/null || true
docker-compose down -v 2>/dev/null || true
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true
docker system prune -f
```

### 정리 확인
- [ ] 모니터링 리소스 정리
- [ ] Kubernetes 리소스 정리
- [ ] 모든 컨테이너 중지 및 삭제
- [ ] 사용하지 않는 이미지 정리
- [ ] Docker 볼륨 정리

</details>

<details>
<summary>📚 학습 요약</summary>

[📚 학습 요약](#📚-학습-요약)

이번 실습을 통해 다음을 배웠습니다:

1. **⚖️ 로드 밸런싱**: ELB, Cloud Load Balancing 구성
2. **📈 Auto Scaling**: 자동 확장 및 축소 정책
3. **📊 모니터링**: CloudWatch, Cloud Monitoring 설정
4. **🔄 장애 복구**: Health Check 기반 자동 복구

</details>

<details>
<summary>📚 관련 가이드 문서</summary>

### 로드 밸런싱 및 Auto Scaling
- 🔗 [로드 밸런싱 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/guides/load-balancing-guide.md) - ELB, Cloud Load Balancing 구성
- 🔗 [Auto Scaling 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/guides/auto-scaling-guide.md) - ASG, MIG 자동 확장 설정
- 🔗 [통합 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/guides/integration-guide.md) - 로드 밸런서 + 오토스케일링 연동

### 컨테이너 모니터링 및 로깅
- 🔗 [모니터링 설정 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/guides/monitoring-setup-guide.md) - Prometheus, Grafana 고급 설정
- 🔗 [고급 모니터링 설정](/mcp_knowledge_base/cloud_container/textbook/Day1/guides/monitoring-advanced/prometheus-config.yaml) - YAML 설정 파일
- 🔗 [ELK Stack 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/guides/monitoring-setup-guide.md) - 로그 수집 및 분석

### 장애 복구 및 운영 자동화
- 🔗 [장애 복구 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/guides/disaster-recovery-guide.md) - 장애 시뮬레이션 및 복구
- 🔗 [운영 자동화 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/guides/auto-scaling-guide.md) - 자동화 스크립트

### 비용 최적화 및 운영 전략
- 🔗 [비용 최적화 가이드](/mcp_knowledge_base/cloud_container/textbook/Day1/cost-optimization-guide.md) - 클라우드 비용 최적화
- 🔗 [비용 최적화 상세 가이드](/mcp_knowledge_base/cloud_master/textbook/Day3/practices/cost-optimization.md) - 비용 분석 도구

### 실습 프로젝트
- 🔗 [My App 프로젝트](/mcp_knowledge_base/cloud_master/repos/samples/day1/my-app/.dockerignore) - 고가용성 웹 애플리케이션
- 🔗 [Actions Demo 프로젝트](/mcp_knowledge_base/cloud_master/repos/samples/day2/actions-demo/README.md) - 고급 CI/CD 파이프라인

### 자동화 스크립트
- 🔗 [AWS 설정 스크립트](/mcp_knowledge_base/cloud_master/repos/cloud-scripts/aws-ec2-create.sh) - 고가용성 AWS 리소스 생성
- 🔗 [GCP 설정 스크립트](/mcp_knowledge_base/cloud_master/repos/cloud-scripts/aws-ec2-create.sh) - 고가용성 GCP 리소스 생성
- 🔗 [프로젝트 설정 가이드](/mcp_knowledge_base/cloud_master/repos/cloud-scripts/PROJECT_SETUP.md) - 전체 환경 설정

### 문제 해결
- 🔗 [트러블슈팅 가이드](/mcp_knowledge_base/cloud_basic/textbook/Day1/troubleshooting-guide.md) - 운영 환경 문제 해결

</details>


## 🎉 완료!

**축하합니다! Cloud Master 3일차를 완료했습니다.**

**🎯 이제 Cloud Master 과정을 모두 완료하였습니다.**

**🎯 이제 고급 클라우드 운영 기술을 갖추었습니다! Cloud Container 과정으로 진행하세요.**

### 🚀 다음 단계

- [**Cloud Container 과정**](cloud_container/README.md): Kubernetes, ECS, Fargate
- **실제 프로젝트 적용**: 자신의 프로젝트에 고급 기능 적용
- **고급 기능 학습**: 서비스 메시, 보안, 성능 최적화

### 💡 추가 학습 자료

[💡 추가 학습 자료](#💡-추가-학습-자료)

- [AWS ELB 공식 문서](https:///docs.aws.amazon.com/elasticloadbalancing/)
- [GCP Cloud Load Balancing 공식 문서](https:///cloud.google.com/load-balancing/docs)


---

<div align="center">

[← 이전: Cloud Master 메인](cloud_master/README.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🏠 학습 경로로 돌아가기](/mcp_knowledge_base/index.md) | [📋 학습 경로](/mcp_knowledge_base/learning-path.md)

</div>