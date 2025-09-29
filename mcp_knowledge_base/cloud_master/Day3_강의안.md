# Cloud Master - 3일차 강의안

> 📋 **강의 일시**: 2024년 9월 24일 ["수"] 9:00~17:00  
> 📋 **강의 방식**: 온라인 실습 중심  
> 📋 **선수 학습**: Day1, Day2 완료 ["기본 배포, 다중 서비스 환경"]
> 📋 **WSL 환경설정**: [cloud_master/_setup_wsl/README.md](_setup_wsl/README.md)
> 📋 **실습 코드**: `git clone https://github.com/jungfrau70/cloud-master.git cloud_master`

---

## 🎯 3일차 학습 목표

### 핵심 목표
- **기존 VM 활용**: Day1, Day2에서 배포된 VM을 활용한 로드밸런싱
- **로드밸런싱**: AWS ALB + GCP Cloud Load Balancing 구축
- **모니터링**: Prometheus + Grafana 통합 모니터링 스택
- **비용 최적화**: 클라우드 리소스 최적화 및 분석
- **자동화**: 실습 자동화 스크립트를 통한 효율적 학습

## ⚠️ 실습 전 필수 준비사항

### 🔧 **사전 요구사항 확인**
```bash
# 1. 필수 도구 설치 확인
echo "=== 필수 도구 확인 ==="
command -v aws && echo "✅ AWS CLI 설치됨" || echo "❌ AWS CLI 설치 필요"
command -v gcloud && echo "✅ GCP CLI 설치됨" || echo "❌ GCP CLI 설치 필요"
command -v docker && echo "✅ Docker 설치됨" || echo "❌ Docker 설치 필요"
command -v docker-compose && echo "✅ Docker Compose 설치됨" || echo "❌ Docker Compose 설치 필요"
command -v jq && echo "✅ jq 설치됨" || echo "❌ jq 설치 필요"
command -v curl && echo "✅ curl 설치됨" || echo "❌ curl 설치 필요"
command -v ab && echo "✅ Apache Bench 설치됨" || echo "❌ Apache Bench 설치 필요 ["부하테스트용"]"

# Apache Bench 설치 [Ubuntu/Debian]
if ! command -v ab &> /dev/null; then
    echo "Apache Bench 설치 중..."
    sudo apt update && sudo apt install -y apache2-utils
    echo "✅ Apache Bench 설치 완료"
fi

# 2. 클라우드 계정 설정 확인
echo "=== 클라우드 계정 설정 확인 ==="
aws sts get-caller-identity && echo "✅ AWS 계정 설정됨" || echo "❌ AWS 계정 설정 필요"
gcloud auth list && echo "✅ GCP 계정 설정됨" || echo "❌ GCP 계정 설정 필요"

# 3. 기존 VM 상태 확인
echo "=== 기존 VM 상태 확인 ==="
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0],PublicIpAddress]' \
    --output table
gcloud compute instances list --format="table[name,zone,status,EXTERNAL_IP]"
```

### 🚨 **중요: 모니터링 스택 포트 충돌 해결**

#### **문제점**
- **Day2**: Prometheus [9090], Grafana [3001] 포트 사용
- **Day3**: Prometheus [9090], Grafana [3001] 포트 사용
- **충돌**: 동일한 포트로 인한 서비스 충돌 발생

#### **해결 방안**
```bash
# 옵션 1: Day2 모니터링 스택 중지 ["권장"]
cd cloud_master/day2/samples/my-app
docker-compose down

# 옵션 2: Day3 모니터링 스택 포트 변경
# 3일차 스크립트에서 자동으로 포트 충돌 감지 및 해결
03-monitoring-stack.sh setup  # 자동으로 포트 충돌 감지 및 해결

# 옵션 3: 별도 네트워크 사용
# Day2와 Day3 모니터링 스택을 별도 Docker 네트워크에서 실행
docker network create day3-monitoring
# Day3 스크립트에서 별도 네트워크 사용

# 옵션 4: 포트 매핑 변경
# Day3 모니터링 스택을 다른 포트로 실행
# Prometheus: 9091, Grafana: 3002, Jaeger: 16687
```

### 📋 **실습 전 체크리스트**

#### **자동 체크 ["권장"]**
```bash
# 환경 체크 스크립트 실행
cd cloud_master/day3/scripts
environment-check.sh
```

#### **수동 체크**
- [ ] **AWS CLI 설정**: `aws sts get-caller-identity` 성공
- [ ] **GCP CLI 설정**: `gcloud auth list` 성공  
- [ ] **Docker 실행**: `docker --version` 확인
- [ ] **Day2 모니터링 중지**: 포트 충돌 방지
- [ ] **기존 VM 확인**: Day1, Day2 VM 상태 정상
- [ ] **권한 확인**: AWS/GCP 리소스 생성 권한
- [ ] **네트워크 확인**: 인터넷 연결 및 방화벽 설정
- [ ] **Git Repository 준비**: 실습 코드 저장소 생성 및 설정

## 📁 **3일차 강의 자료 구조**

### **새로운 디렉토리 구조**
```
cloud_master/day3/
├── automation/          # 자동화 스크립트
│   ├── 01-aws-loadbalancing.sh
│   ├── 02-gcp-loadbalancing.sh
│   ├── 03-monitoring-stack.sh
│   ├── 04-autoscaling.sh
│   ├── 05-cost-optimization.sh
│   ├── 06-integration-test.sh
│   ├── create-git-repo.sh
│   └── vm-setup.sh
├── guides/              # 가이드 문서
│   ├── wsl-to-vm-setup.md
│   ├── port-conflict-resolution.md
│   └── troubleshooting.md
├── samples/             # 실습 샘플 코드
│   ├── cloud-master-day3/
│   ├── cloud-master-day3-aws-vm/
│   ├── cloud-master-day3-existing-vm/
│   ├── cloud-master-day3-smooth/
│   └── cloud-master-day3-vm/
├── docs/                # 문서 및 보고서
│   └── cost-reports/
└── scripts/             # 유틸리티 스크립트
    └── environment-check.sh
```

### **구조화의 장점**
- **체계적 관리**: 기능별로 명확하게 분리된 디렉토리 구조
- **쉬운 접근**: 필요한 자료를 빠르게 찾을 수 있는 구조
- **확장성**: 새로운 자료 추가 시 적절한 위치에 배치 가능
- **유지보수**: 각 디렉토리의 역할이 명확하여 관리 용이

## 🖥️ **WSL → Cloud VM 작업 환경 구성**

### 🔄 **작업 환경 전략**

#### **1단계: WSL에서 Git Repository 생성 ["자동화"]**

##### **방법 1: 자동화 스크립트 사용 ["권장"]**
```bash
# WSL에서 자동화 스크립트 실행
cd /mnt/c/Users/["사용자명"]/mcp_cloud/cloud_master/day3/automation
create-git-repo.sh

# GitHub 사용자명 입력 후 자동으로 Repository 생성 및 설정
```

##### **방법 2: 수동 설정**
```bash
# WSL 환경에서 실습 코드를 Git Repository로 생성
cd /mnt/c/Users/["사용자명"]/Documents
mkdir cloud-master-day3-practice
cd cloud-master-day3-practice

# Git Repository 초기화
git init
git config user.name "Cloud Master Student"
git config user.email "student@cloudmaster.com"

# 실습 코드 복사 및 커밋
cp -r /mnt/c/Users/["사용자명"]/mcp_cloud/cloud_master/day3/automation/* .
git add .
git commit -m "Initial commit: Day3 practice automation scripts"

# GitHub/GitLab에 Repository 생성 및 Push
# ["GitHub에서 새 repository 생성 후"]
git remote add origin https://github.com/["사용자명"]/cloud-master-day3-practice.git
git branch -M main
git push -u origin main
```

#### **2단계: Cloud VM에서 Repository Clone 및 환경 설정**

##### **방법 1: 자동화 스크립트 사용 ["권장"]**
```bash
# AWS/GCP VM에 SSH 접속
ssh -i ~/.ssh/cloud-master-key.pem ubuntu@[VM_IP]

# VM 초기 설정 스크립트 다운로드 및 실행
curl -O https://raw.githubusercontent.com/["사용자명"]/cloud-master-day3-practice/main/vm-setup.sh
chmod +x vm-setup.sh
vm-setup.sh

# 실습 코드 자동 Clone 및 환경 설정 완료
# 실습 시작
01-aws-loadbalancing.sh setup
```

##### **방법 2: 수동 설정**
```bash
# AWS/GCP VM에 SSH 접속
ssh -i ~/.ssh/cloud-master-key.pem ubuntu@[VM_IP]

# VM에서 실습 코드 Clone
git clone https://github.com/["사용자명"]/cloud-master-day3-practice.git
cd cloud-master-day3-practice

# 실행 권한 부여
chmod +x *.sh

# 실습 시작
01-aws-loadbalancing.sh setup
```

### 🛠️ **VM 환경 자동 설정 스크립트**

#### **VM 초기 설정 스크립트 생성**
```bash
# WSL에서 VM 설정 스크립트 생성
cat > vm-setup.sh << 'EOF'
#!/bin/bash

# Cloud VM 초기 설정 스크립트
# 작성일: 2024년 9월 23일
# 목적: Day3 실습을 위한 VM 환경 자동 설정

echo "=== Cloud Master Day3 VM 설정 시작 ==="

# 1. 시스템 업데이트
sudo apt update && sudo apt upgrade -y

# 2. 필수 도구 설치
sudo apt install -y git curl wget jq unzip

# 3. Docker 설치
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# 4. Docker Compose 설치
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$[uname -s]-$[uname -m]" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 5. AWS CLI 설치
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo aws/install

# 6. GCP CLI 설치
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# 7. 실습 코드 Clone
git clone https://github.com/["사용자명"]/cloud-master-day3-practice.git
cd cloud-master-day3-practice
chmod +x *.sh

echo "=== VM 설정 완료 ==="
echo "다음 명령어로 실습을 시작하세요:"
echo "cd cloud-master-day3-practice"
echo "01-aws-loadbalancing.sh setup"
EOF

chmod +x vm-setup.sh
```

### 🔗 **WSL ↔ Cloud VM 연동 방법**

#### **옵션 1: SSH + SCP를 통한 파일 동기화**
```bash
# WSL에서 VM으로 파일 전송
scp -i ~/.ssh/cloud-master-key.pem *.sh ubuntu@[VM_IP]:~/cloud-master-day3-practice/

# VM에서 WSL로 결과 파일 수신
scp -i ~/.ssh/cloud-master-key.pem ubuntu@[VM_IP]:~/cloud-master-day3-practice/results/* ./
```

#### **옵션 2: Git을 통한 실시간 동기화**
```bash
# WSL에서 코드 수정 후
git add .
git commit -m "Update monitoring configuration"
git push origin main

# VM에서 최신 코드 Pull
git pull origin main
```

#### **옵션 3: VS Code Remote SSH 확장 사용**
```bash
# VS Code에서 Remote SSH 확장 설치
# SSH 설정 파일에 VM 정보 추가
Host cloud-master-vm
    HostName [VM_IP]
    User ubuntu
    IdentityFile ~/.ssh/cloud-master-key.pem
    Port 22

# VS Code에서 Remote SSH로 VM에 직접 연결하여 작업
```

### 📊 **작업 흐름도**

```mermaid
flowchart TD
    A["WSL 환경"] -->> B["Git Repository 생성"]
    B -->> C["실습 코드 Push"]
    C -->> D["Cloud VM 접속"]
    D -->> E[Repository Clone]
    E -->> F["실습 스크립트 실행"]
    F -->> G["결과 확인"]
    G -->> H["결과를 WSL로 동기화"]
    H -->> I["WSL에서 분석 및 정리"]
    
    style A fill:#e1f5fe
    style D fill:#f3e5f5
    style F fill:#e8f5e8
    style I fill:#fff3e0
```

### 🚀 **권장 작업 순서**

#### **실습 전 준비 [WSL]**
1. **Git Repository 생성 및 설정**
2. **실습 코드 Push**
3. **VM 접속 정보 확인**

#### **실습 실행 [Cloud VM]**
1. **VM 환경 설정** ["`vm-setup.sh` 실행"]
2. **Repository Clone**
3. **실습 스크립트 순차 실행**

#### **실습 후 정리 [WSL]**
1. **결과 파일 동기화**
2. **분석 및 문서화**
3. **Repository 업데이트**

### ⚠️ **주의사항**

#### **보안 고려사항**
- **SSH 키 관리**: 개인키는 안전하게 보관
- **방화벽 설정**: 필요한 포트만 개방
- **권한 관리**: 최소 권한 원칙 적용

#### **비용 최적화**
- **VM 사용 후 정리**: 실습 완료 후 VM 중지
- **리소스 모니터링**: 사용하지 않는 리소스 정리
- **스냅샷 활용**: 설정 완료된 VM 스냅샷 생성

#### **백업 전략**
- **코드 백업**: Git Repository에 정기적 커밋
- **설정 백업**: VM 설정 스크립트 보관
- **결과 백업**: 실습 결과물 정기적 다운로드

### 실습 후 달성할 수 있는 능력
- ✅ 기존 VM을 활용한 로드밸런서 설정
- ✅ AWS ALB와 GCP Cloud LB 비교 실습
- ✅ Prometheus + Grafana 모니터링 시스템 구축
- ✅ 비용 최적화 분석 및 리포트 생성
- ✅ 자동화 스크립트를 통한 효율적 실습
- ✅ 실제 프로덕션 환경과 유사한 실습 경험

---

## 🕘 1교시: 로드밸런싱 구축 [9:00~10:30]

### 📚 이론 학습 ["15분"]
#### 로드밸런싱 개념
- **트래픽 분산**: 여러 서버에 요청을 균등하게 분산
- **고가용성**: 서버 장애 시 자동으로 다른 서버로 전환
- **확장성**: 트래픽 증가에 따라 서버 추가 가능
- **헬스체크**: 서버 상태를 주기적으로 확인

#### AWS ELB vs GCP Cloud Load Balancing
```bash
# AWS ELB
- Application Load Balancer [ALB]: HTTP/HTTPS
- Network Load Balancer [NLB]: TCP/UDP
- Classic Load Balancer [CLB]: 레거시

# GCP Cloud Load Balancing
- HTTP[S] Load Balancing: 웹 애플리케이션
- TCP/UDP Load Balancing: 네트워크 트래픽
- Internal Load Balancing: 내부 트래픽
```

### 🛠️ 실습 ["75분"]

#### 🏗️ **1단계: 현재 아키텍처 확인**

**현재 상태 ["Day1, Day2 완료 후"]**
```mermaid
flowchart TB
    subgraph "AWS"
        A1[EC2 Instance<br/>cloud-deployment-server<br/>i-099f55941265d751f]
        A2["Security Group<br/>기존 설정"]
        A3["VPC<br/>기본 VPC"]
    end
    
    subgraph "GCP"
        G1[VM Instance<br/>cloud-deployment-server]
        G2["Firewall Rules<br/>기존 설정"]
        G3["VPC Network<br/>기본 네트워크"]
    end
    
    subgraph "Local"
        L1["개발자 머신<br/>WSL/Windows"]
    end
    
    L1 -->> A1
    L1 -->> G1
```

**🔍 명령 실행: 기존 VM 상태 확인**
```bash
# AWS VM 상태 확인
echo "=== AWS VM 상태 확인 ==="
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0],PublicIpAddress,State.Name]' \
    --output table

# GCP VM 상태 확인
echo "=== GCP VM 상태 확인 ==="
gcloud compute instances list --format="table[name,zone,status,EXTERNAL_IP,INTERNAL_IP]"
```

**✅ 예상 결과:**
- AWS: `i-099f55941265d751f` [cloud-deployment-server] 상태: running
- GCP: `cloud-deployment-server` 상태: RUNNING
- Public IP 주소 확인 가능

**🌐 콘솔에서 확인:**
- AWS Console: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:
- GCP Console: https://console.cloud.google.com/compute/instances

---

#### 🚀 **2단계: AWS ALB 로드밸런싱 구축**

**목표 아키텍처 ["1단계 완료 후"]**
```mermaid
flowchart TB
    subgraph "AWS"
        A1[EC2 Instance<br/>cloud-deployment-server]
        A2["Security Group<br/>기존 설정"]
        A3["VPC<br/>기본 VPC"]
        A4[Application Load Balancer<br/>cloud-master-day3-alb]
        A5[Target Group<br/>cloud-master-day3-targets]
        A6[Listener<br/>HTTP:80]
    end
    
    subgraph "GCP"
        G1[VM Instance<br/>cloud-deployment-server]
        G2["Firewall Rules<br/>기존 설정"]
        G3["VPC Network<br/>기본 네트워크"]
    end
    
    subgraph "Local"
        L1["개발자 머신"]
    end
    
    L1 -->> A4
    A4 -->> A6
    A6 -->> A5
    A5 -->> A1
    L1 -->> G1
```

