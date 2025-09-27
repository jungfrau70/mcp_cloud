#!/bin/bash

# 강의 진행 실시간 모니터링 스크립트
# 자동화 코드 실행 상태와 강의 진행 상황을 실시간으로 모니터링

# 오류 처리 설정
set -e
set -u
set -o pipefail

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 로그 함수들
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}=== $1 ===${NC}"; }
log_progress() { echo -e "${CYAN}[PROGRESS]${NC} $1"; }

# 강의 진행 상태 추적
LECTURE_PROGRESS_FILE="/tmp/lecture_progress.json"
LECTURE_LOG_FILE="/tmp/lecture_monitor.log"

# 강의 진행 상태 초기화
init_lecture_progress() {
    cat > "$LECTURE_PROGRESS_FILE" << 'EOF'
{
  "lecture": {
    "day1": {
      "status": "not_started",
      "progress": 0,
      "completed_sections": [],
      "current_section": null,
      "start_time": null,
      "end_time": null
    },
    "day2": {
      "status": "not_started", 
      "progress": 0,
      "completed_sections": [],
      "current_section": null,
      "start_time": null,
      "end_time": null
    }
  },
  "automation": {
    "scripts_running": [],
    "scripts_completed": [],
    "scripts_failed": [],
    "total_scripts": 0,
    "success_rate": 0
  },
  "resources": {
    "docker_containers": 0,
    "kubernetes_pods": 0,
    "aws_resources": 0,
    "gcp_resources": 0
  },
  "last_updated": null
}
EOF
    log_success "강의 진행 상태 초기화 완료"
}

# 강의 진행 상태 업데이트
update_lecture_progress() {
    local day="$1"
    local section="$2"
    local status="$3"
    local progress="$4"
    
    # JSON 업데이트 (jq 사용)
    if command -v jq &> /dev/null; then
        jq --arg day "$day" --arg section "$section" --arg status "$status" --argjson progress "$progress" \
           '.lecture[$day].status = $status | 
            .lecture[$day].current_section = $section |
            .lecture[$day].progress = $progress |
            .last_updated = now' \
           "$LECTURE_PROGRESS_FILE" > "${LECTURE_PROGRESS_FILE}.tmp" && \
        mv "${LECTURE_PROGRESS_FILE}.tmp" "$LECTURE_PROGRESS_FILE"
    fi
    
    log_progress "Day $day - $section: $status (${progress}%)"
}

