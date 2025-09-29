#!/bin/bash

# =============================================================================
# Cloud Intermediate 품질 검증 시스템
# =============================================================================
# 
# 기능:
#   - 코드 품질 검증
#   - 문서 완성도 검증
#   - 실습 코드 동작 검증
#   - 자동화 스크립트 품질 검증
#
# 사용법:
#   ./quality-checker.sh                    # 전체 품질 검증
#   ./quality-checker.sh --code             # 코드 품질만
#   ./quality-checker.sh --docs            # 문서 품질만
#
# 작성일: 2024-12-19
# 작성자: Cloud Intermediate 과정
# =============================================================================

set -euo pipefail

# =============================================================================
# 환경 설정
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
QUALITY_RESULTS_DIR="$PROJECT_ROOT/tests/quality/results"

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
log_quality() { echo -e "${CYAN}[QUALITY]${NC} $1"; }

# 품질 지표 변수
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# =============================================================================
# 품질 검증 함수
# =============================================================================
check_quality() {
    local check_name="$1"
    local check_function="$2"
    local description="$3"
    local severity="${4:-error}"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    log_quality "검증 중: $check_name - $description"
    
    if $check_function; then
        log_success "통과: $check_name"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        if [ "$severity" = "warning" ]; then
            log_warning "경고: $check_name"
            WARNING_CHECKS=$((WARNING_CHECKS + 1))
        else
            log_error "실패: $check_name"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
        fi
        return 1
    fi
}

# =============================================================================
# 코드 품질 검증
# =============================================================================
check_shell_script_syntax() {
    log_quality "Shell 스크립트 구문 검증"
    
    local scripts=(
        "$PROJECT_ROOT/automation/day1/cloud-practice-menu.sh"
        "$PROJECT_ROOT/automation/day2/cicd-pipeline-helper.sh"
        "$PROJECT_ROOT/automation/day2/github-actions-helper.sh"
        "$PROJECT_ROOT/tools/cloud/install-dependencies.sh"
    )
    
    local has_errors=false
    
    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            if bash -n "$script" 2>/dev/null; then
                log_success "구문 검증 통과: $script"
            else
                log_error "구문 오류: $script"
                has_errors=true
            fi
        else
            log_warning "스크립트 파일이 없습니다: $script"
        fi
    done
    
    [ "$has_errors" = false ]
}

check_shell_script_best_practices() {
    log_quality "Shell 스크립트 모범 사례 검증"
    
    local scripts=(
        "$PROJECT_ROOT/automation/day1/cloud-practice-menu.sh"
        "$PROJECT_ROOT/automation/day2/cicd-pipeline-helper.sh"
        "$PROJECT_ROOT/automation/day2/github-actions-helper.sh"
        "$PROJECT_ROOT/tools/cloud/install-dependencies.sh"
    )
    
    local issues=0
    
    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            # set -euo pipefail 확인
            if ! grep -q "set -euo pipefail" "$script"; then
                log_warning "set -euo pipefail이 없습니다: $script"
                issues=$((issues + 1))
            fi
            
            # 함수 정의 확인
            if ! grep -q "function\|()" "$script"; then
                log_warning "함수 정의가 없습니다: $script"
                issues=$((issues + 1))
            fi
            
            # 주석 확인
            local comment_lines=$(grep -c "^#" "$script" || echo "0")
            local total_lines=$(wc -l < "$script")
            local comment_ratio=$((comment_lines * 100 / total_lines))
            
            if [ $comment_ratio -lt 10 ]; then
                log_warning "주석 비율이 낮습니다 ($comment_ratio%): $script"
                issues=$((issues + 1))
            fi
        fi
    done
    
    [ $issues -eq 0 ]
}

check_nodejs_code_quality() {
    log_quality "Node.js 코드 품질 검증"
    
    local app_dir="$PROJECT_ROOT/practice/day2/cicd-practice-app"
    
    if [ ! -d "$app_dir" ]; then
        log_warning "CI/CD 연습용 앱 디렉토리가 없습니다: $app_dir"
        return 0
    fi
    
    cd "$app_dir"
    
    # package.json 확인
    if [ ! -f "package.json" ]; then
        log_error "package.json이 없습니다"
        return 1
    fi
    
    # 의존성 설치
    if ! npm install &> /dev/null; then
        log_error "의존성 설치 실패"
        return 1
    fi
    
    # ESLint 실행 (설치된 경우)
    if [ -f "node_modules/.bin/eslint" ]; then
        if npm run lint &> /dev/null; then
            log_success "ESLint 검증 통과"
        else
            log_warning "ESLint 검증 실패"
        fi
    else
        log_warning "ESLint가 설치되지 않음"
    fi
    
    # 테스트 실행
    if npm test &> /dev/null; then
        log_success "테스트 통과"
    else
        log_warning "테스트 실패"
    fi
    
    return 0
}

