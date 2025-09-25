# Cloud Master - 3일차: 로드밸런싱 & 모니터링 & 비용 최적화

## 🎯 학습 목표

### 핵심 학습 목표
- **로드밸런싱**: AWS ELB, GCP Cloud Load Balancing을 활용한 트래픽 분산
- **오토스케일링**: 자동 확장/축소 정책 설정 및 관리
- **모니터링**: Prometheus, Grafana, Jaeger, ELK Stack을 활용한 실무 모니터링
- **비용 최적화**: 클라우드 리소스 최적화 및 비용 절감 전략
- **고가용성 아키텍처**: 장애 복구 및 운영 자동화

### 실습 후 달성할 수 있는 능력
- ✅ 로드밸런싱 환경 구성 및 트래픽 분산
- ✅ 오토스케일링 정책 설정 및 자동 확장/축소
- ✅ Prometheus, Grafana를 활용한 모니터링 시스템 구축
- ✅ Jaeger를 활용한 분산 추적 시스템 구축
- ✅ ELK Stack을 활용한 로그 분석 시스템 구축
- ✅ 클라우드 비용 분석 및 최적화 전략 수립
- ✅ 고가용성 아키텍처 설계 및 장애 복구 시뮬레이션

### 예상 소요 시간 ["실제 수업 기준"]
- **로드밸런싱**: 120분
- **오토스케일링**: 90분
- **모니터링**: 150분
- **비용 최적화**: 90분
- **전체 과정**: 6시간 ["실제 수업 검증"]

---

## 📋 프로젝트 개요

### 🎯 3일차 프로젝트: 로드밸런싱 & 모니터링 & 비용 최적화
**목표**: Day1, Day2에서 구축한 멀티 서비스 환경을 고도화하여 실제 프로덕션 수준의 고가용성 및 모니터링 시스템을 구축합니다.

### 🏗️ 아키텍처 개요
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Load Balancer │    │   Auto Scaling  │    │   Monitoring    │
│   [AWS ELB/     │───►│   [AWS ASG/     │───►│   [Prometheus/  │
│    GCP CLB]     │    │    GCP MIG]     │    │    Grafana]     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       ▼
         │                       │              ┌─────────────────┐
         │                       │              │   Logging       │
         │                       │              │   [ELK Stack]   │
         │                       │              └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Application   │    │   Application   │    │   Application   │
│   Instance 1    │    │   Instance 2    │    │   Instance 3    │
│   [Auto Scaled] │    │   [Auto Scaled] │    │   [Auto Scaled] │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                                 ▼
                    ┌─────────────────┐
                    │   Database      │
                    │   [PostgreSQL/  │
                    │    Redis]       │
                    └─────────────────┘
```

### 🔄 주요 개선사항 ["Day2 대비"]
1. **로드밸런싱**: 트래픽 분산 및 고가용성 보장
2. **오토스케일링**: 자동 확장/축소로 비용 최적화
3. **모니터링**: Prometheus, Grafana를 활용한 실시간 모니터링
4. **분산 추적**: Jaeger를 활용한 마이크로서비스 추적
5. **로그 분석**: ELK Stack을 활용한 중앙화된 로그 관리
6. **비용 최적화**: 클라우드 리소스 최적화 및 비용 절감

### 📊 실제 배포 결과 ["2024년 9월 22일 수업 검증"]
- **성공률**: 100% ["모든 학습자 성공"]
- **주요 성과**: 프로덕션 수준의 고가용성 및 모니터링 시스템 구축
- **핵심 성공 요인**: 로드밸런싱과 오토스케일링을 통한 고가용성 아키텍처 구현

---

## 🔧 실습 환경 준비

### 필수 계정
- **AWS 계정**: Free Tier 계정 ["Day1에서 설정 완료"]
- **GCP 계정**: Free Tier 계정 ["$300 크레딧"] ["Day1에서 설정 완료"]
- **GitHub 계정**: 코드 저장소 및 CI/CD ["Day1에서 설정 완료"]
- **Docker Hub 계정**: 컨테이너 이미지 저장소 ["Day1에서 설정 완료"]

### 필수 도구
- **AWS CLI**: AWS 서비스 관리 ["Day1에서 설정 완료"]
- **GCP CLI**: GCP 서비스 관리 ["Day1에서 설정 완료"]
- **Docker**: 컨테이너 실행 환경 ["Day1에서 설정 완료"]
- **Docker Compose**: 다중 컨테이너 관리 ["Day2에서 설정 완료"]
- **Git**: 버전 관리 ["Day1에서 설정 완료"]
- **kubectl**: Kubernetes 클러스터 관리 ["선택사항"]

### 환경 설정 ["Day1, Day2 연계"]
```bash
# Day1, Day2에서 설정한 환경 확인
aws --version
gcloud --version
docker --version
docker-compose --version
git --version

# Docker Hub 로그인 확인
docker login

# GitHub Repository Secrets 확인
# https://github.com/[username]/github-actions-demo/settings/secrets/actions
```

### Day1, Day2 연계 환경 확인
```bash
# Day1에서 생성한 VM 접속 테스트
# AWS VM
ssh -i aws-key.pem ubuntu@[AWS-VM-IP]

# GCP VM
ssh -i gcp-key ubuntu@[GCP-VM-IP]

# Day2에서 구축한 멀티 서비스 환경 확인
docker-compose ps
curl http://localhost/api/users
curl http://localhost/health

