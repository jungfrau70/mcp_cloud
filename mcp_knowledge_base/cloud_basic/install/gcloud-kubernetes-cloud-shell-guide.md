# GCP Cloud Shell에서 GKE 클러스터 접속 가이드

## 🎯 학습 목표

### 핵심 학습 목표
- **GKE 클러스터 접속** Cloud Shell에서 kubectl을 사용하여 GKE 클러스터에 접속하는 방법
- **kubectl 설정** gcloud CLI를 통한 kubectl 자동 설정 및 인증

### 실습 후 달성할 수 있는 능력
- ✅ Cloud Shell에서 GKE 클러스터에 안전하게 접속
- ✅ kubectl 명령어를 사용하여 클러스터 관리
- ✅ 클러스터 상태 확인 및 리소스 조회

### 예상 소요 시간
- **GKE 클러스터 접속**: 10-15분
- **kubectl 설정**: 5-10분
- **전체 과정**: 20-30분

---

## 🛠️ 실습 학습

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/mcp_knowledge_base/cloud_basic/textbook/Day1/scripts/gke-connection.sh`
- **자동화 스크립트**: `/mcp_knowledge_base/cloud_basic/automation/day1/gke-connection.sh`
- **클라우드 스크립트**: `/mcp_knowledge_base/cloud_master/repos/cloud-scripts/gke-setup.sh`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **GCP 계정**: 활성화된 Google Cloud Platform 계정
- **Cloud Shell**: GCP 콘솔에서 제공하는 Cloud Shell 환경
- **GKE 클러스터**: 접속할 GKE 클러스터 (기존 또는 새로 생성)

#### 환경 설정
```bash
# Cloud Shell에서 현재 프로젝트 확인
gcloud config get-value project

# 필요한 경우 프로젝트 변경
gcloud config set project YOUR_PROJECT_ID

# gcloud CLI 버전 확인
gcloud version
```

</details>

<details>
<summary>🔧 1단계: GKE 클러스터 목록 확인</summary>

#### 클러스터 목록 조회
```bash
# 현재 프로젝트의 모든 GKE 클러스터 조회
gcloud container clusters list

# 특정 리전의 클러스터만 조회
gcloud container clusters list --filter="location:asia-northeast3"

# 클러스터 상세 정보 확인
gcloud container clusters describe CLUSTER_NAME --zone=ZONE_NAME
```

#### 클러스터 정보 확인
```bash
# 클러스터 상태 확인
gcloud container clusters describe CLUSTER_NAME --zone=ZONE_NAME --format="value(status)"

# 클러스터 엔드포인트 확인
gcloud container clusters describe CLUSTER_NAME --zone=ZONE_NAME --format="value(endpoint)"
```

</details>

<details>
<summary>🔧 2단계: kubectl 자동 설정</summary>

#### kubectl 자동 설정
```bash
# 특정 클러스터에 대한 kubectl 설정
gcloud container clusters get-credentials CLUSTER_NAME --zone=ZONE_NAME

# 리전 클러스터의 경우
gcloud container clusters get-credentials CLUSTER_NAME --region=REGION_NAME

# 설정 확인
kubectl config current-context
```

#### kubectl 설정 검증
```bash
# 클러스터 연결 테스트
kubectl cluster-info

# 노드 상태 확인
kubectl get nodes

# 네임스페이스 목록 확인
kubectl get namespaces
```

</details>

<details>
<summary>🔧 3단계: 클러스터 접속 및 관리</summary>

#### 기본 kubectl 명령어
```bash
# 클러스터 정보 확인
kubectl cluster-info dump

# 노드 상세 정보
kubectl describe nodes

# 파드 목록 확인
kubectl get pods --all-namespaces

# 서비스 목록 확인
kubectl get services --all-namespaces
```

#### 네임스페이스별 리소스 확인
```bash
# 특정 네임스페이스의 파드 확인
kubectl get pods -n kube-system

# 파드 상세 정보
kubectl describe pod POD_NAME -n NAMESPACE

