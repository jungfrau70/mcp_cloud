# Docker 고급 실습 가이드

## 🎯 학습 목표

### 핵심 학습 목표
- **Docker 고급 기능** 멀티스테이지 빌드, 최적화 기법
- **Docker Compose 고급** 서비스 오케스트레이션 및 네트워킹
- **Docker 보안** 이미지 보안, 컨테이너 격리
- **Docker 모니터링** 컨테이너 상태 모니터링 및 로그 관리

### 실습 후 달성할 수 있는 능력
- ✅ 멀티스테이지 빌드를 통한 최적화된 이미지 생성
- ✅ Docker Compose를 이용한 복잡한 애플리케이션 스택 구성
- ✅ Docker 보안 모범 사례 적용
- ✅ 컨테이너 모니터링 및 로그 관리

### 예상 소요 시간
- **Docker 고급 기능**: 90-120분
- **Docker Compose 고급**: 60-90분
- **Docker 보안**: 60-90분
- **Docker 모니터링**: 60-90분
- **전체 과정**: 4-6시간

---

## 🛠️ 실습 학습

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/mcp_knowledge_base/cloud_master/repos/samples/day2/my-app/`
- **자동화 스크립트**: `/mcp_knowledge_base/cloud_master/repos/automation/day2/docker-advanced.sh`
- **클라우드 스크립트**: `/mcp_knowledge_base/cloud_master/repos/cloud-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **Docker**: 20.10 이상
- **Docker Compose**: 2.0 이상
- **Git**: 2.30 이상

#### 환경 설정
```bash
# Docker 설치 확인
docker --version

# Docker Compose 설치 확인
docker-compose --version

# Git 설치 확인
git --version
```

</details>

<details>
<summary>🔧 1단계: 멀티스테이지 빌드 실습</summary>

#### 멀티스테이지 Dockerfile 생성
```dockerfile
# 멀티스테이지 빌드 예시
FROM node:16-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:16-alpine AS runtime
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

#### 이미지 빌드 및 최적화
```bash
# 멀티스테이지 빌드 실행
docker build -t my-app:optimized .

# 이미지 크기 비교
docker images | grep my-app

# 이미지 레이어 분석
docker history my-app:optimized
```

</details>

<details>
<summary>🔧 2단계: Docker Compose 고급 구성</summary>

#### 복잡한 서비스 스택 구성
```yaml
# docker-compose.advanced.yml
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
    networks:
      - app-network

  db:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app-network

  redis:
    image: redis:6-alpine
    networks:
      - app-network

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - web
    networks:
      - app-network

volumes:
  postgres_data:

networks:
  app-network:
    driver: bridge
```

#### 서비스 오케스트레이션
```bash
# 전체 스택 시작
docker-compose -f docker-compose.advanced.yml up -d

# 서비스 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs -f web

# 서비스 스케일링
docker-compose up -d --scale web=3
```

</details>

<details>
<summary>🔧 3단계: Docker 보안 실습</summary>

#### 보안 강화된 Dockerfile
```dockerfile
# 보안 강화된 Dockerfile
FROM node:16-alpine AS builder

# 비루트 사용자 생성
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

WORKDIR /app

# 소유권 변경
COPY --chown=nextjs:nodejs . .

# 비루트 사용자로 전환
USER nextjs

EXPOSE 3000

CMD ["npm", "start"]
```

#### 컨테이너 보안 검사
```bash
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

<details>
<summary>🔧 4단계: Docker 모니터링 실습</summary>

#### 컨테이너 모니터링 설정
```yaml
# docker-compose.monitoring.yml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    labels:
      - "prometheus.scrape=true"
      - "prometheus.port=3000"
    networks:
      - monitoring

  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    networks:
      - monitoring

  grafana:
    image: grafana/grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
    networks:
      - monitoring

volumes:
  grafana_data:

networks:
  monitoring:
    driver: bridge
```

#### 모니터링 실행
```bash
# 모니터링 스택 시작
docker-compose -f docker-compose.monitoring.yml up -d

# 컨테이너 리소스 사용량 확인
docker stats

# 로그 스트리밍
docker-compose logs -f app
```

</details>

---

## 📚 참고 자료

### 유용한 명령어
```bash
# Docker 고급 관리
docker system df                    # 디스크 사용량 확인
docker system prune                 # 사용하지 않는 리소스 정리
docker image prune -a               # 사용하지 않는 이미지 정리
docker container prune              # 중지된 컨테이너 정리

# Docker Compose 관리
docker-compose config               # 설정 파일 검증
docker-compose down -v              # 볼륨까지 삭제
docker-compose restart web          # 특정 서비스 재시작
```

### 문제 해결
1. **멀티스테이지 빌드 실패**
   - 빌드 컨텍스트 확인
   - Dockerfile 문법 검증
   - 레이어 캐시 정리

2. **Docker Compose 네트워크 문제**
   - 네트워크 설정 확인
   - 서비스 의존성 검토
   - 포트 충돌 확인

---

## 🧹 실습 정리

### 자동 정리
```bash
# Day2 Docker 고급 실습 자동 정리
./mcp_knowledge_base/cloud_master/repos/automation/day2/docker-advanced.sh --cleanup
```

### 수동 정리
```bash
# Docker 리소스 정리
docker-compose down -v
docker system prune -a
docker volume prune

# 이미지 정리
docker image prune -a
```

### 정리 확인
- [ ] 모든 컨테이너 중지 및 삭제
- [ ] 사용하지 않는 이미지 정리
- [ ] 볼륨 정리
- [ ] 네트워크 정리
