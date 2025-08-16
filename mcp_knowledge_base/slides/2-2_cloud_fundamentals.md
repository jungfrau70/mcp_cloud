# 2-2. 클라우드 핵심 서비스 개념 (VPC, S3, EC2)

## 학습 목표
- 가상 프라이빗 클라우드 (VPC) 개념과 구성 요소 이해
- 객체 스토리지 (S3, Cloud Storage) 서비스 활용법
- 가상 머신 (EC2, Compute Engine) 인스턴스 관리
- 네트워킹, 스토리지, 컴퓨팅의 상호작용 이해
- 실제 사용 사례와 아키텍처 패턴 학습

---

## 가상 프라이빗 클라우드 (VPC)

### VPC란?
> **VPC (Virtual Private Cloud)**는 클라우드 내에서 논리적으로 격리된 네트워크 환경을 제공하는 서비스

### 핵심 구성 요소

#### 1. 서브넷 (Subnet)
- **퍼블릭 서브넷**: 인터넷 게이트웨이와 연결
- **프라이빗 서브넷**: 인터넷 직접 접근 불가
- **가용영역별 분산**: 고가용성 보장

#### 2. 라우팅 테이블
- **메인 라우팅 테이블**: 기본 라우팅 규칙
- **커스텀 라우팅 테이블**: 특정 서브넷용 규칙
- **라우트 전파**: VPN/Direct Connect 연결

#### 3. 보안 그룹 & NACL
- **보안 그룹**: 인스턴스 레벨 방화벽
- **NACL**: 서브넷 레벨 방화벽
- **상태 기반 vs 무상태**: 연결 추적 방식

---

## AWS VPC 구성 예시

### 기본 VPC 구조
```
VPC: 10.0.0.0/16
├── 가용영역 A (ap-northeast-2a)
│   ├── 퍼블릭 서브넷: 10.0.1.0/24
│   └── 프라이빗 서브넷: 10.0.2.0/24
└── 가용영역 B (ap-northeast-2b)
    ├── 퍼블릭 서브넷: 10.0.3.0/24
    └── 프라이빗 서브넷: 10.0.4.0/24
```

### VPC 생성 명령어
```bash
# VPC 생성
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=BootcampVPC}]'

# 서브넷 생성
aws ec2 create-subnet --vpc-id vpc-12345678 --cidr-block 10.0.1.0/24 --availability-zone ap-northeast-2a

# 인터넷 게이트웨이 연결
aws ec2 create-internet-gateway
aws ec2 attach-internet-gateway --vpc-id vpc-12345678 --internet-gateway-id igw-12345678
```

---

## GCP VPC 구성 예시

### 기본 VPC 구조
```
VPC: custom-vpc
├── 리전: asia-northeast3
├── 서브넷: subnet-asia-northeast3
│   └── CIDR: 10.0.0.0/24
└── 방화벽 규칙: allow-ssh, allow-http
```

### VPC 생성 명령어
```bash
# VPC 생성
gcloud compute networks create bootcamp-vpc --subnet-mode=custom

# 서브넷 생성
gcloud compute networks subnets create subnet-asia-northeast3 \
    --network=bootcamp-vpc \
    --region=asia-northeast3 \
    --range=10.0.0.0/24

# 방화벽 규칙 생성
gcloud compute firewall-rules create allow-ssh \
    --network=bootcamp-vpc \
    --allow=tcp:22 \
    --source-ranges=0.0.0.0/0
```

---

## 객체 스토리지 (S3, Cloud Storage)

### 객체 스토리지 특징
- **무제한 확장성**: 필요에 따라 용량 증가
- **고가용성**: 99.99% 이상의 가용성
- **내구성**: 99.999999999% (11개 9) 데이터 보존
- **비용 효율성**: 사용한 만큼만 지불

### AWS S3 서비스

#### 1. 스토리지 클래스
- **S3 Standard**: 자주 접근하는 데이터
- **S3 Intelligent-Tiering**: 자동 계층화
- **S3 Standard-IA**: 자주 접근하지 않는 데이터
- **S3 One Zone-IA**: 단일 가용영역
- **S3 Glacier**: 장기 보관
- **S3 Glacier Deep Archive**: 최장기 보관

#### 2. S3 기능
- **버전 관리**: 파일 변경 이력 추적
- **수명 주기 정책**: 자동 계층화 및 삭제
- **복제**: 크로스 리전, 크로스 계정
- **암호화**: 서버 사이드 암호화

