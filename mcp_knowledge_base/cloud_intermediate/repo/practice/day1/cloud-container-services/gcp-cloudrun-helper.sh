#!/bin/bash

# GCP Cloud Run Helper 모듈
# 역할: GCP Cloud Run 관련 작업 실행 (서비스 배포, 트래픽 관리, 보안 설정)
# 
# 사용법:
#   ./gcp-cloudrun-helper.sh --action <액션> [옵션]

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

# GCP 환경 설정 로드
if [ -f "$SCRIPT_DIR/gcp-environment.env" ]; then
    source "$SCRIPT_DIR/gcp-environment.env"
else
    echo "ERROR: GCP 환경 설정 파일을 찾을 수 없습니다"
    exit 1
fi

# =============================================================================
# 사용법 출력
# =============================================================================
usage() {
    cat << EOF
GCP Cloud Run Helper 모듈

사용법:
  $0 --action <액션> [옵션]

액션:
  deploy-service          # Cloud Run 서비스 배포
  update-service          # Cloud Run 서비스 업데이트
  manage-traffic          # 트래픽 관리
  setup-security          # 보안 설정
  service-delete          # Cloud Run 서비스 삭제
  cleanup                 # Cloud Run 리소스 정리
  status                  # Cloud Run 상태 확인

옵션:
  --service-name <name>   # 서비스 이름 (기본값: nginx-service)
  --image <image>         # 컨테이너 이미지 (기본값: nginx:1.21)
  --region <region>       # 리전 (기본값: 환경변수)
  --port <port>           # 포트 (기본값: 80)
  --memory <memory>       # 메모리 (기본값: 512Mi)
  --cpu <cpu>             # CPU (기본값: 1)
  --min-instances <min>   # 최소 인스턴스 (기본값: 0)
  --max-instances <max>   # 최대 인스턴스 (기본값: 10)
  --help, -h              # 도움말 표시

예시:
  $0 --action deploy-service
  $0 --action update-service --service-name web-service
  $0 --action manage-traffic --service-name web-service
  $0 --action status
  $0 --action cleanup
EOF
}

# =============================================================================
# 액션별 상세 사용법 함수
# =============================================================================
show_action_help() {
    local action="$1"
    
    case "$action" in
        "deploy-service")
            cat << EOF
DEPLOY-SERVICE 액션 상세 사용법:

기능:
  - Cloud Run 서비스 배포
  - 컨테이너 이미지 배포
  - 자동 스케일링 설정

사용법:
  $0 --action deploy-service [옵션]

옵션:
  --service-name <name>   # 서비스 이름 (기본값: nginx-service)
  --image <image>         # 컨테이너 이미지 (기본값: nginx:1.21)
  --region <region>       # 리전 (기본값: 환경변수)
  --port <port>           # 포트 (기본값: 80)
  --memory <memory>       # 메모리 (기본값: 512Mi)
  --cpu <cpu>             # CPU (기본값: 1)
  --min-instances <min>   # 최소 인스턴스 (기본값: 0)
  --max-instances <max>   # 최대 인스턴스 (기본값: 10)

예시:
  $0 --action deploy-service
  $0 --action deploy-service --image nginx:1.21 --memory 1Gi --cpu 2

생성되는 리소스:
  - Cloud Run 서비스
  - 컨테이너 인스턴스
  - 자동 스케일링 설정
  - 트래픽 라우팅

진행 상황:
  - 서비스 배포
  - 컨테이너 시작
  - 상태 확인
  - 완료 보고
EOF
            ;;
        "update-service")
            cat << EOF
UPDATE-SERVICE 액션 상세 사용법:

기능:
  - Cloud Run 서비스 업데이트
  - 이미지 버전 업데이트
  - 설정 변경

사용법:
  $0 --action update-service [옵션]

옵션:
  --service-name <name>   # 서비스 이름 (기본값: nginx-service)
  --image <image>         # 새로운 컨테이너 이미지
  --region <region>       # 리전 (기본값: 환경변수)
  --memory <memory>       # 메모리 설정
  --cpu <cpu>             # CPU 설정

예시:
  $0 --action update-service
  $0 --action update-service --image nginx:1.22 --memory 1Gi