# 자동화 스크립트 상태 모니터링
monitor_automation_scripts() {
    log_header "자동화 스크립트 상태 모니터링"
    
    local scripts=(
        "day1-practice.sh"
        "day2-practice.sh" 
        "cloud-intermediate-helper.sh"
        "aws-eks-helper.sh"
        "gcp-gke-helper.sh"
        "cloud-cluster-helper.sh"
        "monitoring-stack.sh"
        "cleanup-resources.sh"
    )
    
    local running_count=0
    local completed_count=0
    local failed_count=0
    
    for script in "${scripts[@]}"; do
        if pgrep -f "$script" > /dev/null; then
            log_info "실행 중: $script"
            running_count=$((running_count + 1))
        elif [ -f "/tmp/${script}.completed" ]; then
            log_success "완료됨: $script"
            completed_count=$((completed_count + 1))
        elif [ -f "/tmp/${script}.failed" ]; then
            log_error "실패함: $script"
            failed_count=$((failed_count + 1))
        fi
    done
    
    local total_scripts=${#scripts[@]}
    local success_rate=$((completed_count * 100 / total_scripts))
    
    log_info "실행 중: $running_count, 완료: $completed_count, 실패: $failed_count"
    log_info "성공률: $success_rate%"
}

# 리소스 상태 모니터링
monitor_resources() {
    log_header "리소스 상태 모니터링"
    
    # Docker 컨테이너 수
    local docker_count=$(docker ps -q | wc -l)
    log_info "Docker 컨테이너: $docker_count개 실행 중"
    
    # Kubernetes Pod 수
    local k8s_count=0
    if command -v kubectl &> /dev/null; then
        k8s_count=$(kubectl get pods --all-namespaces --no-headers 2>/dev/null | wc -l)
    fi
    log_info "Kubernetes Pod: $k8s_count개 실행 중"
    
    # AWS 리소스 수
    local aws_count=0
    if command -v aws &> /dev/null; then
        aws_count=$(aws ec2 describe-instances --query 'Reservations[].Instances[?State.Name==`running`]' --output text 2>/dev/null | wc -l)
    fi
    log_info "AWS EC2 인스턴스: $aws_count개 실행 중"
    
    # GCP 리소스 수
    local gcp_count=0
    if command -v gcloud &> /dev/null; then
        gcp_count=$(gcloud compute instances list --filter="status:RUNNING" --format="value(name)" 2>/dev/null | wc -l)
    fi
    log_info "GCP 인스턴스: $gcp_count개 실행 중"
}

# 강의 진행률 계산
calculate_lecture_progress() {
    local day="$1"
    
    if [ "$day" = "day1" ]; then
        local sections=("docker-advanced" "kubernetes-basics" "cloud-services" "monitoring-hub")
    else
        local sections=("cicd-pipeline" "cloud-deployment" "monitoring-basics")
    fi
    
    local completed=0
    local total=${#sections[@]}
    
    for section in "${sections[@]}"; do
        if [ -f "/tmp/${day}-${section}.completed" ]; then
            completed=$((completed + 1))
        fi
    done
    
    local progress=$((completed * 100 / total))
    echo "$progress"
}

# 실시간 대시보드 표시
show_dashboard() {
    clear
    log_header "Cloud Intermediate 강의 진행 대시보드"
    echo ""
    
    # 강의 진행 상태
    log_info "📚 강의 진행 상태"
    local day1_progress=$(calculate_lecture_progress "day1")
    local day2_progress=$(calculate_lecture_progress "day2")
    
    echo "  Day 1: ${day1_progress}% 완료"
    echo "  Day 2: ${day2_progress}% 완료"
    echo ""
    
    # 자동화 스크립트 상태
    log_info "🤖 자동화 스크립트 상태"
    monitor_automation_scripts
    echo ""
    
    # 리소스 상태
    log_info "💻 리소스 상태"
    monitor_resources
    echo ""
    
    # 최근 로그
    log_info "📝 최근 활동"
    if [ -f "$LECTURE_LOG_FILE" ]; then
        tail -5 "$LECTURE_LOG_FILE"
    fi
    echo ""
    
    log_info "대시보드 새로고침: 5초 후..."
    sleep 5
}

# 강의 섹션 완료 마킹
mark_section_completed() {
    local day="$1"
    local section="$2"
    
    touch "/tmp/${day}-${section}.completed"
    update_lecture_progress "$day" "$section" "completed" 100
    
    log_success "✅ $day - $section 섹션 완료"
}

# 강의 섹션 시작 마킹
mark_section_started() {
    local day="$1"
    local section="$2"
    
    update_lecture_progress "$day" "$section" "in_progress" 0
    log_progress "🚀 $day - $section 섹션 시작"
}

# 자동화 스크립트 실행 및 모니터링
run_automation_with_monitoring() {
    local script="$1"
    local day="$2"
    local section="$3"
    
    log_header "자동화 스크립트 실행: $script"
    
    # 섹션 시작 마킹
    mark_section_started "$day" "$section"
    
    # 스크립트 실행
    if ./"$script" --action "$section" 2>&1 | tee -a "$LECTURE_LOG_FILE"; then
        # 성공 시 완료 마킹
        mark_section_completed "$day" "$section"
        touch "/tmp/${script}.completed"
        log_success "✅ $script 실행 완료"
    else
        # 실패 시 실패 마킹
        touch "/tmp/${script}.failed"
        log_error "❌ $script 실행 실패"
        return 1
    fi
}

# 전체 강의 시나리오 실행
run_full_lecture_scenario() {
    log_header "Cloud Intermediate 전체 강의 시나리오 실행"
    
    # 진행 상태 초기화
    init_lecture_progress
    
    # Day 1 실습
    log_header "Day 1 실습 시작"
    run_automation_with_monitoring "day1-practice.sh" "day1" "docker-advanced"
    run_automation_with_monitoring "day1-practice.sh" "day1" "kubernetes-basics"
    run_automation_with_monitoring "day1-practice.sh" "day1" "cloud-services"
    run_automation_with_monitoring "day1-practice.sh" "day1" "monitoring-hub"
    
    # Day 2 실습
    log_header "Day 2 실습 시작"
    run_automation_with_monitoring "day2-practice.sh" "day2" "cicd-pipeline"
    run_automation_with_monitoring "day2-practice.sh" "day2" "cloud-deployment"
    run_automation_with_monitoring "day2-practice.sh" "day2" "monitoring-basics"
    
    # 리소스 정리
    log_header "리소스 정리"
    run_automation_with_monitoring "cleanup-resources.sh" "cleanup" "all"
    
    log_success "🎉 전체 강의 시나리오 완료!"
}

# 사용법 출력
usage() {
    echo "강의 진행 실시간 모니터링 스크립트"
    echo ""
    echo "사용법:"
    echo "  $0 [옵션]"
    echo ""
    echo "옵션:"
    echo "  --dashboard, -d              # 실시간 대시보드 표시"
    echo "  --monitor, -m                # 자동화 스크립트 모니터링"
    echo "  --run-full, -r               # 전체 강의 시나리오 실행"
    echo "  --status, -s                 # 현재 상태 확인"
    echo "  --help, -h                   # 도움말 표시"
    echo ""
    echo "예시:"
    echo "  $0 --dashboard               # 실시간 대시보드"
    echo "  $0 --run-full                # 전체 강의 실행"
}

# 메인 함수
main() {
    case "${1:-}" in
        "--dashboard"|"-d")
            while true; do
                show_dashboard
            done
            ;;
        "--monitor"|"-m")
            monitor_automation_scripts
            monitor_resources
            ;;
        "--run-full"|"-r")
            run_full_lecture_scenario
            ;;
        "--status"|"-s")
            if [ -f "$LECTURE_PROGRESS_FILE" ]; then
                cat "$LECTURE_PROGRESS_FILE" | jq '.' 2>/dev/null || cat "$LECTURE_PROGRESS_FILE"
            else
                log_warning "진행 상태 파일이 없습니다."
            fi
            ;;
        "--help"|"-h")
            usage
            exit 0
            ;;
        *)
            log_error "알 수 없는 옵션: $1"
            usage
            exit 1
            ;;
    esac
}

# 스크립트 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
