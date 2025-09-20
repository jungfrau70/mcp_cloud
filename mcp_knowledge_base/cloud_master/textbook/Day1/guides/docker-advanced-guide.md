# Docker 고급 실습 가이드



<details>
<summary>📋 목차</summary>

1. [🎯 학습 목표](#학습-목표)
2. [📚 Docker 고급 개념](#docker-고급-개념)
3. [🔧 Dockerfile 최적화](#dockerfile-최적화)
4. [🐳 Docker Compose 고급 설정](#docker-compose-고급-설정)
5. [⚡ Docker 이미지 빌드 최적화](#docker-이미지-빌드-최적화)
6. [📚 문제 해결 및 참고 자료](#문제-해결-및-참고-자료)

</details>

---

## 🎯 학습 목표

### 핵심 학습 목표

[핵심 학습 목표](#핵심-학습-목표)
- **Dockerfile 최적화** 멀티스테이지 빌드 및 레이어 최적화
- **Docker Compose 고급 설정** 다중 서비스 관리 및 네트워킹
- **Docker 이미지 빌드 최적화** BuildKit, 캐시 활용
- **보안 및 성능** 컨테이너 보안 및 성능 최적화

### 실습 후 달성할 수 있는 능력

[실습 후 달성할 수 있는 능력](#실습-후-달성할-수-있는-능력)
- ✅ 멀티스테이지 빌드로 최적화된 Dockerfile 작성
- ✅ Docker Compose로 복잡한 애플리케이션 구성
- ✅ BuildKit을 활용한 고급 빌드 최적화
- ✅ 컨테이너 보안 및 성능 최적화

### 예상 소요 시간

[예상 소요 시간](#예상-소요-시간)
- **Dockerfile 최적화**: 60-90분
- **Docker Compose 고급**: 45-60분
- **빌드 최적화**: 30-45분
- **보안 및 성능**: 30-45분
- **전체 과정**: 3-4시간

---

## 📚 Docker 고급 개념

<details>
<summary>📖 Docker 최적화 원칙</summary>

### 레이어 최적화

[레이어 최적화](#레이어-최적화)
- **레이어 통합**: RUN 명령어 통합으로 레이어 수 감소
- **캐시 활용**: 자주 변경되지 않는 레이어를 위에 배치
- **불필요한 파일 제거**: .git, node_modules 등 제거

### 멀티스테이지 빌드

[멀티스테이지 빌드](#멀티스테이지-빌드)
- **빌드 스테이지**: 빌드 도구 및 의존성 설치
- **실행 스테이지**: 최종 실행 환경만 포함
- **크기 최적화**: 빌드 도구 제거로 이미지 크기 대폭 감소

### 보안 최적화

[보안 최적화](#보안-최적화)
- **비루트 사용자**: 컨테이너 내에서 비루트 사용자로 실행
- **최소 권한**: 필요한 권한만 부여
- **이미지 스캔**: 취약점 스캔 및 업데이트

</details>

<details>
<summary>📖 Docker 이미지 크기 최적화</summary>

### 최적화 기법 비교

[최적화 기법 비교](#최적화-기법-비교)
| 기법 | 설명 | 효과 | 적용 난이도 |
|------|------|------|-------------|
| **Alpine Linux** | 경량 리눅스 배포판 | 50-80% 크기 감소 | 쉬움 |
| **멀티스테이지 빌드** | 빌드 도구 제거 | 60-90% 크기 감소 | 중간 |
| **레이어 통합** | RUN 명령어 통합 | 10-20% 크기 감소 | 쉬움 |
| **불필요한 파일 제거** | .git, node_modules 등 | 20-40% 크기 감소 | 쉬움 |
| **Distroless 이미지** | 최소 실행 환경 | 70-90% 크기 감소 | 어려움 |

### 이미지 크기 분석

[이미지 크기 분석](#이미지-크기-분석)
```bash
# 이미지 크기 확인
docker images

# 이미지 히스토리 분석
docker history my-app:latest

# 이미지 상세 정보
docker inspect my-app:latest

# 이미지 크기 비교
docker images --format "table {{.Repository}}/t{{.Tag}}/t{{.Size}}"
```

</details>

---

## 🔧 Dockerfile 최적화

<details>
<summary>📖 기본 Dockerfile (비최적화)</summary>

### 문제점이 있는 Dockerfile

[문제점이 있는 Dockerfile](#문제점이-있는-dockerfile)
```dockerfile
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

### 문제점 분석

[문제점 분석](#문제점-분석)
- **레이어 수 많음**: 각 명령어마다 레이어 생성
- **캐시 활용 부족**: package.json 변경 시 전체 재빌드
- **보안 문제**: 루트 사용자로 실행
- **크기 문제**: 빌드 도구가 최종 이미지에 포함

</details>

<details>
<summary>📖 최적화된 Dockerfile</summary>

### 멀티스테이지 빌드 Dockerfile

[멀티스테이지 빌드 Dockerfile](#멀티스테이지-빌드-dockerfile)
```dockerfile
# 멀티스테이지 빌드
FROM node:18-alpine AS builder

# 빌드 환경 설정
WORKDIR /app

# 의존성 파일만 먼저 복사 (캐시 활용)
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# 소스 코드 복사 및 빌드
COPY . .
RUN npm run build

# 실행 환경
FROM node:18-alpine AS runtime

# 보안 설정
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

# 애플리케이션 복사
WORKDIR /app
COPY --from=builder --chown=nextjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nextjs:nodejs /app/package*.json ./

# 포트 노출
EXPOSE 3000

# 비루트 사용자로 실행
USER nextjs

# 헬스체크
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 /
  CMD curl -f http:/localhost:3000/health || exit 1

# 애플리케이션 실행
CMD ["npm", "start"]
```

### 최적화 포인트

[최적화 포인트](#최적화-포인트)
- **멀티스테이지 빌드**: 빌드 도구와 실행 환경 분리
- **캐시 활용**: package.json을 먼저 복사하여 의존성 캐시 활용
- **보안 강화**: 비루트 사용자로 실행
- **헬스체크**: 컨테이너 상태 모니터링

</details>

<details>
<summary>📖 고급 Dockerfile 패턴</summary>

### 조건부 빌드

[조건부 빌드](#조건부-빌드)
```dockerfile
# 빌드 인수 사용
ARG NODE_ENV=production
ENV NODE_ENV=$NODE_ENV

# 조건부 설치
RUN if [ "$NODE_ENV" = "development" ]; then /
        npm install --include=dev; /
    else /
        npm ci --only=production; /
    fi
```

### 다중 플랫폼 빌드

[다중 플랫폼 빌드](#다중-플랫폼-빌드)
```dockerfile
# 플랫폼별 최적화
FROM --platform=$BUILDPLATFORM node:18-alpine AS builder

# 크로스 컴파일 설정
RUN apk add --no-cache python3 make g++
```

### 보안 강화

[보안 강화](#보안-강화)
```dockerfile
# 보안 스캔 및 업데이트
FROM node:18-alpine AS security-scan
RUN apk add --no-cache curl
RUN curl -sSfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
RUN trivy fs --exit-code 1 --severity HIGH,CRITICAL /
```

</details>

---

## 🐳 Docker Compose 고급 설정

<details>
<summary>📖 Docker Compose 고급 개념</summary>

### 고급 기능

[고급 기능](#고급-기능)
- **의존성 관리**: 서비스 간 의존성 및 시작 순서 제어
- **네트워킹**: 사용자 정의 네트워크 및 서비스 간 통신
- **볼륨 관리**: 데이터 영속성 및 공유
- **환경별 설정**: 개발, 스테이징, 프로덕션 환경 분리

### 서비스 오케스트레이션

[서비스 오케스트레이션](#서비스-오케스트레이션)
- **헬스체크**: 서비스 상태 모니터링
- **재시작 정책**: 장애 시 자동 재시작
- **리소스 제한**: CPU, 메모리 사용량 제한
- **로그 관리**: 중앙화된 로그 수집

</details>

<details>
<summary>📖 고급 docker-compose.yml</summary>

### 완전한 docker-compose.yml

[완전한 docker-compose.yml](#완전한-dockercomposeyml)
```yaml
version: '3.8'

services:
  # 웹 애플리케이션
  web:
    build:
      context: .
      dockerfile: Dockerfile
      target: runtime
      args:
        NODE_ENV: production
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql:/user:password@db:5432/myapp
      - REDIS_URL=redis:/redis:6379
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http:/localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    networks:
      - app-network
    volumes:
      - app-logs:/app/logs
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M

  # 데이터베이스
  db:
    image: postgres:13-alpine
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d myapp"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G

  # Redis 캐시
  redis:
    image: redis:6-alpine
    command: redis-server --appendonly yes --requirepass password
    volumes:
      - redis_data:/data
    restart: unless-stopped
    networks:
      - app-network
    deploy:
      resources:
        limits:
          cpus: '0.25'
          memory: 256M

  # Nginx 리버스 프록시
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
      - nginx-logs:/var/log/nginx
    depends_on:
      - web
    restart: unless-stopped
    networks:
      - app-network
    deploy:
      resources:
        limits:
          cpus: '0.25'
          memory: 128M

  # 모니터링
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
    networks:
      - app-network

  # 로그 수집
  fluentd:
    image: fluent/fluentd:latest
    volumes:
      - ./fluentd.conf:/fluentd/etc/fluent.conf
      - app-logs:/app/logs
      - nginx-logs:/var/log/nginx
    networks:
      - app-network

volumes:
  postgres_data:
  redis_data:
  app-logs:
  nginx-logs:
  prometheus_data:

networks:
  app-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

</details>

<details>
<summary>📖 환경별 설정</summary>

### 개발 환경 (docker-compose.dev.yml)

[개발 환경 (docker-compose.dev.yml)](#개발-환경-dockercomposedevyml)))
```yaml
version: '3.8'

services:
  web:
    build:
      context: .
      dockerfile: Dockerfile
      target: development
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - DEBUG=*
    ports:
      - "3000:3000"
      - "9229:9229"  # 디버깅 포트
    command: npm run dev

  db:
    image: postgres:13-alpine
    environment:
      - POSTGRES_DB=myapp_dev
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    ports:
      - "5432:5432"
    volumes:
      - postgres_dev_data:/var/lib/postgresql/data

volumes:
  postgres_dev_data:
```

### 프로덕션 환경 (docker-compose.prod.yml)

[프로덕션 환경 (docker-compose.prod.yml)](#프로덕션-환경-dockercomposeprodyml)))
```yaml
version: '3.8'

services:
  web:
    image: my-app:latest
    environment:
      - NODE_ENV=production
    restart: always
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3

  db:
    image: postgres:13-alpine
    environment:
      - POSTGRES_DB=myapp_prod
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD_FILE=/run/secrets/db_password
    secrets:
      - db_password
    restart: always
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G

secrets:
  db_password:
    external: true
```

</details>

---

## ⚡ Docker 이미지 빌드 최적화

<details>
<summary>📖 BuildKit을 사용한 최적화</summary>

### BuildKit 활성화

[BuildKit 활성화](#buildkit-활성화)
```bash
# BuildKit 활성화
export DOCKER_BUILDKIT=1

# 또는 docker-compose에서
COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose build
```

### 고급 빌드 명령어

[고급 빌드 명령어](#고급-빌드-명령어)
```bash
# 멀티 플랫폼 빌드
docker buildx build --platform linux/amd64,linux/arm64 -t my-app:latest .

# 캐시 활용
docker buildx build --cache-from type=local,src=/tmp/.buildx-cache --cache-to type=local,dest=/tmp/.buildx-cache-new -t my-app:latest .

# 빌드 인수 사용
docker buildx build --build-arg NODE_ENV=production -t my-app:latest .

# 출력 형식 지정
docker buildx build --output type=image,name=my-app:latest .
```

</details>

<details>
<summary>📖 .dockerignore 최적화</summary>

### .dockerignore 파일

[.dockerignore 파일](#dockerignore-파일)
```dockerignore
# Git
.git
.gitignore
.gitattributes

# Dependencies
node_modules
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Build outputs
dist
build
.next
out

# Environment files
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE
.vscode
.idea
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage
.nyc_output

# Dependency directories
jspm_packages/

# Optional npm cache directory
.npm

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variables file
.env

# parcel-bundler cache (https://parceljs.org/)
.cache
.parcel-cache

# next.js build output
.next

# nuxt.js build output
.nuxt

# vuepress build output
.vuepress/dist

# Serverless directories
.serverless

# FuseBox cache
.fusebox/

# DynamoDB Local files
.dynamodb/

# TernJS port file
.tern-port

# Stores VSCode versions used for testing VSCode extensions
.vscode-test

# Temporary folders
tmp/
temp/
```

</details>

<details>
<summary>📖 빌드 성능 최적화</summary>

### 병렬 빌드

[병렬 빌드](#병렬-빌드)
```bash
# 여러 이미지 동시 빌드
docker buildx build --target web -t my-app:web .
docker buildx build --target api -t my-app:api .
docker buildx build --target worker -t my-app:worker .
```

### 캐시 전략

[캐시 전략](#캐시-전략)
```bash
# 레지스트리 캐시 사용
docker buildx build --cache-from type=registry,ref=my-registry/my-app:cache --cache-to type=registry,ref=my-registry/my-app:cache -t my-app:latest .

# 로컬 캐시 사용
docker buildx build --cache-from type=local,src=/tmp/.buildx-cache --cache-to type=local,dest=/tmp/.buildx-cache-new -t my-app:latest .
```

### 빌드 시간 측정

[빌드 시간 측정](#빌드-시간-측정)
```bash
# 빌드 시간 측정
time docker buildx build -t my-app:latest .

# 빌드 로그 상세 출력
docker buildx build --progress=plain -t my-app:latest .
```

</details>

---

## 📚 문제 해결 및 참고 자료

<details>
<summary>🐛 자주 발생하는 문제</summary>

### Dockerfile 관련 문제

[Dockerfile 관련 문제](#dockerfile-관련-문제)
<details>
<summary>❌ 멀티스테이지 빌드 실패</summary>

**원인**: 
- 빌드 컨텍스트 문제
- 의존성 누락
- 권한 문제

**해결방법**:
```bash
# 1. 빌드 컨텍스트 확인
docker build --no-cache -t my-app .

# 2. 빌드 로그 확인
docker build --progress=plain -t my-app .

# 3. 중간 이미지 확인
docker images | grep my-app
```

</details>

<details>
<summary>❌ Docker 이미지 크기 문제</summary>

**원인**:
- 불필요한 파일 포함
- 레이어 최적화 부족
- 멀티스테이지 빌드 미사용

**해결방법**:
```bash
# 1. 이미지 크기 분석
docker history my-app:latest

# 2. 불필요한 파일 제거
docker run --rm -v $(pwd):/app -w /app node:18-alpine sh -c "find . -name 'node_modules' -type d -exec rm -rf {} +"

# 3. 멀티스테이지 빌드 적용
docker build --target runtime -t my-app:latest .
```

</details>

### Docker Compose 관련 문제

[Docker Compose 관련 문제](#docker-compose-관련-문제)
<details>
<summary>❌ 서비스 시작 실패</summary>

**원인**:
- 의존성 문제
- 포트 충돌
- 환경 변수 누락

**해결방법**:
```bash
# 1. 서비스 상태 확인
docker-compose ps

# 2. 로그 확인
docker-compose logs service-name

# 3. 서비스 재시작
docker-compose restart service-name
```

</details>

<details>
<summary>❌ 네트워크 연결 문제</summary>

**원인**:
- 네트워크 설정 오류
- 방화벽 설정
- DNS 문제

**해결방법**:
```bash
# 1. 네트워크 확인
docker network ls
docker network inspect network-name

# 2. 서비스 간 연결 테스트
docker-compose exec service1 ping service2

# 3. 포트 확인
docker-compose port service-name port
```

</details>

</details>

<details>
<summary>📖 추가 학습 자료</summary>

### 공식 문서

[공식 문서](#공식-문서)
- [Docker 공식 문서](https://docs.docker.com/)
- [Docker Compose 공식 문서](cloud_basic/textbook/Day1/guides/install_docker_compose.md)
- [Dockerfile 참조](https://docs.docker.com/engine/reference/builder/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

### 유용한 리소스

[유용한 리소스](#유용한-리소스)
- [Docker Hub](https://hub.docker.com/)
- [Docker 샘플 프로젝트](https://github.com/docker/awesome-compose)
- [Docker 보안 가이드](cloud_basic/automation/day2/security_basics.sh)
- [Docker 성능 최적화](https://docs.docker.com/config/containers/resource_constraints/)

### 관련 프로젝트

[관련 프로젝트](#관련-프로젝트)
- [Docker Compose 예제](https://docs.docker.com/compose/gettingstarted/)
- [멀티스테이지 빌드 예제](https://docs.docker.com/develop/dev-best-practices/dockerfile_best-practices/#use-multi-stage-builds)

</details>

<details>
<summary>🚀 다음 단계</summary>

### 고급 Docker 기술

[고급 Docker 기술](#고급-docker-기술)
1. **Docker Swarm**: 컨테이너 오케스트레이션
2. **Kubernetes**: 고급 오케스트레이션
3. **Docker 보안**: 보안 스캔 및 하드닝
4. **성능 튜닝**: 컨테이너 성능 최적화

### 실무 적용

[실무 적용](#실무-적용)
1. **CI/CD 파이프라인**: Docker를 활용한 자동화
2. **마이크로서비스**: Docker Compose로 마이크로서비스 구성
3. **모니터링**: 컨테이너 모니터링 및 로깅
4. **보안**: 컨테이너 보안 정책 및 컴플라이언스

</details>

---

## 🎉 완료!

[🎉 완료!](#완료)

축하합니다! Docker 고급 실습을 완료했습니다.

### 📚 학습 요약

[📚 학습 요약](#학습-요약)

이번 실습을 통해 다음을 배웠습니다:

1. **🔧 Dockerfile 최적화**: 멀티스테이지 빌드, 레이어 최적화
2. **🐳 Docker Compose 고급**: 다중 서비스 관리, 네트워킹
3. **⚡ 빌드 최적화**: BuildKit, 캐시 활용
4. **🔒 보안 및 성능**: 컨테이너 보안, 성능 최적화

### 🚀 다음 단계

[🚀 다음 단계](#다음-단계)

- **GitHub Actions 고급**: CI/CD 파이프라인 구축
- **VM 배포**: AWS EC2, GCP Compute Engine 배포
- **실제 프로젝트 적용**: 자신의 프로젝트에 Docker 고급 기술 적용

### 💡 추가 학습 자료

[💡 추가 학습 자료](#추가-학습-자료)

- [Docker 공식 문서](https://docs.docker.com/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [GitHub Actions 고급 실습](cloud_master/textbook/Day1/guides/github-actions-complete-guide.md)

---

**🎯 이제 Docker 고급 기술의 기본기를 갖추었습니다! GitHub Actions 고급 실습으로 진행하세요.**

---




---


---



<div align="center">

[🏠 홈](index.md) | [📚 전체 커리큘럼](curriculum.md) | [🔗 학습 경로](learning-path.md)

</div>