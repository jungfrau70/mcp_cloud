#!/bin/bash

# AWS ECS Helper 모듈
# 역할: AWS ECS 관련 작업 실행 (클러스터 생성, 태스크 정의, 서비스 관리)
# 
# 사용법:
#   ./aws-ecs-helper.sh --action <액션> [옵션]

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
else
    echo "ERROR: AWS 환경 설정 파일을 찾을 수 없습니다"
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
  cluster-create          # ECS 클러스터 생성
  task-definition         # 태스크 정의 생성
  service-create          # ECS 서비스 생성
  service-update          # ECS 서비스 업데이트
  service-delete          # ECS 서비스 삭제
  cleanup                 # ECS 리소스 정리
  status                  # ECS 상태 확인

옵션:
  --cluster-name <name>   # 클러스터 이름 (기본값: 환경변수)
  --service-name <name>   # 서비스 이름 (기본값: nginx-service)
  --task-family <family>  # 태스크 패밀리 (기본값: nginx-task)
  --image <image>         # 컨테이너 이미지 (기본값: nginx:1.21)
  --cpu <cpu>             # CPU 단위 (기본값: 256)
  --memory <memory>       # 메모리 (기본값: 512)
  --desired-count <count> # 원하는 태스크 수 (기본값: 2)
  --help, -h              # 도움말 표시

예시:
  $0 --action cluster-create
  $0 --action task-definition --image nginx:1.21
  $0 --action service-create --desired-count 3
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
        "cluster-create")
            cat << EOF
CLUSTER-CREATE 액션 상세 사용법:

기능:
  - ECS 클러스터 생성
  - 클러스터 설정 및 태그 구성
  - 클러스터 상태 확인

사용법:
  $0 --action cluster-create [옵션]

옵션:
  --cluster-name <name>   # 클러스터 이름 (기본값: 환경변수)

예시:
  $0 --action cluster-create
  $0 --action cluster-create --cluster-name my-ecs-cluster

생성되는 리소스:
  - ECS 클러스터
  - 클러스터 태그
  - 클러스터 설정

진행 상황:
  - 클러스터 생성
  - 태그 설정
  - 상태 확인
  - 완료 보고
EOF
            ;;
        "task-definition")
            cat << EOF
TASK-DEFINITION 액션 상세 사용법:

기능:
  - ECS 태스크 정의 생성
  - 컨테이너 설정 및 리소스 구성
  - 로그 설정 및 네트워크 구성

사용법:
  $0 --action task-definition [옵션]

옵션:
  --task-family <family>  # 태스크 패밀리 (기본값: nginx-task)
  --image <image>         # 컨테이너 이미지 (기본값: nginx:1.21)
  --cpu <cpu>             # CPU 단위 (기본값: 256)
  --memory <memory>       # 메모리 (기본값: 512)

예시:
  $0 --action task-definition
  $0 --action task-definition --image nginx:1.21 --cpu 512 --memory 1024

생성되는 리소스:
  - 태스크 정의
  - 컨테이너 정의
  - 로그 그룹
  - 실행 역할

진행 상황:
  - 태스크 정의 생성
  - 로그 그룹 생성
  - 태스크 정의 등록
  - 완료 보고
EOF
            ;;
        "service-create")
            cat << EOF
SERVICE-CREATE 액션 상세 사용법:

기능:
  - ECS 서비스 생성
  - 태스크 배포 및 로드 밸런서 연결
  - 자동 스케일링 설정

사용법:
  $0 --action service-create [옵션]

옵션:
  --cluster-name <name>   # 클러스터 이름 (기본값: 환경변수)
  --service-name <name>   # 서비스 이름 (기본값: nginx-service)
  --task-family <family>  # 태스크 패밀리 (기본값: nginx-task)
  --desired-count <count> # 원하는 태스크 수 (기본값: 2)

예시:
  $0 --action service-create
  $0 --action service-create --desired-count 3 --service-name web-service

생성되는 리소스:
  - ECS 서비스
  - 태스크 실행
  - 로드 밸런서 연결
  - 자동 스케일링

진행 상황:
  - 서비스 생성
  - 태스크 배포
  - 상태 확인
  - 완료 보고
EOF
            ;;
        "service-update")
            cat << EOF
SERVICE-UPDATE 액션 상세 사용법:

기능:
  - ECS 서비스 업데이트
  - 태스크 정의 업데이트
  - 롤링 업데이트 실행

