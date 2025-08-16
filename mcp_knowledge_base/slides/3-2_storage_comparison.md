# 3-2. 스토리지 서비스 비교 (S3 vs Cloud Storage)

## 학습 목표
- AWS S3와 GCP Cloud Storage의 핵심 차이점 이해
- 각 서비스의 스토리지 클래스와 가격 구조 분석
- 데이터 전송, 암호화, 보안 기능 비교
- 실제 사용 사례별 최적 서비스 선택 방법
- 마이그레이션 전략 및 모범 사례 학습

---

## 객체 스토리지 서비스 개요

### AWS S3 vs GCP Cloud Storage

#### 1. 기본 특징 비교
| 특징 | AWS S3 | GCP Cloud Storage |
|------|---------|-------------------|
| **서비스 출시** | 2006년 | 2010년 |
| **글로벌 가용성** | 99.99% | 99.95% |
| **데이터 내구성** | 99.999999999% | 99.999999999% |
| **최대 객체 크기** | 5TB | 5TB |
| **버킷당 객체 수** | 무제한 | 무제한 |
| **API 호환성** | S3 API | S3 API + GCS API |

#### 2. 리전 및 가용영역
```
AWS S3:
├── 글로벌 서비스 (단일 엔드포인트)
├── 25개 리전
└── 3개 가용영역/리전

GCP Cloud Storage:
├── 글로벌 서비스 (단일 네임스페이스)
├── 35개 리전
└── 3개 가용영역/리전
```

---

## 스토리지 클래스 비교

### AWS S3 스토리지 클래스

#### 1. 자주 접근하는 데이터
- **S3 Standard**
  - 가용성: 99.99%
  - 내구성: 99.999999999%
  - 접근 시간: 밀리초
  - 사용 사례: 웹사이트, 콘텐츠 배포, 빅데이터 분석

#### 2. 자주 접근하지 않는 데이터
- **S3 Standard-IA**
  - 가용성: 99.9%
  - 내구성: 99.999999999%
  - 접근 시간: 밀리초
  - 사용 사례: 백업, 재해 복구, 장기 저장

- **S3 One Zone-IA**
  - 가용성: 99.5%
  - 내구성: 99.999999999%
  - 접근 시간: 밀리초
  - 사용 사례: 로컬 백업, 재생 가능한 데이터

#### 3. 장기 보관
- **S3 Glacier**
  - 가용성: 99.9%
  - 내구성: 99.999999999%
  - 접근 시간: 분~시간
  - 사용 사례: 장기 백업, 아카이브

- **S3 Glacier Deep Archive**
  - 가용성: 99.9%
  - 내구성: 99.999999999%
  - 접근 시간: 시간
  - 사용 사례: 규정 준수, 장기 보관

---

## GCP Cloud Storage 스토리지 클래스

### 1. 자주 접근하는 데이터
- **Standard**
  - 가용성: 99.95%
  - 내구성: 99.999999999%
  - 접근 시간: 밀리초
  - 사용 사례: 웹사이트, 모바일 앱, 게임

### 2. 자주 접근하지 않는 데이터
- **Nearline**
  - 가용성: 99.9%
  - 내구성: 99.999999999%
  - 접근 시간: 밀리초
  - 사용 사례: 백업, 재해 복구

- **Coldline**
  - 가용성: 99.9%
  - 내구성: 99.999999999%
  - 접근 시간: 밀리초
  - 사용 사례: 장기 백업, 아카이브

### 3. 장기 보관
- **Archive**
  - 가용성: 99.9%
  - 내구성: 99.999999999%
  - 접근 시간: 밀리초
  - 사용 사례: 규정 준수, 장기 보관

---

## 가격 구조 비교

### AWS S3 가격 (서울 리전 기준)

#### 1. 스토리지 비용 (GB당 월 비용)
```
S3 Standard: $0.025
S3 Standard-IA: $0.0125
S3 One Zone-IA: $0.01
S3 Glacier: $0.004
S3 Glacier Deep Archive: $0.00099
```

#### 2. 요청 비용
```
GET 요청: $0.0004/1,000 요청
PUT/COPY/POST/LIST 요청: $0.0005/1,000 요청
DELETE 요청: 무료
```

#### 3. 데이터 전송 비용
```
인터넷 → S3: 무료
S3 → 인터넷: $0.114/GB
S3 → CloudFront: $0.02/GB
```

### GCP Cloud Storage 가격 (서울 리전 기준)

#### 1. 스토리지 비용 (GB당 월 비용)
```
Standard: $0.020
Nearline: $0.010
Coldline: $0.004
Archive: $0.0012
```

#### 2. 요청 비용
```
Class A 요청 (읽기): $0.004/1,000 요청
Class B 요청 (쓰기): $0.004/1,000 요청
Class C 요청 (리스트): $0.004/1,000 요청
```

#### 3. 데이터 전송 비용
```
인터넷 → Cloud Storage: 무료
Cloud Storage → 인터넷: $0.12/GB
Cloud Storage → Cloud CDN: $0.02/GB
```

