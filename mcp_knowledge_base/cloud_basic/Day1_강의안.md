# Cloud Basic - 1일차 강의안

> 📋 **강의 일시**: 2024년 9월 2일 ["월"] 9:00~17:00  
> 📋 **강의 방식**: 오프라인 실습 중심  
> 📋 **선수 학습**: IT 기초 지식 ["OS, 네트워크 기본 이해"]
> 📋 **WSL 환경설정**: [mcp_knowledge_base/cloud_basic/_setup_wsl/README.md](_setup_wsl/README.md)
> 📋 **실습 코드**: `git clone https://github.com/jungfrau70/cloud-basic.git cloud_basic`

---

## 🎯 1일차 학습 목표

### 핵심 목표
- **클라우드 기본 개념**: 클라우드 컴퓨팅의 핵심 개념과 장점 이해
- **AWS 계정 생성**: AWS Free Tier 계정 생성 및 기본 설정
- **GCP 계정 생성**: GCP 계정 생성 및 $300 크레딧 활성화
- **EC2 실습**: AWS EC2 인스턴스 생성 및 SSH 접속
- **S3 실습**: AWS S3 버킷 생성 및 파일 관리
- **Compute Engine 실습**: GCP Compute Engine 인스턴스 생성 및 접속
- **Cloud Storage 실습**: GCP Cloud Storage 버킷 생성 및 파일 관리

### 실습 후 달성할 수 있는 능력
- ✅ 클라우드 컴퓨팅의 기본 개념 설명
- ✅ AWS와 GCP 계정 생성 및 설정
- ✅ 가상머신 인스턴스 생성 및 관리
- ✅ 객체 스토리지 서비스 활용
- ✅ 기본적인 클라우드 서비스 사용법 습득

### 예상 소요 시간
- **클라우드 개념 이해**: 60분
- **계정 생성 및 설정**: 120분
- **AWS 서비스 실습**: 120분
- **GCP 서비스 실습**: 120분
- **전체 과정**: 7시간

---

## ⚠️ 실습 전 필수 준비사항

### 🔧 **사전 요구사항 확인**
```bash
# 1. 필수 도구 설치 확인
echo "=== 필수 도구 확인 ==="
command -v aws && echo "✅ AWS CLI 설치됨" || echo "❌ AWS CLI 설치 필요"
command -v gcloud && echo "✅ GCP CLI 설치됨" || echo "❌ GCP CLI 설치 필요"
command -v ssh && echo "✅ SSH 클라이언트 설치됨" || echo "❌ SSH 클라이언트 설치 필요"

# 2. 인터넷 연결 확인
echo "=== 인터넷 연결 확인 ==="
ping -c 3 google.com && echo "✅ 인터넷 연결 정상" || echo "❌ 인터넷 연결 확인 필요"

# 3. 브라우저 확인
echo "=== 브라우저 확인 ==="
echo "다음 브라우저 중 하나가 필요합니다:"
echo "- Chrome ["권장"]"
echo "- Firefox"
echo "- Edge"
echo "- Safari"
```

### 📋 **실습 전 체크리스트**
- [ ] **인터넷 연결**: 안정적인 인터넷 연결 확인
- [ ] **신용카드**: AWS/GCP 계정 생성용 신용카드 준비
- [ ] **이메일 계정**: 계정 생성용 이메일 주소 준비
- [ ] **전화번호**: 2단계 인증용 전화번호 준비
- [ ] **브라우저**: 최신 브라우저 설치 및 업데이트
- [ ] **SSH 클라이언트**: PuTTY [Windows] 또는 기본 터미널 [Mac/Linux]

## 📁 **1일차 강의 자료 구조**

### **새로운 디렉토리 구조**
```
cloud_basic/automation/day1/
├── automation/          # 자동화 스크립트
│   ├── 01-aws-setup.sh
│   ├── 02-gcp-setup.sh
│   ├── 03-ec2-practice.sh
│   ├── 04-s3-practice.sh
│   ├── 05-compute-practice.sh
│   ├── 06-storage-practice.sh
│   └── 07-environment-check.sh
├── samples/             # 실습 코드
│   ├── aws-samples/
│   ├── gcp-samples/
│   └── web-app/
├── docs/                # 문서 및 가이드
│   ├── aws-setup-guide.md
│   ├── gcp-setup-guide.md
│   └── troubleshooting.md
└── scripts/             # 유틸리티 스크립트
    └── environment-check.sh
```

