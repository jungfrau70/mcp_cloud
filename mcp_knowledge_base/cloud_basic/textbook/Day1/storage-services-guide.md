<div align="center">

## 🏠 최상위 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_basic/learning-path.md)

## 📖 현재 위치
**Cloud Basic** > **1일차** > **4교시: 스토리지 서비스 실습**

## ⬅️ 이전/다음 네비게이션
[← 이전: Cloud Basic 메인](/mcp_knowledge_base/cloud_basic/README.md) | [다음: Cloud Basic 1일차 →](/mcp_knowledge_base/cloud_basic/textbook/Day1/README.md)

</div>

# 4교시: 스토리지 서비스 실습

<div align="center">

[← 이전: Cloud Basic 1일차 메인](/mcp_knowledge_base/cloud_master/README.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🏠 학습 경로로 돌아가기](/mcp_knowledge_base/index.md) | [📋 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>

<details>
<summary>📋 목차</summary>

1. [🎯 학습 목표](#학습-목표)
2. [🗂️ AWS S3 실습](#aws-s3-실습)
3. [🚀 GCP Cloud Storage 실습](#gcp-cloud-storage-실습)
4. [🚀 비교 분석](#비교-분석)
5. [🧪 실습 과제](#실습-과제)
6. [📚 문제 해결 및 참고 자료](#문제-해결-및-참고-자료)

</details>

---

## 🎯 학습 목표

### 핵심 학습 목표
- **AWS S3** 버킷 생성 및 파일 관리
- **GCP Cloud Storage** 버킷 생성 및 파일 관리
- **객체 스토리지** 개념 및 활용 사례 이해
- **정적 웹사이트 호스팅** 설정 방법 학습

### 실습 후 달성할 수 있는 능력
- ✅ AWS S3 버킷 생성 및 파일 관리
- ✅ GCP Cloud Storage 버킷 생성 및 파일 관리
- ✅ 객체 스토리지 개념 이해
- ✅ 정적 웹사이트 호스팅 설정

### 예상 소요 시간
- **AWS S3 기초**: 60-90분
- **GCP Cloud Storage 기초**: 60-90분
- **비교 분석**: 30-45분
- **실습 과제**: 45-60분
- **전체 과정**: 3-4시간

</details>

---

## 🗂️ AWS S3 실습

<details>
<summary>📖 AWS S3 개요</summary>

### S3란?
- **Simple Storage Service**: AWS의 객체 스토리지 서비스
- **확장 가능**: 무제한 스토리지 용량
- **내구성**: 99.999999999% (11 9's) 내구성

### 주요 특징
- **객체 기반**: 파일을 객체로 저장
- **REST API**: HTTP/HTTPS를 통한 접근
- **버전 관리**: 파일 버전 관리 지원

</details>

### 1.1 S3 기본 개념

<details>
<summary>🪣 버킷 (Bucket)</summary>

### 버킷 특징
- **전역 고유 이름**: 전 세계적으로 고유한 이름 필요
- **리전 선택**: 데이터 저장 위치 선택
- **버전 관리**: 파일 버전 관리 기능
- **생명주기 정책**: 자동 삭제 및 아카이브

### 버킷 설정
- **퍼블릭 액세스**: 공개/비공개 설정
- **암호화**: 서버 측 암호화 설정
- **로깅**: 액세스 로그 설정
- **태깅**: 비용 관리 및 분류

</details>

<details>
<summary>📄 객체 (Object)</summary>

### 객체 특징
- **키 (Key)**: 파일의 고유 식별자
- **메타데이터**: 파일에 대한 추가 정보
- **ACL**: 접근 제어 목록
- **태그**: 객체 분류 및 관리

### 객체 관리
- **업로드**: 단일/멀티파트 업로드
- **다운로드**: 직접 다운로드 또는 URL 생성
- **삭제**: 단일/일괄 삭제
- **복사**: 버킷 간 복사

</details>

### 1.2 S3 버킷 생성 및 관리

<details>
<summary>🌐 웹 콘솔 방식</summary>
```markdown
1. AWS Console → "S3" 검색
2. "버킷 만들기" 클릭
3. 버킷 설정:
   - 버킷 이름: "cloud-student-bucket-[고유번호]"
   - 리전: "아시아 태평양(서울)"
   - 버전 관리: "비활성화"
   - 퍼블릭 액세스 차단: "해제"
4. "버킷 만들기" 클릭
```

</details>

<details>
<summary>💻 CLI 방식</summary>
```bash
# S3 버킷 생성
aws s3 mb s3://cloud-student-bucket-$(date +%s)

# 버킷 목록 확인
aws s3 ls

# 버킷 정보 확인
aws s3api get-bucket-location --bucket BUCKET_NAME
```

### 1.3 S3 파일 업로드/다운로드

<details>
<summary>📤 파일 업로드</summary>
```bash
# 단일 파일 업로드
echo "Hello from AWS S3!" > hello.txt
aws s3 cp hello.txt s3://cloud-student-bucket-[버킷명]/

# 디렉토리 업로드
aws s3 cp ./local-folder/ s3://cloud-student-bucket-[버킷명]/remote-folder/ --recursive

# 동기화
aws s3 sync ./local-folder/ s3://cloud-student-bucket-[버킷명]/remote-folder/
```

</details>

<details>
<summary>📥 파일 다운로드</summary>
```bash
# 단일 파일 다운로드
aws s3 cp s3://cloud-student-bucket-[버킷명]/hello.txt downloaded-hello.txt

# 디렉토리 다운로드
aws s3 cp s3://cloud-student-bucket-[버킷명]/remote-folder/ ./downloaded-folder/ --recursive
```

</details>

### 1.4 S3 정적 웹사이트 호스팅

<details>
<summary>🌐 웹사이트 설정</summary>
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

</details>

---

## 🚀 GCP Cloud Storage 실습

<details>
<summary>📖 GCP Cloud Storage 개요</summary>

### Cloud Storage란?
- **Google Cloud의 객체 스토리지 서비스**: GCP의 객체 스토리지 서비스
- **확장 가능**: 무제한 스토리지 용량
- **내구성**: 99.999999999% (11 9's) 내구성

### 주요 특징
- **객체 기반**: 파일을 객체로 저장
- **REST API**: HTTP/HTTPS를 통한 접근
- **버전 관리**: 파일 버전 관리 지원

</details>

### 2.1 Cloud Storage 기본 개념

<details>
<summary>🪣 버킷 (Bucket)</summary>

### 버킷 특징
- **전역 고유 이름**: 전 세계적으로 고유한 이름 필요
- **리전 선택**: 데이터 저장 위치 선택
- **스토리지 클래스**: Standard, Nearline, Coldline, Archive
- **생명주기 규칙**: 자동 삭제 및 아카이브

### 버킷 설정
- **퍼블릭 액세스**: 공개/비공개 설정
- **암호화**: 서버 측 암호화 설정
- **로깅**: 액세스 로그 설정
- **라벨링**: 비용 관리 및 분류

</details>

<details>
<summary>📄 객체 (Object)</summary>

### 객체 특징
- **이름**: 파일의 고유 식별자
- **메타데이터**: 파일에 대한 추가 정보
- **ACL**: 접근 제어 목록
- **라벨**: 객체 분류 및 관리

### 객체 관리
- **업로드**: 단일/멀티파트 업로드
- **다운로드**: 직접 다운로드 또는 URL 생성
- **삭제**: 단일/일괄 삭제
- **복사**: 버킷 간 복사

</details>

### 2.2 Cloud Storage 버킷 생성 및 관리

<details>
<summary>🌐 웹 콘솔 방식</summary>
```markdown
1. GCP Console → "Cloud Storage" → "버킷"
2. "버킷 만들기" 클릭
3. 버킷 설정:
   - 버킷 이름: "cloud-student-bucket-[고유번호]"
   - 위치 유형: "리전"
   - 리전: "asia-northeast3 (서울)"
   - 스토리지 클래스: "Standard"
   - 액세스 제어: "균일한 액세스"
4. "만들기" 클릭
```

</details>

<details>
<summary>💻 CLI 방식</summary>
```bash
# Cloud Storage 버킷 생성
gsutil mb gs://cloud-student-bucket-$(date +%s)

# 버킷 목록 확인
gsutil ls

# 버킷 정보 확인
gsutil ls -L -b gs://BUCKET_NAME
```

</details>

### 2.3 Cloud Storage 파일 업로드/다운로드

<details>
<summary>📤 파일 업로드</summary>
```bash
# 단일 파일 업로드
echo "Hello from GCP Cloud Storage!" > hello.txt
gsutil cp hello.txt gs://cloud-student-bucket-[버킷명]/

# 디렉토리 업로드
gsutil -m cp -r ./local-folder/ gs://cloud-student-bucket-[버킷명]/remote-folder/

# 동기화
gsutil -m rsync -r ./local-folder/ gs://cloud-student-bucket-[버킷명]/remote-folder/
```

</details>

<details>
<summary>📥 파일 다운로드</summary>
```bash
# 단일 파일 다운로드
gsutil cp gs://cloud-student-bucket-[버킷명]/hello.txt downloaded-hello.txt

# 디렉토리 다운로드
gsutil -m cp -r gs://cloud-student-bucket-[버킷명]/remote-folder/ ./downloaded-folder/
```

</details>

### 2.4 Cloud Storage 정적 웹사이트 호스팅

<details>
<summary>🌐 웹사이트 설정</summary>
```bash
# HTML 파일 생성
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Cloud Student Website</title>
</head>
<body>
    <h1>Welcome to GCP Cloud Storage!</h1>
    <p>This website is hosted on Google Cloud Storage.</p>
</body>
</html>
EOF

# HTML 파일 업로드
gsutil cp index.html gs://cloud-student-bucket-[버킷명]/

# 버킷을 정적 웹사이트로 설정
gsutil web set -m index.html -e index.html gs://cloud-student-bucket-[버킷명]

# 웹사이트 URL 확인
echo "Website URL: https://storage.googleapis.com/cloud-student-bucket-[버킷명]/index.html"
```

</details>

---

## 🚀 비교 분석

<details>
<summary>📊 AWS S3 vs GCP Cloud Storage 비교</summary>

| 구분 | AWS S3 | GCP Cloud Storage |
|------|--------|-------------------|
| **버킷 이름** | 전역 고유 | 전역 고유 |
| **리전** | 리전별 | 리전별 |
| **스토리지 클래스** | Standard, IA, Glacier | Standard, Nearline, Coldline, Archive |
| **버전 관리** | 지원 | 지원 |
| **생명주기** | 지원 | 지원 |
| **정적 웹사이트** | 지원 | 지원 |
| **가격** | GB당 월 요금 | GB당 월 요금 |

### 주요 차이점
- **AWS S3**: 더 많은 스토리지 클래스 옵션
- **GCP Cloud Storage**: 더 세분화된 스토리지 클래스
- **가격**: GCP가 일반적으로 더 저렴
- **통합**: 각각의 클라우드 생태계와 통합

</details>

---

## 🧪 실습 과제

<details>
<summary>📖 실습 과제 개요</summary>

### 실습 목적
- **AWS S3**: 버킷 생성, 파일 관리, 웹사이트 호스팅
- **GCP Cloud Storage**: 버킷 생성, 파일 관리, 웹사이트 호스팅
- **비교 분석**: 두 플랫폼의 차이점 이해
- **정적 웹사이트**: 정적 웹사이트 호스팅 설정

### 실습 결과물
- AWS S3 버킷 생성 및 파일 관리
- GCP Cloud Storage 버킷 생성 및 파일 관리
- 정적 웹사이트 호스팅 설정
- 두 플랫폼 비교 분석

</details>

### 기본 과제

<details>
<summary>📋 기본 과제 목록</summary>
1. **AWS S3 버킷 생성**: 버킷 생성 및 파일 업로드/다운로드
2. **GCP Cloud Storage 버킷 생성**: 버킷 생성 및 파일 관리
3. **정적 웹사이트 호스팅**: 두 플랫폼 모두에 웹사이트 호스팅
4. **성능 테스트**: 파일 업로드/다운로드 속도 비교

</details>

### 고급 과제

<details>
<summary>📋 고급 과제 목록</summary>
1. **버전 관리**: 파일 버전 관리 및 복원
2. **생명주기 정책**: 자동 삭제 및 아카이브 설정
3. **CDN 연동**: CloudFront/Cloud CDN 연동
4. **비용 최적화**: 스토리지 클래스 최적화

</details>

---

## ✅ 체크리스트

<details>
<summary>📋 학습 완료 체크리스트</summary>

### AWS S3 설정
- [ ] AWS S3 버킷 생성 완료
- [ ] 파일 업로드/다운로드 테스트 완료
- [ ] 정적 웹사이트 호스팅 설정 완료
- [ ] 버킷 정책 및 권한 설정 완료

### GCP Cloud Storage 설정
- [ ] GCP Cloud Storage 버킷 생성 완료
- [ ] 파일 업로드/다운로드 테스트 완료
- [ ] 정적 웹사이트 호스팅 설정 완료
- [ ] 버킷 정책 및 권한 설정 완료

### 비교 및 분석
- [ ] 성능 비교 분석 완료
- [ ] 비용 분석 완료
- [ ] 기능 비교 분석 완료

</details>

---

## 📚 문제 해결 및 참고 자료

<details>
<summary>🐛 자주 발생하는 문제</summary>

### AWS S3 관련 문제
<details>
<summary>❌ S3 버킷 생성 실패</summary>

**원인**:
- 버킷 이름 중복
- 권한 부족
- 리전 제한

**해결방법**:
```bash
# 1. 버킷 이름 확인
aws s3 ls

# 2. 권한 확인
aws sts get-caller-identity

# 3. 리전 확인
aws configure get region
```

</details>

<details>
<summary>❌ 파일 업로드 실패</summary>

**원인**:
- 버킷 권한 오류
- 파일 크기 제한
- 네트워크 문제

**해결방법**:
```bash
# 1. 버킷 권한 확인
aws s3api get-bucket-acl --bucket BUCKET_NAME

# 2. 파일 크기 확인
ls -lh FILE_NAME

# 3. 멀티파트 업로드 사용
aws s3 cp FILE_NAME s3://BUCKET_NAME/ --storage-class STANDARD_IA
```

</details>

### GCP Cloud Storage 관련 문제
<details>
<summary>❌ Cloud Storage 버킷 생성 실패</summary>

**원인**:
- 프로젝트 ID 오류
- 권한 부족
- 리전 제한

**해결방법**:
```bash
# 1. 프로젝트 ID 확인
gcloud config get-value project

# 2. 권한 확인
gcloud auth list

# 3. 리전 확인
gcloud compute regions list
```

</details>

<details>
<summary>❌ 파일 업로드 실패</summary>

**원인**:
- 버킷 권한 오류
- 파일 크기 제한
- 네트워크 문제

**해결방법**:
```bash
# 1. 버킷 권한 확인
gsutil iam get gs://BUCKET_NAME

# 2. 파일 크기 확인
ls -lh FILE_NAME

# 3. 멀티파트 업로드 사용
gsutil -m cp FILE_NAME gs://BUCKET_NAME/
```

</details>

</details>

<details>
<summary>📖 추가 학습 자료</summary>

### 공식 문서
- [AWS S3 공식 문서](https://docs.aws.amazon.com/s3/)
- [GCP Cloud Storage 공식 문서](https://cloud.google.com/storage/docs)
- [AWS S3 스토리지 클래스](https://aws.amazon.com/s3/storage-classes/)
- [GCP Cloud Storage 스토리지 클래스](https://cloud.google.com/storage/docs/storage-classes)

### 유용한 리소스
- [AWS S3 모범 사례](https://docs.aws.amazon.com/AmazonS3/latest/userguide/optimizing-performance.html)
- [GCP Cloud Storage 모범 사례](https://cloud.google.com/storage/docs/best-practices)
- [AWS S3 가격 계산기](https://calculator.aws/)
- [GCP 가격 계산기](https://cloud.google.com/products/calculator)

### 관련 프로젝트
- [AWS S3 샘플 프로젝트](https://github.com/aws-samples/amazon-s3-samples)
- [GCP Cloud Storage 샘플 프로젝트](https://github.com/GoogleCloudPlatform/cloud-storage-samples)

</details>

<details>
<summary>🚀 다음 단계</summary>

### 실습 프로젝트 준비
1. **통합 프로젝트**: AWS와 GCP 서비스 통합
2. **네트워킹**: VPC, 서브넷, 라우팅
3. **보안**: 보안 그룹, 방화벽, 암호화

### 고급 기능
1. **백업 및 복원**: 자동 백업, 스냅샷
2. **모니터링**: CloudWatch, Cloud Monitoring
3. **비용 최적화**: 예약 인스턴스, 스팟 인스턴스

</details>

---

## 🎉 완료!

축하합니다! 스토리지 서비스 실습을 완료했습니다.

### 📚 학습 요약

이번 교시를 통해 다음을 배웠습니다:

1. **🗂️ AWS S3**: 버킷 생성, 파일 관리, 웹사이트 호스팅
2. **☁️ GCP Cloud Storage**: 버킷 생성, 파일 관리, 웹사이트 호스팅
3. **⚖️ 비교 분석**: 두 플랫폼의 차이점 이해
4. **🌐 정적 웹사이트**: 정적 웹사이트 호스팅 설정

### 🚀 다음 단계

- **실습 프로젝트**: [통합 실습 프로젝트](practice/README.md)
- **실제 프로젝트 적용**: 자신의 프로젝트에 스토리지 서비스 적용
- **고급 기능 학습**: CDN 연동, 비용 최적화, 모니터링

### 💡 추가 학습 자료

- [AWS S3 공식 문서](https://docs.aws.amazon.com/s3/)
- [GCP Cloud Storage 공식 문서](https://cloud.google.com/storage/docs)
- [통합 실습 프로젝트](practice/README.md)

---

**🎯 이제 클라우드 스토리지의 기본기를 갖추었습니다! 실습 프로젝트로 진행하세요.**


---

<div align="center">

## 🔗 관련 과정 및 네비게이션
[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_basic/learning-path.md)

## 📖 현재 위치
**Cloud Basic** > **1일차** > **4교시: 스토리지 서비스 실습**

## ⬅️ 이전/다음 네비게이션
[← 이전: Cloud Basic 메인](/mcp_knowledge_base/cloud_basic/README.md) | [다음: Cloud Basic 1일차 →](/mcp_knowledge_base/cloud_basic/textbook/Day1/README.md)

## 🔗 관련 과정
[Cloud Master 1일차](/mcp_knowledge_base/cloud_master/textbook/Day1/README.md) | [Cloud Container 1일차](/mcp_knowledge_base/cloud_container/textbook/Day1/README.md)

</div>