**🔍 명령 실행: AWS ALB 구축**
```bash
# 자동화 스크립트 실행
echo "=== AWS ALB 로드밸런싱 구축 시작 ==="
cloud_master/scripts/aws-loadbalancing-improved.sh setup

# 또는 수동 실행 ["참고용"]
echo "=== 수동 ALB 구축 ==="
# 1. VPC 및 서브넷 정보 확인
VPC_ID=$[aws ec2 describe-vpcs --filters "Name=is-default,Values=true" --query 'Vpcs[0].VpcId' --output text]
echo "VPC ID: $VPC_ID"

# 2. 기존 보안 그룹 확인
INSTANCE_ID="i-099f55941265d751f"
SECURITY_GROUP=$[aws ec2 describe-instances --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' --output text]
echo "Security Group: $SECURITY_GROUP"

# 3. Target Group 생성
TARGET_GROUP_ARN=$[aws elbv2 create-target-group \
    --name "cloud-master-day3-targets" \
    --protocol HTTP --port 80 --vpc-id $VPC_ID \
    --health-check-path "/" \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 5 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3 \
    --target-type instance \
    --query 'TargetGroups[0].TargetGroupArn' --output text]
echo "Target Group ARN: $TARGET_GROUP_ARN"

# 4. ALB 생성
ALB_ARN=$[aws elbv2 create-load-balancer \
    --name "cloud-master-day3-alb" \
    --subnets $[aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" \
        --query 'Subnets[*].SubnetId' --output text | tr '\n' ' '] \
    --security-groups $SECURITY_GROUP \
    --query 'LoadBalancers[0].LoadBalancerArn' --output text]
echo "ALB ARN: $ALB_ARN"

# 5. VM을 Target Group에 등록
aws elbv2 register-targets \
    --target-group-arn $TARGET_GROUP_ARN \
    --targets "Id=$INSTANCE_ID,Port=80"

# 6. Listener 생성
aws elbv2 create-listener \
    --load-balancer-arn $ALB_ARN \
    --protocol HTTP --port 80 \
    --default-actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN

# 7. ALB DNS 확인
ALB_DNS=$[aws elbv2 describe-load-balancers \
    --load-balancer-arns $ALB_ARN \
    --query 'LoadBalancers[0].DNSName' --output text]
echo "ALB DNS: $ALB_DNS"
```

**✅ 예상 결과:**
- Target Group ARN: `arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/cloud-master-day3-targets/1234567890123456`
- ALB ARN: `arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/cloud-master-day3-alb/1234567890123456`
- ALB DNS: `cloud-master-day3-alb-1234567890.us-east-1.elb.amazonaws.com`
- ALB 상태: `active` ["약 2-3분 소요"]

**🌐 콘솔에서 확인:**
- AWS Load Balancer: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:
- AWS Target Groups: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#TargetGroups:

**🌐 브라우저로 서비스 접근:**
```bash
# ALB 상태 확인 ["약 2-3분 대기 후"]
echo "ALB 접속 URL: http://$ALB_DNS"
echo "브라우저에서 접속하여 확인하세요!"

# 헬스체크 확인
curl -I http://$ALB_DNS
```

---

#### 🚀 **3단계: GCP Cloud Load Balancing 구축**

**목표 아키텍처 ["2단계 완료 후"]**
```mermaid
flowchart TB
    subgraph "AWS"
        A1[EC2 Instance<br/>cloud-deployment-server]
        A2["Security Group<br/>기존 설정"]
        A3["VPC<br/>기본 VPC"]
        A4[Application Load Balancer<br/>cloud-master-day3-alb]
        A5[Target Group<br/>cloud-master-day3-targets]
        A6[Listener<br/>HTTP:80]
    end
    
    subgraph "GCP"
        G1[VM Instance<br/>cloud-deployment-server]
        G2["Firewall Rules<br/>기존 설정"]
        G3["VPC Network<br/>기본 네트워크"]
        G4[HTTP[S] Load Balancer<br/>cloud-master-day3-rule]
        G5[Backend Service<br/>cloud-master-day3-backend]
        G6[Instance Group<br/>cloud-master-day3-ig]
        G7[Health Check<br/>cloud-master-day3-hc]
    end
    
    subgraph "Local"
        L1["개발자 머신"]
    end
    
    L1 -->> A4
    A4 -->> A6
    A6 -->> A5
    A5 -->> A1
    
    L1 -->> G4
    G4 -->> G5
    G5 -->> G6
    G6 -->> G1
    G5 -->> G7
    G7 -->> G1
```

**🔍 명령 실행: GCP Load Balancing 구축**
```bash
# 자동화 스크립트 실행
echo "=== GCP Load Balancing 구축 시작 ==="
cloud_master/scripts/cloud-master-helper.sh

# 또는 수동 실행 ["참고용"]
echo "=== 수동 GCP Load Balancing 구축 ==="
# 1. Instance Group 생성
gcloud compute instance-groups unmanaged create cloud-master-day3-ig --zone=asia-northeast3-a

# 2. VM을 Instance Group에 추가
gcloud compute instance-groups unmanaged add-instances cloud-master-day3-ig \
    --instances=cloud-deployment-server --zone=asia-northeast3-a

# 3. Health Check 생성
gcloud compute health-checks create http cloud-master-day3-hc \
    --port=80 --request-path=/ --check-interval=10s --timeout=5s \
    --healthy-threshold=1 --unhealthy-threshold=3

# 4. Backend Service 생성
gcloud compute backend-services create cloud-master-day3-backend \
    --protocol=HTTP --port-name=http --health-checks=cloud-master-day3-hc --global

# 5. Backend Service에 Instance Group 추가
gcloud compute backend-services add-backend cloud-master-day3-backend \
    --instance-group=cloud-master-day3-ig \
    --instance-group-zone=asia-northeast3-a --global

# 6. URL Map 생성
gcloud compute url-maps create cloud-master-day3-url-map \
    --default-service=cloud-master-day3-backend

# 7. Target HTTP Proxy 생성
gcloud compute target-http-proxies create cloud-master-day3-proxy \
    --url-map=cloud-master-day3-url-map

# 8. Forwarding Rule 생성
gcloud compute forwarding-rules create cloud-master-day3-rule \
    --global --target-http-proxy=cloud-master-day3-proxy --ports=80

# 9. Load Balancer IP 확인
LB_IP=$[gcloud compute forwarding-rules describe cloud-master-day3-rule \
    --global --format="value[IPAddress]"]
echo "GCP Load Balancer IP: $LB_IP"
```

**✅ 예상 결과:**
- Instance Group: `cloud-master-day3-ig` 생성
- Health Check: `cloud-master-day3-hc` 생성
- Backend Service: `cloud-master-day3-backend` 생성
- Load Balancer IP: `34.102.xxx.xxx` ["전역 IP"]
- 상태: `HEALTHY` ["약 2-3분 소요"]

**🌐 콘솔에서 확인:**
- GCP Load Balancing: https://console.cloud.google.com/net-services/loadbalancing
- GCP Instance Groups: https://console.cloud.google.com/compute/instanceGroups
- GCP Health Checks: https://console.cloud.google.com/compute/healthChecks

**🌐 브라우저로 서비스 접근:**
```bash
# GCP Load Balancer 접속
echo "GCP Load Balancer 접속 URL: http://$LB_IP"
echo "브라우저에서 접속하여 확인하세요!"

# 헬스체크 확인
curl -I http://$LB_IP
```

---

#### 🎯 **4단계: 로드밸런싱 결과 확인 및 비교**

**🔍 명령 실행: 전체 시스템 상태 확인**
```bash
echo "=== 로드밸런싱 구축 완료 상태 확인 ==="

# AWS ALB 상태 확인
echo "--- AWS ALB 상태 ---"
aws elbv2 describe-load-balancers --names cloud-master-day3-alb \
    --query 'LoadBalancers[0].{DNSName:DNSName,State:State.Code,Scheme:Scheme}'

# AWS Target Group 상태 확인
aws elbv2 describe-target-health --target-group-arn $TARGET_GROUP_ARN

# GCP Load Balancer 상태 확인
echo "--- GCP Load Balancer 상태 ---"
gcloud compute forwarding-rules describe cloud-master-day3-rule --global

# GCP Backend Service 상태 확인
gcloud compute backend-services get-health cloud-master-day3-backend --global
```

**✅ 예상 결과:**
- AWS ALB: `active` 상태, DNS 이름 확인
- AWS Target: `healthy` 상태
- GCP LB: `HEALTHY` 상태, IP 주소 확인
- GCP Backend: `HEALTHY` 상태

**🌐 브라우저로 서비스 접근 및 비교:**
```bash
echo "=== 브라우저 접속 URL 비교 ==="
echo "AWS ALB: http://$ALB_DNS"
echo "GCP LB: http://$LB_IP"
echo ""
echo "두 URL 모두 브라우저에서 접속하여 동일한 응답을 확인하세요!"
echo "응답 시간과 성능을 비교해보세요."

# 성능 테스트 ["선택사항"]
echo "=== 성능 테스트 ==="
if command -v ab &> /dev/null; then
    echo "AWS ALB 성능 테스트:"
    ab -n 10 -c 2 http://$ALB_DNS/ | grep "Requests per second"
    echo "GCP LB 성능 테스트:"
    ab -n 10 -c 2 http://$LB_IP/ | grep "Requests per second"
else
    echo "Apache Bench가 설치되지 않았습니다."
fi
```

**🌐 콘솔에서 최종 확인:**
- AWS Console: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:
- GCP Console: https://console.cloud.google.com/net-services/loadbalancing

#### 🔧 **수동 설정 ["참고용"]**
```bash
# AWS ALB 수동 설정 ["자동화 스크립트 사용 권장"]

# 1. 기존 VM 확인
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0],PublicIpAddress]' \
    --output table

# 2. VPC 및 서브넷 정보 확인
VPC_ID=$[aws ec2 describe-vpcs --filters "Name=is-default,Values=true" --query 'Vpcs[0].VpcId' --output text]
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[*].[SubnetId,AvailabilityZone]' --output table

# 3. 기존 보안 그룹 확인
INSTANCE_ID="i-099f55941265d751f"  # cloud-deployment-server
SECURITY_GROUP=$[aws ec2 describe-instances --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' --output text]
echo "기존 보안 그룹: $SECURITY_GROUP"

# 4. Target Group 생성 ["상세 설정 포함"]
TARGET_GROUP_ARN=$[aws elbv2 create-target-group \
    --name "cloud-master-day3-targets" \
    --protocol HTTP --port 80 --vpc-id $VPC_ID \
    --health-check-path "/" \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 5 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3 \
    --target-type instance \
    --query 'TargetGroups[0].TargetGroupArn' --output text]

# 5. ALB 생성
ALB_ARN=$[aws elbv2 create-load-balancer \
    --name "cloud-master-day3-alb" \
    --subnets $[aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" \
        --query 'Subnets[*].SubnetId' --output text | tr '\n' ' '] \
    --security-groups $SECURITY_GROUP \
    --query 'LoadBalancers[0].LoadBalancerArn' --output text]

# 6. VM을 Target Group에 등록
aws elbv2 register-targets \
    --target-group-arn $TARGET_GROUP_ARN \
    --targets "Id=$INSTANCE_ID,Port=80"

# 7. Listener 생성
aws elbv2 create-listener \
    --load-balancer-arn $ALB_ARN \
    --protocol HTTP --port 80 \
    --default-actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN

# 8. ALB DNS 확인
ALB_DNS=$[aws elbv2 describe-load-balancers \
    --load-balancer-arns $ALB_ARN \
    --query 'LoadBalancers[0].DNSName' --output text]
echo "ALB DNS: http://$ALB_DNS"

# 9. 확인 가능한 URL들
echo "🌐 확인 가능한 URL들:"
echo "- AWS ALB: http://$ALB_DNS"
echo "- AWS Console: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:"
echo "- Target Group: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#TargetGroups:"
echo "- EC2 Instances: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:"
```

#### 🚨 **Target Group 생성 실패 해결 방법**
```bash
# 1. 기존 Target Group 정리
aws elbv2 describe-target-groups --query 'TargetGroups[?contains(TargetGroupName, `cloud-master-day3`)].TargetGroupArn' --output text | xargs -I {} aws elbv2 delete-target-group --target-group-arn {}

# 2. IAM 권한 확인
aws iam get-user
aws iam list-attached-user-policies --user-name $[aws sts get-caller-identity --query User --output text]

# 3. VPC DNS 설정 확인
aws ec2 describe-vpc-attribute --vpc-id $VPC_ID --attribute enableDnsHostnames
aws ec2 describe-vpc-attribute --vpc-id $VPC_ID --attribute enableDnsSupport

# 4. Target Group 생성 디버그
aws elbv2 create-target-group \
    --name "test-target-group-$[date +%s]" \
    --protocol HTTP --port 80 --vpc-id $VPC_ID \
    --health-check-path "/" \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 5 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3 \
    --target-type instance \
    --verbose
```

#### 🔧 **GCP Cloud Load Balancing 수동 설정 ["참고용"]**
```bash
# GCP Cloud Load Balancing 수동 설정 ["자동화 스크립트 사용 권장"]

# 1. 기존 VM 확인
gcloud compute instances list --format="table[name,zone,status,EXTERNAL_IP,INTERNAL_IP]"

# 2. Instance Group 생성
gcloud compute instance-groups unmanaged create cloud-master-day3-ig --zone=asia-northeast3-a

# 3. VM을 Instance Group에 추가
gcloud compute instance-groups unmanaged add-instances cloud-master-day3-ig \
    --instances=cloud-deployment-server --zone=asia-northeast3-a

# 4. Health Check 생성
gcloud compute health-checks create http cloud-master-day3-hc \
    --port=80 --request-path=/ --check-interval=10s --timeout=5s \
    --healthy-threshold=1 --unhealthy-threshold=3

# 5. Backend Service 생성
gcloud compute backend-services create cloud-master-day3-backend \
    --protocol=HTTP --port-name=http --health-checks=cloud-master-day3-hc --global

# 6. Backend Service에 Instance Group 추가
gcloud compute backend-services add-backend cloud-master-day3-backend \
    --instance-group=cloud-master-day3-ig \
    --instance-group-zone=asia-northeast3-a --global

# 7. URL Map 생성
gcloud compute url-maps create cloud-master-day3-url-map \
    --default-service=cloud-master-day3-backend

# 8. Target HTTP Proxy 생성
gcloud compute target-http-proxies create cloud-master-day3-proxy \
    --url-map=cloud-master-day3-url-map

# 9. Forwarding Rule 생성
gcloud compute forwarding-rules create cloud-master-day3-rule \
    --global --target-http-proxy=cloud-master-day3-proxy --ports=80

# 10. Load Balancer IP 확인
LB_IP=$[gcloud compute forwarding-rules describe cloud-master-day3-rule \
    --global --format="value[IPAddress]"]
echo "Load Balancer IP: http://$LB_IP"

# 11. 확인 가능한 URL들
echo "🌐 확인 가능한 URL들:"
echo "- GCP Load Balancer: http://$LB_IP"
echo "- GCP Console: https://console.cloud.google.com/net-services/loadbalancing"
echo "- Instance Groups: https://console.cloud.google.com/compute/instanceGroups"
echo "- Health Checks: https://console.cloud.google.com/compute/healthChecks"
echo "- Backend Services: https://console.cloud.google.com/net-services/loadbalancing/backendServices"
```

#### 🚀 **GCP MIG 자동 스케일링 자동화 스크립트**
```bash
# GCP Managed Instance Group 자동 스케일링 설정
cloud_master/scripts/cloud-master-helper.sh

# 자동화 장점:
# ✅ 인스턴스 템플릿 자동 생성
# ✅ MIG 자동 스케일링 설정
# ✅ 헬스 체크 자동 구성
# ✅ 로드밸런서 자동 연결
# ✅ 모니터링 스택 자동 구축
```

