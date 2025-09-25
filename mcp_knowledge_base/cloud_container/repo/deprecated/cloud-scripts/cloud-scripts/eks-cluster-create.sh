#!/bin/bash

# AWS EKS 클러스터 자동 생성 스크립트
# Cloud Master Day2용 - Kubernetes & 고급 CI/CD

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

# 설정 변수
CLUSTER_NAME="cloud-master-eks-cluster"
REGION="ap-northeast-2"
NODE_GROUP_NAME="cloud-master-nodegroup"
NODE_COUNT=3
NODE_TYPE="t3.medium"
MIN_NODES=1
MAX_NODES=10
VERSION="1.28"

# 체크포인트 파일
CHECKPOINT_FILE="eks-cluster-checkpoint.json"

# 체크포인트 로드
load_checkpoint() {
    if [ -f "$CHECKPOINT_FILE" ]; then
        log_warning "이전 체크포인트 파일이 발견되었습니다."
        log_info "체크포인트 파일 삭제 중..."
        rm -f "$CHECKPOINT_FILE"
        log_success "체크포인트 파일 삭제 완료"
    fi
}

# 체크포인트 저장
save_checkpoint() {
    log_info "체크포인트 저장 중..."
    cat > "$CHECKPOINT_FILE" << EOF
CLUSTER_CREATED=$CLUSTER_CREATED
NODE_GROUP_CREATED=$NODE_GROUP_CREATED
CLUSTER_CONNECTED=$CLUSTER_CONNECTED
VPC_CREATED=$VPC_CREATED
EOF
}

# 환경 체크
check_environment() {
    log_info "환경 체크 중..."
    
    # AWS CLI 체크
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI가 설치되지 않았습니다."
        log_info "설치 방법: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
        exit 1
    fi
    
    # eksctl 체크
    if ! command -v eksctl &> /dev/null; then
        log_warning "eksctl이 설치되지 않았습니다. 설치 중..."
        # Linux/macOS용 설치
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
            sudo mv /tmp/eksctl /usr/local/bin
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install eksctl
        else
            log_error "지원되지 않는 운영체제입니다. eksctl을 수동으로 설치하세요."
            exit 1
        fi
    fi
    
    # kubectl 체크
    if ! command -v kubectl &> /dev/null; then
        log_warning "kubectl이 설치되지 않았습니다. 설치 중..."
        # Linux용 kubectl 설치
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
            chmod +x kubectl
            sudo mv kubectl /usr/local/bin/
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install kubectl
        fi
    fi
    
    # AWS 인증 체크
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS 인증이 필요합니다. 'aws configure'를 실행하세요."
        exit 1
    fi
    
    # AWS 리전 설정
    aws configure set region "$REGION"
    
    log_success "환경 체크 완료"
}

