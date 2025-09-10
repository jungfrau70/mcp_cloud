# 7-1. 클라우드 보안 및 규정 준수

## 학습 목표
- 클라우드 보안의 핵심 원칙 이해
- AWS와 GCP의 보안 서비스 활용
- 규정 준수 요구사항 대응
- 보안 모범 사례 및 체크리스트

---

## 클라우드 보안 원칙

### 공유 책임 모델
```
AWS 공유 책임:
├── AWS 책임 (클라우드 자체)
│   ├── 하드웨어 및 글로벌 인프라
│   ├── 리전, 가용영역, 엣지 로케이션
│   └── 컴퓨팅, 스토리지, 데이터베이스
└── 고객 책임 (클라우드 내부)
    ├── 운영체제 및 네트워크 구성
    ├── 애플리케이션 및 데이터
    └── 보안 그룹 및 방화벽

GCP 공유 책임:
├── Google 책임
│   ├── 물리적 보안
│   ├── 하드웨어 및 소프트웨어 인프라
│   └── 글로벌 네트워크
└── 고객 책임
    ├── 데이터 보안
    ├── 애플리케이션 보안
    └── 액세스 관리
```

---

## AWS 보안 서비스

### IAM (Identity and Access Management)
```bash
# 사용자 생성
aws iam create-user --user-name developer

# 그룹 생성
aws iam create-group --group-name developers

# 사용자를 그룹에 추가
aws iam add-user-to-group --user-name developer --group-name developers

# 정책 연결
aws iam attach-group-policy \
    --group-name developers \
    --policy-arn arn:aws:iam::aws:policy/PowerUserAccess

# MFA 활성화
aws iam enable-mfa-device \
    --user-name developer \
    --serial-number arn:aws:mfa:123456789012:mfa/username \
    --authentication-code1 123456 \
    --authentication-code2 654321
```

### KMS (Key Management Service)
```bash
# 키 생성
aws kms create-key \
    --description "Bootcamp encryption key" \
    --key-usage ENCRYPT_DECRYPT \
    --origin AWS_KMS

# 키 별칭 생성
aws kms create-alias \
    --alias-name alias/bootcamp-key \
    --target-key-id key-id

# 데이터 암호화
aws kms encrypt \
    --key-id alias/bootcamp-key \
    --plaintext "Hello, World!" \
    --output text
```

---

## GCP 보안 서비스

### IAM (Identity and Access Management)
```bash
# 사용자 역할 할당
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="user:user@example.com" \
    --role="roles/compute.viewer"

# 서비스 계정 생성
gcloud iam service-accounts create bootcamp-sa \
    --display-name="Bootcamp Service Account"

# 서비스 계정에 역할 할당
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="serviceAccount:bootcamp-sa@PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

# 키 생성
gcloud iam service-accounts keys create key.json \
    --iam-account=bootcamp-sa@PROJECT_ID.iam.gserviceaccount.com
```

### Cloud KMS
```bash
# 키링 생성
gcloud kms keyrings create bootcamp-keyring \
    --location=asia-northeast3

# 키 생성
gcloud kms keys create bootcamp-key \
    --keyring=bootcamp-keyring \
    --location=asia-northeast3 \
    --purpose=encryption

# 데이터 암호화
echo "Hello, World!" | gcloud kms encrypt \
    --key=bootcamp-key \
    --keyring=bootcamp-keyring \
    --location=asia-northeast3 \
    --plaintext-file=- \
    --ciphertext-file=encrypted.txt
```

---

## 네트워크 보안

### AWS VPC 보안
```bash
# 보안 그룹 생성
aws ec2 create-security-group \
    --group-name web-sg \
    --description "Web server security group" \
    --vpc-id vpc-12345678

# SSH 접근 허용 (특정 IP만)
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 22 \
    --cidr 203.0.113.0/24

# HTTP 접근 허용
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

# HTTPS 접근 허용
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0
```

### GCP VPC 보안
```bash
# 방화벽 규칙 생성
gcloud compute firewall-rules create allow-ssh \
    --network=bootcamp-vpc \
    --allow=tcp:22 \
    --source-ranges=203.0.113.0/24

# HTTP 접근 허용
gcloud compute firewall-rules create allow-http \
    --network=bootcamp-vpc \
    --allow=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server

# HTTPS 접근 허용
gcloud compute firewall-rules create allow-https \
    --network=bootcamp-vpc \
    --allow=tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=https-server
```

---

## 데이터 보안

### AWS S3 암호화
```bash
# 서버 사이드 암호화 활성화
aws s3api put-bucket-encryption \
    --bucket my-bucket \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

# KMS 암호화로 파일 업로드
aws s3 cp file.txt s3://my-bucket/ \
    --sse aws:kms \
    --sse-kms-key-id alias/bootcamp-key

# 버킷 정책으로 액세스 제한
aws s3api put-bucket-policy \
    --bucket my-bucket \
    --policy file://bucket-policy.json
```

