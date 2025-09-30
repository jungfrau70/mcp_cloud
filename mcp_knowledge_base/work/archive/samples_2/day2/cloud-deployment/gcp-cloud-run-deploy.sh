#!/bin/bash

# GCP Cloud Run 배포 스크립트
# Cloud Intermediate Day2 실습용

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 로그 함수들
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 설정 변수
PROJECT_ID="my-project"
SERVICE_NAME="cloud-intermediate-app"
REGION="us-central1"
IMAGE_URI="gcr.io/$PROJECT_ID/cloud-intermediate-app:latest"

# Docker 이미지 빌드 및 푸시
build_and_push_image() {
    log_info "Docker 이미지 빌드 및 푸시 중..."
    
    # Docker 이미지 빌드
    docker build -t $IMAGE_URI .
    
    # GCR에 푸시
    docker push $IMAGE_URI
    
    log_success "Docker 이미지 빌드 및 푸시 완료"
}

# Cloud Run 서비스 배포
deploy_cloud_run() {
    log_info "Cloud Run 서비스 배포 중..."
    
    gcloud run deploy $SERVICE_NAME \
        --image $IMAGE_URI \
        --platform managed \
        --region $REGION \
        --allow-unauthenticated \
        --port 3000 \
        --memory 512Mi \
        --cpu 1 \
        --min-instances 0 \
        --max-instances 10 \
        --concurrency 80 \
        --timeout 300 \
        --set-env-vars NODE_ENV=production,APP_NAME=cloud-intermediate-app \
        --project $PROJECT_ID
    
    log_success "Cloud Run 서비스 배포 완료"
}

# 도메인 매핑
setup_domain() {
    log_info "도메인 매핑 설정 중..."
    
    # 도메인 매핑 생성
    gcloud run domain-mappings create \
        --service $SERVICE_NAME \
        --domain cloud-intermediate.example.com \
        --region $REGION \
        --project $PROJECT_ID || log_warning "도메인 매핑이 이미 존재합니다."
    
    # SSL 인증서 생성
    gcloud compute ssl-certificates create cloud-intermediate-ssl \
        --domains cloud-intermediate.example.com \
        --global \
        --project $PROJECT_ID || log_warning "SSL 인증서가 이미 존재합니다."
    
    log_success "도메인 매핑 설정 완료"
}

# 트래픽 분할 설정
setup_traffic_splitting() {
    log_info "트래픽 분할 설정 중..."
    
    # 새 버전 배포 (트래픽 분할용)
    gcloud run deploy $SERVICE_NAME \
        --image $IMAGE_URI \
        --platform managed \
        --region $REGION \
        --no-traffic \
        --tag canary \
        --project $PROJECT_ID
    
    # 트래픽 분할 설정 (90% stable, 10% canary)
    gcloud run services update-traffic $SERVICE_NAME \
        --to-tags stable=90,canary=10 \
        --region $REGION \
        --project $PROJECT_ID
    
    log_success "트래픽 분할 설정 완료"
}

# 서비스 상태 확인
check_service_status() {
    log_info "서비스 상태 확인 중..."
    
    # 서비스 정보 조회
    gcloud run services describe $SERVICE_NAME \
        --region $REGION \
        --project $PROJECT_ID \
        --format="table(metadata.name,status.url,status.conditions[0].status)"
    
    # 서비스 URL 출력
    SERVICE_URL=$(gcloud run services describe $SERVICE_NAME \
        --region $REGION \
        --project $PROJECT_ID \
        --format="value(status.url)")
    
    log_info "서비스 URL: $SERVICE_URL"
    
    # 헬스 체크
    if curl -f -s "$SERVICE_URL/health" > /dev/null; then
        log_success "서비스가 정상적으로 응답합니다."
    else
        log_warning "서비스 헬스 체크에 실패했습니다."
    fi
}

# 로그 확인
check_logs() {
    log_info "서비스 로그 확인 중..."
    
    # 최근 로그 확인
    gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=$SERVICE_NAME" \
        --limit 50 \
        --format="table(timestamp,severity,textPayload)" \
        --project $PROJECT_ID
    
    # 실시간 로그 스트리밍
    log_info "실시간 로그 스트리밍 시작 (Ctrl+C로 중지)"
    gcloud logging tail "resource.type=cloud_run_revision AND resource.labels.service_name=$SERVICE_NAME" \
        --project $PROJECT_ID
}

# 메트릭 확인
check_metrics() {
    log_info "서비스 메트릭 확인 중..."
    
    # Cloud Monitoring 메트릭 조회
    gcloud monitoring metrics list \
        --filter="metric.type:run.googleapis.com/request_count" \
        --project $PROJECT_ID
    
    # 요청 수 메트릭 조회
    gcloud monitoring time-series list \
        --filter="metric.type:run.googleapis.com/request_count" \
        --interval="1h" \
        --project $PROJECT_ID
}

# 정리 함수
cleanup() {
    log_info "리소스 정리 중..."
    
    # Cloud Run 서비스 삭제
    gcloud run services delete $SERVICE_NAME \
        --region $REGION \
        --project $PROJECT_ID \
        --quiet
    
    # 도메인 매핑 삭제
    gcloud run domain-mappings delete cloud-intermediate.example.com \
        --region $REGION \
        --project $PROJECT_ID \
        --quiet || log_warning "도메인 매핑이 존재하지 않습니다."
    
    # SSL 인증서 삭제
    gcloud compute ssl-certificates delete cloud-intermediate-ssl \
        --global \
        --project $PROJECT_ID \
        --quiet || log_warning "SSL 인증서가 존재하지 않습니다."
    
    log_success "리소스 정리 완료"
}

# 메인 함수
main() {
    case "${1:-deploy}" in
        "deploy")
            build_and_push_image
            deploy_cloud_run
            check_service_status
            ;;
        "domain")
            setup_domain
            ;;
        "traffic")
            setup_traffic_splitting
            ;;
        "status")
            check_service_status
            ;;
        "logs")
            check_logs
            ;;
        "metrics")
            check_metrics
            ;;
        "cleanup")
            cleanup
            ;;
        *)
            echo "사용법: $0 [deploy|domain|traffic|status|logs|metrics|cleanup]"
            echo "  deploy  - 전체 배포 (기본값)"
            echo "  domain  - 도메인 매핑 설정"
            echo "  traffic - 트래픽 분할 설정"
            echo "  status  - 서비스 상태 확인"
            echo "  logs    - 로그 확인"
            echo "  metrics - 메트릭 확인"
            echo "  cleanup - 리소스 정리"
            ;;
    esac
}

# 스크립트 실행
main "$@"
