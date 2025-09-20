# WSL 관리 도구 API 문서

## 📋 개요

WSL 관리 도구(`wsl-manager.sh`)의 내부 함수들과 API를 설명하는 기술 문서입니다.

## 🏗️ 스크립트 구조

### **전역 변수**
```bash
# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 설정
DISTRO_NAME="Ubuntu-22.04"
USER_NAME="clouduser"
WORKSPACE_DIR="$HOME/mcp-cloud-workspace"
PROJECT_DIR="$WORKSPACE_DIR/mcp_cloud"
```

### **로그 함수**
```bash
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}[HEADER]${NC} $1"; }
log_wsl() { echo -e "${CYAN}[WSL]${NC} $1"; }
```

## 🔧 핵심 함수들

### **1. WSL 배포판 관리 함수**

#### **`list_wsl_distros()`**
WSL 배포판 목록을 조회합니다.

**기능:**
- 설치된 모든 WSL 배포판 목록 출력
- 배포판 이름, 상태, 버전 정보 표시

**사용법:**
```bash
list_wsl_distros
```

**출력 예시:**
```
  NAME            STATE           VERSION
* Ubuntu-22.04    Running         2
  Ubuntu-20.04    Stopped         2
```

#### **`check_wsl_status(distro_name)`**
특정 WSL 배포판의 상태를 확인합니다.

**매개변수:**
- `distro_name`: 확인할 배포판 이름

**기능:**
- 배포판 존재 여부 확인
- 실행 상태 확인 및 표시

**사용법:**
```bash
check_wsl_status "Ubuntu-22.04"
```

**반환값:**
- `0`: 성공
- `1`: 실패 (배포판 없음)

#### **`stop_wsl_distro(distro_name)`**
WSL 배포판을 중지합니다.

**매개변수:**
- `distro_name`: 중지할 배포판 이름

**기능:**
- 사용자 확인 후 배포판 중지
- 안전한 중지 처리

**사용법:**
```bash
stop_wsl_distro "Ubuntu-22.04"
```

#### **`delete_wsl_distro(distro_name)`**
WSL 배포판을 삭제합니다.

**매개변수:**
- `distro_name`: 삭제할 배포판 이름

**기능:**
- 이중 확인 시스템
- 안전한 삭제 처리

**사용법:**
```bash
delete_wsl_distro "Ubuntu-22.04"
```

**주의사항:**
- 데이터 손실 위험
- 되돌릴 수 없음

#### **`create_wsl_distro(distro_name)`**
새로운 WSL 배포판을 생성합니다.

**매개변수:**
- `distro_name`: 생성할 배포판 이름

**기능:**
- Ubuntu 22.04 LTS 다운로드 및 설치
- 초기 사용자 설정
- sudo 권한 부여

**사용법:**
```bash
create_wsl_distro "Ubuntu-22.04"
```

#### **`restart_wsl_distro(distro_name)`**
WSL 배포판을 재시작합니다.

**매개변수:**
- `distro_name`: 재시작할 배포판 이름

**기능:**
- 배포판 중지 후 재시작
- 안전한 재시작 처리

**사용법:**
```bash
restart_wsl_distro "Ubuntu-22.04"
```

### **2. 백업 및 복원 함수**

#### **`backup_wsl_distro(distro_name, backup_path)`**
WSL 배포판을 백업합니다.

**매개변수:**
- `distro_name`: 백업할 배포판 이름
- `backup_path`: 백업 파일 경로

**기능:**
- tar 파일로 배포판 내보내기
- 백업 디렉토리 자동 생성

**사용법:**
```bash
backup_wsl_distro "Ubuntu-22.04" "~/backup-ubuntu.tar"
```

#### **`restore_wsl_distro(distro_name, backup_path)`**
백업 파일에서 WSL 배포판을 복원합니다.

**매개변수:**
- `distro_name`: 복원할 배포판 이름
- `backup_path`: 백업 파일 경로

**기능:**
- 기존 배포판 삭제 (있는 경우)
- 백업 파일에서 복원

**사용법:**
```bash
restore_wsl_distro "Ubuntu-22.04" "~/backup-ubuntu.tar"
```

### **3. 사용자 설정 함수**

#### **`setup_wsl_user(distro_name)`**
WSL 배포판의 사용자를 설정합니다.

**매개변수:**
- `distro_name`: 설정할 배포판 이름

**기능:**
- 사용자 생성
- sudo 권한 부여
- 비밀번호 설정
- 홈 디렉토리 권한 설정

**사용법:**
```bash
setup_wsl_user "Ubuntu-22.04"
```

### **4. 전체 관리 함수**

#### **`cleanup_all_wsl()`**
모든 WSL 배포판을 정리합니다.

**기능:**
- 이중 확인 시스템
- 모든 배포판 삭제
- 안전한 정리 처리

**사용법:**
```bash
cleanup_all_wsl
```

**주의사항:**
- 모든 데이터 손실
- 되돌릴 수 없음