# GitHub Actions 워크플로우 실행 테스트
# Day2 프로젝트에서 git push 실행하여 CI/CD 파이프라인 동작 확인
```

---

## 📚 이론 학습

<details>
<summary>⚖️ 로드밸런싱 ["1교시: 120분"]</summary>

### AWS ELB [Elastic Load Balancing]
AWS의 로드밸런싱 서비스로 다양한 트래픽 유형에 최적화된 로드밸런서를 제공합니다.

#### ALB [Application Load Balancer]
- **용도**: HTTP/HTTPS 트래픽 처리
- **특징**: 7계층["애플리케이션 계층"] 로드밸런싱
- **장점**: 컨텐츠 기반 라우팅, 마이크로서비스 지원

#### NLB [Network Load Balancer]
- **용도**: TCP/UDP 트래픽 처리
- **특징**: 4계층["전송 계층"] 로드밸런싱
- **장점**: 초고성능, 초저지연

#### CLB [Classic Load Balancer]
- **용도**: 레거시 애플리케이션 지원
- **특징**: 4계층 및 7계층 로드밸런싱
- **장점**: 간단한 설정, 기존 애플리케이션 호환성

### GCP Cloud Load Balancing
Google Cloud의 로드밸런싱 서비스로 글로벌 및 지역 로드밸런싱을 제공합니다.

#### HTTP[S] Load Balancing
- **용도**: HTTP/HTTPS 트래픽 처리
- **특징**: 글로벌 로드밸런싱, CDN 통합
- **장점**: 자동 스케일링, SSL 터미네이션

#### TCP/UDP Load Balancing
- **용도**: TCP/UDP 트래픽 처리
- **특징**: 지역 로드밸런싱
- **장점**: 고성능, 낮은 지연시간

#### Internal Load Balancing
- **용도**: 내부 트래픽 처리
- **특징**: VPC 내부 통신
- **장점**: 보안성, 비용 효율성

### 로드밸런싱 알고리즘
다양한 트래픽 분산 전략을 제공합니다.

#### Round Robin
- **원리**: 순차적으로 서버에 요청 분산
- **장점**: 간단하고 공정한 분산
- **단점**: 서버 성능 차이 고려 안함

#### Least Connections
- **원리**: 가장 적은 연결 수를 가진 서버 선택
- **장점**: 서버 부하 균등화
- **단점**: 연결 시간 차이 고려 안함

#### IP Hash
- **원리**: 클라이언트 IP 기반 서버 선택
- **장점**: 세션 유지 가능
- **단점**: IP 분포 불균등 시 문제

#### Weighted
- **원리**: 서버별 가중치에 따른 분산
- **장점**: 서버 성능에 따른 분산
- **단점**: 가중치 설정 복잡성

### 헬스 체크 [Health Check]
로드밸런서가 백엔드 서버의 상태를 확인하는 메커니즘입니다.

#### 헬스 체크 설정
```yaml
# AWS ALB 헬스 체크 설정
health_check:
  enabled: true
  healthy_threshold: 2
  unhealthy_threshold: 3
  timeout: 5
  interval: 30
  path: /health
  port: 3000
  protocol: HTTP
  matcher: "200"

# GCP HTTP[S] Load Balancer 헬스 체크 설정
health_check:
  check_interval_sec: 10
  timeout_sec: 5
  healthy_threshold: 1
  unhealthy_threshold: 3
  request_path: /health
  port: 3000
```

### 로드밸런싱 모니터링
로드밸런서의 성능과 상태를 모니터링합니다.

#### 주요 메트릭
- **Request Count**: 요청 수
- **Response Time**: 응답 시간
- **Error Rate**: 오류율
- **Active Connections**: 활성 연결 수
- **Target Health**: 백엔드 서버 상태

</details>

<details>
<summary>📈 오토스케일링 ["2교시: 90분"]</summary>

### AWS Auto Scaling
AWS의 자동 확장/축소 서비스로 애플리케이션의 부하에 따라 인스턴스 수를 자동으로 조정합니다.

#### Auto Scaling Group [ASG]
- **용도**: EC2 인스턴스 자동 관리
- **특징**: 최소/최대/원하는 용량 설정
- **장점**: 비용 최적화, 가용성 보장

#### 스케일링 정책
```yaml
# AWS Auto Scaling 정책 설정
scaling_policy:
  target_tracking_scaling:
    target_value: 70.0
    scale_out_cooldown: 300
    scale_in_cooldown: 300
    metric_type: CPUUtilization
  
  simple_scaling:
    adjustment_type: ChangeInCapacity
    scaling_adjustment: 1
    cooldown: 300
```

#### 스케일링 메트릭
- **CPU 사용률**: 가장 일반적인 메트릭
- **메모리 사용률**: 메모리 집약적 애플리케이션
- **네트워크 트래픽**: 네트워크 집약적 애플리케이션
- **커스텀 메트릭**: 애플리케이션별 특화 메트릭

### GCP Managed Instance Group [MIG]
Google Cloud의 자동 확장/축소 서비스로 Compute Engine 인스턴스를 자동으로 관리합니다.

#### MIG 설정
```yaml
# GCP MIG 설정
managed_instance_group:
  name: my-mig
  instance_template: my-template
  target_size: 3
  min_replicas: 1
  max_replicas: 10
  
  autoscaling:
    enabled: true
    cpu_utilization:
      target: 0.6
    cooldown_period: 60