---

## 🕘 1교시: 클라우드 기본 개념 및 계정 생성 [9:00~10:30]

### 📚 이론 학습 ["30분"]
#### 클라우드 컴퓨팅 개념
- **클라우드 컴퓨팅**: 인터넷을 통한 컴퓨팅 리소스 제공
- **서비스 모델**: IaaS, PaaS, SaaS
- **배포 모델**: Public, Private, Hybrid, Multi-Cloud
- **주요 장점**: 확장성, 유연성, 비용 효율성, 관리 편의성

#### AWS vs GCP 비교
- **AWS**: 시장 점유율 1위, 서비스 다양성, 엔터프라이즈 중심
- **GCP**: Google 기술력, AI/ML 강점, 개발자 친화적
- **서비스 매핑**: EC2 ↔ Compute Engine, S3 ↔ Cloud Storage

### 🛠️ 실습 ["60분"]

#### 🏗️ **1단계: AWS 계정 생성 및 설정**

**목표 아키텍처 ["1단계 완료 후"]**
```mermaid
flowchart TB
    subgraph "AWS Cloud"
        A1["AWS 계정<br/>Free Tier"]
        A2["IAM 사용자<br/>실습용"]
        A3["보안 설정<br/>MFA 활성화"]
        A4["AWS CLI<br/>로컬 설정"]
    end
    
    subgraph "Local"
        L1["개발자 머신<br/>AWS CLI"]
    end
    
    L1 -->> A4
    A4 -->> A1
    A1 -->> A2
    A1 -->> A3
```

**🔍 명령 실행: AWS 계정 생성 및 설정**
```bash
# 자동화 스크립트 실행
echo "=== AWS 계정 생성 및 설정 시작 ==="
cloud_basic/automation/day1/automation/01-aws-setup.sh setup

# 또는 수동 실행 ["참고용"]
echo "=== 수동 AWS 계정 생성 및 설정 ==="
# 1. AWS 계정 생성 ["브라우저에서 실행"]
echo "AWS 계정 생성: https://aws.amazon.com/"
echo "1. 이메일 주소 입력"
echo "2. 계정 이름 입력"
echo "3. 비밀번호 설정"
echo "4. 신용카드 정보 입력"
echo "5. 전화번호 인증"
echo "6. 지원 플랜 선택 [Basic Support - Free]"

# 2. AWS CLI 설치 확인
aws --version

# 3. AWS CLI 설정
aws configure
# AWS Access Key ID: ["입력"]
# AWS Secret Access Key: ["입력"]
# Default region name: ap-northeast-2
# Default output format: json

# 4. 설정 확인
aws sts get-caller-identity
```

**✅ 예상 결과:**
- AWS 계정: Free Tier 활성화
- IAM 사용자: 실습용 사용자 생성
- AWS CLI: 로컬 환경 설정 완료
- 인증: AWS 서비스 접근 가능

**🌐 콘솔에서 확인:**
- AWS Management Console: https://console.aws.amazon.com/

#### 🏗️ **2단계: GCP 계정 생성 및 설정**

**🔍 명령 실행: GCP 계정 생성 및 설정**
```bash
# 자동화 스크립트 실행
echo "=== GCP 계정 생성 및 설정 시작 ==="
cloud_basic/automation/day1/automation/02-gcp-setup.sh setup

# 또는 수동 실행 ["참고용"]
echo "=== 수동 GCP 계정 생성 및 설정 ==="
# 1. GCP 계정 생성 ["브라우저에서 실행"]
echo "GCP 계정 생성: https://cloud.google.com/"
echo "1. Google 계정으로 로그인"
echo "2. $300 크레딧 활성화"
echo "3. 프로젝트 생성"
echo "4. 결제 계정 설정"

# 2. GCP CLI 설치 확인
gcloud --version

# 3. GCP CLI 인증
gcloud auth login

# 4. 프로젝트 설정
gcloud config set project [PROJECT_ID]

# 5. 설정 확인
gcloud config list
gcloud auth list
```

