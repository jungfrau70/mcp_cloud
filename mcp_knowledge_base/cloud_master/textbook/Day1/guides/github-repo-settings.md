# GitHub Repository Secrets 설정 가이드

> 📋 **실제 수업에서 검증된 방법**: 환경파일[.env] 대신 Repository Secrets 사용으로 100% 성공

## 📋 목차

1. ["🔐 Repository Secrets란?"]["#repository-secrets란"]
2. ["📝 필요한 Secrets 목록"]["#필요한-secrets-목록"]
3. ["🛠️ Secrets 설정 방법"]["#secrets-설정-방법"]
4. ["✅ 설정 확인하기"]["#설정-확인하기"]
5. ["🐛 문제 해결"]["#문제-해결"]
6. ["💡 실무 팁"]["#실무-팁"]

---

## 🔐 Repository Secrets란?

### Repository Secrets 소개

**Repository Secrets**는 GitHub 저장소에서 민감한 정보["비밀번호, API 키, 토큰 등"]를 안전하게 저장하고 GitHub Actions에서 사용할 수 있게 해주는 기능입니다.

### 환경파일[.env] vs Repository Secrets

| 구분 | 환경파일[.env] | Repository Secrets |
|------|----------------|-------------------|
| **보안성** | ❌ 코드에 포함되어 노출 위험 | ✅ GitHub에서 암호화하여 안전하게 저장 |
| **관리 편의성** | ❌ 각 환경마다 파일 관리 필요 | ✅ 웹 인터페이스에서 중앙 관리 |
| **실무 적용성** | ❌ 실제 운영환경에서 사용하지 않음 | ✅ 실제 운영환경 표준 방식 |
| **권한 관리** | ❌ 파일 접근 권한으로만 제어 | ✅ 세밀한 권한 제어 가능 |
| **버전 관리** | ❌ Git 히스토리에 민감정보 포함 | ✅ Git 히스토리와 완전 분리 |

### 왜 Repository Secrets를 사용해야 하나요?

- **🔒 보안**: 민감한 정보가 코드에 노출되지 않음
- **🌍 실무 표준**: 실제 운영 환경에서 사용하는 표준 방식
- **👥 팀 협업**: 팀원들이 각자 다른 환경에서도 동일하게 작동
- **🔄 자동화**: GitHub Actions에서 자동으로 사용 가능

---

## 📝 필요한 Secrets 목록

### Cloud Master 1일차 실습용 Secrets

| Secret 이름 | 설명 | 예시 값 | 필수 여부 |
|-------------|------|---------|-----------|
| `DOCKER_USERNAME` | Docker Hub 사용자명 | `myusername` | ✅ 필수 |
| `DOCKER_PASSWORD` | Docker Hub Personal Access Token | `dckr_pat_xxxxx` | ✅ 필수 |
| `GCP_VM_HOST` | GCP VM 공인 IP 주소 | `34.123.45.67` | ✅ 필수 |
| `GCP_VM_SSH_KEY` | GCP VM SSH 개인키 | `-----BEGIN OPENSSH PRIVATE KEY-----` | ✅ 필수 |
| `GCP_VM_USERNAME` | GCP VM 사용자명 | `ubuntu` | ✅ 필수 |
| `AWS_VM_HOST` | AWS VM 공인 IP 주소 | `3.123.45.67` | ✅ 필수 |
| `AWS_VM_SSH_KEY` | AWS VM SSH 개인키 [".pem 파일"] | `-----BEGIN RSA PRIVATE KEY-----` | ✅ 필수 |
| `AWS_VM_USERNAME` | AWS VM 사용자명 | `ubuntu` | ✅ 필수 |

### 각 Secret의 상세 설명

#### 🐳 Docker Hub 관련
- **`DOCKER_USERNAME`**: Docker Hub 계정의 사용자명
- **`DOCKER_PASSWORD`**: Docker Hub Personal Access Token ["비밀번호 아님!"]

#### ☁️ GCP VM 관련
- **`GCP_VM_HOST`**: GCP Compute Engine 인스턴스의 공인 IP
- **`GCP_VM_SSH_KEY`**: GCP VM에 접속하기 위한 OpenSSH 형식 개인키
- **`GCP_VM_USERNAME`**: GCP VM의 사용자명 ["보통 `ubuntu`"]

#### ☁️ AWS VM 관련
- **`AWS_VM_HOST`**: AWS EC2 인스턴스의 공인 IP
- **`AWS_VM_SSH_KEY`**: AWS VM에 접속하기 위한 .pem 형식 개인키
- **`AWS_VM_USERNAME`**: AWS VM의 사용자명 ["보통 `ubuntu`"]

