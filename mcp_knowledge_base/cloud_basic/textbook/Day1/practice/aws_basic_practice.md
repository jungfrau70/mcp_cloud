# AWS 기초 실습 가이드

<div align="center">

[← 이전: Cloud Basic 메인](../README.md) | [📚 전체 커리큘럼](/curriculum.md) | [🏠 학습 경로로 돌아가기](/index.md) | [📋 학습 경로](../../../../learning-path.md)

</div>

<div align="center">

[← 이전: Cloud Basic 1일차 메인](../README.md) | [📚 전체 커리큘럼](/curriculum.md) | [🏠 학습 경로로 돌아가기](/index.md) | [다음: GCP 기초 실습 →](./gcp_basic_practice.md)

</div>

<details>
<summary>📋 목차</summary>

1. [🎯 학습 목표](#학습-목표)
2. [📚 실습 개요](#실습-개요)
3. [🔧 실습 환경 준비](#실습-환경-준비)
4. [🚀 1단계: AWS 계정 생성 및 설정](#1단계-aws-계정-생성-및-설정)
5. [👥 2단계: IAM 사용자 및 권한 관리](#2단계-iam-사용자-및-권한-관리)
6. [💻 3단계: EC2 인스턴스 생성 및 관리](#3단계-ec2-인스턴스-생성-및-관리)
7. [📦 4단계: S3 스토리지 서비스 활용](#4단계-s3-스토리지-서비스-활용)
8. [📚 문제 해결 및 참고 자료](#문제-해결-및-참고-자료)

</details>

---

## 🎯 학습 목표

<details>
<summary>📖 이번 실습에서 배우게 될 내용</summary>

### 핵심 학습 목표
- **AWS 계정 생성** 및 기본 설정 방법
- **IAM 사용자 및 권한** 관리 기초
- **EC2 인스턴스** 생성 및 관리
- **S3 스토리지** 서비스 활용

### 실습 후 달성할 수 있는 능력
- ✅ AWS Free Tier 계정 생성 및 설정
- ✅ IAM을 통한 사용자 및 권한 관리
- ✅ EC2 인스턴스 생성 및 SSH 접속
- ✅ S3 버킷 생성 및 파일 관리

### 예상 소요 시간
- **AWS 계정 생성**: 15-20분
- **IAM 설정**: 20-30분
- **EC2 실습**: 30-45분
- **S3 실습**: 20-30분
- **전체 과정**: 2-3시간

</details>

---

## 📚 실습 개요

<details>
<summary>📖 실습 개요</summary>

### 실습 목적
**AWS Free Tier를 활용한 기초 서비스 실습**

### 실습 범위
- AWS 계정 생성 및 설정
- IAM 사용자 및 권한 관리
- EC2 인스턴스 생성 및 관리
- S3 스토리지 서비스 활용

### 실습 환경
- **AWS Free Tier**: 12개월 무료 사용
- **지역**: Asia Pacific (Seoul) - ap-northeast-2
- **서비스**: EC2, S3, IAM

### 실습 결과물
- AWS 계정 및 IAM 사용자 설정
- EC2 인스턴스 실행 및 접속
- S3 버킷 및 파일 관리

</details>

---

## 🔧 실습 환경 준비

<details>
<summary>📋 필수 요구사항</summary>

### 필수 계정
- **이메일 주소**: AWS 계정 생성용
- **신용카드**: 인증용 (Free Tier 사용)
- **전화번호**: 인증용

### 필수 도구
- **웹 브라우저**: Chrome, Firefox, Safari 등
- **터미널/명령 프롬프트**: CLI 명령어 실행용
- **SSH 클라이언트**: EC2 인스턴스 접속용

### AWS CLI 설치 (선택사항)
```bash
# Windows
winget install Amazon.AWSCLI

# macOS
brew install awscli

# Ubuntu
sudo apt update
sudo apt install awscli
```

</details>

<details>
<summary>📋 실습 전 체크리스트</summary>

### 환경 확인
- [ ] 웹 브라우저가 최신 버전인가?
- [ ] 터미널/명령 프롬프트 사용 가능한가?
- [ ] SSH 클라이언트가 설치되어 있는가?

### 계정 준비
- [ ] 이메일 주소가 준비되어 있는가?
- [ ] 신용카드 정보가 준비되어 있는가?
- [ ] 전화번호가 준비되어 있는가?

</details>

---

## 🚀 1단계: AWS 계정 생성 및 설정

### 1.1 AWS 계정 생성

#### 🌐 웹콘솔 방식
```markdown
1. [AWS 홈페이지](https://aws.amazon.com) 접속
2. "AWS 계정 생성" 클릭
3. 이메일 주소, 비밀번호, 계정 이름 입력
4. 계정 유형: "개인" 선택
5. 신용카드 정보 등록 (Free Tier 사용)
6. 전화번호 인증 완료
7. 지원 플랜: "기본 지원 - 무료" 선택
8. 계정 생성 완료
```

#### 💻 CLI 방식
```bash
# AWS CLI 설치 (Windows)
winget install Amazon.AWSCLI

# AWS CLI 설치 (macOS)
brew install awscli

# AWS CLI 설치 (Ubuntu)
sudo apt update
sudo apt install awscli

# AWS CLI 설정
aws configure
# AWS Access Key ID: [입력]
# AWS Secret Access Key: [입력]
# Default region name: ap-northeast-2
# Default output format: json
```

### 1.2 AWS 콘솔 탐색

#### 🌐 웹콘솔 방식
```markdown
1. [AWS Management Console](https://console.aws.amazon.com) 접속
2. 주요 서비스 탐색:
   - EC2 (가상머신)
   - S3 (스토리지)
   - IAM (사용자 및 권한)
   - VPC (네트워킹)
   - RDS (데이터베이스)
3. 리전 변경: 서울(ap-northeast-2) 선택
```

---

## 👥 2단계: IAM 사용자 및 권한 관리

### 2.1 IAM 사용자 생성

#### 🌐 웹콘솔 방식
```markdown
1. AWS Console → "IAM" 검색
2. "사용자" → "사용자 추가" 클릭
3. 사용자 이름: "cloud-student"
4. 액세스 유형: "프로그래밍 방식 액세스" 선택
5. "다음: 권한" 클릭
6. "기존 정책 직접 연결" 선택
7. 권한 정책 선택:
   - AmazonEC2FullAccess
   - AmazonS3FullAccess
   - AmazonRDSFullAccess
8. "다음: 태그" → "다음: 검토" → "사용자 만들기"
9. 액세스 키 ID와 비밀 액세스 키 저장
```

#### 💻 CLI 방식
```bash
# IAM 사용자 생성
aws iam create-user --user-name cloud-student

# 사용자에게 정책 연결
aws iam attach-user-policy \
  --user-name cloud-student \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess

aws iam attach-user-policy \
  --user-name cloud-student \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

# 액세스 키 생성
aws iam create-access-key --user-name cloud-student

# 사용자 확인
aws iam list-users --output table
```

### 2.2 IAM 그룹 생성 및 사용자 추가

#### 💻 CLI 방식
```bash
# IAM 그룹 생성
aws iam create-group --group-name CloudStudents

# 그룹에 정책 연결
aws iam attach-group-policy \
  --group-name CloudStudents \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess

# 사용자를 그룹에 추가
aws iam add-user-to-group \
  --group-name CloudStudents \
  --user-name cloud-student

# 그룹 확인
aws iam get-group --group-name CloudStudents
```

---

## 💻 3단계: EC2 인스턴스 생성 및 관리

### 3.1 EC2 인스턴스 생성

#### 🌐 웹콘솔 방식
```markdown
1. AWS Console → "EC2" 검색
2. "인스턴스 시작" 클릭
3. AMI 선택: "Amazon Linux 2 AMI (HVM)" 선택
4. 인스턴스 유형: "t2.micro" (Free Tier)
5. "다음: 인스턴스 세부 정보 구성" 클릭
6. "다음: 스토리지 추가" 클릭
7. "다음: 태그 추가" 클릭
8. "다음: 보안 그룹 구성" 클릭
9. 보안 그룹 이름: "web-server-sg"
10. 규칙 추가:
    - SSH (22) - 내 IP
    - HTTP (80) - 어디서나
    - HTTPS (443) - 어디서나
11. "검토 및 시작" → "시작" 클릭
12. 키 페어 선택: "새 키 페어 생성"
13. 키 페어 이름: "cloud-student-key"
14. "인스턴스 시작" 클릭
```

#### 💻 CLI 방식
```bash
# 키 페어 생성
aws ec2 create-key-pair \
  --key-name cloud-student-key \
  --query 'KeyMaterial' \
  --output text > cloud-student-key.pem

# 키 파일 권한 설정
chmod 400 cloud-student-key.pem

# 보안 그룹 생성
aws ec2 create-security-group \
  --group-name web-server-sg \
  --description "Security group for web server"

# 보안 그룹 규칙 추가
aws ec2 authorize-security-group-ingress \
  --group-name web-server-sg \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-name web-server-sg \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

# EC2 인스턴스 시작
aws ec2 run-instances \
  --image-id ami-0c76973fbe0ee100c \
  --count 1 \
  --instance-type t2.micro \
  --key-name cloud-student-key \
  --security-groups web-server-sg \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=cloud-student-server}]'
```

### 3.2 EC2 인스턴스 접속

#### 💻 SSH 접속
```bash
# 인스턴스 IP 확인
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=cloud-student-server" \
  --query 'Reservations[*].Instances[*].PublicIpAddress' \
  --output text

# SSH 접속
ssh -i cloud-student-key.pem ec2-user@[인스턴스-IP]

# 웹 서버 설치 및 시작
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<h1>Hello from AWS EC2!</h1>" | sudo tee /var/www/html/index.html
```

---

## 🗂️ 4단계: S3 스토리지 서비스 활용

### 4.1 S3 버킷 생성

#### 🌐 웹콘솔 방식
```markdown
1. AWS Console → "S3" 검색
2. "버킷 만들기" 클릭
3. 버킷 이름: "cloud-student-bucket-[고유번호]"
4. 리전: "아시아 태평양(서울)"
5. "다음" 클릭
6. 버킷 버전 관리: "비활성화"
7. "다음" 클릭
8. 퍼블릭 액세스 차단: "모든 퍼블릭 액세스 차단 해제"
9. "다음" 클릭
10. "다음" 클릭
11. "버킷 만들기" 클릭
```

#### 💻 CLI 방식
```bash
# S3 버킷 생성
aws s3 mb s3://cloud-student-bucket-$(date +%s)

# 버킷 목록 확인
aws s3 ls

# 파일 업로드
echo "Hello from AWS S3!" > hello.txt
aws s3 cp hello.txt s3://cloud-student-bucket-[버킷명]/

# 파일 다운로드
aws s3 cp s3://cloud-student-bucket-[버킷명]/hello.txt downloaded-hello.txt

# 버킷 내용 확인
aws s3 ls s3://cloud-student-bucket-[버킷명]/
```

### 4.2 S3 정적 웹사이트 호스팅

#### 💻 CLI 방식
```bash
# HTML 파일 생성
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Cloud Student Website</title>
</head>
<body>
    <h1>Welcome to AWS S3 Static Website!</h1>
    <p>This website is hosted on Amazon S3.</p>
</body>
</html>
EOF

# HTML 파일 업로드
aws s3 cp index.html s3://cloud-student-bucket-[버킷명]/

# 정적 웹사이트 호스팅 활성화
aws s3 website s3://cloud-student-bucket-[버킷명]/ \
  --index-document index.html \
  --error-document index.html

# 웹사이트 URL 확인
echo "Website URL: http://cloud-student-bucket-[버킷명].s3-website.ap-northeast-2.amazonaws.com"
```

---

## 🧪 5단계: 실습 테스트

### 5.1 EC2 웹서버 테스트

```bash
# EC2 인스턴스 IP 확인
INSTANCE_IP=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=cloud-student-server" \
  --query 'Reservations[*].Instances[*].PublicIpAddress' \
  --output text)

# 웹서버 접속 테스트
curl http://$INSTANCE_IP
```

### 5.2 S3 정적 웹사이트 테스트

```bash
# S3 웹사이트 URL로 접속 테스트
curl http://cloud-student-bucket-[버킷명].s3-website.ap-northeast-2.amazonaws.com
```

---

## 🧹 6단계: 리소스 정리

### 6.1 EC2 리소스 정리

```bash
# 인스턴스 ID 확인
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=cloud-student-server" \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --output text)

# 인스턴스 종료
aws ec2 terminate-instances --instance-ids $INSTANCE_ID

# 보안 그룹 삭제
aws ec2 delete-security-group --group-name web-server-sg

# 키 페어 삭제
aws ec2 delete-key-pair --key-name cloud-student-key
rm cloud-student-key.pem
```

### 6.2 S3 리소스 정리

```bash
# S3 버킷 내용 삭제
aws s3 rm s3://cloud-student-bucket-[버킷명]/ --recursive

# S3 버킷 삭제
aws s3 rb s3://cloud-student-bucket-[버킷명]
```

---

## ✅ 실습 완료 체크리스트

- [ ] AWS 계정 생성 및 Free Tier 활성화
- [ ] IAM 사용자 생성 및 권한 설정
- [ ] EC2 인스턴스 생성 및 SSH 접속
- [ ] S3 버킷 생성 및 파일 업로드/다운로드
- [ ] 정적 웹사이트 호스팅 설정
- [ ] 리소스 정리 완료

---

## 🎯 학습 포인트

### AWS 기초 개념
- AWS 계정 구조 및 Free Tier 활용
- IAM을 통한 사용자 및 권한 관리
- EC2를 통한 가상머신 관리
- S3를 통한 객체 스토리지 활용

### 실무 적용
- AWS CLI를 통한 자동화된 리소스 관리
- 보안 그룹을 통한 네트워크 보안 설정
- S3 정적 웹사이트 호스팅 활용
- 비용 최적화를 위한 리소스 정리

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
<summary>❌ IAM 사용자 생성 실패</summary>

**원인**:
- 권한 부족
- 정책 ARN 오류
- 사용자 이름 중복

**해결방법**:
```bash
# 1. 현재 사용자 확인
aws sts get-caller-identity

# 2. IAM 권한 확인
aws iam list-attached-user-policies --user-name cloud-student

# 3. 사용자 목록 확인
aws iam list-users
```

</details>

### EC2 관련 문제
<details>
<summary>❌ EC2 인스턴스 시작 실패</summary>

**원인**:
- 키 페어 없음
- 보안 그룹 설정 오류
- 서브넷 설정 오류

**해결방법**:
```bash
# 1. 키 페어 확인
aws ec2 describe-key-pairs

# 2. 보안 그룹 확인
aws ec2 describe-security-groups

# 3. 서브넷 확인
aws ec2 describe-subnets
```

</details>

<details>
<summary>❌ SSH 접속 실패</summary>

**원인**:
- 키 페어 파일 권한 오류
- 보안 그룹 SSH 포트 미개방
- 인스턴스 상태 문제

**해결방법**:
```bash
# 1. 키 페어 파일 권한 설정
chmod 400 my-key.pem

# 2. 보안 그룹 확인
aws ec2 describe-security-groups --group-ids sg-xxxxxxxx

# 3. 인스턴스 상태 확인
aws ec2 describe-instances --instance-ids i-xxxxxxxx
```

</details>

### S3 관련 문제
<details>
<summary>❌ S3 버킷 생성 실패</summary>

**원인**:
- 버킷 이름 중복
- 권한 부족
- 지역 설정 오류

**해결방법**:
```bash
# 1. 버킷 이름 확인
aws s3 ls

# 2. 권한 확인
aws iam get-user

# 3. 지역 설정 확인
aws configure get region
```

</details>

</details>

<details>
<summary>📖 추가 학습 자료</summary>

### 공식 문서
- [AWS 공식 문서](https://docs.aws.amazon.com/)
- [AWS Free Tier](https://aws.amazon.com/free/)
- [AWS CLI 공식 문서](https://docs.aws.amazon.com/cli/)
- [AWS EC2 공식 문서](https://docs.aws.amazon.com/ec2/)
- [AWS S3 공식 문서](https://docs.aws.amazon.com/s3/)

### 유용한 리소스
- [AWS 서비스 카탈로그](https://aws.amazon.com/products/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [AWS 보안 모범 사례](https://aws.amazon.com/security/security-resources/)

### 관련 프로젝트
- [AWS 샘플 프로젝트](https://github.com/aws-samples)
- [AWS Workshop](https://workshops.aws/)

</details>

<details>
<summary>🚀 다음 단계</summary>

### Cloud Basic 과정 계속
1. **GCP 기초 실습**: [GCP 기초 실습 가이드](./gcp_basic_practice.md)
2. **통합 실습**: [AWS & GCP 통합 실습](./실습1_aws_gcp.md)
3. **2일차 실습**: 네트워킹, 보안, 데이터베이스

### Cloud Intermediate 과정 준비
1. **Docker 기초**: 컨테이너 기술 학습
2. **Git/GitHub**: 버전 관리 및 협업
3. **GitHub Actions**: CI/CD 파이프라인

</details>

---

## 🎉 실습 완료!

축하합니다! AWS 기초 실습을 완료했습니다.

### 📚 학습 요약

이번 실습을 통해 다음을 배웠습니다:

1. **🏗️ AWS 계정 생성**: Free Tier 계정 생성 및 설정
2. **👥 IAM 관리**: 사용자 생성 및 권한 설정
3. **💻 EC2 실습**: 인스턴스 생성 및 SSH 접속
4. **📦 S3 실습**: 버킷 생성 및 파일 관리

### 🚀 다음 단계

- **GCP 기초 실습**: [GCP 기초 실습 가이드](./gcp_basic_practice.md)
- **통합 실습**: [AWS & GCP 통합 실습](./실습1_aws_gcp.md)
- **2일차 실습**: 네트워킹, 보안, 데이터베이스

### 💡 추가 학습 아이디어

1. **CloudFormation**: 인프라를 코드로 관리
2. **CloudWatch**: 모니터링 및 로깅
3. **Route 53**: DNS 관리
4. **Lambda**: 서버리스 컴퓨팅
5. **RDS**: 관리형 데이터베이스 서비스

---

**🎯 이제 AWS 기초 서비스의 기본기를 갖추었습니다! GCP 실습으로 진행하세요.**
