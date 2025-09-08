**AWS, Azure, GCP를 모두 포함하는 Cloud 실무자 기초교육 커리큘럼**

---

# 📘 Step 2: Storage

### 🎯 목표

* 각 클라우드의 객체 스토리지 서비스 이해
* 버킷 생성 및 파일 업로드 실습
* 퍼블릭 접근 권한 설정

---

## 시나리오

**당신은 외부 협력사와 파일을 공유해야 하며, 이를 위해 클라우드 스토리지를 사용하여 파일을 업로드하고 퍼블릭 URL을 생성하려 합니다.**

---

## 사용자 가이드

### \[AWS – S3]

1. **버킷 생성**

   * `S3` > `Create bucket` > 이름: `training-s3-bucket`
   * 리전: `Asia Pacific (Seoul)`
   * Public access 차단 해제

2. **파일 업로드**

   * `training.pdf` 업로드

3. **퍼블릭 URL 확인**

   * 업로드된 객체 > `Object URL` 복사

---

### \[Azure – Blob Storage]

1. **Storage Account 생성**

   * `Storage accounts` > `+ Create`
   * 이름: `trainingstorage`, 리전: `Korea Central`

2. **Blob 컨테이너 생성**

   * `Containers` > `+ Container`
   * 이름: `sharedfiles`, Public access level: `Blob (anonymous read access)`

3. **파일 업로드 및 URL 확인**

   * `Upload` > `training.pdf` 업로드
   * URL: 업로드된 파일 > Properties에서 확인

---

### \[GCP – Cloud Storage]

1. **버킷 생성**

   * `Cloud Storage` > `Create bucket` > 이름: `training-gcs-bucket`
   * 리전: `Asia-northeast3 (Seoul)`
   * Public access 허용

2. **파일 업로드**

   * `Upload file` > `training.pdf`

3. **퍼블릭 URL 설정**

   * 객체 클릭 > `Permissions` > `+ Add` > 사용자: `allUsers`, 역할: `Storage Object Viewer`

---

