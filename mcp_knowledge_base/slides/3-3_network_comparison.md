# 3-3. 네트워크 서비스 비교 (VPC)

## 학습 목표
- AWS VPC와 GCP VPC의 핵심 차이점 이해
- 네트워크 아키텍처 설계 패턴 비교
- 보안 그룹, 방화벽, 라우팅 정책 분석
- 하이브리드 클라우드 연결 방식 비교
- 네트워크 성능 및 비용 최적화 전략 학습

---

## VPC 서비스 개요

### AWS VPC vs GCP VPC

#### 1. 기본 특징 비교
| 특징 | AWS VPC | GCP VPC |
|------|---------|---------|
| **서비스 출시** | 2009년 | 2010년 |
| **CIDR 블록** | /16 ~ /28 | /8 ~ /29 |
| **서브넷 모드** | 수동 구성 | 자동/수동 |
| **가용영역** | 3개/리전 | 3개/리전 |
| **라우팅 테이블** | 서브넷별 | VPC 전체 |
| **NACL** | 지원 | 미지원 |

#### 2. 네트워크 아키텍처
```
AWS VPC:
├── VPC (10.0.0.0/16)
├── 가용영역 A
│   ├── 퍼블릭 서브넷 (10.0.1.0/24)
│   └── 프라이빗 서브넷 (10.0.2.0/24)
└── 가용영역 B
    ├── 퍼블릭 서브넷 (10.0.3.0/24)
    └── 프라이빗 서브넷 (10.0.4.0/24)

GCP VPC:
├── VPC (10.0.0.0/16)
├── 리전별 서브넷
│   ├── asia-northeast3 (10.0.1.0/24)
│   └── us-central1 (10.0.2.0/24)
└── 글로벌 라우팅
```

---

## AWS VPC 상세 분석

### AWS VPC 구성 요소

#### 1. VPC 및 서브넷
```bash
# VPC 생성
aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=BootcampVPC}]'

# 서브넷 생성
aws ec2 create-subnet \
    --vpc-id vpc-12345678 \
    --cidr-block 10.0.1.0/24 \
    --availability-zone ap-northeast-2a

# 인터넷 게이트웨이 연결
aws ec2 create-internet-gateway
aws ec2 attach-internet-gateway \
    --vpc-id vpc-12345678 \
    --internet-gateway-id igw-12345678
```

#### 2. 라우팅 테이블
```bash
# 라우팅 테이블 생성
aws ec2 create-route-table --vpc-id vpc-12345678

# 인터넷 라우트 추가
aws ec2 create-route \
    --route-table-id rtb-12345678 \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id igw-12345678

# 서브넷 연결
aws ec2 associate-route-table \
    --subnet-id subnet-12345678 \
    --route-table-id rtb-12345678
```

---

## GCP VPC 상세 분석

### GCP VPC 구성 요소

#### 1. VPC 및 서브넷
```bash
# VPC 생성
gcloud compute networks create bootcamp-vpc \
    --subnet-mode=custom \
    --bgp-routing-mode=regional

# 서브넷 생성
gcloud compute networks subnets create subnet-asia-northeast3 \
    --network=bootcamp-vpc \
    --region=asia-northeast3 \
    --range=10.0.1.0/24

# 방화벽 규칙 생성
gcloud compute firewall-rules create allow-ssh \
    --network=bootcamp-vpc \
    --allow=tcp:22 \
    --source-ranges=0.0.0.0/0
```

#### 2. 방화벽 규칙
```bash
# HTTP 허용
gcloud compute firewall-rules create allow-http \
    --network=bootcamp-vpc \
    --allow=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server

# 내부 통신 허용
gcloud compute firewall-rules create allow-internal \
    --network=bootcamp-vpc \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/16
```

---

## 네트워크 보안 비교

### AWS VPC 보안

#### 1. 보안 그룹 (Security Groups)
```bash
# 보안 그룹 생성
aws ec2 create-security-group \
    --group-name web-sg \
    --description "Web server security group" \
    --vpc-id vpc-12345678

# SSH 허용 규칙
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

# HTTP 허용 규칙
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0
```

#### 2. 네트워크 ACL (NACL)
```bash
# NACL 생성
aws ec2 create-network-acl --vpc-id vpc-12345678

# 인바운드 규칙 (SSH)
aws ec2 create-network-acl-entry \
    --network-acl-id acl-12345678 \
    --ingress \
    --rule-number 100 \
    --protocol tcp \
    --port-range From=22,To=22 \
    --cidr-block 0.0.0.0/0 \
    --rule-action allow

# 아웃바운드 규칙
aws ec2 create-network-acl-entry \
    --network-acl-id acl-12345678 \
    --egress \
    --rule-number 100 \
    --protocol -1 \
    --cidr-block 0.0.0.0/0 \
    --rule-action allow
```

---

## GCP VPC 보안

### GCP 방화벽 규칙