업데이트되는 항목:
  - 컨테이너 이미지
  - 리소스 설정
  - 서비스 구성

진행 상황:
  - 서비스 업데이트
  - 롤링 업데이트
  - 상태 확인
  - 완료 보고
EOF
            ;;
        "manage-traffic")
            cat << EOF
MANAGE-TRAFFIC 액션 상세 사용법:

기능:
  - Cloud Run 트래픽 관리
  - 트래픽 분할 설정
  - A/B 테스트 구성

사용법:
  $0 --action manage-traffic [옵션]

옵션:
  --service-name <name>   # 서비스 이름 (기본값: nginx-service)
  --region <region>       # 리전 (기본값: 환경변수)
  --to-latest             # 최신 버전으로 트래픽 전환
  --to-revision <rev>     # 특정 리비전으로 트래픽 전환
  --split <percent>       # 트래픽 분할 비율

예시:
  $0 --action manage-traffic
  $0 --action manage-traffic --to-latest
  $0 --action manage-traffic --split 50

관리되는 항목:
  - 트래픽 라우팅
  - 버전별 트래픽 분할
  - 롤백 설정

진행 상황:
  - 트래픽 설정
  - 상태 확인
  - 완료 보고
EOF
            ;;
        "setup-security")
            cat << EOF
SETUP-SECURITY 액션 상세 사용법:

기능:
  - Cloud Run 보안 설정
  - 인증 및 권한 설정
  - 네트워크 보안 구성

사용법:
  $0 --action setup-security [옵션]

옵션:
  --service-name <name>   # 서비스 이름 (기본값: nginx-service)
  --region <region>       # 리전 (기본값: 환경변수)
  --allow-unauthenticated # 인증 없이 접근 허용
  --require-auth          # 인증 필요

예시:
  $0 --action setup-security
  $0 --action setup-security --allow-unauthenticated

설정되는 보안 항목:
  - 인증 설정
  - IAM 권한
  - 네트워크 정책

진행 상황:
  - 보안 설정
  - 권한 구성
  - 상태 확인
  - 완료 보고
EOF
            ;;
        "service-delete")
            cat << EOF
SERVICE-DELETE 액션 상세 사용법:

기능:
  - Cloud Run 서비스 삭제
  - 관련 리소스 정리
  - 트래픽 중단

사용법:
  $0 --action service-delete [옵션]

옵션:
  --service-name <name>   # 서비스 이름 (기본값: nginx-service)
  --region <region>       # 리전 (기본값: 환경변수)
  --force                 # 확인 없이 강제 삭제

예시:
  $0 --action service-delete
  $0 --action service-delete --force

삭제되는 리소스:
  - Cloud Run 서비스
  - 컨테이너 인스턴스
  - 트래픽 라우팅

주의사항:
  - 삭제된 서비스는 복구할 수 없습니다
  - --force 옵션 사용 시 확인 없이 삭제됩니다
EOF
            ;;
        "cleanup")
            cat << EOF
CLEANUP 액션 상세 사용법:

기능:
  - Cloud Run 리소스 전체 정리
  - 서비스 및 관련 리소스 삭제
  - 비용 최적화

사용법:
  $0 --action cleanup [옵션]

옵션:
  --region <region>       # 정리할 리전
  --force                 # 확인 없이 강제 정리

예시:
  $0 --action cleanup
  $0 --action cleanup --force

정리되는 리소스:
  - Cloud Run 서비스
  - 컨테이너 이미지
  - 관련 IAM 정책

주의사항:
  - 정리된 리소스는 복구할 수 없습니다
  - --force 옵션 사용 시 확인 없이 정리됩니다
EOF
            ;;
        "status")
            cat << EOF
STATUS 액션 상세 사용법:

기능:
  - Cloud Run 서비스 상태 확인
  - 리소스 사용량 모니터링
  - 성능 지표 확인

사용법:
  $0 --action status [옵션]

옵션:
  --service-name <name>   # 확인할 서비스 이름
  --region <region>       # 리전 (기본값: 환경변수)
  --format <format>       # 출력 형식 (table, json, yaml)

예시:
  $0 --action status
  $0 --action status --format json