**✅ 예상 결과:**
- GCP 계정: $300 크레딧 활성화
- 프로젝트: 실습용 프로젝트 생성
- GCP CLI: 로컬 환경 설정 완료
- 인증: GCP 서비스 접근 가능

**🌐 콘솔에서 확인:**
- GCP Console: https://console.cloud.google.com/

---

## 🕘 2교시: AWS EC2 실습 [10:45~12:00]

### 📚 이론 학습 ["15분"]
#### EC2 기본 개념
- **인스턴스**: 가상 서버
- **AMI**: Amazon Machine Image ["운영체제 템플릿"]
- **인스턴스 타입**: CPU, 메모리, 스토리지 조합
- **키 페어**: SSH 접속용 키
- **보안 그룹**: 방화벽 규칙

### 🛠️ 실습 ["60분"]

#### 🏗️ **3단계: AWS EC2 인스턴스 생성**

**목표 아키텍처 ["3단계 완료 후"]**
```mermaid
flowchart TB
    subgraph "AWS Cloud"
        A1["EC2 인스턴스<br/>t2.micro"]
        A2["보안 그룹<br/>SSH 허용"]
        A3["키 페어<br/>SSH 접속용"]
        A4["퍼블릭 IP<br/>외부 접속"]
    end
    
    subgraph "Local"
        L1["개발자 머신<br/>SSH 클라이언트"]
    end
    
    L1 -->> A4
    A4 -->> A1
    A1 -->> A2
    A1 -->> A3
```

**🔍 명령 실행: AWS EC2 인스턴스 생성**
```bash
# 자동화 스크립트 실행
echo "=== AWS EC2 인스턴스 생성 시작 ==="
cloud_basic/automation/day1/automation/03-ec2-practice.sh setup

# 또는 수동 실행 ["참고용"]
echo "=== 수동 AWS EC2 인스턴스 생성 ==="
# 1. 키 페어 생성
aws ec2 create-key-pair --key-name cloud-basic-key --query 'KeyMaterial' --output text > cloud-basic-key.pem
chmod 400 cloud-basic-key.pem

# 2. 보안 그룹 생성
aws ec2 create-security-group \
    --group-name cloud-basic-sg \
    --description "Security group for Cloud Basic course"

# 3. SSH 접속 허용 규칙 추가
aws ec2 authorize-security-group-ingress \
    --group-name cloud-basic-sg \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

# 4. EC2 인스턴스 생성
aws ec2 run-instances \
    --image-id ami-0c76973fbe0ee100c \
    --count 1 \
    --instance-type t2.micro \
    --key-name cloud-basic-key \
    --security-groups cloud-basic-sg \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=cloud-basic-instance}]'

# 5. 인스턴스 상태 확인
aws ec2 describe-instances --filters "Name=tag:Name,Values=cloud-basic-instance"

# 6. 퍼블릭 IP 확인
aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=cloud-basic-instance" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text
```

**✅ 예상 결과:**
- EC2 인스턴스: t2.micro 인스턴스 생성
- 보안 그룹: SSH["22번 포트"] 허용
- 키 페어: SSH 접속용 키 생성
- 퍼블릭 IP: 외부 접속 가능한 IP 할당

#### 🏗️ **4단계: SSH 접속 및 기본 명령어 실행**

**🔍 명령 실행: SSH 접속 및 기본 명령어**
```bash
# 1. 퍼블릭 IP 가져오기
PUBLIC_IP=$[aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=cloud-basic-instance" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text]

echo "퍼블릭 IP: $PUBLIC_IP"

# 2. SSH 접속
ssh -i cloud-basic-key.pem ec2-user@$PUBLIC_IP

# 3. 인스턴스 내에서 기본 명령어 실행
echo "=== 기본 시스템 정보 확인 ==="
uname -a
cat /etc/os-release
df -h
free -h
ps aux | head -10

# 4. 웹 서버 설치 및 실행
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd

# 5. 간단한 웹 페이지 생성
echo "<h1>Hello from AWS EC2!</h1>" | sudo tee /var/www/html/index.html

# 6. 웹 서버 포트 허용 ["보안 그룹"]
aws ec2 authorize-security-group-ingress \
    --group-name cloud-basic-sg \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

# 7. 웹 서버 접속 테스트
curl http://$PUBLIC_IP
```