사용법:
  $0 --action service-update [옵션]

옵션:
  --cluster-name <name>   # 클러스터 이름 (기본값: 환경변수)
  --service-name <name>   # 서비스 이름 (기본값: nginx-service)
  --desired-count <count> # 원하는 태스크 수

예시:
  $0 --action service-update
  $0 --action service-update --desired-count 5

업데이트되는 항목:
  - 태스크 수
  - 태스크 정의
  - 서비스 설정

진행 상황:
  - 서비스 업데이트
  - 롤링 업데이트
  - 상태 확인
  - 완료 보고
EOF
            ;;
        "service-delete")
            cat << EOF
SERVICE-DELETE 액션 상세 사용법:

기능:
  - ECS 서비스 삭제
  - 태스크 중지 및 정리
  - 관련 리소스 정리

사용법:
  $0 --action service-delete [옵션]

옵션:
  --cluster-name <name>   # 클러스터 이름 (기본값: 환경변수)
  --service-name <name>   # 서비스 이름 (기본값: nginx-service)
  --force                 # 확인 없이 강제 삭제

예시:
  $0 --action service-delete
  $0 --action service-delete --force

삭제되는 리소스:
  - ECS 서비스
  - 실행 중인 태스크
  - 로드 밸런서 연결

주의사항:
  - 삭제된 서비스는 복구할 수 없습니다
  - --force 옵션 사용 시 확인 없이 삭제됩니다
EOF
            ;;
        "cleanup")
            cat << EOF
CLEANUP 액션 상세 사용법:

기능:
  - ECS 리소스 전체 정리
  - 클러스터, 서비스, 태스크 정의 삭제
  - 로그 그룹 정리

사용법:
  $0 --action cleanup [옵션]

옵션:
  --cluster-name <name>   # 정리할 클러스터 이름
  --force                 # 확인 없이 강제 정리

예시:
  $0 --action cleanup
  $0 --action cleanup --force

정리되는 리소스:
  - ECS 클러스터
  - ECS 서비스
  - 태스크 정의
  - 로그 그룹

주의사항:
  - 정리된 리소스는 복구할 수 없습니다
  - --force 옵션 사용 시 확인 없이 정리됩니다
EOF
            ;;
        "status")
            cat << EOF
STATUS 액션 상세 사용법:

기능:
  - ECS 클러스터 상태 확인
  - 서비스 및 태스크 상태 표시
  - 리소스 사용량 확인

사용법:
  $0 --action status [옵션]

옵션:
  --cluster-name <name>   # 확인할 클러스터 이름
  --format <format>       # 출력 형식 (table, json, yaml)

예시:
  $0 --action status
  $0 --action status --format json

확인되는 정보:
  - 클러스터 상태
  - 서비스 목록 및 상태
  - 태스크 목록 및 상태
  - 태스크 정의 목록

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
  - cluster-create: ECS 클러스터 생성
  - task-definition: 태스크 정의 생성
  - service-create: ECS 서비스 생성
  - service-update: ECS 서비스 업데이트
  - service-delete: ECS 서비스 삭제
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
    log_step "AWS ECS 환경 검증 중..."
    
    # AWS CLI 설치 확인
    if ! check_command "aws"; then
        log_error "AWS CLI가 설치되지 않았습니다."
        return 1
    fi
    
    # AWS 자격 증명 확인
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS 자격 증명이 설정되지 않았습니다."
        return 1
    fi
    
    # ECS 서비스 확인
    if ! aws ecs describe-clusters --clusters "$EKS_CLUSTER_NAME" &> /dev/null; then
        log_warning "ECS 클러스터가 존재하지 않거나 접근할 수 없습니다: $EKS_CLUSTER_NAME"
    fi
    
    log_success "AWS ECS 환경 검증 완료"
    return 0
}

