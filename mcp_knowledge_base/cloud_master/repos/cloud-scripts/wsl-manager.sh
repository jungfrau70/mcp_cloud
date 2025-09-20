#!/bin/bash

# =============================================================================
# WSL 관리 도구
# Cloud Master 과정용 WSL 환경 관리 스크립트
# =============================================================================

set -e

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
log_wsl() { echo -e "${CYAN}[WSL]${NC} $1"; }

# 설정
DISTRO_NAME="Ubuntu-22.04"
USER_NAME="clouduser"
WORKSPACE_DIR="$HOME/mcp-cloud-workspace"
PROJECT_DIR="$WORKSPACE_DIR/mcp_cloud"

# =============================================================================
# WSL 관리 함수
# =============================================================================

# WSL 명령어 실행 헬퍼 함수
run_wsl_command() {
    if command -v wsl &> /dev/null; then
        wsl "$@"
    elif command -v wsl.exe &> /dev/null; then
        wsl.exe "$@"
    else
        log_error "WSL이 설치되지 않았습니다."
        return 1
    fi
}

# WSL 배포판 목록 조회
list_wsl_distros() {
    log_info "WSL 배포판 목록 조회 중..."
    echo ""
    
    run_wsl_command --list --verbose
}

# WSL 배포판 목록을 배열로 가져오기
get_wsl_distros() {
    local distros=()
    
    # WSL 명령어 실행 및 awk로 파싱
    while IFS= read -r name state version; do
        if [[ "$name" != "NAME" && "$name" != "Windows" && -n "$name" ]]; then
            distros+=("$name")
        fi
    done < <(run_wsl_command --list --verbose 2>/dev/null | awk 'NR>1 {print $1, $2, $3}')
    
    echo "${distros[@]}"
}

# WSL 배포판 선택 메뉴
select_wsl_distro() {
    local action="$1"
    
    echo ""
    log_info "$action할 WSL 배포판을 선택하세요:"
    echo ""
    
    # 간단한 방법: Ubuntu만 하드코딩 (현재 설치된 것만)
    echo "  1. Ubuntu (Running)"
    echo ""
    echo -n "선택 (1): "
    read -r choice || {
        log_error "입력 읽기 실패"
        return 1
    }
    
    if [[ "$choice" == "1" ]]; then
        echo "Ubuntu"
        return 0
    else
        log_error "잘못된 선택입니다. Ubuntu만 사용 가능합니다."
        return 1
    fi
}

# WSL 배포판 상태 확인
check_wsl_status() {
    local distro_name="$1"
    
    log_info "WSL 배포판 상태 확인: $distro_name"
    
    if run_wsl_command --list --quiet | grep -q "$distro_name"; then
        local status=$(run_wsl_command --list --verbose | grep "$distro_name" | awk '{print $2}')
        case "$status" in
            "Running")
                log_success "✅ $distro_name: 실행 중"
                ;;
            "Stopped")
                log_warning "⚠️ $distro_name: 중지됨"
                ;;
            *)
                log_warning "⚠️ $distro_name: 상태 불명 ($status)"
                ;;
        esac
    else
        log_error "❌ $distro_name: 설치되지 않음"
        return 1
    fi
}

# WSL 배포판 중지
stop_wsl_distro() {
    local distro_name="$1"
    
    log_warning "WSL 배포판 중지: $distro_name"
    echo -n "정말로 중지하시겠습니까? (y/N): "
    read -r response || {
        log_error "입력 읽기 실패"
        return 1
    }
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log_info "중지가 취소되었습니다."
        return 0
    fi
    
    log_info "WSL 배포판 중지 중: $distro_name"
    
    if run_wsl_command --terminate "$distro_name"; then
        log_success "WSL 배포판 중지 완료: $distro_name"
        echo ""
        log_info "Enter를 눌러 메뉴로 돌아가세요..."
        read -r
    else
        log_error "WSL 배포판 중지 실패: $distro_name"
        echo ""
        log_info "Enter를 눌러 메뉴로 돌아가세요..."
        read -r
        return 1
    fi
}

# WSL 배포판 삭제
delete_wsl_distro() {
    local distro_name="$1"
    
    log_error "⚠️ WARNING: WSL 배포판 삭제: $distro_name"
    log_warning "이 작업은 되돌릴 수 없습니다!"
    echo -n "정말로 삭제하시겠습니까? (y/N): "
    read -r response || {
        log_error "입력 읽기 실패"
        return 1
    }
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log_info "삭제가 취소되었습니다."
        return 0
    fi
    
    # 한 번 더 확인
    echo -n "정말로 삭제하시겠습니까? 모든 데이터가 손실됩니다! (DELETE): "
    read -r confirm || {
        log_error "입력 읽기 실패"
        return 1
    }
    
    if [[ "$confirm" != "DELETE" ]]; then
        log_info "삭제가 취소되었습니다."
        return 0
    fi
    
    log_info "WSL 배포판 삭제 중: $distro_name"
    
    if run_wsl_command --unregister "$distro_name"; then
        log_success "WSL 배포판 삭제 완료: $distro_name"
        echo ""
        log_info "Enter를 눌러 메뉴로 돌아가세요..."
        read -r
    else
        log_error "WSL 배포판 삭제 실패: $distro_name"
        echo ""
        log_info "Enter를 눌러 메뉴로 돌아가세요..."
        read -r
        return 1
    fi
}