**✅ 예상 결과:**
- SSH 접속: EC2 인스턴스에 성공적으로 접속
- 시스템 정보: Linux 시스템 정보 확인
- 웹 서버: Apache 웹 서버 설치 및 실행
- 웹 페이지: "Hello from AWS EC2!" 메시지 표시

**🌐 브라우저로 서비스 접근:**
```bash
echo "=== 웹 서버 접속 URL ==="
echo "EC2 웹 서버: http://$PUBLIC_IP"
echo "브라우저에서 접속하여 확인하세요!"
```

---

## 🍽️ 점심 시간 [12:00~13:00]

---

## 🕘 3교시: AWS S3 실습 [13:00~14:30]

### 📚 이론 학습 ["15분"]
#### S3 기본 개념
- **버킷**: 파일 저장소 컨테이너
- **객체**: 버킷에 저장되는 파일
- **키**: 객체의 고유 식별자
- **스토리지 클래스**: Standard, IA, Glacier 등
- **권한**: 버킷 정책, ACL

### 🛠️ 실습 ["75분"]

#### 🏗️ **5단계: AWS S3 버킷 생성 및 파일 관리**

**목표 아키텍처 ["5단계 완료 후"]**
```mermaid
flowchart TB
    subgraph "AWS Cloud"
        A1["S3 버킷<br/>cloud-basic-bucket"]
        A2["객체<br/>파일들"]
        A3["권한 설정<br/>퍼블릭 읽기"]
        A4["웹 호스팅<br/>정적 웹사이트"]
    end
    
    subgraph "Local"
        L1["개발자 머신<br/>파일 업로드"]
    end
    
    subgraph "Internet"
        I1["사용자<br/>웹 브라우저"]
    end
    
    L1 -->> A1
    A1 -->> A2
    A1 -->> A3
    A1 -->> A4
    I1 -->> A4
```

**🔍 명령 실행: AWS S3 버킷 생성 및 파일 관리**
```bash
# 자동화 스크립트 실행
echo "=== AWS S3 버킷 생성 및 파일 관리 시작 ==="
cloud_basic/automation/day1/automation/04-s3-practice.sh setup

# 또는 수동 실행 ["참고용"]
echo "=== 수동 AWS S3 버킷 생성 및 파일 관리 ==="
# 1. 고유한 버킷 이름 생성
BUCKET_NAME="cloud-basic-bucket-$[date +%s]"
echo "버킷 이름: $BUCKET_NAME"

# 2. S3 버킷 생성
aws s3 mb s3://$BUCKET_NAME --region ap-northeast-2

# 3. 버킷 목록 확인
aws s3 ls

# 4. 로컬 파일 생성
echo "Hello from AWS S3!" > hello.txt
echo "<h1>Welcome to Cloud Basic Course!</h1>" > index.html

# 5. 파일 업로드
aws s3 cp hello.txt s3://$BUCKET_NAME/
aws s3 cp index.html s3://$BUCKET_NAME/

# 6. 버킷 내용 확인
aws s3 ls s3://$BUCKET_NAME/

# 7. 파일 다운로드
aws s3 cp s3://$BUCKET_NAME/hello.txt downloaded-hello.txt

# 8. 파일 내용 확인
cat downloaded-hello.txt

# 9. 버킷 정책 설정 ["퍼블릭 읽기 허용"]
cat > bucket-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
        }
    ]
}
EOF

aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://bucket-policy.json

# 10. 정적 웹사이트 호스팅 활성화
aws s3 website s3://$BUCKET_NAME --index-document index.html

# 11. 웹사이트 URL 확인
echo "웹사이트 URL: http://$BUCKET_NAME.s3-website.ap-northeast-2.amazonaws.com"
```

