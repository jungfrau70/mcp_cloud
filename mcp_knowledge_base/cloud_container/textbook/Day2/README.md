# 클라우드 실무력 강화! AWS & GCP 활용법(컨테이너 심화) - 2일차

## 📌 2일차 개요

2일차는 **고가용성 및 확장성 아키텍처**에 집중하여 실무 환경에서 요구되는 안정성과 성능을 확보하는 방법을 학습합니다.

### 📋 학습 목표
- AWS Multi-AZ 및 GCP Multi-Region 아키텍처 설계
- 로드 밸런싱 및 Auto Scaling 고급 설정
- 모니터링 및 로깅 시스템 구축
- 종합 프로젝트를 통한 실무 역량 강화

---

## 🚀 실습 환경 준비

### 1단계: 1일차 실습 결과 확인
```bash
# 1일차에서 배포한 리소스 확인
kubectl get pods -n container-demo
kubectl get services -n container-demo
kubectl get ingress -n container-demo
```

### 2단계: 2일차 실습 환경 설정
```bash
# 2일차 실습 디렉토리로 이동
cd mcp_knowledge_base/cloud_container/textbook/Day2

# 실습 환경 확인
ls -la
```

---

## 📚 실습 순서

### 1교시: 고가용성 아키텍처 설계 (90분)

#### 1.1 AWS Multi-AZ 구성 (45분)
- **학습 내용**: RDS Multi-AZ, EC2 Auto Scaling Group 설정
- **실습 파일**: `high-availability-architecture.md`
- **실습 목표**: 
  - RDS Multi-AZ 인스턴스 생성
  - EC2 Auto Scaling Group 구성
  - Application Load Balancer 설정

#### 1.2 GCP Multi-Region 구성 (45분)
- **학습 내용**: GKE Multi-Region 클러스터, Global Load Balancer
- **실습 파일**: `high-availability-architecture.md`
- **실습 목표**:
  - Multi-Region GKE 클러스터 생성
  - Global Load Balancer 설정
  - Cloud SQL Multi-Region 구성

### 2교시: 로드 밸런싱 및 Auto Scaling (90분)

#### 2.1 AWS ELB 및 Auto Scaling (45분)
- **학습 내용**: Application Load Balancer, Auto Scaling 정책
- **실습 파일**: `high-availability-architecture.md`
- **실습 목표**:
  - ALB 타겟 그룹 설정
  - Auto Scaling 정책 구성
  - 헬스체크 및 알림 설정

#### 2.2 GCP Load Balancing 및 MIG (45분)
- **학습 내용**: Cloud Load Balancing, Managed Instance Group
- **실습 파일**: `high-availability-architecture.md`
- **실습 목표**:
  - Global Load Balancer 설정
  - Managed Instance Group 구성
  - 자동 스케일링 정책 설정

### 3교시: 모니터링 및 로깅 시스템 (90분)

#### 3.1 AWS CloudWatch 설정 (45분)
- **학습 내용**: CloudWatch 메트릭, 로그, 알림
- **실습 파일**: `monitoring-setup.md`
- **실습 목표**:
  - 커스텀 메트릭 전송
  - CloudWatch 알림 설정
  - 로그 기반 모니터링

#### 3.2 GCP Cloud Monitoring 설정 (45분)
- **학습 내용**: Cloud Monitoring, Cloud Logging
- **실습 파일**: `monitoring-setup.md`
- **실습 목표**:
  - Cloud Monitoring 메트릭 설정
  - Cloud Logging 구성
  - 알림 정책 설정

### 4교시: 종합 프로젝트 및 최적화 (90분)

#### 4.1 고가용성 웹 서비스 아키텍처 설계 (45분)
- **학습 내용**: 전체 아키텍처 설계 및 구현
- **실습 파일**: `comprehensive-project.md`
- **실습 목표**:
  - 고가용성 아키텍처 설계
  - 비용 최적화 방안 수립
  - 성능 최적화 전략

#### 4.2 실제 서비스 시나리오 구현 (45분)
- **학습 내용**: 실제 운영 환경 시뮬레이션
- **실습 파일**: `comprehensive-project.md`
- **실습 목표**:
  - 장애 복구 시나리오 테스트
  - 부하 테스트 및 성능 측정
  - 모니터링 및 알림 시스템 검증

---

## 🔧 필요한 권한 및 설정

### AWS 권한
- RDS Multi-AZ 인스턴스 생성 권한
- Auto Scaling Group 관리 권한
- Application Load Balancer 생성 권한
- CloudWatch 메트릭 및 로그 권한

### GCP 권한
- GKE Multi-Region 클러스터 관리 권한
- Global Load Balancer 생성 권한
- Cloud SQL Multi-Region 관리 권한
- Cloud Monitoring 및 Logging 권한