확인되는 정보:
  - 서비스 상태
  - 리비전 정보
  - 트래픽 분할
  - 리소스 사용량

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
  - deploy-service: Cloud Run 서비스 배포
  - update-service: Cloud Run 서비스 업데이트
  - manage-traffic: 트래픽 관리
  - setup-security: 보안 설정
  - service-delete: 서비스 삭제
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
    log_step "GCP Cloud Run 환경 검증 중..."
    
    # gcloud CLI 설치 확인
    if ! check_command "gcloud"; then
        log_error "gcloud CLI가 설치되지 않았습니다."
        return 1
    fi
    
    # GCP 자격 증명 확인
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 &> /dev/null; then
        log_error "GCP 자격 증명이 설정되지 않았습니다."
        return 1
    fi
    
    # Cloud Run API 활성화 확인
    if ! gcloud services list --enabled --filter="name:run.googleapis.com" --format="value(name)" | grep -q "run.googleapis.com"; then
        log_info "Cloud Run API 활성화 중..."
        gcloud services enable run.googleapis.com
    fi
    
    log_success "GCP Cloud Run 환경 검증 완료"
    return 0
}

# =============================================================================
# Cloud Run 서비스 배포
# =============================================================================
deploy_service() {
    local service_name="${1:-cloud-run-demo}"
    local image="${2:-gcr.io/$(gcloud config get-value project)/cloud-run-demo:latest}"
    local region="${3:-$GCP_REGION}"
    local port="${4:-8080}"
    local memory="${5:-512Mi}"
    local cpu="${6:-1}"
    local min_instances="${7:-0}"
    local max_instances="${8:-10}"
    
    log_header "Cloud Run 서비스 배포: $service_name"
    
    # 환경 변수 설정 (수동 가이드와 동일)
    export PROJECT_ID=$(gcloud config get-value project)
    export REGION="$region"
    export SERVICE_NAME="$service_name"
    export IMAGE_NAME="$image"
    
    log_info "환경 변수 확인:"
    log_info "프로젝트 ID: $PROJECT_ID"
    log_info "리전: $REGION"
    log_info "서비스명: $SERVICE_NAME"
    log_info "이미지명: $IMAGE_NAME"
    
    # 기존 서비스 확인
    if gcloud run services describe "$service_name" --region="$region" &> /dev/null; then
        log_warning "서비스가 이미 존재합니다: $service_name"
        log_info "기존 서비스를 사용하여 다음 단계를 진행합니다."
        update_progress "deploy-service" "existing" "기존 서비스 사용: $service_name"
        return 0
    fi
    
    log_info "Cloud Run 서비스 배포 중..."
    update_progress "deploy-service" "started" "Cloud Run 서비스 배포 시작"
    
    # Cloud Run 서비스 배포 (수동 가이드와 동일한 명령어)
    if gcloud run deploy "$service_name" \
        --image "$image" \
        --region "$region" \
        --platform managed \
        --allow-unauthenticated \
        --port "$port"; then
        
        log_success "Cloud Run 서비스 배포 완료: $service_name"
        update_progress "deploy-service" "completed" "Cloud Run 서비스 배포 완료"
        
        # 서비스 URL 확인
        local service_url
        service_url=$(gcloud run services describe "$service_name" --region="$region" --format='value(status.url)')
        log_info "서비스 URL: $service_url"
        
        # 서비스 상태 확인 (수동 가이드와 동일한 형식)
        log_info "서비스 상태 확인:"
        gcloud run services describe "$service_name" --region="$region" --format="table(metadata.name,status.url,status.conditions[0].status,spec.template.spec.containers[0].image)"
        
        return 0
    else
        log_error "Cloud Run 서비스 배포 실패: $service_name"
        update_progress "deploy-service" "failed" "Cloud Run 서비스 배포 실패"
        return 1
    fi
}

