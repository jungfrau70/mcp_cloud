#!/bin/bash

# =============================================================================
# Docker Advanced 실습 - 구체적 비교 데모 스크립트
# =============================================================================
# 
# 기능:
#   - 멀티스테이지 빌드 vs 단일 스테이지 빌드 비교
#   - 이미지 최적화 전후 비교
#   - 보안 스캔 결과 비교
#   - 구체적인 수치와 시각적 비교 제공
#
# 사용법:
#   ./docker-comparison-demo.sh
#
# 작성일: 2024-01-XX
# 작성자: Cloud Intermediate 과정
# =============================================================================

set -euo pipefail

# 스크립트 디렉토리 설정
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR="$SCRIPT_DIR/docker-demo"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 로그 함수
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}[HEADER]${NC} $1"; }
log_comparison() { echo -e "${CYAN}[COMPARISON]${NC} $1"; }

# =============================================================================
# 데모 환경 준비
# =============================================================================
setup_demo_environment() {
    log_header "=== Docker Advanced 실습 데모 환경 준비 ==="
    
    # 데모 디렉토리 생성
    mkdir -p "$DEMO_DIR"
    cd "$DEMO_DIR"
    
    # 샘플 Node.js 애플리케이션 생성
    create_sample_app
    
    log_success "데모 환경 준비 완료"
}

# =============================================================================
# 샘플 애플리케이션 생성
# =============================================================================
create_sample_app() {
    log_info "샘플 Node.js 애플리케이션 생성 중..."
    
    # package.json 생성
    cat > package.json << 'EOF'
{
  "name": "docker-comparison-demo",
  "version": "1.0.0",
  "description": "Docker Advanced 실습용 샘플 애플리케이션",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "build": "echo 'Build completed'"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.0.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.1",
    "jest": "^29.5.0",
    "eslint": "^8.42.0"
  }
}
EOF

    # server.js 생성
    cat > server.js << 'EOF'
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const PORT = process.env.PORT || 3000;

// 미들웨어 설정
app.use(helmet());
app.use(cors());
app.use(express.json());

// 라우트 정의
app.get('/', (req, res) => {
    res.json({
        message: 'Docker Advanced 실습 데모 애플리케이션',
        version: '1.0.0',
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'development'
    });
});

app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        uptime: process.uptime(),
        memory: process.memoryUsage()
    });
});

app.get('/api/info', (req, res) => {
    res.json({
        nodeVersion: process.version,
        platform: process.platform,
        arch: process.arch,
        pid: process.pid
    });
});

// 서버 시작
app.listen(PORT, '0.0.0.0', () => {
    console.log(`서버가 포트 ${PORT}에서 실행 중입니다.`);
    console.log(`환경: ${process.env.NODE_ENV || 'development'}`);
});
EOF

    # .dockerignore 생성
    cat > .dockerignore << 'EOF'
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.nyc_output
coverage
.nyc_output
.coverage
Dockerfile*
docker-compose*
EOF

    # README.md 생성
    cat > README.md << 'EOF'
# Docker Advanced 실습 데모 애플리케이션

이 애플리케이션은 Docker 고급 실습을 위한 샘플 애플리케이션입니다.

## 기능
- Express.js 기반 웹 서버
- 헬스 체크 엔드포인트
- 시스템 정보 API
- 보안 미들웨어 적용

## 실행 방법
```bash
npm install
npm start
```

## API 엔드포인트
- GET / - 기본 정보
- GET /health - 헬스 체크
- GET /api/info - 시스템 정보
EOF

    log_success "샘플 애플리케이션 생성 완료"
}

