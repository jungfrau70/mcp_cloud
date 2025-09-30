#!/bin/bash

# Docker Helper 모듈
# 역할: Docker 고급 실습 관련 작업 실행 (멀티스테이지 빌드, 이미지 최적화, 보안 스캔)
# 
# 사용법:
#   ./docker-helper.sh --action <액션> [옵션]

# =============================================================================
# 환경 설정 로드
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 공통 환경 설정 로드
if [ -f "$SCRIPT_DIR/common-environment.env" ]; then
    source "$SCRIPT_DIR/common-environment.env"
else
    echo "ERROR: 공통 환경 설정 파일을 찾을 수 없습니다"
    exit 1
fi

# =============================================================================
# 사용법 출력
# =============================================================================
usage() {
    cat << EOF
Docker Helper 모듈

사용법:
  $0 --action <액션> [옵션]

액션:
  multistage-build        # 멀티스테이지 빌드 실습
  optimize-image          # 이미지 최적화 실습
  security-scan           # 보안 스캔 실습
  cleanup                 # Docker 리소스 정리
  status                  # Docker 상태 확인

옵션:
  --image-name <name>     # 이미지 이름 (기본값: myapp)
  --tag <tag>             # 이미지 태그 (기본값: latest)
  --help, -h              # 도움말 표시

예시:
  $0 --action multistage-build
  $0 --action optimize-image --image-name myapp --tag optimized
  $0 --action security-scan --image-name myapp
  $0 --action cleanup
EOF
}

# =============================================================================
# 액션별 상세 사용법 함수
# =============================================================================
show_action_help() {
    local action="$1"
    
    case "$action" in
        "multistage-build")
            cat << EOF
MULTISTAGE-BUILD 액션 상세 사용법:

기능:
  - 멀티스테이지 빌드를 통한 Docker 이미지 최적화
  - 빌드 도구와 런타임 환경 분리
  - 이미지 크기 최적화 및 보안 강화

사용법:
  $0 --action multistage-build [옵션]

옵션:
  --image-name <name>     # 이미지 이름 (기본값: myapp)
  --tag <tag>             # 이미지 태그 (기본값: multistage)

예시:
  $0 --action multistage-build
  $0 --action multistage-build --image-name myapp --tag v1.0

생성되는 리소스:
  - 멀티스테이지 Dockerfile
  - 최적화된 Docker 이미지
  - 이미지 크기 비교 보고서

진행 상황:
  - Dockerfile 생성
  - 멀티스테이지 빌드 실행
  - 이미지 크기 비교
  - 최적화 결과 보고
EOF
            ;;
        "optimize-image")
            cat << EOF
OPTIMIZE-IMAGE 액션 상세 사용법:

기능:
  - Alpine Linux 기반 경량 이미지 생성
  - .dockerignore 파일 활용
  - 레이어 최적화 및 캐싱 활용

사용법:
  $0 --action optimize-image [옵션]

옵션:
  --image-name <name>     # 이미지 이름 (기본값: myapp)
  --tag <tag>             # 이미지 태그 (기본값: optimized)

예시:
  $0 --action optimize-image
  $0 --action optimize-image --image-name myapp --tag alpine

생성되는 리소스:
  - 최적화된 Dockerfile
  - .dockerignore 파일
  - Alpine 기반 이미지
  - 최적화 보고서

진행 상황:
  - .dockerignore 생성
  - 최적화된 Dockerfile 생성
  - 이미지 빌드
  - 최적화 결과 확인
EOF
            ;;
        "security-scan")
            cat << EOF
SECURITY-SCAN 액션 상세 사용법:

기능:
  - Trivy를 사용한 Docker 이미지 보안 스캔
  - 취약점 검사 및 보고서 생성
  - 보안 강화 권장사항 제공

사용법:
  $0 --action security-scan [옵션]

옵션:
  --image-name <name>     # 스캔할 이미지 이름 (기본값: myapp)
  --tag <tag>             # 이미지 태그 (기본값: latest)