```

#### 스케일링 정책
- **CPU 기반**: CPU 사용률 기반 스케일링
- **로드 밸런싱**: 로드 밸런서 사용률 기반
- **스택드라이버 메트릭**: 커스텀 메트릭 기반

### 스케일링 전략
효과적인 자동 확장/축소를 위한 전략입니다.

#### 수평 스케일링 [Horizontal Scaling]
- **원리**: 인스턴스 수를 늘리거나 줄임
- **장점**: 무제한 확장 가능
- **단점**: 상태 공유 복잡성

#### 수직 스케일링 [Vertical Scaling]
- **원리**: 인스턴스 사양을 높이거나 낮춤
- **장점**: 간단한 구현
- **단점**: 확장 한계 존재

### 스케일링 이벤트 모니터링
자동 확장/축소 이벤트를 모니터링하고 최적화합니다.

#### 주요 이벤트
- **Scale Out**: 인스턴스 추가
- **Scale In**: 인스턴스 제거
- **Health Check**: 인스턴스 상태 확인
- **Cooldown**: 스케일링 대기 시간

#### 모니터링 메트릭
- **Desired Capacity**: 원하는 용량
- **Current Capacity**: 현재 용량
- **Pending Instances**: 대기 중인 인스턴스
- **Terminating Instances**: 종료 중인 인스턴스

</details>

<details>
<summary>📊 모니터링 ["3교시: 150분"]</summary>

### Prometheus
오픈소스 모니터링 및 알림 시스템으로 메트릭 수집과 저장을 담당합니다.

#### Prometheus 특징
- **Pull 기반**: 메트릭을 직접 수집
- **시계열 데이터베이스**: 시간 기반 데이터 저장
- **쿼리 언어**: PromQL을 통한 강력한 쿼리
- **서비스 디스커버리**: 자동 서비스 발견

#### Prometheus 설정
```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
  
  - job_name: 'application'
    static_configs:
      - targets: ['localhost:3000']
    metrics_path: /metrics
    scrape_interval: 5s
```

### Grafana
시각화 및 대시보드 도구로 Prometheus 데이터를 시각화합니다.

#### Grafana 특징
- **다양한 데이터 소스**: Prometheus, InfluxDB, MySQL 등
- **풍부한 시각화**: 그래프, 테이블, 게이지 등
- **알림 기능**: 임계값 기반 알림
- **대시보드 공유**: 팀 간 대시보드 공유

#### Grafana 대시보드 설정
```json
{
  "dashboard": {
    "title": "Application Monitoring",
    "panels": [
      {
        "title": "CPU Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "100 - [avg[irate[node_cpu_seconds_total{mode=\"idle\"}[5m]]] * 100]",
            "legendFormat": "CPU Usage %"
          }
        ]
      },
      {
        "title": "Memory Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes",
            "legendFormat": "Memory Used"
          }
        ]
      }
    ]
  }
}
```

### Jaeger
분산 추적 시스템으로 마이크로서비스 간 요청 흐름을 추적합니다.

#### Jaeger 특징
- **분산 추적**: 마이크로서비스 간 요청 추적
- **성능 분석**: 병목 지점 식별
- **오류 추적**: 오류 발생 지점 추적
- **의존성 분석**: 서비스 간 의존성 시각화

#### Jaeger 설정
```yaml
# jaeger-config.yml
collector:
  zipkin:
    http-port: 9411

query:
  port: 16686

agent:
  zipkin:
    http-port: 9411