**✅ 예상 결과:**
- S3 버킷: 고유한 이름의 버킷 생성
- 파일 업로드: 로컬 파일을 S3에 업로드
- 파일 다운로드: S3에서 로컬로 파일 다운로드
- 웹 호스팅: 정적 웹사이트 호스팅 활성화
- 퍼블릭 접근: 웹 브라우저에서 접근 가능

**🌐 브라우저로 서비스 접근:**
```bash
echo "=== S3 웹사이트 접속 URL ==="
echo "S3 웹사이트: http://$BUCKET_NAME.s3-website.ap-northeast-2.amazonaws.com"
echo "브라우저에서 접속하여 확인하세요!"
```

---

## 🕘 4교시: GCP Compute Engine 실습 [14:45~16:15]

### 📚 이론 학습 ["15분"]
#### Compute Engine 기본 개념
- **인스턴스**: 가상 머신
- **이미지**: 운영체제 템플릿
- **머신 타입**: CPU, 메모리 조합
- **방화벽 규칙**: 네트워크 보안
- **SSH 키**: 인스턴스 접속

### 🛠️ 실습 ["75분"]

#### 🏗️ **6단계: GCP Compute Engine 인스턴스 생성**

**목표 아키텍처 ["6단계 완료 후"]**
```mermaid
flowchart TB
    subgraph "GCP Cloud"
        G1[Compute Engine<br/>e2-micro]
        G2["방화벽 규칙<br/>SSH, HTTP 허용"]
        G3["SSH 키<br/>인스턴스 접속용"]
        G4["외부 IP<br/>외부 접속"]
    end
    
    subgraph "Local"
        L1["개발자 머신<br/>SSH 클라이언트"]
    end
    
    L1 -->> G4
    G4 -->> G1
    G1 -->> G2
    G1 -->> G3
```

**🔍 명령 실행: GCP Compute Engine 인스턴스 생성**
```bash
# 자동화 스크립트 실행
echo "=== GCP Compute Engine 인스턴스 생성 시작 ==="
cloud_basic/automation/day1/automation/05-compute-practice.sh setup

# 또는 수동 실행 ["참고용"]
echo "=== 수동 GCP Compute Engine 인스턴스 생성 ==="
# 1. SSH 키 생성
ssh-keygen -t rsa -f ~/.ssh/gcp-key -C "cloud-basic-user"

# 2. SSH 키를 GCP에 등록
gcloud compute os-login ssh-keys add \
    --key-file ~/.ssh/gcp-key.pub \
    --project $[gcloud config get-value project]

# 3. 방화벽 규칙 생성 ["SSH 허용"]
gcloud compute firewall-rules create allow-ssh \
    --allow tcp:22 \
    --source-ranges 0.0.0.0/0 \
    --description "Allow SSH access"

# 4. 방화벽 규칙 생성 ["HTTP 허용"]
gcloud compute firewall-rules create allow-http \
    --allow tcp:80 \
    --source-ranges 0.0.0.0/0 \
    --description "Allow HTTP access"

# 5. Compute Engine 인스턴스 생성
gcloud compute instances create cloud-basic-instance \
    --zone=asia-northeast3-a \
    --machine-type=e2-micro \
    --image-family=centos-7 \
    --image-project=centos-cloud \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-standard \
    --tags=cloud-basic

# 6. 인스턴스 상태 확인
gcloud compute instances list

# 7. 외부 IP 확인
gcloud compute instances describe cloud-basic-instance \
    --zone=asia-northeast3-a \
    --format='get[networkInterfaces[0].accessConfigs[0].natIP]'
```

**✅ 예상 결과:**
- Compute Engine 인스턴스: e2-micro 인스턴스 생성
- 방화벽 규칙: SSH["22번"], HTTP["80번"] 포트 허용
- SSH 키: 인스턴스 접속용 키 생성
- 외부 IP: 외부 접속 가능한 IP 할당

#### 🏗️ **7단계: SSH 접속 및 웹 서버 설정**

