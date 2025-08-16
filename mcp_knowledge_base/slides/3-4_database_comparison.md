# 3-4. 데이터베이스 서비스 비교 (RDS vs Cloud SQL)

## 학습 목표
- AWS RDS와 GCP Cloud SQL의 핵심 차이점 이해
- 각 서비스의 데이터베이스 엔진과 기능 비교
- 성능, 확장성, 가용성 특성 분석
- 백업, 복구, 모니터링 기능 비교
- 마이그레이션 전략 및 모범 사례 학습

---

## 관리형 데이터베이스 서비스 개요

### AWS RDS vs GCP Cloud SQL

#### 1. 기본 특징 비교
| 특징 | AWS RDS | GCP Cloud SQL |
|------|---------|---------------|
| **서비스 출시** | 2009년 | 2011년 |
| **지원 데이터베이스** | 6개 엔진 | 3개 엔진 |
| **자동 백업** | 지원 | 지원 |
| **다중 AZ 배포** | 지원 | 지원 |
| **읽기 전용 복제본** | 지원 | 지원 |
| **자동 패치** | 지원 | 지원 |

#### 2. 지원 데이터베이스 엔진
```
AWS RDS:
├── MySQL (5.7, 8.0)
├── PostgreSQL (10, 11, 12, 13, 14, 15)
├── MariaDB (10.3, 10.4, 10.5, 10.6)
├── Oracle (12c, 19c, 21c)
├── SQL Server (2012, 2014, 2016, 2017, 2019)
└── Amazon Aurora (MySQL, PostgreSQL)

GCP Cloud SQL:
├── MySQL (5.7, 8.0)
├── PostgreSQL (9.6, 10, 11, 12, 13, 14, 15)
└── SQL Server (2017, 2019)
```

---

## 성능 및 확장성 비교

### 성능 특성

#### 1. AWS RDS 성능
```
스토리지 성능:
├── General Purpose SSD: 최대 16,000 IOPS
├── Provisioned IOPS SSD: 최대 64,000 IOPS
└── Magnetic: 최대 1,000 IOPS

네트워크 성능:
├── db.t3.micro: 최대 5 Gbps
├── db.m5.large: 최대 10 Gbps
└── db.r5.2xlarge: 최대 10 Gbps
```

#### 2. GCP Cloud SQL 성능
```
스토리지 성능:
├── SSD: 최대 64,000 IOPS
├── HDD: 최대 15,000 IOPS
└── Local SSD: 최대 375,000 IOPS

네트워크 성능:
├── db-f1-micro: 최대 1 Gbps
├── db-n1-standard-1: 최대 1 Gbps
└── db-n1-standard-16: 최대 32 Gbps
```

---

## 가용성 및 재해 복구

### AWS RDS 가용성

#### 1. 다중 AZ 배포
```bash
# 다중 AZ 인스턴스 생성
aws rds create-db-instance \
    --db-instance-identifier mydb \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --multi-az

# 다중 AZ 활성화
aws rds modify-db-instance \
    --db-instance-identifier mydb \
    --multi-az \
    --apply-immediately
```

#### 2. 백업 및 복구
```bash
# 자동 백업 설정
aws rds create-db-instance \
    --db-instance-identifier mydb \
    --backup-retention-period 7 \
    --preferred-backup-window "03:00-04:00"

# 스냅샷 생성
aws rds create-db-snapshot \
    --db-instance-identifier mydb \
    --db-snapshot-identifier mydb-snapshot-001
```

---

## GCP Cloud SQL 가용성

### GCP Cloud SQL 가용성

#### 1. 고가용성 구성
```bash
# 고가용성 인스턴스 생성
gcloud sql instances create mydb \
    --database-version=MYSQL_8_0 \
    --tier=db-n1-standard-1 \
    --region=asia-northeast3 \
    --availability-type=REGIONAL

# 고가용성 활성화
gcloud sql instances patch mydb \
    --availability-type=REGIONAL
```