```

### ELK Stack
Elasticsearch, Logstash, Kibana를 활용한 로그 분석 시스템입니다.

#### Elasticsearch
- **용도**: 로그 데이터 저장 및 검색
- **특징**: 분산 검색 엔진
- **장점**: 빠른 검색, 확장성

#### Logstash
- **용도**: 로그 데이터 수집 및 변환
- **특징**: 다양한 입력 소스 지원
- **장점**: 실시간 처리, 필터링

#### Kibana
- **용도**: 로그 데이터 시각화
- **특징**: 웹 기반 인터페이스
- **장점**: 직관적 검색, 대시보드

#### ELK Stack 설정
```yaml
# docker-compose.yml
version: '3.8'
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.15.0
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ports:
      - "9200:9200"
  
  logstash:
    image: docker.elastic.co/logstash/logstash:7.15.0
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
    ports:
      - "5044:5044"
  
  kibana:
    image: docker.elastic.co/kibana/kibana:7.15.0
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
```

### 모니터링 모범 사례
효과적인 모니터링을 위한 모범 사례입니다.

#### 메트릭 수집
- **인프라 메트릭**: CPU, 메모리, 디스크, 네트워크
- **애플리케이션 메트릭**: 응답 시간, 처리량, 오류율
- **비즈니스 메트릭**: 사용자 수, 거래 수, 수익

#### 알림 설정
- **임계값 기반**: 정적 임계값 설정
- **동적 임계값**: 통계적 이상 탐지
- **에스컬레이션**: 알림 단계별 전달

#### 대시보드 설계
- **계층적 구조**: 전체 → 서비스 → 인스턴스
- **실시간 업데이트**: 1-5초 간격
- **모바일 지원**: 반응형 디자인

</details>

<details>
<summary>💰 비용 최적화 ["4교시: 90분"]</summary>

### 클라우드 비용 분석
클라우드 리소스 사용량과 비용을 분석하여 최적화 방안을 도출합니다.

#### AWS 비용 분석
- **Cost Explorer**: 비용 추세 및 패턴 분석
- **Trusted Advisor**: 비용 최적화 권장사항
- **Billing Alerts**: 비용 임계값 알림

#### GCP 비용 분석
- **Cloud Billing**: 비용 상세 분석
- **Recommender**: 비용 최적화 제안
- **Budget Alerts**: 예산 초과 알림

### 리소스 최적화 전략
비용을 절감하면서 성능을 유지하는 전략입니다.

#### 인스턴스 최적화
- **Right Sizing**: 적절한 인스턴스 크기 선택
- **Reserved Instances**: 예약 인스턴스 활용
- **Spot Instances**: 스팟 인스턴스 활용

#### 스토리지 최적화
- **스토리지 클래스**: 사용 패턴에 따른 클래스 선택
- **라이프사이클 정책**: 자동 아카이빙
- **압축**: 데이터 압축으로 용량 절약

### 비용 모니터링
지속적인 비용 모니터링과 최적화를 위한 도구입니다.

#### 비용 대시보드
- **일일/월간 비용**: 비용 추세 모니터링
- **서비스별 비용**: 서비스별 비용 분석
- **프로젝트별 비용**: 프로젝트별 비용 할당

#### 비용 알림
- **예산 알림**: 예산 초과 시 알림
- **비용 급증 알림**: 비용 급증 시 알림
- **리소스 미사용 알림**: 미사용 리소스 알림

</details>

<details>
<summary>📈 오토스케일링</summary>

### AWS Auto Scaling
- **Instance Group**: 인스턴스 그룹 관리
- **Autoscaler**: 자동 스케일링
- **Load Balancing**: 로드밸런싱 통합

### 스케일링 정책
- **Target Tracking**: CPU, 메모리 사용률 기반
- **Step Scaling**: 단계별 스케일링
- **Simple Scaling**: 단순 스케일링
- **Scheduled Scaling**: 시간 기반 스케일링

</details>

<details>
<summary>📊 클라우드 네이티브 모니터링</summary>

### AWS CloudWatch
- **메트릭 수집**: EC2, RDS, ELB 등 AWS 서비스 메트릭
- **로그 관리**: CloudWatch Logs를 통한 중앙화된 로그 관리
- **알림**: CloudWatch Alarms를 통한 임계값 기반 알림
- **대시보드**: CloudWatch Dashboard를 통한 시각적 모니터링

### GCP Cloud Monitoring
- **메트릭 수집**: Compute Engine, Cloud SQL 등 GCP 서비스 메트릭
- **로그 관리**: Cloud Logging을 통한 중앙화된 로그 관리
- **알림**: Alerting Policy를 통한 임계값 기반 알림
- **대시보드**: Monitoring Dashboard를 통한 시각적 모니터링

### 실무 모니터링 전략
- **애플리케이션 메트릭**: CPU, 메모리, 디스크, 네트워크 사용률
- **비즈니스 메트릭**: 사용자 수, 요청 수, 응답 시간, 오류율
- **인프라 메트릭**: 서버 상태, 데이터베이스 성능, 로드밸런서 상태
- **보안 메트릭**: 로그인 시도, 접근 패턴, 보안 이벤트

</details>

<details>
<summary>💰 비용 최적화</summary>

### AWS 비용 최적화
- **Right Sizing**: 적절한 인스턴스 크기 선택
- **Reserved Instances**: 예약 인스턴스
- **Spot Instances**: 스팟 인스턴스
- **Savings Plans**: 절약 계획

### GCP 비용 최적화
- **Committed Use Discounts**: 약정 사용 할인
- **Sustained Use Discounts**: 지속 사용 할인
- **Preemptible Instances**: 선점 가능 인스턴스

### 비용 분석 도구
- **AWS Cost Explorer**: 비용 분석 및 예측
- **GCP Billing Reports**: 청구서 및 비용 분석
- **Third-party Tools**: CloudHealth, Cloudyn 등

</details>

---

## 🛠️ 실습 가이드

### 1단계: 로드밸런서 설정 ["1교시: 120분"]

#### AWS ALB 설정
```bash
# AWS ALB 생성
aws elbv2 create-load-balancer \
  --name my-alb \
  --subnets subnet-12345 subnet-67890 \
  --security-groups sg-12345

# Target Group 생성
aws elbv2 create-target-group \
  --name my-targets \
  --protocol HTTP \
  --port 3000 \
  --vpc-id vpc-12345

# Target Group에 인스턴스 등록
aws elbv2 register-targets \
  --target-group-arn arn:aws:elasticloadbalancing:region:account:targetgroup/my-targets/1234567890123456 \
  --targets Id=i-1234567890abcdef0,Port=3000

# Listener 생성
aws elbv2 create-listener \
  --load-balancer-arn arn:aws:elasticloadbalancing:region:account:loadbalancer/app/my-alb/1234567890123456 \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:region:account:targetgroup/my-targets/1234567890123456
```

#### GCP HTTP[S] Load Balancer 설정
```bash
# Backend Service 생성
gcloud compute backend-services create my-backend-service \
  --protocol HTTP \
  --health-checks my-health-check \
  --global

# URL Map 생성
gcloud compute url-maps create my-lb \
  --default-service my-backend-service

# Target HTTP Proxy 생성
gcloud compute target-http-proxies create my-lb-proxy \
  --url-map my-lb

# Forwarding Rule 생성
gcloud compute forwarding-rules create my-lb-rule \
  --global \
  --target-http-proxy my-lb-proxy \
  --ports 80
```

#### 로드밸런서 테스트
```bash
# 로드밸런서 DNS 확인
aws elbv2 describe-load-balancers --names my-alb --query 'LoadBalancers[0].DNSName'
gcloud compute forwarding-rules describe my-lb-rule --global --format="value[IPAddress]"

# 헬스 체크 테스트
curl -I http://my-alb-1234567890.us-west-2.elb.amazonaws.com/health
curl -I http://35.123.456.789/health

# 부하 분산 테스트
for i in {1..10}; do
  curl http://my-alb-1234567890.us-west-2.elb.amazonaws.com/
  sleep 1