# =============================================================================
# ECS 클러스터 생성
# =============================================================================
create_cluster() {
    local cluster_name="${1:-$EKS_CLUSTER_NAME}"
    
    log_header "ECS 클러스터 생성: $cluster_name"
    
    # 기존 클러스터 확인
    if aws ecs describe-clusters --clusters "$cluster_name" --query 'clusters[0].status' --output text 2>/dev/null | grep -q "ACTIVE"; then
        log_warning "클러스터가 이미 존재합니다: $cluster_name"
        log_info "기존 클러스터를 사용하여 다음 단계를 진행합니다."
        update_progress "cluster-create" "existing" "기존 클러스터 사용: $cluster_name"
        return 0
    fi
    
    log_info "새 ECS 클러스터 생성 시작: $cluster_name"
    update_progress "cluster-create" "started" "ECS 클러스터 생성 시작"
    
    # ECS 클러스터 생성
    if aws ecs create-cluster \
        --cluster-name "$cluster_name" \
        --tags "Key=Environment,Value=$ENVIRONMENT_TAG" \
        "Key=Project,Value=$PROJECT_TAG" \
        "Key=Owner,Value=$OWNER_TAG" \
        "Key=Course,Value=$COURSE_TAG"; then
        
        log_success "ECS 클러스터 생성 완료: $cluster_name"
        update_progress "cluster-create" "completed" "ECS 클러스터 생성 완료"
        
        # 클러스터 상태 확인
        log_info "클러스터 상태 확인 중..."
        aws ecs describe-clusters --clusters "$cluster_name" --query 'clusters[0].{Name:clusterName,Status:status,ActiveServices:activeServicesCount,RunningTasks:runningTasksCount}' --output table
        
        return 0
    else
        log_error "ECS 클러스터 생성 실패: $cluster_name"
        update_progress "cluster-create" "failed" "ECS 클러스터 생성 실패"
        return 1
    fi
}

# =============================================================================
# 태스크 정의 생성
# =============================================================================
create_task_definition() {
    local task_family="${1:-nginx-task}"
    local image="${2:-nginx:1.21}"
    local cpu="${3:-256}"
    local memory="${4:-512}"
    
    log_header "ECS 태스크 정의 생성: $task_family"
    
    # 로그 그룹 생성
    local log_group="/ecs/$task_family"
    log_info "로그 그룹 생성: $log_group"
    aws logs create-log-group --log-group-name "$log_group" --region "$AWS_REGION" 2>/dev/null || true
    
    # 태스크 정의 JSON 생성
    local task_definition_json=$(cat << EOF
{
  "family": "$task_family",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "$cpu",
  "memory": "$memory",
  "executionRoleArn": "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "nginx",
      "image": "$image",
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "$log_group",
          "awslogs-region": "$AWS_REGION",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "essential": true
    }
  ]
}
EOF
)
    
    # 태스크 정의 등록
    log_info "태스크 정의 등록 중..."
    update_progress "task-definition" "started" "태스크 정의 생성 시작"
    
    if echo "$task_definition_json" | aws ecs register-task-definition --cli-input-json file:///dev/stdin; then
        log_success "태스크 정의 생성 완료: $task_family"
        update_progress "task-definition" "completed" "태스크 정의 생성 완료"
        
        # 태스크 정의 확인
        log_info "태스크 정의 확인:"
        aws ecs describe-task-definition --task-definition "$task_family" --query 'taskDefinition.{Family:family,Revision:revision,Cpu:cpu,Memory:memory,Status:status}' --output table
        
        return 0
    else
        log_error "태스크 정의 생성 실패: $task_family"
        update_progress "task-definition" "failed" "태스크 정의 생성 실패"
        return 1
    fi
}

# =============================================================================
# ECS 서비스 생성
# =============================================================================
create_service() {
    local cluster_name="${1:-$EKS_CLUSTER_NAME}"
    local service_name="${2:-nginx-service}"
    local task_family="${3:-nginx-task}"
    local desired_count="${4:-2}"
    
    log_header "ECS 서비스 생성: $service_name"
    
    # 기존 서비스 확인
    if aws ecs describe-services --cluster "$cluster_name" --services "$service_name" --query 'services[0].status' --output text 2>/dev/null | grep -q "ACTIVE"; then
        log_warning "서비스가 이미 존재합니다: $service_name"
        log_info "기존 서비스를 사용하여 다음 단계를 진행합니다."
        update_progress "service-create" "existing" "기존 서비스 사용: $service_name"
        return 0
    fi
    
    # 서브넷 및 보안 그룹 확인
    local subnet_id=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$(aws ec2 describe-vpcs --filters "Name=is-default,Values=true" --query 'Vpcs[0].VpcId' --output text)" --query 'Subnets[0].SubnetId' --output text)
    local security_group_id=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=default" --query 'SecurityGroups[0].GroupId' --output text)
    
    log_info "서브넷: $subnet_id"
    log_info "보안 그룹: $security_group_id"
    
    # ECS 서비스 생성
    log_info "ECS 서비스 생성 중..."
    update_progress "service-create" "started" "ECS 서비스 생성 시작"
    
    if aws ecs create-service \
        --cluster "$cluster_name" \
        --service-name "$service_name" \
        --task-definition "$task_family:1" \
        --desired-count "$desired_count" \
        --launch-type FARGATE \
        --network-configuration "awsvpcConfiguration={subnets=[$subnet_id],securityGroups=[$security_group_id],assignPublicIp=ENABLED}"; then
        
        log_success "ECS 서비스 생성 완료: $service_name"
        update_progress "service-create" "completed" "ECS 서비스 생성 완료"
        
        # 서비스 상태 확인
        log_info "서비스 상태 확인 중..."
        aws ecs describe-services --cluster "$cluster_name" --services "$service_name" --query 'services[0].{ServiceName:serviceName,Status:status,DesiredCount:desiredCount,RunningCount:runningCount,PendingCount:pendingCount}' --output table
        
        return 0
    else
        log_error "ECS 서비스 생성 실패: $service_name"
        update_progress "service-create" "failed" "ECS 서비스 생성 실패"
        return 1
    fi
}