#### 2. 백업 및 복구
```bash
# 백업 설정
gcloud sql instances patch mydb \
    --backup-start-time="03:00" \
    --backup-retention-days=7 \
    --enable-bin-log

# 스냅샷 생성
gcloud sql instances export mydb \
    gs://my-backup-bucket/mydb-backup.sql \
    --database=myapp
```

---

## 읽기 전용 복제본

### AWS RDS 읽기 전용 복제본

#### 1. 복제본 생성
```bash
# 읽기 전용 복제본 생성
aws rds create-db-instance-read-replica \
    --db-instance-identifier mydb-read-replica \
    --source-db-instance-identifier mydb \
    --db-instance-class db.t3.micro

# 크로스 리전 복제본
aws rds create-db-instance-read-replica \
    --db-instance-identifier mydb-read-replica-us \
    --source-db-instance-identifier mydb \
    --db-instance-class db.t3.micro \
    --availability-zone us-east-1a
```

#### 2. 복제본 관리
```bash
# 복제본 상태 확인
aws rds describe-db-instances \
    --db-instance-identifier mydb-read-replica

# 복제본을 독립 인스턴스로 승격
aws rds promote-read-replica \
    --db-instance-identifier mydb-read-replica
```

---

## GCP Cloud SQL 읽기 전용 복제본

### GCP Cloud SQL 복제본

#### 1. 복제본 생성
```bash
# 읽기 전용 복제본 생성
gcloud sql instances create mydb-read-replica \
    --master-instance-name=mydb \
    --tier=db-n1-standard-1 \
    --region=asia-northeast3

# 크로스 리전 복제본
gcloud sql instances create mydb-read-replica-us \
    --master-instance-name=mydb \
    --tier=db-n1-standard-1 \
    --region=us-central1
```

#### 2. 복제본 관리
```bash
# 복제본 상태 확인
gcloud sql instances describe mydb-read-replica

# 복제본을 독립 인스턴스로 승격
gcloud sql instances promote-replica mydb-read-replica
```

---

## 보안 및 암호화

### AWS RDS 보안

#### 1. 암호화
```bash
# 저장 시 암호화 활성화
aws rds create-db-instance \
    --db-instance-identifier mydb \
    --storage-encrypted \
    --kms-key-id arn:aws:kms:region:account:key/key-id

# 전송 시 암호화
aws rds modify-db-instance \
    --db-instance-identifier mydb \
    --ca-certificate-identifier rds-ca-2019
```

#### 2. 네트워크 보안
```bash
# VPC 보안 그룹 생성
aws ec2 create-security-group \
    --group-name db-sg \
    --description "Database security group" \
    --vpc-id vpc-12345678

# 데이터베이스 포트 허용
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 3306 \
    --cidr 10.0.1.0/24
```

---

## GCP Cloud SQL 보안

### GCP Cloud SQL 보안

#### 1. 암호화
```bash
# 저장 시 암호화 (기본 활성화)
gcloud sql instances create mydb \
    --database-version=MYSQL_8_0 \
    --tier=db-n1-standard-1

# 고객 관리 암호화 키
gcloud sql instances create mydb \
    --database-version=MYSQL_8_0 \
    --tier=db-n1-standard-1 \
    --disk-encryption-key=projects/project/locations/location/keyRings/keyring/cryptoKeys/key
```

#### 2. 네트워크 보안
```bash
# 승인된 네트워크 설정
gcloud sql instances patch mydb \
    --authorized-networks=203.0.113.0/24,198.51.100.0/24

# 프라이빗 서비스 연결
gcloud sql instances patch mydb \
    --network=projects/project/global/networks/network
```

---

## 모니터링 및 로깅

### AWS RDS 모니터링

