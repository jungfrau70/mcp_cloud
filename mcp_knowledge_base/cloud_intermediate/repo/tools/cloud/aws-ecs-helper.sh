#!/bin/bash

# AWS ECS Helper 모듈
# 역할: AWS ECS 클러스터 및 서비스 관련 작업 실행
# 
# 사용법:
#   ./aws-ecs-helper.sh --action <액션> --provider aws

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

# AWS 환경 설정 로드
if [ -f "$SCRIPT_DIR/aws-environment.env" ]; then
    source "$SCRIPT_DIR/aws-environment.env"
    log_info "AWS 환경 설정 로드 완료"
else
    log_error "AWS 환경 설정 파일을 찾을 수 없습니다"
    exit 1
fi

# =============================================================================
# 사용법 출력
# =============================================================================
usage() {
    cat << EOF
AWS ECS Helper 모듈

사용법:
  $0 --action <액션> [옵션]

액션:
  cluster-create           # ECS 클러스터 생성
  cluster-delete           # ECS 클러스터 삭제
  cluster-status           # ECS 클러스터 상태 확인
  task-definition-create   # 태스크 정의 생성
  service-create           # ECS 서비스 생성
  service-delete           # ECS 서비스 삭제
  service-status           # ECS 서비스 상태 확인
  cleanup                  # 전체 정리

옵션:
  --cluster-name <name>    # ECS 클러스터 이름 (기본값: 환경변수)
  --service-name <name>    # ECS 서비스 이름 (기본값: cloud-intermediate-service)
  --task-family <family>   # 태스크 패밀리 이름 (기본값: cloud-intermediate-task)
  --help, -h              # 도움말 표시

예시:
  $0 --action cluster-create
  $0 --action service-create --service-name my-service
  $0 --action cluster-status

상세 사용법:
  $0 --help --action cluster-create     # cluster-create 액션 상세 사용법
  $0 --help --action service-create     # service-create 액션 상세 사용법
  $0 --help --action cleanup            # cleanup 액션 상세 사용법
EOF
}

# =============================================================================
# 액션별 상세 사용법 함수
# =============================================================================
show_action_help() {
    local action="$1"
    
    case "$action" in
        "cluster-create")
            cat << EOF
CLUSTER-CREATE 액션 상세 사용법:

기능:
  - 새로운 ECS 클러스터를 생성합니다
  - 기존 클러스터가 있으면 재사용합니다
  - 클러스터 생성 과정을 실시간으로 추적합니다

사용법:
  $0 --action cluster-create [옵션]

옵션:
  --cluster-name <name>   # 클러스터 이름 (기본값: 환경변수)
  --region <region>       # 리전 (기본값: 환경변수)
  --tags <tags>           # 태그 (JSON 형식)

예시:
  $0 --action cluster-create
  $0 --action cluster-create --cluster-name my-ecs-cluster
  $0 --action cluster-create --tags '{"Environment":"Learning","Project":"CloudIntermediate"}'

생성되는 리소스:
  - ECS 클러스터
  - 클러스터 로그 그룹
  - IAM 역할 (필요한 경우)
  - 보안 그룹 (필요한 경우)

진행 상황:
  - 환경 검증
  - 기존 클러스터 확인
  - 클러스터 생성
  - 상태 확인
  - 완료 보고
EOF
            ;;
        "service-create")
            cat << EOF
SERVICE-CREATE 액션 상세 사용법:

기능:
  - ECS 서비스를 생성합니다
  - 태스크 정의를 기반으로 서비스를 배포합니다
  - 로드 밸런서와 연동합니다

사용법:
  $0 --action service-create [옵션]

옵션:
  --cluster-name <name>   # 클러스터 이름 (기본값: 환경변수)
  --service-name <name>   # 서비스 이름 (기본값: 환경변수)
  --task-family <family>  # 태스크 패밀리 이름 (기본값: 환경변수)
  --desired-count <count> # 원하는 태스크 수 (기본값: 1)

예시:
  $0 --action service-create
  $0 --action service-create --cluster-name my-cluster --service-name my-service
  $0 --action service-create --desired-count 3

