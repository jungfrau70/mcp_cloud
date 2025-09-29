# 자동화 코드 아키텍처 문서

## 🎯 개요

이 문서는 Cloud Intermediate Day 1 실습 자동화 시스템의 메뉴 시스템과 서브 모듈 구조를 설명합니다.

## 🏗️ 아키텍처 원칙

### **1. 관심사 분리 (Separation of Concerns)**
- **메뉴 시스템**: 사용자 인터페이스와 네비게이션만 담당
- **서브 모듈**: 실제 비즈니스 로직과 작업 수행
- **명확한 경계**: 각 컴포넌트의 역할과 책임이 명확히 구분됨

### **2. 모듈화 (Modularity)**
- **독립적 모듈**: 각 서브 모듈은 독립적으로 실행 가능
- **재사용성**: 서브 모듈들은 다른 메뉴에서도 재사용 가능
- **확장성**: 새로운 기능 추가 시 기존 구조에 영향 없음

### **3. 일관성 (Consistency)**
- **표준화된 인터페이스**: 모든 서브 모듈은 동일한 인터페이스 패턴 사용
- **에러 처리**: 일관된 에러 처리 및 대안 제공
- **로깅**: 표준화된 로깅 시스템 사용

## 📁 디렉토리 구조

```
cloud_intermediate/repo/
├── automation/day1/                    # 메뉴 시스템
│   └── day1-practice.sh               # 메인 메뉴 시스템
├── tools/cloud/                       # 서브 모듈들
│   ├── aws-eks-helper.sh             # EKS 클러스터 관리
│   ├── gcp-gke-helper.sh             # GKE 클러스터 관리
│   ├── cloud-cluster-helper.sh       # 통합 클러스터 관리
│   ├── improved-eks-cleanup.sh       # 개선된 EKS 정리
│   └── stack-deletion-demo.sh        # 스택 삭제 데모
├── samples/day1/                     # 실습 샘플 코드
└── docs/                             # 문서
    └── automation-architecture.md   # 이 문서
```

## 🎮 메뉴 시스템 (`day1-practice.sh`)

### **역할과 책임**
- **사용자 인터페이스**: 메뉴 표시 및 사용자 입력 처리
- **네비게이션**: 메뉴 간 이동 및 상태 관리
- **서브 모듈 호출**: 적절한 서브 모듈로 작업 위임
- **에러 처리**: 서브 모듈 실행 실패 시 대안 제공

### **메뉴 구조**
```bash
=== Cloud Intermediate Day 1 실습 메뉴 ===
1. Docker 고급 실습
2. 클라우드 컨테이너 서비스 기초 실습 (EKS/GKE)
3. 통합 모니터링 실습
4. 전체 Day 1 실습 실행
5. K8s 클러스터 관리
6. 실습 환경 정리
7. 종료
```

### **서브 메뉴 구조**
```bash
=== K8s 클러스터 관리 메뉴 ===
1. 클러스터 현황 확인
2. EKS 클러스터 관리          # → aws-eks-helper.sh
3. GKE 클러스터 관리          # → gcp-gke-helper.sh
4. 통합 클러스터 관리         # → cloud-cluster-helper.sh
5. 클러스터 상태
6. EKS 클러스터 정리 (개선된 로직)  # → improved-eks-cleanup.sh
7. 뒤로 가기
```

## 🔧 서브 모듈들 (`../../tools/cloud/`)

### **1. AWS EKS Helper (`aws-eks-helper.sh`)**
- **역할**: AWS EKS 클러스터 생성, 삭제, 관리
- **주요 기능**:
  - 클러스터 생성/삭제
  - 노드 그룹 관리
  - CloudFormation 스택 관리
  - 개선된 스택 삭제 로직 (생성 시간 역순)
- **인터페이스**: `--action <create|delete|status> --interactive`

### **2. GCP GKE Helper (`gcp-gke-helper.sh`)**
- **역할**: GCP GKE 클러스터 생성, 삭제, 관리
- **주요 기능**:
  - 클러스터 생성/삭제
  - 노드 풀 관리
  - 네트워크 설정
- **인터페이스**: `--action <create|delete|status> --interactive`

### **3. 통합 클러스터 Helper (`cloud-cluster-helper.sh`)**
- **역할**: 멀티 클라우드 클러스터 통합 관리
- **주요 기능**:
  - AWS/GCP 클러스터 상태 확인
  - 통합 모니터링 설정
  - 클러스터 간 연결 테스트
- **인터페이스**: `--action <status|monitor|test> --interactive`

