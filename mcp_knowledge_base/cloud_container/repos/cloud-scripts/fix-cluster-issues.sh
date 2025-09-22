#!/bin/bash

# 클러스터 문제 해결 통합 스크립트
# AWS EKS와 GCP GKE 클러스터 연결 문제 해결

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

echo "=== 클러스터 문제 해결 통합 스크립트 ==="
echo ""

# 1. 환경 확인
log_info "환경 확인 중..."
echo "OS: $(uname -a)"
echo "WSL 감지: $(grep -q Microsoft /proc/version 2>/dev/null && echo 'Yes' || echo 'No')"
echo ""

# 2. AWS EKS 클러스터 상태 확인
log_info "=== AWS EKS 클러스터 상태 확인 ==="
if command -v aws &> /dev/null; then
    log_info "AWS CLI 사용 가능"
    
    # EKS 클러스터 목록 확인
    log_info "EKS 클러스터 목록 확인 중..."
    aws eks list-clusters --region ap-northeast-2 --output table 2>/dev/null || log_warning "EKS 클러스터 목록을 가져올 수 없습니다"
    
    # kubectl 컨텍스트 확인
    log_info "kubectl 컨텍스트 확인 중..."
    kubectl config get-contexts 2>/dev/null || log_warning "kubectl 컨텍스트를 가져올 수 없습니다"
    
    # EKS 클러스터 연결 테스트
    log_info "EKS 클러스터 연결 테스트 중..."
    if kubectl get nodes 2>/dev/null; then
        log_success "✅ AWS EKS 클러스터 연결 정상"
    else
        log_warning "⚠️ AWS EKS 클러스터 연결 실패"
        log_info "다음 명령어로 수동 연결 시도:"
        echo "  aws eks update-kubeconfig --region ap-northeast-2 --name cloud-master-eks-cluster"
    fi
else
    log_warning "AWS CLI가 설치되지 않았습니다"
fi
echo ""

# 3. GCP GKE 클러스터 상태 확인
log_info "=== GCP GKE 클러스터 상태 확인 ==="
if command -v gcloud &> /dev/null; then
    log_info "gcloud CLI 사용 가능"
    
    # GKE 클러스터 목록 확인
    log_info "GKE 클러스터 목록 확인 중..."
    gcloud container clusters list --region=asia-northeast3 --format="table(name,location,status)" 2>/dev/null || log_warning "GKE 클러스터 목록을 가져올 수 없습니다"
    
    # gke-gcloud-auth-plugin 확인
    log_info "gke-gcloud-auth-plugin 확인 중..."
    if command -v gke-gcloud-auth-plugin &> /dev/null; then
        log_success "✅ gke-gcloud-auth-plugin 설치됨"
        log_info "플러그인 버전: $(gke-gcloud-auth-plugin --version 2>/dev/null || echo '버전 확인 불가')"
    else
        log_warning "⚠️ gke-gcloud-auth-plugin이 설치되지 않음"
        
        # 1. gcloud components를 통한 설치 시도
        log_info "gcloud components를 통한 설치 시도 중..."
        if gcloud components install gke-gcloud-auth-plugin --quiet 2>/dev/null; then
            log_success "✅ gcloud components를 통한 설치 성공"
        else
            log_warning "gcloud components 설치 실패. 권한 문제일 수 있습니다."
            
            # 2. 수동 설치 스크립트 실행
            log_info "수동 설치 스크립트 실행 중..."
            if [ -f "./fix-gke-auth.sh" ]; then
                chmod +x ./fix-gke-auth.sh
                if ./fix-gke-auth.sh; then
                    log_success "✅ gke-gcloud-auth-plugin 설치 완료"
                else
                    log_error "❌ gke-gcloud-auth-plugin 설치 실패"
                    log_error "해결 방법:"
                    log_error "1. WSL을 관리자 권한으로 실행"
                    log_error "2. sudo gcloud components install gke-gcloud-auth-plugin 실행"
                    log_error "3. PC 재시작 후 다시 시도"
                fi
            else
                log_error "fix-gke-auth.sh 스크립트를 찾을 수 없습니다"
                log_error "해결 방법:"
                log_error "1. WSL을 관리자 권한으로 실행"
                log_error "2. sudo gcloud components install gke-gcloud-auth-plugin 실행"
                log_error "3. PC 재시작 후 다시 시도"
            fi
        fi
    fi
    
    # GKE 클러스터 연결 테스트
    log_info "GKE 클러스터 연결 테스트 중..."
    if kubectl get nodes 2>/dev/null; then
        log_success "✅ GCP GKE 클러스터 연결 정상"
    else
        log_warning "⚠️ GCP GKE 클러스터 연결 실패"
        log_info "다음 명령어로 수동 연결 시도:"
        echo "  gcloud container clusters get-credentials cloud-master-cluster --zone=asia-northeast3-a"
    fi