#### 💰 **GCP 비용 최적화 자동화 스크립트**
```bash
# GCP 비용 최적화 분석 실행
cloud_master/scripts/cloud-master-helper.sh

# 자동화 장점:
# ✅ 사용하지 않는 리소스 자동 검색
# ✅ 비용 절약 권장사항 자동 생성
# ✅ 상세한 비용 분석 리포트 제공
# ✅ 실행 가능한 명령어 자동 생성
```

#### 🚀 **GCP 자동화 스크립트 상세 가이드**
```bash
# GCP Cloud Load Balancing 자동화 스크립트 사용법
cloud_master/scripts/cloud-master-helper.sh

# GCP MIG 자동 스케일링 자동화 스크립트 사용법
cloud_master/automation/day3/04-autoscaling.sh setup

# GCP 비용 최적화 자동화 스크립트 사용법
cloud_master/automation/day3/05-cost-optimization.sh analyze

# GCP 통합 실습 자동화 스크립트 사용법
cloud_master/automation/day3/06-integration-test.sh setup

# 스크립트 옵션:
# setup   - 설정 실행 ["기본값"]
# cleanup - 리소스 정리
# test    - 시스템 테스트

# 예시:
cloud_master/automation/day3/02-gcp-loadbalancing.sh cleanup
cloud_master/automation/day3/04-autoscaling.sh test
```

# 1. GCP 전용 로드밸런싱 실습
cloud_master/scripts/cloud-master-helper.sh

# 2. GCP 모니터링 스택 자동 구축
cloud_master/automation/day3/03-monitoring-stack.sh setup

# 3. GCP 자동 스케일링 설정
cloud_master/automation/day3/04-autoscaling.sh setup

# 4. GCP 비용 최적화 분석
cloud_master/automation/day3/05-cost-optimization.sh analyze

# GCP 자동화 스크립트 특징:
# ✅ GCP Cloud SDK 자동 설정 확인
# ✅ 기존 VM 자동 검색 및 활용
# ✅ 방화벽 규칙 자동 생성 및 관리
# ✅ Instance Group 자동 구성
# ✅ Health Check 자동 설정
# ✅ Backend Service 자동 생성
# ✅ URL Map 및 Forwarding Rule 자동 구성
# ✅ 로드밸런서 상태 자동 모니터링
# ✅ 실패 시 자동 롤백 기능
# ✅ 리소스 정리 자동화
```

### 📊 예상 결과
- **성공률**: 95% ["자동화 스크립트 활용"]
- **소요 시간**: 60분 ["자동화로 단축"]
- **주요 개선**: 기존 VM 활용, 보안 그룹 재사용, 타임아웃 처리

### 🏗️ 시스템 아키텍처 변화

#### 초기 상태 ["Day1, Day2 완료 후"]
```mermaid
flowchart TB
    subgraph "AWS"
        A1[EC2 Instance<br/>cloud-deployment-server]
        A2["Security Group<br/>기존 설정"]
        A3["VPC<br/>기본 VPC"]
    end
    
    subgraph "GCP"
        G1[VM Instance<br/>cloud-deployment-server]
        G2["Firewall Rules<br/>기존 설정"]
        G3["VPC Network<br/>기본 네트워크"]
    end
    
    subgraph "Local"
        L1["개발자 머신"]
    end
    
    L1 -->> A1
    L1 -->> G1
```

#### 1단계: AWS ALB 로드밸런싱 구축 후
```mermaid
flowchart TB
    subgraph "AWS"
        A1[EC2 Instance<br/>cloud-deployment-server]
        A2["Security Group<br/>기존 설정"]
        A3["VPC<br/>기본 VPC"]
        A4[Application Load Balancer<br/>cloud-master-day3-alb]
        A5[Target Group<br/>cloud-master-day3-targets]
        A6[Listener<br/>HTTP:80]
    end
    
    subgraph "GCP"
        G1[VM Instance<br/>cloud-deployment-server]
        G2["Firewall Rules<br/>기존 설정"]
        G3["VPC Network<br/>기본 네트워크"]
    end
    
    subgraph "Local"
        L1["개발자 머신"]
    end
    
    L1 -->> A4
    A4 -->> A6
    A6 -->> A5
    A5 -->> A1
    L1 -->> G1
```

**적용된 기능:**
- ✅ **로드밸런서 생성**: 트래픽 분산 시작
- ✅ **Target Group**: VM을 백엔드로 등록
- ✅ **헬스체크**: 서버 상태 모니터링
- ✅ **보안 그룹 재사용**: 기존 설정 활용

#### 📊 장단점 분석

**✅ 장점:**
- **고가용성 확보**: 단일 장애점 제거로 서비스 안정성 향상
- **트래픽 분산**: 부하를 여러 인스턴스에 균등 분산
- **자동 장애 복구**: 헬스체크를 통한 자동 트래픽 전환
- **비용 효율성**: 기존 VM 재사용으로 추가 비용 없음
- **확장성 준비**: 향후 인스턴스 추가 용이

**❌ 단점:**
- **복잡성 증가**: 단순한 단일 VM에서 로드밸런서 구조로 복잡해짐
- **지연 시간**: 로드밸런서를 통한 추가 홉으로 약간의 지연 발생
- **비용 증가**: ALB 사용료 발생 ["시간당 약 $0.0225"]
- **설정 복잡성**: Target Group, Listener 등 추가 설정 필요
- **디버깅 어려움**: 문제 발생 시 로드밸런서와 백엔드 모두 확인 필요

---

## 🕘 2교시: 모니터링 스택 구축 [10:45~12:00]

### 📚 이론 학습 ["15분"]
#### 모니터링 아키텍처
- **Prometheus**: 메트릭 수집 및 저장
- **Grafana**: 시각화 및 대시보드
- **Jaeger**: 분산 추적
- **ELK Stack**: 로그 수집 및 분석

### 🛠️ 실습 ["60분"]

#### 🏗️ **1단계: 모니터링 아키텍처 이해**

**목표 아키텍처 ["모니터링 스택 추가 후"]**
```mermaid
flowchart TB
    subgraph "AWS Cloud"
        A1[EC2 Instance<br/>cloud-deployment-server]
        A2[Application Load Balancer<br/>cloud-master-day3-alb]
        A3[Target Group<br/>cloud-master-day3-targets]
    end
    
    subgraph "GCP Cloud"
        G1[VM Instance<br/>cloud-deployment-server]
        G2[HTTP[S] Load Balancer<br/>cloud-master-day3-rule]
        G3[Backend Service<br/>cloud-master-day3-backend]
    end
    
    subgraph "Local - Monitoring Stack"
        M1["Prometheus<br/>:9090<br/>메트릭 수집"]
        M2["Grafana<br/>:3001<br/>시각화 대시보드"]
        M3["Node Exporter<br/>:9100<br/>시스템 메트릭"]
        M4["Docker Compose<br/>모니터링 스택"]
    end
    
    subgraph "Local"
        L1["개발자 머신<br/>WSL/Windows"]
    end
    
    L1 -->> A2
    A2 -->> A3
    A3 -->> A1
    
    L1 -->> G2
    G2 -->> G3
    G3 -->> G1
    
    M1 -->> A1
    M1 -->> G1
    M3 -->> A1
    M3 -->> G1
    M2 -->> M1
    L1 -->> M2
    L1 -->> M1
    L1 -->> M3
    M4 -->> M1
    M4 -->> M2
    M4 -->> M3
```

**🔍 명령 실행: 모니터링 스택 구축**
```bash
# 자동화 스크립트 실행
echo "=== 모니터링 스택 구축 시작 ==="
cloud_master/automation/day3/03-monitoring-stack.sh setup

# 또는 수동 실행 ["참고용"]
echo "=== 수동 모니터링 스택 구축 ==="
# 1. 모니터링 디렉토리 생성
mkdir -p monitoring/{prometheus,grafana/dashboards,grafana/provisioning/datasources}

# 2. Prometheus 설정 파일 생성 ["클라우드 인스턴스 메트릭 수집 포함"]
cat > monitoring/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
  
  - job_name: 'app'
    static_configs:
      - targets: ['app:3000']
    metrics_path: '/metrics'
    scrape_interval: 30s
  
  # AWS EC2 인스턴스 메트릭 수집
  - job_name: 'aws-ec2-instances'
    static_configs:
      - targets: ['AWS_INSTANCE_IP:9100']  # Node Exporter가 설치된 AWS 인스턴스
    scrape_interval: 15s
    metrics_path: '/metrics'
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
        replacement: 'aws-ec2-instance'
  
  # GCP VM 인스턴스 메트릭 수집
  - job_name: 'gcp-vm-instances'
    static_configs:
      - targets: ['GCP_INSTANCE_IP:9100']  # Node Exporter가 설치된 GCP 인스턴스
    scrape_interval: 15s
    metrics_path: '/metrics'
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
        replacement: 'gcp-vm-instance'
  
  # HTTP 요청 메트릭 수집 [nginx_exporter]
  - job_name: 'nginx-metrics'
    static_configs:
      - targets: ['AWS_INSTANCE_IP:9113', 'GCP_INSTANCE_IP:9113']  # nginx_exporter 포트
    scrape_interval: 10s
    metrics_path: '/metrics'
EOF

echo "✅ Prometheus 설정에 클라우드 인스턴스 메트릭 수집 추가됨"
echo "   - AWS EC2 인스턴스 메트릭 수집"
echo "   - GCP VM 인스턴스 메트릭 수집"
echo "   - HTTP 요청 메트릭 수집"

# 2-1. 클라우드 인스턴스에 Node Exporter 설치 ["부하테스트 연계용"]
echo "=== 클라우드 인스턴스에 Node Exporter 설치 ==="
echo "AWS EC2 인스턴스에 Node Exporter 설치:"
echo "ssh -i ~/.ssh/cloud-master-key.pem ubuntu@[AWS_INSTANCE_IP]"
echo "sudo docker run -d --name node-exporter --restart=always -p 9100:9100 prom/node-exporter"
echo ""
echo "GCP VM 인스턴스에 Node Exporter 설치:"
echo "ssh -i ~/.ssh/cloud-master-key.pem ubuntu@[GCP_INSTANCE_IP]"
echo "sudo docker run -d --name node-exporter --restart=always -p 9100:9100 prom/node-exporter"
echo ""
echo "⚠️ 주의: 실제 IP 주소로 교체하고 보안 그룹/방화벽에서 9100 포트 개방 필요"

# 3. Docker Compose 파일 생성
cat > monitoring/docker-compose.yml << 'EOF'
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.enable-lifecycle'

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
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

volumes:
  prometheus_data:
  grafana_data:
EOF

# 4. 모니터링 스택 실행
cd monitoring
docker-compose up -d

# 5. 상태 확인
echo "🔍 모니터링 시스템 상태 확인"
sleep 10  # 컨테이너 시작 대기
curl -f http://localhost:9090 && echo "✅ Prometheus 정상"
curl -f http://localhost:3001 && echo "✅ Grafana 정상"
curl -f http://localhost:9100 && echo "✅ Node Exporter 정상"
```

**✅ 예상 결과:**
- Prometheus 컨테이너: `prometheus` 실행 중
- Grafana 컨테이너: `grafana` 실행 중
- Node Exporter 컨테이너: `node-exporter` 실행 중
- 모든 서비스 HTTP 200 응답

**🌐 브라우저로 서비스 접근:**
```bash
echo "=== 모니터링 서비스 접속 URL ==="
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3001 [admin/admin]"
echo "Node Exporter: http://localhost:9100"
echo ""
echo "브라우저에서 각 URL에 접속하여 확인하세요!"

# Prometheus 타겟 상태 확인
echo "Prometheus 타겟 상태 확인:"
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health}'
```

---

#### 🎯 **2단계: Grafana 대시보드 설정**

**🔍 명령 실행: Grafana 데이터소스 설정**
```bash
# Grafana 데이터소스 자동 설정
echo "=== Grafana 데이터소스 설정 ==="

# Prometheus 데이터소스 설정 파일 생성
cat > monitoring/grafana/provisioning/datasources/datasources.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
EOF

# Grafana 컨테이너 재시작
cd monitoring
docker-compose restart grafana

# 설정 확인
echo "Grafana 데이터소스 설정 완료"
```

**✅ 예상 결과:**
- Prometheus 데이터소스가 Grafana에 자동 등록
- 데이터소스 상태: `Connected`

**🌐 브라우저로 Grafana 접근:**
```bash
echo "=== Grafana 대시보드 설정 ==="
echo "1. 브라우저에서 http://localhost:3001 접속"
echo "2. 로그인: admin / admin"
echo "3. Configuration > Data Sources에서 Prometheus 연결 확인"
echo "4. + > Import에서 대시보드 ID 1860 [Node Exporter] 임포트"
echo "5. 대시보드에서 시스템 메트릭 확인"
```

---

#### 🎯 **3단계: 모니터링 시스템 통합 확인**

**🔍 명령 실행: 전체 모니터링 시스템 상태 확인**
```bash
echo "=== 모니터링 시스템 통합 확인 ==="

# Docker 컨테이너 상태 확인
echo "--- Docker 컨테이너 상태 ---"
docker-compose ps

# Prometheus 타겟 상태 확인
echo "--- Prometheus 타겟 상태 ---"
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health, lastScrape: .lastScrape}'

# 메트릭 수집 확인
echo "--- 메트릭 수집 확인 ---"
curl -s http://localhost:9100/metrics | head -20

# Grafana API 상태 확인
echo "--- Grafana API 상태 ---"
curl -s http://localhost:3001/api/health | jq '.'
```

**✅ 예상 결과:**
- 모든 컨테이너: `Up` 상태
- Prometheus 타겟: `up` 상태
- Node Exporter 메트릭: 정상 수집
- Grafana API: `ok` 상태

**🌐 브라우저로 통합 모니터링 확인:**
```bash
echo "=== 통합 모니터링 확인 ==="
echo "1. Prometheus: http://localhost:9090/targets - 타겟 상태 확인"
echo "2. Prometheus: http://localhost:9090/graph - 메트릭 쿼리 테스트"
echo "3. Grafana: http://localhost:3001 - 대시보드 확인"
echo "4. Node Exporter: http://localhost:9100/metrics - 시스템 메트릭 확인"
echo ""
echo "각 서비스에서 다음을 확인하세요:"
echo "- Prometheus: 타겟이 모두 'UP' 상태인지"
echo "- Grafana: 대시보드에서 CPU, 메모리, 디스크 사용량 그래프"
echo "- Node Exporter: 시스템 메트릭이 정상적으로 수집되는지"
```

**🌐 콘솔에서 최종 확인:**
- Docker Desktop: 컨테이너 상태 확인
- 시스템 리소스: CPU, 메모리 사용량 모니터링

#### 🚀 **권장: 자동화 스크립트 사용**
```bash
# 모니터링 스택이 자동으로 구축됩니다
# AWS/GCP VM 실습 스크립트에 포함되어 있음

# 1. AWS 통합 실습 실행 ["모니터링 포함"]
cloud_master/scripts/aws-loadbalancing-improved.sh setup

# 2. GCP 통합 실습 실행 ["모니터링 포함"]
cloud_master/scripts/cloud-master-helper.sh

# 3. 멀티 클라우드 모니터링 통합 실행
cloud_master/automation/day3/03-monitoring-stack.sh setup

# 4. 모니터링만 별도 실행
cloud_master/automation/day3/03-monitoring-stack.sh setup

# 접속 URL:
# - Prometheus: http://localhost:9090
# - Grafana: http://localhost:3001 [admin/admin]
# - Node Exporter: http://localhost:9100
# - GCP Monitoring: https://console.cloud.google.com/monitoring

# 확인 가능한 URL들
echo "🌐 모니터링 시스템 접속 URL:"
echo "- Prometheus ["메트릭 수집"]: http://localhost:9090"
echo "- Grafana ["대시보드"]: http://localhost:3001 [admin/admin]"
echo "- Node Exporter ["시스템 메트릭"]: http://localhost:9100"
echo "- GCP Cloud Monitoring: https://console.cloud.google.com/monitoring"
echo "- Docker Compose 상태: docker-compose ps"

# 자동화 장점:
# ✅ Docker Compose 자동 실행
# ✅ Prometheus 설정 자동 생성
# ✅ Grafana 데이터소스 자동 설정
# ✅ 시스템 메트릭 수집 자동 설정
# ✅ 컨테이너 상태 모니터링
# ✅ GCP Cloud Monitoring 연동
# ✅ 멀티 클라우드 메트릭 통합
```

#### 🔧 **수동 모니터링 설정 ["참고용"]**
```bash
# Docker Compose로 모니터링 스택 수동 실행

