# 🐳 Docker 고급 활용

## 🎯 학습 목표

### 핵심 학습 목표
- **Dockerfile 최적화** 레이어 캐싱, 멀티스테이지 빌드, 이미지 크기 최적화
- **Docker Compose 고급** 환경별 설정, 네트워킹, 보안 설정

### 실습 후 달성할 수 있는 능력
- ✅ 최적화된 Dockerfile 작성 및 멀티스테이지 빌드 활용
- ✅ Docker Compose를 통한 복잡한 애플리케이션 스택 구성
- ✅ 컨테이너 보안 모범 사례 적용

### 예상 소요 시간
- **Dockerfile 최적화**: 60-90분
- **Docker Compose 고급**: 60-90분
- **전체 과정**: 2-3시간

---

## 🛠️ 실습 학습

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/mcp_knowledge_base/cloud_intermediate/repo/samples/day1/docker-advanced/`
- **자동화 스크립트**: `/mcp_knowledge_base/cloud_intermediate/repo/scripts/docker-advanced-practice.sh`
- **클라우드 스크립트**: `/mcp_knowledge_base/cloud_intermediate/repo/cloud-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **Docker Desktop**: 컨테이너 실행 환경
- **Docker Compose**: 다중 컨테이너 관리
- **VS Code**: 코드 편집 ["Docker 확장 권장"]

#### 환경 설정
```bash
# Docker 설치 확인
docker --version
docker-compose --version

# Docker 데몬 상태 확인
docker info

# Docker Hub 로그인 ["선택사항"]
docker login
```

</details>

<details>
<summary>🔧 1단계: Dockerfile 최적화</summary>

#### 기본 Dockerfile 작성
```dockerfile
# 기본 Dockerfile ["비최적화"]
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
EXPOSE 3000
CMD ["npm", "start"]
```

#### 최적화된 Dockerfile 작성
```dockerfile
# 최적화된 Dockerfile
FROM node:18-alpine AS builder
WORKDIR /app

# 의존성 파일만 먼저 복사 ["캐시 최적화"]
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# 애플리케이션 코드 복사
COPY . .

# 프로덕션 이미지
FROM node:18-alpine AS runtime
WORKDIR /app

# 보안을 위한 non-root 사용자 생성
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# 빌드된 파일만 복사
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nextjs:nodejs /app ./

USER nextjs
EXPOSE 3000
CMD ["npm", "start"]
```

#### 멀티스테이지 빌드 실습
```bash
# 멀티스테이지 빌드 실행
docker build --target builder -t myapp:builder .
docker build --target runtime -t myapp:runtime .

# 이미지 크기 비교
docker images | grep myapp

# 빌드 캐시 활용
docker build --cache-from myapp:latest -t myapp:latest .
```

</details>

<details>
<summary>🔧 2단계: Docker Compose 고급</summary>

#### 기본 docker-compose.yml
```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      - db
      - redis

  db:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:6-alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

#### 고급 docker-compose.yml
```yaml
# docker-compose.override.yml
version: '3.8'

services:
  web:
    build:
      context: .
      dockerfile: Dockerfile.prod
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user:password@db:5432/myapp
      - REDIS_URL=redis://redis:6379
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    networks:
      - app-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - app-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d myapp"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:6-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - app-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 3

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - web
    networks:
      - app-network
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:

networks:
  app-network:
    driver: bridge
```

#### 환경별 설정 관리
```bash
# 개발 환경
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# 프로덕션 환경
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up

# 스테이징 환경
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up
```

</details>

<details>
<summary>🔧 3단계: 컨테이너 보안</summary>

#### 보안 강화 Dockerfile
```dockerfile
# 보안 강화 Dockerfile
FROM node:18-alpine AS builder
WORKDIR /app

# 보안 업데이트
RUN apk update && apk upgrade && apk add --no-cache dumb-init

# 의존성 설치
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# 애플리케이션 코드 복사
COPY . .

# 프로덕션 이미지
FROM node:18-alpine AS runtime
WORKDIR /app

# 보안을 위한 non-root 사용자 생성
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# 빌드된 파일만 복사
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nextjs:nodejs /app ./

# 보안 설정
USER nextjs
EXPOSE 3000

# dumb-init 사용 ["PID 1 문제 해결"]
ENTRYPOINT ["dumb-init", "--"]
CMD ["npm", "start"]
```

#### 보안 스캔
```bash
# Trivy를 사용한 보안 스캔
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image myapp:latest

# Docker Bench Security 실행
docker run --rm --net host --pid host --userns host --cap-add audit_control \
  -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
  -v /etc:/etc:ro \
  -v /usr/bin/containerd:/usr/bin/containerd:ro \
  -v /usr/bin/runc:/usr/bin/runc:ro \
  -v /usr/lib/systemd:/usr/lib/systemd:ro \
  -v /var/lib:/var/lib:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  --label docker_bench_security \
  docker/docker-bench-security
```

</details>

---

## 📚 참고 자료

### 유용한 명령어
```bash
# Docker 명령어
docker system prune -a  # 사용하지 않는 이미지 정리
docker image ls --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
docker history myapp:latest  # 이미지 레이어 히스토리
docker inspect myapp:latest  # 이미지 상세 정보

# Docker Compose 명령어
docker-compose config  # 설정 파일 검증
docker-compose logs -f  # 실시간 로그 확인
docker-compose exec web bash  # 컨테이너 내부 접속
docker-compose down -v  # 볼륨까지 삭제
```

### 문제 해결
1. **Dockerfile 빌드 실패**
   - Dockerfile 문법 확인
   - 베이스 이미지 존재 여부 확인
   - 네트워크 연결 상태 확인

2. **Docker Compose 실행 실패**
   - 포트 충돌 확인
   - 볼륨 권한 확인
   - 네트워크 설정 확인

3. **보안 스캔 실패**
   - 이미지 존재 여부 확인
   - 스캔 도구 설치 확인
   - 권한 설정 확인

---

## 🧹 실습 정리

### 자동 정리
```bash
# Docker 고급 실습 자동 정리
./mcp_knowledge_base/cloud_intermediate/repo/scripts/docker-advanced-practice.sh --cleanup
```

### 수동 정리
```bash
# Docker 이미지 정리
docker rmi myapp:builder myapp:runtime myapp:latest

# Docker Compose 정리
docker-compose down -v
docker-compose rm -f

# Docker 시스템 정리
docker system prune -a
```

### 정리 확인
- [ ] Docker 이미지 정리 완료
- [ ] Docker Compose 리소스 정리 완료
- [ ] 볼륨 정리 완료
- [ ] 네트워크 정리 완료

---

## 🔗 관련 자료

### 📚 실습 가이드
- ["Kubernetes 기초"][kubernetes-basics.md]
- ["클라우드 컨테이너 서비스"][cloud-container-services.md]

### 🛠️ 설치 가이드
- ["Docker Desktop 설치"][_setup_wsl/install-docker-wsl.sh]
- ["Docker Compose 설치"][_setup_wsl/install-docker-compose-wsl.sh]

### 🏠 네비게이션
<div align="center">

["← 이전: Cloud Basic 과정"][../../cloud_basic/README.md] | 
["📚 전체 커리큘럼"][../../../curriculum.md] | 
["🏠 학습 경로로 돌아가기"][../../../index.md] | 
["다음: Kubernetes 기초 →"][kubernetes-basics.md]

</div>