# WSL 배포판 생성
create_wsl_distro() {
    local distro_name="$1"
    
    log_info "WSL 배포판 생성: $distro_name"
    
    # Ubuntu 22.04 LTS 다운로드 및 설치
    log_info "Ubuntu 22.04 LTS 다운로드 중..."
    
    if run_wsl_command --install -d "$distro_name"; then
        log_success "WSL 배포판 생성 완료: $distro_name"
        
        # 초기 설정 대기
        log_info "초기 설정을 완료한 후 Enter를 눌러주세요..."
        read -r
        
        # 사용자 설정
        setup_wsl_user "$distro_name"
        
        echo ""
        log_info "Enter를 눌러 메뉴로 돌아가세요..."
        read -r
        
    else
        log_error "WSL 배포판 생성 실패: $distro_name"
        echo ""
        log_info "Enter를 눌러 메뉴로 돌아가세요..."
        read -r
        return 1
    fi
}

# WSL 사용자 설정
setup_wsl_user() {
    local distro_name="$1"
    
    log_info "WSL 사용자 설정: $distro_name"
    
    # 사용자 생성 및 sudo 권한 부여
    run_wsl_command -d "$distro_name" -u root -- bash -c "
        # 사용자 생성
        useradd -m -s /bin/bash $USER_NAME
        
        # sudo 그룹에 추가
        usermod -aG sudo $USER_NAME
        
        # 비밀번호 설정
        echo '$USER_NAME:cloud123!' | chpasswd
        
        # 홈 디렉토리 권한 설정
        chown -R $USER_NAME:$USER_NAME /home/$USER_NAME
    "
    
    log_success "WSL 사용자 설정 완료: $USER_NAME"
}

# WSL 배포판 재시작
restart_wsl_distro() {
    local distro_name="$1"
    
    log_info "WSL 배포판 재시작: $distro_name"
    
    # 중지
    run_wsl_command --terminate "$distro_name" 2>/dev/null || true
    
    # 잠시 대기
    sleep 2
    
    # 시작
    run_wsl_command -d "$distro_name" -- echo "WSL 배포판이 시작되었습니다."
    
    log_success "WSL 배포판 재시작 완료: $distro_name"
    echo ""
    log_info "Enter를 눌러 메뉴로 돌아가세요..."
    read -r
}

# WSL 배포판 백업
backup_wsl_distro() {
    local distro_name="$1"
    local backup_path="$2"
    
    log_info "WSL 배포판 백업: $distro_name → $backup_path"
    
    # 백업 디렉토리 생성
    mkdir -p "$(dirname "$backup_path")"
    
    # WSL 배포판 내보내기
    if run_wsl_command --export "$distro_name" "$backup_path"; then
        log_success "WSL 배포판 백업 완료: $backup_path"
        echo ""
        log_info "Enter를 눌러 메뉴로 돌아가세요..."
        read -r
    else
        log_error "WSL 배포판 백업 실패: $distro_name"
        echo ""
        log_info "Enter를 눌러 메뉴로 돌아가세요..."
        read -r
        return 1
    fi
}

# WSL 배포판 복원
restore_wsl_distro() {
    local distro_name="$1"
    local backup_path="$2"
    
    log_info "WSL 배포판 복원: $backup_path → $distro_name"
    
    if [[ ! -f "$backup_path" ]]; then
        log_error "백업 파일을 찾을 수 없습니다: $backup_path"
        return 1
    fi
    
    # 기존 배포판이 있으면 삭제
    if run_wsl_command --list --quiet | grep -q "$distro_name"; then
        log_warning "기존 배포판 삭제 중: $distro_name"
        run_wsl_command --unregister "$distro_name"
    fi
    
    # 백업에서 복원
    if run_wsl_command --import "$distro_name" "$HOME/.wsl/$distro_name" "$backup_path"; then
        log_success "WSL 배포판 복원 완료: $distro_name"
        echo ""
        log_info "Enter를 눌러 메뉴로 돌아가세요..."
        read -r
    else
        log_error "WSL 배포판 복원 실패: $distro_name"
        echo ""
        log_info "Enter를 눌러 메뉴로 돌아가세요..."
        read -r
        return 1
    fi
}