done
```

### 2단계: 오토스케일링 설정 ["2교시: 120분"]

#### AWS Auto Scaling 설정
```bash
# Launch Template 생성
aws ec2 create-launch-template \
  --launch-template-name my-template \
  --launch-template-data '{
    "ImageId": "ami-12345678",
    "InstanceType": "t3.micro",
    "SecurityGroupIds": ["sg-12345"],
    "UserData": "IyEvYmluL2Jhc2gKc3VkbyB5dW0gdXBkYXRlIC15CnN1ZG8geXVtIGluc3RhbGwgLXkgZG9ja2VyCnN1ZG8gc3lzdGVtY3RsIHN0YXJ0IGRvY2tlcgpzdWRvIHN5c3RlbWN0bCBlbmFibGUgZG9ja2VyCnN1ZG8gdXNlcm1vZCAtYSBHIGRvY2tlciAkVVNFUgpkb2NrZXIgcnVuIC1kIC1wIDMwMDA6MzAwMCBteWFwcA=="
  }'

# Auto Scaling Group 생성
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name my-asg \
  --launch-template LaunchTemplateName=my-template \
  --min-size 1 \
  --max-size 10 \
  --desired-capacity 3 \
  --target-group-arns arn:aws:elasticloadbalancing:region:account:targetgroup/my-targets/1234567890123456

# Scaling Policy 생성
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name my-asg \
  --policy-name scale-out \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration '{
    "TargetValue": 70.0,
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ASGAverageCPUUtilization"
    }
  }'
```

#### GCP MIG 설정
```bash
# Instance Template 생성
gcloud compute instance-templates create my-template \
  --image-family ubuntu-2004-lts \
  --image-project ubuntu-os-cloud \
  --machine-type e2-micro \
  --tags http-server \
  --metadata startup-script='#!/bin/bash
apt-get update
apt-get install -y docker.io
systemctl start docker
systemctl enable docker
usermod -aG docker $USER
docker run -d -p 3000:3000 myapp'

# Managed Instance Group 생성
gcloud compute instance-groups managed create my-mig \
  --template my-template \
  --size 3 \
  --zone us-central1-a

# Autoscaler 생성
gcloud compute instance-groups managed set-autoscaling my-mig \
  --zone us-central1-a \
  --max-num-replicas 10 \
  --min-num-replicas 1 \
  --target-cpu-utilization 0.6
```

#### 오토스케일링 테스트
```bash
# CPU 부하 생성 ["스케일 아웃 테스트"]
for i in {1..5}; do
  ssh -i my-key.pem ubuntu@$[aws ec2 describe-instances --query 'Reservations[0].Instances[0].PublicIpAddress' --output text] \
    "yes > /dev/null &"
done

# 인스턴스 수 확인
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names my-asg \
  --query 'AutoScalingGroups[0].Instances[*].InstanceId' --output table

gcloud compute instance-groups managed list-instances my-mig --zone us-central1-a
```

### 3단계: 모니터링 설정 ["3교시: 150분"]

#### Prometheus 설정
```bash
# Prometheus 설정 파일 생성
cat > prometheus.yml << EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
  
  - job_name: 'application'
    static_configs:
      - targets: ['localhost:3000']
    metrics_path: /metrics
    scrape_interval: 5s
EOF

# Prometheus 실행
docker run -d \
  --name prometheus \
  -p 9090:9090 \
  -v $[pwd]/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus
```

#### Grafana 설정
```bash
# Grafana 실행
docker run -d \
  --name grafana \
  -p 3001:3000 \
  -e "GF_SECURITY_ADMIN_PASSWORD=admin" \
  grafana/grafana

# Prometheus 데이터 소스 추가
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://prometheus:9090",
    "access": "proxy"
  }' \
  http://admin:admin@localhost:3001/api/datasources
```

#### Jaeger 설정
```bash
# Jaeger 실행
docker run -d \
  --name jaeger \
  -p 16686:16686 \
  -p 14268:14268 \
  jaegertracing/all-in-one:latest
```

#### ELK Stack 설정
```bash
# ELK Stack 실행
cat > docker-compose.elk.yml << EOF
version: '3.8'
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.15.0
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ports:
      - "9200:9200"
  
  logstash:
    image: docker.elastic.co/logstash/logstash:7.15.0
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
    ports:
      - "5044:5044"
    depends_on:
      - elasticsearch
  
  kibana:
    image: docker.elastic.co/kibana/kibana:7.15.0
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch
EOF

docker-compose -f docker-compose.elk.yml up -d
```

### 4단계: 비용 최적화 ["4교시: 90분"]

#### AWS 비용 분석
```bash
# Cost Explorer 활성화
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost

# Trusted Advisor 권장사항 확인
aws support describe-trusted-advisor-checks \
  --language en \
  --query 'checks[?category==`cost_optimizing`]'

# Reserved Instance 권장사항 확인
aws ce get-reservation-coverage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY
```

#### GCP 비용 분석
```bash
# Billing API 활성화
gcloud services enable cloudbilling.googleapis.com

# 비용 정보 조회
gcloud billing budgets list --billing-account=123456-789ABC-DEF012

# Recommender 권장사항 확인
gcloud recommender recommendations list \
  --recommender=google.compute.instance.MachineTypeRecommender \
  --project=my-project
```

#### 비용 최적화 실행
```bash
# 스팟 인스턴스로 전환
aws ec2 request-spot-instances \
  --spot-price "0.01" \
  --instance-count 1 \
  --type "one-time" \
  --launch-specification '{
    "ImageId": "ami-12345678",
    "InstanceType": "t3.micro",
    "SecurityGroupIds": ["sg-12345"]
  }'

# Preemptible 인스턴스로 전환
gcloud compute instances create my-preemptible \
  --image-family ubuntu-2004-lts \
  --image-project ubuntu-os-cloud \
  --machine-type e2-micro \
  --preemptible