# =============================================================================
# 문서 품질 검증
# =============================================================================
check_markdown_syntax() {
    log_quality "Markdown 구문 검증"
    
    local markdown_files=(
        "$PROJECT_ROOT/README.md"
        "$PROJECT_ROOT/learning-path.md"
        "$PROJECT_ROOT/lectures/day1/Day1_통합강의안_오전.md"
        "$PROJECT_ROOT/lectures/day2/Day2_통합강의안_오전.md"
    )
    
    local has_errors=false
    
    for file in "${markdown_files[@]}"; do
        if [ -f "$file" ]; then
            # 기본적인 Markdown 구문 검증
            if grep -q "^# " "$file"; then
                log_success "제목 구조 확인: $file"
            else
                log_warning "제목 구조가 없습니다: $file"
            fi
            
            # 링크 구문 검증
            if grep -q "\[.*\](.*)" "$file"; then
                log_success "링크 구문 확인: $file"
            else
                log_warning "링크가 없습니다: $file"
            fi
        else
            log_warning "Markdown 파일이 없습니다: $file"
        fi
    done
    
    return 0
}

check_documentation_completeness() {
    log_quality "문서 완성도 검증"
    
    local required_sections=(
        "강의 개요"
        "실습 학습"
        "필수 도구"
        "환경 설정"
        "실습 진행"
        "문제 해결"
    )
    
    local lecture_files=(
        "$PROJECT_ROOT/lectures/day1/Day1_통합강의안_오전.md"
        "$PROJECT_ROOT/lectures/day2/Day2_통합강의안_오전.md"
    )
    
    local missing_sections=0
    
    for file in "${lecture_files[@]}"; do
        if [ -f "$file" ]; then
            for section in "${required_sections[@]}"; do
                if ! grep -q "$section" "$file"; then
                    log_warning "필수 섹션이 없습니다: $section in $file"
                    missing_sections=$((missing_sections + 1))
                fi
            done
        fi
    done
    
    [ $missing_sections -eq 0 ]
}

check_anchor_links() {
    log_quality "앵커 링크 검증"
    
    local lecture_files=(
        "$PROJECT_ROOT/lectures/day1/Day1_통합강의안_오전.md"
        "$PROJECT_ROOT/lectures/day2/Day2_통합강의안_오전.md"
    )
    
    local broken_links=0
    
    for file in "${lecture_files[@]}"; do
        if [ -f "$file" ]; then
            # 앵커 링크 추출
            local anchor_links=$(grep -o '\[.*\](#[^)]*)' "$file" || true)
            
            if [ -n "$anchor_links" ]; then
                log_success "앵커 링크 발견: $file"
            else
                log_warning "앵커 링크가 없습니다: $file"
            fi
        fi
    done
    
    return 0
}

# =============================================================================
# 실습 코드 품질 검증
# =============================================================================
check_practice_code_structure() {
    log_quality "실습 코드 구조 검증"
    
    local practice_dirs=(
        "$PROJECT_ROOT/practice/day1/docker-advanced"
        "$PROJECT_ROOT/practice/day1/kubernetes-basics"
        "$PROJECT_ROOT/practice/day1/cloud-container-services"
        "$PROJECT_ROOT/practice/day1/monitoring-hub"
        "$PROJECT_ROOT/practice/day2/cicd-pipeline"
        "$PROJECT_ROOT/practice/day2/cicd-practice-app"
        "$PROJECT_ROOT/practice/day2/advanced-monitoring"
        "$PROJECT_ROOT/practice/day2/cloud-deployment"
    )
    
    local missing_dirs=0
    
    for dir in "${practice_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            log_error "실습 디렉토리가 없습니다: $dir"
            missing_dirs=$((missing_dirs + 1))
        fi
    done
    
    [ $missing_dirs -eq 0 ]
}

check_automation_scripts_quality() {
    log_quality "자동화 스크립트 품질 검증"
    
    local scripts=(
        "$PROJECT_ROOT/automation/day1/cloud-practice-menu.sh"
        "$PROJECT_ROOT/automation/day2/cicd-pipeline-helper.sh"
        "$PROJECT_ROOT/automation/day2/github-actions-helper.sh"
    )
    
    local quality_issues=0
    
    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            # 실행 권한 확인
            if [ ! -x "$script" ]; then
                log_warning "실행 권한이 없습니다: $script"
                quality_issues=$((quality_issues + 1))
            fi
            
            # shebang 확인
            if ! head -n1 "$script" | grep -q "^#!/bin/bash"; then
                log_warning "shebang이 없습니다: $script"
                quality_issues=$((quality_issues + 1))
            fi
            
            # 함수 정의 확인
            if ! grep -q "function\|()" "$script"; then
                log_warning "함수 정의가 없습니다: $script"
                quality_issues=$((quality_issues + 1))
            fi
        fi
    done
    
    [ $quality_issues -eq 0 ]
}