**🔍 명령 실행: SSH 접속 및 웹 서버 설정**
```bash
# 1. 외부 IP 가져오기
EXTERNAL_IP=$[gcloud compute instances describe cloud-basic-instance \
    --zone=asia-northeast3-a \
    --format='get[networkInterfaces[0].accessConfigs[0].natIP]']

echo "외부 IP: $EXTERNAL_IP"

# 2. SSH 접속
gcloud compute ssh cloud-basic-instance --zone=asia-northeast3-a

# 3. 인스턴스 내에서 기본 명령어 실행
echo "=== 기본 시스템 정보 확인 ==="
uname -a
cat /etc/centos-release
df -h
free -h
ps aux | head -10

# 4. 웹 서버 설치 및 실행
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd

# 5. 간단한 웹 페이지 생성
echo "<h1>Hello from GCP Compute Engine!</h1>" | sudo tee /var/www/html/index.html

# 6. 웹 서버 접속 테스트
curl http://localhost

# 7. 인스턴스에서 나가기
exit

# 8. 외부에서 웹 서버 접속 테스트
curl http://$EXTERNAL_IP
```

**✅ 예상 결과:**
- SSH 접속: Compute Engine 인스턴스에 성공적으로 접속
- 시스템 정보: CentOS 시스템 정보 확인
- 웹 서버: Apache 웹 서버 설치 및 실행
- 웹 페이지: "Hello from GCP Compute Engine!" 메시지 표시

**🌐 브라우저로 서비스 접근:**
```bash
echo "=== 웹 서버 접속 URL ==="
echo "Compute Engine 웹 서버: http://$EXTERNAL_IP"
echo "브라우저에서 접속하여 확인하세요!"
```

---

## 🕘 5교시: GCP Cloud Storage 실습 [16:30~17:00]

### 📚 이론 학습 ["10분"]
#### Cloud Storage 기본 개념
- **버킷**: 파일 저장소 컨테이너
- **객체**: 버킷에 저장되는 파일
- **스토리지 클래스**: Standard, Nearline, Coldline, Archive
- **권한**: IAM, ACL
- **라이프사이클**: 자동 관리 정책

### 🛠️ 실습 ["20분"]

#### 🏗️ **8단계: GCP Cloud Storage 버킷 생성 및 파일 관리**

**🔍 명령 실행: GCP Cloud Storage 버킷 생성 및 파일 관리**
```bash
# 자동화 스크립트 실행
echo "=== GCP Cloud Storage 버킷 생성 및 파일 관리 시작 ==="
cloud_basic/automation/day1/automation/06-storage-practice.sh setup

# 또는 수동 실행 ["참고용"]
echo "=== 수동 GCP Cloud Storage 버킷 생성 및 파일 관리 ==="
# 1. 고유한 버킷 이름 생성
BUCKET_NAME="cloud-basic-bucket-$[date +%s]"
echo "버킷 이름: $BUCKET_NAME"

# 2. Cloud Storage 버킷 생성
gsutil mb gs://$BUCKET_NAME

# 3. 버킷 목록 확인
gsutil ls

# 4. 로컬 파일 생성
echo "Hello from GCP Cloud Storage!" > hello.txt
echo "<h1>Welcome to GCP Cloud Storage!</h1>" > index.html

# 5. 파일 업로드
gsutil cp hello.txt gs://$BUCKET_NAME/
gsutil cp index.html gs://$BUCKET_NAME/

# 6. 버킷 내용 확인
gsutil ls gs://$BUCKET_NAME/

# 7. 파일 다운로드
gsutil cp gs://$BUCKET_NAME/hello.txt downloaded-hello.txt

# 8. 파일 내용 확인
cat downloaded-hello.txt

# 9. 버킷을 퍼블릭으로 설정
gsutil iam ch allUsers:objectViewer gs://$BUCKET_NAME

# 10. 정적 웹사이트 호스팅 설정
gsutil web set -m index.html gs://$BUCKET_NAME

# 11. 웹사이트 URL 확인
echo "웹사이트 URL: https://storage.googleapis.com/$BUCKET_NAME/index.html"
```

**✅ 예상 결과:**
- Cloud Storage 버킷: 고유한 이름의 버킷 생성
- 파일 업로드: 로컬 파일을 Cloud Storage에 업로드
- 파일 다운로드: Cloud Storage에서 로컬로 파일 다운로드
- 웹 호스팅: 정적 웹사이트 호스팅 설정
- 퍼블릭 접근: 웹 브라우저에서 접근 가능