```

### 5단계: 통합 테스트 및 검증

#### 전체 시스템 테스트
```bash
# 로드밸런서 테스트
curl -I http://my-alb-1234567890.us-west-2.elb.amazonaws.com/health

# 오토스케일링 테스트
# CPU 부하 생성 후 인스턴스 수 확인

# 모니터링 대시보드 확인
# Grafana: http://localhost:3001
# Jaeger: http://localhost:16686
# Kibana: http://localhost:5601

# 비용 모니터링 확인
# AWS Cost Explorer
# GCP Cloud Billing
```

#### 성능 벤치마크
```bash
# Apache Bench를 사용한 부하 테스트
ab -n 1000 -c 10 http://my-alb-1234567890.us-west-2.elb.amazonaws.com/

# 응답 시간 측정
curl -w "@curl-format.txt" -o /dev/null -s http://my-alb-1234567890.us-west-2.elb.amazonaws.com/
```

## 🎯 Day 3 수업 결과 요약 ["2024년 9월 22일"]

### ✅ 전체 성과
- **수강생 수**: 15명
- **완료율**: 100% ["모든 학습자 성공"]
- **총 소요 시간**: 8시간 ["예상 8시간"]
- **주요 성과**: 프로덕션 수준의 고가용성 아키텍처 구축 완료

### 📊 교시별 성과
| 교시 | 내용 | 소요 시간 | 성공률 | 주요 성과 |
|------|------|-----------|--------|-----------|
| 1교시 | 로드밸런싱 | 120분 | 100% | AWS ALB, GCP Cloud LB 구축 |
| 2교시 | 오토스케일링 | 120분 | 100% | AWS Auto Scaling, GCP MIG 구축 |
| 3교시 | 모니터링 | 150분 | 100% | Prometheus, Grafana, Jaeger, ELK 구축 |
| 4교시 | 비용 최적화 | 90분 | 100% | 클라우드 비용 분석 및 최적화 |

### 🔑 핵심 성공 요인
1. **로드밸런싱**: AWS ALB와 GCP Cloud LB를 통한 고가용성 확보
2. **오토스케일링**: CPU 기반 자동 스케일링으로 비용 효율성 달성
3. **모니터링**: Prometheus, Grafana, Jaeger, ELK를 통한 종합 모니터링
4. **비용 최적화**: 스팟/프리엠티블 인스턴스 활용으로 비용 절감

### 💡 학습자 피드백
- "로드밸런서와 오토스케일링을 통해 실제 프로덕션 환경과 동일한 구조를 구축해보니 운영 환경에 대한 이해가 깊어졌다"
- "Prometheus와 Grafana를 통해 시스템을 실시간으로 모니터링할 수 있어서 정말 유용하다"
- "비용 최적화를 통해 클라우드 비용을 절감할 수 있는 방법을 알게 되어 실무에 바로 적용할 수 있겠다"

<details>
<summary>⚖️ 로드밸런싱 실습</summary>

### 1단계: AWS ALB 생성

**방법 1: 자동화 스크립트 사용 ["권장"]**
```bash
# 로드밸런서 자동 설정
chmod +x ../../repos/day1/cloud-scripts/load-balancer-setup.sh
./../../repos/day1/cloud-scripts/load-balancer-setup.sh aws
```

**방법 2: 수동 명령어 실행**
```bash
# 보안 그룹 생성
aws ec2 create-security-group \
  --group-name my-alb-sg \
  --description "Security group for ALB"

# ALB 생성
aws elbv2 create-load-balancer \
  --name my-alb \
  --subnets subnet-12345678 subnet-87654321 \
  --security-groups sg-12345678

# 타겟 그룹 생성
aws elbv2 create-target-group \
  --name my-targets \
  --protocol HTTP \
  --port 3000 \
  --vpc-id vpc-12345678

# 리스너 생성
aws elbv2 create-listener \
  --load-balancer-arn arn:aws:elasticloadbalancing:region:account:loadbalancer/app/my-alb/1234567890123456 \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:region:account:targetgroup/my-targets/1234567890123456
```

### 2단계: GCP HTTP[S] Load Balancing
```bash
# 인스턴스 그룹 생성
gcloud compute instance-groups unmanaged create my-instance-group \
  --zone=us-central1-a

# 인스턴스 그룹에 인스턴스 추가
gcloud compute instance-groups unmanaged add-instances my-instance-group \
  --instances=my-vm-1,my-vm-2 \
  --zone=us-central1-a

# 백엔드 서비스 생성
gcloud compute backend-services create my-backend-service \
  --protocol=HTTP \
  --port-name=http \
  --health-checks=my-health-check \
  --global

# URL 맵 생성
gcloud compute url-maps create my-url-map \
  --default-service=my-backend-service

# HTTP 프록시 생성
gcloud compute target-http-proxies create my-http-proxy \
  --url-map=my-url-map

# 전역 포워딩 규칙 생성
gcloud compute forwarding-rules create my-forwarding-rule \
  --global \
  --target-http-proxy=my-http-proxy \
  --ports=80
```

### 3단계: 로드밸런싱 테스트
```bash
# ALB DNS 이름 확인
aws elbv2 describe-load-balancers --names my-alb

# GCP 로드밸런서 IP 확인
gcloud compute forwarding-rules describe my-forwarding-rule --global