# =============================================================================
# Original Dockerfile 생성
# =============================================================================
create_original_dockerfile() {
    log_info "Original Dockerfile 생성 중..."
    
    cat > Dockerfile.original << 'EOF'
# =============================================================================
# Original Dockerfile (비교 기준)
# =============================================================================
# 문제점:
# - Ubuntu 기반으로 무거움
# - 개발 의존성 포함
# - Root 사용자로 실행
# - 불필요한 파일 포함
# - 레이어 최적화 없음
# =============================================================================

FROM node:18

# 작업 디렉토리 설정
WORKDIR /app

# 모든 파일 복사 (캐시 최적화 없음)
COPY . .

# 모든 의존성 설치 (개발 의존성 포함)
RUN npm install

# 포트 노출
EXPOSE 3000

# Root 사용자로 실행 (보안 취약)
CMD ["npm", "start"]
EOF

    log_success "Original Dockerfile 생성 완료"
}

# =============================================================================
# Optimized Dockerfile 생성
# =============================================================================
create_optimized_dockerfile() {
    log_info "Optimized Dockerfile 생성 중..."
    
    cat > Dockerfile.optimized << 'EOF'
# =============================================================================
# Optimized Dockerfile (단일 스테이지 최적화)
# =============================================================================
# 개선사항:
# - Alpine Linux 사용으로 크기 감소
# - .dockerignore 활용
# - 레이어 캐싱 최적화
# - Production 의존성만 설치
# - Non-root 사용자 설정
# =============================================================================

FROM node:18-alpine

# 작업 디렉토리 설정
WORKDIR /app

# 의존성 파일만 먼저 복사 (캐시 최적화)
COPY package*.json ./

# Production 의존성만 설치
RUN npm install --only=production && npm cache clean --force

# 애플리케이션 코드 복사
COPY . .

# 보안을 위한 non-root 사용자 생성
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# 파일 소유권 변경
RUN chown -R nextjs:nodejs /app

# Non-root 사용자로 전환
USER nextjs

# 포트 노출
EXPOSE 3000

# 애플리케이션 실행
CMD ["npm", "start"]
EOF

    log_success "Optimized Dockerfile 생성 완료"
}

# =============================================================================
# Multistage Dockerfile 생성
# =============================================================================
create_multistage_dockerfile() {
    log_info "Multistage Dockerfile 생성 중..."
    
    cat > Dockerfile.multistage << 'EOF'
# =============================================================================
# Multistage Dockerfile (멀티스테이지 빌드)
# =============================================================================
# 개선사항:
# - 빌드 도구와 런타임 환경 분리
# - 최종 이미지에 빌드 도구 제외
# - 더 작은 이미지 크기
# - 보안 강화 (최소 권한)
# - 레이어 최적화
# =============================================================================

# Build stage
FROM node:18-alpine AS builder
WORKDIR /app

# 의존성 파일만 먼저 복사 (캐시 최적화)
COPY package*.json ./
RUN npm install --only=production && npm cache clean --force

# 애플리케이션 코드 복사
COPY . .

# Production stage
FROM node:18-alpine AS runtime
WORKDIR /app

# 보안을 위한 non-root 사용자 생성
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# 빌드된 파일만 복사 (빌드 도구 제외)
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nextjs:nodejs /app ./

# Non-root 사용자로 전환
USER nextjs

# 포트 노출
EXPOSE 3000

# 애플리케이션 실행
CMD ["npm", "start"]
EOF

    log_success "Multistage Dockerfile 생성 완료"
}


# =============================================================================
# 이미지 빌드 및 비교
# =============================================================================
build_and_compare_images() {
    log_header "=== Docker 이미지 빌드 및 비교 ==="
    
    # 이미지 빌드
    log_info "Original 이미지 빌드 중..."
    docker build -f Dockerfile.original -t demo-app:original .
    
    log_info "Optimized 이미지 빌드 중..."
    docker build -f Dockerfile.optimized -t demo-app:optimized .
    
    log_info "Multistage 이미지 빌드 중..."
    docker build -f Dockerfile.multistage -t demo-app:multistage .
    
    # 이미지 크기 비교
    compare_image_sizes
    
    # 이미지 레이어 분석
    analyze_image_layers
    
    # 보안 스캔
    security_scan_images
}

