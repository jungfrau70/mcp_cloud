# Docker Hub 가입 및 토큰 설정 가이드

## 📋 목차
1. [Docker Hub란?](#docker-hub란)
2. [Docker Hub 가입하기](#docker-hub-가입하기)
3. [Personal Access Token 생성하기](#personal-access-token-생성하기)
4. [GitHub 시크릿 설정하기](#github-시크릿-설정하기)
5. [설정 확인하기](#설정-확인하기)
6. [문제 해결](#문제-해결)

---

## 🐳 Docker Hub란?

### Docker Hub 소개
Docker Hub는 **Docker 이미지를 저장하고 공유하는 클라우드 기반 레지스트리 서비스**입니다.

### Docker Hub의 주요 기능
- **이미지 저장**: Docker 이미지를 클라우드에 저장
- **이미지 공유**: 다른 개발자들과 이미지 공유
- **자동 빌드**: GitHub과 연동하여 자동으로 이미지 빌드
- **버전 관리**: 이미지의 여러 버전 관리

### 왜 Docker Hub가 필요한가?
- **GitHub Actions에서 사용**: CI/CD 파이프라인에서 이미지 푸시
- **배포 시 사용**: 실제 서버에서 이미지 다운로드
- **팀 협업**: 팀원들과 이미지 공유

---

## 📝 Docker Hub 가입하기

### 1단계: Docker Hub 웹사이트 접속
1. 웹 브라우저에서 [https://hub.docker.com](https://hub.docker.com) 접속
2. 오른쪽 상단의 **"Sign Up"** 버튼 클릭

### 2단계: 계정 정보 입력
```
Username: your-username (고유한 사용자명)
Email: your-email@example.com
Password: 안전한 비밀번호 입력
```

**⚠️ 주의사항**:
- **Username**: 고유해야 하며, 나중에 이미지 이름에 사용됩니다
- **Email**: 실제 사용하는 이메일 주소를 입력하세요
- **Password**: 8자 이상, 대소문자, 숫자, 특수문자 포함 권장

### 3단계: 이메일 인증
1. 입력한 이메일 주소로 인증 메일이 발송됩니다
2. 이메일을 확인하고 **"Verify Email"** 링크 클릭
3. 인증 완료 후 Docker Hub에 로그인

### 4단계: 프로필 설정 (선택사항)
1. **"Complete your profile"** 페이지에서 정보 입력
2. **"Skip for now"**를 클릭하여 나중에 설정 가능

---

## 🔑 Personal Access Token 생성하기

### 1단계: Docker Hub 로그인
1. [https://hub.docker.com](https://hub.docker.com)에서 로그인
2. 오른쪽 상단의 **사용자 아이콘** 클릭
3. **"Account Settings"** 선택

### 2단계: Settings 메뉴로 이동
1. 왼쪽 메뉴에서 **"Settings"** 클릭
2. **"Personal access token"** 블레이드 클릭
3. **"Generate new token"** 버튼 클릭

### 3단계: 토큰 생성
```
Access Token Description: GitHub Actions
Access Permissions: Read, Write, Delete (권장)
Expiration: 1 year (권장)
```

**📋 토큰 설명**:
- **Description**: 토큰의 용도를 명확히 표시 (예: "GitHub Actions")
- **Permissions**: 
  - **Read**: 이미지 다운로드
  - **Write**: 이미지 업로드
  - **Delete**: 이미지 삭제
- **Expiration**: 보안을 위해 1년 권장

### 4단계: 토큰 생성 및 복사
1. **"Generate"** 버튼 클릭
2. 생성된 토큰을 **즉시 복사**하여 안전한 곳에 저장
3. **⚠️ 중요**: 이 토큰은 다시 볼 수 없으므로 반드시 복사하세요!

**토큰 예시**:
```
dckr_pat_1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
```

---

## 🔐 GitHub 시크릿 설정하기

### 1단계: GitHub 저장소 접속
1. GitHub에서 `actions-demo` 저장소 접속
2. 상단 메뉴에서 **"Settings"** 클릭

### 2단계: Secrets and variables 메뉴 접속
1. 왼쪽 메뉴에서 **"Secrets and variables"** 클릭
2. **"Actions"** 선택

### 3단계: 새 시크릿 생성
1. **"New repository secret"** 버튼 클릭
2. 시크릿 정보 입력:
   ```
   Name: DOCKERHUB_TOKEN
   Secret: dckr_pat_1234567890abcdef... (복사한 토큰)
   ```
3. **"Add secret"** 버튼 클릭

### 4단계: 시크릿 확인
1. 시크릿 목록에서 `DOCKERHUB_TOKEN`이 생성되었는지 확인
2. **"Update"** 또는 **"Delete"** 버튼으로 나중에 수정 가능

---

## ✅ 설정 확인하기

### 1단계: 워크플로우 파일 확인
`.github/workflows/deploy.yml` 파일에서 다음 부분을 확인:

```yaml
- name: Log in to Container Registry
  uses: docker/login-action@v3
  with:
    registry: ${{ env.REGISTRY }}
    username: ${{ github.actor }}
    password: ${{ secrets.DOCKERHUB_TOKEN }}
  continue-on-error: true

- name: Build and push Docker image
  uses: docker/build-push-action@v5
  with:
    context: .
    push: true  # 푸시 활성화 확인
    tags: ${{ steps.meta.outputs.tags }}
    labels: ${{ steps.meta.outputs.labels }}
    cache-from: type=gha
    cache-to: type=gha,mode=max
  continue-on-error: true
```

### 2단계: 코드 푸시하여 테스트
```bash
# 변경사항 커밋
git add .
git commit -m "Enable Docker Hub push"
git push origin main
```

### 3단계: GitHub Actions 실행 확인
1. GitHub 저장소 → **"Actions"** 탭
2. **"Deploy to Docker Hub"** 워크플로우 실행 확인
3. **"Build and push Docker image"** 단계에서 성공 확인

### 4단계: Docker Hub에서 이미지 확인
1. [https://hub.docker.com](https://hub.docker.com)에서 로그인
2. **"Repositories"** 메뉴에서 `actions-demo` 저장소 확인
3. 최신 이미지가 업로드되었는지 확인

---

## 🐛 문제 해결

### 자주 발생하는 문제들

#### 1. Docker Hub 로그인 실패
```
Error: failed to push to registry: unauthorized
```

**원인**: 
- 잘못된 토큰
- 토큰 권한 부족
- 토큰 만료

**해결방법**:
1. 토큰이 올바르게 복사되었는지 확인
2. 토큰 권한이 Read, Write, Delete인지 확인
3. 토큰이 만료되지 않았는지 확인
4. 새 토큰 생성 후 GitHub 시크릿 업데이트

#### 2. 이미지 푸시 실패
```
Error: failed to push to registry: denied
```

**원인**:
- 저장소 이름 충돌
- 권한 부족

**해결방법**:
1. Docker Hub에서 사용자명 확인
2. `IMAGE_NAME: ${{ github.actor }}/actions-demo`에서 사용자명이 올바른지 확인
3. Docker Hub에서 해당 이름의 저장소가 있는지 확인

#### 3. GitHub 시크릿 설정 실패
```
Error: secret not found
```

**원인**:
- 시크릿 이름 오타
- 시크릿이 생성되지 않음

**해결방법**:
1. GitHub 저장소 → Settings → Secrets and variables → Actions
2. `DOCKERHUB_TOKEN` 시크릿이 있는지 확인
3. 시크릿 이름이 정확한지 확인 (대소문자 구분)

#### 4. 워크플로우 실행 안됨
**원인**:
- 파일 경로 오류
- YAML 문법 오류

**해결방법**:
1. `.github/workflows/deploy.yml` 파일 경로 확인
2. YAML 문법 검사 (들여쓰기, 콜론 등)
3. GitHub Actions 탭에서 오류 메시지 확인

---

## 📚 추가 자료

### Docker Hub 공식 문서
- [Docker Hub 가이드](https://docs.docker.com/docker-hub/)
- [Personal Access Tokens](https://docs.docker.com/docker-hub/access-tokens/)

### GitHub Actions 문서
- [GitHub Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Docker Actions](https://github.com/marketplace?type=actions&query=docker)

### 유용한 링크
- [Docker Hub](https://hub.docker.com)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)

---

## 🎯 다음 단계

### 기본 설정 완료 후
1. **Slack 알림 설정**: `SLACK_WEBHOOK_URL` 시크릿 추가
2. **Codecov 설정**: `CODECOV_TOKEN` 시크릿 추가
3. **고급 워크플로우**: AWS, GCP 배포 워크플로우 활성화

### 실습 프로젝트
1. **로컬 테스트**: `docker run -p 3000:3000 YOUR_USERNAME/actions-demo:main-COMMIT_SHA`
2. **이미지 태그 관리**: 버전별 태그 생성
3. **자동 배포**: main 브랜치 푸시 시 자동 배포 확인

---

## 💡 팁

### 보안 관련
- **토큰 보안**: 토큰을 코드에 직접 입력하지 마세요
- **정기 갱신**: 토큰을 정기적으로 갱신하세요
- **권한 최소화**: 필요한 권한만 부여하세요

### 효율성 관련
- **캐시 활용**: GitHub Actions 캐시를 활용하세요
- **병렬 처리**: 여러 작업을 병렬로 실행하세요
- **조건부 실행**: 필요한 경우에만 실행하도록 설정하세요

---

**🎉 축하합니다! Docker Hub 설정이 완료되었습니다. 이제 GitHub Actions를 통해 자동으로 Docker 이미지를 빌드하고 배포할 수 있습니다!**