예시:
  $0 --action security-scan
  $0 --action security-scan --image-name myapp --tag latest

생성되는 리소스:
  - 보안 스캔 보고서
  - 취약점 목록
  - 보안 강화 권장사항

진행 상황:
  - Trivy 도구 설치
  - 이미지 보안 스캔 실행
  - 취약점 분석
  - 보고서 생성
EOF
            ;;
        "cleanup")
            cat << EOF
CLEANUP 액션 상세 사용법:

기능:
  - Docker 이미지, 컨테이너, 볼륨 정리
  - 불필요한 리소스 제거
  - 디스크 공간 확보

사용법:
  $0 --action cleanup [옵션]

옵션:
  --force                 # 확인 없이 강제 정리
  --keep-images <pattern> # 유지할 이미지 패턴

예시:
  $0 --action cleanup
  $0 --action cleanup --force
  $0 --action cleanup --keep-images "ubuntu|alpine"

정리되는 리소스:
  - 중지된 컨테이너
  - 사용하지 않는 이미지
  - 사용하지 않는 볼륨
  - 사용하지 않는 네트워크

주의사항:
  - 정리된 리소스는 복구할 수 없습니다
  - --force 옵션 사용 시 확인 없이 정리됩니다
EOF
            ;;
        "status")
            cat << EOF
STATUS 액션 상세 사용법:

기능:
  - Docker 시스템 상태 확인
  - 이미지 및 컨테이너 목록 표시
  - 리소스 사용량 확인

사용법:
  $0 --action status [옵션]

옵션:
  --format <format>       # 출력 형식 (table, json, yaml)
  --verbose               # 상세 정보 출력

예시:
  $0 --action status
  $0 --action status --format json --verbose

확인되는 정보:
  - Docker 버전 및 상태
  - 이미지 목록 및 크기
  - 컨테이너 목록 및 상태
  - 디스크 사용량
  - 네트워크 정보

출력 형식:
  - table: 테이블 형태 (기본값)
  - json: JSON 형태
  - yaml: YAML 형태
EOF
            ;;
        *)
            cat << EOF
알 수 없는 액션: $action

사용 가능한 액션:
  - multistage-build: 멀티스테이지 빌드
  - optimize-image: 이미지 최적화
  - security-scan: 보안 스캔
  - cleanup: 리소스 정리
  - status: 상태 확인

각 액션의 상세 사용법을 보려면:
  $0 --help --action <액션명>
EOF
            ;;
    esac
}

# =============================================================================
# --help 옵션 처리 로직
# =============================================================================
handle_help_option() {
    local action="$1"
    
    if [ -n "$action" ]; then
        show_action_help "$action"
    else
        usage
    fi
    exit 0
}

# =============================================================================
# 환경 검증
# =============================================================================
validate_environment() {
    log_step "Docker 환경 검증 중..."
    
    # Docker 설치 확인
    if ! check_command "docker"; then
        log_error "Docker가 설치되지 않았습니다."
        return 1
    fi
    
    # Docker 서비스 상태 확인
    if ! docker info &> /dev/null; then
        log_error "Docker 서비스가 실행되지 않았습니다."
        return 1
    fi
    
    log_success "Docker 환경 검증 완료"
    return 0
}