# 로드밸런싱 테스트
curl http://my-alb-1234567890.us-west-2.elb.amazonaws.com
curl http://35.123.456.789
```

</details>

<details>
<summary>📈 오토스케일링 실습</summary>

### 1단계: AWS Auto Scaling Group
```bash
# Launch Template 생성
aws ec2 create-launch-template \
  --launch-template-name my-template \
  --launch-template-data '{
    "ImageId": "ami-0abcdef1234567890",
    "InstanceType": "t2.micro",
    "SecurityGroupIds": ["sg-12345678"],
    "UserData": "IyEvYmluL2Jhc2gKc3VkbyB5dW0gdXBkYXRlIC15CnN1ZG8geXVtIGluc3RhbGwgLXkgZG9ja2VyCnN1ZG8gc3lzdGVtY3RsIHN0YXJ0IGRvY2tlcgpzdWRvIHN5c3RlbWN0bCBlbmFibGUgZG9ja2VyCnVzZXJtb2QgLWEgLUcgZG9ja2VyIGVjMi11c2Vy"
  }'

# Auto Scaling Group 생성
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name my-asg \
  --launch-template LaunchTemplateName=my-template,Version='$Latest' \
  --min-size 1 \
  --max-size 10 \
  --desired-capacity 2 \
  --vpc-zone-identifier "subnet-12345678,subnet-87654321"

# Target Tracking Policy 생성
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name my-asg \
  --policy-name my-target-tracking-policy \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration '{
    "TargetValue": 70.0,
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ASGAverageCPUUtilization"
    }
  }'
```

### 2단계: GCP Managed Instance Group
```bash
# 인스턴스 템플릿 생성
gcloud compute instance-templates create my-template \
  --machine-type=e2-micro \
  --image-family=ubuntu-2004-lts \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=10GB \
  --boot-disk-type=pd-standard

# Managed Instance Group 생성
gcloud compute instance-groups managed create my-mig \
  --template=my-template \
  --size=2 \
  --zone=us-central1-a

# Autoscaler 생성
gcloud compute instance-groups managed set-autoscaling my-mig \
  --zone=us-central1-a \
  --max-num-replicas=10 \
  --min-num-replicas=1 \
  --target-cpu-utilization=0.7
```

### 3단계: 스케일링 테스트
```bash
# CPU 사용률 증가 ["스케일링 트리거"]
stress --cpu 1 --timeout 300

# Auto Scaling Group 상태 확인
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names my-asg

# Managed Instance Group 상태 확인
gcloud compute instance-groups managed list-instances my-mig --zone=us-central1-a
```

</details>

<details>
<summary>📊 클라우드 모니터링 실습</summary>

### 1단계: AWS CloudWatch 모니터링 설정

**Day1, Day2 연계**: 기존 VM 환경 활용
```bash
# AWS VM에 접속하여 CloudWatch 에이전트 설치
ssh -i aws-key.pem ubuntu@[AWS-VM-IP]  # AWS: .pem 파일 사용

# CloudWatch 에이전트 설치
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i amazon-cloudwatch-agent.deb

# CloudWatch 에이전트 설정
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
```

### 2단계: GCP Cloud Monitoring 설정
```bash
# GCP VM에 접속하여 Monitoring 에이전트 설치
ssh -i gcp-key ubuntu@[GCP-VM-IP]  # GCP: OpenSSH 키 사용

# Monitoring 에이전트 설치
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install

# 에이전트 시작
sudo systemctl start google-cloud-ops-agent
sudo systemctl enable google-cloud-ops-agent
```

### 3단계: 모니터링 대시보드 구성

**AWS CloudWatch Dashboard**
```bash
# AWS CLI를 통한 대시보드 생성
aws cloudwatch put-dashboard \
  --dashboard-name "CloudMaster-Monitoring" \
  --dashboard-body '{
    "widgets": [
      {
        "type": "metric",
        "properties": {
          "metrics": [
            ["AWS/EC2", "CPUUtilization", "InstanceId", "i-1234567890abcdef0"]
          ],
          "period": 300,
          "stat": "Average",
          "region": "us-west-2",
          "title": "EC2 CPU Utilization"
        }
      }
    ]
  }'
```

**GCP Monitoring Dashboard**
```bash
# GCP CLI를 통한 대시보드 생성
gcloud monitoring dashboards create \
  --config-from-file=dashboard-config.json
```

### 4단계: 알림 정책 설정

**AWS CloudWatch Alarms**
```bash
# CPU 사용률 알림 설정
aws cloudwatch put-metric-alarm \
  --alarm-name "High-CPU-Utilization" \
  --alarm-description "Alert when CPU exceeds 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2
```

**GCP Alerting Policy**
```bash
# GCP 알림 정책 생성
gcloud alpha monitoring policies create \
  --policy-from-file=alert-policy.yaml
```

### 5단계: 모니터링 테스트
```bash
# CPU 사용률 증가 ["알림 트리거"]
stress --cpu 1 --timeout 300

# CloudWatch 메트릭 확인
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --period 300 \
  --statistics Average

# GCP 메트릭 확인
gcloud monitoring metrics list \
  --filter="metric.type=compute.googleapis.com/instance/cpu/utilization"
```

</details>

<details>
<summary>💰 비용 최적화 실습</summary>

### 1단계: AWS 비용 분석

**방법 1: 자동화 스크립트 사용 ["권장"]**
```bash
# 비용 최적화 스크립트 실행
chmod +x ../../repos/day1/cloud-scripts/cost-optimization.sh
./../../repos/day1/cloud-scripts/cost-optimization.sh aws
```

**방법 2: 수동 명령어 실행**
```bash
# Cost Explorer API 사용
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost

# Reserved Instances 권장사항 조회
aws ce get-reservation-coverage \
  --time-period Start=2024-01-01,End=2024-01-31

# Right Sizing 권장사항 조회
aws ce get-right-sizing-recommendation \
  --service=AmazonEC2