# =============================================================================
# 이미지 크기 비교
# =============================================================================
compare_image_sizes() {
    log_header "=== 이미지 크기 비교 ==="
    
    echo ""
    log_comparison "이미지 크기 비교 결과:"
    echo "=========================================="
    
    # 이미지 크기 정보 추출
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep demo-app
    
    echo ""
    log_comparison "상세 크기 분석:"
    echo "=========================================="
    
    # 각 이미지의 상세 크기 정보
    for tag in original optimized multistage; do
        size=$(docker images --format "{{.Size}}" demo-app:$tag)
        log_info "demo-app:$tag = $size"
    done
    
    # 비교 테이블 생성
    generate_comparison_table
    
    echo ""
    log_comparison "크기 최적화 효과:"
    echo "=========================================="
    
    # 크기 비교 계산
    original_size=$(docker images --format "{{.Size}}" demo-app:original | sed 's/[^0-9.]//g')
    optimized_size=$(docker images --format "{{.Size}}" demo-app:optimized | sed 's/[^0-9.]//g')
    multistage_size=$(docker images --format "{{.Size}}" demo-app:multistage | sed 's/[^0-9.]//g')
    
    if [[ "$original_size" =~ ^[0-9.]+$ ]] && [[ "$optimized_size" =~ ^[0-9.]+$ ]]; then
        reduction=$(echo "scale=2; ($original_size - $optimized_size) / $original_size * 100" | bc -l 2>/dev/null || echo "계산 불가")
        log_success "Optimized로 ${reduction}% 크기 감소"
    fi
    
    if [[ "$original_size" =~ ^[0-9.]+$ ]] && [[ "$multistage_size" =~ ^[0-9.]+$ ]]; then
        reduction=$(echo "scale=2; ($original_size - $multistage_size) / $original_size * 100" | bc -l 2>/dev/null || echo "계산 불가")
        log_success "Multistage로 ${reduction}% 크기 감소"
    fi
}