#### 1. 기본 방화벽 규칙
```bash
# 기본 SSH 규칙
gcloud compute firewall-rules create default-allow-ssh \
    --network=default \
    --allow=tcp:22 \
    --source-ranges=0.0.0.0/0

# 기본 HTTP 규칙
gcloud compute firewall-rules create default-allow-http \
    --network=default \
    --allow=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server

# 기본 HTTPS 규칙
gcloud compute firewall-rules create default-allow-https \
    --network=default \
    --allow=tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=https-server
```

#### 2. 커스텀 방화벽 규칙
```bash
# 특정 IP에서만 접근 허용
gcloud compute firewall-rules create restricted-ssh \
    --network=bootcamp-vpc \
    --allow=tcp:22 \
    --source-ranges=203.0.113.0/24

# 특정 태그가 있는 인스턴스만 대상
gcloud compute firewall-rules create app-server-access \
    --network=bootcamp-vpc \
    --allow=tcp:8080 \
    --source-tags=web-server \
    --target-tags=app-server
```

---

## 라우팅 및 연결 비교

### AWS VPC 라우팅

#### 1. 라우팅 테이블 구성
```bash
# 메인 라우팅 테이블
aws ec2 describe-route-tables \
    --filters "Name=vpc-id,Values=vpc-12345678"

# 커스텀 라우팅 테이블 생성
aws ec2 create-route-table --vpc-id vpc-12345678

# NAT 게이트웨이 라우트
aws ec2 create-route \
    --route-table-id rtb-12345678 \
    --destination-cidr-block 0.0.0.0/0 \
    --nat-gateway-id nat-12345678
```

#### 2. NAT 게이트웨이
```bash
# NAT 게이트웨이 생성
aws ec2 create-nat-gateway \
    --subnet-id subnet-12345678 \
    --allocation-id eipalloc-12345678

# Elastic IP 할당
aws ec2 allocate-address --domain vpc
```

---

## GCP VPC 라우팅

### GCP 라우팅 구성

#### 1. 자동 라우팅
```bash
# VPC 생성 시 라우팅 모드 설정
gcloud compute networks create bootcamp-vpc \
    --subnet-mode=custom \
    --bgp-routing-mode=regional

# 커스텀 라우팅 테이블
gcloud compute routes create internet-route \
    --network=bootcamp-vpc \
    --destination-range=0.0.0.0/0 \
    --next-hop-gateway=default-internet-gateway
```

#### 2. Cloud NAT
```bash
# Cloud NAT 생성
gcloud compute routers create nat-router \
    --network=bootcamp-vpc \
    --region=asia-northeast3

gcloud compute routers nats create nat-config \
    --router=nat-router \
    --region=asia-northeast3 \
    --nat-all-subnet-ip-ranges \
    --source-subnetwork-ip-ranges-to-nat=ALL_SUBNETWORKS_ALL_IP_RANGES
```

---

## 하이브리드 클라우드 연결

### AWS VPN 연결

#### 1. VPN Gateway
```bash
# VPN Gateway 생성
aws ec2 create-vpn-gateway \
    --type ipsec.1 \
    --tag-specifications 'ResourceType=vpn-gateway,Tags=[{Key=Name,Value=BootcampVPN}]'

# VPN Gateway를 VPC에 연결
aws ec2 attach-vpn-gateway \
    --vpc-id vpc-12345678 \
    --vpn-gateway-id vgw-12345678

# Customer Gateway 생성
aws ec2 create-customer-gateway \
    --bgp-asn 65000 \
    --public-ip 203.0.113.1 \
    --type ipsec.1
```

#### 2. VPN 연결
```bash
# VPN 연결 생성
aws ec2 create-vpn-connection \
    --customer-gateway-id cgw-12345678 \
    --vpn-gateway-id vgw-12345678 \
    --type ipsec.1 \
    --options '{"StaticRoutesOnly":true}'
```

---

## GCP VPN 연결

### GCP Cloud VPN

#### 1. VPN Gateway
```bash
# VPN Gateway 생성
gcloud compute vpn-gateways create bootcamp-vpn-gateway \
    --network=bootcamp-vpc \
    --region=asia-northeast3

# 외부 IP 주소 예약
gcloud compute addresses create vpn-ip \
    --region=asia-northeast3
```

#### 2. VPN 터널
```bash
# VPN 터널 생성
gcloud compute vpn-tunnels create bootcamp-tunnel \
    --peer-address=203.0.113.1 \
    --shared-secret=SECRET_KEY \
    --local-traffic-selector=10.0.0.0/16 \
    --remote-traffic-selector=192.168.0.0/16 \
    --vpn-gateway=bootcamp-vpn-gateway \
    --region=asia-northeast3
```

---

## 네트워크 성능 비교

### 대역폭 및 지연시간

#### 1. AWS VPC 성능
```
인스턴스 타입별 대역폭:
├── t3.micro: 최대 5 Gbps
├── c5.large: 최대 10 Gbps
├── m5.2xlarge: 최대 10 Gbps
└── c5.9xlarge: 최대 25 Gbps

VPC 엔드포인트:
├── S3: 프라이빗 네트워크 접근
├── DynamoDB: 프라이빗 네트워크 접근
└── 기타 AWS 서비스: 프라이빗 네트워크 접근
```