---

## GCP Cloud Storage 서비스

### 스토리지 클래스
- **Standard**: 자주 접근하는 데이터
- **Nearline**: 월 1회 이하 접근
- **Coldline**: 분기 1회 이하 접근
- **Archive**: 연 1회 이하 접근

### 고급 기능
- **Object Lifecycle Management**: 자동 계층화
- **Versioning**: 파일 버전 관리
- **Retention Policy**: 보존 정책
- **Object Holds**: 법적 보존

---

## S3/Cloud Storage 사용 예시

### AWS S3 명령어
```bash
# 버킷 생성
aws s3 mb s3://my-bootcamp-bucket

# 파일 업로드
aws s3 cp local-file.txt s3://my-bootcamp-bucket/

# 디렉토리 동기화
aws s3 sync ./local-folder s3://my-bootcamp-bucket/

# 버킷 정책 설정
aws s3api put-bucket-policy --bucket my-bootcamp-bucket --policy file://bucket-policy.json

# 수명 주기 정책 설정
aws s3api put-bucket-lifecycle-configuration \
    --bucket my-bootcamp-bucket \
    --lifecycle-configuration file://lifecycle-policy.json
```

### GCP Cloud Storage 명령어
```bash
# 버킷 생성
gsutil mb gs://my-bootcamp-bucket

# 파일 업로드
gsutil cp local-file.txt gs://my-bootcamp-bucket/

# 디렉토리 동기화
gsutil -m rsync -r ./local-folder gs://my-bootcamp-bucket/

# 버킷 정책 설정
gsutil iam ch user:user@example.com:objectViewer gs://my-bootcamp-bucket

# 수명 주기 정책 설정
gsutil lifecycle set lifecycle-policy.json gs://my-bootcamp-bucket
```

---

## 가상 머신 (EC2, Compute Engine)

### 가상 머신 특징
- **가상화**: 물리적 하드웨어를 논리적으로 분할
- **확장성**: 필요에 따라 인스턴스 크기 조정
- **유연성**: 다양한 OS 및 애플리케이션 실행
- **비용 효율성**: 사용한 시간만큼 과금

### AWS EC2 인스턴스

#### 1. 인스턴스 타입
- **General Purpose**: t3, m5, m6 (웹 서버, 애플리케이션)
- **Compute Optimized**: c5, c6 (고성능 컴퓨팅)
- **Memory Optimized**: r5, r6 (대용량 메모리)
- **Storage Optimized**: i3, d2 (고성능 스토리지)

#### 2. 인스턴스 구매 옵션
- **On-Demand**: 사용한 만큼 지불
- **Reserved**: 1-3년 약정으로 할인
- **Spot**: 미사용 용량을 할인된 가격으로 사용
- **Dedicated**: 전용 하드웨어

---

## GCP Compute Engine 인스턴스

### 머신 타입
- **General Purpose**: e2, n2, n2d (일반적인 워크로드)
- **Compute Optimized**: c2, c2d (고성능 컴퓨팅)
- **Memory Optimized**: m2, m2-ultramem (대용량 메모리)
- **GPU**: a2, g2 (머신러닝, 그래픽 처리)

### 인스턴스 옵션
- **On-Demand**: 사용한 만큼 지불
- **Preemptible**: 24시간 이내 종료 가능 (할인)
- **Sustained Use Discounts**: 장기 사용 할인
- **Committed Use Discounts**: 1-3년 약정 할인

---

## EC2/Compute Engine 관리

### AWS EC2 명령어
```bash
# 인스턴스 생성
aws ec2 run-instances \
    --image-id ami-12345678 \
    --count 1 \
    --instance-type t3.micro \
    --key-name my-key-pair \
    --security-group-ids sg-12345678 \
    --subnet-id subnet-12345678

# 인스턴스 목록
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"

# 인스턴스 시작/중지
aws ec2 start-instances --instance-ids i-12345678
aws ec2 stop-instances --instance-ids i-12345678

# 인스턴스 종료
aws ec2 terminate-instances --instance-ids i-12345678
```

### GCP Compute Engine 명령어
```bash
# 인스턴스 생성
gcloud compute instances create bootcamp-instance \
    --zone=asia-northeast3-a \
    --machine-type=e2-micro \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --network=bootcamp-vpc \
    --subnet=subnet-asia-northeast3

# 인스턴스 목록
gcloud compute instances list --filter="status=RUNNING"

# 인스턴스 시작/중지
gcloud compute instances start bootcamp-instance --zone=asia-northeast3-a
gcloud compute instances stop bootcamp-instance --zone=asia-northeast3-a

# 인스턴스 삭제
gcloud compute instances delete bootcamp-instance --zone=asia-northeast3-a
```