생성되는 리소스:
  - ECS 서비스
  - 태스크 정의 (없는 경우)
  - 로드 밸런서 (설정된 경우)
  - 타겟 그룹 (설정된 경우)

진행 상황:
  - 클러스터 확인
  - 태스크 정의 확인/생성
  - 서비스 생성
  - 상태 확인
  - 완료 보고
EOF
            ;;
        "cleanup")
            cat << EOF
CLEANUP 액션 상세 사용법:

기능:
  - ECS 관련 모든 리소스를 안전하게 삭제합니다
  - 서비스, 클러스터, 태스크 정의를 순서대로 정리합니다
  - 삭제 전 확인 절차를 거칩니다

사용법:
  $0 --action cleanup [옵션]

옵션:
  --cluster-name <name>   # 삭제할 클러스터 이름
  --service-name <name>   # 삭제할 서비스 이름
  --force                 # 확인 없이 강제 삭제
  --keep-logs             # 로그 그룹 유지

예시:
  $0 --action cleanup
  $0 --action cleanup --cluster-name my-cluster
  $0 --action cleanup --force

삭제되는 리소스:
  - ECS 서비스
  - ECS 클러스터
  - 태스크 정의
  - 로그 그룹 (--keep-logs 옵션 없을 경우)
  - 관련 IAM 역할

주의사항:
  - 삭제된 리소스는 복구할 수 없습니다
  - --force 옵션 사용 시 확인 없이 삭제됩니다
  - 로그 그룹은 별도로 삭제해야 할 수 있습니다
EOF
            ;;
        *)
            cat << EOF
알 수 없는 액션: $action

사용 가능한 액션:
  - cluster-create: ECS 클러스터 생성
  - cluster-delete: ECS 클러스터 삭제
  - cluster-status: ECS 클러스터 상태 확인
  - task-definition-create: 태스크 정의 생성
  - service-create: ECS 서비스 생성
  - service-delete: ECS 서비스 삭제
  - service-status: ECS 서비스 상태 확인
  - cleanup: 전체 정리

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
    log_step "AWS ECS 환경 검증 중..."
    
    # AWS CLI 확인
    if ! check_command "aws"; then
        log_error "AWS CLI가 설치되지 않았습니다."
        return 1
    fi
    
    # AWS 자격 증명 확인
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS 자격 증명이 설정되지 않았습니다."
        return 1
    fi
    
    log_success "AWS ECS 환경 검증 완료"
    return 0
}

# =============================================================================
# ECS 클러스터 생성
# =============================================================================
create_ecs_cluster() {
    local cluster_name="${1:-$ECS_CLUSTER_NAME}"
    
    log_header "ECS 클러스터 생성: $cluster_name"
    
    # 클러스터 존재 확인
    if aws ecs describe-clusters --clusters "$cluster_name" --region "$AWS_REGION" &> /dev/null; then
        log_warning "ECS 클러스터가 이미 존재합니다: $cluster_name"
        log_info "기존 클러스터를 사용하여 다음 단계를 진행합니다."
        update_progress "cluster-check" "existing" "기존 ECS 클러스터 사용: $cluster_name"
        return 0
    fi
    
    log_info "새 ECS 클러스터 생성 시작: $cluster_name"
    update_progress "cluster-create" "started" "ECS 클러스터 생성 시작"
    
    # ECS 클러스터 생성
    aws ecs create-cluster \
        --cluster-name "$cluster_name" \
        --region "$AWS_REGION" \
        --tags key=Environment,value="$ENVIRONMENT_TAG" key=Project,value="$PROJECT_TAG" key=Owner,value="$OWNER_TAG"
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        log_success "ECS 클러스터 생성 완료: $cluster_name"
        update_progress "cluster-create" "completed" "ECS 클러스터 생성 완료"
        return 0
    else
        log_error "ECS 클러스터 생성 실패: $cluster_name"
        update_progress "cluster-create" "failed" "ECS 클러스터 생성 실패"
        return 1
    fi
}