# =============================================================================
# 멀티스테이지 빌드
# =============================================================================
multistage_build() {
    local image_name="${1:-myapp}"
    local tag="${2:-multistage}"
    
    log_header "Docker 멀티스테이지 빌드: $image_name:$tag"
    
    # 멀티스테이지 Dockerfile 생성
    log_info "멀티스테이지 Dockerfile 생성 중..."
    cat > Dockerfile.multistage << 'EOF'
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Production stage
FROM node:18-alpine AS production
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001
USER nextjs
EXPOSE 3000
CMD ["node", "server.js"]
EOF
    
    # 기존 이미지 크기 확인
    log_info "기존 이미지 크기 확인 중..."
    local original_size=0
    if docker images "$image_name:latest" --format "{{.Size}}" | grep -q "MB\|GB"; then
        original_size=$(docker images "$image_name:latest" --format "{{.Size}}" | sed 's/[^0-9.]//g')
    fi
    
    # 멀티스테이지 빌드 실행
    log_info "멀티스테이지 빌드 실행 중..."
    update_progress "multistage-build" "started" "멀티스테이지 빌드 시작"
    
    if docker build -f Dockerfile.multistage -t "$image_name:$tag" .; then
        log_success "멀티스테이지 빌드 완료: $image_name:$tag"
        update_progress "multistage-build" "completed" "멀티스테이지 빌드 완료"
        
        # 이미지 크기 비교
        log_info "이미지 크기 비교:"
        docker images | grep "$image_name" | head -2
        
        # 정리
        rm -f Dockerfile.multistage
        return 0
    else
        log_error "멀티스테이지 빌드 실패"
        update_progress "multistage-build" "failed" "멀티스테이지 빌드 실패"
        return 1
    fi
}

# =============================================================================
# 이미지 최적화
# =============================================================================
optimize_image() {
    local image_name="${1:-myapp}"
    local tag="${2:-optimized}"
    
    log_header "Docker 이미지 최적화: $image_name:$tag"
    
    # .dockerignore 파일 생성
    log_info ".dockerignore 파일 생성 중..."
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
EOF
    
    # 최적화된 Dockerfile 생성
    log_info "최적화된 Dockerfile 생성 중..."
    cat > Dockerfile.optimized << 'EOF'
FROM node:18-alpine
WORKDIR /app

# 보안 강화: non-root 사용자 생성
RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001

# 패키지 설치 및 정리
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# 소스 코드 복사 및 권한 설정
COPY --chown=nextjs:nodejs . .
USER nextjs

EXPOSE 3000
CMD ["node", "server.js"]
EOF
    
    # 최적화된 이미지 빌드
    log_info "최적화된 이미지 빌드 중..."
    update_progress "optimize-image" "started" "이미지 최적화 시작"
    
    if docker build -f Dockerfile.optimized -t "$image_name:$tag" .; then
        log_success "이미지 최적화 완료: $image_name:$tag"
        update_progress "optimize-image" "completed" "이미지 최적화 완료"
        
        # 최적화 결과 확인
        log_info "최적화 결과:"
        docker images | grep "$image_name" | head -2
        
        # 정리
        rm -f Dockerfile.optimized
        return 0
    else
        log_error "이미지 최적화 실패"
        update_progress "optimize-image" "failed" "이미지 최적화 실패"
        return 1
    fi
}

# =============================================================================
# 보안 스캔
# =============================================================================
security_scan() {
    local image_name="${1:-myapp}"
    local tag="${2:-latest}"
    
    log_header "Docker 이미지 보안 스캔: $image_name:$tag"
    
    # Trivy 설치 확인
    if ! command -v trivy &> /dev/null; then
        log_info "Trivy 설치 중..."
        if ! docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
            aquasec/trivy image "$image_name:$tag"; then
            log_error "Trivy 설치 실패"
            return 1
        fi
    fi
    
    # 보안 스캔 실행
    log_info "보안 스캔 실행 중..."
    update_progress "security-scan" "started" "보안 스캔 시작"
    
    if docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
        aquasec/trivy image "$image_name:$tag" --format table; then
        log_success "보안 스캔 완료: $image_name:$tag"
        update_progress "security-scan" "completed" "보안 스캔 완료"
        return 0
    else
        log_error "보안 스캔 실패"
        update_progress "security-scan" "failed" "보안 스캔 실패"
        return 1
    fi
}

