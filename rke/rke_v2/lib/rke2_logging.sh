#!/bin/bash

# RKE2 로깅 라이브러리
# Version: 1.0.0
# Description: RKE2 모니터링 스크립트 로깅 함수들

# 로그 파일 초기화
init_log_files() {
    local script_name="$1"
    local timestamp=$(get_timestamp)
    local log_file="${LOG_DIR}/${script_name}_${timestamp}.log"
    local html_log_file="${LOG_DIR}/${script_name}_${timestamp}.html"
    
    # 로그 파일 초기화
    cat > "${log_file}" << EOF
============================================
     RKE2 ${script_name} 점검 보고서
     실행 시각: $(get_current_time)
============================================

EOF

    # HTML 로그 파일 초기화
    cat > "${html_log_file}" << EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f8f9fa; padding: 20px; border-radius: 5px; }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #dee2e6; border-radius: 5px; }
        .success { color: #28a745; }
        .warning { color: #ffc107; }
        .error { color: #dc3545; }
        .info { color: #17a2b8; }
        .timestamp { color: #6c757d; }
        .summary { background-color: #e9ecef; padding: 15px; margin-top: 20px; border-radius: 5px; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { padding: 8px; text-align: left; border: 1px solid #dee2e6; }
        th { background-color: #f8f9fa; }
        .status-ok { color: #28a745; }
        .status-warning { color: #ffc107; }
        .status-error { color: #dc3545; }
        .details { margin-left: 20px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>RKE2 ${script_name} 점검 보고서</h1>
        <p class="timestamp">점검 시각: $(get_current_time)</p>
    </div>
EOF

    # 전역 변수로 설정
    export LOG_FILE="${log_file}"
    export HTML_LOG_FILE="${html_log_file}"
    
    echo "로그 파일: ${log_file}"
    echo "HTML 파일: ${html_log_file}"
}

# 로그 메시지 출력 함수
log_message() {
    local message="$1"
    local level="${2:-INFO}"
    message=$(echo -e "$message")
    local masked_message=$(mask_sensitive_info "$message")
    local timestamp=$(get_current_time)
    local html_message=$(echo "$masked_message" | sed ':a;N;$!ba;s/\n/<br>/g')

    case $level in
        "ERROR")
            printf "${RED}[오류]${NC} %b\n" "$masked_message" >&2
            printf "[%s] [오류] %b\n" "$timestamp" "$masked_message" >> "${LOG_FILE}"
            echo "<div class='section error'><strong>오류:</strong> $html_message</div>" >> "${HTML_LOG_FILE}"
            ;; 
        "WARNING")
            printf "${YELLOW}[경고]${NC} %b\n" "$masked_message"
            printf "[%s] [경고] %b\n" "$timestamp" "$masked_message" >> "${LOG_FILE}"
            echo "<div class='section warning'><strong>경고:</strong> $html_message</div>" >> "${HTML_LOG_FILE}"
            ;; 
        "SUCCESS")
            printf "${GREEN}[성공]${NC} %b\n" "$masked_message"
            printf "[%s] [성공] %b\n" "$timestamp" "$masked_message" >> "${LOG_FILE}"
            echo "<div class='section success'><strong>성공:</strong> $html_message</div>" >> "${HTML_LOG_FILE}"
            ;; 
        "SECTION")
            printf "\n${BLUE}${BOLD}=== %b ===${NC}\n" "$masked_message"
            printf "\n===========================================\n" >> "${LOG_FILE}"
            printf "[%s] === %b ===\n" "$timestamp" "$masked_message" >> "${LOG_FILE}"
            printf "===========================================\n" >> "${LOG_FILE}"
            echo "<div class='section'><h2>$html_message</h2>" >> "${HTML_LOG_FILE}"
            ;; 
        "SECTION_END")
            echo "</div>" >> "${HTML_LOG_FILE}"
            ;; 
        *)
            printf "%b\n" "$masked_message"
            printf "[%s] %b\n" "$timestamp" "$masked_message" >> "${LOG_FILE}"
            echo "<div class='details'>$html_message</div>" >> "${HTML_LOG_FILE}"
            ;; 
    esac
}

# HTML 테이블 함수들
start_table() {
    local headers=($@)
    echo "<table><tr>" >> "${HTML_LOG_FILE}"
    for header in "${headers[@]}"; do
        echo "<th>$header</th>" >> "${HTML_LOG_FILE}"
    done
    echo "</tr>" >> "${HTML_LOG_FILE}"
}

add_table_row() {
    echo "<tr>" >> "${HTML_LOG_FILE}"
    for cell in "$@"; do
        echo "<td>$cell</td>" >> "${HTML_LOG_FILE}"
    done
    echo "</tr>" >> "${HTML_LOG_FILE}"
}

end_table() {
    echo "</table>" >> "${HTML_LOG_FILE}"
}

# 요약 정보 추가
add_summary() {
    local total_pods="$1"
    local running_pods="$2"
    local problem_pods="$3"
    local namespaces="$4"
    
    echo "<div class='summary'>" >> "${HTML_LOG_FILE}"
    echo "<h2>점검 요약</h2>" >> "${HTML_LOG_FILE}"
    echo "<ul>" >> "${HTML_LOG_FILE}"
    echo "<li>검사한 네임스페이스: $namespaces</li>" >> "${HTML_LOG_FILE}"
    echo "<li>전체 파드 수: $total_pods</li>" >> "${HTML_LOG_FILE}"
    echo "<li>정상 실행 중인 파드: $running_pods</li>" >> "${HTML_LOG_FILE}"
    echo "<li>문제가 있는 파드: $problem_pods</li>" >> "${HTML_LOG_FILE}"
    echo "</ul>" >> "${HTML_LOG_FILE}"
}

# HTML 파일 완성
finish_html() {
    echo "</body></html>" >> "${HTML_LOG_FILE}"
    log_message "HTML 형식의 보고서가 생성되었습니다: ${HTML_LOG_FILE}" "SUCCESS"
}

# 로그 레벨 설정
set_log_level() {
    local level="$1"
    case $level in
        "DEBUG"|"INFO"|"WARNING"|"ERROR")
            export LOG_LEVEL="$level"
            log_message "로그 레벨이 $level로 설정되었습니다." "INFO"
            ;; 
        *)
            log_message "잘못된 로그 레벨입니다: $level" "WARNING"
            ;; 
    esac
}

# 로그 파일 정리
cleanup_old_logs() {
    local retention_days="${1:-30}"
    local current_time=$(date +%s)
    local cutoff_time=$((current_time - retention_days * 24 * 60 * 60))
    
    find "${LOG_DIR}" -name "*.log" -type f -mtime +${retention_days} -delete 2>/dev/null
    find "${LOG_DIR}" -name "*.html" -type f -mtime +${retention_days} -delete 2>/dev/null
    
    log_message "오래된 로그 파일이 정리되었습니다 (보존 기간: ${retention_days}일)" "INFO"
}
