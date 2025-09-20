# Cloud Container - 2일차: 고가용성 및 확장성 아키텍처 이론 및 실습

<details>
<summary>📋 목차</summary>

## 📚 이론 학습

[📚 이론 학습](#이론-학습)
1. [🎯 학습 목표](#학습-목표)
2. [🏗️ 고가용성 아키텍처 설계](#고가용성-아키텍처-설계)
3. [📊 모니터링 및 로깅 시스템](#모니터링-및-로깅-시스템)
4. [🔄 자동 복구 및 운영 자동화](#자동-복구-및-운영-자동화)
5. [💰 비용 최적화 전략](#비용-최적화-전략)

## 🛠️ 실습 학습

[🛠️ 실습 학습](#실습-학습)
6. [🔧 실습 환경 준비](#실습-환경-준비)
7. [🏗️ 고가용성 아키텍처 실습](#고가용성-아키텍처-실습)
8. [📊 모니터링 및 로깅 시스템 실습](#모니터링-및-로깅-시스템-실습)
9. [🔄 자동 복구 및 운영 자동화 실습](#자동-복구-및-운영-자동화-실습)
10. [💰 비용 최적화 전략 실습](#비용-최적화-전략-실습)

## 📚 참고 자료

[📚 참고 자료](#참고-자료)
11. [📚 문제 해결 및 참고 자료](#문제-해결-및-참고-자료)

</details>

---

## 🎯 학습 목표

### 핵심 학습 목표

[핵심 학습 목표](#핵심-학습-목표)
- **고가용성 아키텍처** Multi-AZ, Multi-Region 설계 및 구현
- **로드 밸런싱** ELB, Cloud Load Balancing 고급 구성
- **Auto Scaling** 정책 및 메트릭 기반 확장
- **모니터링 및 로깅** CloudWatch, Cloud Monitoring 고급 설정

### 실습 후 달성할 수 있는 능력

[실습 후 달성할 수 있는 능력](#실습-후-달성할-수-있는-능력)
- ✅ Multi-AZ/Multi-Region 고가용성 아키텍처 구성
- ✅ 고급 로드 밸런싱 및 Auto Scaling 정책 설정
- ✅ 종합적인 모니터링 및 로깅 시스템 구축
- ✅ 실제 서비스 시나리오 아키텍처 구현

### 예상 소요 시간

[예상 소요 시간](#예상-소요-시간)
- **고가용성 아키텍처**: 90-120분
- **로드 밸런싱 및 Auto Scaling**: 90-120분
- **모니터링 및 로깅**: 90-120분
- **종합 프로젝트**: 90-120분
- **전체 과정**: 6-8시간

---

## 📚 실습 가이드

[📚 실습 가이드](#실습-가이드)

<details>
<summary>📖 실습 가이드 개요</summary>

### 실습 구성

[실습 구성](#실습-구성)
1. **고가용성 아키텍처 설계** (120분)
2. **로드 밸런싱 및 Auto Scaling** (120분)
3. **모니터링 및 로깅 시스템** (120분)
4. **종합 프로젝트 및 최적화** (120분)

### 실습 방식

[실습 방식](#실습-방식)
- **고가용성**: Multi-AZ, Multi-Region 아키텍처
- **로드 밸런싱**: ELB, Cloud Load Balancing 고급 설정
- **모니터링**: CloudWatch, Cloud Monitoring, Prometheus
- **종합 프로젝트**: 실제 서비스 시나리오 구현

### 실습 결과물

[실습 결과물](#실습-결과물)
- Multi-AZ/Multi-Region 고가용성 아키텍처
- 고급 로드 밸런싱 및 Auto Scaling 구성
- 종합적인 모니터링 및 로깅 시스템
- 실제 서비스 시나리오 아키텍처

</details>

<details>
<summary>🔗 관련 실습 가이드</summary>

### 📖 상세 실습 가이드

[📖 상세 실습 가이드](#상세-실습-가이드)
- 🔗 [고가용성 아키텍처 실습](cloud_container/textbook/Day2/high-availability-architecture.md)
- 🔗 [고급 로드 밸런싱 실습](cloud_container/textbook/Day2/practice/advanced-load-balancing.md)
- 🔗 [모니터링 시스템 구축](cloud_container/textbook/Day2/practice/monitoring-system-setup.md)
- 🔗 [종합 프로젝트 실습](cloud_container/textbook/Day2/practice/comprehensive-project.md)

### 📚 개념 학습 가이드

[📚 개념 학습 가이드](#개념-학습-가이드)
- 🔗 [고가용성 아키텍처 가이드](cloud_container/textbook/Day2/high-availability-architecture.md)
- 🔗 [모니터링 설정 가이드](cloud_container/textbook/Day2/monitoring-setup.md)

### 🔗 관련 과정 링크

[🔗 관련 과정 링크](#관련-과정-링크)
- 🔗 Cloud Basic 과정 - AWS/GCP 기초 과정
- 🔗 Cloud Master 과정 - Docker, CI/CD 심화 과정
- 🔗 [전체 커리큘럼](curriculum.md) - 전체 과정 구조 및 학습 경로
- 🔗 [통합 인덱스](index.md) - 전체 과정 인덱스
- 🔗 [학습 경로로 돌아가기](learning-path.md) - Cloud Container 학습 경로

---

## 🔧 실습 환경 준비

<details>
<summary>📋 필수 계정 및 도구</summary>

### 필수 계정

[필수 계정](#필수-계정)
- **AWS 계정**: Free Tier 계정
- **GCP 계정**: $300 크레딧 계정
- **GitHub 계정**: 저장소 관리 및 Actions 사용
- **Docker Hub 계정**: 컨테이너 이미지 저장소

### 필수 도구

[필수 도구](#필수-도구)
- **kubectl**: Kubernetes 클러스터 관리
- **gcloud**: Google Cloud CLI
- **aws**: AWS CLI
- **Docker**: 컨테이너 이미지 빌드
- **Helm**: Kubernetes 패키지 관리자

</details>

<details>
<summary>🔧 1일차 실습 완료 확인</summary>

### 필수 완료 사항

[필수 완료 사항](#필수-완료-사항)
- [ ] Kubernetes 클러스터 아키텍처 이해
- [ ] GKE 클러스터 생성 및 고급 설정
- [ ] 마이크로서비스 아키텍처 구성
- [ ] ECS Fargate 서비스 배포

### 실습 환경 확인

[실습 환경 확인](#실습-환경-확인)
```bash
# kubectl 설정 확인
kubectl cluster-info

# gcloud 설정 확인
gcloud auth list

# aws 설정 확인
aws sts get-caller-identity

# Docker 설정 확인
docker --version
```

</details>

<details>
<summary>🔧 추가 도구 설치</summary>

### 모니터링 도구 설치

[모니터링 도구 설치](#모니터링-도구-설치)
```bash
# Prometheus (선택사항)
docker run -d --name prometheus -p 9090:9090 prom/prometheus

# Grafana (선택사항)
docker run -d --name grafana -p 3000:3000 grafana/grafana

# ELK Stack (선택사항)
docker-compose up -d elasticsearch kibana logstash
```

### 네트워크 도구 설치

[네트워크 도구 설치](#네트워크-도구-설치)
```bash
# Windows
winget install Microsoft.AzureCLI

# macOS
brew install curl wget

# Ubuntu
sudo apt install curl wget netcat
```

</details>

---

## 🚀 고가용성 아키텍처 설계

<details>
<summary>📖 고가용성 개념 이해</summary>

### 고가용성의 3가지 기둥

[고가용성의 3가지 기둥](#고가용성의-3가지-기둥)
- **가용성**: 서비스 중단 시간 최소화
- **내결함성**: 장애 발생 시 자동 복구
- **확장성**: 트래픽 증가에 따른 자동 확장

### Multi-AZ vs Multi-Region

[Multi-AZ vs Multi-Region](#multiaz-vs-multiregion)
| 구분 | Multi-AZ | Multi-Region |
|------|----------|--------------|
| **거리** | 같은 리전 내 | 다른 리전 간 |
| **복구 시간** | 빠름 (분) | 느림 (시간) |
| **비용** | 낮음 | 높음 |
| **데이터 일관성** | 강함 | 약함 |

### 고가용성 아키텍처 패턴

[고가용성 아키텍처 패턴](#고가용성-아키텍처-패턴)
- **Active-Active**: 모든 인스턴스가 활성 상태
- **Active-Passive**: 주 인스턴스와 대기 인스턴스
- **N+1**: N개 운영 + 1개 대기
- **N+M**: N개 운영 + M개 대기

</details>

<details>
<summary>🔗 상세 실습 가이드</summary>

### 📖 실습 파일

[📖 실습 파일](#실습-파일)
- 🔗 [고가용성 아키텍처 실습](cloud_container/textbook/Day2/high-availability-architecture.md)

### 📚 개념 학습

[📚 개념 학습](#개념-학습)
- 🔗 [고가용성 아키텍처 가이드](cloud_container/textbook/Day2/high-availability-architecture.md)
- 🔗 [모니터링 설정 가이드](cloud_container/textbook/Day2/monitoring-setup.md)

</details>

---

## 🚀 로드 밸런싱 및 Auto Scaling

[🚀 로드 밸런싱 및 Auto Scaling](#로드-밸런싱-및-auto-scaling)

<details>
<summary>📖 고급 로드 밸런싱</summary>

### 로드 밸런싱 전략

[로드 밸런싱 전략](#로드-밸런싱-전략)
- **Round Robin**: 순차적 분산
- **Least Connections**: 연결 수가 적은 서버 선택
- **IP Hash**: 클라이언트 IP 기반 분산
- **Weighted**: 가중치 기반 분산

### Health Check 고급 설정

[Health Check 고급 설정](#health-check-고급-설정)
- **HTTP Health Check**: 애플리케이션 레벨 상태 확인
- **TCP Health Check**: 포트 연결 상태 확인
- **Custom Health Check**: 사용자 정의 상태 확인

### 로드 밸런싱 타입 비교

[로드 밸런싱 타입 비교](#로드-밸런싱-타입-비교)
| 타입 | 계층 | 특징 | 사용 사례 |
|------|------|------|-----------|
| **ALB** | Layer 7 | HTTP/HTTPS, 라우팅 | 웹 애플리케이션 |
| **NLB** | Layer 4 | TCP/UDP, 고성능 | 게임, IoT |
| **CLB** | Layer 4 | 레거시 | 기존 애플리케이션 |

</details>

<details>
<summary>🔗 상세 실습 가이드</summary>

### 📖 실습 파일

[📖 실습 파일](#실습-파일)
- 🔗 [고급 로드 밸런싱 실습](cloud_container/textbook/Day2/practice/advanced-load-balancing.md)

### 📚 개념 학습

[📚 개념 학습](#개념-학습)
- 🔗 [고급 로드 밸런싱 가이드](cloud_container/textbook/Day2/practice/advanced-load-balancing.md)

</details>

---

## 📊 모니터링 및 로깅 시스템

## 🔄 자동 복구 및 운영 자동화

## 💰 비용 최적화 전략

<details>
<summary>📖 비용 최적화 방법</summary>

### 비용 분석 및 모니터링

[비용 분석 및 모니터링](#비용-분석-및-모니터링)
- **Cost Explorer**: 상세한 비용 분석
- **Budget Alerts**: 예산 초과 알림
- **Resource Tagging**: 리소스별 비용 추적
- **Cost Allocation**: 부서별 비용 배분

### 최적화 전략

[최적화 전략](#최적화-전략)
- **Right Sizing**: 적절한 인스턴스 크기 선택
- **Reserved Instances**: 장기 사용 시 할인
- **Spot Instances**: 중단 가능한 작업용
- **Auto Scaling**: 수요에 따른 자동 조정

### 비용 절약 팁

[비용 절약 팁](#비용-절약-팁)
- **S3 Lifecycle**: 자동 아카이빙 및 삭제
- **CloudFront**: CDN으로 전송 비용 절약
- **RDS**: 자동 백업 및 스냅샷 최적화
- **Lambda**: 서버리스로 인프라 비용 절약

</details>

<details>
<summary>🔗 상세 실습 가이드</summary>

### 📖 실습 파일

[📖 실습 파일](#실습-파일)
- 🔗 [비용 최적화 전략 실습](cloud_container/textbook/Day1/cost-optimization-guide.md)

### 📚 개념 학습

[📚 개념 학습](#개념-학습)
- 🔗 [비용 최적화 전략 가이드](cloud_container/textbook/Day1/cost-optimization-guide.md)

</details>

---



<details>
<summary>📖 자동 복구 시스템</summary>

### 자동 복구 전략

[자동 복구 전략](#자동-복구-전략)
- **Health Check**: 정기적인 상태 확인
- **Auto Healing**: 자동 복구 및 재시작
- **Circuit Breaker**: 장애 전파 방지
- **Rolling Update**: 무중단 배포

### 운영 자동화

[운영 자동화](#운영-자동화)
- **Infrastructure as Code**: Terraform, CloudFormation
- **Configuration Management**: Ansible, Chef, Puppet
- **CI/CD Pipeline**: GitHub Actions, GitLab CI
- **Monitoring & Alerting**: 자동 알림 및 대응

### 장애 대응 프로세스

[장애 대응 프로세스](#장애-대응-프로세스)
1. **Detection**: 모니터링 시스템이 장애 감지
2. **Analysis**: 로그 및 메트릭 분석
3. **Response**: 자동 복구 또는 수동 개입
4. **Recovery**: 서비스 정상화
5. **Post-mortem**: 사후 분석 및 개선

</details>

<details>
<summary>🔗 상세 실습 가이드</summary>

### 📖 실습 파일

[📖 실습 파일](#실습-파일)
- 🔗 [자동 복구 및 운영 자동화 실습](cloud_container/textbook/Day1/auto-recovery-guide.md)

### 📚 개념 학습

[📚 개념 학습](#개념-학습)
- 🔗 [자동 복구 및 운영 자동화 가이드](cloud_container/textbook/Day1/auto-recovery-guide.md)

</details>

---



## 🔄 자동 복구 및 운영 자동화

## 💰 비용 최적화 전략

<details>
<summary>📖 비용 최적화 방법</summary>

### 비용 분석 및 모니터링

[비용 분석 및 모니터링](#비용-분석-및-모니터링)
- **Cost Explorer**: 상세한 비용 분석
- **Budget Alerts**: 예산 초과 알림
- **Resource Tagging**: 리소스별 비용 추적
- **Cost Allocation**: 부서별 비용 배분

### 최적화 전략

[최적화 전략](#최적화-전략)
- **Right Sizing**: 적절한 인스턴스 크기 선택
- **Reserved Instances**: 장기 사용 시 할인
- **Spot Instances**: 중단 가능한 작업용
- **Auto Scaling**: 수요에 따른 자동 조정

### 비용 절약 팁

[비용 절약 팁](#비용-절약-팁)
- **S3 Lifecycle**: 자동 아카이빙 및 삭제
- **CloudFront**: CDN으로 전송 비용 절약
- **RDS**: 자동 백업 및 스냅샷 최적화
- **Lambda**: 서버리스로 인프라 비용 절약

</details>

<details>
<summary>🔗 상세 실습 가이드</summary>

### 📖 실습 파일

[📖 실습 파일](#실습-파일)
- 🔗 [비용 최적화 전략 실습](cloud_container/textbook/Day1/cost-optimization-guide.md)

### 📚 개념 학습

[📚 개념 학습](#개념-학습)
- 🔗 [비용 최적화 전략 가이드](cloud_container/textbook/Day1/cost-optimization-guide.md)

</details>

---



<details>
<summary>📖 자동 복구 시스템</summary>

### 자동 복구 전략

[자동 복구 전략](#자동-복구-전략)
- **Health Check**: 정기적인 상태 확인
- **Auto Healing**: 자동 복구 및 재시작
- **Circuit Breaker**: 장애 전파 방지
- **Rolling Update**: 무중단 배포

### 운영 자동화

[운영 자동화](#운영-자동화)
- **Infrastructure as Code**: Terraform, CloudFormation
- **Configuration Management**: Ansible, Chef, Puppet
- **CI/CD Pipeline**: GitHub Actions, GitLab CI
- **Monitoring & Alerting**: 자동 알림 및 대응

### 장애 대응 프로세스

[장애 대응 프로세스](#장애-대응-프로세스)
1. **Detection**: 모니터링 시스템이 장애 감지
2. **Analysis**: 로그 및 메트릭 분석
3. **Response**: 자동 복구 또는 수동 개입
4. **Recovery**: 서비스 정상화
5. **Post-mortem**: 사후 분석 및 개선

</details>

<details>
<summary>🔗 상세 실습 가이드</summary>

### 📖 실습 파일

[📖 실습 파일](#실습-파일)
- 🔗 [자동 복구 및 운영 자동화 실습](cloud_container/textbook/Day1/auto-recovery-guide.md)

### 📚 개념 학습

[📚 개념 학습](#개념-학습)
- 🔗 [자동 복구 및 운영 자동화 가이드](cloud_container/textbook/Day1/auto-recovery-guide.md)

</details>

---



<details>
<summary>📖 종합 모니터링 시스템</summary>

### 모니터링 계층

[모니터링 계층](#모니터링-계층)
- **인프라 모니터링**: CPU, 메모리, 네트워크
- **애플리케이션 모니터링**: 응답 시간, 에러율, 처리량
- **비즈니스 모니터링**: 사용자 수, 매출, 전환율

### 로깅 전략

[로깅 전략](#로깅-전략)
- **구조화된 로그**: JSON 형식 로그
- **로그 집계**: 중앙화된 로그 수집
- **로그 분석**: 실시간 로그 분석 및 알림

### 모니터링 도구 비교

[모니터링 도구 비교](#모니터링-도구-비교)
| 구분 | AWS | GCP | 오픈소스 |
|------|-----|-----|----------|
| **메트릭** | CloudWatch | Cloud Monitoring | Prometheus |
| **로그** | CloudWatch Logs | Cloud Logging | ELK Stack |
| **트레이스** | X-Ray | Cloud Trace | Jaeger |
| **대시보드** | CloudWatch | Cloud Monitoring | Grafana |

</details>

<details>
<summary>🔗 상세 실습 가이드</summary>

### 📖 실습 파일

[📖 실습 파일](#실습-파일)
- 🔗 [모니터링 시스템 구축](cloud_container/textbook/Day2/practice/monitoring-system-setup.md)

### 📚 개념 학습

[📚 개념 학습](#개념-학습)
- 🔗 [모니터링 시스템 가이드](cloud_container/textbook/Day2/monitoring-setup.md)

</details>

---

## 🎯 종합 프로젝트 및 최적화

## 🏗️ 고가용성 아키텍처 실습

## 📊 모니터링 및 로깅 시스템 실습

## 🔄 자동 복구 및 운영 자동화 실습

## 💰 비용 최적화 전략 실습

<details>
<summary>📖 실습 개요</summary>

### 실습 목표

[실습 목표](#실습-목표)
- 비용 분석 및 모니터링 설정
- 최적화 전략 적용
- 비용 절약 효과 측정
- 예산 관리 및 알림 설정

### 실습 환경

[실습 환경](#실습-환경)
- **AWS**: Cost Explorer, Budgets, Trusted Advisor
- **GCP**: Billing, Recommender, Budgets
- **도구**: Terraform, CloudFormation

</details>

<details>
<summary>🔗 상세 실습 가이드</summary>

### 📖 실습 파일

[📖 실습 파일](#실습-파일)
- 🔗 [비용 최적화 전략 실습](cloud_container/textbook/Day1/cost-optimization-guide.md)

### 📚 개념 학습

[📚 개념 학습](#개념-학습)
- 🔗 [비용 최적화 전략 가이드](cloud_container/textbook/Day1/cost-optimization-guide.md)

</details>

---



<details>
<summary>📖 실습 개요</summary>

### 실습 목표

[실습 목표](#실습-목표)
- 자동 복구 시스템 구성
- 운영 자동화 스크립트 작성
- CI/CD 파이프라인 구축
- 모니터링 및 알림 설정

### 실습 환경

[실습 환경](#실습-환경)
- **AWS**: Lambda, Step Functions, CodePipeline
- **GCP**: Cloud Functions, Cloud Build, Cloud Scheduler
- **도구**: Terraform, Ansible, GitHub Actions

</details>

<details>
<summary>🔗 상세 실습 가이드</summary>

### 📖 실습 파일

[📖 실습 파일](#실습-파일)
- 🔗 [자동 복구 및 운영 자동화 실습](cloud_container/textbook/Day1/auto-recovery-guide.md)

### 📚 개념 학습

[📚 개념 학습](#개념-학습)
- 🔗 [자동 복구 및 운영 자동화 가이드](cloud_container/textbook/Day1/auto-recovery-guide.md)

</details>

---



<details>
<summary>📖 실습 개요</summary>

### 실습 목표

[실습 목표](#실습-목표)
- CloudWatch 고급 설정
- Cloud Monitoring 구성
- 대시보드 및 알림 설정
- 로그 분석 및 시각화

### 실습 환경

[실습 환경](#실습-환경)
- **AWS**: CloudWatch, X-Ray
- **GCP**: Cloud Monitoring, Cloud Logging
- **오픈소스**: Prometheus, Grafana

</details>

<details>
<summary>🔗 상세 실습 가이드</summary>

### 📖 실습 파일

[📖 실습 파일](#실습-파일)
- 🔗 [모니터링 시스템 구축](cloud_container/textbook/Day2/practice/monitoring-system-setup.md)

### 📚 개념 학습

[📚 개념 학습](#개념-학습)
- 🔗 [모니터링 시스템 가이드](cloud_container/textbook/Day2/practice/monitoring-system-setup.md)

</details>

---



<details>
<summary>📖 실습 개요</summary>

### 실습 목표

[실습 목표](#실습-목표)
- Multi-AZ 아키텍처 구성
- Multi-Region 아키텍처 구성
- 고가용성 테스트 수행
- 장애 복구 시나리오 검증

### 실습 환경

[실습 환경](#실습-환경)
- **AWS**: EC2, RDS, ELB, Route 53
- **GCP**: Compute Engine, Cloud SQL, Load Balancer
- **모니터링**: CloudWatch, Cloud Monitoring

</details>

<details>
<summary>🔗 상세 실습 가이드</summary>

### 📖 실습 파일

[📖 실습 파일](#실습-파일)
- 🔗 [고가용성 아키텍처 실습](cloud_container/textbook/Day2/high-availability-architecture.md)

### 📚 개념 학습

[📚 개념 학습](#개념-학습)
- 🔗 [고가용성 아키텍처 가이드](cloud_container/textbook/Day2/high-availability-architecture.md)

</details>

---



## 🏗️ 고가용성 아키텍처 실습

## 📊 모니터링 및 로깅 시스템 실습

## 🔄 자동 복구 및 운영 자동화 실습

## 💰 비용 최적화 전략 실습

<details>
<summary>📖 실습 개요</summary>

### 실습 목표

[실습 목표](#실습-목표)
- 비용 분석 및 모니터링 설정
- 최적화 전략 적용
- 비용 절약 효과 측정
- 예산 관리 및 알림 설정

### 실습 환경

[실습 환경](#실습-환경)
- **AWS**: Cost Explorer, Budgets, Trusted Advisor
- **GCP**: Billing, Recommender, Budgets
- **도구**: Terraform, CloudFormation

</details>

<details>
<summary>🔗 상세 실습 가이드</summary>

### 📖 실습 파일

[📖 실습 파일](#실습-파일)
- 🔗 [비용 최적화 전략 실습](cloud_container/textbook/Day1/cost-optimization-guide.md)

### 📚 개념 학습

[📚 개념 학습](#개념-학습)
- 🔗 [비용 최적화 전략 가이드](cloud_container/textbook/Day1/cost-optimization-guide.md)

</details>

---



<details>
<summary>📖 실습 개요</summary>

### 실습 목표

[실습 목표](#실습-목표)
- 자동 복구 시스템 구성
- 운영 자동화 스크립트 작성
- CI/CD 파이프라인 구축
- 모니터링 및 알림 설정

### 실습 환경

[실습 환경](#실습-환경)
- **AWS**: Lambda, Step Functions, CodePipeline
- **GCP**: Cloud Functions, Cloud Build, Cloud Scheduler
- **도구**: Terraform, Ansible, GitHub Actions

</details>

<details>
<summary>🔗 상세 실습 가이드</summary>

### 📖 실습 파일

[📖 실습 파일](#실습-파일)
- 🔗 [자동 복구 및 운영 자동화 실습](cloud_container/textbook/Day1/auto-recovery-guide.md)

### 📚 개념 학습

[📚 개념 학습](#개념-학습)
- 🔗 [자동 복구 및 운영 자동화 가이드](cloud_container/textbook/Day1/auto-recovery-guide.md)

</details>

---



<details>
<summary>📖 실습 개요</summary>

### 실습 목표

[실습 목표](#실습-목표)
- CloudWatch 고급 설정
- Cloud Monitoring 구성
- 대시보드 및 알림 설정
- 로그 분석 및 시각화

### 실습 환경

[실습 환경](#실습-환경)
- **AWS**: CloudWatch, X-Ray
- **GCP**: Cloud Monitoring, Cloud Logging
- **오픈소스**: Prometheus, Grafana

</details>

<details>
<summary>🔗 상세 실습 가이드</summary>

### 📖 실습 파일

[📖 실습 파일](#실습-파일)
- 🔗 [모니터링 시스템 구축](cloud_container/textbook/Day2/practice/monitoring-system-setup.md)

### 📚 개념 학습

[📚 개념 학습](#개념-학습)
- 🔗 [모니터링 시스템 가이드](cloud_container/textbook/Day2/practice/monitoring-system-setup.md)

</details>

---



<details>
<summary>📖 실습 개요</summary>

### 실습 목표

[실습 목표](#실습-목표)
- Multi-AZ 아키텍처 구성
- Multi-Region 아키텍처 구성
- 고가용성 테스트 수행
- 장애 복구 시나리오 검증

### 실습 환경

[실습 환경](#실습-환경)
- **AWS**: EC2, RDS, ELB, Route 53
- **GCP**: Compute Engine, Cloud SQL, Load Balancer
- **모니터링**: CloudWatch, Cloud Monitoring

</details>

<details>
<summary>🔗 상세 실습 가이드</summary>

### 📖 실습 파일

[📖 실습 파일](#실습-파일)
- 🔗 [고가용성 아키텍처 실습](cloud_container/textbook/Day2/high-availability-architecture.md)

### 📚 개념 학습

[📚 개념 학습](#개념-학습)
- 🔗 [고가용성 아키텍처 가이드](cloud_container/textbook/Day2/high-availability-architecture.md)

</details>

---



[🎯 종합 프로젝트 및 최적화](#종합-프로젝트-및-최적화)

<details>
<summary>📖 실제 서비스 시나리오</summary>

### 프로젝트 요구사항

[프로젝트 요구사항](#프로젝트-요구사항)
- **고가용성**: 99.9% 가용성 보장
- **확장성**: 트래픽 증가에 따른 자동 확장
- **모니터링**: 실시간 모니터링 및 알림
- **비용 최적화**: 비용 효율적인 아키텍처

### 아키텍처 설계

[아키텍처 설계](#아키텍처-설계)
```
Internet → CloudFront → ALB → Auto Scaling Group → ECS Fargate
                ↓
            CloudWatch → SNS → Slack/Email
```

### 성능 목표

[성능 목표](#성능-목표)
- **응답 시간**: 95% 요청이 200ms 이내
- **가용성**: 99.9% 이상
- **처리량**: 초당 1000 요청 처리
- **복구 시간**: 장애 발생 시 5분 이내 복구

</details>

<details>
<summary>🔗 상세 실습 가이드</summary>

### 📖 실습 파일

[📖 실습 파일](#실습-파일)
- 🔗 [종합 프로젝트 실습](cloud_container/textbook/Day2/practice/comprehensive-project.md)

### 📚 개념 학습

[📚 개념 학습](#개념-학습)
- 🔗 [종합 프로젝트 가이드](cloud_container/textbook/Day2/practice/comprehensive-project.md)

</details>

---

## 📚 문제 해결 및 참고 자료

<details>
<summary>🐛 자주 발생하는 문제</summary>

### 고가용성 관련 문제

[고가용성 관련 문제](#고가용성-관련-문제)
- 🔗 [종합 트러블슈팅 가이드](cloud_container/textbook/Day2/troubleshooting/multi-az-issues.md)

### 모니터링 관련 문제

[모니터링 관련 문제](#모니터링-관련-문제)
- 🔗 [모니터링 트러블슈팅](cloud_container/textbook/Day2/troubleshooting/multi-az-issues.md)

</details>

<details>
<summary>📖 추가 학습 자료</summary>

### 공식 문서

[공식 문서](#공식-문서)
- [AWS Well-Architected Framework](https:///aws.amazon.com/architecture/well-architected/)
- [GCP Architecture Center](https:///cloud.google.com/architecture)
- [Kubernetes 고가용성](https:///kubernetes.io/docs/setup/production-environment/)
- [Prometheus 공식 문서](https:///prometheus.io/docs/)
- [Grafana 공식 문서](https:///grafana.com/docs/)

### 유용한 리소스

[유용한 리소스](#유용한-리소스)
- [AWS 샘플 프로젝트](https:///github.com/aws-samples)
- [GCP 샘플 프로젝트](https:///github.com/GoogleCloudPlatform)
- [Kubernetes 샘플 프로젝트](https:///github.com/kubernetes/examples)
- [ELK Stack 가이드](https:///www.elastic.co/guide/)

</details>

<details>
<summary>🚀 다음 단계</summary>

### 실무 적용

[실무 적용](#실무-적용)
1. **실제 프로젝트**: 자신의 프로젝트에 고가용성 아키텍처 적용
2. **모니터링**: 종합적인 모니터링 시스템 구축
3. **자동화**: 완전 자동화된 운영 환경
4. **비용 최적화**: 지속적인 비용 최적화

### 고급 기능

[고급 기능](#고급-기능)
1. **서비스 메시**: Istio, Linkerd 구현
2. **보안**: Pod Security Policy, Network Policy
3. **성능**: HPA, VPA, Cluster Autoscaler
4. **운영**: 백업, 재해 복구

</details>

---

## 🚀 시작하기

[🚀 시작하기](#시작하기)

1일차 실습이 완료되었다면 [고가용성 아키텍처 실습](cloud_container/textbook/Day2/high-availability-architecture.md)부터 시작하세요.

### 문제가 있나요?

[문제가 있나요?](#문제가-있나요)
실습 중 문제가 발생하면 [트러블슈팅 가이드](cloud_basic/textbook/Day1/troubleshooting-guide.md)를 참고하세요.

---

<div align="center">

## 🎉 Day 2 실습을 시작하세요!

[🎉 Day 2 실습을 시작하세요!](#day-2-실습을-시작하세요)

[🚀 실습 시작하기](cloud_container/textbook/Day1/practice/container-basics.md) | 
📚 Cloud Basic 과정 전체 |
[🏠 홈으로 돌아가기](index.md)

</div>

---

<div align="center">

[🏠 홈](index.md) | [📚 전체 커리큘럼](curriculum.md) | [🔗 학습 경로](learning-path.md)

</div>