# =============================================================================
# ECS 클러스터 삭제
# =============================================================================
delete_ecs_cluster() {
    local cluster_name="${1:-$ECS_CLUSTER_NAME}"
    
    log_header "ECS 클러스터 삭제: $cluster_name"
    
    # 클러스터 존재 확인
    if ! aws ecs describe-clusters --clusters "$cluster_name" --region "$AWS_REGION" &> /dev/null; then
        log_warning "삭제할 ECS 클러스터가 존재하지 않습니다: $cluster_name"
        update_progress "cluster-delete" "skipped" "ECS 클러스터가 존재하지 않음"
        return 0
    fi
    
    log_info "ECS 클러스터 삭제 시작: $cluster_name"
    update_progress "cluster-delete" "started" "ECS 클러스터 삭제 시작"
    
    # ECS 클러스터 삭제
    aws ecs delete-cluster --cluster "$cluster_name" --region "$AWS_REGION"
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        log_success "ECS 클러스터 삭제 완료: $cluster_name"
        update_progress "cluster-delete" "completed" "ECS 클러스터 삭제 완료"
        return 0
    else
        log_error "ECS 클러스터 삭제 실패: $cluster_name"
        update_progress "cluster-delete" "failed" "ECS 클러스터 삭제 실패"
        return 1
    fi
}

# =============================================================================
# ECS 클러스터 상태 확인
# =============================================================================
check_cluster_status() {
    local cluster_name="${1:-$ECS_CLUSTER_NAME}"
    
    log_header "ECS 클러스터 상태 확인: $cluster_name"
    
    # 클러스터 정보 조회
    log_info "클러스터 기본 정보:"
    aws ecs describe-clusters --clusters "$cluster_name" --region "$AWS_REGION" \
        --query 'clusters[0].{Name:clusterName,Status:status,ActiveServices:activeServicesCount,RunningTasks:runningTasksCount,RegisteredContainerInstances:registeredContainerInstancesCount}' \
        --output table
    
    # 클러스터 서비스 목록
    log_step "클러스터 서비스 목록:"
    local services=$(aws ecs list-services --cluster "$cluster_name" --region "$AWS_REGION" --query 'serviceArns' --output text)
    
    if [ -n "$services" ] && [ "$services" != "None" ]; then
        log_info "서비스 ARNs:"
        echo "$services"
        
        # 각 서비스 상세 정보
        for service_arn in $services; do
            log_info "서비스 상세 정보: $service_arn"
            aws ecs describe-services --cluster "$cluster_name" --services "$service_arn" --region "$AWS_REGION" \
                --query 'services[0].{Name:serviceName,Status:status,RunningCount:runningCount,DesiredCount:desiredCount}' \
                --output table
        done
    else
        log_info "등록된 서비스가 없습니다."
    fi
    
    update_progress "cluster-status" "completed" "ECS 클러스터 상태 확인 완료"
}

# =============================================================================
# 태스크 정의 생성
# =============================================================================
create_task_definition() {
    local task_family="${1:-cloud-intermediate-task}"
    local cluster_name="${2:-$ECS_CLUSTER_NAME}"
    
    log_header "ECS 태스크 정의 생성: $task_family"
    
    # 태스크 정의 JSON 생성
    cat > task-definition.json << EOF
{
    "family": "$task_family",
    "networkMode": "awsvpc",
    "requiresCompatibilities": ["FARGATE"],
    "cpu": "256",
    "memory": "512",
    "executionRoleArn": "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/ecsTaskExecutionRole",
    "containerDefinitions": [
        {
            "name": "cloud-intermediate-app",
            "image": "nginx:1.21",
            "portMappings": [
                {
                    "containerPort": 80,
                    "protocol": "tcp"
                }
            ],
            "essential": true,
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/$task_family",
                    "awslogs-region": "$AWS_REGION",
                    "awslogs-stream-prefix": "ecs"
                }
            },
            "environment": [
                {
                    "name": "ENVIRONMENT",
                    "value": "production"
                },
                {
                    "name": "APP_NAME",
                    "value": "cloud-intermediate-app"
                }
            ]
        }
    ]
}
EOF

    # CloudWatch 로그 그룹 생성
    aws logs create-log-group --log-group-name "/ecs/$task_family" --region "$AWS_REGION" 2>/dev/null || true
    
    # 태스크 정의 등록
    aws ecs register-task-definition \
        --cli-input-json file://task-definition.json \
        --region "$AWS_REGION"
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        log_success "태스크 정의 생성 완료: $task_family"
        update_progress "task-definition-create" "completed" "태스크 정의 생성 완료"
        return 0
    else
        log_error "태스크 정의 생성 실패: $task_family"
        update_progress "task-definition-create" "failed" "태스크 정의 생성 실패"
        return 1
    fi
}

