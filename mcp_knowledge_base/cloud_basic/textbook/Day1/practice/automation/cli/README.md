# Cloud 실습 자동화 스크립트

이 디렉토리에는 각 실습 가이드에 대한 자동화 스크립트와 환경 변수 파일이 포함되어 있습니다.

## 📁 파일 구조

```
cli/
├── README.md                           # 이 파일
├── 실습1_azure_finops.sh              # Azure FinOps 실습 자동화 스크립트
├── 실습1_azure_finops.env             # Azure FinOps 환경 변수
├── 실습2_gcp_static_website.sh        # GCP 정적 웹사이트 배포 자동화 스크립트
├── 실습2_gcp_static_website.env       # GCP 정적 웹사이트 환경 변수
├── 실습3_bigquery_analysis.sh         # BigQuery 서버리스 분석 자동화 스크립트
├── 실습3_bigquery_analysis.env        # BigQuery 분석 환경 변수
├── 실습4_aws_serverless.sh            # AWS 서버리스 시스템 자동화 스크립트
└── 실습4_aws_serverless.env           # AWS 서버리스 환경 변수
```

## 🚀 사용 방법

### 1. 사전 준비

각 실습을 실행하기 전에 다음 사항을 확인하세요:

#### Azure 실습 (실습1)
- Azure CLI 설치 및 로그인
- Azure 구독 권한
- `az login` 실행

#### GCP 실습 (실습2, 실습3)
- Google Cloud SDK 설치 및 로그인
- GCP 프로젝트 권한
- `gcloud auth login` 실행

#### AWS 실습 (실습4)
- AWS CLI 설치 및 구성
- AWS 계정 권한
- `aws configure` 실행

### 2. 스크립트 실행

각 실습 디렉토리에서 다음 명령어를 실행하세요:

```bash
# 1. 환경 변수 파일 복사
cp 실습1_azure_finops.env .env

# 2. 스크립트 실행 권한 부여
chmod +x 실습1_azure_finops.sh

# 3. 스크립트 실행
./실습1_azure_finops.sh
```

### 3. 환경 변수 설정

각 `.env` 파일을 편집하여 프로젝트에 맞는 값으로 수정하세요:

```bash
# 예시: 실습1_azure_finops.env
SUBSCRIPTION_NAME="your-subscription-name"
RESOURCE_GROUP_NAME="your-resource-group-name"
STORAGE_ACCOUNT_NAME="your-storage-account-name"
```

## 📋 실습별 상세 정보

### 실습1: Azure FinOps
- **목적**: Azure FinOps 환경 구축 및 비용 관리
- **주요 서비스**: Azure Storage, IAM, Cost Management, Policy
- **실행 시간**: 약 15-20분
- **비용**: 최소 비용 (스토리지 계정 생성)

### 실습2: GCP 정적 웹사이트
- **목적**: Cloud Storage를 활용한 정적 웹사이트 배포
- **주요 서비스**: Cloud Storage, IAM
- **실행 시간**: 약 10-15분
- **비용**: 최소 비용 (스토리지 사용량)

### 실습3: BigQuery 서버리스 분석
- **목적**: BigQuery를 활용한 데이터 분석 및 ML 모델 생성
- **주요 서비스**: BigQuery, Data Studio 연동
- **실행 시간**: 약 20-25분
- **비용**: 쿼리 처리량에 따른 비용

### 실습4: AWS 서버리스 시스템
- **목적**: AWS 서버리스 서비스를 활용한 투자 제안 심사 시스템
- **주요 서비스**: Lambda, API Gateway, DynamoDB, S3, Step Functions, SNS
- **실행 시간**: 약 30-40분
- **비용**: 서비스 사용량에 따른 비용

## ⚠️ 주의사항

1. **비용 관리**: 각 실습은 실제 클라우드 리소스를 생성하므로 비용이 발생할 수 있습니다.
2. **리소스 정리**: 실습 완료 후 불필요한 리소스는 삭제하세요.
3. **권한 확인**: 각 클라우드 플랫폼에 적절한 권한이 있는지 확인하세요.
4. **네트워크**: 안정적인 인터넷 연결이 필요합니다.

## 🧹 정리 스크립트

실습 완료 후 리소스를 정리하려면 다음 명령어를 사용하세요:

### Azure 리소스 정리
```bash
# 리소스 그룹 삭제
az group delete --name "RG-FinOps-Demo" --yes
```

### GCP 리소스 정리
```bash
# 프로젝트 삭제 (주의: 모든 리소스가 삭제됩니다)
gcloud projects delete "my-static-website"
```

### AWS 리소스 정리
```bash
# Lambda 함수 삭제
aws lambda delete-function --function-name proposal-upload
aws lambda delete-function --function-name proposal-analysis
aws lambda delete-function --function-name notification

# DynamoDB 테이블 삭제
aws dynamodb delete-table --table-name InvestmentProposals

# S3 버킷 삭제
aws s3 rb s3://investment-proposals-docs-YYYYMMDDHHMMSS --force
```

## 🆘 문제 해결

### 일반적인 오류

1. **권한 오류**
   - 클라우드 플랫폼에 로그인되어 있는지 확인
   - 적절한 권한이 있는지 확인

2. **리소스 이름 중복**
   - 환경 변수에서 고유한 이름으로 변경
   - 기존 리소스 삭제 후 재실행

3. **네트워크 오류**
   - 인터넷 연결 확인
   - 방화벽 설정 확인

### 로그 확인

각 스크립트는 상세한 로그를 출력합니다:
- `[INFO]`: 정보 메시지
- `[SUCCESS]`: 성공 메시지
- `[WARNING]`: 경고 메시지
- `[ERROR]`: 오류 메시지

## 📞 지원

문제가 발생하면 다음을 확인하세요:
1. 스크립트 로그 메시지
2. 클라우드 플랫폼 콘솔의 오류 메시지
3. 각 실습 가이드의 상세 설명

---

**Happy Cloud Learning! 🚀**