# 1. 모니터링 디렉토리 생성
mkdir -p monitoring/{prometheus,grafana/dashboards,grafana/provisioning/datasources}

# 2. Prometheus 설정 파일 생성
cat > monitoring/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
  
  - job_name: 'app'
    static_configs:
      - targets: ['app:3000']
    metrics_path: '/metrics'
    scrape_interval: 30s
EOF

# 3. Docker Compose 파일 생성
cat > monitoring/docker-compose.yml << 'EOF'
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.enable-lifecycle'

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
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

volumes:
  prometheus_data:
  grafana_data:
EOF

# 4. 모니터링 스택 실행
cd monitoring
docker-compose up -d

# 5. 상태 확인
echo "🔍 모니터링 시스템 상태 확인"
curl -f http://localhost:9090 && echo "✅ Prometheus 정상"
curl -f http://localhost:3001 && echo "✅ Grafana 정상"
curl -f http://localhost:9100 && echo "✅ Node Exporter 정상"

# 6. 접속 정보
echo "📊 모니터링 접속 정보:"
echo "- Prometheus: http://localhost:9090"
echo "- Grafana: http://localhost:3001 [admin/admin]"
echo "- Node Exporter: http://localhost:9100"

# 7. 추가 확인 URL들
echo "🌐 추가 확인 가능한 URL들:"
echo "- Prometheus Targets: http://localhost:9090/targets"
echo "- Prometheus Graph: http://localhost:9090/graph"
echo "- Grafana Dashboards: http://localhost:3001/dashboards"
echo "- Grafana Data Sources: http://localhost:3001/datasources"
echo "- Node Exporter Metrics: http://localhost:9100/metrics"
echo "- Docker Compose Logs: docker-compose logs"
```

### 📊 예상 결과
- **성공률**: 95% ["자동화 스크립트 활용"]
- **소요 시간**: 30분 ["자동화로 단축"]
- **주요 개선**: Docker Compose 자동 실행, 설정 파일 자동 생성

### 🏗️ 시스템 아키텍처 변화

#### 2단계: 모니터링 스택 구축 후
```mermaid
flowchart TB
    subgraph "AWS"
        A1[EC2 Instance<br/>cloud-deployment-server]
        A2["Security Group<br/>기존 설정"]
        A3["VPC<br/>기본 VPC"]
        A4[Application Load Balancer<br/>cloud-master-day3-alb]
        A5[Target Group<br/>cloud-master-day3-targets]
        A6[Listener<br/>HTTP:80]
    end
    
    subgraph "GCP"
        G1[VM Instance<br/>cloud-deployment-server]
        G2["Firewall Rules<br/>기존 설정"]
        G3["VPC Network<br/>기본 네트워크"]
        G4[HTTP[S] Load Balancer<br/>cloud-master-day3-rule]
        G5[Backend Service<br/>cloud-master-day3-backend]
        G6[Instance Group<br/>cloud-master-day3-ig]
        G7[Health Check<br/>cloud-master-day3-hc]
    end
    
    subgraph "Local - Monitoring Stack"
        M1[Prometheus<br/>:9090]
        M2[Grafana<br/>:3001]
        M3[Node Exporter<br/>:9100]
        M4["Docker Compose<br/>모니터링 스택"]
    end
    
    subgraph "Local"
        L1["개발자 머신"]
    end
    
    L1 -->> A4
    A4 -->> A6
    A6 -->> A5
    A5 -->> A1
    
    L1 -->> G4
    G4 -->> G5
    G5 -->> G6
    G6 -->> G1
    G5 -->> G7
    G7 -->> G1
    
    M1 -->> A1
    M1 -->> G1
    M3 -->> A1
    M3 -->> G1
    M2 -->> M1
    L1 -->> M2
    L1 -->> M1
    L1 -->> M3
```

**적용된 기능:**
- ✅ **Prometheus**: 메트릭 수집 및 저장
- ✅ **Grafana**: 시각화 대시보드
- ✅ **Node Exporter**: 시스템 메트릭 수집
- ✅ **Docker Compose**: 모니터링 스택 자동화
- ✅ **GCP Load Balancer**: 멀티 클라우드 로드밸런싱

#### 📊 장단점 분석

**✅ 장점:**
- **실시간 모니터링**: 시스템 상태를 실시간으로 파악 가능
- **시각화**: Grafana를 통한 직관적인 대시보드 제공
- **문제 조기 발견**: 메트릭 기반으로 성능 이슈 사전 감지
- **멀티 클라우드 지원**: AWS와 GCP 리소스 동시 모니터링
- **자동화**: Docker Compose로 모니터링 스택 자동 구축
- **확장성**: 추가 메트릭 수집기 쉽게 추가 가능

**❌ 단점:**
- **리소스 사용량**: 모니터링 스택 자체가 CPU/메모리 사용
- **데이터 저장**: Prometheus가 메트릭 데이터를 계속 저장하여 디스크 사용량 증가
- **복잡성**: 모니터링 설정과 대시보드 구성에 추가 학습 필요
- **비용**: GCP Cloud Monitoring 사용 시 추가 비용 발생 가능
- **의존성**: 모니터링 시스템 장애 시 전체 시스템 상태 파악 어려움
- **설정 관리**: Prometheus 설정 파일과 Grafana 대시보드 관리 필요

---

## 🍽️ 점심 시간 [12:00~13:00]

---

## 🕘 3교시: 분산 추적 및 로그 관리 [13:00~14:30]

### 📚 이론 학습 ["15분"]
#### 분산 추적의 중요성
- **마이크로서비스**: 여러 서비스 간의 요청 추적
- **성능 분석**: 병목 지점 식별
- **장애 진단**: 문제 발생 지점 빠른 파악
- **의존성 분석**: 서비스 간 관계 파악

### 🛠️ 실습 ["75분"]

#### 🚀 **권장: 자동화 스크립트 사용**
```bash
# 비용 최적화 자동 분석 실행
cloud_master/automation/day3/05-cost-optimization.sh analyze

# 자동화 장점:
# ✅ AWS/GCP 비용 분석 자동 실행
# ✅ 사용하지 않는 리소스 자동 검색
# ✅ 비용 최적화 리포트 자동 생성
# ✅ 예산 알림 설정 자동 구성
# ✅ 리소스 사용량 분석 자동화
```

#### 🔧 **수동 비용 최적화 분석 ["참고용"]**
```bash
# AWS 비용 분석 수동 실행

# 1. AWS 비용 및 사용량 조회
echo "💰 AWS 비용 분석 시작..."
aws ce get-cost-and-usage \
    --time-period Start=2024-01-01,End=2024-12-31 \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=DIMENSION,Key=SERVICE

# 2. 사용하지 않는 EC2 인스턴스 찾기
echo "🔍 중지된 EC2 인스턴스:"
aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=stopped" \
    --query "Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name,LaunchTime:LaunchTime}" \
    --output table

# 3. 사용하지 않는 EBS 볼륨 찾기
echo "🔍 사용하지 않는 EBS 볼륨:"
aws ec2 describe-volumes \
    --filters "Name=status,Values=available" \
    --query "Volumes[].{VolumeId:VolumeId,Size:Size,CreateTime:CreateTime}" \
    --output table

# 4. 사용하지 않는 Elastic IP 찾기
echo "🔍 사용하지 않는 Elastic IP:"
aws ec2 describe-addresses \
    --query "Addresses[?AssociationId==null].{PublicIp:PublicIp,AllocationId:AllocationId}" \
    --output table

# 5. GCP 비용 분석
echo "💰 GCP 비용 분석..."
gcloud billing budgets list

# 6. 중지된 GCP 인스턴스 찾기
echo "🔍 중지된 GCP 인스턴스:"
gcloud compute instances list --filter="status=TERMINATED" --format="table[name,zone,status]"

# 7. 사용하지 않는 GCP 디스크 찾기
echo "🔍 사용하지 않는 GCP 디스크:"
gcloud compute disks list --filter="status=UNATTACHED" --format="table[name,zone,sizeGb,status]"

# 8. 비용 최적화 권장사항
echo "📊 비용 최적화 권장사항:"
echo "1. 중지된 인스턴스 삭제 또는 스냅샷 생성 후 삭제"
echo "2. 사용하지 않는 EBS 볼륨 삭제"
echo "3. 사용하지 않는 Elastic IP 해제"
echo "4. 예약 인스턴스 고려 ["장기 사용 시"]"
echo "5. 스팟 인스턴스 활용 ["개발/테스트 환경"]"

# 9. 확인 가능한 URL들
echo "🌐 비용 최적화 확인 URL들:"
echo "- AWS Cost Explorer: https://console.aws.amazon.com/cost-management/home#/dashboard"
echo "- AWS Budgets: https://console.aws.amazon.com/billing/home#/budgets"
echo "- AWS Trusted Advisor: https://console.aws.amazon.com/trustedadvisor/"
echo "- GCP Billing: https://console.cloud.google.com/billing"
echo "- GCP Recommender: https://console.cloud.google.com/recommender"
echo "- GCP Cost Management: https://console.cloud.google.com/cost-management"
```

### 📊 예상 결과
- **성공률**: 95% ["자동화 스크립트 활용"]
- **소요 시간**: 30분 ["자동화로 단축"]
- **주요 개선**: 비용 분석 자동화, 리포트 자동 생성

---

## 🕘 4교시: 비용 최적화 및 자동 스케일링 [14:45~16:15]

### 📚 이론 학습 ["15분"]
#### 로드밸런서와 오토스케일링 연계 동작
- **자동 등록**: 오토스케일링으로 생성된 인스턴스가 자동으로 로드밸런서에 등록
- **헬스체크 연동**: 로드밸런서 헬스체크를 통한 인스턴스 상태 모니터링
- **트래픽 분산**: 스케일링된 인스턴스들에 자동으로 트래픽 분산
- **장애 복구**: 불건전한 인스턴스 자동 제거 및 교체

#### 비용 최적화 전략
- **리소스 최적화**: 사용하지 않는 리소스 제거
- **스케일링**: 수요에 따른 자동 조정
- **스팟 인스턴스**: 비용 절감을 위한 일시적 인스턴스
- **예약 인스턴스**: 장기 사용 시 할인 혜택

### 🛠️ 실습 ["75분"]

#### 🏗️ **1단계: 자동 스케일링 아키텍처 이해**

**목표 아키텍처 ["로드밸런서와 오토스케일링 연계"]**
```mermaid
flowchart TB
    subgraph "AWS Cloud"
        A1[EC2 Instances<br/>Auto Scaling Group<br/>1-3 instances]
        A2[Application Load Balancer<br/>cloud-master-day3-alb]
        A3[Target Group<br/>cloud-master-day3-targets]
        A4[Launch Template<br/>cloud-master-day3-template]
        A5["Scaling Policy<br/>CPU 기반 스케일링"]
    end
    
    subgraph "GCP Cloud"
        G1[VM Instances<br/>Managed Instance Group<br/>1-5 instances]
        G2[HTTP[S] Load Balancer<br/>cloud-master-day3-rule]
        G3[Backend Service<br/>cloud-master-day3-backend]
        G4[Instance Template<br/>cloud-master-day3-template]
        G5["Autoscaling Policy<br/>CPU 기반 스케일링"]
    end
    
    subgraph "Local - Monitoring Stack"
        M1[Prometheus<br/>:9090]
        M2[Grafana<br/>:3001]
        M3[Node Exporter<br/>:9100]
    end
    
    subgraph "Local"
        L1["개발자 머신"]
    end
    
    L1 -->> A2
    A2 -->> A3
    A3 -->> A1
    A1 -->> A4
    A1 -->> A5
    
    L1 -->> G2
    G2 -->> G3
    G3 -->> G1
    G1 -->> G4
    G1 -->> G5
    
    M1 -->> A1
    M1 -->> G1
    M2 -->> M1
    L1 -->> M2
    
    %% 연계 관계 표시
    A3 -.->>|자동 등록| A1
    A1 -.->>|스케일링| A3
    G3 -.->>|자동 등록| G1
    G1 -.->>|스케일링| G3
```

**🔍 명령 실행: AWS Auto Scaling Group 구축**
```bash
# 자동화 스크립트 실행
echo "=== AWS Auto Scaling Group 구축 시작 ==="
cloud_master/automation/day3/04-autoscaling.sh setup

# 또는 수동 실행 ["참고용"]
echo "=== 수동 AWS Auto Scaling 구축 ==="
# 1. Launch Template 생성
LAUNCH_TEMPLATE_ID=$[aws ec2 create-launch-template \
    --launch-template-name cloud-master-day3-template \
    --launch-template-data '{
        "ImageId": "ami-0c02fb55956c7d316",
        "InstanceType": "t2.micro",
        "SecurityGroupIds": ["'$SECURITY_GROUP'"],
        "TagSpecifications": [{
            "ResourceType": "instance",
            "Tags": [{"Key": "Name", "Value": "cloud-master-day3-asg"}]
        }]
    }' \
    --query 'LaunchTemplate.LaunchTemplateId' --output text]
echo "Launch Template ID: $LAUNCH_TEMPLATE_ID"

# 2. Auto Scaling Group 생성 ["로드밸런서와 연계"]
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name cloud-master-day3-asg \
    --launch-template LaunchTemplateId=$LAUNCH_TEMPLATE_ID,Version='$Latest' \
    --min-size 1 --max-size 3 --desired-capacity 2 \
    --target-group-arns $TARGET_GROUP_ARN \
    --health-check-type ELB --health-check-grace-period 300 \
    --vpc-zone-identifier $[aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" \
        --query 'Subnets[*].SubnetId' --output text | tr '\n' ',' | sed 's/,$//']

echo "✅ Auto Scaling Group이 Target Group과 연계되어 생성됨"
echo "   - 새 인스턴스가 자동으로 Target Group에 등록됨"
echo "   - 로드밸런서가 Auto Scaling Group 인스턴스들을 자동으로 관리함"

# 3. 스케일링 정책 생성
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name cloud-master-day3-asg \
    --policy-name scale-out-policy \
    --policy-type TargetTrackingScaling \
    --target-tracking-configuration '{
        "TargetValue": 70.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ASGAverageCPUUtilization"
        }
    }'

# 4. Auto Scaling Group 상태 확인
aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names cloud-master-day3-asg \
    --query 'AutoScalingGroups[0].{DesiredCapacity:DesiredCapacity,MinSize:MinSize,MaxSize:MaxSize,Instances:length[Instances]}'
```

**✅ 예상 결과:**
- Launch Template ID: `lt-1234567890abcdef0` 생성
- Auto Scaling Group: `cloud-master-day3-asg` 생성
- 현재 인스턴스 수: 2개 [desired capacity]
- 스케일링 정책: CPU 70% 기준으로 자동 스케일링

**🌐 콘솔에서 확인:**
- AWS Auto Scaling Groups: https://console.aws.amazon.com/ec2autoscaling/home?region=us-east-1#/groups
- AWS Launch Templates: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LaunchTemplates:

---

#### 🎯 **2단계: GCP Managed Instance Group 구축**

**🔍 명령 실행: GCP MIG 구축**
```bash
# 자동화 스크립트 실행
echo "=== GCP Managed Instance Group 구축 시작 ==="
cloud_master/automation/day3/04-autoscaling.sh setup

# 또는 수동 실행 ["참고용"]
echo "=== 수동 GCP MIG 구축 ==="
# 1. Instance Template 생성
gcloud compute instance-templates create cloud-master-day3-template \
    --image-family=ubuntu-2004-lts --image-project=ubuntu-os-cloud \
    --machine-type=e2-micro --boot-disk-size=10GB \
    --tags=http-server

# 2. Managed Instance Group 생성 ["로드밸런서와 연계"]
gcloud compute instance-groups managed create cloud-master-day3-mig \
    --template=cloud-master-day3-template --size=2 --zone=asia-northeast3-a

echo "✅ Managed Instance Group이 생성됨"

# 3. MIG를 Backend Service에 연결 ["로드밸런서 연계"]
gcloud compute backend-services add-backend cloud-master-day3-backend \
    --instance-group=cloud-master-day3-mig \
    --instance-group-zone=asia-northeast3-a --global

echo "✅ MIG가 Backend Service와 연계됨"
echo "   - MIG 인스턴스들이 자동으로 로드밸런서에 등록됨"
echo "   - 로드밸런서가 MIG 인스턴스들을 자동으로 관리함"

# 4. Auto Scaling 정책 설정
gcloud compute instance-groups managed set-autoscaling cloud-master-day3-mig \
    --zone=asia-northeast3-a --max-num-replicas=5 --min-num-replicas=1 \
    --target-cpu-utilization=0.7 --cool-down-period=60