# 파드 로그 확인
kubectl logs POD_NAME -n NAMESPACE
```

</details>

<details>
<summary>🔧 4단계: 고급 접속 설정</summary>

#### 여러 클러스터 관리
```bash
# 사용 가능한 컨텍스트 목록
kubectl config get-contexts

# 컨텍스트 전환
kubectl config use-context CONTEXT_NAME

# 현재 컨텍스트 확인
kubectl config current-context
```

#### kubectl 설정 파일 관리
```bash
# kubectl 설정 파일 위치 확인
echo $KUBECONFIG

# 설정 파일 내용 확인
kubectl config view

# 특정 클러스터 정보만 확인
kubectl config view --minify
```

</details>

---

## 📚 참고 자료

### 유용한 명령어
```bash
# 클러스터 상태 모니터링
kubectl top nodes
kubectl top pods --all-namespaces

# 리소스 사용량 확인
kubectl get resourcequota --all-namespaces

# 이벤트 확인
kubectl get events --sort-by=.metadata.creationTimestamp
```

### 문제 해결
1. **인증 오류**
   - `gcloud auth login` 실행
   - `gcloud auth application-default login` 실행
   - 서비스 계정 키 확인

2. **클러스터 접속 실패**
   - 클러스터 상태 확인: `gcloud container clusters describe`
   - 방화벽 규칙 확인
   - 네트워크 연결 상태 확인

3. **kubectl 명령어 오류**
   - kubectl 버전 확인: `kubectl version --client`
   - 클러스터 API 서버 버전과 호환성 확인
   - 컨텍스트 설정 확인: `kubectl config current-context`

### 보안 고려사항
```bash
# RBAC 권한 확인
kubectl auth can-i get pods
kubectl auth can-i create deployments

# 서비스 계정 권한 확인
kubectl get serviceaccounts
kubectl describe serviceaccount SERVICE_ACCOUNT_NAME
```

---

## 🧹 실습 정리

### 자동 정리
```bash
# kubectl 컨텍스트 정리 (필요시)
kubectl config delete-context CONTEXT_NAME

# 불필요한 클러스터 설정 제거
gcloud container clusters delete CLUSTER_NAME --zone=ZONE_NAME --quiet
```

### 수동 정리
```bash
# 현재 컨텍스트 확인
kubectl config current-context

# 설정 파일 백업
cp ~/.kube/config ~/.kube/config.backup

# kubectl 설정 초기화 (필요시)
kubectl config unset current-context
```

### 정리 확인
- [ ] 불필요한 클러스터 연결 제거
- [ ] kubectl 설정 파일 정리
- [ ] 사용하지 않는 컨텍스트 삭제

---

## 🔧 환경 체크 시스템

### 통합 환경 체크 스크립트
```bash
#!/bin/bash

# GKE 클러스터 접속 환경 체크 스크립트
# Cloud Shell에서 GKE 접속 환경 검증 도구

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 로그 함수
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 체크 결과 저장
CHECKS_PASSED=0
CHECKS_FAILED=0
TOTAL_CHECKS=0

# 체크 함수
check_command() {
    local command_name="$1"
    local command="$2"
    local expected_output="$3"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    log_info "체크 중: $command_name"
    
    if command -v "$command" &> /dev/null; then
        if [ -n "$expected_output" ]; then
            if eval "$command" | grep -q "$expected_output"; then
                log_success "✅ $command_name: 정상"
                CHECKS_PASSED=$((CHECKS_PASSED + 1))
            else
                log_error "❌ $command_name: 예상 출력과 다름"
                CHECKS_FAILED=$((CHECKS_FAILED + 1))
            fi
        else
            log_success "✅ $command_name: 설치됨"
            CHECKS_PASSED=$((CHECKS_PASSED + 1))
        fi
    else
        log_error "❌ $command_name: 설치되지 않음"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
}