# =============================================================================
# Cloud Run 서비스 업데이트
# =============================================================================
update_service() {
    local service_name="${1:-nginx-service}"
    local image="${2:-nginx:1.21}"
    local region="${3:-$GCP_REGION}"
    local memory="${4:-512Mi}"
    local cpu="${5:-1}"
    
    log_header "Cloud Run 서비스 업데이트: $service_name"
    
    # 서비스 존재 확인
    if ! gcloud run services describe "$service_name" --region="$region" &> /dev/null; then
        log_error "서비스가 존재하지 않습니다: $service_name"
        return 1
    fi
    
    log_info "Cloud Run 서비스 업데이트 중..."
    update_progress "update-service" "started" "Cloud Run 서비스 업데이트 시작"
    
    # Cloud Run 서비스 업데이트
    if gcloud run services update "$service_name" \
        --image "$image" \
        --region "$region" \
        --memory "$memory" \
        --cpu "$cpu" \
        --quiet; then
        
        log_success "Cloud Run 서비스 업데이트 완료: $service_name"
        update_progress "update-service" "completed" "Cloud Run 서비스 업데이트 완료"
        
        # 업데이트 상태 확인
        log_info "업데이트 상태 확인:"
        gcloud run services describe "$service_name" --region="$region" --format="table(metadata.name,status.url,spec.template.spec.containers[0].image,status.conditions[0].status)"
        
        return 0
    else
        log_error "Cloud Run 서비스 업데이트 실패: $service_name"
        update_progress "update-service" "failed" "Cloud Run 서비스 업데이트 실패"
        return 1
    fi
}

# =============================================================================
# 트래픽 관리
# =============================================================================
manage_traffic() {
    local service_name="${1:-cloud-run-demo}"
    local region="${2:-$GCP_REGION}"
    local to_latest="${3:-false}"
    local to_revision="${4:-}"
    local split="${5:-100}"
    
    log_header "Cloud Run 트래픽 관리: $service_name"
    
    # 환경 변수 설정 (수동 가이드와 동일)
    export SERVICE_NAME="$service_name"
    export REGION="$region"
    
    # 서비스 존재 확인
    if ! gcloud run services describe "$service_name" --region="$region" &> /dev/null; then
        log_error "서비스가 존재하지 않습니다: $service_name"
        return 1
    fi
    
    log_info "트래픽 관리 설정 중..."
    update_progress "manage-traffic" "started" "트래픽 관리 시작"
    
    # 현재 리비전 목록 확인 (수동 가이드와 동일)
    log_info "현재 리비전 목록 확인:"
    gcloud run revisions list \
        --service "$service_name" \
        --region "$region" \
        --format="table(metadata.name,status.conditions[0].status,spec.containers[0].image)"
    
    # 최신 리비전과 이전 리비전 확인 (수동 가이드와 동일한 로직)
    local latest_revision
    local previous_revision
    
    latest_revision=$(gcloud run revisions list --service "$service_name" --region "$region" --limit 1 --format="value(metadata.name)")
    previous_revision=$(gcloud run revisions list --service "$service_name" --region "$region" --limit 2 | tail -1 | awk '{print $1}')
    
    log_info "최신 리비전: $latest_revision"
    log_info "이전 리비전: $previous_revision"
    
    # 트래픽 설정 (수동 가이드와 동일한 명령어)
    if [ "$to_latest" = "true" ]; then
        log_info "최신 버전으로 트래픽 전환 중..."
        gcloud run services update-traffic "$service_name" \
            --to-latest \
            --region "$region"
    elif [ -n "$to_revision" ]; then
        log_info "특정 리비전으로 트래픽 전환 중: $to_revision"
        gcloud run services update-traffic "$service_name" \
            --to-revisions="$to_revision" \
            --region "$region"
    else
        log_info "트래픽을 50:50으로 분할 설정 중..."
        gcloud run services update-traffic "$service_name" \
            --region "$region" \
            --to-revisions "$latest_revision=50,$previous_revision=50"
    fi
    
    if [ $? -eq 0 ]; then
        log_success "트래픽 관리 완료: $service_name"
        update_progress "manage-traffic" "completed" "트래픽 관리 완료"
        
        # 트래픽 상태 확인 (수동 가이드와 동일한 형식)
        log_info "트래픽 상태 확인:"
        gcloud run services describe "$service_name" --region="$region" --format="table(spec.traffic[].revisionName,spec.traffic[].percent)"
        
        return 0
    else
        log_error "트래픽 관리 실패: $service_name"
        update_progress "manage-traffic" "failed" "트래픽 관리 실패"
        return 1
    fi
}

