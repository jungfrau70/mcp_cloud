#!/bin/bash

# AWS ECS 배포 스크립트
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
CLUSTER_NAME="cloud-intermediate-cluster"
SERVICE_NAME="cloud-intermediate-service"
TASK_DEFINITION="cloud-intermediate-app"
IMAGE_URI="123456789012.dkr.ecr.us-west-2.amazonaws.com/cloud-intermediate-app:latest"
REGION="us-west-2"

# ECS 클러스터 생성
create_cluster() {
    log_info "ECS 클러스터 생성 중..."
    
    aws ecs create-cluster \
        --cluster-name $CLUSTER_NAME \
        --capacity-providers FARGATE \
        --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1 \
        --region $REGION || log_warning "클러스터가 이미 존재합니다."
    
    log_success "ECS 클러스터 생성 완료"
}

# 태스크 정의 등록
register_task_definition() {
    log_info "태스크 정의 등록 중..."
    
    # 태스크 정의 파일이 있는지 확인
    if [ -f "task-definition.json" ]; then
        aws ecs register-task-definition \
            --cli-input-json file://task-definition.json \
            --region $REGION
        log_success "태스크 정의 등록 완료"
    else
        log_error "task-definition.json 파일을 찾을 수 없습니다."
        exit 1
    fi
}

# ECS 서비스 생성
create_service() {
    log_info "ECS 서비스 생성 중..."
    
    aws ecs create-service \
        --cluster $CLUSTER_NAME \
        --service-name $SERVICE_NAME \
        --task-definition $TASK_DEFINITION:1 \
        --desired-count 2 \
        --launch-type FARGATE \
        --network-configuration "awsvpcConfiguration={subnets=[subnet-12345,subnet-67890],securityGroups=[sg-12345],assignPublicIp=ENABLED}" \
        --load-balancers "targetGroupArn=arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/cloud-intermediate-tg/1234567890123456,containerName=cloud-intermediate-app,containerPort=80" \
        --region $REGION || log_warning "서비스가 이미 존재합니다."
    
    log_success "ECS 서비스 생성 완료"
}

# Application Load Balancer 생성
create_load_balancer() {
    log_info "Application Load Balancer 생성 중..."
    
    # ALB 생성
    aws elbv2 create-load-balancer \
        --name cloud-intermediate-alb \
        --subnets subnet-12345 subnet-67890 \
        --security-groups sg-12345 \
        --region $REGION || log_warning "ALB가 이미 존재합니다."
    
    # 타겟 그룹 생성
    aws elbv2 create-target-group \
        --name cloud-intermediate-tg \
        --protocol HTTP \
        --port 80 \
        --vpc-id vpc-12345 \
        --target-type ip \
        --health-check-path /health \
        --health-check-interval-seconds 30 \
        --health-check-timeout-seconds 5 \
        --healthy-threshold-count 2 \
        --unhealthy-threshold-count 3 \
        --region $REGION || log_warning "타겟 그룹이 이미 존재합니다."
    
    log_success "Load Balancer 설정 완료"
}

# 서비스 업데이트
update_service() {
    log_info "서비스 업데이트 중..."
    
    aws ecs update-service \
        --cluster $CLUSTER_NAME \
        --service $SERVICE_NAME \
        --force-new-deployment \
        --region $REGION
    
    log_success "서비스 업데이트 완료"
}

# 배포 상태 확인
check_deployment_status() {
    log_info "배포 상태 확인 중..."
    
    # 서비스 상태 확인
    aws ecs describe-services \
        --cluster $CLUSTER_NAME \
        --services $SERVICE_NAME \
        --region $REGION \
        --query 'services[0].{Status:status,RunningCount:runningCount,DesiredCount:desiredCount}'
    
    # 태스크 상태 확인
    aws ecs list-tasks \
        --cluster $CLUSTER_NAME \
        --service-name $SERVICE_NAME \
        --region $REGION \
        --query 'taskArns'
}

# 로그 확인
check_logs() {
    log_info "서비스 로그 확인 중..."
    
    # CloudWatch 로그 그룹 확인
    aws logs describe-log-groups \
        --log-group-name-prefix "/ecs/cloud-intermediate-app" \
        --region $REGION
    
    # 최근 로그 확인
    aws logs tail \
        /ecs/cloud-intermediate-app \
        --follow \
        --region $REGION &
    
    log_info "로그 모니터링 시작 (Ctrl+C로 중지)"
}

# 정리 함수
cleanup() {
    log_info "리소스 정리 중..."
    
    # 서비스 삭제
    aws ecs update-service \
        --cluster $CLUSTER_NAME \
        --service $SERVICE_NAME \
        --desired-count 0 \
        --region $REGION
    
    # 서비스 삭제
    aws ecs delete-service \
        --cluster $CLUSTER_NAME \
        --service $SERVICE_NAME \
        --region $REGION
    
    # 클러스터 삭제
    aws ecs delete-cluster \
        --cluster $CLUSTER_NAME \
        --region $REGION
    
    log_success "리소스 정리 완료"
}

# 메인 함수
main() {
    case "${1:-deploy}" in
        "deploy")
            create_cluster
            register_task_definition
            create_load_balancer
            create_service
            check_deployment_status
            ;;
        "update")
            update_service
            check_deployment_status
            ;;
        "status")
            check_deployment_status
            ;;
        "logs")
            check_logs
            ;;
        "cleanup")
            cleanup
            ;;
        *)
            echo "사용법: $0 [deploy|update|status|logs|cleanup]"
            echo "  deploy  - 전체 배포 (기본값)"
            echo "  update  - 서비스 업데이트"
            echo "  status  - 배포 상태 확인"
            echo "  logs    - 로그 확인"
            echo "  cleanup - 리소스 정리"
            ;;
    esac
}

# 스크립트 실행
main "$@"