**🌐 브라우저로 서비스 접근:**
```bash
echo "=== Cloud Storage 웹사이트 접속 URL ==="
echo "Cloud Storage 웹사이트: https://storage.googleapis.com/$BUCKET_NAME/index.html"
echo "브라우저에서 접속하여 확인하세요!"
```

---

## 🎯 **실습 진행 패턴 요약**

### 📋 **각 단계별 진행 패턴**
1. **🏗️ 아키텍처 그림**: 현재 상태와 목표 상태를 Mermaid 다이어그램으로 시각화
2. **🔍 명령 실행**: 자동화 스크립트 또는 수동 명령어 실행
3. **✅ 예상 결과**: 명령 실행 후 예상되는 결과 명시
4. **🌐 콘솔에서 확인**: AWS/GCP 콘솔에서 리소스 상태 확인
5. **🌐 브라우저로 서비스 접근**: 실제 서비스에 접근하여 동작 확인

### 🚀 **실습 진행 순서**
1. **1교시**: 클라우드 기본 개념 및 계정 생성
2. **2교시**: AWS EC2 실습
3. **3교시**: AWS S3 실습
4. **4교시**: GCP Compute Engine 실습
5. **5교시**: GCP Cloud Storage 실습

### 🎯 **핵심 학습 포인트**
- **아키텍처 이해**: 각 단계별 시스템 구조 변화 시각화
- **실습 중심**: 90% 실습, 10% 이론
- **단계별 검증**: 각 단계마다 결과 확인 및 검증
- **비교 학습**: AWS와 GCP 서비스 비교
- **자동화**: 스크립트를 통한 효율적 실습

---

## 🏗️ 최종 시스템 아키텍처

### 5교시: GCP Cloud Storage 실습 완료 후
```mermaid
flowchart TB
    subgraph "AWS Cloud"
        A1["EC2 인스턴스<br/>t2.micro<br/>웹 서버"]
        A2["S3 버킷<br/>정적 웹사이트<br/>파일 저장소"]
        A3["보안 그룹<br/>SSH, HTTP 허용"]
        A4["키 페어<br/>SSH 접속용"]
    end
    
    subgraph "GCP Cloud"
        G1["Compute Engine<br/>e2-micro<br/>웹 서버"]
        G2["Cloud Storage<br/>정적 웹사이트<br/>파일 저장소"]
        G3["방화벽 규칙<br/>SSH, HTTP 허용"]
        G4["SSH 키<br/>인스턴스 접속용"]
    end
    
    subgraph "Local"
        L1["개발자 머신<br/>AWS CLI, GCP CLI"]
    end
    
    subgraph "Internet"
        I1["사용자<br/>웹 브라우저"]
    end
    
    L1 -->> A1
    L1 -->> A2
    L1 -->> G1
    L1 -->> G2
    
    I1 -->> A1
    I1 -->> A2
    I1 -->> G1
    I1 -->> G2
    
    A1 -->> A3
    A1 -->> A4
    G1 -->> G3
    G1 -->> G4
```

**최종 적용된 기능:**
- ✅ **AWS 계정**: Free Tier 계정 생성 및 설정
- ✅ **GCP 계정**: $300 크레딧 계정 생성 및 설정
- ✅ **EC2 인스턴스**: t2.micro 인스턴스 생성 및 웹 서버 설정
- ✅ **S3 버킷**: 정적 웹사이트 호스팅 및 파일 관리
- ✅ **Compute Engine**: e2-micro 인스턴스 생성 및 웹 서버 설정
- ✅ **Cloud Storage**: 정적 웹사이트 호스팅 및 파일 관리

### 📊 예상 결과
- **성공률**: 95% ["자동화 스크립트 활용"]
- **소요 시간**: 7시간 ["자동화로 단축"]
- **주요 개선**: AWS/GCP 비교 학습, 실습 중심 교육

---

## 🎯 1일차 수업 성과