### **5. 메인 메뉴 함수**

#### **`main_menu()`**
사용자 인터페이스 메뉴를 제공합니다.

**기능:**
- 대화형 메뉴 표시
- 사용자 입력 처리
- 함수 호출 관리

**사용법:**
```bash
main_menu
```

## 🔄 함수 호출 흐름

### **메인 실행 흐름**
```
main()
├── WSL 설치 확인
└── main_menu()
    ├── 1. list_wsl_distros()
    ├── 2. check_wsl_status()
    ├── 3. stop_wsl_distro()
    ├── 4. delete_wsl_distro()
    ├── 5. create_wsl_distro()
    │   └── setup_wsl_user()
    ├── 6. restart_wsl_distro()
    ├── 7. backup_wsl_distro()
    ├── 8. restore_wsl_distro()
    ├── 9. cleanup_all_wsl()
    ├── 10. wsl-auto-setup.sh 실행
    └── 11. 종료
```

### **배포판 생성 흐름**
```
create_wsl_distro()
├── Ubuntu 22.04 LTS 다운로드
├── WSL 배포판 설치
├── 초기 설정 대기
└── setup_wsl_user()
    ├── 사용자 생성
    ├── sudo 권한 부여
    ├── 비밀번호 설정
    └── 홈 디렉토리 권한 설정
```

### **배포판 삭제 흐름**
```
delete_wsl_distro()
├── 첫 번째 확인
├── 두 번째 확인 (DELETE 입력)
└── wsl --unregister 실행
```

## 🛡️ 오류 처리

### **입력 오류 처리**
```bash
read -r response || {
    log_error "입력 읽기 실패"
    return 1
}
```

### **명령어 실행 오류 처리**
```bash
if wsl --terminate "$distro_name"; then
    log_success "성공 메시지"
else
    log_error "실패 메시지"
    return 1
fi
```

### **WSL 설치 확인**
```bash
if ! command -v wsl &> /dev/null; then
    log_error "WSL이 설치되지 않았습니다."
    exit 1
fi
```

## 📊 로그 레벨

### **로그 레벨별 사용**
- **INFO**: 일반적인 정보 메시지
- **SUCCESS**: 성공적인 작업 완료
- **WARNING**: 주의가 필요한 상황
- **ERROR**: 오류 발생
- **HEADER**: 섹션 제목
- **WSL**: WSL 관련 특별 메시지

### **로그 출력 예시**
```bash
[INFO] WSL 배포판 목록 조회 중...
[SUCCESS] ✅ Ubuntu-22.04: 실행 중
[WARNING] ⚠️ WARNING: WSL 배포판 삭제
[ERROR] ❌ WSL이 설치되지 않았습니다.
[HEADER] === WSL 관리 도구 ===
[WSL] WSL 배포판 생성 중...
```

## 🔧 확장 가능성

### **새로운 함수 추가**
```bash
# 새로운 함수 템플릿
new_function() {
    local param1="$1"
    local param2="$2"
    
    log_info "새로운 함수 실행: $param1"
    
    if command_success; then
        log_success "성공 메시지"
        return 0
    else
        log_error "실패 메시지"
        return 1
    fi
}
```

### **메뉴에 새 옵션 추가**
```bash
case $choice in
    # 기존 옵션들...
    12)
        new_function "$param1" "$param2"
        ;;
esac
```

## 🧪 테스트

### **단위 테스트 예시**
```bash
# 함수 테스트
test_list_wsl_distros() {
    echo "Testing list_wsl_distros..."
    list_wsl_distros
    echo "Test completed."
}

# 전체 테스트 실행
test_all() {
    test_list_wsl_distros
    # 다른 테스트 함수들...
}
```

### **통합 테스트**
```bash
# 전체 시나리오 테스트
test_full_scenario() {
    # 1. 배포판 생성
    create_wsl_distro "Test-Ubuntu"
    
    # 2. 상태 확인
    check_wsl_status "Test-Ubuntu"
    
    # 3. 백업
    backup_wsl_distro "Test-Ubuntu" "~/test-backup.tar"
    
    # 4. 삭제
    delete_wsl_distro "Test-Ubuntu"
    
    # 5. 복원
    restore_wsl_distro "Test-Ubuntu" "~/test-backup.tar"
}
```

## 📚 참고 자료

### **WSL 명령어 참조**
- `wsl --list --verbose`: 배포판 목록
- `wsl --terminate <distro>`: 배포판 중지
- `wsl --unregister <distro>`: 배포판 삭제
- `wsl --install -d <distro>`: 배포판 설치
- `wsl --export <distro> <file>`: 배포판 내보내기
- `wsl --import <distro> <path> <file>`: 배포판 가져오기

### **Bash 스크립팅 참조**
- 함수 정의 및 호출
- 매개변수 처리
- 오류 처리
- 사용자 입력 처리

---

**이 API 문서를 참고하여 WSL 관리 도구를 확장하고 개선하세요!** 🚀