# =============================================================================
# 보안 설정
# =============================================================================
setup_security() {
    local service_name="${1:-nginx-service}"
    local region="${2:-$GCP_REGION}"
    local allow_unauthenticated="${3:-true}"
    
    log_header "Cloud Run 보안 설정: $service_name"
    
    # 서비스 존재 확인
    if ! gcloud run services describe "$service_name" --region="$region" &> /dev/null; then
        log_error "서비스가 존재하지 않습니다: $service_name"
        return 1
    fi
    
    log_info "보안 설정 중..."
    update_progress "setup-security" "started" "보안 설정 시작"
    
    # 보안 설정
    if [ "$allow_unauthenticated" = "true" ]; then
        log_info "인증 없이 접근 허용 설정 중..."
        gcloud run services add-iam-policy-binding "$service_name" \
            --region="$region" \
            --member="allUsers" \
            --role="roles/run.invoker" \
            --quiet
    else
        log_info "인증 필요 설정 중..."
        gcloud run services remove-iam-policy-binding "$service_name" \
            --region="$region" \
            --member="allUsers" \
            --role="roles/run.invoker" \
            --quiet
    fi
    
    if [ $? -eq 0 ]; then
        log_success "보안 설정 완료: $service_name"
        update_progress "setup-security" "completed" "보안 설정 완료"
        
        # 보안 상태 확인
        log_info "보안 상태 확인:"
        gcloud run services get-iam-policy "$service_name" --region="$region"
        
        return 0
    else
        log_error "보안 설정 실패: $service_name"
        update_progress "setup-security" "failed" "보안 설정 실패"
        return 1
    fi
}

# =============================================================================
# Cloud Run 서비스 삭제
# =============================================================================
delete_service() {
    local service_name="${1:-nginx-service}"
    local region="${2:-$GCP_REGION}"
    local force="${3:-false}"
    
    log_header "Cloud Run 서비스 삭제: $service_name"
    
    # 서비스 존재 확인
    if ! gcloud run services describe "$service_name" --region="$region" &> /dev/null; then
        log_warning "삭제할 서비스가 존재하지 않습니다: $service_name"
        update_progress "service-delete" "skipped" "서비스가 존재하지 않음"
        return 0
    fi
    
    if [ "$force" != "true" ]; then
        log_warning "삭제할 서비스: $service_name"
        read -p "정말 삭제하시겠습니까? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "삭제가 취소되었습니다."
            return 0
        fi
    fi
    
    log_info "Cloud Run 서비스 삭제 중..."
    update_progress "service-delete" "started" "Cloud Run 서비스 삭제 시작"
    
    if gcloud run services delete "$service_name" --region="$region" --quiet; then
        log_success "Cloud Run 서비스 삭제 완료: $service_name"
        update_progress "service-delete" "completed" "Cloud Run 서비스 삭제 완료"
        return 0
    else
        log_error "Cloud Run 서비스 삭제 실패: $service_name"
        update_progress "service-delete" "failed" "Cloud Run 서비스 삭제 실패"
        return 1
    fi
}

# =============================================================================
# Cloud Run 리소스 정리
# =============================================================================
cleanup_cloudrun() {
    local region="${1:-$GCP_REGION}"
    local force="${2:-false}"
    
    log_header "Cloud Run 리소스 정리: $region"
    
    if [ "$force" != "true" ]; then
        log_warning "정리할 리소스:"
        local service_count
        service_count=$(gcloud run services list --region="$region" --format="value(metadata.name)" | wc -l)
        log_info "서비스: $service_count개"
        
        read -p "정말 정리하시겠습니까? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "정리가 취소되었습니다."
            return 0
        fi
    fi
    
    log_info "Cloud Run 리소스 정리 중..."
    update_progress "cleanup" "started" "Cloud Run 리소스 정리 시작"
    
    # 모든 서비스 삭제
    log_info "서비스 삭제 중..."
    for service in $(gcloud run services list --region="$region" --format="value(metadata.name)"); do
        gcloud run services delete "$service" --region="$region" --quiet 2>/dev/null || true
    done
    
    log_success "Cloud Run 리소스 정리 완료"
    update_progress "cleanup" "completed" "Cloud Run 리소스 정리 완료"
    return 0
}