# WSL 전체 정리
cleanup_all_wsl() {
    log_error "⚠️ WARNING: 모든 WSL 배포판 정리"
    log_warning "이 작업은 되돌릴 수 없습니다!"
    echo -n "정말로 모든 WSL 배포판을 삭제하시겠습니까? (y/N): "
    read -r response || {
        log_error "입력 읽기 실패"
        return 1
    }
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log_info "정리가 취소되었습니다."
        return 0
    fi
    
    # 한 번 더 확인
    echo -n "정말로 모든 WSL 배포판을 삭제하시겠습니까? (DELETE ALL): "
    read -r confirm || {
        log_error "입력 읽기 실패"
        return 1
    }
    
    if [[ "$confirm" != "DELETE ALL" ]]; then
        log_info "정리가 취소되었습니다."
        return 0
    fi
    
    log_info "모든 WSL 배포판 정리 중..."
    
    # 모든 배포판 목록 가져오기
    local distros=$(run_wsl_command --list --quiet)
    
    for distro in $distros; do
        if [[ "$distro" != "Windows" ]]; then
            log_info "WSL 배포판 삭제 중: $distro"
            run_wsl_command --unregister "$distro" 2>/dev/null || true
        fi
    done
    
    log_success "모든 WSL 배포판 정리 완료"
    echo ""
    log_info "Enter를 눌러 메뉴로 돌아가세요..."
    read -r
}

# =============================================================================
# 메인 메뉴
# =============================================================================

main_menu() {
    while true; do
        echo ""
        log_header "=== WSL 관리 도구 ==="
        echo "1. WSL 배포판 목록 보기"
        echo "2. WSL 배포판 상태 확인"
        echo "3. WSL 배포판 중지"
        echo "4. WSL 배포판 삭제"
        echo "5. WSL 배포판 생성"
        echo "6. WSL 배포판 재시작"
        echo "7. WSL 배포판 백업"
        echo "8. WSL 배포판 복원"
        echo "9. WSL 전체 정리"
        echo "10. WSL 자동 설정 실행"
        echo "11. 종료"
        echo ""
        echo -n "선택 (1-11): "
        read -r choice || {
            log_error "입력 읽기 실패"
            continue
        }
        
        case $choice in
            1)
                list_wsl_distros
                ;;
            2)
                distro_name=$(select_wsl_distro "상태 확인")
                if [[ $? -eq 0 && -n "$distro_name" ]]; then
                    check_wsl_status "$distro_name"
                fi
                ;;
            3)
                distro_name=$(select_wsl_distro "중지")
                if [[ $? -eq 0 && -n "$distro_name" ]]; then
                    stop_wsl_distro "$distro_name"
                fi
                ;;
            4)
                distro_name=$(select_wsl_distro "삭제")
                if [[ $? -eq 0 && -n "$distro_name" ]]; then
                    delete_wsl_distro "$distro_name"
                fi
                ;;
            5)
                echo -n "생성할 배포판 이름을 입력하세요 (기본값: $DISTRO_NAME): "
                read -r distro_name || {
                    log_error "입력 읽기 실패"
                    continue
                }
                distro_name=${distro_name:-$DISTRO_NAME}
                create_wsl_distro "$distro_name"
                ;;
            6)
                distro_name=$(select_wsl_distro "재시작")
                if [[ $? -eq 0 && -n "$distro_name" ]]; then
                    restart_wsl_distro "$distro_name"
                fi
                ;;
            7)
                distro_name=$(select_wsl_distro "백업")
                if [[ $? -eq 0 && -n "$distro_name" ]]; then
                    echo -n "백업 파일 경로를 입력하세요 (기본값: ~/wsl-backup-$distro_name.tar): "
                    read -r backup_path || {
                        log_error "입력 읽기 실패"
                        continue
                    }
                    backup_path=${backup_path:-"$HOME/wsl-backup-$distro_name.tar"}
                    backup_wsl_distro "$distro_name" "$backup_path"
                fi
                ;;
            8)
                echo -n "복원할 배포판 이름을 입력하세요: "
                read -r distro_name || {
                    log_error "입력 읽기 실패"
                    continue
                }
                echo -n "백업 파일 경로를 입력하세요: "
                read -r backup_path || {
                    log_error "입력 읽기 실패"
                    continue
                }
                restore_wsl_distro "$distro_name" "$backup_path"
                ;;
            9)
                cleanup_all_wsl
                ;;
            10)
                log_info "WSL 자동 설정 스크립트를 실행합니다."
                if [[ -f "./wsl-auto-setup.sh" ]]; then
                    ./wsl-auto-setup.sh
                else
                    log_error "wsl-auto-setup.sh 파일을 찾을 수 없습니다."
                fi
                ;;
            11)
                log_info "WSL 관리 도구를 종료합니다."
                break
                ;;
            *)
                log_error "잘못된 선택입니다. 1-11 중에서 선택하세요."
                ;;
        esac
    done
}

# =============================================================================
# 메인 실행
# =============================================================================

main() {
    log_header "=== WSL 관리 도구 시작 ==="
    
    # WSL 설치 확인
    if ! command -v wsl &> /dev/null && ! command -v wsl.exe &> /dev/null; then
        log_error "WSL이 설치되지 않았습니다."
        log_info "Windows에서 WSL을 설치한 후 다시 실행하세요."
        log_info "설치 방법: https://docs.microsoft.com/ko-kr/windows/wsl/install"
        exit 1
    fi
    
    # 메인 메뉴 실행
    main_menu
}

# 스크립트 실행
main "$@"