# =============================================================================
# 비교 테이블 생성
# =============================================================================
generate_comparison_table() {
    log_header "=== Dockerfile 비교 테이블 ==="
    
    echo ""
    echo "┌─────────────────┬─────────────────┬─────────────────┬─────────────────┐"
    echo "│     항목        │    Original     │    Optimized    │   Multistage    │"
    echo "├─────────────────┼─────────────────┼─────────────────┼─────────────────┤"
    echo "│ Base Image      │   node:18       │  node:18-alpine │  node:18-alpine │"
    echo "│ Build Stages    │        1        │        1        │        2        │"
    echo "│ Dependencies    │   All (dev+prod)│   Production    │   Production    │"
    echo "│ User            │     Root        │   Non-root      │   Non-root      │"
    echo "│ Security        │      Low        │     Medium      │      High       │"
    echo "│ Cache Strategy  │      None       │   Layer Cache   │   Layer Cache   │"
    echo "│ Build Tools     │   Included      │   Included      │   Excluded      │"
    echo "│ Image Size      │     Large       │     Medium      │     Small       │"
    echo "│ Build Time      │     Fast        │     Medium      │     Medium      │"
    echo "│ Runtime Perf    │     Medium      │     Good        │     Best        │"
    echo "└─────────────────┴─────────────────┴─────────────────┴─────────────────┘"
    
    echo ""
    log_comparison "특징별 상세 비교:"
    echo "=========================================="
    
    # 크기 비교 테이블
    echo ""
    echo "📊 이미지 크기 비교:"
    echo "┌─────────────────┬─────────────────┬─────────────────┬─────────────────┐"
    echo "│     이미지      │      크기       │   레이어 수     │   압축률        │"
    echo "├─────────────────┼─────────────────┼─────────────────┼─────────────────┤"
    
    for tag in original optimized multistage; do
        size=$(docker images --format "{{.Size}}" demo-app:$tag)
        layers=$(docker history demo-app:$tag --format "{{.CreatedBy}}" | wc -l)
        echo "│ demo-app:$tag    │     $size      │       $layers        │      N/A       │"
    done
    
    echo "└─────────────────┴─────────────────┴─────────────────┴─────────────────┘"
    
    # 보안 비교 테이블
    echo ""
    echo "🔒 보안 비교:"
    echo "┌─────────────────┬─────────────────┬─────────────────┬─────────────────┐"
    echo "│     항목        │    Original     │    Optimized    │   Multistage    │"
    echo "├─────────────────┼─────────────────┼─────────────────┼─────────────────┤"
    echo "│ Root User       │       ✅        │       ❌        │       ❌        │"
    echo "│ Dev Dependencies│       ✅        │       ❌        │       ❌        │"
    echo "│ Build Tools     │       ✅        │       ✅        │       ❌        │"
    echo "│ Attack Surface  │      Large      │     Medium      │     Small       │"
    echo "│ CVE Risk        │      High       │     Medium      │      Low        │"
    echo "└─────────────────┴─────────────────┴─────────────────┴─────────────────┘"
    
    # 성능 비교 테이블
    echo ""
    echo "⚡ 성능 비교:"
    echo "┌─────────────────┬─────────────────┬─────────────────┬─────────────────┐"
    echo "│     항목        │    Original     │    Optimized    │   Multistage    │"
    echo "├─────────────────┼─────────────────┼─────────────────┼─────────────────┤"
    echo "│ Startup Time    │     Medium      │      Fast       │      Fast       │"
    echo "│ Memory Usage    │      High       │     Medium      │      Low        │"
    echo "│ Network I/O     │      High       │     Medium      │      Low        │"
    echo "│ Storage I/O     │      High       │     Medium      │      Low        │"
    echo "│ CPU Usage       │     Medium      │     Medium      │      Low        │"
    echo "└─────────────────┴─────────────────┴─────────────────┴─────────────────┘"
}

# =============================================================================
# 이미지 레이어 분석
# =============================================================================
analyze_image_layers() {
    log_header "=== 이미지 레이어 분석 ==="
    
    echo ""
    log_comparison "Original 이미지 레이어:"
    echo "=========================================="
    docker history demo-app:original --format "table {{.CreatedBy}}\t{{.Size}}"
    
    echo ""
    log_comparison "Optimized 이미지 레이어:"
    echo "=========================================="
    docker history demo-app:optimized --format "table {{.CreatedBy}}\t{{.Size}}"
    
    echo ""
    log_comparison "Multistage 이미지 레이어:"
    echo "=========================================="
    docker history demo-app:multistage --format "table {{.CreatedBy}}\t{{.Size}}"
}

# =============================================================================
# 보안 스캔
# =============================================================================
security_scan_images() {
    log_header "=== 보안 스캔 결과 ==="
    
    # Trivy 설치 확인
    if ! command -v trivy &> /dev/null; then
        log_warning "Trivy가 설치되지 않았습니다. Docker를 사용하여 스캔합니다."
        scan_with_docker_trivy
    else
        scan_with_local_trivy
    fi
}

# =============================================================================
# Docker Trivy로 보안 스캔
# =============================================================================
scan_with_docker_trivy() {
    log_info "Docker Trivy로 보안 스캔 중..."
    
    for tag in original optimized multistage; do
        echo ""
        log_comparison "demo-app:$tag 보안 스캔 결과:"
        echo "=========================================="
        
        docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
            aquasec/trivy image demo-app:$tag --format table --severity HIGH,CRITICAL
    done
}