# VPC 및 서브넷 생성
create_vpc() {
    if [ "$VPC_CREATED" = "true" ]; then
        log_info "VPC가 이미 생성되어 있습니다."
        return 0
    fi
    
    log_info "VPC 및 서브넷 확인 중..."
    
    # 기존 VPC 확인 (cloud-master 관련)
    VPC_ID=$(aws ec2 describe-vpcs \
        --filters "Name=tag:Name,Values=*cloud-master*" \
        --query 'Vpcs[0].VpcId' \
        --output text 2>/dev/null)
    
    # cloud-master VPC가 없으면 일반 VPC 확인
    if [ -z "$VPC_ID" ] || [ "$VPC_ID" = "None" ]; then
        VPC_ID=$(aws ec2 describe-vpcs \
            --filters "Name=state,Values=available" \
            --query 'Vpcs[0].VpcId' \
            --output text 2>/dev/null)
    fi
    
    if [ -n "$VPC_ID" ] && [ "$VPC_ID" != "None" ]; then
        log_warning "기존 VPC를 발견했습니다: $VPC_ID"
        echo -n "기존 VPC를 사용하시겠습니까? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_info "새 VPC를 생성합니다."
            VPC_ID=""
        else
            log_info "기존 VPC 사용: $VPC_ID"
        fi
    fi
    
    if [ -n "$VPC_ID" ] && [ "$VPC_ID" != "None" ]; then
        log_info "기존 VPC 사용: $VPC_ID"
        
        # 기존 서브넷 확인 (cloud-master 관련)
        SUBNET_1_ID=$(aws ec2 describe-subnets \
            --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=*cloud-master-eks-subnet-1*" \
            --query 'Subnets[0].SubnetId' \
            --output text 2>/dev/null)
        
        SUBNET_2_ID=$(aws ec2 describe-subnets \
            --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=*cloud-master-eks-subnet-2*" \
            --query 'Subnets[0].SubnetId' \
            --output text 2>/dev/null)
        
        # cloud-master 서브넷이 없으면 일반 서브넷 확인
        if [ -z "$SUBNET_1_ID" ] || [ "$SUBNET_1_ID" = "None" ]; then
            SUBNET_1_ID=$(aws ec2 describe-subnets \
                --filters "Name=vpc-id,Values=$VPC_ID" "Name=availability-zone,Values=${REGION}a" \
                --query 'Subnets[0].SubnetId' \
                --output text 2>/dev/null)
        fi
        
        if [ -z "$SUBNET_2_ID" ] || [ "$SUBNET_2_ID" = "None" ]; then
            SUBNET_2_ID=$(aws ec2 describe-subnets \
                --filters "Name=vpc-id,Values=$VPC_ID" "Name=availability-zone,Values=${REGION}c" \
                --query 'Subnets[0].SubnetId' \
                --output text 2>/dev/null)
        fi
        
        if [ -n "$SUBNET_1_ID" ] && [ -n "$SUBNET_2_ID" ] && [ "$SUBNET_1_ID" != "None" ] && [ "$SUBNET_2_ID" != "None" ]; then
            log_success "기존 VPC 및 서브넷 사용 완료"
            log_info "VPC ID: $VPC_ID"
            log_info "서브넷 1 ID: $SUBNET_1_ID"
            log_info "서브넷 2 ID: $SUBNET_2_ID"
            VPC_CREATED="true"
            return 0
        else
            log_warning "기존 VPC는 있지만 서브넷이 부족합니다. 새로 생성합니다."
        fi
    fi
    
    log_info "새 VPC 및 서브넷 생성 중..."
    
    # VPC 생성
    VPC_ID=$(aws ec2 create-vpc \
        --cidr-block 10.0.0.0/16 \
        --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=cloud-master-eks-vpc}]' \
        --query 'Vpc.VpcId' \
        --output text 2>/dev/null)
    
    if [ -z "$VPC_ID" ] || [ "$VPC_ID" = "None" ]; then
        log_error "VPC 생성 실패"
        log_error "가능한 원인:"
        log_error "1. VPC 한도 초과 (최대 5개)"
        log_error "2. AWS 계정 권한 부족"
        log_error "3. 리전별 리소스 한도 초과"
        log_error ""
        log_error "해결 방법:"
        log_error "1. 기존 VPC 삭제: aws ec2 delete-vpc --vpc-id [VPC_ID]"
        log_error "2. 다른 리전 사용: --region [다른-리전]"
        log_error "3. AWS 콘솔에서 VPC 한도 증가 요청"
        exit 1
    fi
    
    # VPC ID를 환경변수로 설정
    export VPC_ID
    
    # 인터넷 게이트웨이 생성 및 연결
    IGW_ID=$(aws ec2 create-internet-gateway \
        --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=cloud-master-eks-igw}]' \
        --query 'InternetGateway.InternetGatewayId' \
        --output text)
    
    aws ec2 attach-internet-gateway \
        --vpc-id "$VPC_ID" \
        --internet-gateway-id "$IGW_ID"
    
    # 퍼블릭 서브넷 생성 (2개 AZ)
    SUBNET_1_ID=$(aws ec2 create-subnet \
        --vpc-id "$VPC_ID" \
        --cidr-block 10.0.1.0/24 \
        --availability-zone "${REGION}a" \
        --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=cloud-master-eks-subnet-1}]' \
        --query 'Subnet.SubnetId' \
        --output text)
    
    SUBNET_2_ID=$(aws ec2 create-subnet \
        --vpc-id "$VPC_ID" \
        --cidr-block 10.0.2.0/24 \
        --availability-zone "${REGION}c" \
        --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=cloud-master-eks-subnet-2}]' \
        --query 'Subnet.SubnetId' \
        --output text)
    
    # 서브넷 ID를 환경변수로 설정
    export SUBNET_1_ID
    export SUBNET_2_ID
    
    # 라우트 테이블 생성 및 설정
    RT_ID=$(aws ec2 create-route-table \
        --vpc-id "$VPC_ID" \
        --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=cloud-master-eks-rt}]' \
        --query 'RouteTable.RouteTableId' \
        --output text)
    
    # 인터넷 게이트웨이로의 라우트 추가
    aws ec2 create-route \
        --route-table-id "$RT_ID" \
        --destination-cidr-block 0.0.0.0/0 \
        --gateway-id "$IGW_ID"
    
    # 서브넷을 라우트 테이블에 연결
    aws ec2 associate-route-table \
        --subnet-id "$SUBNET_1_ID" \
        --route-table-id "$RT_ID"
    
    aws ec2 associate-route-table \
        --subnet-id "$SUBNET_2_ID" \
        --route-table-id "$RT_ID"
    
    # 서브넷에서 퍼블릭 IP 자동 할당 활성화
    aws ec2 modify-subnet-attribute \
        --subnet-id "$SUBNET_1_ID" \
        --map-public-ip-on-launch
    
    aws ec2 modify-subnet-attribute \
        --subnet-id "$SUBNET_2_ID" \
        --map-public-ip-on-launch
    
    VPC_CREATED="true"
    log_success "VPC 및 서브넷 생성 완료"
    log_info "VPC ID: $VPC_ID"
    log_info "서브넷 1 ID: $SUBNET_1_ID"
    log_info "서브넷 2 ID: $SUBNET_2_ID"
}

