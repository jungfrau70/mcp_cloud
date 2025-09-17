<div align="center">

## 🏠 최상위 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_basic/learning-path.md)

## 📖 현재 위치
**Cloud Basic** > **2일차** > **네트워킹, 보안, 데이터베이스 실습**

## ⬅️ 이전/다음 네비게이션
[← 이전: Cloud Basic 1일차](/mcp_knowledge_base/cloud_basic/textbook/Day1/README.md) | [다음: Cloud Master 1일차 →](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md)

</div>







# Cloud Basic - 2일차: 네트워킹, 보안, 데이터베이스 이론 및 실습

<details>
<summary>📋 목차</summary>

## 📚 이론 학습
1. [🎯 학습 목표](#학습-목표)
2. [🌐 네트워킹 기초 이론](#네트워킹-기초-이론)
3. [🔒 보안 그룹 및 방화벽 이론](#보안-그룹-및-방화벽-이론)
4. [🚀 데이터베이스 서비스 기초 이론](#데이터베이스-서비스-기초-이론)
5. [🏗️ 종합 아키텍처 이론](#종합-아키텍처-이론)

## 🛠️ 실습 학습
6. [🔧 실습 환경 준비](#실습-환경-준비)
7. [🌐 네트워킹 기초 실습](#네트워킹-기초-실습)
8. [🔒 보안 그룹 및 방화벽 실습](#보안-그룹-및-방화벽-실습)
9. [🚀 데이터베이스 서비스 기초 실습](#데이터베이스-서비스-기초-실습)
10. [🏗️ 종합 실습](#종합-실습)

## 📚 참고 자료
11. [📚 문제 해결 및 참고 자료](#문제-해결-및-참고-자료)

</details>

---

## 🎯 학습 목표

### 핵심 학습 목표
- **네트워킹** VPC, 서브넷, 라우팅 기본 개념
- **보안** Security Groups, Firewall Rules 설정
- **데이터베이스** RDS, Cloud SQL 기본 사용법
- **종합 실습** 웹 애플리케이션 배포

### 실습 후 달성할 수 있는 능력
- ✅ VPC 및 서브넷 구성
- ✅ 보안 그룹 및 방화벽 규칙 설정
- ✅ RDS/Cloud SQL 데이터베이스 생성 및 관리
- ✅ 완전한 웹 애플리케이션 아키텍처 구성

### 예상 소요 시간
- **네트워킹 기초**: 90-120분
- **보안 설정**: 60-90분
- **데이터베이스**: 60-90분
- **종합 실습**: 90-120분
- **전체 과정**: 5-7시간

---

## 📚 이론 학습

### 🌐 네트워킹 기초 이론

<details>
<summary>🌐 클라우드 네트워킹 기본 개념</summary>

#### VPC (Virtual Private Cloud)란?
VPC는 클라우드에서 논리적으로 격리된 네트워크 환경을 제공하는 서비스입니다.

#### VPC 핵심 개념
- **VPC**: 논리적으로 격리된 가상 네트워크
- **서브넷 (Subnet)**: VPC 내의 IP 주소 범위
- **라우팅 테이블**: 네트워크 트래픽을 어디로 보낼지 결정
- **인터넷 게이트웨이**: VPC와 인터넷 간의 통신
- **NAT 게이트웨이**: 프라이빗 서브넷의 아웃바운드 인터넷 접근

#### AWS VPC vs GCP VPC
| 특징 | AWS VPC | GCP VPC |
|------|---------|---------|
| **CIDR 블록** | 10.0.0.0/16 | 10.0.0.0/16 |
| **서브넷** | 퍼블릭/프라이빗 | 자동 모드/커스텀 모드 |
| **라우팅** | 라우팅 테이블 | 라우트 |
| **게이트웨이** | IGW, NAT GW | 인터넷 게이트웨이, Cloud NAT |

#### 네트워크 보안
- **보안 그룹**: 인스턴스 레벨 방화벽
- **NACL**: 서브넷 레벨 방화벽
- **VPC 피어링**: VPC 간 연결
- **VPN 연결**: 온프레미스와 클라우드 연결

</details>

<details>
<summary>🔒 보안 그룹 및 방화벽 이론</summary>

#### 보안 그룹이란?
보안 그룹은 인스턴스에 대한 가상 방화벽으로, 인바운드 및 아웃바운드 트래픽을 제어합니다.

#### AWS Security Groups
- **상태 저장**: 연결 상태를 기억하는 상태 저장 방화벽
- **인바운드 규칙**: 인스턴스로 들어오는 트래픽 제어
- **아웃바운드 규칙**: 인스턴스에서 나가는 트래픽 제어
- **기본 규칙**: 모든 아웃바운드 트래픽 허용

#### GCP Firewall Rules
- **방향**: 인바운드/아웃바운드
- **작업**: 허용/거부
- **대상**: 모든 인스턴스/특정 태그
- **소스/대상**: IP 범위, 서비스 계정, 네트워크

#### 방화벽 모범 사례
- **최소 권한 원칙**: 필요한 포트만 열기
- **기본 거부**: 명시적으로 허용하지 않은 모든 트래픽 거부
- **정기적 검토**: 보안 규칙 정기적 검토 및 정리
- **로그 모니터링**: 방화벽 로그 모니터링

</details>

<details>
<summary>🚀 데이터베이스 서비스 기초 이론</summary>

#### 클라우드 데이터베이스란?
클라우드에서 제공하는 관리형 데이터베이스 서비스로, 설치, 운영, 백업 등을 클라우드 제공자가 관리합니다.

#### AWS RDS (Relational Database Service)
- **관리형 서비스**: 설치, 패치, 백업 자동화
- **엔진 지원**: MySQL, PostgreSQL, Oracle, SQL Server
- **고가용성**: Multi-AZ 배포로 가용성 확보
- **자동 백업**: 자동 백업 및 Point-in-Time 복구

#### GCP Cloud SQL
- **완전 관리형**: Google이 모든 관리 작업 수행
- **엔진 지원**: MySQL, PostgreSQL, SQL Server
- **자동 스케일링**: 워크로드에 따른 자동 확장
- **통합 모니터링**: Cloud Monitoring과 완전 통합

#### 데이터베이스 보안
- **암호화**: 전송 중 및 저장 시 암호화
- **접근 제어**: IAM을 통한 세밀한 권한 관리
- **네트워크 격리**: VPC 내에서만 접근 가능
- **정기적 패치**: 보안 패치 자동 적용

#### 데이터베이스 선택 기준
- **데이터 타입**: 관계형 vs NoSQL
- **성능 요구사항**: 읽기/쓰기 성능
- **확장성**: 수직/수평 확장
- **비용**: 라이선스 및 운영 비용

</details>

<details>
<summary>🏗️ 종합 아키텍처 이론</summary>

#### 3-Tier 아키텍처란?
웹 애플리케이션을 프레젠테이션, 비즈니스 로직, 데이터 계층으로 분리한 아키텍처입니다.

#### 3-Tier 아키텍처 구성
- **웹 계층**: 사용자 인터페이스 (웹 서버)
- **애플리케이션 계층**: 비즈니스 로직 (애플리케이션 서버)
- **데이터 계층**: 데이터 저장 (데이터베이스)

#### 클라우드 아키텍처 설계 원칙
- **가용성**: 고가용성 설계로 서비스 중단 최소화
- **확장성**: 트래픽 증가에 대응할 수 있는 확장성
- **보안**: 다층 보안으로 데이터 보호
- **비용 효율성**: 필요한 만큼만 사용하는 비용 최적화

#### AWS 아키텍처 예시
- **웹 계층**: EC2 + ALB
- **애플리케이션 계층**: EC2 + Auto Scaling
- **데이터 계층**: RDS Multi-AZ
- **스토리지**: S3
- **CDN**: CloudFront

#### GCP 아키텍처 예시
- **웹 계층**: Compute Engine + Load Balancer
- **애플리케이션 계층**: Compute Engine + Managed Instance Group
- **데이터 계층**: Cloud SQL
- **스토리지**: Cloud Storage
- **CDN**: Cloud CDN

</details>

---

## 🛠️ 실습 학습

## 📚 실습 가이드

<details>
<summary>📖 실습 가이드 개요</summary>

### 실습 구성
1. **네트워킹 기초** (120분)
2. **보안 그룹 및 방화벽** (90분)
3. **데이터베이스 서비스 기초** (90분)
4. **종합 실습** (120분)

### 실습 방식
- **네트워킹**: VPC, 서브넷, 라우팅 테이블 구성
- **보안**: Security Groups, NACL, Firewall Rules
- **데이터베이스**: RDS, Cloud SQL 인스턴스 생성
- **종합**: 웹 애플리케이션 전체 아키텍처

### 실습 결과물
- VPC 및 서브넷 구성
- 보안 그룹 및 방화벽 규칙 설정
- RDS/Cloud SQL 데이터베이스 구성
- 완전한 웹 애플리케이션 배포

</details>

<details>
<summary>🔗 관련 실습 가이드</summary>

### 📖 상세 실습 가이드
- 🔗 [종합 실습 프로젝트](/mcp_knowledge_base/cloud_basic/textbook/Day2/practice/basic-to-master-bridge.md)

### 🔗 관련 과정 링크
- 🔗 [Cloud Master 과정](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md) - Docker, CI/CD 심화 과정
- 🔗 [Cloud Container 과정](/mcp_knowledge_base/cloud_container/textbook/Day1/README.md) - Kubernetes 고급 과정
- 🔗 [전체 커리큘럼](/mcp_knowledge_base/curriculum.md) - 전체 과정 구조 및 학습 경로
- 🔗 [통합 인덱스](/mcp_knowledge_base/index.md) - 전체 과정 인덱스
- 🔗 [학습 경로로 돌아가기](/mcp_knowledge_base/learning-path.md) - Cloud Basic 학습 경로

---

## 🔧 실습 환경 준비

<details>
<summary>📋 필수 계정 및 도구</summary>

### 필수 계정
- **AWS 계정**: Free Tier 계정 (1일차에서 생성)
- **GCP 계정**: $300 크레딧 계정 (1일차에서 생성)
- **GitHub 계정**: 코드 저장소 (선택사항)

### 필수 도구
- **AWS CLI**: 1일차에서 설치 완료
- **gcloud CLI**: 1일차에서 설치 완료
- **웹 브라우저**: Chrome, Firefox, Safari 등
- **SSH 클라이언트**: 가상머신 접속용

</details>

<details>
<summary>🔧 1일차 실습 완료 확인</summary>

### 필수 완료 사항
- [ ] AWS Free Tier 계정 생성 및 설정
- [ ] GCP $300 크레딧 계정 생성 및 설정
- [ ] AWS CLI 및 gcloud CLI 설치 및 인증
- [ ] IAM 사용자/서비스 계정 생성
- [ ] EC2/Compute Engine 인스턴스 생성 경험
- [ ] S3/Cloud Storage 버킷 생성 경험

### 실습 환경 확인
```bash
# AWS CLI 설정 확인
aws sts get-caller-identity

# gcloud 설정 확인
gcloud auth list

# AWS 리전 설정 확인
aws configure get region

# GCP 프로젝트 설정 확인
gcloud config get-value project
```

</details>

---

## 🌐 네트워킹 기초

### 📚 이론: 클라우드 네트워킹 원리

#### 네트워킹의 기본 개념
- **OSI 7계층 모델**: 물리계층부터 애플리케이션 계층까지의 네트워크 구조
- **TCP/IP 프로토콜**: 인터넷의 기본 통신 프로토콜 스택
- **IP 주소**: 네트워크상의 장치를 식별하는 고유 주소
- **포트**: 애플리케이션을 식별하는 논리적 주소

#### 가상화된 네트워킹의 필요성
- **멀티 테넌시**: 여러 고객의 격리된 네트워크 환경 제공
- **확장성**: 필요에 따라 네트워크 리소스 동적 할당
- **보안**: 네트워크 레벨에서의 격리 및 보안 정책 적용
- **유연성**: 다양한 네트워크 토폴로지 구성 가능

#### VPC의 핵심 구성요소
- **서브넷**: IP 주소 범위를 나눈 논리적 네트워크 세그먼트
- **라우팅 테이블**: 네트워크 트래픽의 경로를 결정하는 규칙
- **게이트웨이**: VPC와 외부 네트워크 간의 연결점
- **보안 그룹/방화벽**: 네트워크 트래픽을 제어하는 보안 규칙

<details>
<summary>📖 네트워킹 개념 이해</summary>

### VPC (Virtual Private Cloud)
- **정의**: 가상 사설 클라우드 네트워크
- **특징**: 격리된 네트워크 환경, 사용자 정의 IP 범위
- **구성 요소**: 서브넷, 라우팅 테이블, 인터넷 게이트웨이

### AWS VPC vs GCP VPC
| 구분 | AWS VPC | GCP VPC |
|------|---------|---------|
| **IP 범위** | CIDR 블록 (10.0.0.0/16) | CIDR 블록 (10.0.0.0/16) |
| **서브넷** | Public/Private 서브넷 | Regional 서브넷 |
| **라우팅** | 라우팅 테이블 | 라우팅 테이블 |
| **게이트웨이** | Internet Gateway | Internet Gateway |

</details>

<details>
<summary>🔗 AWS VPC 실습</summary>

### VPC 생성
```bash
# VPC 생성
aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=my-vpc}]'

# VPC ID 확인
VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=tag:Name,Values=my-vpc" \
    --query 'Vpcs[0].VpcId' \
    --output text)

echo "VPC ID: $VPC_ID"
```

### 서브넷 생성
```bash
# Public 서브넷 생성
aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.1.0/24 \
    --availability-zone ap-northeast-2a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=public-subnet-1}]'

# Private 서브넷 생성
aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.2.0/24 \
    --availability-zone ap-northeast-2b \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=private-subnet-1}]'
```

### 인터넷 게이트웨이 설정
```bash
# 인터넷 게이트웨이 생성
aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=my-igw}]'

# VPC에 인터넷 게이트웨이 연결
aws ec2 attach-internet-gateway \
    --vpc-id $VPC_ID \
    --internet-gateway-id $IGW_ID
```

</details>

<details>
<summary>🔗 GCP VPC 실습</summary>

### VPC 네트워크 생성
```bash
# VPC 네트워크 생성
gcloud compute networks create my-vpc \
    --subnet-mode custom \
    --bgp-routing-mode regional

# 서브넷 생성
gcloud compute networks subnets create public-subnet \
    --network my-vpc \
    --range 10.0.1.0/24 \
    --region asia-northeast3

gcloud compute networks subnets create private-subnet \
    --network my-vpc \
    --range 10.0.2.0/24 \
    --region asia-northeast3
```

### 방화벽 규칙 생성
```bash
# SSH 허용 규칙
gcloud compute firewall-rules create allow-ssh \
    --network my-vpc \
    --allow tcp:22 \
    --source-ranges 0.0.0.0/0

# HTTP 허용 규칙
gcloud compute firewall-rules create allow-http \
    --network my-vpc \
    --allow tcp:80 \
    --source-ranges 0.0.0.0/0
```

</details>

---

## 🔒 보안 그룹 및 방화벽

<details>
<summary>📖 보안 개념 이해</summary>

### Security Groups (AWS)
- **정의**: 가상 방화벽
- **특징**: 인스턴스 레벨 보안, 상태 기반 필터링
- **규칙**: 인바운드/아웃바운드 트래픽 제어

### Firewall Rules (GCP)
- **정의**: 네트워크 방화벽 규칙
- **특징**: 네트워크 레벨 보안, 우선순위 기반
- **규칙**: 인바운드/아웃바운드 트래픽 제어

</details>

<details>
<summary>🔗 AWS Security Groups 실습</summary>

### Security Group 생성
```bash
# Web Server Security Group
aws ec2 create-security-group \
    --group-name web-server-sg \
    --description "Security group for web servers" \
    --vpc-id $VPC_ID

# Database Security Group
aws ec2 create-security-group \
    --group-name database-sg \
    --description "Security group for database servers" \
    --vpc-id $VPC_ID
```

### Security Group 규칙 설정
```bash
# HTTP/HTTPS 허용
aws ec2 authorize-security-group-ingress \
    --group-id $WEB_SG_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id $WEB_SG_ID \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

# SSH 허용 (관리자만)
aws ec2 authorize-security-group-ingress \
    --group-id $WEB_SG_ID \
    --protocol tcp \
    --port 22 \
    --cidr YOUR_IP/32
```

</details>

<details>
<summary>🔗 GCP Firewall Rules 실습</summary>

### Firewall Rules 생성
```bash
# HTTP/HTTPS 허용
gcloud compute firewall-rules create allow-http-https \
    --network my-vpc \
    --allow tcp:80,tcp:443 \
    --source-ranges 0.0.0.0/0 \
    --target-tags web-server

# SSH 허용 (관리자만)
gcloud compute firewall-rules create allow-ssh-admin \
    --network my-vpc \
    --allow tcp:22 \
    --source-ranges YOUR_IP/32 \
    --target-tags admin
```

</details>

---

## 🚀 데이터베이스 서비스 기초

<details>
<summary>📖 데이터베이스 서비스 비교</summary>

### AWS RDS vs GCP Cloud SQL
| 구분 | AWS RDS | GCP Cloud SQL |
|------|---------|---------------|
| **엔진** | MySQL, PostgreSQL, Oracle, SQL Server | MySQL, PostgreSQL, SQL Server |
| **스토리지** | EBS 기반 | 영구 디스크 기반 |
| **백업** | 자동 백업 | 자동 백업 |
| **모니터링** | CloudWatch | Cloud Monitoring |

</details>

<details>
<summary>🔗 AWS RDS 실습</summary>

### RDS 인스턴스 생성
```bash
# RDS 서브넷 그룹 생성
aws rds create-db-subnet-group \
    --db-subnet-group-name my-db-subnet-group \
    --db-subnet-group-description "Subnet group for RDS" \
    --subnet-ids subnet-12345 subnet-67890

# RDS 인스턴스 생성
aws rds create-db-instance \
    --db-instance-identifier my-db-instance \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --master-username admin \
    --master-user-password MyPassword123 \
    --allocated-storage 20 \
    --vpc-security-group-ids $DB_SG_ID \
    --db-subnet-group-name my-db-subnet-group
```

</details>

<details>
<summary>🔗 GCP Cloud SQL 실습</summary>

### Cloud SQL 인스턴스 생성
```bash
# Cloud SQL 인스턴스 생성
gcloud sql instances create my-sql-instance \
    --database-version=MYSQL_8_0 \
    --tier=db-f1-micro \
    --region=asia-northeast3 \
    --storage-type=SSD \
    --storage-size=10GB \
    --storage-auto-increase

# 데이터베이스 생성
gcloud sql databases create myapp \
    --instance=my-sql-instance

# 사용자 생성
gcloud sql users create myapp-user \
    --instance=my-sql-instance \
    --password=MyPassword123
```

</details>

---

## 📚 문제 해결 및 참고 자료

<details>
<summary>🐛 자주 발생하는 문제</summary>

### 네트워킹 관련 문제
<details>
<summary>❌ 인스턴스에 접속할 수 없음</summary>

**원인**: 
- Security Group 규칙 문제
- 서브넷 라우팅 문제
- 인터넷 게이트웨이 연결 문제

**해결방법**:
```bash
# 1. Security Group 규칙 확인
aws ec2 describe-security-groups --group-ids sg-xxxxxxxx

# 2. 라우팅 테이블 확인
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=vpc-xxxxxxxx"

# 3. 인터넷 게이트웨이 확인
aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=vpc-xxxxxxxx"
```

</details>

<details>
<summary>❌ 데이터베이스 연결 실패</summary>

**원인**:
- Security Group 규칙 문제
- 데이터베이스 엔드포인트 오류
- 네트워크 ACL 문제

**해결방법**:
```bash
# 1. RDS 엔드포인트 확인
aws rds describe-db-instances --db-instance-identifier my-db-instance

# 2. Security Group 규칙 확인
aws ec2 describe-security-groups --group-ids sg-xxxxxxxx

# 3. 연결 테스트
telnet RDS_ENDPOINT 3306
```

</details>

</details>

<details>
<summary>📖 추가 학습 자료</summary>

### 공식 문서
- [AWS VPC 공식 문서](https://docs.aws.amazon.com/vpc/)
- [GCP VPC 공식 문서](https://cloud.google.com/vpc/docs)
- [AWS RDS 공식 문서](https://docs.aws.amazon.com/rds/)
- [GCP Cloud SQL 공식 문서](https://cloud.google.com/sql/docs)

### 유용한 리소스
- [AWS VPC 예제](https://github.com/aws-samples/aws-vpc-examples)
- [GCP VPC 예제](https://github.com/GoogleCloudPlatform/vpc-examples)
- [네트워킹 모범 사례](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)

### 관련 프로젝트
- [AWS 샘플 프로젝트](https://github.com/aws-samples)
- [GCP 샘플 프로젝트](https://github.com/GoogleCloudPlatform)

</details>

<details>
<summary>🚀 다음 단계</summary>

### Cloud Intermediate 과정 준비
1. **Docker 기초**: 컨테이너 기술 학습
2. **Git/GitHub**: 버전 관리 및 협업
3. **GitHub Actions**: CI/CD 파이프라인
4. **VM 배포**: 웹 애플리케이션 배포

### 실무 적용
1. **실제 프로젝트**: 자신의 프로젝트에 클라우드 서비스 적용
2. **아키텍처 설계**: 네트워킹, 보안, 데이터베이스 통합 설계
3. **모니터링**: CloudWatch, Cloud Monitoring 설정
4. **비용 최적화**: 리소스 사용량 모니터링 및 최적화

</details>

---

## 🎉 완료!

축하합니다! Cloud Basic 2일차 실습을 완료했습니다.

### 📚 학습 요약

이번 실습을 통해 다음을 배웠습니다:

1. **🌐 네트워킹**: VPC, 서브넷, 라우팅 테이블 구성
2. **🔒 보안**: Security Groups, Firewall Rules 설정
3. **🗄️ 데이터베이스**: RDS, Cloud SQL 인스턴스 생성
4. **🏗️ 아키텍처**: 완전한 웹 애플리케이션 아키텍처

### 🚀 다음 단계

- **Cloud Intermediate 과정**: Docker, Git/GitHub, GitHub Actions
- **실제 프로젝트 적용**: 자신의 프로젝트에 클라우드 서비스 적용
- **고급 기능 학습**: 모니터링, 자동화, 최적화

### 💡 추가 학습 자료

- [AWS VPC 공식 문서](https://docs.aws.amazon.com/vpc/)
- [GCP VPC 공식 문서](https://cloud.google.com/vpc/docs)
- [Cloud Master 과정](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md)

---

**🎯 이제 클라우드 기초 서비스의 모든 기본기를 갖추었습니다! Cloud Intermediate 과정으로 진행하세요.**



---



---



---

<div align="center">

## 🏠 최상위 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_basic/learning-path.md)

## 📖 현재 위치
**Cloud Basic** > **2일차** > **네트워킹, 보안, 데이터베이스 실습**

## ⬅️ 이전/다음 네비게이션
[← 이전: Cloud Basic 1일차](/mcp_knowledge_base/cloud_basic/textbook/Day1/README.md) | [다음: Cloud Master 1일차 →](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md)

</div>