### **4. 개선된 EKS 정리 (`improved-eks-cleanup.sh`)**
- **역할**: EKS 클러스터 완전 정리 (개선된 로직)
- **주요 기능**:
  - 클러스터 이름 기반 동적 스택 검색
  - 생성 시간 역순 삭제
  - 의존성 순서 고려한 정리
  - VPC 삭제 지연 문제 해결
- **인터페이스**: 직접 실행 또는 메뉴에서 호출

## 🔄 메뉴 시스템과 서브 모듈 연동

### **호출 패턴**
```bash
# 메뉴에서 서브 모듈 호출 예시
case $choice in
    2)
        log_info "EKS 클러스터 관리"
        local eks_helper="../../tools/cloud/aws-eks-helper.sh"
        if [ -f "$eks_helper" ]; then
            chmod +x "$eks_helper"
            "$eks_helper" --interactive
        else
            log_warning "EKS Helper를 찾을 수 없습니다"
        fi
        ;;
esac
```

### **에러 처리**
```bash
# 서브 모듈이 없을 때 대안 제공
if [ -f "$improved_cleanup" ]; then
    log_info "개선된 EKS 정리 스크립트 실행 중..."
    "$improved_cleanup"
else
    log_warning "개선된 EKS 정리 스크립트를 찾을 수 없습니다"
    log_info "대신 기존 EKS Helper를 사용합니다."
    # 대안 로직 실행
fi
```

## 📋 서브 모듈 개발 가이드라인

### **1. 표준 인터페이스**
모든 서브 모듈은 다음 인터페이스를 준수해야 합니다:

```bash
#!/bin/bash
# 서브 모듈 표준 헤더
# 역할: [모듈 역할 설명]
# 인터페이스: --action <액션> [옵션]

# 표준 로깅 함수
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

### **2. 에러 처리**
```bash
# 서브 모듈 에러 처리 예시
if [ ! -f "$required_file" ]; then
    log_error "필수 파일을 찾을 수 없습니다: $required_file"
    exit 1
fi

# 명령 실행 에러 처리
if ! command -v aws &> /dev/null; then
    log_error "AWS CLI가 설치되지 않았습니다"
    exit 1
fi
```

### **3. 로깅 표준**
```bash
# 표준 로깅 함수 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
```

## 🧪 테스트 및 검증

### **1. 메뉴 시스템 테스트**
```bash
# 메뉴 시스템 기본 테스트
./day1-practice.sh --help
./day1-practice.sh --action status
./day1-practice.sh --action cleanup
```

### **2. 서브 모듈 테스트**
```bash
# 개별 서브 모듈 테스트
./aws-eks-helper.sh --action status
./gcp-gke-helper.sh --action status
./improved-eks-cleanup.sh
```

### **3. 통합 테스트**
```bash
# 전체 시스템 통합 테스트
./day1-practice.sh --action all
```

## 📊 성능 및 모니터링

### **1. 성능 지표**
- **메뉴 응답 시간**: 1초 이내
- **서브 모듈 실행 시간**: 작업별 최적화
- **에러 발생률**: 5% 이하

### **2. 모니터링 포인트**
- 서브 모듈 실행 성공/실패
- 사용자 메뉴 선택 패턴
- 에러 발생 빈도 및 유형

## 🔄 확장 가이드

### **1. 새 서브 모듈 추가**
1. `../../tools/cloud/` 디렉토리에 새 스크립트 생성
2. 표준 인터페이스 구현
3. 메뉴 시스템에 새 옵션 추가
4. 테스트 및 문서화

### **2. 새 메뉴 추가**
1. `day1-practice.sh`에 새 메뉴 함수 추가
2. 서브 모듈 호출 로직 구현
3. 에러 처리 및 대안 로직 추가
4. 사용자 가이드 업데이트

## 📚 관련 문서

- [Cloud Intermediate Day 1 실습 가이드](../README.md)
- [EKS 클러스터 관리 가이드](../tools/cloud/aws-eks-helper.sh)
- [GKE 클러스터 관리 가이드](../tools/cloud/gcp-gke-helper.sh)
- [개선된 EKS 정리 가이드](../tools/cloud/improved-eks-cleanup.sh)

## 🎯 결론

이 아키텍처는 **메뉴 시스템과 서브 모듈의 명확한 분리**를 통해 유지보수성과 확장성을 보장합니다. 각 컴포넌트는 독립적으로 개발, 테스트, 배포할 수 있으며, 전체 시스템의 안정성을 유지할 수 있습니다.
