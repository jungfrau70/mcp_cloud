# Cloud Master - 3일차: 로드밸런싱 & 모니터링 & 비용 최적화

## 🎯 학습 목표

### 핵심 학습 목표
- **로드밸런싱**: AWS ELB, GCP Cloud Load Balancing을 활용한 트래픽 분산
- **오토스케일링**: 자동 확장/축소 정책 설정 및 관리
- **모니터링**: Prometheus, Grafana를 활용한 모니터링 시스템 구축
- **비용 최적화**: 클라우드 리소스 최적화 및 비용 절감 전략

### 실습 후 달성할 수 있는 능력
- ✅ 로드밸런싱 환경 구성 및 트래픽 분산
- ✅ 오토스케일링 정책 설정 및 자동 확장/축소
- ✅ Prometheus + Grafana 모니터링 시스템 구축
- ✅ 클라우드 비용 분석 및 최적화 전략 수립

### 예상 소요 시간
- **로드밸런싱**: 90-120분
- **오토스케일링**: 90-120분
- **모니터링**: 120-150분
- **비용 최적화**: 90-120분
- **전체 과정**: 6-8시간

---

## 🔧 실습 환경 준비

### 필수 계정
- **AWS 계정**: Free Tier 계정
- **GCP 계정**: Free Tier 계정 ($300 크레딧)
- **GitHub 계정**: 코드 저장소 및 CI/CD

### 필수 도구
- **AWS CLI**: AWS 서비스 관리
- **GCP CLI**: GCP 서비스 관리
- **kubectl**: Kubernetes 클러스터 관리
- **Docker**: 컨테이너 실행 환경

### 환경 설정
```bash
# AWS CLI 설치 확인
aws --version

# GCP CLI 설치 확인
gcloud --version

# kubectl 설치 확인
kubectl version --client

# Docker 설치 확인
docker --version
```

---

## 📚 이론 학습

<details>
<summary>⚖️ 로드밸런싱</summary>

### AWS ELB (Elastic Load Balancing)
- **ALB (Application Load Balancer)**: HTTP/HTTPS 트래픽
- **NLB (Network Load Balancer)**: TCP/UDP 트래픽
- **CLB (Classic Load Balancer)**: 레거시 로드밸런서

### GCP Cloud Load Balancing
- **HTTP(S) Load Balancing**: HTTP/HTTPS 트래픽
- **TCP/UDP Load Balancing**: TCP/UDP 트래픽
- **Internal Load Balancing**: 내부 트래픽

### 로드밸런싱 알고리즘
- **Round Robin**: 순차적 분산
- **Least Connections**: 최소 연결 수
- **IP Hash**: IP 기반 분산
- **Weighted**: 가중치 기반 분산

</details>

<details>
<summary>📈 오토스케일링</summary>

### AWS Auto Scaling
- **Auto Scaling Group**: 인스턴스 그룹 관리
- **Scaling Policy**: 확장/축소 정책
- **Target Tracking**: 목표 지표 기반 스케일링

### GCP Managed Instance Group
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
<summary>📊 모니터링</summary>

### Prometheus
- **메트릭 수집**: 애플리케이션 메트릭 수집
- **시계열 데이터베이스**: 메트릭 저장
- **쿼리 언어**: PromQL을 통한 메트릭 쿼리

### Grafana
- **대시보드**: 시각적 모니터링
- **알림**: 임계값 기반 알림
- **데이터 소스**: Prometheus 연동

### ELK Stack
- **Elasticsearch**: 로그 검색 및 분석
- **Logstash**: 로그 수집 및 처리
- **Kibana**: 로그 시각화

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

## 🛠️ 실습 학습

> 📚 **상세 실습 가이드**: 각 주제별 상세한 실습은 다음 파일들을 참조하세요.
> - [로드 밸런싱 실습](practices/load-balancing.md)
> - [오토스케일링 실습](practices/auto-scaling.md)
> - [모니터링 기초 실습](practices/monitoring-basics.md)
> - [비용 최적화 실습](practices/cost-optimization.md)

<details>
<summary>⚖️ 로드밸런싱 실습</summary>

### 1단계: AWS ALB 생성
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