#### 1. CloudWatch 메트릭
```bash
# 메트릭 확인
aws cloudwatch get-metric-statistics \
    --namespace AWS/RDS \
    --metric-name CPUUtilization \
    --dimensions Name=DBInstanceIdentifier,Value=mydb \
    --start-time 2023-01-01T00:00:00Z \
    --end-time 2023-01-02T00:00:00Z \
    --period 3600 \
    --statistics Average

# 주요 메트릭
├── CPUUtilization: CPU 사용률
├── DatabaseConnections: 데이터베이스 연결 수
├── FreeableMemory: 사용 가능한 메모리
├── ReadIOPS: 읽기 IOPS
└── WriteIOPS: 쓰기 IOPS
```

#### 2. 로그 관리
```bash
# 로그 내보내기 활성화
aws rds modify-db-instance \
    --db-instance-identifier mydb \
    --enable-cloudwatch-logs-exports error,general,slow-query

# 로그 다운로드
aws rds describe-db-log-files \
    --db-instance-identifier mydb
```

---

## GCP Cloud SQL 모니터링

### GCP Cloud SQL 모니터링

#### 1. Cloud Monitoring
```bash
# 메트릭 확인
gcloud monitoring metrics list \
    --filter="metric.type:cloudsql.googleapis.com"

# 주요 메트릭
├── cloudsql.googleapis.com/database/cpu/utilization
├── cloudsql.googleapis.com/database/connections
├── cloudsql.googleapis.com/database/memory/utilization
├── cloudsql.googleapis.com/database/disk/read_ops_count
└── cloudsql.googleapis.com/database/disk/write_ops_count
```

#### 2. 로그 관리
```bash
# 로그 내보내기 활성화
gcloud sql instances patch mydb \
    --enable-bin-log

# 로그 확인
gcloud sql logs list \
    --instance=mydb
```

---

## 비용 구조 비교

### AWS RDS 비용 (서울 리전 기준)

#### 1. 인스턴스 비용
```
db.t3.micro (2 vCPU, 1 GB):
├── On-Demand: 시간당 $0.017
├── Reserved 1년: 시간당 $0.011
└── Reserved 3년: 시간당 $0.007

db.m5.large (2 vCPU, 8 GB):
├── On-Demand: 시간당 $0.137
├── Reserved 1년: 시간당 $0.089
└── Reserved 3년: 시간당 $0.059
```

#### 2. 스토리지 비용
```
General Purpose SSD:
├── 20 GB: 월 $2.30
├── 100 GB: 월 $11.50
└── 1 TB: 월 $115.00

Provisioned IOPS SSD:
├── 스토리지: GB당 월 $0.115
└── IOPS: IOPS당 월 $0.10
```

---

## GCP Cloud SQL 비용 (서울 리전 기준)

### GCP Cloud SQL 비용

#### 1. 인스턴스 비용
```
db-f1-micro (0.6 vCPU, 0.6 GB):
├── On-Demand: 시간당 $0.015
└── Sustained Use: 시간당 $0.011

db-n1-standard-1 (1 vCPU, 3.75 GB):
├── On-Demand: 시간당 $0.054
└── Sustained Use: 시간당 $0.041
```

#### 2. 스토리지 비용
```
SSD:
├── 10 GB: 월 $1.70
├── 100 GB: 월 $17.00
└── 1 TB: 월 $170.00

HDD:
├── 10 GB: 월 $0.40
├── 100 GB: 월 $4.00
└── 1 TB: 월 $40.00
```

---

## 마이그레이션 전략

### AWS RDS에서 GCP Cloud SQL로

#### 1. 마이그레이션 방법
```
방법 1: Database Migration Service
├── AWS DMS를 사용한 실시간 마이그레이션
├── 다운타임 최소화
└── 스키마 및 데이터 변환

방법 2: mysqldump/psql
├── 데이터 내보내기
├── GCP로 데이터 가져오기
└── 애플리케이션 연결 변경

방법 3: Cloud SQL Proxy
├── 로컬에서 GCP 연결
├── 애플리케이션 테스트
└── 점진적 전환
```

