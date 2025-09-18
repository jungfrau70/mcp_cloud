# Cloud Master - 3일차: 모니터링 및 로깅 실습

<details>
<summary>📋 목차</summary>

[📚 이론 학습](#-)

[🛠️ 실습 학습](#실습-학습)

[📚 참고 자료](#참고-자료)

[📚 문제 해결 및 참고 자료](#-)

</details>

---

## 🎯 학습 목표

### 핵심 학습 목표

- **Prometheus 기초** 메트릭 수집 및 저장
- **Grafana 대시보드** 시각화 및 모니터링
- **로드 밸런싱** 트래픽 분산 및 고가용성
- **Auto Scaling** 자동 확장 및 축소

### 실습 후 달성할 수 있는 능력

- ✅ Prometheus로 메트릭 수집 및 저장
- ✅ Grafana로 대시보드 구축
- ✅ 로드 밸런서 구성 및 관리
- ✅ Auto Scaling 정책 설정

### 예상 소요 시간

- **Prometheus 설정**: 90-120분
- **Grafana 대시보드**: 60-90분
- **로드 밸런싱**: 90-120분
- **Auto Scaling**: 60-90분
- **전체 과정**: 5-7시간

---

## 🛠️ 실습 학습

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/mcp_knowledge_base/cloud_master/repos/samples/day3/my-app/`
- **자동화 스크립트**: `/mcp_knowledge_base/cloud_master/repos/automation/day3/monitoring-practice-automation.sh`
- **클라우드 스크립트**: `/mcp_knowledge_base/cloud_master/repos/cloud-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구

- **Docker Compose**: 멀티 컨테이너 관리
- **kubectl**: Kubernetes 클러스터 관리
- **AWS CLI**: AWS 리소스 관리
- **gcloud CLI**: GCP 리소스 관리

#### 환경 설정

```bash
# Docker Compose 설치 확인
docker-compose --version

# kubectl 설치 확인
kubectl version --client

# AWS CLI 설정 확인
aws sts get-caller-identity

# gcloud 설정 확인
gcloud auth list
```

</details>

<details>
<summary>📊 1단계: Prometheus 설정</summary>

#### Prometheus 구성

```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
  
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']
```

#### Docker Compose로 실행

```yaml
# docker-compose.yml
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'

  node-exporter:
    image: prom/node-exporter:latest
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    privileged: true
    devices:
      - /dev/kmsg
```

```bash
# 서비스 시작
docker-compose up -d

# 상태 확인
docker-compose ps

# Prometheus 접근
open http://localhost:9090
```

</details>

<details>
<summary>📈 2단계: Grafana 대시보드</summary>

#### Grafana 설정

```yaml
# docker-compose.yml에 추가
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-storage:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
```

#### 대시보드 구성

```bash
# Grafana 접근
open http://localhost:3000

# 로그인 (admin/admin)
# Prometheus 데이터소스 추가
# 대시보드 임포트
```

</details>

<details>
<summary>⚖️ 3단계: 로드 밸런싱</summary>

#### AWS ALB 설정

```bash
# ALB 생성
aws elbv2 create-load-balancer /
    --name my-load-balancer /
    --subnets subnet-12345 subnet-67890 /
    --security-groups sg-12345

# 타겟 그룹 생성
aws elbv2 create-target-group /
    --name my-targets /
    --protocol HTTP /
    --port 80 /
    --vpc-id vpc-12345

# 리스너 생성
aws elbv2 create-listener /
    --load-balancer-arn arn:aws:elasticloadbalancing:region:account:loadbalancer/app/my-load-balancer/1234567890123456 /
    --protocol HTTP /
    --port 80 /
    --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:region:account:targetgroup/my-targets/1234567890123456
```

#### GCP Load Balancer 설정

```bash
# 백엔드 서비스 생성
gcloud compute backend-services create my-backend-service /
    --global /
    --protocol HTTP /
    --health-checks my-health-check

# URL 맵 생성
gcloud compute url-maps create my-url-map /
    --default-service my-backend-service

# 타겟 프록시 생성
gcloud compute target-http-proxies create my-target-proxy /
    --url-map my-url-map

# 글로벌 포워딩 규칙 생성
gcloud compute forwarding-rules create my-forwarding-rule /
    --global /
    --target-http-proxy my-target-proxy /
    --ports 80
```

</details>

<details>
<summary>🔄 4단계: Auto Scaling</summary>

#### AWS Auto Scaling Group

```bash
# Launch Template 생성
aws ec2 create-launch-template /
    --launch-template-name my-template /
    --launch-template-data '{
        "ImageId": "ami-12345",
        "InstanceType": "t2.micro",
        "UserData": "#!/bin/bash/necho Hello World"
    }'

# Auto Scaling Group 생성
aws autoscaling create-auto-scaling-group /
    --auto-scaling-group-name my-asg /
    --launch-template LaunchTemplateName=my-template /
    --min-size 1 /
    --max-size 10 /
    --desired-capacity 2 /
    --vpc-zone-identifier "subnet-12345,subnet-67890"
```

#### GCP Managed Instance Group

```bash
# 인스턴스 템플릿 생성
gcloud compute instance-templates create my-template /
    --machine-type e2-micro /
    --image-family debian-9 /
    --image-project debian-cloud

# Managed Instance Group 생성
gcloud compute instance-groups managed create my-mig /
    --template my-template /
    --size 2 /
    --zone us-central1-a

# Auto Scaling 정책 설정
gcloud compute instance-groups managed set-autoscaling my-mig /
    --max-num-replicas 10 /
    --min-num-replicas 1 /
    --target-cpu-utilization 0.6 /
    --zone us-central1-a
```

</details>

---

## 📚 참고 자료

### 유용한 명령어

```bash
# Docker Compose 관리
docker-compose up -d
docker-compose down
docker-compose logs -f

# Kubernetes 모니터링
kubectl top nodes
kubectl top pods
kubectl get events

# AWS 모니터링
aws cloudwatch get-metric-statistics
aws autoscaling describe-auto-scaling-groups

# GCP 모니터링
gcloud monitoring metrics list
gcloud compute instance-groups managed list
```

### 문제 해결

1. **Prometheus 메트릭 수집 실패**
   - 네트워크 연결 확인
   - 포트 접근 확인

2. **Grafana 대시보드 로드 실패**
   - 데이터소스 연결 확인
   - 권한 설정 확인

3. **로드 밸런서 헬스 체크 실패**
   - 백엔드 서버 상태 확인
   - 방화벽 규칙 확인

4. **Auto Scaling 작동 안함**
   - 메트릭 설정 확인
   - 임계값 설정 확인

---

## 🧹 실습 정리

### 자동 정리

```bash
# 자동화 스크립트로 정리
./mcp_knowledge_base/cloud_master/repos/automation/day3/monitoring-practice-automation.sh --cleanup
```

### 수동 정리

```bash
# Docker Compose 정리
docker-compose down -v

# Kubernetes 리소스 정리
kubectl delete all --all

# AWS 리소스 정리
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name my-asg
aws elbv2 delete-load-balancer --load-balancer-arn arn:aws:elasticloadbalancing:region:account:loadbalancer/app/my-load-balancer/1234567890123456

# GCP 리소스 정리
gcloud compute instance-groups managed delete my-mig --zone us-central1-a
gcloud compute forwarding-rules delete my-forwarding-rule --global
```

### 정리 확인

- [ ] 모든 컨테이너 중지 및 삭제
- [ ] 모든 Kubernetes 리소스 삭제
- [ ] AWS 리소스 정리
- [ ] GCP 리소스 정리
- [ ] 모니터링 스택 정리
