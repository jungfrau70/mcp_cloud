#!/bin/bash

# 클러스터 연결 테스트 스크립트
# 간단한 연결 상태 확인

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "=== 클러스터 연결 테스트 ==="
echo ""

# 1. 현재 컨텍스트 확인
log_info "현재 kubectl 컨텍스트:"
CURRENT_CONTEXT=$(kubectl config current-context 2>/dev/null)
if [ -n "$CURRENT_CONTEXT" ]; then
    echo "  $CURRENT_CONTEXT"
else
    log_warning "현재 컨텍스트를 가져올 수 없습니다"
fi
echo ""

# 2. 사용 가능한 컨텍스트 목록
log_info "사용 가능한 컨텍스트:"
kubectl config get-contexts 2>/dev/null || log_warning "컨텍스트 목록을 가져올 수 없습니다"
echo ""

# 3. 클러스터 정보
log_info "클러스터 정보:"
kubectl cluster-info 2>/dev/null || log_warning "클러스터 정보를 가져올 수 없습니다"
echo ""

# 4. 노드 상태
log_info "노드 상태:"
if kubectl get nodes 2>/dev/null; then
    log_success "✅ 클러스터 연결 정상"
    
    # 노드 수 확인
    NODE_COUNT=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
    log_info "총 노드 수: $NODE_COUNT"
    
    # 노드 상태 요약
    READY_NODES=$(kubectl get nodes --no-headers 2>/dev/null | grep "Ready" | wc -l)
    log_info "Ready 상태 노드: $READY_NODES/$NODE_COUNT"
    
else
    log_warning "⚠️ 클러스터 연결 실패"
    
    # 상세 오류 정보
    log_info "상세 오류 정보:"
    kubectl get nodes 2>&1 | head -3
fi
echo ""

# 5. 네임스페이스 확인
log_info "네임스페이스:"
kubectl get namespaces 2>/dev/null || log_warning "네임스페이스 정보를 가져올 수 없습니다"
echo ""

# 6. Pod 상태 확인
log_info "시스템 Pod 상태:"
kubectl get pods -n kube-system 2>/dev/null || log_warning "Pod 정보를 가져올 수 없습니다"
echo ""

log_success "=== 테스트 완료 ==="
