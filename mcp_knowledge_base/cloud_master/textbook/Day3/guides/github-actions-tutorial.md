# GitHub Actions 실습 가이드

## 🎯 학습 목표

- **GitHub Actions 기초**: 워크플로우와 작업의 개념 이해
- **CI/CD 파이프라인**: 자동화된 빌드, 테스트, 배포 구현
- **클라우드 통합**: AWS, GCP와 GitHub Actions 연동
- **실무 적용**: 실제 프로젝트에 GitHub Actions 적용

## 📖 참고 자료

- [GitHub Actions 공식 자습서](https://docs.github.com/ko/actions/tutorials)
- [GitHub Actions 워크플로우 구문](https://docs.github.com/ko/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Actions 변수 및 컨텍스트](https://docs.github.com/ko/actions/learn-github-actions/contexts)

## 🚀 GitHub Actions 핵심 개념

### **1. 워크플로우 (Workflow)**
```yaml
# .github/workflows/ci-cd.yml
name: Cloud Master CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

env:
  AWS_REGION: ap-northeast-2
  GCP_REGION: asia-northeast3
```

**동작 원리**:
- **트리거**: 코드 푸시, PR 생성, 수동 실행 시 워크플로우 시작
- **환경 변수**: 모든 작업에서 공유되는 변수 정의
- **조건부 실행**: 특정 조건에서만 작업 실행

### **2. 작업 (Job)**
```yaml
jobs:
  environment-check:
    name: Environment Check
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup WSL environment
        run: |
          echo "Setting up WSL environment simulation..."
          sudo apt-get update
```

**동작 원리**:
- **병렬 실행**: 여러 작업이 동시에 실행 가능
- **의존성**: `needs` 키워드로 작업 간 의존성 정의
- **실행기**: GitHub 호스팅 또는 자체 호스팅 실행기 사용

### **3. 단계 (Step)**
```yaml
steps:
  - name: Configure AWS credentials
    uses: aws-actions/configure-aws-credentials@v4
    with:
      aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
      aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      aws-region: ${{ env.AWS_REGION }}
```

**동작 원리**:
- **액션 사용**: 재사용 가능한 액션 활용
- **비밀 관리**: `secrets` 컨텍스트로 민감한 정보 보호
- **조건부 실행**: `if` 조건으로 단계 실행 제어

## 🔧 실습 1: 기본 워크플로우 생성

### **단계별 실습**

#### **1단계: 워크플로우 파일 생성**
```bash
# .github/workflows 디렉토리 생성
mkdir -p .github/workflows

# 기본 워크플로우 파일 생성
cat > .github/workflows/hello-world.yml << 'EOF'
name: Hello World

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  hello:
    runs-on: ubuntu-latest
    steps:
      - name: Say Hello
        run: echo "Hello, GitHub Actions!"
      
      - name: Show Environment
        run: |
          echo "Runner OS: ${{ runner.os }}"
          echo "GitHub Repository: ${{ github.repository }}"
          echo "GitHub Actor: ${{ github.actor }}"
EOF
```

**동작 원리**:
- **파일 위치**: `.github/workflows/` 디렉토리에 YAML 파일 저장
- **자동 감지**: GitHub이 자동으로 워크플로우 파일 인식
- **컨텍스트 변수**: `${{ github.* }}` 형태로 GitHub 정보 접근

#### **2단계: 워크플로우 실행**
```bash
# 코드 커밋 및 푸시
git add .github/workflows/hello-world.yml
git commit -m "Add Hello World workflow"
git push origin main
```

**동작 원리**:
- **트리거**: `push` 이벤트로 워크플로우 자동 실행
- **실행기**: GitHub 호스팅 Ubuntu 실행기에서 실행
- **로그 확인**: GitHub Actions 탭에서 실행 로그 확인

## 🔧 실습 2: 클라우드 통합 워크플로우

### **AWS 통합 예시**

#### **1단계: AWS 자격 증명 설정**
```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ap-northeast-2
```

**동작 원리**:
- **비밀 관리**: GitHub Secrets에 AWS 자격 증명 저장
- **액션 활용**: 공식 AWS 액션 사용으로 안전한 인증
- **지역 설정**: AWS 리전을 환경 변수로 설정

#### **2단계: AWS 리소스 생성**
```yaml
- name: Create S3 Bucket
  run: |
    aws s3 mb s3://my-cloud-master-bucket-${{ github.run_number }}
    aws s3 ls
```

**동작 원리**:
- **동적 이름**: `${{ github.run_number }}`로 고유한 버킷 이름 생성
- **명령어 실행**: `run` 단계에서 AWS CLI 명령어 실행
- **결과 확인**: `aws s3 ls`로 생성된 리소스 확인

### **GCP 통합 예시**

#### **1단계: GCP 인증 설정**
```yaml
- name: Setup GCP CLI
  uses: google-github-actions/setup-gcloud@v2
  with:
    service_account_key: ${{ secrets.GCP_SA_KEY }}
    project_id: ${{ secrets.GCP_PROJECT_ID }}
```

**동작 원리**:
- **서비스 계정**: GCP 서비스 계정 키를 비밀로 저장
- **프로젝트 설정**: GCP 프로젝트 ID 자동 설정
- **gcloud 명령어**: 설정 후 gcloud CLI 사용 가능

#### **2단계: GCP 리소스 관리**
```yaml
- name: Create GCP Resources
  run: |
    gcloud compute instances list
    gcloud storage buckets list
```

## 🔧 실습 3: 고급 워크플로우 패턴

### **조건부 실행**
```yaml
- name: Deploy to Production
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  run: |
    echo "Deploying to production..."
    # 배포 로직
```

**동작 원리**:
- **브랜치 조건**: `main` 브랜치에서만 배포 실행
- **이벤트 조건**: `push` 이벤트에서만 배포 실행
- **조건부 로직**: `if` 문으로 복잡한 조건 설정

### **매트릭스 전략**
```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
    node-version: [18, 20, 22]
  
jobs:
  test:
    runs-on: ${{ matrix.os }}
    steps:
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
```

**동작 원리**:
- **조합 생성**: OS와 Node.js 버전의 모든 조합 생성
- **병렬 실행**: 각 조합이 독립적으로 실행
- **매트릭스 변수**: `${{ matrix.* }}`로 현재 조합 접근

### **캐싱 활용**
```yaml
- name: Cache Node modules
  uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

**동작 원리**:
- **캐시 키**: 파일 해시 기반으로 고유한 캐시 키 생성
- **복원 키**: 부분 일치로 캐시 복원 시도
- **성능 향상**: 의존성 설치 시간 단축

## 🔧 실습 4: Cloud Master CI/CD 파이프라인

### **전체 워크플로우 구조**

```yaml
name: Cloud Master CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
    paths:
      - 'mcp_knowledge_base/cloud_master/repos/cloud-scripts/**'
  pull_request:
    branches: [ main ]
  workflow_dispatch:

env:
  AWS_REGION: ap-northeast-2
  GCP_REGION: asia-northeast3
  DOCKER_REGISTRY: ghcr.io

jobs:
  # 1. 환경 체크
  environment-check:
    name: Environment Check
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Validate scripts
        run: |
          find mcp_knowledge_base/cloud_master/repos/cloud-scripts -name "*.sh" -exec bash -n {} \;
  
  # 2. AWS 테스트
  aws-test:
    name: AWS Environment Test
    runs-on: ubuntu-latest
    needs: environment-check
    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}
      
      - name: Test AWS CLI
        run: |
          aws sts get-caller-identity
          aws ec2 describe-regions --region-names ap-northeast-2
  
  # 3. GCP 테스트
  gcp-test:
    name: GCP Environment Test
    runs-on: ubuntu-latest
    needs: environment-check
    steps:
      - name: Setup GCP CLI
        uses: google-github-actions/setup-gcloud@v2
        with:
          service_account_key: ${{ secrets.GCP_SA_KEY }}
          project_id: ${{ secrets.GCP_PROJECT_ID }}
      
      - name: Test GCP CLI
        run: |
          gcloud auth list
          gcloud config get-value project
  
  # 4. Docker 빌드
  docker-build:
    name: Docker Build and Test
    runs-on: ubuntu-latest
    needs: environment-check
    steps:
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.DOCKER_REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Build and push Docker images
        run: |
          docker build -t ${{ env.DOCKER_REGISTRY }}/cloud-master-base:latest .
          docker push ${{ env.DOCKER_REGISTRY }}/cloud-master-base:latest
  
  # 5. 통합 테스트
  integration-test:
    name: Integration Test
    runs-on: ubuntu-latest
    needs: [aws-test, gcp-test, docker-build]
    steps:
      - name: Run integration tests
        run: |
          echo "Running integration tests..."
          # 전체 실습 환경 배포 테스트
  
  # 6. 배포 (Production)
  deploy:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: integration-test
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    environment: production
    steps:
      - name: Deploy to production
        run: |
          echo "Deploying to production environment..."
          # 실제 배포 로직
```

**동작 원리**:
1. **트리거**: 코드 변경 시 자동 실행
2. **환경 체크**: 스크립트 문법 검증
3. **클라우드 테스트**: AWS, GCP 환경 테스트
4. **Docker 빌드**: 컨테이너 이미지 빌드 및 푸시
5. **통합 테스트**: 전체 시스템 통합 테스트
6. **배포**: 조건부 프로덕션 배포

## 🔧 실습 5: 비밀 관리 및 보안

### **GitHub Secrets 설정**

#### **1단계: Secrets 생성**
```bash
# GitHub 웹 인터페이스에서 Settings > Secrets and variables > Actions
# 다음 비밀들 추가:
# - AWS_ACCESS_KEY_ID
# - AWS_SECRET_ACCESS_KEY
# - GCP_SA_KEY
# - GCP_PROJECT_ID
```

#### **2단계: 비밀 사용**
```yaml
- name: Use Secrets
  run: |
    echo "AWS Access Key: ${{ secrets.AWS_ACCESS_KEY_ID }}"
    echo "GCP Project: ${{ secrets.GCP_PROJECT_ID }}"
    # 비밀 값은 로그에 표시되지 않음
```

**동작 원리**:
- **암호화 저장**: GitHub에서 비밀을 암호화하여 저장
- **런타임 주입**: 워크플로우 실행 시에만 비밀 값 주입
- **로그 보호**: 비밀 값이 로그에 노출되지 않음

### **OpenID Connect (OIDC) 사용**

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::123456789012:role/GitHubActions
    aws-region: ap-northeast-2
```

**동작 원리**:
- **임시 자격 증명**: AWS IAM 역할 기반 임시 자격 증명 사용
- **보안 강화**: 장기간 유효한 액세스 키 불필요
- **자동 회전**: 자격 증명 자동 회전으로 보안 향상

## 🔧 실습 6: 워크플로우 최적화

### **캐싱 전략**
```yaml
- name: Cache dependencies
  uses: actions/cache@v4
  with:
    path: |
      ~/.npm
      ~/.cache/pip
      ~/.terraform
    key: ${{ runner.os }}-deps-${{ hashFiles('**/package-lock.json', '**/requirements.txt', '**/.terraform.lock.hcl') }}
    restore-keys: |
      ${{ runner.os }}-deps-
```

### **병렬 실행**
```yaml
strategy:
  matrix:
    test-suite: [unit, integration, e2e]
  
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        test-suite: [unit, integration, e2e]
    steps:
      - name: Run ${{ matrix.test-suite }} tests
        run: |
          echo "Running ${{ matrix.test-suite }} tests"
```

### **조건부 실행**
```yaml
- name: Deploy to Staging
  if: github.ref == 'refs/heads/develop'
  run: |
    echo "Deploying to staging..."
  
- name: Deploy to Production
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  run: |
    echo "Deploying to production..."
```

## 📊 모니터링 및 디버깅

### **워크플로우 상태 확인**
```yaml
- name: Notify on Success
  if: success()
  run: |
    echo "✅ Workflow completed successfully!"
  
- name: Notify on Failure
  if: failure()
  run: |
    echo "❌ Workflow failed!"
    # 실패 알림 로직
```

### **디버그 로깅**
```yaml
- name: Debug Information
  run: |
    echo "::debug::GitHub Context: ${{ toJson(github) }}"
    echo "::debug::Runner Context: ${{ toJson(runner) }}"
    echo "::debug::Job Context: ${{ toJson(job) }}"
```

## 🎯 실습 완료 체크리스트

- [ ] 기본 워크플로우 생성 및 실행
- [ ] AWS/GCP 클라우드 통합 구현
- [ ] 비밀 관리 및 보안 설정
- [ ] Docker 이미지 빌드 및 푸시
- [ ] 조건부 실행 및 매트릭스 전략 적용
- [ ] 캐싱 및 성능 최적화
- [ ] 모니터링 및 디버깅 설정

## 🔗 추가 학습 자료

- [GitHub Actions 공식 문서](https://docs.github.com/ko/actions)
- [GitHub Actions 마켓플레이스](https://github.com/marketplace?type=actions)
- [GitHub Actions 예제 모음](https://github.com/actions/starter-workflows)
- [GitHub Actions 모범 사례](https://docs.github.com/ko/actions/learn-github-actions/best-practices-for-github-actions)

이 가이드를 통해 GitHub Actions의 핵심 개념과 실무 적용 방법을 체계적으로 학습할 수 있습니다.