# =============================================================================
# 로컬 Trivy로 보안 스캔
# =============================================================================
scan_with_local_trivy() {
    log_info "로컬 Trivy로 보안 스캔 중..."
    
    for tag in original optimized multistage; do
        echo ""
        log_comparison "demo-app:$tag 보안 스캔 결과:"
        echo "=========================================="
        
        trivy image demo-app:$tag --format table --severity HIGH,CRITICAL
    done
}

# =============================================================================
# 컨테이너 실행 테스트
# =============================================================================
test_container_execution() {
    log_header "=== 컨테이너 실행 테스트 ==="
    
    for tag in original optimized multistage; do
        echo ""
        log_comparison "demo-app:$tag 실행 테스트:"
        echo "=========================================="
        
        # 컨테이너 실행
        container_id=$(docker run -d -p 3000:3000 --name "demo-app-$tag" demo-app:$tag)
        
        # 잠시 대기
        sleep 3
        
        # 헬스 체크
        if curl -s http://localhost:3000/health > /dev/null; then
            log_success "demo-app:$tag 정상 실행됨"
            
            # API 테스트
            echo "API 응답:"
            curl -s http://localhost:3000/ | jq . 2>/dev/null || curl -s http://localhost:3000/
        else
            log_error "demo-app:$tag 실행 실패"
        fi
        
        # 컨테이너 정리
        docker stop "$container_id" > /dev/null
        docker rm "$container_id" > /dev/null
    done
}

# =============================================================================
# 성능 비교
# =============================================================================
performance_comparison() {
    log_header "=== 성능 비교 ==="
    
    echo ""
    log_comparison "컨테이너 시작 시간 비교:"
    echo "=========================================="
    
    for tag in original optimized multistage; do
        echo ""
        log_info "demo-app:$tag 시작 시간 측정 중..."
        
        # 시작 시간 측정
        start_time=$(date +%s.%N)
        container_id=$(docker run -d -p 3000:3000 --name "demo-app-$tag" demo-app:$tag)
        
        # 헬스 체크 대기
        while ! curl -s http://localhost:3000/health > /dev/null; do
            sleep 0.1
        done
        
        end_time=$(date +%s.%N)
        duration=$(echo "$end_time - $start_time" | bc -l)
        
        log_success "demo-app:$tag 시작 시간: ${duration}초"
        
        # 컨테이너 정리
        docker stop "$container_id" > /dev/null
        docker rm "$container_id" > /dev/null
    done
}

# =============================================================================
# 정리 함수
# =============================================================================
cleanup_demo() {
    log_header "=== 데모 환경 정리 ==="
    
    # 실행 중인 컨테이너 정리
    docker ps -a --filter "name=demo-app-" --format "{{.Names}}" | xargs -r docker rm -f
    
    # 이미지 정리
    docker rmi demo-app:original demo-app:optimized demo-app:multistage 2>/dev/null || true
    
    # 데모 디렉토리 정리
    cd "$SCRIPT_DIR"
    rm -rf "$DEMO_DIR"
    
    log_success "데모 환경 정리 완료"
}

# =============================================================================
# 메인 실행 함수
# =============================================================================
main() {
    log_header "=== Docker Advanced 실습 - 구체적 비교 데모 ==="
    
    # 데모 환경 준비
    setup_demo_environment
    
    # Dockerfile 생성
    create_original_dockerfile
    create_optimized_dockerfile
    create_multistage_dockerfile
    
    # 이미지 빌드 및 비교
    build_and_compare_images
    
    # 컨테이너 실행 테스트
    test_container_execution
    
    # 성능 비교
    performance_comparison
    
    # 정리 여부 확인
    echo ""
    read -p "데모 환경을 정리하시겠습니까? (y/N): " cleanup_choice
    if [[ "$cleanup_choice" =~ ^[Yy]$ ]]; then
        cleanup_demo
    else
        log_info "데모 환경이 유지됩니다: $DEMO_DIR"
    fi
    
    log_success "Docker Advanced 실습 데모 완료!"
}

# =============================================================================
# 스크립트 실행
# =============================================================================
main "$@"