### GitHub Secrets (1일차와 동일)
```bash
# AWS 관련
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION

# GCP 관련
GCP_PROJECT_ID
GCP_SA_KEY
GCP_REGION
```

---

## 📋 실습 체크리스트

### 고가용성 아키텍처
- [ ] AWS RDS Multi-AZ 인스턴스 생성
- [ ] AWS EC2 Auto Scaling Group 설정
- [ ] AWS Application Load Balancer 구성
- [ ] GCP Multi-Region GKE 클러스터 생성
- [ ] GCP Global Load Balancer 설정
- [ ] GCP Cloud SQL Multi-Region 구성

### 로드 밸런싱 및 Auto Scaling
- [ ] AWS ALB 타겟 그룹 설정
- [ ] AWS Auto Scaling 정책 구성
- [ ] GCP Managed Instance Group 설정
- [ ] GCP 자동 스케일링 정책 구성
- [ ] 헬스체크 및 알림 설정
- [ ] 로드 밸런싱 테스트

### 모니터링 및 로깅
- [ ] AWS CloudWatch 메트릭 설정
- [ ] AWS CloudWatch 알림 구성
- [ ] GCP Cloud Monitoring 설정
- [ ] GCP Cloud Logging 구성
- [ ] Prometheus + Grafana 스택 구축
- [ ] ELK Stack 로그 분석 시스템

### 종합 프로젝트
- [ ] 고가용성 아키텍처 설계 완료
- [ ] 비용 최적화 방안 수립
- [ ] 성능 최적화 전략 구현
- [ ] 장애 복구 시나리오 테스트
- [ ] 부하 테스트 및 성능 측정
- [ ] 모니터링 및 알림 시스템 검증

---

## 🐛 문제 해결

### 자주 발생하는 문제

#### 1. RDS Multi-AZ 생성 실패
```bash
# 해결방법: 서브넷 그룹 확인
aws rds describe-db-subnet-groups
aws rds create-db-subnet-group --db-subnet-group-name container-demo-subnet-group
```

#### 2. Auto Scaling Group 생성 실패
```bash
# 해결방법: Launch Template 확인
aws ec2 describe-launch-templates
aws autoscaling describe-auto-scaling-groups
```

#### 3. GCP Multi-Region 클러스터 생성 실패
```bash
# 해결방법: 프로젝트 및 권한 확인
gcloud config get-value project
gcloud auth list
gcloud container clusters list
```

#### 4. 모니터링 데이터 수집 실패
```bash
# 해결방법: Prometheus 설정 확인
kubectl get configmap prometheus-config -o yaml
kubectl logs -f deployment/prometheus -n container-demo
```

---

## 📚 참고 자료

### 1일차 연계
- [1일차 README](../Day1/README.md)
- [Container 오케스트레이션 가이드](../Day1/container-orchestration-guide.md)
- [Kubernetes 고급 가이드](../Day1/kubernetes-advanced-guide.md)

### 2일차 실습 가이드
- [고가용성 아키텍처 가이드](./high-availability-architecture.md)
- [모니터링 설정 가이드](./monitoring-setup.md)
- [종합 프로젝트 가이드](./comprehensive-project.md)

### 공식 문서
- [AWS RDS Multi-AZ 공식 문서](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html)
- [AWS Auto Scaling 공식 문서](https://docs.aws.amazon.com/autoscaling/)
- [GCP Multi-Region 공식 문서](https://cloud.google.com/architecture/best-practices-for-enterprise-organizations)
- [GCP Global Load Balancing 공식 문서](https://cloud.google.com/load-balancing/docs/https)

---

## 🎯 학습 성과

2일차 과정을 완료한 후 수강생은 다음을 수행할 수 있습니다:

- **고가용성 아키텍처 설계**: AWS Multi-AZ, GCP Multi-Region 아키텍처 구현
- **로드 밸런싱 및 Auto Scaling**: ELB, ALB, GCP Load Balancer, MIG 설정
- **모니터링 시스템 구축**: CloudWatch, Cloud Monitoring, Prometheus, Grafana 구성
- **장애 복구 전략 수립**: RTO/RPO 목표 달성, 자동 복구 시스템 구현
- **실무 프로젝트 수행**: 실제 서비스 시나리오 기반 아키텍처 설계 및 구현

---

**💡 팁**: 2일차는 1일차에서 학습한 컨테이너 기술을 바탕으로 실제 운영 환경에서 요구되는 고가용성과 안정성을 확보하는 방법을 학습합니다. 각 실습을 차근차근 따라하면서 실무 역량을 강화해보세요!
