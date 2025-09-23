# Docker Compose 실습 가이드

## 🎯 개요

이 가이드는 Cloud Master Day2 과정의 Docker Compose 실습을 위한 완전한 가이드입니다. 개발 환경과 프로덕션 환경의 차이점을 명확히 하고, 실제 발생할 수 있는 문제들과 해결방법을 포함합니다.

## 📋 목차

1. [Docker Compose 기본 개념](#1-docker-compose-기본-개념)
2. [개발 환경 vs 프로덕션 환경](#2-개발-환경-vs-프로덕션-환경)
3. [실습 환경 설정](#3-실습-환경-설정)
4. [문제 해결 가이드](#4-문제-해결-가이드)
5. [고급 기능](#5-고급-기능)

---

## 1. Docker Compose 기본 개념

### 1.1 Docker Compose란?

Docker Compose는 다중 컨테이너 Docker 애플리케이션을 정의하고 실행하는 도구입니다.

**주요 특징:**
- YAML 파일로 서비스 정의
- 단일 명령어로 전체 스택 실행
- 서비스 간 의존성 관리
- 환경별 설정 분리

### 1.2 프로젝트 구조

```
project/
├── docker-compose.yml          # 개발 환경
├── docker-compose.prod.yml     # 프로덕션 환경
├── Dockerfile                  # 애플리케이션 이미지
├── src/                        # 소스 코드
├── database/
│   └── init.sql               # 데이터베이스 초기화
├── nginx/
│   ├── nginx.dev.conf         # 개발용 Nginx 설정
│   └── nginx.prod.conf        # 프로덕션용 Nginx 설정
└── .env.prod                  # 프로덕션 환경 변수
```

---

## 2. 개발 환경 vs 프로덕션 환경

### 2.1 개발 환경 (docker-compose.yml)

**특징:**
- 디버깅 및 개발에 최적화
- 모든 포트 노출
- 상세한 로깅
- 빠른 재시작

**서비스 구성:**
```yaml
services:
  app:
    container_name: github-actions-demo-app-dev
    ports:
      - "3000:3000"  # 직접 접근 가능
    environment:
      - NODE_ENV=development
      - LOG_LEVEL=debug
    volumes:
      - ./logs:/app/logs  # 로그 마운트
```

### 2.2 프로덕션 환경 (docker-compose.prod.yml)

**특징:**
- 보안 및 성능 최적화
- 선택적 포트 노출
- 리소스 제한
- 헬스체크 및 재시작 정책

**서비스 구성:**
```yaml
services:
  app:
    container_name: github-actions-demo-app-prod
    ports:
      - "3000:3000"  # 내부 접근만
    environment:
      - NODE_ENV=production
      - LOG_LEVEL=info
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
```

### 2.3 환경별 차이점 비교

| 항목 | 개발 환경 | 프로덕션 환경 |
|------|-----------|---------------|
| **컨테이너 이름** | `-dev` 접미사 | `-prod` 접미사 |
| **환경 변수** | `NODE_ENV=development` | `NODE_ENV=production` |
| **로그 레벨** | `debug` | `info` |
| **포트 노출** | 모든 포트 | 선택적 포트 |
| **리소스 제한** | 없음 | 엄격한 제한 |
| **재시작 정책** | 수동 | `unless-stopped` |
| **헬스체크** | 기본 | 고급 헬스체크 |
| **볼륨** | 로그 마운트 | 데이터 영구 저장 |

---

## 3. 실습 환경 설정

### 3.1 사전 준비

#### 필수 도구 설치
```bash
# Docker 및 Docker Compose 설치 확인
docker --version
docker-compose --version

# Git 설치 확인
git --version

# Node.js 설치 확인 (로컬 개발용)
node --version
npm --version
```

#### 프로젝트 클론
```bash
# 프로젝트 디렉토리로 이동
cd mcp_knowledge_base/cloud_master/textbook/Day2/project

# 프로젝트 구조 확인
ls -la
```

### 3.2 개발 환경 실행

#### 1단계: 개발 환경 시작
```bash
# 개발 환경 실행
docker-compose up --build -d

# 실행 상태 확인
docker-compose ps
```

#### 2단계: 서비스 확인
```bash
# 애플리케이션 헬스체크
curl http://localhost:3000/health

# Nginx 프록시 확인
curl http://localhost/health

# API 테스트
curl http://localhost/api/users
```

#### 3단계: 로그 확인
```bash
# 전체 로그 확인
docker-compose logs

# 특정 서비스 로그 확인
docker-compose logs app
docker-compose logs postgres
docker-compose logs redis
```

### 3.3 프로덕션 환경 실행

#### 1단계: 환경 변수 설정
```bash
# 프로덕션 환경 변수 생성
echo "DB_PASSWORD=secure_prod_password_123" > .env.prod
echo "REDIS_PASSWORD=secure_redis_password_456" >> .env.prod
```

#### 2단계: 프로덕션 환경 시작
```bash
# 프로덕션 환경 실행
docker-compose -f docker-compose.prod.yml up --build -d

# 실행 상태 확인
docker-compose -f docker-compose.prod.yml ps
```

#### 3단계: 프로덕션 기능 확인
```bash
# 보안 헤더 확인
curl -I http://localhost/

# 메트릭 수집 확인
curl http://localhost/metrics

# Rate Limiting 확인 (여러 번 요청)
for i in {1..5}; do curl http://localhost/api/users; done
```

---

## 4. 문제 해결 가이드

### 4.1 컨테이너 이름 충돌

**문제:** `container name is already in use`

**원인:** 기존 컨테이너가 실행 중

**해결방법:**
```bash
# 1단계: 기존 컨테이너 정리
docker-compose down

# 2단계: 특정 컨테이너 제거
docker rm -f github-actions-demo-app-dev
docker rm -f github-actions-demo-db-dev
docker rm -f github-actions-demo-redis-dev
docker rm -f github-actions-demo-nginx-dev

# 3단계: 모든 관련 컨테이너 제거
docker rm -f $(docker ps -a --filter "name=github-actions-demo" --format "{{.Names}}") 2>/dev/null || true

# 4단계: 다시 실행
docker-compose up --build
```

### 4.2 PostgreSQL SQL 문법 오류

**문제:** `syntax error at or near 'timestamp'`

**원인:** `timestamp`는 PostgreSQL 예약어

**해결방법:**
```sql
-- 수정 전
CREATE TABLE app_logs (
    id SERIAL PRIMARY KEY,
    level VARCHAR(20),
    message TEXT,
    timestamp TIMESTAMP
);

-- 수정 후
CREATE TABLE app_logs (
    id SERIAL PRIMARY KEY,
    level VARCHAR(20),
    message TEXT,
    "timestamp" TIMESTAMP
);
```

### 4.3 Redis 연결 오류

**문제:** `connect ECONNREFUSED ::1:6379`

**원인:** IPv6 vs IPv4 주소 문제

**해결방법:**
```javascript
// 수정 전 (구버전)
const redisClient = redis.createClient({
  host: 'redis',
  port: 6379,
  password: 'password'
});

// 수정 후 (최신 버전)
const redisClient = redis.createClient({
  socket: {
    host: 'redis',
    port: 6379
  },
  password: 'password'
});
```

### 4.4 Redis 메서드 오류

**문제:** `redisClient.setex is not a function`

**원인:** 최신 Redis 클라이언트에서 메서드명 변경

**해결방법:**
```javascript
// 수정 전
await redisClient.setex('key', 300, 'value');

// 수정 후
await redisClient.setEx('key', 300, 'value');
```

### 4.5 데이터베이스 연결 실패

**문제:** 애플리케이션이 데이터베이스에 연결할 수 없음

**해결방법:**
```bash
# 1단계: 데이터베이스 컨테이너 상태 확인
docker-compose ps postgres

# 2단계: 데이터베이스 로그 확인
docker-compose logs postgres

# 3단계: 데이터베이스 재시작
docker-compose restart postgres

# 4단계: 헬스체크 대기
docker-compose up --wait
```

### 4.6 메모리 부족 오류

**문제:** 컨테이너가 메모리 부족으로 종료

**해결방법:**
```bash
# 1단계: Docker 리소스 정리
docker system prune -a

# 2단계: 사용하지 않는 컨테이너 제거
docker container prune -f

# 3단계: 사용하지 않는 이미지 제거
docker image prune -a -f

# 4단계: 다시 실행
docker-compose up --build
```

---

## 5. 고급 기능

### 5.1 환경별 설정 분리

#### 개발 환경 설정
```yaml
# docker-compose.yml
services:
  app:
    environment:
      - NODE_ENV=development
      - LOG_LEVEL=debug
    volumes:
      - ./src:/app/src  # 소스 코드 마운트
```

#### 프로덕션 환경 설정
```yaml
# docker-compose.prod.yml
services:
  app:
    environment:
      - NODE_ENV=production
      - LOG_LEVEL=info
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
```

### 5.2 리소스 제한

#### 프로덕션 환경 리소스 제한
```yaml
services:
  app:
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
        reservations:
          memory: 256M
          cpus: '0.25'
```

### 5.3 헬스체크 설정

#### 애플리케이션 헬스체크
```yaml
services:
  app:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

#### 데이터베이스 헬스체크
```yaml
services:
  postgres:
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U myapp_user -d myapp"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### 5.4 볼륨 관리

#### 데이터 영구 저장
```yaml
volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local

services:
  postgres:
    volumes:
      - postgres_data:/var/lib/postgresql/data
  redis:
    volumes:
      - redis_data:/data
```

---

## 6. 실습 체크리스트

### 개발 환경 실습
- [ ] Docker Compose 개발 환경 실행
- [ ] 모든 서비스 정상 작동 확인
- [ ] API 엔드포인트 테스트
- [ ] 로그 확인 및 디버깅
- [ ] 개발 환경 정리

### 프로덕션 환경 실습
- [ ] 환경 변수 설정
- [ ] Docker Compose 프로덕션 환경 실행
- [ ] 보안 헤더 확인
- [ ] 메트릭 수집 확인
- [ ] Rate Limiting 테스트
- [ ] 프로덕션 환경 정리

### 문제 해결 실습
- [ ] 컨테이너 이름 충돌 해결
- [ ] 데이터베이스 연결 문제 해결
- [ ] Redis 연결 문제 해결
- [ ] 메모리 부족 문제 해결
- [ ] 로그 분석 및 디버깅

---

## 7. 추가 학습 자료

### 공식 문서
- [Docker Compose 공식 문서](https://docs.docker.com/compose/)
- [Docker 공식 문서](https://docs.docker.com/)
- [PostgreSQL 공식 문서](https://www.postgresql.org/docs/)
- [Redis 공식 문서](https://redis.io/documentation)

### 관련 가이드
- [Docker 기본 실습 가이드](docker-basic-guide.md)
- [데이터베이스 연동 가이드](database-integration-guide.md)
- [Nginx 설정 가이드](nginx-configuration-guide.md)
- [모니터링 설정 가이드](monitoring-setup-guide.md)

이 가이드를 통해 Docker Compose의 모든 기능을 마스터하고, 실제 프로덕션 환경에서 안정적으로 운영할 수 있습니다! 🚀
