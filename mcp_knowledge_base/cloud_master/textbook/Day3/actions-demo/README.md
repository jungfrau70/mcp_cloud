# GitHub Actions Demo Project

## 🎯 프로젝트 개요

이 프로젝트는 **GitHub Actions를 사용한 CI/CD 파이프라인**을 학습하기 위한 데모 프로젝트입니다.

## 📋 현재 활성화된 워크플로우

### ✅ **기본 워크플로우 (현재 활성화됨)**

#### 1. **CI Pipeline** (`ci.yml`)
- **트리거**: `push` (main, develop), `pull_request` (main)
- **기능**: 코드 품질 검사, 테스트, 빌드
- **소요 시간**: 약 2-3분

#### 2. **Docker Hub 배포** (`deploy.yml`)
- **트리거**: `push` (main), `tags` (v*)
- **기능**: Docker 이미지 빌드 및 Docker Hub 푸시
- **소요 시간**: 약 3-5분

## 🚀 빠른 시작

### 1단계: 저장소 포크 또는 클론
```bash
git clone https://github.com/YOUR_USERNAME/actions-demo.git
cd actions-demo
```


### 2단계: Docker Hub 토큰 설정 (권장)
**📖 상세 가이드**: [Docker Hub 가입 및 토큰 설정 가이드](../docker-hub-setup-guide)

**간단 설정**:
1. [Docker Hub](https://hub.docker.com)에서 Personal Access Token 생성
2. GitHub 저장소 → Settings → Secrets and variables → Actions
3. `DOCKERHUB_TOKEN` 시크릿 추가

**💡 토큰 없이도 워크플로우는 실행되지만, 실제 Docker 이미지 푸시는 되지 않습니다.**

### 3단계: 코드 푸시하여 워크플로우 실행
```bash
git add .
git commit -m "Initial commit"
git push origin main
```

### 4단계: 결과 확인
1. GitHub 저장소 → Actions 탭
2. 워크플로우 실행 결과 확인
3. Docker Hub에서 이미지 확인

## 🔧 고급 워크플로우 (비활성화됨)

현재 고급 워크플로우들은 **비활성화**되어 있습니다. 사용하려면 파일명에서 `.disabled`를 제거하세요.

### 📁 고급 워크플로우 목록

| 워크플로우 | 설명 | 활성화 방법 |
|-----------|------|-------------|
| `advanced-ci.yml.disabled` | 고급 CI/CD 기능 | `advanced-ci.yml`로 이름 변경 |
| `aws-deploy.yml.disabled` | AWS ECS 배포 | `aws-deploy.yml`로 이름 변경 |
| `gcp-deploy.yml.disabled` | GCP Cloud Run 배포 | `gcp-deploy.yml`로 이름 변경 |
| `multi-cloud-deploy.yml.disabled` | 멀티클라우드 배포 | `multi-cloud-deploy.yml`로 이름 변경 |
| `vm-docker-deploy.yml.disabled` | VM Docker 배포 | `vm-docker-deploy.yml`로 이름 변경 |

### 🎯 고급 워크플로우 활성화 방법

#### 방법 1: 개별 활성화
```bash
# AWS 배포만 활성화
ren aws-deploy.yml.disabled aws-deploy.yml

# GCP 배포만 활성화  
ren gcp-deploy.yml.disabled gcp-deploy.yml
```

#### 방법 2: 모든 고급 워크플로우 활성화
```bash
# 모든 .disabled 파일을 활성화
for %f in (*.disabled) do ren "%f" "%~nf"
```

## 📚 학습 가이드

### 🎓 **초급자 (추천)**
1. **기본 워크플로우만 사용**
   - `ci.yml`: CI/CD 기본 개념 학습
   - `deploy.yml`: Docker Hub 배포 학습

2. **학습 순서**
   - GitHub Actions 기본 개념 이해
   - 워크플로우 파일 구조 파악
   - Docker 이미지 빌드 및 푸시 과정 이해

### 🚀 **중급자**
1. **고급 CI/CD 기능**
   ```bash
   ren advanced-ci.yml.disabled advanced-ci.yml
   ```
   - 매트릭스 빌드
   - 코드 커버리지
   - 보안 스캔

2. **클라우드 배포**
   ```bash
   ren aws-deploy.yml.disabled aws-deploy.yml
   # 또는
   ren gcp-deploy.yml.disabled gcp-deploy.yml
   ```

### 🏆 **고급자**
1. **멀티클라우드 배포**
   ```bash
   ren multi-cloud-deploy.yml.disabled multi-cloud-deploy.yml
   ```
   - AWS ECS + GCP Cloud Run 동시 배포
   - 권한 설정 및 실제 배포

## 🔐 필요한 권한 및 설정

### Docker Hub 배포 (기본)
- `DOCKERHUB_TOKEN`: Docker Hub Personal Access Token

### AWS ECS 배포 (고급)
- `AWS_ACCESS_KEY_ID`: AWS 액세스 키
- `AWS_SECRET_ACCESS_KEY`: AWS 시크릿 키
- `AWS_REGION`: AWS 리전
- `AWS_ECS_CLUSTER`: ECS 클러스터 이름
- `AWS_ECS_SERVICE`: ECS 서비스 이름

### GCP Cloud Run 배포 (고급)
- `GCP_PROJECT_ID`: GCP 프로젝트 ID
- `GCP_SA_KEY`: GCP 서비스 계정 키 (JSON)
- `GCP_REGION`: GCP 리전
- `GCP_SERVICE_NAME`: Cloud Run 서비스 이름

## 🐛 문제 해결

### 자주 발생하는 문제

#### 1. Docker Hub 푸시 실패
```
Error: failed to push to registry
```
**해결방법**: `DOCKERHUB_TOKEN` 시크릿이 올바르게 설정되었는지 확인

#### 2. 워크플로우가 실행되지 않음
**해결방법**: 
- 파일명에 `.disabled`가 있는지 확인
- `.github/workflows/` 디렉토리에 있는지 확인
- YAML 문법 오류가 없는지 확인


#### 3. 테스트 실패
```
Jest did not exit one second after the test run has completed
```
**해결방법**: 이미 해결됨 (app.js에서 테스트 환경 분리)

#### 4. npm 의존성 충돌 오류
```
npm error Invalid: lock file's @types/node@24.3.1 does not satisfy @types/node@20.19.13
npm error Missing: jest-junit@16.0.0 from lock file
```

**원인**:
- `package-lock.json`과 `package.json`의 버전 불일치
- 의존성 버전 충돌

**해결방법**:
1. `package-lock.json` 파일 삭제
2. `npm install` 실행하여 새로 생성
3. 또는 `npm ci` 대신 `npm install` 사용

## 📖 추가 자료

- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [Docker Hub 공식 문서](https://docs.docker.com/docker-hub/)
- [AWS ECS 공식 문서](https://docs.aws.amazon.com/ecs/)
- [GCP Cloud Run 공식 문서](https://cloud.google.com/run/docs)

## 🤝 기여하기

1. 이 저장소를 포크하세요
2. 새로운 브랜치를 생성하세요 (`git checkout -b feature/amazing-feature`)
3. 변경사항을 커밋하세요 (`git commit -m 'Add amazing feature'`)
4. 브랜치에 푸시하세요 (`git push origin feature/amazing-feature`)
5. Pull Request를 생성하세요

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

---

**💡 팁**: 처음 사용하시는 분은 기본 워크플로우부터 시작하세요. 고급 기능은 필요에 따라 단계적으로 활성화하시면 됩니다!