# EKS 클러스터 생성
create_cluster() {
    if [ "$CLUSTER_CREATED" = "true" ]; then
        log_info "클러스터가 이미 생성되어 있습니다."
        return 0
    fi
    
    log_info "EKS 클러스터 생성 중..."
    
    # 서브넷 ID 확인
    if [ -z "$SUBNET_1_ID" ] || [ -z "$SUBNET_2_ID" ]; then
        log_error "서브넷 ID가 설정되지 않았습니다. VPC를 다시 생성합니다."
        VPC_CREATED="false"
        create_vpc
    fi
    
    # EKS 클러스터 생성 (SSH 접근 없이)
    log_info "EKS 클러스터를 생성합니다."
    
    eksctl create cluster \
        --name "$CLUSTER_NAME" \
        --region "$REGION" \
        --version "$VERSION" \
        --vpc-private-subnets "$SUBNET_1_ID,$SUBNET_2_ID" \
        --vpc-public-subnets "$SUBNET_1_ID,$SUBNET_2_ID" \
        --nodegroup-name "$NODE_GROUP_NAME" \
        --node-type "$NODE_TYPE" \
        --nodes "$NODE_COUNT" \
        --nodes-min "$MIN_NODES" \
        --nodes-max "$MAX_NODES" \
        --managed \
        --with-oidc \
        --full-ecr-access \
        --asg-access \
        --external-dns-access \
        --appmesh-access \
        --alb-ingress-access
    
    if [ $? -eq 0 ]; then
        CLUSTER_CREATED="true"
        log_success "EKS 클러스터 생성 완료: $CLUSTER_NAME"
    else
        log_error "클러스터 생성 실패"
        exit 1
    fi
}

# 클러스터 연결
connect_cluster() {
    if [ "$CLUSTER_CONNECTED" = "true" ]; then
        log_info "클러스터가 이미 연결되어 있습니다."
        return 0
    fi
    
    log_info "클러스터 연결 중..."
    
    # kubeconfig 업데이트
    aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"
    
    if [ $? -eq 0 ]; then
        CLUSTER_CONNECTED="true"
        log_success "클러스터 연결 완료"
        
        # 클러스터 정보 출력
        log_info "클러스터 정보:"
        kubectl cluster-info
        kubectl get nodes
    else
        log_error "클러스터 연결 실패"
        exit 1
    fi
}

# 네임스페이스 생성
create_namespaces() {
    log_info "네임스페이스 생성 중..."
    
    # 기본 네임스페이스들 생성
    kubectl create namespace development --dry-run=client -o yaml | kubectl apply -f -
    kubectl create namespace staging --dry-run=client -o yaml | kubectl apply -f -
    kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f -
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    
    log_success "네임스페이스 생성 완료"
}

# 기본 리소스 생성
create_basic_resources() {
    log_info "기본 리소스 생성 중..."
    
    # ConfigMap 생성
    kubectl create configmap app-config \
        --from-literal=database_url="postgresql://localhost:5432/myapp" \
        --from-literal=redis_url="redis://localhost:6379" \
        --namespace=development
    
    # Secret 생성
    kubectl create secret generic app-secrets \
        --from-literal=api-key="your-api-key-here" \
        --from-literal=db-password="your-db-password-here" \
        --namespace=development
    
    # ServiceAccount 생성
    kubectl create serviceaccount app-service-account --namespace=development
    
    # ClusterRole 및 ClusterRoleBinding 생성
    kubectl create clusterrole app-cluster-role \
        --verb=get,list,watch \
        --resource=pods,services,configmaps,secrets
    
    kubectl create clusterrolebinding app-cluster-role-binding \
        --clusterrole=app-cluster-role \
        --serviceaccount=development:app-service-account
    
    log_success "기본 리소스 생성 완료"
}

