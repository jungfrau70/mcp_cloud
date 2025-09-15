# Cloud Basic - 1일차: AWS & GCP 기초 서비스 실습

<div align="center">

[← 이전: Cloud Basic 1일차 메인](../README.md) | [다음: Cloud Basic 2일차 →](../Day2/README.md) | [📚 전체 커리큘럼](../curriculum.md) | [🏠 학습 경로로 돌아가기](../index.md) | [📋 학습 경로](../learning-path.md)

</div>

<details>
<summary>📋 목차</summary>

1. [🎯 학습 목표](#학습-목표)
2. [📚 실습 가이드](#실습-가이드)
3. [🔧 실습 환경 준비](#실습-환경-준비)
4. [🚀 클라우드 개념 및 계정 생성](#클라우드-개념-및-계정-생성)
5. [🔐 IAM 기초 실습](#iam-기초-실습)
6. [💻 가상머신 서비스 기초](#가상머신-서비스-기초)
7. [📦 스토리지 서비스 기초](#스토리지-서비스-기초)
8. [📚 문제 해결 및 참고 자료](#문제-해결-및-참고-자료)

</details>

---

## 🎯 학습 목표

<details>
<summary>📖 이번 실습에서 배우게 될 내용</summary>

### 핵심 학습 목표
- **클라우드 컴퓨팅** 기본 개념 이해
- **AWS와 GCP** 서비스 개요 및 비교
- **IAM** 사용자 및 권한 관리 기초
- **가상머신, 스토리지** 서비스 기본 활용

### 실습 후 달성할 수 있는 능력
- ✅ AWS/GCP 계정 생성 및 기본 설정
- ✅ IAM을 통한 사용자 및 권한 관리
- ✅ EC2/Compute Engine 인스턴스 생성 및 관리
- ✅ S3/Cloud Storage 버킷 생성 및 파일 관리

### 예상 소요 시간
- **기본 실습**: 60-90분
- **고급 실습**: 120-150분
- **전체 과정**: 3-4시간

</details>

---

## 📚 실습 가이드

<details>
<summary>📖 실습 가이드 개요</summary>

### 실습 구성
1. **클라우드 개념 및 계정 생성** (30분)
2. **IAM 기초 실습** (45분)
3. **가상머신 서비스 기초** (60분)
4. **스토리지 서비스 기초** (45분)

### 실습 방식
- **웹 콘솔**: GUI를 통한 직관적 학습
- **CLI 명령어**: 명령줄을 통한 자동화 학습
- **비교 실습**: AWS와 GCP 동시 실습

### 실습 결과물
- AWS/GCP 계정 설정 완료
- IAM 사용자 및 권한 구성
- EC2/Compute Engine 인스턴스 실행
- S3/Cloud Storage 버킷 및 파일 관리

</details>

<details>
<summary>🔗 관련 실습 가이드</summary>

### 📖 상세 실습 가이드
- 🔗 [AWS 기초 실습 가이드](practice/aws_basic_practice.md)
- 🔗 [GCP 기초 실습 가이드](practice/gcp_basic_practice.md)
- 🔗 [통합 실습 가이드](practice/실습1_aws_gcp.md)

### 📚 개념 학습 가이드
- 🔗 [클라우드 계정 설정 가이드](./aws-gcp-account-setup.md)
- 🔗 [IAM 기초 가이드](./iam-basics-guide.md)
- 🔗 [가상머신 서비스 가이드](./vm-services-guide.md)
- 🔗 [스토리지 서비스 가이드](./storage-services-guide.md)

### 🛠️ 문제 해결 가이드
- 🔗 [트러블슈팅 가이드](./troubleshooting-guide.md)

### 🔗 관련 과정 링크
- 🔗 [Cloud Master 과정](../../../cloud_master/textbook/Day1/README.md) - Docker, CI/CD 심화 과정
- 🔗 [Cloud Container 과정](../../../cloud_container/textbook/Day1/README.md) - Kubernetes 고급 과정
- 🔗 [전체 커리큘럼](../curriculum.md) - 전체 과정 구조 및 학습 경로
- 🔗 [통합 인덱스](../index.md) - 전체 과정 인덱스
- 🔗 [학습 경로로 돌아가기](../learning-path.md) - Cloud Basic 학습 경로

---

## 🔧 실습 환경 준비

<details>
<summary>📋 필수 계정 및 도구</summary>

### 필수 계정
- **AWS 계정**: Free Tier 계정 생성
- **GCP 계정**: $300 크레딧 활성화
- **이메일 주소**: 계정 생성용
- **신용카드**: 인증용 (Free Tier 사용)

### 필수 도구
- **웹 브라우저**: Chrome, Firefox, Safari 등
- **터미널/명령 프롬프트**: CLI 명령어 실행용
- **SSH 클라이언트**: 가상머신 접속용

</details>

<details>
<summary>🔧 CLI 도구 설치</summary>

### AWS CLI 설치
```bash
# Windows
winget install Amazon.AWSCLI

# macOS
brew install awscli

# Ubuntu
sudo apt install awscli
```

### Google Cloud SDK 설치
```bash
# Windows
winget install Google.CloudSDK

# macOS
brew install google-cloud-sdk

# Ubuntu
curl https://sdk.cloud.google.com | bash
```

### 설치 확인
```bash
# AWS CLI 버전 확인
aws --version

# gcloud 버전 확인
gcloud --version
```

</details>

---

## 🚀 클라우드 개념 및 계정 생성

### 📚 이론: 클라우드 컴퓨팅 기초

#### 클라우드 컴퓨팅의 핵심 개념
- **정의**: 인터넷을 통해 컴퓨팅 리소스를 제공하는 서비스 모델
- **5가지 필수 특성**: 온디맨드 셀프 서비스, 광범위한 네트워크 접근, 리소스 풀링, 신속한 확장성, 측정 가능한 서비스
- **3가지 서비스 모델**: IaaS(인프라), PaaS(플랫폼), SaaS(소프트웨어)
- **4가지 배포 모델**: 퍼블릭, 프라이빗, 하이브리드, 커뮤니티 클라우드

#### 클라우드의 장점과 도전과제
- **장점**: 비용 절감, 확장성, 유연성, 접근성, 자동화
- **도전과제**: 보안, 네트워크 의존성, 벤더 락인, 성능 변동성
- **비용 모델**: 종량제(Pay-as-you-go), 예약 인스턴스, 스팟 인스턴스

<details>
<summary>📖 클라우드 컴퓨팅 개요</summary>

### 클라우드 컴퓨팅이란?
- **정의**: 인터넷을 통해 컴퓨팅 리소스를 제공하는 서비스
- **특징**: 온디맨드, 확장성, 유연성, 비용 효율성
- **서비스 모델**: IaaS, PaaS, SaaS

### AWS vs GCP 비교
| 구분 | AWS | GCP |
|------|-----|-----|
| **시장 점유율** | 1위 (32%) | 3위 (9%) |
| **강점** | 서비스 다양성, 생태계 | AI/ML, 데이터 분석 |
| **Free Tier** | 12개월 무료 | $300 크레딧 |
| **리전** | 25개 리전 | 24개 리전 |

</details>

<details>
<summary>🔗 AWS 계정 생성</summary>

### 1단계: AWS 계정 생성
1. [AWS 홈페이지](https://aws.amazon.com) 접속
2. "AWS 계정 생성" 클릭
3. 이메일 주소, 비밀번호, 계정 이름 입력
4. 계정 유형: "개인" 선택
5. 신용카드 정보 등록 (Free Tier 사용)
6. 전화번호 인증 완료
7. 지원 플랜: "기본 지원 - 무료" 선택
8. 계정 생성 완료

### 2단계: AWS CLI 설정
```bash
# AWS CLI 설정
aws configure
# AWS Access Key ID: [입력]
# AWS Secret Access Key: [입력]
# Default region name: ap-northeast-2
# Default output format: json
```

### 3단계: AWS 콘솔 탐색
- **서비스 카탈로그**: 200+ 서비스 탐색
- **리소스 그룹**: 리소스 관리
- **비용 관리**: Free Tier 사용량 확인

</details>

<details>
<summary>🔗 GCP 계정 생성</summary>

### 1단계: GCP 계정 생성
1. [GCP 홈페이지](https://cloud.google.com) 접속
2. "무료로 시작하기" 클릭
3. Google 계정으로 로그인
4. $300 크레딧 활성화
5. 결제 정보 등록 (크레딧 사용)
6. 프로젝트 생성

### 2단계: gcloud 초기화
```bash
# gcloud 초기화
gcloud init

# 프로젝트 설정
gcloud config set project YOUR_PROJECT_ID
```

### 3단계: GCP 콘솔 탐색
- **서비스 카탈로그**: 100+ 서비스 탐색
- **프로젝트 관리**: 리소스 격리
- **빌링**: 크레딧 사용량 확인

</details>

---

## 🔐 IAM 기초 실습

### 📚 이론: 클라우드 보안 및 접근 제어

#### IAM의 핵심 개념
- **정의**: Identity and Access Management, 사용자와 리소스에 대한 접근을 제어하는 서비스
- **4가지 핵심 요소**: 사용자(Users), 그룹(Groups), 역할(Roles), 정책(Policies)
- **최소 권한 원칙**: 사용자가 작업을 수행하는데 필요한 최소한의 권한만 부여
- **공유 책임 모델**: 클라우드 제공자와 고객 간의 보안 책임 분담

#### 인증과 인가의 차이
- **인증(Authentication)**: "당신이 누구인가?" - 신원 확인
- **인가(Authorization)**: "당신이 무엇을 할 수 있는가?" - 권한 확인
- **MFA**: 다중 인증 요소를 통한 보안 강화
- **SSO**: 단일 로그인으로 여러 서비스 접근

#### AWS vs GCP IAM 비교
- **AWS IAM**: 사용자 중심, 세밀한 권한 제어, 정책 기반
- **GCP IAM**: 프로젝트 중심, 역할 기반, 조직 정책 지원

<details>
<summary>📖 IAM 개념 이해</summary>

### AWS IAM
- **Identity and Access Management**: 사용자, 그룹, 역할, 정책 관리
- **최소 권한 원칙**: 필요한 권한만 부여
- **MFA**: 다중 인증으로 보안 강화

### GCP IAM
- **Identity and Access Management**: 서비스 계정, 역할, 권한 관리
- **조직 정책**: 중앙 집중식 권한 관리
- **서비스 계정**: 애플리케이션용 계정

</details>

<details>
<summary>🔗 AWS IAM 실습</summary>

### 1단계: IAM 사용자 생성
```bash
# IAM 사용자 생성
aws iam create-user --user-name student-user

# 사용자 그룹 생성
aws iam create-group --group-name students

# 사용자를 그룹에 추가
aws iam add-user-to-group --user-name student-user --group-name students
```

### 2단계: 권한 정책 생성
```bash
# 정책 생성
aws iam create-policy --policy-name StudentPolicy --policy-document file://student-policy.json

# 그룹에 정책 연결
aws iam attach-group-policy --group-name students --policy-arn arn:aws:iam::ACCOUNT:policy/StudentPolicy
```

### 3단계: MFA 설정
1. AWS 콘솔 → IAM → 사용자
2. "보안 자격 증명" 탭
3. "MFA 할당" 클릭
4. 가상 MFA 디바이스 설정

</details>

<details>
<summary>🔗 GCP IAM 실습</summary>

### 1단계: 서비스 계정 생성
```bash
# 서비스 계정 생성
gcloud iam service-accounts create student-service-account \
    --display-name="Student Service Account" \
    --description="Service account for student practice"
```

### 2단계: 역할 부여
```bash
# Compute Instance Admin 역할 부여
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:student-service-account@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/compute.instanceAdmin"
```

### 3단계: 서비스 계정 키 생성
```bash
# JSON 키 파일 생성
gcloud iam service-accounts keys create student-key.json \
    --iam-account=student-service-account@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

</details>

---

## 💻 가상머신 서비스 기초

<details>
<summary>📖 가상머신 서비스 비교</summary>

### AWS EC2 vs GCP Compute Engine
| 구분 | AWS EC2 | GCP Compute Engine |
|------|---------|-------------------|
| **인스턴스 타입** | t3, m5, c5 등 | e2, n2, c2 등 |
| **이미지** | AMI (Amazon Machine Image) | 이미지 패밀리 |
| **스토리지** | EBS (Elastic Block Store) | 영구 디스크 |
| **네트워킹** | VPC, 서브넷 | VPC, 서브넷 |

### 인스턴스 타입 선택
- **t3.micro**: 무료 티어, 개발/테스트용
- **e2-medium**: 일반적인 웹 애플리케이션
- **c2-standard-4**: CPU 집약적 작업

</details>

<details>
<summary>🔗 AWS EC2 실습</summary>

### 1단계: EC2 인스턴스 생성
```bash
# EC2 인스턴스 생성
aws ec2 run-instances \
    --image-id ami-0ae2c887094315bed \
    --count 1 \
    --instance-type t3.micro \
    --key-name student-key \
    --security-group-ids sg-xxxxxxxx \
    --subnet-id subnet-xxxxxxxx
```

### 2단계: 인스턴스 상태 확인
```bash
# 인스턴스 상태 확인
aws ec2 describe-instances \
    --filters "Name=instance-type,Values=t3.micro" \
    --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]'
```

### 3단계: SSH 접속
```bash
# SSH 접속
ssh -i student-key.pem ec2-user@YOUR_EC2_PUBLIC_IP
```

</details>

<details>
<summary>🔗 GCP Compute Engine 실습</summary>

### 1단계: Compute Engine 인스턴스 생성
```bash
# 인스턴스 생성
gcloud compute instances create student-instance \
    --zone=asia-northeast3-a \
    --machine-type=e2-medium \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=10GB
```

### 2단계: 인스턴스 상태 확인
```bash
# 인스턴스 목록 확인
gcloud compute instances list

# 인스턴스 상세 정보
gcloud compute instances describe student-instance --zone=asia-northeast3-a
```

### 3단계: SSH 접속
```bash
# SSH 접속
gcloud compute ssh student-instance --zone=asia-northeast3-a
```

</details>

---

## 📦 스토리지 서비스 기초

<details>
<summary>📖 스토리지 서비스 비교</summary>

### AWS S3 vs GCP Cloud Storage
| 구분 | AWS S3 | GCP Cloud Storage |
|------|--------|-------------------|
| **스토리지 클래스** | Standard, IA, Glacier | Standard, Nearline, Coldline |
| **버킷 이름** | 전역 고유 | 프로젝트 내 고유 |
| **액세스 제어** | 버킷 정책, ACL | IAM, ACL |
| **가격** | 사용량 기반 | 사용량 기반 |

### 스토리지 클래스 선택
- **Standard**: 자주 접근하는 데이터
- **IA (Infrequent Access)**: 가끔 접근하는 데이터
- **Glacier**: 장기 보관 데이터

</details>

<details>
<summary>🔗 AWS S3 실습</summary>

### 1단계: S3 버킷 생성
```bash
# S3 버킷 생성
aws s3 mb s3://student-bucket-$(date +%s)

# 버킷 목록 확인
aws s3 ls
```

### 2단계: 파일 업로드/다운로드
```bash
# 파일 업로드
aws s3 cp local-file.txt s3://student-bucket-123456789/

# 파일 다운로드
aws s3 cp s3://student-bucket-123456789/local-file.txt downloaded-file.txt

# 디렉토리 동기화
aws s3 sync ./local-directory s3://student-bucket-123456789/
```

### 3단계: 버킷 정책 설정
```bash
# 버킷 정책 생성
aws s3api put-bucket-policy --bucket student-bucket-123456789 --policy file://bucket-policy.json
```

</details>

<details>
<summary>🔗 GCP Cloud Storage 실습</summary>

### 1단계: Cloud Storage 버킷 생성
```bash
# 버킷 생성
gsutil mb gs://student-bucket-$(date +%s)

# 버킷 목록 확인
gsutil ls
```

### 2단계: 파일 업로드/다운로드
```bash
# 파일 업로드
gsutil cp local-file.txt gs://student-bucket-123456789/

# 파일 다운로드
gsutil cp gs://student-bucket-123456789/local-file.txt downloaded-file.txt

# 디렉토리 동기화
gsutil -m rsync -r ./local-directory gs://student-bucket-123456789/
```

### 3단계: 버킷 권한 설정
```bash
# 버킷 권한 설정
gsutil iam ch allUsers:objectViewer gs://student-bucket-123456789
```

</details>

---

## 📚 문제 해결 및 참고 자료

<details>
<summary>🐛 자주 발생하는 문제</summary>

### 계정 생성 관련 문제
<details>
<summary>❌ AWS 계정 생성 실패</summary>

**원인**: 
- 이메일 주소 중복
- 신용카드 정보 오류
- 전화번호 인증 실패

**해결방법**:
1. 다른 이메일 주소 사용
2. 신용카드 정보 재확인
3. 전화번호 형식 확인

</details>

<details>
<summary>❌ GCP 크레딧 활성화 실패</summary>

**원인**:
- 결제 정보 미등록
- 지역 제한
- 계정 상태 문제

**해결방법**:
1. 결제 정보 등록 확인
2. 지원되는 지역에서 접속
3. 계정 상태 확인

</details>

### CLI 관련 문제
<details>
<summary>❌ AWS CLI 인증 실패</summary>

**원인**:
- Access Key ID/Secret Key 오류
- 권한 부족
- 리전 설정 오류

**해결방법**:
```bash
# 1. 자격 증명 재설정
aws configure

# 2. 권한 확인
aws sts get-caller-identity

# 3. 리전 확인
aws configure get region
```

</details>

<details>
<summary>❌ gcloud 인증 실패</summary>

**원인**:
- 서비스 계정 키 오류
- 프로젝트 ID 오류
- 권한 부족

**해결방법**:
```bash
# 1. 인증 재설정
gcloud auth login

# 2. 프로젝트 설정
gcloud config set project YOUR_PROJECT_ID

# 3. 서비스 계정 키 설정
gcloud auth activate-service-account --key-file=student-key.json
```

</details>

</details>

<details>
<summary>📖 추가 학습 자료</summary>

### 공식 문서
- [AWS 공식 문서](https://docs.aws.amazon.com/)
- [GCP 공식 문서](https://cloud.google.com/docs)
- [AWS CLI 공식 문서](https://docs.aws.amazon.com/cli/)
- [gcloud CLI 공식 문서](https://cloud.google.com/sdk/docs)

### 유용한 리소스
- [AWS Free Tier](https://aws.amazon.com/free/)
- [GCP Free Tier](https://cloud.google.com/free)
- [AWS 서비스 카탈로그](https://aws.amazon.com/products/)
- [GCP 서비스 카탈로그](https://cloud.google.com/products)

### 관련 프로젝트
- [AWS 샘플 프로젝트](https://github.com/aws-samples)
- [GCP 샘플 프로젝트](https://github.com/GoogleCloudPlatform)

</details>

<details>
<summary>🚀 다음 단계</summary>

### 2일차 준비
1. **네트워킹 기초**: VPC, 서브넷, 라우팅
2. **보안 그룹**: Security Groups, Firewall Rules
3. **데이터베이스**: RDS, Cloud SQL
4. **종합 실습**: 웹 애플리케이션 배포

### 고급 기능
1. **자동화**: Terraform, CloudFormation
2. **모니터링**: CloudWatch, Cloud Monitoring
3. **보안**: IAM 고급 기능, 암호화
4. **비용 최적화**: 비용 분석, 예산 설정

</details>

---

## 🎉 완료!

축하합니다! Cloud Basic 1일차 실습을 완료했습니다.

### 📚 학습 요약

이번 실습을 통해 다음을 배웠습니다:

1. **☁️ 클라우드 개념**: AWS와 GCP 서비스 개요 및 비교
2. **🔐 IAM 기초**: 사용자, 그룹, 역할, 정책 관리
3. **💻 가상머신**: EC2와 Compute Engine 인스턴스 생성 및 관리
4. **📦 스토리지**: S3와 Cloud Storage 버킷 생성 및 파일 관리

### 🚀 다음 단계

- **2일차 실습**: 네트워킹, 보안, 데이터베이스 실습
- **실제 프로젝트 적용**: 자신의 프로젝트에 클라우드 서비스 적용
- **고급 기능 학습**: 자동화, 모니터링, 보안 강화

### 💡 추가 학습 자료

- [AWS 공식 문서](https://docs.aws.amazon.com/)
- [GCP 공식 문서](https://cloud.google.com/docs)
- [Cloud Basic 2일차 실습](../Day2/README.md)

---

**🎯 이제 클라우드 기초 서비스의 기본기를 갖추었습니다! 2일차 실습으로 진행하세요.**

<div align="center">

[← 이전 과정 없음] | [📚 전체 커리큘럼](../curriculum.md) | [🏠 학습 경로로 돌아가기](../index.md) | [다음 과정: Cloud Master 1일차 →](../../../cloud_master/textbook/Day1/README.md)

</div>