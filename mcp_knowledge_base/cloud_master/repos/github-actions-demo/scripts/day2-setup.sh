#!/bin/bash
# Day2 - Advanced CI/CD with Docker Compose Setup Script
# Cloud Master Day2 강의안 기반

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 로그 함수
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

log_info "🚀 Cloud Master Day2 - Advanced CI/CD with Docker Compose Setup 시작"

# 1. 환경 변수 설정
log_info "📋 환경 변수 설정 중..."
if [ ! -f .env ]; then
    cp .env.example .env
    log_success ".env 파일 생성 완료"
else
    log_info ".env 파일이 이미 존재합니다"
fi

# 환경 변수 추가
cat >> .env << EOF

# Day2 Advanced Configuration
NODE_ENV=production
DATABASE_URL=postgresql://postgres:postgres@db:5432/github_actions_demo
REDIS_URL=redis://redis:6379
PROMETHEUS_ENABLED=true
GRAFANA_ENABLED=true
EOF

# 2. 의존성 설치
log_info "📦 의존성 설치 중..."
npm install

# 3. PostgreSQL 클라이언트 설치
log_info "🗄️ PostgreSQL 클라이언트 설치 중..."
npm install pg

# 4. Redis 클라이언트 설치
log_info "🔴 Redis 클라이언트 설치 중..."
npm install redis

# 5. Prometheus 클라이언트 설치
log_info "📊 Prometheus 클라이언트 설치 중..."
npm install prom-client

# 6. Docker Compose 스택 빌드
log_info "🐳 Docker Compose 스택 빌드 중..."
docker-compose -f docker-compose.day2.yml build

# 7. 데이터베이스 초기화
log_info "🗄️ 데이터베이스 초기화 중..."
docker-compose -f docker-compose.day2.yml up -d db
sleep 10

# 8. 전체 스택 시작
log_info "🚀 전체 스택 시작 중..."
docker-compose -f docker-compose.day2.yml up -d

# 9. 서비스 상태 확인
log_info "🔍 서비스 상태 확인 중..."
sleep 30
docker-compose -f docker-compose.day2.yml ps

# 10. 헬스 체크
log_info "🔍 헬스 체크 중..."
services=("web" "db" "redis" "nginx" "prometheus" "grafana")
for service in "${services[@]}"; do
    if docker-compose -f docker-compose.day2.yml ps | grep -q "$service.*Up"; then
        log_success "✅ $service 서비스가 정상적으로 실행되고 있습니다"
    else
        log_error "❌ $service 서비스 실행에 실패했습니다"
    fi
done

# 11. 애플리케이션 테스트
log_info "🧪 애플리케이션 테스트 중..."

# 기본 엔드포인트 테스트
if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    log_success "✅ 애플리케이션이 정상적으로 실행되고 있습니다"
else
    log_error "❌ 애플리케이션 실행에 실패했습니다"
fi

# API 엔드포인트 테스트
if curl -f http://localhost:3000/api/info > /dev/null 2>&1; then
    log_success "✅ API 엔드포인트가 정상적으로 작동합니다"
else
    log_error "❌ API 엔드포인트 테스트에 실패했습니다"
fi

# 데이터베이스 연결 테스트
if curl -f http://localhost:3000/api/db/test > /dev/null 2>&1; then
    log_success "✅ 데이터베이스 연결이 정상입니다"
else
    log_error "❌ 데이터베이스 연결 테스트에 실패했습니다"
fi

# Redis 연결 테스트
if curl -f http://localhost:3000/api/redis/test > /dev/null 2>&1; then
    log_success "✅ Redis 연결이 정상입니다"
else
    log_error "❌ Redis 연결 테스트에 실패했습니다"
fi

# 메트릭 엔드포인트 테스트
if curl -f http://localhost:3000/metrics > /dev/null 2>&1; then
    log_success "✅ Prometheus 메트릭이 정상적으로 수집되고 있습니다"
else
    log_error "❌ Prometheus 메트릭 수집에 실패했습니다"
fi

# 12. Nginx 로드밸런서 테스트
log_info "⚖️ Nginx 로드밸런서 테스트 중..."
if curl -f http://localhost/health > /dev/null 2>&1; then
    log_success "✅ Nginx 로드밸런서가 정상적으로 작동합니다"
else
    log_error "❌ Nginx 로드밸런서 테스트에 실패했습니다"
fi

# 13. 모니터링 대시보드 확인
log_info "📊 모니터링 대시보드 확인 중..."
log_info "📈 Prometheus: http://localhost:9090"
log_info "📊 Grafana: http://localhost:3001 (admin/admin)"

# 14. 로그 확인
log_info "📋 서비스 로그 확인 중..."
docker-compose -f docker-compose.day2.yml logs --tail=10

log_success "🎉 Day2 고급 CI/CD with Docker Compose 설정 완료!"
log_info "📋 다음 단계:"
log_info "1. GitHub 저장소에 코드 푸시"
log_info "2. GitHub Actions Matrix Build 실행 확인"
log_info "3. Docker Compose 스택 배포"
log_info "4. 모니터링 대시보드 설정"
log_info "5. 환경별 배포 테스트"

log_info "🔗 접속 정보:"
log_info "• 애플리케이션: http://localhost:3000"
log_info "• Nginx: http://localhost"
log_info "• Prometheus: http://localhost:9090"
log_info "• Grafana: http://localhost:3001"