**AWS, Azure, GCP를 모두 포함하는 Cloud 실무자 기초교육 커리큘럼**

---

# 📘 Step 1: IAM (Identity & Access Management)

### 🎯 목표

* 클라우드 리소스 접근 권한의 개념 이해
* 사용자 및 역할(Role) 생성
* 최소 권한 원칙 기반 권한 부여 실습

---

## 시나리오

**당신은 팀원에게 특정 클라우드 리소스에 대한 접근 권한을 부여해야 합니다. 전체 관리자 권한이 아닌, '스토리지 읽기 권한'만 제공해야 합니다.**

---

## 사용자 가이드

### \[AWS]

1. **IAM 사용자 생성**

   * `IAM` > `Users` > `Add users`
   * 사용자명: `storage-reader`, Access type: `Programmatic access`

2. **정책 부여**

   * 기존 정책 선택: `AmazonS3ReadOnlyAccess`

3. **그룹 생성 및 사용자 추가**

   * 그룹명: `S3Readers`
   * 사용자 할당

---

### \[Azure]

1. **사용자 추가 (Azure AD)**

   * `Azure Active Directory` > `Users` > `+ New user`

2. **역할 할당**

   * `Storage Account` > `Access Control (IAM)` > `Add Role Assignment`
   * 역할: `Storage Blob Data Reader`
   * 사용자 지정

---

### \[GCP]

1. **사용자 추가**

   * `IAM & Admin` > `IAM` > `+ Add`

2. **역할 할당**

   * 역할: `Storage Object Viewer`
   * 사용자 이메일 입력

---