### GCP Cloud Storage 암호화
```bash
# 고객 관리 암호화 키로 버킷 생성
gsutil mb -p PROJECT_ID -c STANDARD -l asia-northeast3 \
    gs://my-bucket

# 암호화된 파일 업로드
gsutil cp file.txt gs://my-bucket/ \
    --encryption-key=projects/PROJECT_ID/locations/asia-northeast3/keyRings/bootcamp-keyring/cryptoKeys/bootcamp-key

# IAM 정책으로 액세스 제한
gsutil iam ch user:user@example.com:objectViewer gs://my-bucket
```

---

## 모니터링 및 로깅

### AWS CloudTrail
```bash
# CloudTrail 활성화
aws cloudtrail create-trail \
    --name bootcamp-trail \
    --s3-bucket-name my-log-bucket \
    --include-global-service-events

# 로그 파일 확인
aws s3 ls s3://my-log-bucket/AWSLogs/ACCOUNT_ID/CloudTrail/

# API 호출 이벤트 조회
aws cloudtrail lookup-events \
    --lookup-attributes AttributeKey=EventName,AttributeValue=RunInstances
```

### GCP Cloud Audit Logs
```bash
# 감사 로그 확인
gcloud logging read "resource.type=gce_instance" \
    --limit=10 \
    --format="table(timestamp,resource.labels.instance_name,textPayload)"

# 로그 내보내기
gcloud logging sinks create bootcamp-sink \
    gs://my-log-bucket \
    --log-filter="resource.type=gce_instance"
```

---

## 규정 준수

### SOC 2 준수
```
SOC 2 Type II 준수:
├── 보안 (Security)
├── 가용성 (Availability)
├── 처리 무결성 (Processing Integrity)
├── 기밀성 (Confidentiality)
└── 개인정보보호 (Privacy)
```

### GDPR 준수
```bash
# 데이터 분류 및 태깅
aws s3api put-bucket-tagging \
    --bucket my-bucket \
    --tagging '{
        "TagSet": [
            {
                "Key": "DataClassification",
                "Value": "PII"
            },
            {
                "Key": "RetentionPeriod",
                "Value": "7years"
            }
        ]
    }'

# 데이터 수명 주기 정책
aws s3api put-bucket-lifecycle-configuration \
    --bucket my-bucket \
    --lifecycle-configuration '{
        "Rules": [
            {
                "ID": "GDPR_Retention",
                "Status": "Enabled",
                "Expiration": {
                    "Days": 2555
                }
            }
        ]
    }'
```

---

## 보안 모범 사례

### 액세스 관리
- [ ] **최소 권한 원칙**: 필요한 권한만 부여
- [ ] **정기적인 권한 검토**: 사용하지 않는 권한 제거
- [ ] **MFA 활성화**: 모든 사용자 계정에 적용
- [ ] **액세스 키 순환**: 90일마다 변경

### 네트워크 보안
- [ ] **VPC 구성**: 퍼블릭/프라이빗 서브넷 분리
- [ ] **보안 그룹**: 최소한의 포트만 열기
- [ ] **WAF 활용**: 웹 애플리케이션 방화벽
- [ ] **VPN 연결**: 온프레미스와 안전한 연결

### 데이터 보안
- [ ] **암호화**: 저장 시 및 전송 시 암호화
- [ ] **백업**: 정기적인 백업 및 복구 테스트
- [ ] **데이터 분류**: 민감도에 따른 데이터 관리
- [ ] **접근 로깅**: 모든 데이터 액세스 기록

---

## 보안 체크리스트

### 인프라 보안
- [ ] **IAM 정책 검토**: 사용자별 권한 확인
- [ ] **보안 그룹 설정**: 네트워크 액세스 제어
- [ ] **암호화 설정**: 데이터 암호화 활성화
- [ ] **로깅 활성화**: 모든 활동 로그 수집

### 애플리케이션 보안
- [ ] **코드 스캔**: 보안 취약점 검사
- [ ] **의존성 검사**: 보안 업데이트 확인
- [ ] **시크릿 관리**: 민감한 정보 안전한 저장
- [ ] **HTTPS 강제**: 모든 통신 암호화

### 운영 보안
- [ ] **패치 관리**: 정기적인 보안 업데이트
- [ ] **모니터링**: 보안 이벤트 실시간 감시
- [ ] **인시던트 대응**: 보안 사고 대응 계획
- [ ] **정기 감사**: 보안 상태 정기 점검

---

## 실습 과제

### 기본 실습
1. **IAM 사용자 및 그룹 생성**
2. **보안 그룹 및 방화벽 규칙 설정**
3. **데이터 암호화 구성**

### 고급 실습
1. **보안 모니터링 및 알림 설정**
2. **규정 준수 체크리스트 작성**
3. **보안 인시던트 대응 시나리오**

---

## 다음 단계
- 클라우드 기반 DevOps 심화 실습
- GitOps 및 고급 워크플로우
- 클라우드 네이티브 아키텍처 설계