# =============================================================================
# Docker 리소스 정리
# =============================================================================
cleanup_docker() {
    local force="${1:-false}"
    
    log_header "Docker 리소스 정리"
    
    if [ "$force" != "true" ]; then
        log_warning "정리할 리소스:"
        log_info "중지된 컨테이너: $(docker ps -a --filter status=exited -q | wc -l)개"
        log_info "사용하지 않는 이미지: $(docker images -f dangling=true -q | wc -l)개"
        log_info "사용하지 않는 볼륨: $(docker volume ls -f dangling=true -q | wc -l)개"
        
        read -p "정말 정리하시겠습니까? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "정리가 취소되었습니다."
            return 0
        fi
    fi
    
    log_info "Docker 리소스 정리 중..."
    update_progress "cleanup" "started" "Docker 리소스 정리 시작"
    
    # 중지된 컨테이너 제거
    log_info "중지된 컨테이너 제거 중..."
    docker container prune -f
    
    # 사용하지 않는 이미지 제거
    log_info "사용하지 않는 이미지 제거 중..."
    docker image prune -f
    
    # 사용하지 않는 볼륨 제거
    log_info "사용하지 않는 볼륨 제거 중..."
    docker volume prune -f
    
    # 사용하지 않는 네트워크 제거
    log_info "사용하지 않는 네트워크 제거 중..."
    docker network prune -f
    
    log_success "Docker 리소스 정리 완료"
    update_progress "cleanup" "completed" "Docker 리소스 정리 완료"
    return 0
}

# =============================================================================
# Docker 상태 확인
# =============================================================================
check_docker_status() {
    local format="${1:-table}"
    
    log_header "Docker 상태 확인"
    
    # Docker 버전 정보
    log_info "Docker 버전:"
    docker --version
    
    # Docker 시스템 정보
    log_info "Docker 시스템 정보:"
    docker system df
    
    # 이미지 목록
    log_info "Docker 이미지 목록:"
    case "$format" in
        "json")
            docker images --format "{{json .}}" | jq .
            ;;
        "yaml")
            docker images --format "{{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedAt}}\t{{.Size}}" | column -t
            ;;
        *)
            docker images
            ;;
    esac
    
    # 컨테이너 목록
    log_info "Docker 컨테이너 목록:"
    case "$format" in
        "json")
            docker ps -a --format "{{json .}}" | jq .
            ;;
        "yaml")
            docker ps -a --format "{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | column -t
            ;;
        *)
            docker ps -a
            ;;
    esac
    
    update_progress "status" "completed" "Docker 상태 확인 완료"
    return 0
}

# =============================================================================
# 메인 실행 로직
# =============================================================================
main() {
    local action=""
    local image_name="myapp"
    local tag="latest"
    local force="false"
    local format="table"
    
    # 인수 파싱
    while [[ $# -gt 0 ]]; do
        case $1 in
            --action)
                action="$2"
                shift 2
                ;;
            --image-name)
                image_name="$2"
                shift 2
                ;;
            --tag)
                tag="$2"
                shift 2
                ;;
            --force)
                force="true"
                shift
                ;;
            --format)
                format="$2"
                shift 2
                ;;
            --help|-h)
                # --help 옵션 처리
                if [ "$2" = "--action" ] && [ -n "$3" ]; then
                    handle_help_option "$3"
                else
                    usage
                    exit 0
                fi
                ;;
            *)
                log_error "알 수 없는 옵션: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # 액션이 지정되지 않은 경우
    if [ -z "$action" ]; then
        log_error "액션이 지정되지 않았습니다."
        usage
        exit 1
    fi
    
    # 환경 검증
    if ! validate_environment; then
        log_error "환경 검증 실패"
        exit 1
    fi
    
    # 액션 실행
    case "$action" in
        "multistage-build")
            multistage_build "$image_name" "$tag"
            ;;
        "optimize-image")
            optimize_image "$image_name" "$tag"
            ;;
        "security-scan")
            security_scan "$image_name" "$tag"
            ;;
        "cleanup")
            cleanup_docker "$force"
            ;;
        "status")
            check_docker_status "$format"
            ;;
        *)
            log_error "알 수 없는 액션: $action"
            usage
            exit 1
            ;;
    esac
    
    # 실행 요약 보고
    generate_summary
}

# =============================================================================
# 스크립트 실행
# =============================================================================
main "$@"