---

## 네트워킹, 스토리지, 컴퓨팅의 상호작용

### 기본 아키텍처 패턴
```
인터넷
    ↓
인터넷 게이트웨이
    ↓
퍼블릭 서브넷 (10.0.1.0/24)
    ↓
로드 밸런서
    ↓
프라이빗 서브넷 (10.0.2.0/24)
    ↓
EC2 인스턴스들
    ↓
RDS 데이터베이스
    ↓
S3 버킷 (백업/로그)
```

### 데이터 플로우
1. **사용자 요청** → 인터넷 게이트웨이
2. **로드 밸런서** → 여러 EC2 인스턴스로 분산
3. **EC2 인스턴스** → RDS에서 데이터 조회
4. **결과 반환** → 사용자에게 응답
5. **로그 저장** → S3에 자동 저장

---

## 실제 사용 사례

### 웹 애플리케이션 호스팅
```
사용자 → CloudFront → ALB → EC2 (Auto Scaling) → RDS
                                    ↓
                                S3 (정적 파일)
```

### 데이터 분석 파이프라인
```
데이터 소스 → S3 (Raw Data) → Lambda → S3 (Processed) → Athena → QuickSight
```

### 마이크로서비스 아키텍처
```
API Gateway → Lambda → DynamoDB
     ↓
CloudWatch (모니터링)
     ↓
S3 (로그 저장)
```

---

## 보안 및 모범 사례

### 네트워크 보안
- [ ] **서브넷 분리**: 퍼블릭/프라이빗 서브넷 분리
- [ ] **보안 그룹**: 최소 권한 원칙 적용
- [ ] **NACL**: 서브넷 레벨 방화벽 설정
- [ ] **VPN 연결**: 온프레미스와 안전한 연결

### 스토리지 보안
- [ ] **암호화**: 저장 시 및 전송 시 암호화
- [ ] **액세스 제어**: IAM 정책으로 세밀한 권한 관리
- [ ] **버전 관리**: 실수로 삭제된 파일 복구
- [ ] **백업**: 크로스 리전 백업 설정

### 컴퓨팅 보안
- [ ] **키 페어**: SSH 키 안전한 관리
- [ ] **패치 관리**: 정기적인 보안 업데이트
- [ ] **모니터링**: CloudWatch/Cloud Monitoring 설정
- [ ] **로그 관리**: 모든 활동 로그 수집

---

## 비용 최적화 전략

### 컴퓨팅 최적화
- **Auto Scaling**: 수요에 따른 자동 확장/축소
- **Spot 인스턴스**: 비용이 중요한 워크로드
- **Reserved 인스턴스**: 안정적인 워크로드
- **Right Sizing**: 적절한 인스턴스 크기 선택

### 스토리지 최적화
- **수명 주기 정책**: 자동 계층화
- **압축**: 데이터 압축으로 용량 절약
- **중복 제거**: 중복 데이터 제거
- **백업 전략**: 비용 효율적인 백업

---

## 실습 과제

### 기본 실습
1. **VPC 생성 및 서브넷 구성**
2. **EC2 인스턴스 생성 및 연결**
3. **S3 버킷 생성 및 파일 업로드**
4. **보안 그룹 및 방화벽 규칙 설정**

### 고급 실습
1. **멀티 티어 아키텍처 구축**
2. **Auto Scaling 그룹 구성**
3. **로드 밸런서 설정**
4. **모니터링 및 알림 구성**

---

## 다음 단계
- AWS와 GCP 서비스 비교 분석
- Terraform을 사용한 인프라 코드화
- CI/CD 파이프라인 구축

---

## 참고 자료
- [AWS VPC 사용자 가이드](https://docs.aws.amazon.com/vpc/latest/userguide/)
- [GCP VPC 문서](https://cloud.google.com/vpc/docs)
- [AWS S3 사용자 가이드](https://docs.aws.amazon.com/s3/latest/userguide/)
- [GCP Cloud Storage 문서](https://cloud.google.com/storage/docs)
- [AWS EC2 사용자 가이드](https://docs.aws.amazon.com/ec2/latest/userguide/)
- [GCP Compute Engine 문서](https://cloud.google.com/compute/docs)