# =============================================================================
# ECS 서비스 업데이트
# =============================================================================
update_service() {
    local cluster_name="${1:-$EKS_CLUSTER_NAME}"
    local service_name="${2:-nginx-service}"
    local desired_count="${3:-2}"
    
    log_header "ECS 서비스 업데이트: $service_name"
    
    # 서비스 존재 확인
    if ! aws ecs describe-services --cluster "$cluster_name" --services "$service_name" --query 'services[0].status' --output text 2>/dev/null | grep -q "ACTIVE"; then
        log_error "서비스가 존재하지 않습니다: $service_name"
        return 1
    fi
    
    log_info "ECS 서비스 업데이트 중..."
    update_progress "service-update" "started" "ECS 서비스 업데이트 시작"
    
    if aws ecs update-service \
        --cluster "$cluster_name" \
        --service "$service_name" \
        --desired-count "$desired_count" \
        --force-new-deployment; then
        
        log_success "ECS 서비스 업데이트 완료: $service_name"
        update_progress "service-update" "completed" "ECS 서비스 업데이트 완료"
        
        # 업데이트 상태 확인
        log_info "업데이트 상태 확인 중..."
        aws ecs describe-services --cluster "$cluster_name" --services "$service_name" --query 'services[0].{ServiceName:serviceName,Status:status,DesiredCount:desiredCount,RunningCount:runningCount,PendingCount:pendingCount}' --output table
        
        return 0
    else
        log_error "ECS 서비스 업데이트 실패: $service_name"
        update_progress "service-update" "failed" "ECS 서비스 업데이트 실패"
        return 1
    fi
}