#### 2. GCP VPC 성능
```
인스턴스 타입별 대역폭:
├── e2-micro: 최대 1 Gbps
├── e2-standard-2: 최대 10 Gbps
├── n2-standard-4: 최대 10 Gbps
└── c2-standard-8: 최대 32 Gbps

VPC Service Controls:
├── 서비스 간 통신 제어
├── 데이터 유출 방지
└── 네트워크 격리 강화
```

---

## 비용 구조 비교

### AWS VPC 비용

#### 1. 기본 비용
```
VPC: 무료
서브넷: 무료
라우팅 테이블: 무료
인터넷 게이트웨이: 무료
```

#### 2. 유료 서비스
```
NAT 게이트웨이:
├── 시간당 $0.045
├── 데이터 처리: GB당 $0.045
└── Elastic IP: 사용하지 않을 때 시간당 $0.005

VPN Gateway:
├── 시간당 $0.05
└── 데이터 처리: GB당 $0.05
```

### GCP VPC 비용

#### 1. 기본 비용
```
VPC: 무료
서브넷: 무료
방화벽 규칙: 무료
라우팅: 무료
```

#### 2. 유료 서비스
```
Cloud NAT:
├── 시간당 $0.045
└── 데이터 처리: GB당 $0.045

Cloud VPN:
├── 시간당 $0.05
└── 데이터 처리: GB당 $0.05
```

---

## 모범 사례 및 권장사항

### AWS VPC 모범 사례

#### 1. 네트워크 설계
- [ ] **서브넷 분리**: 퍼블릭/프라이빗 서브넷 분리
- [ ] **가용영역 분산**: 고가용성을 위한 다중 AZ 구성
- [ ] **CIDR 블록 계획**: 확장성을 고려한 IP 주소 할당
- [ ] **라우팅 최적화**: 불필요한 홉 최소화

#### 2. 보안 강화
- [ ] **보안 그룹**: 최소 권한 원칙 적용
- [ ] **NACL**: 서브넷 레벨 방화벽 설정
- [ ] **VPC 엔드포인트**: 프라이빗 네트워크 접근
- [ ] **모니터링**: VPC Flow Logs 활성화

### GCP VPC 모범 사례

#### 1. 네트워크 설계
- [ ] **서브넷 모드**: 자동 모드로 시작하여 필요시 수동 전환
- [ ] **리전별 서브넷**: 지역별 리소스 배치
- [ ] **방화벽 규칙**: 태그 기반 규칙 구성
- [ ] **라우팅**: 커스텀 라우팅으로 세밀한 제어

#### 2. 보안 강화
- [ ] **방화벽 규칙**: 소스 IP 범위 제한
- [ ] **VPC Service Controls**: 서비스 간 통신 제어
- [ ] **IAM 조건**: 네트워크 기반 액세스 제어
- [ ] **감사 로그**: 모든 네트워크 활동 기록

---

## 실제 사용 사례

### 멀티 티어 웹 애플리케이션

#### 1. AWS VPC 구성
```
인터넷
    ↓
인터넷 게이트웨이
    ↓
퍼블릭 서브넷 (10.0.1.0/24)
    ↓
Application Load Balancer
    ↓
프라이빗 서브넷 (10.0.2.0/24)
    ↓
EC2 인스턴스들
    ↓
프라이빗 서브넷 (10.0.3.0/24)
    ↓
RDS 데이터베이스
```

#### 2. GCP VPC 구성
```
인터넷
    ↓
Cloud Load Balancing
    ↓
퍼블릭 서브넷 (10.0.1.0/24)
    ↓
Compute Engine 인스턴스들
    ↓
프라이빗 서브넷 (10.0.2.0/24)
    ↓
Cloud SQL
```

---

## 실습 과제

### 기본 실습
1. **AWS VPC 및 서브넷 생성**
2. **GCP VPC 및 서브넷 생성**
3. **보안 그룹/방화벽 규칙 설정**

### 고급 실습
1. **하이브리드 클라우드 연결 구성**
2. **멀티 티어 아키텍처 구축**
3. **네트워크 모니터링 및 로깅 설정**

---

## 다음 단계
- 데이터베이스 서비스 비교 (RDS vs Cloud SQL)
- Terraform을 사용한 인프라 코드화
- CI/CD 파이프라인 구축

---

## 참고 자료
- [AWS VPC 사용자 가이드](https://docs.aws.amazon.com/vpc/latest/userguide/)
- [GCP VPC 문서](https://cloud.google.com/vpc/docs)
- [AWS VPC 가격](https://aws.amazon.com/vpc/pricing/)
- [GCP VPC 가격](https://cloud.google.com/vpc/pricing)
- [AWS VPC 모범 사례](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [GCP VPC 모범 사례](https://cloud.google.com/vpc/docs/vpc-best-practices)