else
    log_warning "gcloud CLI가 설치되지 않았습니다"
fi
echo ""

# 4. kubectl 상태 종합 확인
log_info "=== kubectl 상태 종합 확인 ==="
log_info "현재 kubectl 컨텍스트:"
kubectl config current-context 2>/dev/null || log_warning "현재 컨텍스트를 가져올 수 없습니다"

log_info "사용 가능한 컨텍스트:"
kubectl config get-contexts 2>/dev/null || log_warning "컨텍스트 목록을 가져올 수 없습니다"

log_info "클러스터 정보:"
kubectl cluster-info 2>/dev/null || log_warning "클러스터 정보를 가져올 수 없습니다"

log_info "노드 상태:"
kubectl get nodes 2>/dev/null || log_warning "노드 정보를 가져올 수 없습니다"
echo ""

# 5. 문제 해결 권장사항
log_info "=== 문제 해결 권장사항 ==="

# AWS EKS 문제 해결
if ! kubectl get nodes 2>/dev/null | grep -q "ip-172-31"; then
    log_warning "AWS EKS 클러스터 연결 문제가 있습니다."
    echo "해결 방법:"
    echo "1. aws configure list  # AWS 자격 증명 확인"
    echo "2. aws eks update-kubeconfig --region ap-northeast-2 --name cloud-master-eks-cluster"
    echo "3. kubectl get nodes  # 연결 확인"
    echo ""
fi

# GCP GKE 문제 해결
if ! kubectl get nodes 2>/dev/null | grep -q "gke-"; then
    log_warning "GCP GKE 클러스터 연결 문제가 있습니다."
    echo "해결 방법:"
    echo "1. gcloud auth list  # GCP 인증 확인"
    echo "2. gcloud container clusters get-credentials cloud-master-cluster --zone=asia-northeast3-a"
    echo "3. kubectl get nodes  # 연결 확인"
    echo ""
fi

# 6. 자동 수정 시도
log_info "=== 자동 수정 시도 ==="

# AWS EKS 자동 연결
log_info "AWS EKS 클러스터 자동 연결 시도 중..."
if aws eks update-kubeconfig --region ap-northeast-2 --name cloud-master-eks-cluster 2>/dev/null; then
    log_success "✅ AWS EKS 클러스터 연결 완료"
    
    # AWS EKS 연결 테스트
    log_info "AWS EKS 클러스터 연결 테스트 중..."
    if kubectl get nodes 2>/dev/null | grep -q "ip-172-31"; then
        log_success "✅ AWS EKS 클러스터 정상 작동"
    else
        log_warning "⚠️ AWS EKS 클러스터 연결은 되었지만 노드 정보를 가져올 수 없습니다"
    fi
else
    log_warning "⚠️ AWS EKS 클러스터 자동 연결 실패"
fi

# GCP GKE 자동 연결
log_info "GCP GKE 클러스터 자동 연결 시도 중..."
if gcloud container clusters get-credentials cloud-master-cluster --zone=asia-northeast3-a 2>/dev/null; then
    log_success "✅ GCP GKE 클러스터 연결 완료"
    
    # GCP GKE 연결 테스트
    log_info "GCP GKE 클러스터 연결 테스트 중..."
    if kubectl get nodes 2>/dev/null | grep -q "gke-"; then
        log_success "✅ GCP GKE 클러스터 정상 작동"
    else
        log_warning "⚠️ GCP GKE 클러스터 연결은 되었지만 노드 정보를 가져올 수 없습니다"
    fi
else
    log_warning "⚠️ GCP GKE 클러스터 자동 연결 실패"
fi

echo ""
log_success "=== 클러스터 문제 해결 완료 ==="
echo ""
log_info "최종 상태 확인:"

# 현재 컨텍스트 확인
CURRENT_CONTEXT=$(kubectl config current-context 2>/dev/null)
log_info "현재 kubectl 컨텍스트: $CURRENT_CONTEXT"

# 클러스터 정보 확인
log_info "클러스터 정보:"
kubectl cluster-info 2>/dev/null || log_warning "클러스터 정보를 가져올 수 없습니다"

# 노드 상태 확인
log_info "노드 상태:"
if kubectl get nodes 2>/dev/null; then
    log_success "✅ 클러스터 연결 정상"
else
    log_warning "⚠️ 클러스터 연결 실패"
    
    # 상세 오류 정보
    log_info "상세 오류 정보:"
    kubectl get nodes 2>&1 | head -5
fi
