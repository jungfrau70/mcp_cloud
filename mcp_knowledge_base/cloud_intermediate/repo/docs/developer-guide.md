# 자동화 시스템 개발자 가이드

## 🚀 빠른 시작

### **개발 환경 설정**
```bash
# 프로젝트 디렉토리로 이동
cd cloud_intermediate/repo

# 실행 권한 부여
chmod +x automation/day1/day1-practice.sh
chmod +x tools/cloud/*.sh

# 기본 테스트
./automation/day1/day1-practice.sh --help
```

### **메뉴 시스템 실행**
```bash
# 대화형 모드
./automation/day1/day1-practice.sh

# 특정 액션 실행
./automation/day1/day1-practice.sh --action status
./automation/day1/day1-practice.sh --action cleanup
```

## 🏗️ 아키텍처 이해

### **시스템 구조**
```
메뉴 시스템 (day1-practice.sh)
    ↓ 호출
서브 모듈들 (tools/cloud/*.sh)
    ↓ 실행
실제 작업 (AWS/GCP CLI, kubectl 등)
```

### **데이터 흐름**
1. **사용자 입력** → 메뉴 시스템
2. **메뉴 선택** → 서브 모듈 호출
3. **서브 모듈** → 실제 작업 수행
4. **결과 반환** → 메뉴 시스템
5. **사용자에게 표시** → 다음 선택 대기

## 🔧 개발 가이드라인

### **1. 새 서브 모듈 개발**

#### **단계 1: 기본 구조 생성**
```bash
#!/bin/bash
# 새 서브 모듈: tools/cloud/new-module.sh

# 표준 헤더
# 역할: [모듈 역할 설명]
# 인터페이스: --action <액션> [옵션]

# 표준 로깅 함수
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 메인 로직
main() {
    # 모듈별 비즈니스 로직
}

# 스크립트 실행
main "$@"
```

#### **단계 2: 인터페이스 구현**
```bash
# 액션 처리
case "$1" in
    --action)
        case "$2" in
            create)
                create_resource
                ;;
            delete)
                delete_resource
                ;;
            status)
                check_status
                ;;
            *)
                log_error "알 수 없는 액션: $2"
                show_help
                exit 1
                ;;
        esac
        ;;
    --interactive)
        interactive_mode
        ;;
    --help|-h)
        show_help
        ;;
    *)
        log_error "알 수 없는 옵션: $1"
        show_help
        exit 1
        ;;
esac
```

#### **단계 3: 에러 처리**
```bash
# 필수 도구 검증
check_prerequisites() {
    local missing_tools=()
    
    if ! command -v aws &> /dev/null; then
        missing_tools+=("aws")
    fi
    
    if ! command -v kubectl &> /dev/null; then
        missing_tools+=("kubectl")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "필수 도구가 설치되지 않았습니다: ${missing_tools[*]}"
        exit 1
    fi
}
```

### **2. 메뉴 시스템에 새 모듈 추가**

#### **단계 1: 메뉴 항목 추가**
```bash
# show_cluster_menu() 함수에 새 항목 추가
echo "8. 새 모듈 기능"  # 새 메뉴 항목
```

#### **단계 2: 케이스 추가**
```bash
case $choice in
    8)
        log_info "새 모듈 기능"
        new_module_function
        ;;
esac
```

#### **단계 3: 함수 구현**
```bash
new_module_function() {
    log_header "새 모듈 기능"
    
    local new_module="../../tools/cloud/new-module.sh"
    if [ -f "$new_module" ]; then
        chmod +x "$new_module"
        "$new_module" --interactive
    else
        log_warning "새 모듈을 찾을 수 없습니다: $new_module"
    fi
}
```

## 🧪 테스트 가이드

### **1. 단위 테스트**
```bash
# 개별 서브 모듈 테스트
./tools/cloud/aws-eks-helper.sh --action status
./tools/cloud/gcp-gke-helper.sh --action status
./tools/cloud/improved-eks-cleanup.sh
```

### **2. 통합 테스트**
```bash
# 메뉴 시스템 전체 테스트
./automation/day1/day1-practice.sh --action all

# 특정 기능 테스트
./automation/day1/day1-practice.sh --action cleanup
./automation/day1/day1-practice.sh --action status
```

### **3. 에러 상황 테스트**
```bash
# 필수 도구 제거 후 테스트
# AWS CLI 제거 후 EKS 관련 메뉴 테스트
# 권한 부족 상황에서 테스트
```

## 📊 디버깅 가이드

### **1. 로그 레벨 설정**
```bash
# 디버그 모드 활성화
export DEBUG=true

# 상세 로그 출력
set -x  # 명령어 실행 전 출력
set +x  # 상세 로그 비활성화
```

### **2. 일반적인 문제 해결**

#### **문제: 서브 모듈을 찾을 수 없음**
```bash
# 해결책: 경로 확인
ls -la ../../tools/cloud/
# 상대 경로가 올바른지 확인
```

#### **문제: 실행 권한 없음**
```bash
# 해결책: 권한 부여
chmod +x ../../tools/cloud/*.sh
```

#### **문제: 필수 도구 없음**
```bash
# 해결책: 도구 설치 확인
which aws
which kubectl
which gcloud
```

## 🔄 CI/CD 통합

### **자동화 스크립트 테스트**
```yaml
# .github/workflows/automation-test.yml
name: Automation Test
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup tools
        run: |
          # AWS CLI, kubectl, gcloud 설치
      - name: Test menu system
        run: ./automation/day1/day1-practice.sh --help
      - name: Test sub-modules
        run: |
          ./tools/cloud/aws-eks-helper.sh --action status
          ./tools/cloud/gcp-gke-helper.sh --action status
```

## 📚 참고 자료

### **관련 문서**
- [자동화 아키텍처 문서](./automation-architecture.md)
- [커서룰](./.cursor/rules/automation-architecture.mdc)

### **외부 자료**
- [Bash 스크립팅 가이드](https://www.gnu.org/software/bash/manual/)
- [AWS CLI 문서](https://docs.aws.amazon.com/cli/)
- [kubectl 문서](https://kubernetes.io/docs/reference/kubectl/)

## 🎯 모범 사례

### **1. 코드 품질**
- **명확한 변수명**: `cluster_name` vs `cn`
- **함수 분리**: 하나의 함수는 하나의 책임
- **에러 처리**: 모든 가능한 에러 상황 처리

### **2. 사용자 경험**
- **직관적 메뉴**: 사용자가 쉽게 이해할 수 있는 메뉴
- **명확한 피드백**: 작업 진행 상황과 결과 명확히 표시
- **에러 복구**: 에러 발생 시 복구 방법 제시

### **3. 유지보수성**
- **문서화**: 모든 함수와 주요 로직에 주석
- **모듈화**: 독립적으로 테스트 가능한 모듈
- **확장성**: 새로운 기능 추가 시 기존 코드 영향 최소화

이 가이드를 따라 개발하면 일관되고 유지보수 가능한 자동화 시스템을 구축할 수 있습니다.
