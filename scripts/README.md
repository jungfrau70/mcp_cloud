# 환경별 실행 가이드 (Docker Compose)

## 🚀 개발 환경 실행

### Windows
```cmd
# 개발 환경 실행 (Docker Compose)
scripts\dev.bat

# 또는 수동으로 Docker Compose 실행
# 1. 공통 데이터베이스 서비스 시작
docker-compose -f docker-compose.base.yml up -d

# 2. 개발 환경 애플리케이션 시작
docker-compose -f docker-compose.base.yml -f docker-compose.dev.yml up --build

# 3. 서비스 중지
docker-compose -f docker-compose.base.yml -f docker-compose.dev.yml down
```

### Linux/Mac
```bash
# 실행 권한 부여 (최초 1회)
chmod +x scripts/dev.sh scripts/prod.sh

# 개발 환경 실행 (Docker Compose)
./scripts/dev.sh

# 또는 수동으로 Docker Compose 실행
# 1. 공통 데이터베이스 서비스 시작
docker-compose -f docker-compose.base.yml up -d

# 2. 개발 환경 애플리케이션 시작
docker-compose -f docker-compose.base.yml -f docker-compose.dev.yml up --build

# 3. 서비스 중지
docker-compose -f docker-compose.base.yml -f docker-compose.dev.yml down
```

## 🏭 운영 환경 실행

### Windows
```cmd
# 운영 환경 실행 (Docker Compose)
scripts\prod.bat

# 또는 수동으로 Docker Compose 실행
# 1. 공통 데이터베이스 서비스 시작
docker-compose -f docker-compose.base.yml up -d

# 2. 운영 환경 애플리케이션 시작 (백그라운드)
docker-compose -f docker-compose.base.yml -f docker-compose.prod.yml up --build -d

# 3. 서비스 상태 확인
docker-compose -f docker-compose.base.yml -f docker-compose.prod.yml ps

# 4. 서비스 중지
docker-compose -f docker-compose.base.yml -f docker-compose.prod.yml down
```

### Linux/Mac
```bash
# 운영 환경 실행 (Docker Compose)
./scripts/prod.sh

# 또는 수동으로 Docker Compose 실행
# 1. 공통 데이터베이스 서비스 시작
docker-compose -f docker-compose.base.yml up -d

# 2. 운영 환경 애플리케이션 시작 (백그라운드)
docker-compose -f docker-compose.base.yml -f docker-compose.prod.yml up --build -d

# 3. 서비스 상태 확인
docker-compose -f docker-compose.base.yml -f docker-compose.prod.yml ps

# 4. 서비스 중지
docker-compose -f docker-compose.base.yml -f docker-compose.prod.yml down
```

## 🔧 환경별 설정 차이점

### 개발 환경 (development)
- **API URL**: `http://localhost:8000`
- **Frontend URL**: `http://localhost:3000`
- **데이터베이스**: PostgreSQL (공통 사용)
- **CORS**: 모든 origin 허용 (`*`)
- **디버그**: 활성화
- **Hot Reload**: 활성화 (코드 변경 시 자동 재시작)
- **볼륨 마운트**: 소스 코드 실시간 반영

### 운영 환경 (production)
- **API URL**: `https://api.goldencircle.us`
- **Frontend URL**: `https://app.goldencircle.us`
- **데이터베이스**: PostgreSQL (공통 사용)
- **CORS**: 특정 도메인만 허용
- **디버그**: 비활성화
- **Hot Reload**: 비활성화
- **볼륨 마운트**: 최소한의 마운트

## 🗄️ 공통 데이터베이스 사용

### 데이터베이스 공유 구조
- **PostgreSQL**: 개발/운영 환경에서 동일한 데이터베이스 사용
- **Redis**: 캐싱용으로 공통 사용
- **Neo4j**: RAG용 그래프 데이터베이스 공통 사용

### 데이터 분리 방법
- **스키마 분리**: `dev_` 접두사로 개발용 테이블 구분
- **데이터베이스 분리**: 환경별로 다른 데이터베이스 사용 (권장)
- **네임스페이스 분리**: 애플리케이션 레벨에서 데이터 분리

## 📋 환경 변수 목록

### 공통 환경 변수
- `ENV`: 환경 설정 (development/production)
- `NODE_ENV`: Node.js 환경 설정
- `DEBUG`: 디버그 모드 활성화 여부

### 프론트엔드 환경 변수
- `NUXT_PUBLIC_API_BASE_URL`: API 서버 URL
- `NUXT_PUBLIC_ENV`: 프론트엔드 환경 설정
- `NUXT_PUBLIC_DEBUG`: 프론트엔드 디버그 모드
- `NUXT_PUBLIC_WS_BASE_URL`: WebSocket 서버 URL

### 백엔드 환경 변수
- `DATABASE_URL`: 데이터베이스 연결 URL
- `HOST`: 서버 호스트
- `PORT`: 서버 포트
- `LOG_LEVEL`: 로그 레벨
- `GEMINI_API_KEY`: Gemini API 키
- `MCP_API_KEY`: MCP API 키
- `DISABLE_AUTH`: 인증 비활성화 여부
- `KB_PUBLIC_READ`: 지식베이스 공개 읽기 여부

## 🚨 주의사항

1. **개발 환경**: 로컬 개발 시에는 `scripts/dev.bat` 또는 `scripts/dev.sh` 사용
2. **운영 환경**: 실제 서비스 배포 시에는 `scripts/prod.bat` 또는 `scripts/prod.sh` 사용
3. **환경 변수**: 각 환경에 맞는 환경 변수가 올바르게 설정되었는지 확인
4. **포트 충돌**: 8000번 포트가 다른 서비스에서 사용 중인지 확인
5. **데이터베이스**: 운영 환경에서는 PostgreSQL 사용, 개발 환경에서는 SQLite 사용