# 4. MIG 상태 확인
gcloud compute instance-groups managed describe cloud-master-day3-mig \
    --zone=asia-northeast3-a \
    --format="value[targetSize,autoscaler.autoscalingPolicy.maxNumReplicas,autoscaler.autoscalingPolicy.minNumReplicas]"
```

**✅ 예상 결과:**
- Instance Template: `cloud-master-day3-template` 생성
- Managed Instance Group: `cloud-master-day3-mig` 생성
- 현재 인스턴스 수: 2개
- Auto Scaling 정책: CPU 70% 기준, 1-5개 인스턴스

**🌐 콘솔에서 확인:**
- GCP Instance Groups: https://console.cloud.google.com/compute/instanceGroups
- GCP Instance Templates: https://console.cloud.google.com/compute/instanceTemplates

---

#### 🎯 **3단계: 로드밸런서와 오토스케일링 연계 동작 확인**

**🔍 명령 실행: 로드밸런서-오토스케일링 연계 상태 확인**
```bash
echo "=== 로드밸런서와 오토스케일링 연계 동작 확인 ==="

# 1. AWS ALB와 Auto Scaling Group 연계 확인
echo "--- AWS ALB ↔ Auto Scaling Group 연계 상태 ---"
echo "ALB Target Group 상태:"
aws elbv2 describe-target-health --target-group-arn $TARGET_GROUP_ARN \
    --query 'TargetHealthDescriptions[*].{InstanceId:Target.Id,Port:Target.Port,Health:TargetHealth.State}'

echo "Auto Scaling Group 인스턴스 상태:"
aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names cloud-master-day3-asg \
    --query 'AutoScalingGroups[0].{DesiredCapacity:DesiredCapacity,Instances:length[Instances],HealthStatus:Instances[0].HealthStatus}'

echo "Auto Scaling Group 인스턴스 목록:"
aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names cloud-master-day3-asg \
    --query 'AutoScalingGroups[0].Instances[*].{InstanceId:InstanceId,HealthStatus:HealthStatus,LifecycleState:LifecycleState}'

# 2. GCP Load Balancer와 MIG 연계 확인
echo "--- GCP Load Balancer ↔ MIG 연계 상태 ---"
echo "Backend Service 상태:"
gcloud compute backend-services get-health cloud-master-day3-backend --global

echo "MIG 인스턴스 상태:"
gcloud compute instance-groups managed list-instances cloud-master-day3-mig \
    --zone=asia-northeast3-a \
    --format="table[instance,status,currentAction,healthState]"

# 3. 로드밸런서를 통한 트래픽 분산 확인
echo "--- 로드밸런서 트래픽 분산 테스트 ---"
ALB_DNS=$[aws elbv2 describe-load-balancers --names cloud-master-day3-alb \
    --query 'LoadBalancers[0].DNSName' --output text]
LB_IP=$[gcloud compute forwarding-rules describe cloud-master-day3-rule \
    --global --format="value[IPAddress]"]

echo "AWS ALB 트래픽 분산 테스트 ["10회 요청"]:"
for i in {1..10}; do
    echo -n "요청 $i: "
    curl -s http://$ALB_DNS | grep -o "Server: [^<]*" || echo "응답 없음"
    sleep 1
done

echo "GCP LB 트래픽 분산 테스트 ["10회 요청"]:"
for i in {1..10}; do
    echo -n "요청 $i: "
    curl -s http://$LB_IP | grep -o "Server: [^<]*" || echo "응답 없음"
    sleep 1
done
```

**✅ 예상 결과:**
- AWS ALB: Target Group에 Auto Scaling Group 인스턴스들이 `healthy` 상태로 등록
- GCP LB: Backend Service에 MIG 인스턴스들이 `HEALTHY` 상태로 등록
- 트래픽 분산: 로드밸런서가 여러 인스턴스에 요청을 분산하여 처리
- 연계 동작: 오토스케일링으로 생성된 인스턴스가 자동으로 로드밸런서에 등록

#### 🎯 **4단계: 자동 스케일링 동작 테스트**

**🔍 명령 실행: 스케일링 동작 테스트**
```bash
echo "=== 자동 스케일링 동작 테스트 시작 ==="

# 1. 현재 상태 확인
echo "--- 현재 스케일링 상태 ---"
echo "AWS Auto Scaling Group:"
aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names cloud-master-day3-asg \
    --query 'AutoScalingGroups[0].{DesiredCapacity:DesiredCapacity,MinSize:MinSize,MaxSize:MaxSize,Instances:length[Instances]}'

echo "GCP MIG:"
gcloud compute instance-groups managed describe cloud-master-day3-mig \
    --zone=asia-northeast3-a \
    --format="value[targetSize,autoscaler.autoscalingPolicy.maxNumReplicas,autoscaler.autoscalingPolicy.minNumReplicas]"

# 2. CPU 부하 생성으로 스케일링 트리거 ["선택사항"]
echo "--- CPU 부하 생성으로 스케일링 테스트 ---"
echo "⚠️ 주의: 이 테스트는 실제 CPU 부하를 생성합니다."
read -p "CPU 부하 테스트를 실행하시겠습니까? [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "CPU 부하 생성 중... ["60초간"]"
    # CPU 부하 생성 ["백그라운드"]
    yes > /dev/null &
    LOAD_PID=$!
    
    echo "CPU 부하 생성됨 [PID: $LOAD_PID]"
    echo "60초 후 자동으로 종료됩니다..."
    
    # 60초 대기
    sleep 60
    
    # 부하 종료
    kill $LOAD_PID 2>/dev/null
    echo "CPU 부하 테스트 완료"
    
    # 스케일링 결과 확인
    echo "--- 스케일링 결과 확인 ---"
    echo "AWS Auto Scaling Group 상태:"
    aws autoscaling describe-auto-scaling-groups \
        --auto-scaling-group-names cloud-master-day3-asg \
        --query 'AutoScalingGroups[0].{DesiredCapacity:DesiredCapacity,Instances:length[Instances]}'
    
    echo "GCP MIG 상태:"
    gcloud compute instance-groups managed list-instances cloud-master-day3-mig \
        --zone=asia-northeast3-a \
        --format="table[instance,status,currentAction]"
else
    echo "CPU 부하 테스트를 건너뜁니다."
fi

# 3. 스케일링 활동 로그 확인
echo "--- 스케일링 활동 로그 ---"
echo "AWS Auto Scaling 활동:"
aws autoscaling describe-scaling-activities \
    --auto-scaling-group-name cloud-master-day3-asg \
    --max-items 5 \
    --query 'Activities[*].{Time:StartTime,Status:StatusCode,Description:Description}'

echo "GCP MIG 활동:"
gcloud compute instance-groups managed list-instances cloud-master-day3-mig \
    --zone=asia-northeast3-a \
    --format="table[instance,status,currentAction,lastAttempt]"
```

**✅ 예상 결과:**
- AWS ASG: 2개 인스턴스 실행 중, `Healthy` 상태
- GCP MIG: 2개 인스턴스 실행 중, `RUNNING` 상태
- CPU 사용률이 70% 초과 시 자동으로 인스턴스 추가

#### 🎯 **5단계: 로드밸런서-오토스케일링 연계 부하테스트**

**🔍 명령 실행: 연계 동작 검증을 위한 부하테스트**
```bash
echo "=== 로드밸런서-오토스케일링 연계 부하테스트 시작 ==="

# 1. 초기 상태 확인
echo "--- 부하테스트 전 초기 상태 ---"
echo "AWS Auto Scaling Group 초기 상태:"
aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names cloud-master-day3-asg \
    --query 'AutoScalingGroups[0].{DesiredCapacity:DesiredCapacity,Instances:length[Instances]}'

echo "GCP MIG 초기 상태:"
gcloud compute instance-groups managed describe cloud-master-day3-mig \
    --zone=asia-northeast3-a \
    --format="value[targetSize]"

# 2. 로드밸런서 접속 정보 확인
ALB_DNS=$[aws elbv2 describe-load-balancers --names cloud-master-day3-alb \
    --query 'LoadBalancers[0].DNSName' --output text]
LB_IP=$[gcloud compute forwarding-rules describe cloud-master-day3-rule \
    --global --format="value[IPAddress]"]

echo "부하테스트 대상:"
echo "- AWS ALB: http://$ALB_DNS"
echo "- GCP LB: http://$LB_IP"

# 3. Apache Bench를 이용한 부하테스트 ["설치 확인"]
if command -v ab &> /dev/null; then
    echo "--- Apache Bench 부하테스트 실행 ---"
    
    echo "AWS ALB 부하테스트 ["1000 요청, 동시 50개"]:"
    ab -n 1000 -c 50 http://$ALB_DNS/ > aws_alb_loadtest.log 2>&1 &
    AWS_PID=$!
    
    echo "GCP LB 부하테스트 ["1000 요청, 동시 50개"]:"
    ab -n 1000 -c 50 http://$LB_IP/ > gcp_lb_loadtest.log 2>&1 &
    GCP_PID=$!
    
    echo "부하테스트 실행 중... [PID: AWS=$AWS_PID, GCP=$GCP_PID]"
    echo "진행 상황을 모니터링합니다..."
    
    # 4. 부하테스트 중 스케일링 모니터링 ["모니터링 스택 연계"]
    echo "=== 모니터링 스택 연계 부하테스트 시작 ==="
    
    # Prometheus 메트릭 수집 시작
    echo "Prometheus 메트릭 수집 시작..."
    PROMETHEUS_URL="http://localhost:9090"
    GRAFANA_URL="http://localhost:3001"
    
    # 부하테스트 시작 시간 기록
    LOADTEST_START_TIME=$[date -u +%Y-%m-%dT%H:%M:%S]
    echo "부하테스트 시작 시간: $LOADTEST_START_TIME"
    
    for i in {1..20}; do
        echo "--- 모니터링 $i/20 ["10초 간격"] ---"
        
        # AWS ASG 상태
        echo "AWS ASG 상태:"
        aws autoscaling describe-auto-scaling-groups \
            --auto-scaling-group-names cloud-master-day3-asg \
            --query 'AutoScalingGroups[0].{DesiredCapacity:DesiredCapacity,Instances:length[Instances]}'
        
        # GCP MIG 상태
        echo "GCP MIG 상태:"
        gcloud compute instance-groups managed describe cloud-master-day3-mig \
            --zone=asia-northeast3-a \
            --format="value[targetSize]"
        
        # Prometheus 메트릭 확인
        echo "Prometheus 메트릭 확인:"
        if curl -s $PROMETHEUS_URL/api/v1/query?query=up > /dev/null; then
            echo "✅ Prometheus 연결됨"
            
            # CPU 사용률 메트릭 쿼리
            CPU_METRICS=$[curl -s "$PROMETHEUS_URL/api/v1/query?query=100%20-%20[avg%20by%20[instance]%20[irate[node_cpu_seconds_total{mode=\"idle\"}[5m]]]%20*%20100]"]
            echo "CPU 사용률 메트릭: $CPU_METRICS"
            
            # 메모리 사용률 메트릭 쿼리
            MEMORY_METRICS=$[curl -s "$PROMETHEUS_URL/api/v1/query?query=[1%20-%20[node_memory_MemAvailable_bytes%20/%20node_memory_MemTotal_bytes]]%20*%20100"]
            echo "메모리 사용률 메트릭: $MEMORY_METRICS"
            
            # HTTP 요청 메트릭 쿼리 ["nginx_exporter가 있다면"]
            HTTP_METRICS=$[curl -s "$PROMETHEUS_URL/api/v1/query?query=rate[nginx_http_requests_total[1m]]"]
            echo "HTTP 요청 메트릭: $HTTP_METRICS"
        else
            echo "❌ Prometheus 연결 실패"
        fi
        
        # Grafana 대시보드 상태 확인
        echo "Grafana 대시보드 확인:"
        if curl -s $GRAFANA_URL/api/health > /dev/null; then
            echo "✅ Grafana 연결됨 - 대시보드에서 실시간 모니터링 가능"
            echo "   대시보드 URL: $GRAFANA_URL"
        else
            echo "❌ Grafana 연결 실패"
        fi
        
        # AWS CloudWatch 메트릭 확인
        echo "AWS CloudWatch 메트릭:"
        aws cloudwatch get-metric-statistics \
            --namespace AWS/EC2 \
            --metric-name CPUUtilization \
            --dimensions Name=AutoScalingGroupName,Value=cloud-master-day3-asg \
            --start-time $[date -u -d '5 minutes ago' +%Y-%m-%dT%H:%M:%S] \
            --end-time $[date -u +%Y-%m-%dT%H:%M:%S] \
            --period 300 \
            --statistics Average \
            --query 'Datapoints[0].Average' --output text 2>/dev/null || echo "데이터 없음"
        
        # GCP Monitoring 메트릭 확인
        echo "GCP Monitoring 메트릭:"
        gcloud monitoring metrics list --filter="metric.type:compute.googleapis.com/instance/cpu/utilization" \
            --limit=5 --format="value[metric.type]" 2>/dev/null || echo "GCP Monitoring 데이터 없음"
        
        sleep 10
    done
    
    # 5. 부하테스트 완료 대기
    echo "부하테스트 완료 대기 중..."
    wait $AWS_PID
    wait $GCP_PID
    
    echo "부하테스트 완료!"
    
    # 6. 부하테스트 결과 분석 ["모니터링 스택 연계"]
    echo "--- 부하테스트 결과 분석 ["모니터링 스택 연계"] ---"
    
    # 부하테스트 종료 시간 기록
    LOADTEST_END_TIME=$[date -u +%Y-%m-%dT%H:%M:%S]
    echo "부하테스트 종료 시간: $LOADTEST_END_TIME"
    
    # Apache Bench 결과 분석
    echo "AWS ALB Apache Bench 결과:"
    grep -E "[Requests per second|Time per request|Failed requests]" aws_alb_loadtest.log || echo "결과 분석 실패"
    
    echo "GCP LB Apache Bench 결과:"
    grep -E "[Requests per second|Time per request|Failed requests]" gcp_lb_loadtest.log || echo "결과 분석 실패"
    
    # Prometheus 메트릭 기반 분석
    echo "--- Prometheus 메트릭 기반 부하테스트 분석 ---"
    if curl -s $PROMETHEUS_URL/api/v1/query?query=up > /dev/null; then
        echo "부하테스트 기간 중 최대 CPU 사용률:"
        MAX_CPU=$[curl -s "$PROMETHEUS_URL/api/v1/query?query=max_over_time[100%20-%20[avg%20by%20[instance]%20[irate[node_cpu_seconds_total{mode=\"idle\"}[5m]]]%20*%20100][10m:1m]]"]
        echo "$MAX_CPU"
        
        echo "부하테스트 기간 중 최대 메모리 사용률:"
        MAX_MEMORY=$[curl -s "$PROMETHEUS_URL/api/v1/query?query=max_over_time[[1%20-%20[node_memory_MemAvailable_bytes%20/%20node_memory_MemTotal_bytes]]%20*%20100[10m:1m]]"]
        echo "$MAX_MEMORY"
        
        echo "부하테스트 기간 중 평균 응답 시간:"
        AVG_RESPONSE_TIME=$[curl -s "$PROMETHEUS_URL/api/v1/query?query=avg_over_time[http_request_duration_seconds[10m]]"]
        echo "$AVG_RESPONSE_TIME"
    else
        echo "❌ Prometheus 연결 실패 - 메트릭 분석 불가"
    fi
    
    # Grafana 대시보드에서 부하테스트 결과 확인 안내
    echo "--- Grafana 대시보드에서 부하테스트 결과 확인 ---"
    echo "1. Grafana 대시보드 접속: $GRAFANA_URL [admin/admin]"
    echo "2. 부하테스트 기간: $LOADTEST_START_TIME ~ $LOADTEST_END_TIME"
    echo "3. 확인할 메트릭:"
    echo "   - CPU 사용률 그래프"
    echo "   - 메모리 사용률 그래프"
    echo "   - HTTP 요청 수 그래프"
    echo "   - 응답 시간 그래프"
    echo "   - 인스턴스 수 변화 그래프"
    
