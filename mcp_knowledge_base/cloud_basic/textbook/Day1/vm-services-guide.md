# 3교시: 가상머신 서비스 실습

<div align="center">

[← 이전: Cloud Basic 1일차 메인](/mcp_knowledge_base/cloud_master/README.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🏠 학습 경로로 돌아가기](/mcp_knowledge_base/index.md) | [📋 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>

<details>
<summary>📋 목차</summary>

1. [🎯 학습 목표](#학습-목표)
2. [🖥️ AWS EC2 실습](#aws-ec2-실습)
3. [🚀 GCP Compute Engine 실습](#gcp-compute-engine-실습)
4. [🚀 비교 분석](#비교-분석)
5. [🧪 실습 과제](#실습-과제)
6. [📚 문제 해결 및 참고 자료](#문제-해결-및-참고-자료)

</details>

---

## 🎯 학습 목표

### 핵심 학습 목표
- **AWS EC2** 인스턴스 생성 및 관리
- **GCP Compute Engine** 인스턴스 생성 및 관리
- **인스턴스 타입** 및 **이미지** 선택 기준 이해
- **네트워킹** 및 **보안** 설정 방법 학습

### 실습 후 달성할 수 있는 능력
- ✅ AWS EC2 인스턴스 생성 및 관리
- ✅ GCP Compute Engine 인스턴스 생성 및 관리
- ✅ 인스턴스 타입 및 이미지 선택
- ✅ 네트워킹 및 보안 설정

### 예상 소요 시간
- **AWS EC2 기초**: 60-90분
- **GCP Compute Engine 기초**: 60-90분
- **비교 분석**: 30-45분
- **실습 과제**: 45-60분
- **전체 과정**: 3-4시간

</details>

---

## 🖥️ AWS EC2 실습

<details>
<summary>📖 AWS EC2 개요</summary>

### EC2란?
- **Elastic Compute Cloud**: AWS의 가상머신 서비스
- **확장 가능**: 필요에 따라 인스턴스 수 조정
- **다양한 옵션**: 다양한 인스턴스 타입과 이미지 제공

### 주요 특징
- **온디맨드**: 필요할 때만 사용
- **유연한 결제**: 사용한 만큼만 비용 지불
- **보안**: VPC와 보안 그룹을 통한 네트워크 보안

</details>

### 1.1 EC2 기본 개념

<details>
<summary>💻 인스턴스 타입</summary>

### 인스턴스 패밀리
- **t3**: 범용, 버스트 가능한 성능
- **m5**: 범용, 균형잡힌 성능
- **c5**: 컴퓨팅 최적화
- **r5**: 메모리 최적화
- **g4**: GPU 최적화

### 인스턴스 크기
- **nano**: 0.5 vCPU, 0.5 GB RAM
- **micro**: 1 vCPU, 1 GB RAM (Free Tier)
- **small**: 1 vCPU, 2 GB RAM
- **medium**: 2 vCPU, 4 GB RAM
- **large**: 2 vCPU, 8 GB RAM

### 선택 기준
- **Free Tier**: t3.micro (12개월 무료)
- **개발/테스트**: t3.small, t3.medium
- **프로덕션**: m5.large 이상

</details>

<details>
<summary>🖼️ AMI (Amazon Machine Image)</summary>

### AMI 유형
- **Amazon Linux 2**: AWS 최적화 Linux
- **Ubuntu**: 인기 있는 Linux 배포판
- **Windows Server**: Windows 환경
- **커스텀 AMI**: 사용자 정의 이미지

### AMI 선택 기준
- **운영체제**: Linux vs Windows
- **애플리케이션**: 웹 서버, 데이터베이스 등
- **보안**: 보안 패치 적용 여부
- **비용**: 라이선스 비용 고려

</details>

### 1.2 EC2 인스턴스 생성

<details>
<summary>🌐 웹 콘솔 방식</summary>
```markdown
1. AWS Console → "EC2" 검색
2. "인스턴스 시작" 클릭
3. AMI 선택: "Amazon Linux 2 AMI"
4. 인스턴스 유형: "t3.micro" (Free Tier)
5. 키 페어 선택: "새 키 페어 생성"
6. 보안 그룹 설정:
   - SSH (22) - 내 IP
   - HTTP (80) - 어디서나
   - HTTPS (443) - 어디서나
7. "시작" 클릭
```

</details>

<details>
<summary>💻 CLI 방식</summary>
```bash
# 키 페어 생성
aws ec2 create-key-pair \
  --key-name cloud-student-key \
  --query 'KeyMaterial' \
  --output text > cloud-student-key.pem

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

# EC2 인스턴스 시작
aws ec2 run-instances \
  --image-id ami-0c76973fbe0ee100c \
  --count 1 \
  --instance-type t3.micro \
  --key-name cloud-student-key \
  --security-groups web-server-sg \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=cloud-student-server}]'
```

</details>

### 1.3 EC2 인스턴스 관리

<details>
<summary>📊 인스턴스 상태 확인</summary>
```bash
# 인스턴스 목록 확인
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=cloud-student-server" \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]' \
  --output table

# 인스턴스 시작/중지
aws ec2 start-instances --instance-ids i-1234567890abcdef0
aws ec2 stop-instances --instance-ids i-1234567890abcdef0
```

</details>

<details>
<summary>🔐 SSH 접속</summary>
```bash
# 인스턴스 IP 확인
INSTANCE_IP=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=cloud-student-server" \
  --query 'Reservations[*].Instances[*].PublicIpAddress' \
  --output text)

# SSH 접속
ssh -i cloud-student-key.pem ec2-user@$INSTANCE_IP
```

</details>

---

## 🚀 GCP Compute Engine 실습

<details>
<summary>📖 GCP Compute Engine 개요</summary>

### Compute Engine이란?
- **Google Cloud의 가상머신 서비스**: GCP의 가상머신 서비스
- **확장 가능**: 필요에 따라 인스턴스 수 조정
- **다양한 옵션**: 다양한 머신 타입과 이미지 제공

### 주요 특징
- **온디맨드**: 필요할 때만 사용
- **유연한 결제**: 사용한 만큼만 비용 지불
- **보안**: VPC와 방화벽을 통한 네트워크 보안

</details>

### 2.1 Compute Engine 기본 개념

<details>
<summary>💻 머신 유형</summary>

### 머신 패밀리
- **e2**: 범용, 비용 효율적
- **n1**: 범용, 균형잡힌 성능
- **c2**: 컴퓨팅 최적화
- **m1**: 메모리 최적화
- **a2**: GPU 최적화

### 머신 크기
- **micro**: 0.5-1 vCPU, 0.5-1 GB RAM (Free Tier)
- **small**: 1 vCPU, 2 GB RAM
- **medium**: 1 vCPU, 4 GB RAM
- **large**: 2 vCPU, 8 GB RAM

### 선택 기준
- **Free Tier**: e2-micro (12개월 무료)
- **개발/테스트**: e2-small, e2-medium
- **프로덕션**: n1-standard-1 이상

</details>

<details>
<summary>🖼️ 이미지</summary>

### 이미지 유형
- **Ubuntu**: 인기 있는 Linux 배포판
- **Debian**: 안정적인 Linux 배포판
- **CentOS**: 엔터프라이즈 Linux
- **Windows Server**: Windows 환경

### 이미지 선택 기준
- **운영체제**: Linux vs Windows
- **애플리케이션**: 웹 서버, 데이터베이스 등
- **보안**: 보안 패치 적용 여부
- **비용**: 라이선스 비용 고려

</details>

### 2.2 Compute Engine 인스턴스 생성

<details>
<summary>🌐 웹 콘솔 방식</summary>
```markdown
1. GCP Console → "Compute Engine" → "VM 인스턴스"
2. "인스턴스 만들기" 클릭
3. 인스턴스 정보:
   - 이름: "cloud-student-server"
   - 리전: "asia-northeast3 (서울)"
   - 영역: "asia-northeast3-a"
   - 머신 유형: "e2-micro"
   - 부팅 디스크: "Ubuntu 22.04 LTS"
4. 방화벽: "HTTP 트래픽 허용", "HTTPS 트래픽 허용" 체크
5. "만들기" 클릭
```

</details>

<details>
<summary>💻 CLI 방식</summary>
```bash
# 방화벽 규칙 생성
gcloud compute firewall-rules create allow-http-https \
  --allow tcp:80,tcp:443 \
  --source-ranges 0.0.0.0/0 \
  --description "Allow HTTP and HTTPS traffic"

# Compute Engine 인스턴스 생성
gcloud compute instances create cloud-student-server \
  --zone=asia-northeast3-a \
  --machine-type=e2-micro \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud \
  --tags=web-server
```

</details>

### 2.3 Compute Engine 인스턴스 관리

<details>
<summary>📊 인스턴스 상태 확인</summary>
```bash
# 인스턴스 목록 확인
gcloud compute instances list

# 인스턴스 상세 정보
gcloud compute instances describe cloud-student-server \
  --zone=asia-northeast3-a
```

</details>

<details>
<summary>🔐 SSH 접속</summary>
```bash
# gcloud을 통한 SSH 접속
gcloud compute ssh cloud-student-server --zone=asia-northeast3-a

# 또는 직접 SSH 접속
gcloud compute instances describe cloud-student-server \
  --zone=asia-northeast3-a \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
```

</details>

---

## 🚀 비교 분석

<details>
<summary>📊 AWS EC2 vs GCP Compute Engine 비교</summary>

| 구분 | AWS EC2 | GCP Compute Engine |
|------|---------|-------------------|
| **인스턴스 타입** | t3, m5, c5, r5 등 | e2, n2, c2, m2 등 |
| **이미지** | AMI | 이미지 패밀리 |
| **키 관리** | 키 페어 | SSH 키 |
| **보안** | 보안 그룹 | 방화벽 규칙 |
| **스토리지** | EBS | 영구 디스크 |
| **네트워킹** | VPC | VPC 네트워크 |
| **가격** | 시간당 | 초당 |

### 주요 차이점
- **AWS**: 보안 그룹 기반 네트워크 보안
- **GCP**: 방화벽 규칙 기반 네트워크 보안
- **가격**: GCP는 초당 과금으로 더 유연함
- **이미지**: AWS는 AMI, GCP는 이미지 패밀리라고 부름

</details>

---

## 🧪 실습 과제

<details>
<summary>📖 실습 과제 개요</summary>

### 실습 목적
- **AWS EC2**: 인스턴스 생성, 관리, SSH 접속
- **GCP Compute Engine**: 인스턴스 생성, 관리, SSH 접속
- **비교 분석**: 두 플랫폼의 차이점 이해
- **네트워킹**: 보안 그룹/방화벽 설정

### 실습 결과물
- AWS EC2 인스턴스 생성 및 관리
- GCP Compute Engine 인스턴스 생성 및 관리
- SSH 접속 및 기본 명령어 실행
- 네트워킹 및 보안 설정

</details>

### 기본 과제

<details>
<summary>📋 기본 과제 목록</summary>
1. **AWS EC2 인스턴스 생성**: t3.micro 인스턴스 생성 및 SSH 접속
2. **GCP Compute Engine 인스턴스 생성**: e2-micro 인스턴스 생성 및 접속
3. **웹 서버 설치**: 두 플랫폼 모두에 Apache/Nginx 설치
4. **성능 비교**: 동일한 워크로드로 성능 테스트

</details>

### 고급 과제

<details>
<summary>📋 고급 과제 목록</summary>
1. **자동화 스크립트**: 인스턴스 생성 자동화 스크립트 작성
2. **모니터링 설정**: CloudWatch/Cloud Monitoring 설정
3. **백업 전략**: 스냅샷 및 이미지 백업 설정
4. **비용 최적화**: 스팟 인스턴스 및 예약 인스턴스 활용

</details>

---

## ✅ 체크리스트

<details>
<summary>📋 학습 완료 체크리스트</summary>

### AWS EC2 설정
- [ ] AWS EC2 인스턴스 생성 완료
- [ ] SSH 접속 테스트 완료
- [ ] 보안 그룹 설정 완료
- [ ] 웹 서버 설치 및 테스트 완료

### GCP Compute Engine 설정
- [ ] GCP Compute Engine 인스턴스 생성 완료
- [ ] SSH 접속 테스트 완료
- [ ] 방화벽 규칙 설정 완료
- [ ] 웹 서버 설치 및 테스트 완료

### 비교 및 분석
- [ ] 성능 비교 분석 완료
- [ ] 비용 분석 완료
- [ ] 보안 설정 비교 완료

</details>

---

## 📚 문제 해결 및 참고 자료

<details>
<summary>🐛 자주 발생하는 문제</summary>

### AWS EC2 관련 문제
<details>
<summary>❌ EC2 인스턴스 생성 실패</summary>

**원인**:
- AMI ID 오류
- 인스턴스 타입 제한
- 키 페어 오류

**해결방법**:
```bash
# 1. AMI ID 확인
aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*"

# 2. 인스턴스 타입 확인
aws ec2 describe-instance-types --instance-types t3.micro

# 3. 키 페어 확인
aws ec2 describe-key-pairs
```

</details>

<details>
<summary>❌ SSH 접속 실패</summary>

**원인**:
- 보안 그룹 설정 오류
- 키 페어 권한 오류
- 인스턴스 상태 문제

**해결방법**:
```bash
# 1. 보안 그룹 확인
aws ec2 describe-security-groups --group-names web-server-sg

# 2. 키 페어 권한 설정
chmod 400 cloud-student-key.pem

# 3. 인스턴스 상태 확인
aws ec2 describe-instances --instance-ids i-1234567890abcdef0
```

</details>

### GCP Compute Engine 관련 문제
<details>
<summary>❌ Compute Engine 인스턴스 생성 실패</summary>

**원인**:
- 프로젝트 ID 오류
- 리전/영역 제한
- 이미지 오류

**해결방법**:
```bash
# 1. 프로젝트 ID 확인
gcloud config get-value project

# 2. 리전/영역 확인
gcloud compute regions list
gcloud compute zones list

# 3. 이미지 확인
gcloud compute images list --filter="family:ubuntu-2204-lts"
```

</details>

<details>
<summary>❌ SSH 접속 실패</summary>

**원인**:
- 방화벽 규칙 오류
- SSH 키 오류
- 인스턴스 상태 문제

**해결방법**:
```bash
# 1. 방화벽 규칙 확인
gcloud compute firewall-rules list

# 2. SSH 키 확인
gcloud compute os-login ssh-keys list

# 3. 인스턴스 상태 확인
gcloud compute instances describe INSTANCE_NAME --zone=ZONE
```

</details>

</details>

<details>
<summary>📖 추가 학습 자료</summary>

### 공식 문서
- [AWS EC2 공식 문서](https://docs.aws.amazon.com/ec2/)
- [GCP Compute Engine 공식 문서](https://cloud.google.com/compute/docs)
- [AWS EC2 인스턴스 타입](https://aws.amazon.com/ec2/instance-types/)
- [GCP 머신 타입](https://cloud.google.com/compute/docs/machine-types)

### 유용한 리소스
- [AWS EC2 모범 사례](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-best-practices.html)
- [GCP Compute Engine 모범 사례](https://cloud.google.com/compute/docs/best-practices)
- [AWS EC2 가격 계산기](https://calculator.aws/)
- [GCP 가격 계산기](https://cloud.google.com/products/calculator)

### 관련 프로젝트
- [AWS EC2 샘플 프로젝트](https://github.com/aws-samples/ec2-examples)
- [GCP Compute Engine 샘플 프로젝트](https://github.com/GoogleCloudPlatform/compute-samples)

</details>

<details>
<summary>🚀 다음 단계</summary>

### 4교시 준비
1. **스토리지 서비스**: AWS S3, GCP Cloud Storage
2. **데이터베이스 서비스**: AWS RDS, GCP Cloud SQL
3. **네트워킹**: VPC, 서브넷, 라우팅

### 고급 기능
1. **오토 스케일링**: 자동 확장/축소
2. **로드 밸런싱**: 트래픽 분산
3. **모니터링**: CloudWatch, Cloud Monitoring

</details>

---

## 🎉 완료!

축하합니다! 가상머신 서비스 실습을 완료했습니다.

### 📚 학습 요약

이번 교시를 통해 다음을 배웠습니다:

1. **🖥️ AWS EC2**: 인스턴스 생성, 관리, SSH 접속
2. **☁️ GCP Compute Engine**: 인스턴스 생성, 관리, SSH 접속
3. **⚖️ 비교 분석**: 두 플랫폼의 차이점 이해
4. **🔐 네트워킹**: 보안 그룹/방화벽 설정

### 🚀 다음 단계

- **4교시 실습**: [스토리지 서비스 실습](/mcp_knowledge_base/cloud_basic/textbook/Day1/storage-services-guide.md)
- **실제 프로젝트 적용**: 자신의 프로젝트에 가상머신 적용
- **고급 기능 학습**: 오토 스케일링, 로드 밸런싱, 모니터링

### 💡 추가 학습 자료

- [AWS EC2 공식 문서](https://docs.aws.amazon.com/ec2/)
- [GCP Compute Engine 공식 문서](https://cloud.google.com/compute/docs)
- [스토리지 서비스 실습](/mcp_knowledge_base/cloud_basic/textbook/Day1/storage-services-guide.md)

---

**🎯 이제 클라우드 가상머신의 기본기를 갖추었습니다! 4교시로 진행하세요.**


---

<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_basic/learning-path.md)

</div>

---

<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_basic/learning-path.md)

</div>
