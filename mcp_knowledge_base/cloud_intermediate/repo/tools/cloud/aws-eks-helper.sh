#!/bin/bash

# AWS EKS 클러스터 구성 Helper 스크립트
# Cloud Intermediate 과정용 EKS 클러스터 자동화 도구

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

# 기본 설정
CLUSTER_NAME="cloud-intermediate-eks"
REGION="ap-northeast-2"
NODE_TYPE="t3.medium"
NODE_COUNT=2
MIN_NODES=1
MAX_NODES=4
VERSION="1.28"

# 환경 변수 로드
if [ -f "aws-environment.env" ]; then
    source aws-environment.env
    log_info "AWS 환경 변수 로드 완료"
fi

# AWS CLI 설정 확인
check_aws_cli() {
    log_info "AWS CLI 설정 확인 중..."
    
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI가 설치되지 않았습니다."
        return 1
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS 자격 증명이 설정되지 않았습니다."
        return 1
    fi
    
    log_success "AWS CLI 설정 확인 완료"
    return 0
}

# eksctl 설치 확인
check_eksctl() {
    log_info "eksctl 설치 확인 중..."
    
    if ! command -v eksctl &> /dev/null; then
        log_warning "eksctl이 설치되지 않았습니다. 설치를 진행합니다..."
        
        # eksctl 설치
        curl --silent --location "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
        sudo mv /tmp/eksctl /usr/local/bin
        chmod +x /usr/local/bin/eksctl
        
        if command -v eksctl &> /dev/null; then
            log_success "eksctl 설치 완료"
        else
            log_error "eksctl 설치 실패"
            return 1
        fi
    else
        log_success "eksctl 설치 확인 완료"
    fi
    
    return 0
}

# EKS 클러스터 생성
create_eks_cluster() {
    log_info "EKS 클러스터 생성 시작: $CLUSTER_NAME"
    
    # 클러스터 존재 여부 확인
    if eksctl get cluster --name $CLUSTER_NAME --region $REGION &> /dev/null; then
        log_warning "클러스터 $CLUSTER_NAME이 이미 존재합니다."
        read -p "기존 클러스터를 삭제하고 새로 생성하시겠습니까? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            delete_eks_cluster
        else
            log_info "기존 클러스터를 사용합니다."
            return 0
        fi
    fi
    
    # EKS 클러스터 생성
    eksctl create cluster \
        --name $CLUSTER_NAME \
        --region $REGION \
        --version $VERSION \
        --nodegroup-name standard-workers \
        --node-type $NODE_TYPE \
        --nodes $NODE_COUNT \
        --nodes-min $MIN_NODES \
        --nodes-max $MAX_NODES \
        --managed \
        --with-oidc \
        --ssh-access \
        --ssh-public-key cloud-deployment-key \
        --full-ecr-access \
        --tags "Environment=Learning,Project=CloudIntermediate"
    
    if [ $? -eq 0 ]; then
        log_success "EKS 클러스터 생성 완료: $CLUSTER_NAME"
        
        # kubectl 설정
        aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME
        
        # 클러스터 정보 출력
        log_info "클러스터 정보:"
        kubectl cluster-info
        kubectl get nodes
        
        return 0
    else
        log_error "EKS 클러스터 생성 실패"
        return 1
    fi
}

# EKS 클러스터 삭제
delete_eks_cluster() {
    log_warning "EKS 클러스터 삭제 시작: $CLUSTER_NAME"
    
    read -p "정말로 클러스터를 삭제하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "클러스터 삭제를 취소했습니다."
        return 0
    fi
    
    eksctl delete cluster --name $CLUSTER_NAME --region $REGION
    
    if [ $? -eq 0 ]; then
        log_success "EKS 클러스터 삭제 완료: $CLUSTER_NAME"
    else
        log_error "EKS 클러스터 삭제 실패"
        return 1
    fi
}

# EKS 클러스터 상태 확인
check_eks_cluster() {
    log_info "EKS 클러스터 상태 확인: $CLUSTER_NAME"
    
    if eksctl get cluster --name $CLUSTER_NAME --region $REGION &> /dev/null; then
        log_success "클러스터가 실행 중입니다."
        
        # 클러스터 상세 정보
        eksctl get cluster --name $CLUSTER_NAME --region $REGION -o yaml
        
        # 노드 그룹 정보
        eksctl get nodegroup --cluster $CLUSTER_NAME --region $REGION
        
        # kubectl 설정 확인
        if kubectl cluster-info &> /dev/null; then
            log_success "kubectl 설정 완료"
            kubectl get nodes
        else
            log_warning "kubectl 설정이 필요합니다."
            aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME
        fi
    else
        log_error "클러스터가 존재하지 않거나 접근할 수 없습니다."
        return 1
    fi
}

# EKS 클러스터 스케일링
scale_eks_cluster() {
    local desired_count=$1
    
    if [ -z "$desired_count" ]; then
        log_error "스케일링할 노드 수를 지정해주세요."
        return 1
    fi
    
    log_info "EKS 클러스터 스케일링: $desired_count 노드"
    
    eksctl scale nodegroup \
        --cluster $CLUSTER_NAME \
        --name standard-workers \
        --nodes $desired_count \
        --region $REGION
    
    if [ $? -eq 0 ]; then
        log_success "클러스터 스케일링 완료: $desired_count 노드"
    else
        log_error "클러스터 스케일링 실패"
        return 1
    fi
}