### 🔑 SSH 키 형식 차이점

| 클라우드 | 키 형식 | 파일 확장자 | 시작 헤더 | 사용 예시 |
|----------|---------|-------------|-----------|-----------|
| **AWS** | RSA Private Key | `.pem` | `-----BEGIN RSA PRIVATE KEY-----` | `ssh -i aws-key.pem ubuntu@[IP]` |
| **GCP** | OpenSSH Private Key | `.key` 또는 없음 | `-----BEGIN OPENSSH PRIVATE KEY-----` | `ssh -i gcp-key ubuntu@[IP]` |

### 📝 SSH 키 설정 방법

#### AWS .pem 파일 설정
```bash
# AWS에서 다운로드한 .pem 파일을 그대로 사용
cat aws-key.pem
# -----BEGIN RSA PRIVATE KEY-----
# MIIEpAIBAAKCAQEA...
# -----END RSA PRIVATE KEY-----
```

#### GCP OpenSSH 키 설정
```bash
# GCP에서 생성한 OpenSSH 형식 키 사용
cat gcp-key
# -----BEGIN OPENSSH PRIVATE KEY-----
# b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcn...
# -----END OPENSSH PRIVATE KEY-----
```

---

## 🛠️ Secrets 설정 방법

### 1단계: GitHub 저장소 접속

1. **Fork한 저장소로 이동**
   ```
   https://github.com/[your-username]/github-actions-demo
   ```

2. **Settings 탭 클릭**
   - 저장소 상단 메뉴에서 "Settings" 클릭

3. **Secrets and variables 메뉴 선택**
   - 왼쪽 사이드바에서 "Secrets and variables" 클릭
   - "Actions" 선택

### 2단계: Repository Secrets 추가

#### Docker Hub Secrets 설정

1. **"New repository secret" 버튼 클릭**

2. **DOCKER_USERNAME 설정**
   - Name: `DOCKER_USERNAME`
   - Secret: `[your-docker-hub-username]`
   - "Add secret" 클릭

3. **DOCKER_PASSWORD 설정**
   - Name: `DOCKER_PASSWORD`
   - Secret: `[your-docker-hub-token]` ["비밀번호가 아닌 Personal Access Token!"]
   - "Add secret" 클릭

#### GCP VM Secrets 설정

1. **GCP_VM_HOST 설정**
   - Name: `GCP_VM_HOST`
   - Secret: `[gcp-vm-public-ip]`
   - "Add secret" 클릭

2. **GCP_VM_SSH_KEY 설정**
   - Name: `GCP_VM_SSH_KEY`
   - Secret: `[gcp-vm-ssh-private-key]` ["전체 개인키 내용"]
   - "Add secret" 클릭

3. **GCP_VM_USERNAME 설정**
   - Name: `GCP_VM_USERNAME`
   - Secret: `ubuntu`
   - "Add secret" 클릭

#### AWS VM Secrets 설정

1. **AWS_VM_HOST 설정**
   - Name: `AWS_VM_HOST`
   - Secret: `[aws-vm-public-ip]`
   - "Add secret" 클릭

2. **AWS_VM_SSH_KEY 설정**
   - Name: `AWS_VM_SSH_KEY`
   - Secret: `[aws-vm-ssh-private-key.pem]` ["전체 .pem 파일 내용"]
   - "Add secret" 클릭

3. **AWS_VM_USERNAME 설정**
   - Name: `AWS_VM_USERNAME`
   - Secret: `ubuntu`
   - "Add secret" 클릭

### 3단계: 설정 완료 확인

설정이 완료되면 다음과 같이 표시됩니다:

```
Repository secrets
✅ DOCKER_PASSWORD [Last updated: 2 hours ago]
✅ DOCKER_USERNAME [Last updated: 2 hours ago]
✅ GCP_VM_HOST [Last updated: 2 hours ago]
✅ GCP_VM_SSH_KEY [Last updated: 2 hours ago]
✅ GCP_VM_USERNAME [Last updated: 2 hours ago]
✅ AWS_VM_HOST [Last updated: 2 hours ago]
✅ AWS_VM_SSH_KEY [Last updated: 2 hours ago]
✅ AWS_VM_USERNAME [Last updated: 2 hours ago]
```

---

## ✅ 설정 확인하기

### GitHub Actions에서 Secrets 사용 확인

1. **Actions 탭으로 이동**
   - 저장소 상단 메뉴에서 "Actions" 클릭