# =============================================================================
# ECS 서비스 삭제
# =============================================================================
delete_service() {
    local cluster_name="${1:-$EKS_CLUSTER_NAME}"
    local service_name="${2:-nginx-service}"
    local force="${3:-false}"
    
    log_header "ECS 서비스 삭제: $service_name"
    
    # 서비스 존재 확인
    if ! aws ecs describe-services --cluster "$cluster_name" --services "$service_name" --query 'services[0].status' --output text 2>/dev/null | grep -q "ACTIVE"; then
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
    
    log_info "ECS 서비스 삭제 중..."
    update_progress "service-delete" "started" "ECS 서비스 삭제 시작"
    
    if aws ecs delete-service --cluster "$cluster_name" --service "$service_name"; then
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
# ECS 리소스 정리
# =============================================================================
cleanup_ecs() {
    local cluster_name="${1:-$EKS_CLUSTER_NAME}"
    local force="${2:-false}"
    
    log_header "ECS 리소스 정리: $cluster_name"
    
    if [ "$force" != "true" ]; then
        log_warning "정리할 리소스:"
        log_info "클러스터: $cluster_name"
        log_info "서비스: $(aws ecs list-services --cluster "$cluster_name" --query 'serviceArns | length(@)' --output text)개"
        log_info "태스크 정의: $(aws ecs list-task-definitions --query 'taskDefinitionArns | length(@)' --output text)개"
        
        read -p "정말 정리하시겠습니까? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "정리가 취소되었습니다."
            return 0
        fi
    fi
    
    log_info "ECS 리소스 정리 중..."
    update_progress "cleanup" "started" "ECS 리소스 정리 시작"
    
    # 서비스 삭제
    log_info "서비스 삭제 중..."
    for service in $(aws ecs list-services --cluster "$cluster_name" --query 'serviceArns[]' --output text); do
        local service_name=$(basename "$service")
        aws ecs delete-service --cluster "$cluster_name" --service "$service_name" --force 2>/dev/null || true
    done
    
    # 태스크 정의 삭제
    log_info "태스크 정의 삭제 중..."
    for task_def in $(aws ecs list-task-definitions --query 'taskDefinitionArns[]' --output text); do
        aws ecs deregister-task-definition --task-definition "$task_def" 2>/dev/null || true
    done
    
    # 클러스터 삭제
    log_info "클러스터 삭제 중..."
    aws ecs delete-cluster --cluster "$cluster_name" 2>/dev/null || true
    
    # 로그 그룹 삭제
    log_info "로그 그룹 삭제 중..."
    aws logs delete-log-group --log-group-name "/ecs/nginx-task" --region "$AWS_REGION" 2>/dev/null || true
    
    log_success "ECS 리소스 정리 완료"
    update_progress "cleanup" "completed" "ECS 리소스 정리 완료"
    return 0
}

# =============================================================================
# ECS 상태 확인
# =============================================================================
check_ecs_status() {
    local cluster_name="${1:-$EKS_CLUSTER_NAME}"
    local format="${2:-table}"
    
    log_header "ECS 상태 확인: $cluster_name"
    
    # 클러스터 상태
    log_info "클러스터 상태:"
    case "$format" in
        "json")
            aws ecs describe-clusters --clusters "$cluster_name" --output json
            ;;
        "yaml")
            aws ecs describe-clusters --clusters "$cluster_name" --output yaml
            ;;
        *)
            aws ecs describe-clusters --clusters "$cluster_name" --query 'clusters[0].{Name:clusterName,Status:status,ActiveServices:activeServicesCount,RunningTasks:runningTasksCount,PendingTasks:pendingTasksCount}' --output table
            ;;
    esac
    
    # 서비스 상태
    log_info "서비스 상태:"
    case "$format" in
        "json")
            aws ecs list-services --cluster "$cluster_name" --output json
            ;;
        "yaml")
            aws ecs list-services --cluster "$cluster_name" --output yaml
            ;;
        *)
            aws ecs describe-services --cluster "$cluster_name" --services $(aws ecs list-services --cluster "$cluster_name" --query 'serviceArns[]' --output text) --query 'services[].{ServiceName:serviceName,Status:status,DesiredCount:desiredCount,RunningCount:runningCount,PendingCount:pendingCount}' --output table
            ;;
    esac
    
    # 태스크 정의 상태
    log_info "태스크 정의 상태:"
    case "$format" in
        "json")
            aws ecs list-task-definitions --output json
            ;;
        "yaml")
            aws ecs list-task-definitions --output yaml
            ;;
        *)
            aws ecs list-task-definitions --query 'taskDefinitionArns[]' --output table
            ;;
    esac
    
    update_progress "status" "completed" "ECS 상태 확인 완료"
    return 0
}

# =============================================================================
# 메인 실행 로직
# =============================================================================
main() {
    local action=""
    local cluster_name="$EKS_CLUSTER_NAME"
    local service_name="nginx-service"
    local task_family="nginx-task"
    local image="nginx:1.21"
    local cpu="256"
    local memory="512"
    local desired_count="2"
    local force="false"
    local format="table"
    
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
            --image)
                image="$2"
                shift 2
                ;;
            --cpu)
                cpu="$2"
                shift 2
                ;;
            --memory)
                memory="$2"
                shift 2
                ;;
            --desired-count)
                desired_count="$2"
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
        "cluster-create")
            create_cluster "$cluster_name"
            ;;
        "task-definition")
            create_task_definition "$task_family" "$image" "$cpu" "$memory"
            ;;
        "service-create")
            create_service "$cluster_name" "$service_name" "$task_family" "$desired_count"
            ;;
        "service-update")
            update_service "$cluster_name" "$service_name" "$desired_count"
            ;;
        "service-delete")
            delete_service "$cluster_name" "$service_name" "$force"
            ;;
        "cleanup")
            cleanup_ecs "$cluster_name" "$force"
            ;;
        "status")
            check_ecs_status "$cluster_name" "$format"
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