### 2단계: GCP HTTP(S) Load Balancing
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
# CPU 사용률 증가 (스케일링 트리거)
stress --cpu 1 --timeout 300

# Auto Scaling Group 상태 확인
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names my-asg

# Managed Instance Group 상태 확인
gcloud compute instance-groups managed list-instances my-mig --zone=us-central1-a
```

</details>

<details>
<summary>📊 모니터링 실습</summary>

### 1단계: Prometheus 설치
```bash
# Prometheus 설정 파일 생성
cat > prometheus.yml << EOF
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
EOF

# Prometheus 실행
docker run -d \
  --name prometheus \
  -p 9090:9090 \
  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus

# Node Exporter 실행
docker run -d \
  --name node-exporter \
  -p 9100:9100 \
  prom/node-exporter
```

### 2단계: Grafana 설치
```bash
# Grafana 실행
docker run -d \
  --name grafana \
  -p 3000:3000 \
  grafana/grafana

# Grafana 접속
# http://localhost:3000
# admin/admin
```

### 3단계: 대시보드 생성
```bash
# Prometheus 데이터 소스 추가
# Grafana > Configuration > Data Sources > Add data source
# URL: http://prometheus:9090

# 대시보드 생성
# Grafana > Create > Dashboard
# Panel 추가 및 메트릭 설정
```

### 4단계: 알림 설정
```bash
# AlertManager 설정
cat > alertmanager.yml << EOF
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alertmanager@example.com'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
- name: 'web.hook'
  webhook_configs:
  - url: 'http://127.0.0.1:5001/'
EOF

# AlertManager 실행
docker run -d \
  --name alertmanager \
  -p 9093:9093 \
  -v $(pwd)/alertmanager.yml:/etc/alertmanager/alertmanager.yml \
  prom/alertmanager
```

</details>

<details>
<summary>💰 비용 최적화 실습</summary>

### 1단계: AWS 비용 분석
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

### 수동 정리
- [ ] AWS 로드밸런서 삭제
- [ ] AWS Auto Scaling Group 삭제
- [ ] GCP 로드밸런서 삭제
- [ ] GCP Managed Instance Group 삭제
- [ ] 모니터링 컨테이너 정리
- [ ] 사용하지 않는 리소스 정리

---

## 📚 참고 자료

### 상세 가이드
- [로드 밸런싱 가이드](guides/load-balancing-guide.md) - 고급 로드 밸런싱 설정
- [오토스케일링 가이드](guides/auto-scaling-guide.md) - 자동 스케일링 정책 설정
- [모니터링 설정 가이드](guides/monitoring-setup-guide.md) - Prometheus & Grafana 설정
- [비용 최적화 가이드](guides/cost-optimization-guide.md) - 클라우드 비용 관리
- [통합 가이드](guides/integration-guide.md) - 전체 시스템 통합
- [재해 복구 가이드](guides/disaster-recovery-guide.md) - 고가용성 아키텍처
- [트러블슈팅 가이드](guides/troubleshooting-guide.md) - 문제 해결 및 디버깅

### 공식 문서
- [AWS ELB 공식 문서](https://docs.aws.amazon.com/elasticloadbalancing/)
- [AWS Auto Scaling 공식 문서](https://docs.aws.amazon.com/autoscaling/)
- [GCP Load Balancing 공식 문서](https://cloud.google.com/load-balancing/docs)
- [Prometheus 공식 문서](https://prometheus.io/docs/)
- [Grafana 공식 문서](https://grafana.com/docs/)

### 문제 해결
1. **로드밸런싱 실패**: 보안 그룹 및 타겟 그룹 설정 확인
2. **오토스케일링 실패**: 스케일링 정책 및 메트릭 설정 확인
3. **모니터링 실패**: Prometheus 설정 및 데이터 소스 연결 확인
4. **비용 최적화 실패**: 권한 및 API 설정 확인

---

<div align="center">

[← 이전: Day 2](../Day2/README.md) | 
[📚 전체 커리큘럼](../../../curriculum.md) | 
[🏠 학습 경로로 돌아가기](../../../index.md) | 
[다음: Cloud Container 과정 →](../../../cloud_container/README.md)

</div>