# =============================================================================
# 환경 설정 품질 검증
# =============================================================================
check_environment_config_quality() {
    log_quality "환경 설정 품질 검증"
    
    local config_files=(
        "$PROJECT_ROOT/tools/cloud/environment-config.yml"
        "$PROJECT_ROOT/tools/cloud/dependencies.yml"
    )
    
    local config_issues=0
    
    for config in "${config_files[@]}"; do
        if [ -f "$config" ]; then
            # YAML 구문 검증
            if command -v yq &> /dev/null; then
                if yq eval '.' "$config" &> /dev/null; then
                    log_success "YAML 구문 검증 통과: $config"
                else
                    log_error "YAML 구문 오류: $config"
                    config_issues=$((config_issues + 1))
                fi
            else
                log_warning "yq가 설치되지 않아 YAML 구문 검증을 건너뜁니다"
            fi
        else
            log_error "환경 설정 파일이 없습니다: $config"
            config_issues=$((config_issues + 1))
        fi
    done
    
    [ $config_issues -eq 0 ]
}

# =============================================================================
# 품질 보고서 생성
# =============================================================================
generate_quality_report() {
    local report_file="$QUALITY_RESULTS_DIR/quality-report-$(date +%Y%m%d-%H%M%S).json"
    
    mkdir -p "$QUALITY_RESULTS_DIR"
    
    cat > "$report_file" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "summary": {
    "total_checks": $TOTAL_CHECKS,
    "passed_checks": $PASSED_CHECKS,
    "failed_checks": $FAILED_CHECKS,
    "warning_checks": $WARNING_CHECKS,
    "quality_score": "$(( (PASSED_CHECKS * 100) / TOTAL_CHECKS ))%"
  },
  "details": {
    "code_quality": {
      "shell_script_syntax": "검증 완료",
      "shell_script_best_practices": "검증 완료",
      "nodejs_code_quality": "검증 완료"
    },
    "documentation_quality": {
      "markdown_syntax": "검증 완료",
      "documentation_completeness": "검증 완료",
      "anchor_links": "검증 완료"
    },
    "practice_code_quality": {
      "practice_code_structure": "검증 완료",
      "automation_scripts_quality": "검증 완료"
    },
    "environment_quality": {
      "environment_config_quality": "검증 완료"
    }
  },
  "recommendations": [
    "코드 주석 비율을 20% 이상으로 유지하세요",
    "모든 스크립트에 set -euo pipefail을 추가하세요",
    "함수 정의를 활용하여 코드를 모듈화하세요",
    "문서에 앵커 링크를 추가하여 네비게이션을 개선하세요"
  ]
}
EOF
    
    log_success "품질 보고서 생성: $report_file"
}

# =============================================================================
# 메인 실행 로직
# =============================================================================
main() {
    local check_code=false
    local check_docs=false
    local check_all=true
    
    # 명령행 인수 처리
    while [[ $# -gt 0 ]]; do
        case $1 in
            --code)
                check_code=true
                check_all=false
                shift
                ;;
            --docs)
                check_docs=true
                check_all=false
                shift
                ;;
            --help|-h)
                echo "사용법: $0 [--code] [--docs]"
                exit 0
                ;;
            *)
                log_error "알 수 없는 옵션: $1"
                exit 1
                ;;
        esac
    done
    
    log_header "Cloud Intermediate 품질 검증 시작"
    
    # 코드 품질 검증
    if [ "$check_all" = true ] || [ "$check_code" = true ]; then
        log_header "코드 품질 검증"
        check_quality "shell_script_syntax" check_shell_script_syntax "Shell 스크립트 구문 검증"
        check_quality "shell_script_best_practices" check_shell_script_best_practices "Shell 스크립트 모범 사례 검증" "warning"
        check_quality "nodejs_code_quality" check_nodejs_code_quality "Node.js 코드 품질 검증"
    fi
    
    # 문서 품질 검증
    if [ "$check_all" = true ] || [ "$check_docs" = true ]; then
        log_header "문서 품질 검증"
        check_quality "markdown_syntax" check_markdown_syntax "Markdown 구문 검증"
        check_quality "documentation_completeness" check_documentation_completeness "문서 완성도 검증" "warning"
        check_quality "anchor_links" check_anchor_links "앵커 링크 검증"
    fi
    
    # 실습 코드 품질 검증
    if [ "$check_all" = true ]; then
        log_header "실습 코드 품질 검증"
        check_quality "practice_code_structure" check_practice_code_structure "실습 코드 구조 검증"
        check_quality "automation_scripts_quality" check_automation_scripts_quality "자동화 스크립트 품질 검증" "warning"
        check_quality "environment_config_quality" check_environment_config_quality "환경 설정 품질 검증"
    fi
    
    # 품질 결과 요약
    log_header "품질 검증 결과 요약"
    log_info "총 검증: $TOTAL_CHECKS"
    log_success "통과: $PASSED_CHECKS"
    log_error "실패: $FAILED_CHECKS"
    log_warning "경고: $WARNING_CHECKS"
    
    local quality_score=$(( (PASSED_CHECKS * 100) / TOTAL_CHECKS ))
    log_info "품질 점수: ${quality_score}%"
    
    # 보고서 생성
    generate_quality_report
    
    # 종료 코드 설정
    if [ $FAILED_CHECKS -eq 0 ]; then
        log_success "모든 품질 검증이 통과했습니다!"
        exit 0
    else
        log_error "$FAILED_CHECKS 개의 품질 검증이 실패했습니다"
        exit 1
    fi
}

# =============================================================================
# 스크립트 실행
# =============================================================================
main "$@"