# =============================================================================
# Cloud Run 상태 확인
# =============================================================================
check_cloudrun_status() {
    local service_name="${1:-cloud-run-demo}"
    local region="${2:-$GCP_REGION}"
    local format="${3:-table}"
    
    log_header "Cloud Run 상태 확인: $region"
    
    # 환경 변수 설정 (수동 가이드와 동일)
    export SERVICE_NAME="$service_name"
    export REGION="$region"
    
    # 서비스 정보 확인 (수동 가이드와 동일한 명령어)
    log_info "서비스 정보 확인:"
    gcloud run services describe "$service_name" \
        --region "$region" \
        --format="table(metadata.name,status.url,status.conditions[0].status,spec.template.spec.containers[0].image)"
    
    # 서비스 URL 확인 (수동 가이드와 동일)
    local service_url
    service_url=$(gcloud run services describe "$service_name" --region="$region" --format="value(status.url)")
    log_info "서비스 URL: $service_url"
    
    # 서비스 테스트 (수동 가이드와 동일)
    log_info "서비스 응답 테스트:"
    if curl -s "$service_url" | jq '.'; then
        log_success "서비스 응답 정상"
    else
        log_warning "서비스 응답 확인 실패"
    fi
    
    # 트래픽 분할 상태 확인 (수동 가이드와 동일)
    log_info "트래픽 분할 상태 확인:"
    gcloud run services describe "$service_name" --region="$region" --format="table(spec.traffic[].revisionName,spec.traffic[].percent)"
    
    # 로그 확인 (수동 가이드와 동일)
    log_info "Cloud Run 로그 확인:"
    gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=$service_name" \
        --limit 5 \
        --format="table(timestamp,severity,textPayload)"
    
    update_progress "status" "completed" "Cloud Run 상태 확인 완료"
    return 0
}

# =============================================================================
# 메인 실행 로직
# =============================================================================
main() {
    local action=""
    local service_name="cloud-run-demo"
    local image="gcr.io/$(gcloud config get-value project)/cloud-run-demo:latest"
    local region="$GCP_REGION"
    local port="8080"
    local memory="512Mi"
    local cpu="1"
    local min_instances="0"
    local max_instances="10"
    local to_latest="false"
    local to_revision=""
    local split="100"
    local allow_unauthenticated="true"
    local force="false"
    local format="table"
    
    # 인수 파싱
    while [[ $# -gt 0 ]]; do
        case $1 in
            --action)
                action="$2"
                shift 2
                ;;
            --service-name)
                service_name="$2"
                shift 2
                ;;
            --image)
                image="$2"
                shift 2
                ;;
            --region)
                region="$2"
                shift 2
                ;;
            --port)
                port="$2"
                shift 2
                ;;
            --memory)
                memory="$2"
                shift 2
                ;;
            --cpu)
                cpu="$2"
                shift 2
                ;;
            --min-instances)
                min_instances="$2"
                shift 2
                ;;
            --max-instances)
                max_instances="$2"
                shift 2
                ;;
            --to-latest)
                to_latest="true"
                shift
                ;;
            --to-revision)
                to_revision="$2"
                shift 2
                ;;
            --split)
                split="$2"
                shift 2
                ;;
            --allow-unauthenticated)
                allow_unauthenticated="true"
                shift
                ;;
            --require-auth)
                allow_unauthenticated="false"
                shift
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
        "deploy-service")
            deploy_service "$service_name" "$image" "$region" "$port" "$memory" "$cpu" "$min_instances" "$max_instances"
            ;;
        "update-service")
            update_service "$service_name" "$image" "$region" "$memory" "$cpu"
            ;;
        "manage-traffic")
            manage_traffic "$service_name" "$region" "$to_latest" "$to_revision" "$split"
            ;;
        "setup-security")
            setup_security "$service_name" "$region" "$allow_unauthenticated"
            ;;
        "service-delete")
            delete_service "$service_name" "$region" "$force"
            ;;
        "cleanup")
            cleanup_cloudrun "$region" "$force"
            ;;
        "status")
            check_cloudrun_status "$service_name" "$region" "$format"
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