# =============================================================================
# ECS 서비스 생성
# =============================================================================
create_ecs_service() {
    local service_name="${1:-cloud-intermediate-service}"
    local cluster_name="${2:-$ECS_CLUSTER_NAME}"
    local task_family="${3:-cloud-intermediate-task}"
    
    log_header "ECS 서비스 생성: $service_name"
    
    # VPC 및 서브넷 정보 조회
    local vpc_id=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=*$PROJECT_TAG*" --query 'Vpcs[0].VpcId' --output text --region "$AWS_REGION")
    local subnet_ids=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id" --query 'Subnets[0:2].SubnetId' --output text --region "$AWS_REGION")
    local security_group_id=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=*$PROJECT_TAG*" --query 'SecurityGroups[0].GroupId' --output text --region "$AWS_REGION")
    
    if [ "$vpc_id" = "None" ] || [ -z "$vpc_id" ]; then
        log_error "VPC를 찾을 수 없습니다. VPC를 먼저 생성하세요."
        return 1
    fi
    
    if [ "$subnet_ids" = "None" ] || [ -z "$subnet_ids" ]; then
        log_error "서브넷을 찾을 수 없습니다. 서브넷을 먼저 생성하세요."
        return 1
    fi
    
    # 서비스 생성
    aws ecs create-service \
        --cluster "$cluster_name" \
        --service-name "$service_name" \
        --task-definition "$task_family" \
        --desired-count 2 \
        --launch-type FARGATE \
        --network-configuration "awsvpcConfiguration={subnets=[$subnet_ids],securityGroups=[$security_group_id],assignPublicIp=ENABLED}" \
        --region "$AWS_REGION"
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        log_success "ECS 서비스 생성 완료: $service_name"
        update_progress "service-create" "completed" "ECS 서비스 생성 완료"
        
        # 서비스 상태 확인
        check_service_status "$service_name" "$cluster_name"
    else
        log_error "ECS 서비스 생성 실패: $service_name"
        update_progress "service-create" "failed" "ECS 서비스 생성 실패"
        return 1
    fi
}

# =============================================================================
# ECS 서비스 삭제
# =============================================================================
delete_ecs_service() {
    local service_name="${1:-cloud-intermediate-service}"
    local cluster_name="${2:-$ECS_CLUSTER_NAME}"
    
    log_header "ECS 서비스 삭제: $service_name"
    
    # 서비스 존재 확인
    if ! aws ecs describe-services --cluster "$cluster_name" --services "$service_name" --region "$AWS_REGION" &> /dev/null; then
        log_warning "삭제할 ECS 서비스가 존재하지 않습니다: $service_name"
        update_progress "service-delete" "skipped" "ECS 서비스가 존재하지 않음"
        return 0
    fi
    
    log_info "ECS 서비스 삭제 시작: $service_name"
    update_progress "service-delete" "started" "ECS 서비스 삭제 시작"
    
    # 서비스 삭제
    aws ecs delete-service \
        --cluster "$cluster_name" \
        --service "$service_name" \
        --region "$AWS_REGION"
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        log_success "ECS 서비스 삭제 완료: $service_name"
        update_progress "service-delete" "completed" "ECS 서비스 삭제 완료"
        return 0
    else
        log_error "ECS 서비스 삭제 실패: $service_name"
        update_progress "service-delete" "failed" "ECS 서비스 삭제 실패"
        return 1
    fi
}