else
    echo "Apache Bench가 설치되지 않았습니다."
    echo "수동 부하테스트를 실행합니다..."
    
    # 7. 수동 부하테스트 ["curl 기반"]
    echo "--- 수동 부하테스트 ["curl 기반"] ---"
    echo "AWS ALB 수동 부하테스트 ["100회 요청"]:"
    for i in {1..100}; do
        curl -s -o /dev/null -w "요청 $i: %{http_code} - %{time_total}s\n" http://$ALB_DNS/ &
        if [ $[[i % 10]] -eq 0 ]; then
            wait  # 10개씩 배치로 실행
        fi
    done
    wait
    
    echo "GCP LB 수동 부하테스트 ["100회 요청"]:"
    for i in {1..100}; do
        curl -s -o /dev/null -w "요청 $i: %{http_code} - %{time_total}s\n" http://$LB_IP/ &
        if [ $[[i % 10]] -eq 0 ]; then
            wait  # 10개씩 배치로 실행
        fi
    done
    wait
fi

# 8. 부하테스트 후 스케일링 결과 확인
echo "--- 부하테스트 후 스케일링 결과 ---"
echo "AWS Auto Scaling Group 최종 상태:"
aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names cloud-master-day3-asg \
    --query 'AutoScalingGroups[0].{DesiredCapacity:DesiredCapacity,Instances:length[Instances],MinSize:MinSize,MaxSize:MaxSize}'

echo "GCP MIG 최종 상태:"
gcloud compute instance-groups managed describe cloud-master-day3-mig \
    --zone=asia-northeast3-a \
    --format="value[targetSize,autoscaler.autoscalingPolicy.maxNumReplicas,autoscaler.autoscalingPolicy.minNumReplicas]"

# 9. 스케일링 활동 로그 확인
echo "--- 스케일링 활동 로그 ---"
echo "AWS Auto Scaling 활동 ["최근 10개"]:"
aws autoscaling describe-scaling-activities \
    --auto-scaling-group-name cloud-master-day3-asg \
    --max-items 10 \
    --query 'Activities[*].{Time:StartTime,Status:StatusCode,Description:Description}' \
    --output table

echo "GCP MIG 인스턴스 상태:"
gcloud compute instance-groups managed list-instances cloud-master-day3-mig \
    --zone=asia-northeast3-a \
    --format="table[instance,status,currentAction,healthState]"

# 10. 로드밸런서 헬스체크 상태 확인
echo "--- 로드밸런서 헬스체크 상태 ---"
echo "AWS ALB Target Group 헬스체크:"
aws elbv2 describe-target-health --target-group-arn $TARGET_GROUP_ARN \
    --query 'TargetHealthDescriptions[*].{InstanceId:Target.Id,Health:TargetHealth.State,Reason:TargetHealth.Reason}'

echo "GCP Backend Service 헬스체크:"
gcloud compute backend-services get-health cloud-master-day3-backend --global
```

**✅ 예상 결과:**
- **부하테스트 전**: AWS 2개, GCP 2개 인스턴스
- **부하테스트 중**: CPU 사용률 증가로 인한 스케일링 트리거
- **부하테스트 후**: AWS 최대 3개, GCP 최대 5개 인스턴스로 확장
- **응답 시간**: 부하 증가에도 안정적인 응답 시간 유지
- **헬스체크**: 모든 인스턴스가 `healthy` 상태 유지

**🌐 브라우저로 부하테스트 결과 확인:**
```bash
echo "=== 부하테스트 결과 확인 ==="
echo "1. Grafana: http://localhost:3001 - CPU 사용률 및 응답 시간 그래프 확인"
echo "2. Prometheus: http://localhost:9090/graph - 메트릭 쿼리로 부하 확인"
echo "3. AWS Console: Auto Scaling Groups에서 스케일링 활동 확인"
echo "4. GCP Console: Instance Groups에서 스케일링 활동 확인"
echo ""
echo "확인 포인트:"
echo "- CPU 사용률이 70% 초과했는지"
echo "- 자동으로 인스턴스가 추가되었는지"
echo "- 부하 분산이 정상적으로 작동했는지"
echo "- 응답 시간이 안정적으로 유지되었는지"
```

**🌐 브라우저로 모니터링 확인:**
```bash
echo "=== 자동 스케일링 모니터링 ==="
echo "1. Grafana: http://localhost:3001 - CPU 사용률 대시보드 확인"
echo "2. Prometheus: http://localhost:9090/graph - CPU 메트릭 쿼리"
echo "3. AWS Console: Auto Scaling Groups에서 스케일링 활동 확인"
echo "4. GCP Console: Instance Groups에서 스케일링 활동 확인"
echo ""
echo "CPU 부하를 생성한 후 다음을 확인하세요:"
echo "- CPU 사용률이 70% 초과하는지"
echo "- 자동으로 인스턴스가 추가되는지"
echo "- 스케일링 활동 로그 확인"
```

---

#### 🎯 **4단계: 비용 최적화 분석**

**🔍 명령 실행: 비용 최적화 분석**
```bash
# 자동화 스크립트 실행
echo "=== 비용 최적화 분석 시작 ==="
cloud_master/automation/day3/05-cost-optimization.sh analyze

# 또는 수동 실행 ["참고용"]
echo "=== 수동 비용 최적화 분석 ==="
# 1. AWS 비용 분석
echo "--- AWS 비용 분석 ---"
aws ce get-cost-and-usage \
    --time-period Start=2024-01-01,End=2024-12-31 \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=DIMENSION,Key=SERVICE

# 2. 사용하지 않는 AWS 리소스 찾기
echo "--- 사용하지 않는 AWS 리소스 ---"
echo "중지된 EC2 인스턴스:"
aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=stopped" \
    --query "Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name,LaunchTime:LaunchTime}" \
    --output table

echo "사용하지 않는 EBS 볼륨:"
aws ec2 describe-volumes \
    --filters "Name=status,Values=available" \
    --query "Volumes[].{VolumeId:VolumeId,Size:Size,CreateTime:CreateTime}" \
    --output table

# 3. GCP 비용 분석
echo "--- GCP 비용 분석 ---"
gcloud billing budgets list

# 4. 중지된 GCP 인스턴스 찾기
echo "--- 중지된 GCP 인스턴스 ---"
gcloud compute instances list --filter="status=TERMINATED" --format="table[name,zone,status]"
```

**✅ 예상 결과:**
- AWS 비용 분석: 서비스별 월간 비용 리포트
- 사용하지 않는 리소스: 중지된 인스턴스, 미사용 볼륨 목록
- GCP 비용 분석: 예산 설정 및 사용량 확인
- 비용 절약 권장사항 자동 생성

**🌐 브라우저로 비용 관리 확인:**
```bash
echo "=== 비용 관리 콘솔 접속 ==="
echo "AWS Cost Explorer: https://console.aws.amazon.com/cost-management/home#/dashboard"
echo "AWS Budgets: https://console.aws.amazon.com/billing/home#/budgets"
echo "GCP Billing: https://console.cloud.google.com/billing"
echo "GCP Recommender: https://console.cloud.google.com/recommender"
echo ""
echo "각 콘솔에서 다음을 확인하세요:"
echo "- 현재 월간 비용"
echo "- 비용 트렌드 분석"
echo "- 비용 최적화 권장사항"
echo "- 예산 설정 및 알림"
```

**🌐 콘솔에서 최종 확인:**
- AWS Cost Explorer: 비용 분석 및 트렌드
- GCP Billing: 예산 및 사용량 모니터링
- 자동 스케일링 활동 로그 확인

#### 🚀 **권장: 자동화 스크립트 사용**
```bash
# 자동 스케일링 자동 설정 실행
cloud_master/automation/day3/04-autoscaling.sh setup

# 자동화 장점:
# ✅ AWS Auto Scaling Group 자동 생성
# ✅ GCP Managed Instance Group 자동 설정
# ✅ 스케일링 정책 자동 구성
# ✅ 헬스체크 자동 설정
# ✅ 타겟 그룹 자동 연결
```

#### 🔧 **수동 자동 스케일링 설정 ["참고용"]**
```bash
# AWS Auto Scaling 수동 설정

# 1. Launch Template 생성
LAUNCH_TEMPLATE_ID=$[aws ec2 create-launch-template \
    --launch-template-name cloud-master-day3-template \
    --launch-template-data '{
        "ImageId": "ami-0c02fb55956c7d316",
        "InstanceType": "t2.micro",
        "SecurityGroupIds": ["'$SECURITY_GROUP'"],
        "TagSpecifications": [{
            "ResourceType": "instance",
            "Tags": [{"Key": "Name", "Value": "cloud-master-day3-asg"}]
        }]
    }' \
    --query 'LaunchTemplate.LaunchTemplateId' --output text]

# 2. Auto Scaling Group 생성
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name cloud-master-day3-asg \
    --launch-template LaunchTemplateId=$LAUNCH_TEMPLATE_ID,Version='$Latest' \
    --min-size 1 --max-size 3 --desired-capacity 2 \
    --target-group-arns $TARGET_GROUP_ARN \
    --health-check-type ELB --health-check-grace-period 300

# 3. 스케일링 정책 생성
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name cloud-master-day3-asg \
    --policy-name scale-out-policy \
    --policy-type TargetTrackingScaling \
    --target-tracking-configuration '{
        "TargetValue": 70.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ASGAverageCPUUtilization"
        }
    }'

# GCP Managed Instance Group 수동 설정
gcloud compute instance-templates create cloud-master-day3-template \
    --image-family=ubuntu-2004-lts --image-project=ubuntu-os-cloud \
    --machine-type=e2-micro --boot-disk-size=10GB

gcloud compute instance-groups managed create cloud-master-day3-mig \
    --template=cloud-master-day3-template --size=2 --zone=asia-northeast3-a

gcloud compute instance-groups managed set-autoscaling cloud-master-day3-mig \
    --zone=asia-northeast3-a --max-num-replicas=5 --min-num-replicas=1 \
    --target-cpu-utilization=0.7 --cool-down-period=60

# 확인 가능한 URL들
echo "🌐 자동 스케일링 확인 URL들:"
echo "- AWS Auto Scaling Groups: https://console.aws.amazon.com/ec2autoscaling/home?region=us-east-1#/groups"
echo "- AWS Launch Templates: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LaunchTemplates:"
echo "- AWS CloudWatch Alarms: https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#alarmsV2:"
echo "- GCP Instance Groups: https://console.cloud.google.com/compute/instanceGroups"
echo "- GCP Instance Templates: https://console.cloud.google.com/compute/instanceTemplates"
echo "- GCP Monitoring: https://console.cloud.google.com/monitoring"
```

### 📊 예상 결과
- **성공률**: 95% ["자동화 스크립트 활용"]
- **소요 시간**: 30분 ["자동화로 단축"]
- **주요 개선**: 스케일링 정책 자동 구성, 헬스체크 자동 설정

### 🏗️ 시스템 아키텍처 변화

#### 3단계: 자동 스케일링 설정 후
```mermaid
flowchart TB
    subgraph "AWS"
        A1[EC2 Instances<br/>Auto Scaling Group]
        A2["Security Group<br/>기존 설정"]
        A3["VPC<br/>기본 VPC"]
        A4[Application Load Balancer<br/>cloud-master-day3-alb]
        A5[Target Group<br/>cloud-master-day3-targets]
        A6[Listener<br/>HTTP:80]
        A7[Auto Scaling Group<br/>cloud-master-day3-asg]
        A8[Launch Template<br/>cloud-master-day3-template]
        A9["Scaling Policy<br/>CPU 기반 스케일링"]
    end
    
    subgraph "GCP"
        G1[VM Instances<br/>Managed Instance Group]
        G2["Firewall Rules<br/>기존 설정"]
        G3["VPC Network<br/>기본 네트워크"]
        G4[HTTP[S] Load Balancer<br/>cloud-master-day3-rule]
        G5[Backend Service<br/>cloud-master-day3-backend]
        G6[Instance Group<br/>cloud-master-day3-ig]
        G7[Health Check<br/>cloud-master-day3-hc]
        G8[Managed Instance Group<br/>cloud-master-day3-mig]
        G9[Instance Template<br/>cloud-master-day3-template]
        G10["Autoscaling Policy<br/>CPU 기반 스케일링"]
    end
    
    subgraph "Local - Monitoring Stack"
        M1[Prometheus<br/>:9090]
        M2[Grafana<br/>:3001]
        M3[Node Exporter<br/>:9100]
        M4["Docker Compose<br/>모니터링 스택"]
    end
    
    subgraph "Local"
        L1["개발자 머신"]
    end
    
    L1 -->> A4
    A4 -->> A6
    A6 -->> A5
    A5 -->> A1
    A5 -->> A7
    A7 -->> A8
    A7 -->> A9
    
    L1 -->> G4
    G4 -->> G5
    G5 -->> G6
    G6 -->> G1
    G5 -->> G8
    G8 -->> G9
    G8 -->> G10
    G5 -->> G7
    G7 -->> G1
    
    M1 -->> A1
    M1 -->> G1
    M3 -->> A1
    M3 -->> G1
    M2 -->> M1
    L1 -->> M2
    L1 -->> M1
    L1 -->> M3
```

**적용된 기능:**
- ✅ **AWS Auto Scaling**: CPU 기반 자동 스케일링
- ✅ **GCP MIG**: Managed Instance Group 자동 스케일링
- ✅ **Launch Template**: 인스턴스 템플릿 자동 생성
- ✅ **Scaling Policy**: 스케일링 정책 자동 구성
- ✅ **동적 리소스 관리**: 수요에 따른 자동 인스턴스 조정
- ✅ **로드밸런서 연계**: 오토스케일링 인스턴스가 자동으로 로드밸런서에 등록
- ✅ **헬스체크 연동**: 로드밸런서 헬스체크를 통한 인스턴스 상태 관리
- ✅ **트래픽 분산**: 스케일링된 인스턴스들에 자동 트래픽 분산

#### 📊 장단점 분석

**✅ 장점:**
- **비용 최적화**: 트래픽에 따라 자동으로 리소스 조정하여 비용 절약
- **성능 보장**: 높은 부하 시 자동으로 인스턴스 추가하여 성능 유지
- **운영 효율성**: 수동 개입 없이 자동으로 시스템 관리
- **확장성**: 수요 증가에 즉시 대응 가능
- **안정성**: 인스턴스 장애 시 자동으로 교체
- **멀티 클라우드**: AWS와 GCP 모두에서 동일한 자동 스케일링 적용

**❌ 단점:**
- **복잡성 증가**: 스케일링 정책 설정과 튜닝이 복잡
- **비용 예측 어려움**: 자동 스케일링으로 인한 비용 변동성 증가
- **Cold Start**: 새 인스턴스 시작 시 초기 응답 시간 지연
- **설정 오류 위험**: 잘못된 스케일링 정책으로 과도한 비용 발생 가능
- **의존성**: 스케일링 정책에 의존하여 수동 제어 어려움
- **모니터링 필요**: 스케일링 동작을 지속적으로 모니터링해야 함

---

## 🕘 5교시: 통합 테스트 및 최종 정리 [16:30~17:00]

### 🛠️ 실습 ["30분"]

#### 🏗️ **1단계: 최종 아키텍처 확인**

**최종 완성된 아키텍처**
```mermaid
flowchart TB
    subgraph "AWS Cloud"
        A1[EC2 Instances<br/>Auto Scaling Group<br/>1-3 instances]
        A2[Application Load Balancer<br/>High Availability]
        A3[Target Groups<br/>Health Checks]
        A4[Security Groups<br/>Network Security]
        A5[VPC<br/>Network Isolation]
        A6[Cost Optimization<br/>Resource Management]
    end
    
    subgraph "GCP Cloud"
        G1[VM Instances<br/>Managed Instance Group<br/>1-5 instances]
        G2[HTTP[S] Load Balancer<br/>Global Load Balancing]
        G3[Backend Services<br/>Health Checks]
        G4[Firewall Rules<br/>Network Security]
        G5[VPC Network<br/>Network Isolation]
        G6[Cost Optimization<br/>Resource Management]
    end
    
    subgraph "Local Environment"
        L1[Prometheus<br/>Metrics Collection]
        L2[Grafana<br/>Visualization Dashboard]
        L3[Node Exporter<br/>System Metrics]
        L4[Docker Compose<br/>Monitoring Stack]
        L5[Cost Analysis Tools<br/>Optimization Scripts]
    end
    
    subgraph "Developer Machine"
        D1[CLI Tools<br/>AWS CLI, GCP CLI]
        D2[Automation Scripts<br/>Day3 Practice Scripts]
        D3[Monitoring Access<br/>Grafana, Prometheus]
    end
    
    D1 -->> A2
    D1 -->> G2
    D2 -->> A1
    D2 -->> G1
    D3 -->> L2
    D3 -->> L1
    
    A2 -->> A3
    A3 -->> A1
    A1 -->> A4
    A4 -->> A5
    
    G2 -->> G3
    G3 -->> G1
    G1 -->> G4
    G4 -->> G5
    
    L1 -->> A1
    L1 -->> G1
    L3 -->> A1
    L3 -->> G1
    L2 -->> L1
    L4 -->> L1
    L4 -->> L2
    L4 -->> L3
    
    L5 -->> A6
    L5 -->> G6
    D2 -->> L5