2. **워크플로우 실행 확인**
   - 최근 실행된 워크플로우 클릭
   - 각 단계에서 Secrets 사용 여부 확인

3. **로그에서 확인**
   - "Build and push Docker image" 단계에서 Docker Hub 로그인 성공 확인
   - "Deploy to AWS" 단계에서 AWS VM 배포 성공 확인
   - "Deploy to GCP" 단계에서 GCP VM 배포 성공 확인

### 배포 결과 확인

1. **AWS VM 배포 확인**
   ```
   http://[AWS-VM-IP]:3000
   ```

2. **GCP VM 배포 확인**
   ```
   http://[GCP-VM-IP]:3000
   ```

---

## 🐛 문제 해결

### 자주 발생하는 문제들

#### 1. Docker Hub 로그인 실패
**증상**: "unauthorized: authentication required" 오류
**해결방법**:
- `DOCKER_USERNAME`이 정확한지 확인
- `DOCKER_PASSWORD`가 Personal Access Token인지 확인 ["비밀번호 아님!"]
- Docker Hub에서 Personal Access Token 재생성

#### 2. SSH 연결 실패
**증상**: "Permission denied [publickey]" 오류
**해결방법**:
- SSH 개인키가 올바른지 확인
- 개인키에 불필요한 공백이나 줄바꿈이 없는지 확인
- VM의 공인 IP가 정확한지 확인

#### 3. VM 사용자명 오류
**증상**: "user ubuntu not found" 오류
**해결방법**:
- AWS: `ubuntu` 또는 `ec2-user` 사용
- GCP: `ubuntu` 사용
- VM 생성 시 사용한 이미지에 따라 다를 수 있음

### 디버깅 팁

1. **GitHub Actions 로그 확인**
   - Actions 탭에서 실패한 워크플로우 클릭
   - 각 단계별 로그 확인

2. **Secrets 값 확인**
   - Settings > Secrets and variables > Actions에서 값 확인
   - 잘못된 값이 있으면 "Update" 클릭하여 수정

3. **VM 연결 테스트**
   ```bash
   # AWS VM 연결 테스트 [".pem 파일 사용"]
   ssh -i aws-key.pem ubuntu@[AWS-VM-IP]
   
   # GCP VM 연결 테스트 ["OpenSSH private key 사용"]
   ssh -i gcp-key ubuntu@[GCP-VM-IP]
   ```

---

## 💡 실무 팁

### 보안 모범 사례

1. **Personal Access Token 사용**
   - 비밀번호 대신 Personal Access Token 사용
   - 토큰에 최소한의 권한만 부여

2. **정기적인 토큰 갱신**
   - 3-6개월마다 Personal Access Token 갱신
   - 만료된 토큰은 즉시 삭제

3. **팀원별 개별 설정**
   - 각 팀원이 개별 저장소에서 Secrets 설정
   - 공유 계정 사용 금지

### 효율적인 관리 방법

1. **Secrets 명명 규칙**
   - 일관된 명명 규칙 사용
   - 예: `{SERVICE}_{ENVIRONMENT}_{TYPE}`

2. **문서화**
   - 각 Secret의 용도와 설정 방법 문서화
   - 팀원들이 쉽게 따라할 수 있도록 가이드 작성

3. **자동화**
   - 가능한 경우 자동화 스크립트 사용
   - 수동 설정 실수 방지

### 확장 가능한 구조

1. **환경별 Secrets**
   - 개발/스테이징/프로덕션 환경별로 분리
   - Environment Secrets 활용

2. **조직 수준 관리**
   - Organization Secrets로 중앙 관리
   - 팀 전체가 공유하는 Secrets 관리

---

## 📚 관련 자료

### 추가 학습 자료
- ["GitHub Actions 공식 문서"][https://docs.github.com/en/actions/security-guides/encrypted-secrets]
- ["Docker Hub Personal Access Token 가이드"][https://docs.docker.com/docker-hub/access-tokens/]
- ["AWS EC2 SSH 키 관리"][https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html]
- ["GCP Compute Engine SSH 키 관리"][https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys]

### 실습 가이드
- ["Docker Hub 설정 가이드"](docker-hub-setup-guide.md)
- ["GitHub Actions CI/CD 가이드"](github-actions-guide.md)
- ["VM 배포 실습 가이드"](../practices/vm-deployment.md)

---

<div align="center">

["← 이전: GitHub Actions 기초"](github-actions-guide.md) | 
["📚 전체 가이드 목록"](../README.md) | 
["🏠 학습 경로로 돌아가기"](../../../index.md) | 
["다음: VM 배포 실습 →"](../practices/vm-deployment.md)

</div>