# AWS Load Balancer Controller 설치
install_aws_load_balancer_controller() {
    log_info "AWS Load Balancer Controller 설치 중..."
    
    # IAM 정책 다운로드
    curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.4/docs/install/iam_policy.json
    
    # IAM 정책 생성
    aws iam create-policy \
        --policy-name AWSLoadBalancerControllerIAMPolicy \
        --policy-document file://iam_policy.json
    
    # IAM 역할 생성
    eksctl create iamserviceaccount \
        --cluster="$CLUSTER_NAME" \
        --namespace=kube-system \
        --name=aws-load-balancer-controller \
        --role-name AmazonEKSLoadBalancerControllerRole \
        --attach-policy-arn=arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/AWSLoadBalancerControllerIAMPolicy \
        --approve
    
    # Helm을 통한 설치
    helm repo add eks https://aws.github.io/eks-charts
    helm repo update
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
        -n kube-system \
        --set clusterName="$CLUSTER_NAME" \
        --set serviceAccount.create=false \
        --set serviceAccount.name=aws-load-balancer-controller
    
    # 정리
    rm -f iam_policy.json
    
    log_success "AWS Load Balancer Controller 설치 완료"
}

# 모니터링 설정
setup_monitoring() {
    log_info "모니터링 설정 중..."
    
    # Prometheus 네임스페이스 생성
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    
    # Prometheus ConfigMap 생성
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090']
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
          - role: pod
EOF
    
    log_success "모니터링 설정 완료"
}

# 클러스터 상태 확인
check_cluster_status() {
    log_info "클러스터 상태 확인 중..."
    
    # 노드 상태 확인
    log_info "노드 상태:"
    kubectl get nodes -o wide
    
    # 시스템 Pod 상태 확인
    log_info "시스템 Pod 상태:"
    kubectl get pods -n kube-system
    
    # 네임스페이스 확인
    log_info "네임스페이스:"
    kubectl get namespaces
    
    # 리소스 사용량 확인
    log_info "리소스 사용량:"
    kubectl top nodes 2>/dev/null || log_warning "메트릭 서버가 설치되지 않았습니다."
}

# 정리 함수
cleanup() {
    log_info "정리 중..."
    
    # 체크포인트 파일 삭제
    rm -f "$CHECKPOINT_FILE"
    
    log_success "정리 완료"
}

# 클러스터 삭제 함수
delete_cluster() {
    log_warning "클러스터 삭제를 시작합니다..."
    
    # EKS 클러스터 삭제
    eksctl delete cluster --name "$CLUSTER_NAME" --region "$REGION" --wait
    
    if [ $? -eq 0 ]; then
        log_success "클러스터 삭제 완료"
    else
        log_error "클러스터 삭제 실패"
    fi
    
    # 정리
    cleanup
}

# 메인 함수
main() {
    log_info "=== Cloud Master Day2 - AWS EKS 클러스터 생성 시작 ==="
    
    # 체크포인트 로드
    load_checkpoint
    
    # 환경 체크
    check_environment
    
    # VPC 생성
    create_vpc
    save_checkpoint
    
    # 클러스터 생성
    create_cluster
    save_checkpoint
    
    # 클러스터 연결
    connect_cluster
    save_checkpoint
    
    # 네임스페이스 생성
    create_namespaces
    
    # 기본 리소스 생성
    create_basic_resources
    
    # AWS Load Balancer Controller 설치
    install_aws_load_balancer_controller
    
    # 모니터링 설정
    setup_monitoring
    
    # 클러스터 상태 확인
    check_cluster_status
    
    log_success "=== AWS EKS 클러스터 생성 완료 ==="
    log_info "클러스터 이름: $CLUSTER_NAME"
    log_info "리전: $REGION"
    log_info "노드 수: $NODE_COUNT"
    log_info "노드 타입: $NODE_TYPE"
    log_info "VPC ID: $VPC_ID"
    
    log_info "다음 단계:"
    log_info "1. kubectl get nodes - 클러스터 노드 확인"
    log_info "2. kubectl get namespaces - 네임스페이스 확인"
    log_info "3. kubectl create deployment nginx --image=nginx - 테스트 배포"
    log_info "4. kubectl expose deployment nginx --port=80 --type=LoadBalancer - 서비스 생성"
}

# 스크립트 실행
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    case "${1:-}" in
        "delete")
            delete_cluster
            ;;
        "cleanup")
            cleanup
            ;;
        *)
            main "$@"
            ;;
    esac
fi