```

**🔍 명령 실행: 전체 시스템 상태 확인**
```bash
echo "=== 전체 시스템 통합 테스트 시작 ==="

# 1. 로드밸런서 상태 확인
echo "--- 로드밸런서 상태 확인 ---"
echo "AWS ALB 상태:"
aws elbv2 describe-load-balancers --names cloud-master-day3-alb \
    --query 'LoadBalancers[0].{DNSName:DNSName,State:State.Code,Scheme:Scheme}'

echo "GCP Load Balancer 상태:"
gcloud compute forwarding-rules describe cloud-master-day3-rule --global

# 2. 모니터링 시스템 확인
echo "--- 모니터링 시스템 확인 ---"
curl -f http://localhost:9090 && echo "✅ Prometheus 정상"
curl -f http://localhost:3001 && echo "✅ Grafana 정상"
curl -f http://localhost:9100 && echo "✅ Node Exporter 정상"

# 3. 자동 스케일링 상태 확인
echo "--- 자동 스케일링 상태 확인 ---"
echo "AWS Auto Scaling:"
aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names cloud-master-day3-asg \
    --query 'AutoScalingGroups[0].{DesiredCapacity:DesiredCapacity,MinSize:MinSize,MaxSize:MaxSize}'

echo "GCP MIG:"
gcloud compute instance-groups managed describe cloud-master-day3-mig \
    --zone=asia-northeast3-a \
    --format="value[targetSize,autoscaler.autoscalingPolicy.maxNumReplicas]"
```

**✅ 예상 결과:**
- AWS ALB: `active` 상태, DNS 이름 확인
- GCP LB: `HEALTHY` 상태, IP 주소 확인
- 모니터링 스택: 모든 서비스 정상 동작
- 자동 스케일링: AWS 1-3개, GCP 1-5개 인스턴스 설정

---

#### 🎯 **2단계: 성능 테스트 및 검증**

**🔍 명령 실행: 성능 테스트**
```bash
echo "=== 성능 테스트 실행 ==="

# ALB DNS와 GCP LB IP 가져오기
ALB_DNS=$[aws elbv2 describe-load-balancers --names cloud-master-day3-alb \
    --query 'LoadBalancers[0].DNSName' --output text]
LB_IP=$[gcloud compute forwarding-rules describe cloud-master-day3-rule \
    --global --format="value[IPAddress]"]

echo "AWS ALB DNS: $ALB_DNS"
echo "GCP LB IP: $LB_IP"

# 1. 헬스체크 테스트
echo "--- 헬스체크 테스트 ---"
echo "AWS ALB 헬스체크:"
curl -I http://$ALB_DNS

echo "GCP LB 헬스체크:"
curl -I http://$LB_IP

# 2. 성능 테스트 [Apache Bench]
echo "--- 성능 테스트 ---"
if command -v ab &> /dev/null; then
    echo "AWS ALB 성능 테스트:"
    ab -n 100 -c 5 http://$ALB_DNS/ | grep "Requests per second"
    
    echo "GCP LB 성능 테스트:"
    ab -n 100 -c 5 http://$LB_IP/ | grep "Requests per second"
else
    echo "Apache Bench가 설치되지 않았습니다."
    echo "수동으로 브라우저에서 응답 시간을 확인하세요."
fi

# 3. 모니터링 메트릭 확인
echo "--- 모니터링 메트릭 확인 ---"
echo "Prometheus 타겟 상태:"
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health}'
```

**✅ 예상 결과:**
- 헬스체크: HTTP 200 응답
- 성능 테스트: 초당 요청 처리 수 확인
- 모니터링: 모든 타겟 `up` 상태

**🌐 브라우저로 성능 테스트:**
```bash
echo "=== 브라우저 성능 테스트 ==="
echo "1. AWS ALB: http://$ALB_DNS"
echo "2. GCP LB: http://$LB_IP"
echo ""
echo "브라우저에서 다음을 확인하세요:"
echo "- 응답 시간 ["개발자 도구 > Network 탭"]"
echo "- 페이지 로딩 속도"
echo "- 두 로드밸런서의 성능 비교"
```

---

#### 🎯 **3단계: 비용 최적화 결과 확인**

**🔍 명령 실행: 비용 최적화 결과 확인**
```bash
echo "=== 비용 최적화 결과 확인 ==="

# 1. 비용 리포트 확인
echo "--- 비용 분석 리포트 ---"
ls -la cloud-master-day3-*/cost-optimization-report.json 2>/dev/null || echo "비용 리포트가 생성되지 않았습니다."

# 2. 사용하지 않는 리소스 확인
echo "--- 사용하지 않는 리소스 ---"
echo "중지된 AWS 인스턴스:"
aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=stopped" \
    --query "Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name}" \
    --output table

echo "중지된 GCP 인스턴스:"
gcloud compute instances list --filter="status=TERMINATED" --format="table[name,zone,status]"

# 3. 현재 실행 중인 리소스 요약
echo "--- 현재 실행 중인 리소스 요약 ---"
echo "AWS 실행 중인 인스턴스:"
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0]]' \
    --output table

echo "GCP 실행 중인 인스턴스:"
gcloud compute instances list --filter="status=RUNNING" --format="table[name,zone,status]"
```

**✅ 예상 결과:**
- 비용 최적화 리포트: JSON 형태의 상세 분석
- 사용하지 않는 리소스: 중지된 인스턴스 목록
- 현재 리소스: 실행 중인 인스턴스 요약

**🌐 브라우저로 비용 관리 확인:**
```bash
echo "=== 비용 관리 최종 확인 ==="
echo "AWS Cost Explorer: https://console.aws.amazon.com/cost-management/home#/dashboard"
echo "GCP Billing: https://console.cloud.google.com/billing"
echo ""
echo "각 콘솔에서 다음을 확인하세요:"
echo "- 현재 월간 비용"
echo "- 비용 트렌드"
echo "- 비용 최적화 권장사항"
echo "- 예산 설정"
```

---

#### 🎯 **4단계: 최종 정리 및 정리**

**🔍 명령 실행: 시스템 정리 ["선택사항"]**
```bash
echo "=== 시스템 정리 ["선택사항"] ==="
echo "⚠️ 주의: 다음 명령어는 모든 리소스를 삭제합니다!"
echo "실습을 계속 진행하려면 정리를 건너뛰세요."
echo ""

# 정리 여부 확인
read -p "정말로 모든 리소스를 정리하시겠습니까? [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "리소스 정리 시작..."
    
    # 1. 모니터링 스택 정리
    echo "--- 모니터링 스택 정리 ---"
    cd monitoring
    docker-compose down -v
    cd ..
    
    # 2. AWS 리소스 정리
    echo "--- AWS 리소스 정리 ---"
    cloud_master/automation/day3/01-aws-loadbalancing.sh cleanup
    
    # 3. GCP 리소스 정리
    echo "--- GCP 리소스 정리 ---"
    cloud_master/automation/day3/02-gcp-loadbalancing.sh cleanup
    
    echo "✅ 모든 리소스 정리 완료"
else
    echo "리소스 정리를 건너뜁니다."
    echo "수동으로 정리하려면 각 스크립트의 cleanup 옵션을 사용하세요."
fi
```

**✅ 예상 결과:**
- 모니터링 스택: 컨테이너 중지 및 볼륨 삭제
- AWS 리소스: ALB, Target Group, Auto Scaling Group 삭제
- GCP 리소스: Load Balancer, Instance Group, Template 삭제

**🌐 최종 확인:**
```bash
echo "=== 최종 확인 ==="
echo "🎉 Cloud Master Day3 실습 완료!"
echo ""
echo "📊 실습 결과 요약:"
echo "- AWS ALB 로드밸런싱 구축 완료"
echo "- GCP Cloud Load Balancing 구축 완료"
echo "- Prometheus + Grafana 모니터링 스택 구축 완료"
echo "- AWS Auto Scaling + GCP MIG 자동 스케일링 설정 완료"
echo "- 비용 최적화 분석 및 리포트 생성 완료"
echo ""
echo "🌐 접속 가능한 URL들:"
echo "- AWS ALB: http://$ALB_DNS"
echo "- GCP LB: http://$LB_IP"
echo "- Grafana: http://localhost:3001 [admin/admin]"
echo "- Prometheus: http://localhost:9090"
echo ""
echo "📚 다음 단계:"
echo "- 실습 결과 분석 및 문서화"
echo "- 추가 모니터링 대시보드 구성"
echo "- 비용 최적화 권장사항 적용"
echo "- 프로덕션 환경 적용 계획 수립"
```

#### 🚀 **권장: 통합 자동화 스크립트 사용**
```bash
# 전체 시스템 통합 테스트 자동 실행
cloud_master/automation/day3/06-integration-test.sh setup

# 개선된 통합 실습 ["매끄러운 실행"]
cloud_master/automation/day3/06-integration-test.sh setup

# 자동화 장점:
# ✅ 전체 시스템 상태 자동 확인
# ✅ 로드밸런서 헬스체크 자동 실행
# ✅ 모니터링 시스템 접속 확인
# ✅ 성능 테스트 자동 실행
# ✅ 결과 리포트 자동 생성
```

#### 🔧 **수동 통합 테스트 ["참고용"]**
```bash
# 전체 시스템 상태 확인
echo "🔍 전체 시스템 상태 확인..."

# 1. 로드밸런서 상태 확인
echo "📋 AWS ALB 상태:"
ALB_DNS=$[aws elbv2 describe-load-balancers \
    --names cloud-master-day3-alb \
    --query 'LoadBalancers[0].DNSName' --output text]
curl -f http://$ALB_DNS/health && echo "✅ AWS ALB 정상"

# 2. 모니터링 시스템 확인
echo "📋 모니터링 시스템:"
curl -f http://localhost:9090 && echo "✅ Prometheus 정상"
curl -f http://localhost:3001 && echo "✅ Grafana 정상"
curl -f http://localhost:9100 && echo "✅ Node Exporter 정상"

# 3. 자동 스케일링 상태 확인
echo "📋 자동 스케일링 상태:"
aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names cloud-master-day3-asg \
    --query 'AutoScalingGroups[0].{DesiredCapacity:DesiredCapacity,MinSize:MinSize,MaxSize:MaxSize}'

# 4. 성능 테스트 [Apache Bench]
echo "🚀 부하 테스트 시작..."
if command -v ab &> /dev/null; then
    ab -n 100 -c 5 http://$ALB_DNS/ | grep "Requests per second"
else
    echo "Apache Bench가 설치되지 않았습니다. 수동으로 테스트하세요."
fi

# 5. 비용 최적화 결과 확인
echo "💰 비용 최적화 결과:"
ls -la cloud-master-day3-*/cost-optimization-report.json 2>/dev/null || echo "비용 리포트가 생성되지 않았습니다."

echo "🎉 통합 테스트 완료!"
echo "📊 모니터링 대시보드: http://localhost:3001 [admin/admin]"
echo "📊 Prometheus: http://localhost:9090"
echo "🌐 ALB DNS: http://$ALB_DNS"

# 전체 시스템 확인 URL들
echo "🌐 전체 시스템 확인 URL들:"
echo ""
echo "📊 모니터링 시스템:"
echo "- Grafana 대시보드: http://localhost:3001 [admin/admin]"
echo "- Prometheus 메트릭: http://localhost:9090"
echo "- Node Exporter: http://localhost:9100"
echo ""
echo "☁️ AWS 리소스:"
echo "- ALB: http://$ALB_DNS"
echo "- EC2 콘솔: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:"
echo "- Load Balancer: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:"
echo "- Auto Scaling: https://console.aws.amazon.com/ec2autoscaling/home?region=us-east-1#/groups"
echo ""
echo "☁️ GCP 리소스:"
echo "- GCP 콘솔: https://console.cloud.google.com/compute/instances"
echo "- Load Balancing: https://console.cloud.google.com/net-services/loadbalancing"
echo "- Instance Groups: https://console.cloud.google.com/compute/instanceGroups"
echo "- Monitoring: https://console.cloud.google.com/monitoring"
echo ""
echo "💰 비용 관리:"
echo "- AWS Cost Explorer: https://console.aws.amazon.com/cost-management/home#/dashboard"
echo "- GCP Billing: https://console.cloud.google.com/billing"
```

### 📊 예상 결과
- **성공률**: 95% ["자동화 스크립트 활용"]
- **소요 시간**: 15분 ["자동화로 단축"]
- **주요 개선**: 통합 테스트 자동화, 결과 리포트 자동 생성

---

## 🎯 **실습 진행 패턴 요약**

### 📋 **각 단계별 진행 패턴**
1. **🏗️ 아키텍처 그림**: 현재 상태와 목표 상태를 Mermaid 다이어그램으로 시각화
2. **🔍 명령 실행**: 자동화 스크립트 또는 수동 명령어 실행
3. **✅ 예상 결과**: 명령 실행 후 예상되는 결과 명시
4. **🌐 콘솔에서 확인**: AWS/GCP 콘솔에서 리소스 상태 확인
5. **🌐 브라우저로 서비스 접근**: 실제 서비스에 접근하여 동작 확인

### 🚀 **실습 진행 순서**
1. **1교시**: 로드밸런싱 구축 [AWS ALB + GCP LB]
2. **2교시**: 모니터링 스택 구축 [Prometheus + Grafana]
3. **3교시**: 비용 최적화 분석 [Cost Analysis]
4. **4교시**: 자동 스케일링 설정 [Auto Scaling + MIG]
5. **5교시**: 통합 테스트 및 최종 정리

### 🎯 **핵심 학습 포인트**
- **아키텍처 이해**: 각 단계별 시스템 구조 변화 시각화
- **실습 중심**: 90% 실습, 10% 이론
- **단계별 검증**: 각 단계마다 결과 확인 및 검증
- **멀티 클라우드**: AWS와 GCP 동시 활용
- **자동화**: 스크립트를 통한 효율적 실습

### 🏗️ 최종 시스템 아키텍처

#### 4단계: 통합 테스트 및 비용 최적화 완료 후
```mermaid
flowchart TB
    subgraph "AWS Cloud"
        A1[EC2 Instances<br/>Auto Scaling Group]
        A2[Application Load Balancer<br/>High Availability]
        A3[Target Groups<br/>Health Checks]
        A4[Security Groups<br/>Network Security]
        A5[VPC<br/>Network Isolation]
        A6[Cost Optimization<br/>Resource Management]
    end
    
    subgraph "GCP Cloud"
        G1[VM Instances<br/>Managed Instance Group]
        G2[HTTP[S] Load Balancer<br/>Global Load Balancing]
        G3[Backend Services<br/>Health Checks]
        G4[Firewall Rules<br/>Network Security]
        G5[VPC Network<br/>Network Isolation]
        G6[Cost Optimization<br/>Resource Management]
    end
    
    subgraph "Local Environment"
        L1[Prometheus<br/>Metrics Collection]
        L2[Grafana<br/>Visualization Dashboard]
        L3[Node Exporter<br/>System Metrics]
        L4[Docker Compose<br/>Monitoring Stack]
        L5[Cost Analysis Tools<br/>Optimization Scripts]
    end
    
    subgraph "Developer Machine"
        D1[CLI Tools<br/>AWS CLI, GCP CLI]
        D2[Automation Scripts<br/>Day3 Practice Scripts]
        D3[Monitoring Access<br/>Grafana, Prometheus]
    end
    
    D1 -->> A2
    D1 -->> G2
    D2 -->> A1
    D2 -->> G1
    D3 -->> L2
    D3 -->> L1
    
    A2 -->> A3
    A3 -->> A1
    A1 -->> A4
    A4 -->> A5
    
    G2 -->> G3
    G3 -->> G1
    G1 -->> G4
    G4 -->> G5
    
    L1 -->> A1
    L1 -->> G1
    L3 -->> A1
    L3 -->> G1
    L2 -->> L1
    L4 -->> L1
    L4 -->> L2
    L4 -->> L3
    
    L5 -->> A6
    L5 -->> G6
    D2 -->> L5