---

## 기능 및 특성 비교

### AWS S3 고급 기능

#### 1. 데이터 관리
- **S3 Lifecycle**: 자동 계층화 및 삭제
- **S3 Replication**: 크로스 리전, 크로스 계정
- **S3 Batch Operations**: 대량 객체 작업
- **S3 Object Lock**: 규정 준수 및 WORM

#### 2. 성능 최적화
- **S3 Transfer Acceleration**: CloudFront 엣지 로케이션 활용
- **S3 Select**: 객체 내용 필터링
- **S3 Glacier Select**: 아카이브 데이터 쿼리
- **S3 Intelligent-Tiering**: 자동 계층화

#### 3. 보안 및 암호화
- **Server-Side Encryption**: SSE-S3, SSE-KMS, SSE-C
- **Client-Side Encryption**: CSE-KMS, CSE-C
- **VPC Endpoints**: 프라이빗 네트워크 접근
- **Access Points**: 세밀한 액세스 제어

---

## GCP Cloud Storage 고급 기능

### 1. 데이터 관리
- **Object Lifecycle Management**: 자동 계층화
- **Object Versioning**: 파일 버전 관리
- **Retention Policy**: 보존 정책
- **Object Holds**: 법적 보존

### 2. 성능 최적화
- **Parallel Composite Uploads**: 대용량 파일 업로드 최적화
- **Resumable Uploads**: 업로드 재개
- **Object Composition**: 객체 병합
- **Cloud CDN**: 글로벌 콘텐츠 배포

### 3. 보안 및 암호화
- **Customer-Supplied Encryption Keys**: 고객 제공 암호화 키
- **Customer-Managed Encryption Keys**: 고객 관리 암호화 키
- **VPC Service Controls**: 네트워크 격리
- **IAM Conditions**: 조건부 액세스

---

## 성능 및 확장성 비교

### 처리량 및 대역폭

#### 1. AWS S3 성능
```
단일 객체 업로드: 최대 5GB (PUT), 5GB+ (Multipart)
단일 객체 다운로드: 최대 5GB
Multipart 업로드: 최대 10,000 파트
전송 속도: 최대 5Gbps (인스턴스 타입별)
```

#### 2. GCP Cloud Storage 성능
```
단일 객체 업로드: 최대 5GB (PUT), 5GB+ (Resumable)
단일 객체 다운로드: 최대 5GB
Resumable 업로드: 최대 5TB
전송 속도: 최대 32Gbps (인스턴스 타입별)
```

### 확장성 및 제한

#### 1. AWS S3 제한
```
버킷당 객체: 무제한
객체 크기: 최소 0바이트, 최대 5TB
키 이름 길이: 최대 1,024바이트
태그: 객체당 최대 10개
```

#### 2. GCP Cloud Storage 제한
```
버킷당 객체: 무제한
객체 크기: 최소 0바이트, 최대 5TB
키 이름 길이: 최대 1,024바이트
라벨: 객체당 최대 64개
```

---

## 보안 및 규정 준수

### 암호화 비교

#### 1. 저장 시 암호화
```
AWS S3:
├── SSE-S3: AWS 관리 키
├── SSE-KMS: AWS KMS 키
└── SSE-C: 고객 제공 키

GCP Cloud Storage:
├── Google 관리 키 (기본)
├── Customer-Managed Keys
└── Customer-Supplied Keys
```

#### 2. 전송 시 암호화
```
AWS S3: HTTPS/TLS 1.2+ (기본)
GCP Cloud Storage: HTTPS/TLS 1.2+ (기본)
```

### 액세스 제어

#### 1. AWS S3 액세스 제어
- **IAM 정책**: 사용자별 권한 관리
- **버킷 정책**: 버킷 레벨 액세스 제어
- **ACL**: 객체별 액세스 제어
- **S3 Access Points**: 세밀한 액세스 제어

#### 2. GCP Cloud Storage 액세스 제어
- **IAM**: 프로젝트 레벨 권한 관리
- **ACL**: 객체별 액세스 제어
- **Signed URLs**: 임시 액세스 URL
- **VPC Service Controls**: 네트워크 격리

---

## 실제 사용 사례 비교

### 웹 애플리케이션 호스팅

#### 1. AWS S3 + CloudFront
```
사용자 → CloudFront → S3
├── 정적 웹사이트 호스팅
├── 이미지/비디오 저장
├── 사용자 업로드 파일
└── 백업 및 로그 저장
```

#### 2. GCP Cloud Storage + Cloud CDN
```
사용자 → Cloud CDN → Cloud Storage
├── 정적 웹사이트 호스팅
├── 미디어 파일 저장
├── 사용자 콘텐츠
└── 백업 및 아카이브
```

### 데이터 분석 파이프라인

#### 1. AWS 데이터 파이프라인
```
데이터 소스 → S3 (Raw) → Lambda → S3 (Processed) → Athena → QuickSight
```