```

### 2단계: GCP 비용 분석
```bash
# 청구서 정보 조회
gcloud billing accounts list

# 프로젝트별 비용 조회
gcloud billing budgets list --billing-account=123456789012

# 커밋 사용 할인 권장사항 조회
gcloud compute commitments list --regions=us-central1
```

### 3단계: 비용 최적화 전략 수립
```bash
# 인스턴스 크기 최적화
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name]' \
  --output table

# 사용하지 않는 리소스 식별
aws ec2 describe-volumes \
  --filters "Name=status,Values=available" \
  --query 'Volumes[*].[VolumeId,Size,State]' \
  --output table

# 스팟 인스턴스 가격 조회
aws ec2 describe-spot-price-history \
  --instance-types t2.micro \
  --product-descriptions "Linux/UNIX" \
  --max-items 10
```

</details>

---

## 🧹 실습 정리

### 자동 정리

**방법 1: 통합 정리 스크립트 사용 ["권장"]**
```bash
# 통합 클러스터 정리 스크립트 실행
chmod +x ../../repos/day1/cloud-scripts/cluster-cleanup-interactive.sh
./../../repos/day1/cloud-scripts/cluster-cleanup-interactive.sh

# 통합 VM 정리 스크립트 실행
chmod +x ../../repos/day1/cloud-scripts/vm-cleanup-interactive.sh
./../../repos/day1/cloud-scripts/vm-cleanup-interactive.sh

# 환경 체크 도구에서 정리 메뉴 사용
chmod +x ../../repos/day1/cloud-scripts/environment-check-wsl.sh
./../../repos/day1/cloud-scripts/environment-check-wsl.sh
```

**방법 2: 개별 정리 명령어**
```bash
# AWS 리소스 정리
aws elbv2 delete-load-balancer --load-balancer-arn arn:aws:elasticloadbalancing:region:account:loadbalancer/app/my-alb/1234567890123456
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name my-asg --force-delete
aws ec2 delete-launch-template --launch-template-name my-template

# GCP 리소스 정리
gcloud compute forwarding-rules delete my-forwarding-rule --global
gcloud compute instance-groups managed delete my-mig --zone=us-central1-a
gcloud compute instance-templates delete my-template

# Docker 컨테이너 정리
docker stop prometheus grafana node-exporter alertmanager
docker rm prometheus grafana node-exporter alertmanager
```

### 수동 정리 체크리스트
- [ ] AWS 로드밸런서 삭제
- [ ] AWS Auto Scaling Group 삭제
- [ ] GCP 로드밸런서 삭제
- [ ] GCP Managed Instance Group 삭제
- [ ] 모니터링 컨테이너 정리
- [ ] 사용하지 않는 리소스 정리
- [ ] 생성된 SSH 키 정리
- [ ] 로컬 프로젝트 파일 정리

---

## 📚 참고 자료

### 상세 가이드
- ["GitHub Actions 실습 가이드"][cloud_master/textbook/Day3/guides/github-actions-tutorial.md] - GitHub Actions CI/CD 파이프라인
- ["Cloud Scripts 동작 원리 가이드"][cloud_master/textbook/Day3/guides/cloud-scripts-operation-guide.md] - 스크립트 동작 원리 상세 설명
- ["로드 밸런싱 가이드"][cloud_master/textbook/Day3/guides/load-balancing-guide.md] - 고급 로드 밸런싱 설정
- ["오토스케일링 가이드"][cloud_master/textbook/Day3/guides/auto-scaling-guide.md] - 자동 스케일링 정책 설정
- ["모니터링 설정 가이드"][cloud_master/textbook/Day3/guides/monitoring-setup-guide.md] - Prometheus & Grafana 설정
- ["비용 최적화 가이드"][cloud_master/textbook/Day3/guides/cost-optimization-guide.md] - 클라우드 비용 관리
- ["통합 가이드"][cloud_master/textbook/Day3/guides/integration-guide.md] - 전체 시스템 통합
- ["재해 복구 가이드"][cloud_master/textbook/Day3/guides/disaster-recovery-guide.md] - 고가용성 아키텍처
- ["트러블슈팅 가이드"][cloud_master/textbook/Day3/guides/troubleshooting-guide.md] - 문제 해결 및 디버깅

### 공식 문서
- ["GitHub Actions 공식 자습서"][https://docs.github.com/ko/actions/tutorials]
- ["GitHub Actions 워크플로우 구문"][https://docs.github.com/ko/actions/using-workflows/workflow-syntax-for-github-actions]
- ["AWS ELB 공식 문서"][https://docs.aws.amazon.com/elasticloadbalancing/]
- ["AWS Auto Scaling 공식 문서"][https://docs.aws.amazon.com/autoscaling/]
- ["GCP Load Balancing 공식 문서"][https://cloud.google.com/load-balancing/docs]
- ["Prometheus 공식 문서"][https://prometheus.io/docs/]
- ["Grafana 공식 문서"][https://grafana.com/docs/]

### 문제 해결
1. **로드밸런싱 실패**: 보안 그룹 및 타겟 그룹 설정 확인
2. **오토스케일링 실패**: 스케일링 정책 및 메트릭 설정 확인
3. **모니터링 실패**: Prometheus 설정 및 데이터 소스 연결 확인
4. **비용 최적화 실패**: 권한 및 API 설정 확인

---

<div align="center">

["← 이전: Day 2"][../Day2/README.md] | 
["📚 전체 커리큘럼"][../../../curriculum.md] | 
["🏠 학습 경로로 돌아가기"][../../../index.md] | 
["다음: Cloud Container 과정 →"][../../../cloud_container/README.md]

</div>