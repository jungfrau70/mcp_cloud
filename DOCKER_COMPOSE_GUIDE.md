# Docker Compose 환경별 실행 가이드

## 🎯 개요

이 프로젝트는 Docker Compose를 사용하여 개발 환경과 운영 환경을 분리하되, 데이터베이스는 공통으로 사용하는 구조로 설계되었습니다.

## 📁 파일 구조

```
mcp_cloud/
├── docker-compose.base.yml      # 공통 데이터베이스 및 인프라 서비스
├── docker-compose.dev.yml       # 개발 환경 애플리케이션
├── docker-compose.prod.yml      # 운영 환경 애플리케이션
├── scripts/
│   ├── dev.bat                  # Windows 개발 환경 실행
│   ├── dev.sh                   # Linux/Mac 개발 환경 실행
│   ├── prod.bat                 # Windows 운영 환경 실행
│   └── prod.sh                  # Linux/Mac 운영 환경 실행
└── DOCKER_COMPOSE_GUIDE.md      # 이 가이드
```

## 🚀 빠른 시작

### 개발 환경 실행

#### Windows
```cmd
# 개발 환경 실행
scripts\dev.bat
```

#### Linux/Mac
```bash
# 실행 권한 부여 (최초 1회)
chmod +x scripts/*.sh

# 개발 환경 실행
./scripts/dev.sh
```

### 운영 환경 실행

#### Windows
```cmd
# 운영 환경 실행
scripts\prod.bat
```

#### Linux/Mac
```bash
# 운영 환경 실행
./scripts/prod.sh
```

## 🔧 수동 실행 방법

### 1. 공통 데이터베이스 서비스 시작
```bash
# PostgreSQL, Redis, Neo4j 등 공통 서비스 시작
docker-compose -f docker-compose.base.yml up -d
```

### 2. 개발 환경 애플리케이션 시작
```bash
# 개발 환경 (Hot Reload, 디버그 모드)
docker-compose -f docker-compose.base.yml -f docker-compose.dev.yml up --build
```

### 3. 운영 환경 애플리케이션 시작
```bash
# 운영 환경 (백그라운드 실행)
docker-compose -f docker-compose.base.yml -f docker-compose.prod.yml up --build -d
```

## 🗄️ 공통 데이터베이스 사용

### 데이터베이스 공유 구조
- **PostgreSQL**: 개발/운영 환경에서 동일한 데이터베이스 사용
- **Redis**: 캐싱용으로 공통 사용
- **Neo4j**: RAG용 그래프 데이터베이스 공통 사용

### 포트 매핑
- **PostgreSQL**: `localhost:5432`
- **Redis**: `localhost:6379`
- **Neo4j Browser**: `localhost:7474`
- **Neo4j Bolt**: `localhost:7687`

## 🔧 환경별 설정 차이점

### 개발 환경 (docker-compose.dev.yml)
- **API URL**: `http://localhost:8000`
- **Frontend URL**: `http://localhost:3000`
- **Hot Reload**: 활성화 (코드 변경 시 자동 재시작)
- **디버그 모드**: 활성화
- **이메일 인증**: 우회 (TEST_MODE=true)
- **인증**: 비활성화 (DISABLE_AUTH=true)
- **볼륨 마운트**: 소스 코드 실시간 반영

### 운영 환경 (docker-compose.prod.yml)
- **API URL**: `https://api.goldencircle.us`
- **Frontend URL**: `https://app.goldencircle.us`
- **Hot Reload**: 비활성화
- **디버그 모드**: 비활성화
- **이메일 인증**: 활성화
- **인증**: 활성화
- **볼륨 마운트**: 최소한의 마운트

## 🛠️ 유용한 명령어

### 서비스 상태 확인
```bash
# 모든 서비스 상태 확인
docker-compose -f docker-compose.base.yml -f docker-compose.dev.yml ps

# 특정 서비스 로그 확인
docker-compose -f docker-compose.base.yml -f docker-compose.dev.yml logs mcp_backend_dev
```