# GKE 클러스터 접속 체크
check_gke_connection() {
    log_info "GKE 클러스터 접속 환경 체크"
    
    # gcloud CLI 체크
    check_command "gcloud CLI" "gcloud version" "Google Cloud SDK"
    
    # kubectl 체크
    check_command "kubectl" "kubectl version --client" "Client Version"
    
    # 현재 프로젝트 체크
    local current_project=$(gcloud config get-value project 2>/dev/null)
    if [ -n "$current_project" ]; then
        log_success "✅ 현재 프로젝트: $current_project"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_error "❌ 프로젝트가 설정되지 않음"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    # GKE 클러스터 존재 여부 체크
    local cluster_count=$(gcloud container clusters list --format="value(name)" 2>/dev/null | wc -l)
    if [ "$cluster_count" -gt 0 ]; then
        log_success "✅ GKE 클러스터 $cluster_count개 발견"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_warning "⚠️ GKE 클러스터가 없습니다"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    # kubectl 컨텍스트 체크
    local current_context=$(kubectl config current-context 2>/dev/null)
    if [ -n "$current_context" ]; then
        log_success "✅ 현재 kubectl 컨텍스트: $current_context"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        log_warning "⚠️ kubectl 컨텍스트가 설정되지 않음"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

# 결과 요약
print_summary() {
    log_info "=== GKE 클러스터 접속 환경 체크 결과 요약 ==="
    
    local success_rate=$((CHECKS_PASSED * 100 / TOTAL_CHECKS))
    
    if [ "$success_rate" -ge 90 ]; then
        log_success "🎉 GKE 접속 환경 준비 완료! (${success_rate}%)"
    elif [ "$success_rate" -ge 70 ]; then
        log_warning "⚠️ GKE 접속 환경 부분 준비 (${success_rate}%)"
    else
        log_error "❌ GKE 접속 환경 설정 필요 (${success_rate}%)"
    fi
    
    echo ""
    log_info "다음 단계:"
    if [ "$CHECKS_FAILED" -gt 0 ]; then
        log_info "1. gcloud container clusters get-credentials CLUSTER_NAME --zone=ZONE_NAME"
        log_info "2. kubectl cluster-info"
        log_info "3. kubectl get nodes"
    else
        log_info "1. kubectl get pods --all-namespaces"
        log_info "2. kubectl get services --all-namespaces"
        log_info "3. kubectl get nodes"
    fi
}

# 메인 실행
main() {
    log_info "GKE 클러스터 접속 환경 체크 시작"
    check_gke_connection
    print_summary
}

# 스크립트 실행
main "$@"
```

---

## 📋 품질 관리 규칙

### **문서 무결성 체크**
- [ ] 모든 GKE 접속 명령어가 실제로 작동하는지 확인
- [ ] Cloud Shell 환경에서 테스트 완료
- [ ] 다양한 GKE 클러스터 유형에서 검증
- [ ] 오류 상황에 대한 해결 방법 포함

### **구조 일관성 체크**
- [ ] 단계별 명령어 순서가 논리적
- [ ] 각 단계별 예상 결과 명시
- [ ] 문제 해결 가이드 포함
- [ ] 보안 고려사항 포함

### **연결 관계 체크**
- [ ] GKE 클러스터 생성 가이드와 연결
- [ ] kubectl 기본 사용법과 연결
- [ ] GCP 인증 가이드와 연결
- [ ] Cloud Shell 사용법과 연결

---

## 🚀 확장 규칙

### **새로운 GKE 기능 추가 시**
1. 새로운 kubectl 명령어 추가
2. 환경 체크 스크립트에 새 기능 검증 로직 추가
3. 문제 해결 가이드에 새 오류 상황 추가
4. 보안 고려사항 업데이트

### **새로운 클러스터 유형 지원 시**
1. 클러스터별 접속 방법 추가
2. 특화된 설정 옵션 설명
3. 클러스터별 문제 해결 가이드 추가
4. 성능 최적화 팁 추가

이 가이드를 통해 Cloud Shell에서 GKE 클러스터에 안전하고 효율적으로 접속할 수 있습니다.