#### 2. GCP 데이터 파이프라인
```
데이터 소스 → Cloud Storage (Raw) → Cloud Functions → Cloud Storage (Processed) → BigQuery → Data Studio
```

---

## 마이그레이션 전략

### AWS S3에서 GCP Cloud Storage로

#### 1. 마이그레이션 방법
```
방법 1: gsutil rsync (권장)
gsutil -m rsync -r s3://source-bucket gs://destination-bucket

방법 2: Storage Transfer Service
- GCP 콘솔에서 설정
- 자동화된 전송 관리
- 진행 상황 모니터링

방법 3: Cloud Dataflow
- 대용량 데이터 처리
- 변환 및 필터링
- 실시간 스트리밍
```

#### 2. 마이그레이션 단계
```
Phase 1: 계획 및 준비
├── 데이터 크기 및 구조 분석
├── 네트워크 대역폭 확인
├── 마이그레이션 도구 선택
└── 테스트 환경 구성

Phase 2: 파일럿 마이그레이션
├── 작은 데이터셋으로 테스트
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

### AWS S3 모범 사례

#### 1. 성능 최적화
- [ ] **Multipart 업로드**: 100MB 이상 파일
- [ ] **CloudFront 활용**: 글로벌 콘텐츠 배포
- [ ] **적절한 스토리지 클래스**: 접근 패턴에 맞춤
- [ ] **S3 Select**: 필요한 데이터만 다운로드

#### 2. 보안 강화
- [ ] **버킷 정책**: 최소 권한 원칙
- [ ] **암호화**: 저장 시 및 전송 시 암호화
- [ ] **액세스 로깅**: 모든 액세스 기록
- [ ] **버전 관리**: 실수로 삭제된 파일 복구

### GCP Cloud Storage 모범 사례

#### 1. 성능 최적화
- [ ] **Resumable 업로드**: 대용량 파일 처리
- [ ] **Cloud CDN**: 글로벌 콘텐츠 배포
- [ ] **적절한 스토리지 클래스**: 비용 효율성
- [ ] **병렬 처리**: 대용량 데이터 작업

#### 2. 보안 강화
- [ ] **IAM 정책**: 세밀한 권한 관리
- [ ] **암호화**: 고객 관리 키 사용
- [ ] **VPC Service Controls**: 네트워크 격리
- [ ] **감사 로그**: 모든 활동 기록

---

## 비용 최적화 전략

### AWS S3 비용 최적화

#### 1. 스토리지 클래스 최적화
```bash
# 수명 주기 정책 설정
aws s3api put-bucket-lifecycle-configuration \
    --bucket my-bucket \
    --lifecycle-configuration file://lifecycle-policy.json

# 예시 정책
{
  "Rules": [
    {
      "ID": "TransitionToIA",
      "Status": "Enabled",
      "Transitions": [
        {
          "Days": 30,
          "StorageClass": "STANDARD_IA"
        }
      ]
    }
  ]
}
```

#### 2. 데이터 전송 최적화
- **CloudFront**: 자주 접근하는 콘텐츠
- **S3 Transfer Acceleration**: 글로벌 업로드
- **S3 Select**: 필요한 데이터만 다운로드

### GCP Cloud Storage 비용 최적화

#### 1. 스토리지 클래스 최적화
```bash
# 수명 주기 정책 설정
gsutil lifecycle set lifecycle-policy.json gs://my-bucket

# 예시 정책
{
  "rule": [
    {
      "action": {"type": "SetStorageClass", "storageClass": "NEARLINE"},
      "condition": {"age": 30}
    }
  ]
}
```

#### 2. 데이터 전송 최적화
- **Cloud CDN**: 글로벌 콘텐츠 배포
- **Parallel Composite Uploads**: 대용량 파일
- **Resumable Uploads**: 네트워크 중단 대응

---

## 실습 과제

### 기본 실습
1. **S3와 Cloud Storage 버킷 생성 및 비교**
2. **다양한 스토리지 클래스로 객체 저장**
3. **수명 주기 정책 설정 및 테스트**

### 고급 실습
1. **크로스 플랫폼 마이그레이션 실행**
2. **성능 벤치마크 및 최적화**
3. **보안 정책 구성 및 테스트**

---

## 다음 단계
- 네트워크 서비스 비교 (VPC)
- 데이터베이스 서비스 비교 (RDS vs Cloud SQL)
- Terraform을 사용한 인프라 코드화

---

## 참고 자료
- [AWS S3 사용자 가이드](https://docs.aws.amazon.com/s3/latest/userguide/)
- [GCP Cloud Storage 문서](https://cloud.google.com/storage/docs)
- [AWS S3 가격](https://aws.amazon.com/s3/pricing/)
- [GCP Cloud Storage 가격](https://cloud.google.com/storage/pricing)
- [S3에서 Cloud Storage로 마이그레이션](https://cloud.google.com/storage/docs/migrating)