### 서비스 재시작
```bash
# 특정 서비스만 재시작
docker-compose -f docker-compose.base.yml -f docker-compose.dev.yml restart mcp_backend_dev

# 모든 서비스 재시작
docker-compose -f docker-compose.base.yml -f docker-compose.dev.yml restart
```

### 서비스 중지
```bash
# 개발 환경 중지
docker-compose -f docker-compose.base.yml -f docker-compose.dev.yml down

# 운영 환경 중지
docker-compose -f docker-compose.base.yml -f docker-compose.prod.yml down

# 모든 서비스 중지 (데이터베이스 포함)
docker-compose -f docker-compose.base.yml down
```

### 볼륨 및 이미지 정리
```bash
# 사용하지 않는 볼륨 정리
docker volume prune

# 사용하지 않는 이미지 정리
docker image prune

# 모든 컨테이너 중지 및 제거
docker-compose -f docker-compose.base.yml -f docker-compose.dev.yml down --volumes --remove-orphans
```

## 🚨 문제 해결

### 포트 충돌
```bash
# 포트 사용 중인 프로세스 확인
netstat -tulpn | grep :8000
netstat -tulpn | grep :3000

# 프로세스 종료
kill -9 <PID>
```

### 데이터베이스 연결 오류
```bash
# PostgreSQL 컨테이너 상태 확인
docker-compose -f docker-compose.base.yml ps mcp_postgres

# PostgreSQL 로그 확인
docker-compose -f docker-compose.base.yml logs mcp_postgres
```

### 컨테이너 재빌드
```bash
# 특정 서비스만 재빌드
docker-compose -f docker-compose.base.yml -f docker-compose.dev.yml build mcp_backend_dev

# 모든 서비스 재빌드
docker-compose -f docker-compose.base.yml -f docker-compose.dev.yml build --no-cache
```

## 📊 모니터링

### 리소스 사용량 확인
```bash
# 컨테이너 리소스 사용량
docker stats

# 특정 컨테이너 리소스 사용량
docker stats mcp_backend_dev mcp_frontend_dev
```

### 로그 실시간 모니터링
```bash
# 모든 서비스 로그
docker-compose -f docker-compose.base.yml -f docker-compose.dev.yml logs -f

# 특정 서비스 로그
docker-compose -f docker-compose.base.yml -f docker-compose.dev.yml logs -f mcp_backend_dev
```

## 🔒 보안 고려사항

### 개발 환경
- 인증 비활성화 (DISABLE_AUTH=true)
- 이메일 인증 우회 (TEST_MODE=true)
- 모든 CORS 허용

### 운영 환경
- 인증 활성화
- 이메일 인증 필수
- 특정 도메인만 CORS 허용
- HTTPS 강제

## 📝 환경 변수 설정

### 개발 환경 (.env.development)
```env
ENV=development
DEBUG=true
TEST_MODE=true
DISABLE_AUTH=true
DATABASE_URL=postgresql://mcpuser:mcppassword@mcp_postgres:5432/mcp_db
```

### 운영 환경 (.env.production)
```env
ENV=production
DEBUG=false
TEST_MODE=false
DISABLE_AUTH=false
DATABASE_URL=postgresql://mcpuser:mcppassword@mcp_postgres:5432/mcp_db
```

## 🎯 다음 단계

1. **개발 환경 설정**: `scripts\dev.bat` 또는 `./scripts/dev.sh` 실행
2. **브라우저 접속**: `http://localhost:3000`
3. **API 문서 확인**: `http://localhost:8000/docs`
4. **데이터베이스 관리**: `http://localhost:7474` (Neo4j Browser)

## 📞 지원

문제가 발생하면 다음을 확인하세요:
1. Docker 및 Docker Compose 설치 상태
2. 포트 충돌 여부
3. 환경 변수 설정
4. 컨테이너 로그

추가 도움이 필요하면 프로젝트 이슈를 생성해 주세요.