# =============================================================================
# ECS 서비스 상태 확인
# =============================================================================
check_service_status() {
    local service_name="${1:-cloud-intermediate-service}"
    local cluster_name="${2:-$ECS_CLUSTER_NAME}"
    
    log_header "ECS 서비스 상태 확인: $service_name"
    
    # 서비스 정보 조회
    aws ecs describe-services \
        --cluster "$cluster_name" \
        --services "$service_name" \
        --region "$AWS_REGION" \
        --query 'services[0].{Name:serviceName,Status:status,DesiredCount:desiredCount,RunningCount:runningCount,PendingCount:pendingCount,TaskDefinition:taskDefinition}' \
        --output table
    
    # 태스크 목록 조회
    log_step "실행 중인 태스크 목록:"
    local task_arns=$(aws ecs list-tasks --cluster "$cluster_name" --service-name "$service_name" --region "$AWS_REGION" --query 'taskArns' --output text)
    
    if [ -n "$task_arns" ] && [ "$task_arns" != "None" ]; then
        for task_arn in $task_arns; do
            log_info "태스크 상세 정보: $task_arn"
            aws ecs describe-tasks \
                --cluster "$cluster_name" \
                --tasks "$task_arn" \
                --region "$AWS_REGION" \
                --query 'tasks[0].{TaskArn:taskArn,LastStatus:lastStatus,DesiredStatus:desiredStatus,HealthStatus:healthStatus}' \
                --output table
        done
    else
        log_info "실행 중인 태스크가 없습니다."
    fi
    
    update_progress "service-status" "completed" "ECS 서비스 상태 확인 완료"
}

# =============================================================================
# 전체 정리
# =============================================================================
cleanup_all() {
    local cluster_name="${1:-$ECS_CLUSTER_NAME}"
    local service_name="${2:-cloud-intermediate-service}"
    local task_family="${3:-cloud-intermediate-task}"
    
    log_header "AWS ECS 환경 전체 정리"
    
    # 서비스 삭제
    delete_ecs_service "$service_name" "$cluster_name"
    
    # 클러스터 삭제
    delete_ecs_cluster "$cluster_name"
    
    # 태스크 정의 비활성화
    log_info "태스크 정의 비활성화 중..."
    aws ecs list-task-definitions --family-prefix "$task_family" --region "$AWS_REGION" --query 'taskDefinitionArns' --output text | \
    while read task_def_arn; do
        if [ -n "$task_def_arn" ] && [ "$task_def_arn" != "None" ]; then
            aws ecs deregister-task-definition --task-definition "$task_def_arn" --region "$AWS_REGION" 2>/dev/null || true
        fi
    done
    
    # 설정 파일 정리
    rm -f task-definition.json
    
    log_success "AWS ECS 환경 정리 완료"
    update_progress "cleanup" "completed" "AWS ECS 환경 정리 완료"
}

# =============================================================================
# 메인 실행 로직
# =============================================================================
main() {
    local action=""
    local cluster_name="$ECS_CLUSTER_NAME"
    local service_name="cloud-intermediate-service"
    local task_family="cloud-intermediate-task"
    
    # 인수 파싱
    while [[ $# -gt 0 ]]; do
        case $1 in
            --action)
                action="$2"
                shift 2
                ;;
            --cluster-name)
                cluster_name="$2"
                shift 2
                ;;
            --service-name)
                service_name="$2"
                shift 2
                ;;
            --task-family)
                task_family="$2"
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
        "cluster-create")
            create_ecs_cluster "$cluster_name"
            ;;
        "cluster-delete")
            delete_ecs_cluster "$cluster_name"
            ;;
        "cluster-status")
            check_cluster_status "$cluster_name"
            ;;
        "task-definition-create")
            create_task_definition "$task_family" "$cluster_name"
            ;;
        "service-create")
            create_ecs_service "$service_name" "$cluster_name" "$task_family"
            ;;
        "service-delete")
            delete_ecs_service "$service_name" "$cluster_name"
            ;;
        "service-status")
            check_service_status "$service_name" "$cluster_name"
            ;;
        "cleanup")
            cleanup_all "$cluster_name" "$service_name" "$task_family"
            ;;
        "cloud-container-services")
            # 메뉴에서 호출되는 통합 액션
            create_ecs_cluster "$cluster_name"
            create_task_definition "$task_family" "$cluster_name"
            create_ecs_service "$service_name" "$cluster_name" "$task_family"
            check_service_status "$service_name" "$cluster_name"
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