### ✅ 달성한 학습 목표
- [x] 클라우드 컴퓨팅의 기본 개념 이해
- [x] AWS Free Tier 계정 생성 및 설정
- [x] GCP $300 크레딧 계정 생성 및 설정
- [x] AWS EC2 인스턴스 생성 및 웹 서버 설정
- [x] AWS S3 버킷 생성 및 정적 웹사이트 호스팅
- [x] GCP Compute Engine 인스턴스 생성 및 웹 서버 설정
- [x] GCP Cloud Storage 버킷 생성 및 정적 웹사이트 호스팅

### 🔍 주요 학습 포인트
1. **클라우드 기본 개념**: IaaS, PaaS, SaaS 이해
2. **계정 관리**: AWS/GCP 계정 생성 및 CLI 설정
3. **가상머신**: EC2와 Compute Engine 비교 실습
4. **객체 스토리지**: S3와 Cloud Storage 비교 실습
5. **웹 호스팅**: 정적 웹사이트 호스팅 실습

### 🚀 실습 결과물
- **AWS 환경**: EC2 인스턴스 + S3 버킷
- **GCP 환경**: Compute Engine 인스턴스 + Cloud Storage 버킷
- **웹 서비스**: 4개의 웹사이트 [EC2, S3, Compute Engine, Cloud Storage]
- **비교 분석**: AWS vs GCP 서비스 비교 경험

---

## 📚 상세 실습 가이드

### 🔗 **분할 작성 버전 참조**
상세한 실습 내용과 단계별 가이드는 다음 문서들을 참조하세요:

#### **1교시: 클라우드 기본 개념 및 계정 생성**
- **상세 가이드**: `cloud_basic/automation/day1/docs/01-cloud-concepts.md`
- **자동화 스크립트**: `cloud_basic/automation/day1/automation/01-aws-setup.sh`
- **실습 코드**: `cloud_basic/automation/day1/samples/01-account-setup/`

#### **2교시: AWS EC2 실습**
- **상세 가이드**: `cloud_basic/automation/day1/docs/02-aws-ec2.md`
- **자동화 스크립트**: `cloud_basic/automation/day1/automation/03-ec2-practice.sh`
- **실습 코드**: `cloud_basic/automation/day1/samples/02-aws-ec2/`

#### **3교시: AWS S3 실습**
- **상세 가이드**: `cloud_basic/automation/day1/docs/03-aws-s3.md`
- **자동화 스크립트**: `cloud_basic/automation/day1/automation/04-s3-practice.sh`
- **실습 코드**: `cloud_basic/automation/day1/samples/03-aws-s3/`

#### **4교시: GCP Compute Engine 실습**
- **상세 가이드**: `cloud_basic/automation/day1/docs/04-gcp-compute.md`
- **자동화 스크립트**: `cloud_basic/automation/day1/automation/05-compute-practice.sh`
- **실습 코드**: `cloud_basic/automation/day1/samples/04-gcp-compute/`

#### **5교시: GCP Cloud Storage 실습**
- **상세 가이드**: `cloud_basic/automation/day1/docs/05-gcp-storage.md`
- **자동화 스크립트**: `cloud_basic/automation/day1/automation/06-storage-practice.sh`
- **실습 코드**: `cloud_basic/automation/day1/samples/05-gcp-storage/`

### 🛠️ **자동화 도구**
- **통합 환경 체크**: `cloud_basic/automation/day1/scripts/environment-check.sh`
- **AWS 설정 도우미**: `cloud_basic/automation/day1/scripts/aws-setup-helper.sh`
- **GCP 설정 도우미**: `cloud_basic/automation/day1/scripts/gcp-setup-helper.sh`

### 📋 **문제 해결 가이드**
- **일반적인 문제**: `cloud_basic/automation/day1/docs/troubleshooting.md`
- **AWS 문제**: `cloud_basic/automation/day1/docs/aws-troubleshooting.md`
- **GCP 문제**: `cloud_basic/automation/day1/docs/gcp-troubleshooting.md`

---

**강의안 작성일**: 2024년 9월 2일  
**예상 소요 시간**: 7시간 ["9:00~17:00, 자동화로 단축"]  
**실습 중심**: 90% 실습, 10% 이론  
**자동화 활용**: 95% 자동화 스크립트 사용 권장  
**비교 학습**: AWS vs GCP 서비스 비교 실습