#### 2. 마이그레이션 단계
```
Phase 1: 계획 및 준비
├── 데이터베이스 크기 및 구조 분석
├── 네트워크 대역폭 확인
├── 마이그레이션 도구 선택
└── 테스트 환경 구성

Phase 2: 파일럿 마이그레이션
├── 작은 데이터베이스로 테스트
├── 성능 및 정확성 검증
├── 문제점 파악 및 해결
└── 모범 사례 확립

Phase 3: 전체 마이그레이션
├── 단계별 데이터 전송
├── 진행 상황 모니터링
├── 데이터 무결성 검증
└── 애플리케이션 전환
```

---

## 모범 사례 및 권장사항

### AWS RDS 모범 사례

#### 1. 성능 최적화
- [ ] **인스턴스 크기**: 워크로드에 맞는 적절한 크기 선택
- [ ] **스토리지**: IOPS 요구사항에 맞는 스토리지 타입 선택
- [ ] **읽기 전용 복제본**: 읽기 부하 분산
- [ ] **파라미터 그룹**: 데이터베이스 엔진 최적화

#### 2. 보안 강화
- [ ] **암호화**: 저장 시 및 전송 시 암호화 활성화
- [ ] **보안 그룹**: 최소 권한 원칙 적용
- [ ] **IAM 정책**: 데이터베이스 액세스 제어
- [ ] **백업**: 자동 백업 및 스냅샷 설정

### GCP Cloud SQL 모범 사례

#### 1. 성능 최적화
- [ ] **머신 타입**: 워크로드에 맞는 적절한 타입 선택
- [ ] **스토리지**: SSD 사용으로 성능 향상
- [ ] **읽기 전용 복제본**: 읽기 부하 분산
- [ ] **연결 풀**: 애플리케이션 레벨 연결 관리

#### 2. 보안 강화
- [ ] **승인된 네트워크**: IP 범위 제한
- [ ] **프라이빗 서비스 연결**: VPC 내부 통신
- [ ] **IAM 조건**: 네트워크 기반 액세스 제어
- [ ] **백업**: 자동 백업 및 로그 설정

---

## 실제 사용 사례

### 웹 애플리케이션 데이터베이스

#### 1. AWS RDS 구성
```
웹 서버 → RDS MySQL (다중 AZ)
├── 자동 백업 (7일 보관)
├── 읽기 전용 복제본 (2개)
├── 자동 패치 및 업데이트
└── CloudWatch 모니터링
```

#### 2. GCP Cloud SQL 구성
```
웹 서버 → Cloud SQL MySQL (고가용성)
├── 자동 백업 (7일 보관)
├── 읽기 전용 복제본 (2개)
├── 자동 패치 및 업데이트
└── Cloud Monitoring
```

---

## 실습 과제

### 기본 실습
1. **RDS와 Cloud SQL 인스턴스 생성**
2. **데이터베이스 연결 및 테스트**
3. **백업 및 복구 테스트**

### 고급 실습
1. **읽기 전용 복제본 구성**
2. **크로스 플랫폼 마이그레이션 실행**
3. **모니터링 및 알림 설정**

---

## 다음 단계
- Terraform을 사용한 인프라 코드화
- CI/CD 파이프라인 구축
- 컨테이너 및 고급 배포 전략

---

## 참고 자료
- [AWS RDS 사용자 가이드](https://docs.aws.amazon.com/rds/latest/userguide/)
- [GCP Cloud SQL 문서](https://cloud.google.com/sql/docs)
- [AWS RDS 가격](https://aws.amazon.com/rds/pricing/)
- [GCP Cloud SQL 가격](https://cloud.google.com/sql/pricing)
- [AWS Database Migration Service](https://docs.aws.amazon.com/dms/latest/userguide/)
- [GCP Database Migration Service](https://cloud.google.com/database-migration)