# EKS 클러스터 업그레이드
upgrade_eks_cluster() {
    local target_version=$1
    
    if [ -z "$target_version" ]; then
        log_error "업그레이드할 버전을 지정해주세요."
        return 1
    fi
    
    log_info "EKS 클러스터 업그레이드: $target_version"
    
    eksctl upgrade cluster \
        --name $CLUSTER_NAME \
        --version $target_version \
        --region $REGION
    
    if [ $? -eq 0 ]; then
        log_success "클러스터 업그레이드 완료: $target_version"
    else
        log_error "클러스터 업그레이드 실패"
        return 1
    fi
}

# EKS 클러스터 모니터링 설정
setup_eks_monitoring() {
    log_info "EKS 클러스터 모니터링 설정 시작"
    
    # Prometheus 설정
    kubectl create namespace monitoring
    
    # Prometheus Operator 설치
    kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/bundle.yaml
    
    # Node Exporter DaemonSet
    kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      containers:
      - name: node-exporter
        image: prom/node-exporter:latest
        ports:
        - containerPort: 9100
        volumeMounts:
        - name: proc
          mountPath: /host/proc
          readOnly: true
        - name: sys
          mountPath: /host/sys
          readOnly: true
      volumes:
      - name: proc
        hostPath:
          path: /proc
      - name: sys
        hostPath:
          path: /sys
EOF
    
    log_success "EKS 클러스터 모니터링 설정 완료"
}

# 사용법 출력
usage() {
    echo "AWS EKS 클러스터 구성 Helper 스크립트"
    echo ""
    echo "사용법:"
    echo "  $0 [옵션]                    # Interactive 모드"
    echo "  $0 --action <액션> [파라미터] # Parameter 모드"
    echo ""
    echo "Interactive 모드 옵션:"
    echo "  --interactive, -i            # Interactive 모드 (기본값)"
    echo "  --help, -h                   # 도움말 출력"
    echo ""
    echo "Parameter 모드 액션:"
    echo "  --action create              # EKS 클러스터 생성"
    echo "  --action delete              # EKS 클러스터 삭제"
    echo "  --action status              # EKS 클러스터 상태 확인"
    echo "  --action scale <count>       # 클러스터 스케일링"
    echo "  --action upgrade <version>   # 클러스터 업그레이드"
    echo "  --action monitoring          # 모니터링 설정"
    echo ""
    echo "예시:"
    echo "  $0                           # Interactive 모드"
    echo "  $0 --action create           # EKS 클러스터 생성"
    echo "  $0 --action status           # 클러스터 상태 확인"
    echo "  $0 --action scale 3          # 노드 3개로 스케일링"
    echo ""
    echo "환경 변수:"
    echo "  CLUSTER_NAME        클러스터 이름 (기본값: cloud-intermediate-eks)"
    echo "  REGION              AWS 리전 (기본값: ap-northeast-2)"
    echo "  NODE_TYPE           노드 타입 (기본값: t3.medium)"
    echo "  NODE_COUNT          노드 수 (기본값: 2)"
}

# Interactive 모드 메뉴
show_interactive_menu() {
    echo ""
    log_header "AWS EKS 클러스터 관리 메뉴"
    echo "1. EKS 클러스터 생성"
    echo "2. EKS 클러스터 삭제"
    echo "3. 클러스터 상태 확인"
    echo "4. 클러스터 스케일링"
    echo "5. 클러스터 업그레이드"
    echo "6. 모니터링 설정"
    echo "7. 종료"
    echo ""
}

# Interactive 모드 실행
run_interactive_mode() {
    log_header "AWS EKS 클러스터 관리"
    
    while true; do
        show_interactive_menu
        read -p "선택하세요 (1-7): " choice
        
        case $choice in
            1)
                create_eks_cluster
                ;;
            2)
                delete_eks_cluster
                ;;
            3)
                check_eks_cluster
                ;;
            4)
                read -p "스케일링할 노드 수를 입력하세요: " node_count
                scale_eks_cluster "$node_count"
                ;;
            5)
                read -p "업그레이드할 버전을 입력하세요: " version
                upgrade_eks_cluster "$version"
                ;;
            6)
                setup_eks_monitoring
                ;;
            7)
                log_info "프로그램을 종료합니다"
                exit 0
                ;;
            *)
                log_error "잘못된 선택입니다. 1-7 중에서 선택하세요."
                ;;
        esac
        
        echo ""
        read -p "계속하려면 Enter를 누르세요..."
    done
}

# Parameter 모드 실행
run_parameter_mode() {
    local action=$1
    shift
    
    case "$action" in
        "create")
            check_aws_cli && check_eksctl && create_eks_cluster
            ;;
        "delete")
            check_aws_cli && check_eksctl && delete_eks_cluster
            ;;
        "status")
            check_aws_cli && check_eksctl && check_eks_cluster
            ;;
        "scale")
            check_aws_cli && check_eksctl && scale_eks_cluster "$1"
            ;;
        "upgrade")
            check_aws_cli && check_eksctl && upgrade_eks_cluster "$1"
            ;;
        "monitoring")
            check_aws_cli && check_eksctl && setup_eks_monitoring
            ;;
        *)
            log_error "알 수 없는 액션: $action"
            usage
            exit 1
            ;;
    esac
}

# 메인 함수
main() {
    # 인수 처리
    case "${1:-}" in
        "--help"|"-h")
            usage
            exit 0
            ;;
        "--interactive"|"-i"|"")
            run_interactive_mode
            ;;
        "--action")
            if [ -z "${2:-}" ]; then
                log_error "액션을 지정해주세요."
                usage
                exit 1
            fi
            run_parameter_mode "$2" "$3"
            ;;
        *)
            log_error "알 수 없는 옵션: $1"
            usage
            exit 1
            ;;
    esac
}

# 스크립트 실행
main "$@"