```

**최종 적용된 기능:**
- ✅ **멀티 클라우드 로드밸런싱**: AWS ALB + GCP Cloud LB
- ✅ **자동 스케일링**: CPU 기반 동적 리소스 조정
- ✅ **통합 모니터링**: Prometheus + Grafana + Node Exporter
- ✅ **비용 최적화**: 자동화된 비용 분석 및 리포트
- ✅ **고가용성**: 다중 AZ/Region 분산 배포
- ✅ **자동화**: 전체 시스템 자동 구축 및 관리

#### 📊 최종 시스템 장단점 분석

**✅ 장점:**
- **프로덕션 수준 아키텍처**: 실제 서비스에 바로 적용 가능한 고급 구조
- **멀티 클라우드 전략**: 벤더 종속성 제거 및 리스크 분산
- **완전 자동화**: 수동 개입 최소화로 운영 효율성 극대화
- **비용 최적화**: 자동 스케일링과 비용 분석으로 최적 비용 달성
- **고가용성**: 다중 장애점으로 서비스 중단 위험 최소화
- **확장성**: 트래픽 증가에 자동 대응하는 무제한 확장 가능
- **모니터링**: 실시간 시스템 상태 파악으로 문제 조기 발견

**❌ 단점:**
- **높은 복잡성**: 다수의 컴포넌트와 설정으로 관리 복잡도 증가
- **비용 증가**: 멀티 클라우드와 고급 기능으로 인한 비용 상승
- **학습 곡선**: 운영팀의 높은 수준의 기술 역량 필요
- **의존성 증가**: 각 컴포넌트 간 의존성으로 장애 전파 위험
- **디버깅 어려움**: 문제 발생 시 여러 시스템을 동시에 확인해야 함
- **설정 관리**: 복잡한 설정 파일과 정책 관리 부담
- **초기 투자**: 시스템 구축과 학습을 위한 높은 초기 비용

#### 🎯 권장 사용 시나리오

**✅ 적합한 경우:**
- 대규모 트래픽을 처리해야 하는 프로덕션 서비스
- 24/7 고가용성이 필요한 비즈니스 크리티컬 애플리케이션
- 멀티 클라우드 전략을 추구하는 기업
- 비용 최적화가 중요한 장기 운영 서비스
- DevOps 팀의 높은 기술 역량을 보유한 조직

**❌ 부적합한 경우:**
- 소규모 프로토타입이나 MVP 단계의 서비스
- 예측 가능한 트래픽 패턴의 단순한 애플리케이션
- 제한된 예산과 리소스를 가진 스타트업
- 단일 클라우드 벤더에 특화된 서비스
- 간단한 정적 웹사이트나 개인 프로젝트

---

## 🎯 3일차 수업 성과

### ✅ 달성한 학습 목표
- [x] 기존 VM을 활용한 AWS ALB 구축
- [x] Prometheus + Grafana 통합 모니터링 시스템
- [x] 자동화 스크립트를 통한 효율적 실습
- [x] AWS Auto Scaling + GCP Managed Instance Group
- [x] 클라우드 비용 최적화 분석 및 리포트 생성
- [x] 고가용성 아키텍처 설계 및 구현

### 🔍 주요 학습 포인트
1. **기존 VM 활용**: Day1, Day2 VM을 활용한 비용 효율적 실습
2. **자동화 도구**: 스크립트를 통한 효율적 실습 환경 구축
3. **로드밸런싱**: 트래픽 분산과 고가용성 확보
4. **모니터링**: 실시간 시스템 상태 파악 및 시각화
5. **자동 스케일링**: 수요에 따른 자동 리소스 조정
6. **비용 최적화**: 효율적인 클라우드 리소스 활용

### 🚀 실습 결과물
- **로드밸런서**: AWS ALB ["기존 VM 활용"]
- **모니터링**: Prometheus + Grafana + Node Exporter
- **자동 스케일링**: AWS Auto Scaling + GCP MIG
- **비용 최적화**: 자동화된 비용 분석 및 리포트
- **자동화 스크립트**: 효율적인 실습 환경 구축

### 🔄 시스템 변화 요약

#### 단계별 아키텍처 진화
1. **초기 상태**: 단일 VM ["Day1, Day2 완료"]
2. **1단계**: 로드밸런싱 구축 [ALB + Target Group]
3. **2단계**: 모니터링 추가 [Prometheus + Grafana]
4. **3단계**: 자동 스케일링 [Auto Scaling Group + MIG]
5. **4단계**: 비용 최적화 [Cost Analysis + Optimization]

#### 핵심 변화 포인트
- **정적 → 동적**: 고정 리소스에서 자동 스케일링으로
- **단일 → 분산**: 하나의 VM에서 로드밸런싱된 다중 인스턴스로
- **수동 → 자동**: 수동 관리에서 자동화된 운영으로
- **단일 클라우드 → 멀티 클라우드**: AWS와 GCP 동시 활용
- **기본 → 고급**: 단순 배포에서 프로덕션 수준 아키텍처로

#### 📈 단계별 장단점 진화

**1단계 ["로드밸런싱"]**
- ✅ 고가용성 확보, ❌ 복잡성 증가

**2단계 ["모니터링"]**
- ✅ 실시간 상태 파악, ❌ 리소스 사용량 증가

**3단계 ["자동 스케일링"]**
- ✅ 비용 최적화, ❌ 비용 예측 어려움

**4단계 ["통합 시스템"]**
- ✅ 프로덕션 수준, ❌ 높은 복잡성

#### 🎯 아키텍처 선택 가이드

**소규모 프로젝트**: Day1, Day2 수준 ["단일 VM + CI/CD"]
**중간 규모 서비스**: Day3 1-2단계 ["로드밸런싱 + 모니터링"]
**대규모 프로덕션**: Day3 전체 ["완전 자동화 + 멀티 클라우드"]

### 📈 Cloud Master 과정 완성
- **Day1**: 기본 환경 구축 및 CI/CD 파이프라인
- **Day2**: 다중 서비스 환경 및 고급 CI/CD
- **Day3**: 로드밸런싱, 모니터링, 비용 최적화
- **최종 결과**: 프로덕션 수준의 클라우드 네이티브 애플리케이션

---

**강의안 작성일**: 2024년 9월 24일  
**예상 소요 시간**: 6시간 ["9:00~17:00, 자동화로 단축"]  
**실습 중심**: 90% 실습, 10% 이론  
**자동화 활용**: 95% 자동화 스크립트 사용 권장  
**과정 완료**: Cloud Master 과정 전체 완성

---

## 🛠️ 자동화 스크립트 사용 가이드

### 📋 **실습 전 준비사항**
```bash
# 1. 스크립트 실행 권한 부여
chmod +x cloud_master/automation/day3/*.sh

# 2. 환경 변수 확인
echo "AWS CLI 설정 확인:"
aws sts get-caller-identity

echo "GCP CLI 설정 확인:"
gcloud auth list

# 3. 기존 VM 확인
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0]]' --output table

# 4. 실습 후 확인 가능한 URL들
echo "🌐 실습 완료 후 확인 가능한 URL들:"
echo ""
echo "📊 모니터링 시스템:"
echo "- Grafana: http://localhost:3001 [admin/admin]"
echo "- Prometheus: http://localhost:9090"
echo "- Node Exporter: http://localhost:9100"
echo ""
echo "☁️ AWS 콘솔:"
echo "- EC2: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:"
echo "- Load Balancer: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:"
echo "- Auto Scaling: https://console.aws.amazon.com/ec2autoscaling/home?region=us-east-1#/groups"
echo ""
echo "☁️ GCP 콘솔:"
echo "- Compute Engine: https://console.cloud.google.com/compute/instances"
echo "- Load Balancing: https://console.cloud.google.com/net-services/loadbalancing"
echo "- Monitoring: https://console.cloud.google.com/monitoring"
```

### 🚀 **권장 실습 순서**

#### 📋 **자동화 스크립트 명명 규칙**
```
01-aws-loadbalancing.sh     # AWS 로드밸런싱 구축
02-gcp-loadbalancing.sh     # GCP 로드밸런싱 구축  
03-monitoring-stack.sh      # 모니터링 스택 구축
04-autoscaling.sh           # 자동 스케일링 설정
05-cost-optimization.sh     # 비용 최적화 분석
06-integration-test.sh      # 통합 테스트 실행
```

#### 🔢 **실습 순서**
```bash
# 1. AWS 로드밸런싱 구축 ["권장"]
cloud_master/scripts/aws-loadbalancing-improved.sh setup

# 2. GCP 로드밸런싱 구축
cloud_master/scripts/cloud-master-helper.sh

# 3. 모니터링 스택 구축
cloud_master/automation/day3/03-monitoring-stack.sh setup

# 4. 자동 스케일링 설정
cloud_master/automation/day3/04-autoscaling.sh setup

# 5. 비용 최적화 분석
cloud_master/automation/day3/05-cost-optimization.sh analyze

# 6. 통합 테스트
cloud_master/automation/day3/06-integration-test.sh setup

# 각 스크립트 실행 후 확인 가능한 URL들
echo "🌐 실습 완료 후 확인 URL들:"
echo ""
echo "📊 모니터링 시스템:"
echo "- Grafana: http://localhost:3001 [admin/admin]"
echo "- Prometheus: http://localhost:9090"
echo "- Node Exporter: http://localhost:9100"
echo ""
echo "☁️ AWS 리소스:"
echo "- EC2 콘솔: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:"
echo "- Load Balancer: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:"
echo "- Auto Scaling: https://console.aws.amazon.com/ec2autoscaling/home?region=us-east-1#/groups"
echo "- CloudWatch: https://console.aws.amazon.com/cloudwatch/home?region=us-east-1"
echo ""
echo "☁️ GCP 리소스:"
echo "- Compute Engine: https://console.cloud.google.com/compute/instances"
echo "- Load Balancing: https://console.cloud.google.com/net-services/loadbalancing"
echo "- Instance Groups: https://console.cloud.google.com/compute/instanceGroups"
echo "- Monitoring: https://console.cloud.google.com/monitoring"
echo ""
echo "💰 비용 관리:"
echo "- AWS Cost Explorer: https://console.aws.amazon.com/cost-management/home#/dashboard"
echo "- GCP Billing: https://console.cloud.google.com/billing"
```

### ⚠️ **주의사항**
- 자동화 스크립트 사용을 **강력히 권장**합니다
- 수동 설정은 참고용으로만 사용하세요
- 실습 전 반드시 기존 VM 상태를 확인하세요
- 문제 발생 시 스크립트의 `cleanup` 옵션을 사용하세요

### 🔧 **스크립트 옵션 사용법**

#### **01-aws-loadbalancing.sh**
```bash
01-aws-loadbalancing.sh ["옵션"]

옵션:
  setup      전체 실습 환경 설정 ["기본값"]
  test       시스템 테스트
  status     시스템 상태 확인
  cleanup    전체 리소스 정리
  help       도움말 표시

특징:
  - 기존 AWS cloud-deployment-server VM 활용
  - AWS ALB 로드밸런서 설정
  - 통합 모니터링 설정
  - 비용 최적화 분석
```

#### **02-gcp-loadbalancing.sh**
```bash
02-gcp-loadbalancing.sh [setup|cleanup|test]

옵션:
  setup   - GCP Load Balancing 설정 ["기본값"]
  cleanup - 리소스 정리
  test    - 시스템 테스트

특징:
  - GCP Cloud Load Balancing 설정
  - Instance Group 자동 구성
  - Health Check 자동 설정
  - 멀티 클라우드 지원
```

#### **03-monitoring-stack.sh**
```bash
03-monitoring-stack.sh ["옵션"]

옵션:
  setup     모니터링 스택 설정 ["기본값"]
  start     모니터링 스택 시작
  test      모니터링 테스트
  stop      모니터링 스택 중지
  cleanup   리소스 정리
  help      도움말 표시

접속 URL:
  Prometheus: http://localhost:9090
  Grafana: http://localhost:3001 [admin/admin]
  Jaeger: http://localhost:16686
  Elasticsearch: http://localhost:9200
  Kibana: http://localhost:5601
  Test App: http://localhost:3000
```

#### **04-autoscaling.sh**
```bash
04-autoscaling.sh [setup|cleanup|test]

옵션:
  setup   - 자동 스케일링 설정 ["기본값"]
  cleanup - 리소스 정리
  test    - 스케일링 테스트

특징:
  - AWS Auto Scaling Group 설정
  - GCP Managed Instance Group 설정
  - CPU 기반 스케일링 정책
  - Launch Template 자동 생성
```

#### **05-cost-optimization.sh**
```bash
05-cost-optimization.sh [analyze|optimize|monitor|report|cleanup]

옵션:
  analyze  - 비용 분석 실행 ["기본값"]
  optimize - 비용 최적화 실행
  monitor  - 비용 모니터링 설정
  report   - 리포트 생성
  cleanup  - 리소스 정리

특징:
  - AWS/GCP 비용 분석
  - 사용하지 않는 리소스 검색
  - 비용 최적화 권장사항
  - 상세 리포트 생성
```

#### **06-integration-test.sh**
```bash
06-integration-test.sh [setup|cleanup|test]

옵션:
  setup   - 통합 테스트 실행 ["기본값"]
  cleanup - 전체 리소스 정리
  test    - 시스템 통합 테스트

특징:
  - 전체 시스템 상태 확인
  - 로드밸런서 헬스체크
  - 모니터링 시스템 검증
  - 성능 테스트 자동 실행
```

#### **create-git-repo.sh ["WSL용"]**
```bash
create-git-repo.sh

기능:
  - Git Repository 자동 생성
  - GitHub Repository 생성 및 연결
  - 실습 스크립트 자동 복사
  - .gitignore 및 README.md 생성

사용법:
  # WSL에서 실행
  cd /mnt/c/Users/["사용자명"]/mcp_cloud/cloud_master/automation/day3
  create-git-repo.sh
```

#### **vm-setup.sh ["Cloud VM용"]**
```bash
vm-setup.sh

기능:
  - VM 환경 자동 설정
  - Docker, AWS CLI, GCP CLI 설치
  - 실습 코드 자동 Clone
  - 작업 공간 및 환경 변수 설정

사용법:
  # Cloud VM에서 실행
  curl -O https://raw.githubusercontent.com/["사용자명"]/cloud-master-day3-practice/main/vm-setup.sh
  chmod +x vm-setup.sh
  vm-setup.sh
```

#### **environment-check.sh ["환경 진단용"]**
```bash
environment-check.sh

기능:
  - 시스템 사전 요구사항 자동 확인
  - Docker, AWS CLI, GCP CLI 상태 검증
  - 포트 사용 현황 및 충돌 확인
  - 메모리, 디스크 공간 확인
  - 실습 스크립트 존재 여부 확인

사용법:
  # WSL 또는 Cloud VM에서 실행
  cd /path/to/day3/scripts
  environment-check.sh
```

### 🚀 **실습 순서별 스크립트 사용법**

#### **WSL에서 ["개발 환경"]**
```bash
# 1단계: Git Repository 생성
cd /mnt/c/Users/["사용자명"]/mcp_cloud/cloud_master/day3/automation
create-git-repo.sh

# 2단계: 코드 수정 및 동기화
# ["필요시 스크립트 수정"]
git add .
git commit -m "Update scripts"
git push origin main
```

#### **Cloud VM에서 ["실습 환경"]**
```bash
# 1단계: VM 환경 설정
curl -O https://raw.githubusercontent.com/["사용자명"]/cloud-master-day3-practice/main/vm-setup.sh
chmod +x vm-setup.sh
vm-setup.sh

# 2단계: AWS 로드밸런싱
01-aws-loadbalancing.sh setup
01-aws-loadbalancing.sh status

# 3단계: GCP 로드밸런싱
02-gcp-loadbalancing.sh setup
02-gcp-loadbalancing.sh test

# 4단계: 모니터링 스택
03-monitoring-stack.sh setup
03-monitoring-stack.sh start

# 5단계: 자동 스케일링
04-autoscaling.sh setup
04-autoscaling.sh test

# 6단계: 비용 최적화
05-cost-optimization.sh analyze
05-cost-optimization.sh report

# 7단계: 통합 테스트
06-integration-test.sh setup
06-integration-test.sh test
```

#### **WSL에서 ["결과 분석"]**
```bash
# 1단계: 결과 파일 동기화
scp -i ~/.ssh/cloud-master-key.pem ubuntu@[VM_IP]:~/cloud-master-workspace/results/* ./

# 2단계: 분석 및 문서화
# ["결과 파일 분석 및 정리"]
```
