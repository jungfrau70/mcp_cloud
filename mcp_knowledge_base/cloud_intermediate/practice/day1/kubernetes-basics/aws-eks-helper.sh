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
log_header() { echo -e "${PURPLE}=== $1 ===${NC}"; }

# 기본 설정 (환경 변수로 오버라이드 가능)
CLUSTER_NAME="${CLUSTER_NAME:-cloud-intermediate-eks}"
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
        log_info "기존 클러스터를 사용합니다."
        return 0
    fi
    
    # 모든 관련 CloudFormation 스택 확인 및 정리
    local existing_stacks=$(aws cloudformation list-stacks --region $REGION --query 'StackSummaries[?contains(StackName, `'$CLUSTER_NAME'`) && StackStatus!=`DELETE_COMPLETE`].StackName' --output text 2>/dev/null)
    
    if [ -n "$existing_stacks" ]; then
        log_warning "기존 CloudFormation 스택들이 존재합니다:"
        echo "$existing_stacks"
        log_info "기존 스택들을 정리하고 새로 생성하시겠습니까?"
        
        # Force 옵션이 있으면 자동으로 y 선택
        if [ "$FORCE_DELETE" = "true" ]; then
            log_info "Force 옵션으로 자동 삭제 진행..."
            REPLY="y"
        else
            read -p "기존 스택들을 삭제하고 새로 생성하시겠습니까? (y/N): " -n 1 -r
            echo
        fi
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "기존 CloudFormation 스택들 삭제 중 (개선된 로직 사용)..."
            
            # 개선된 클러스터 이름 기반 스택 삭제 사용
            cleanup_all_cluster_stacks
        else
            log_info "기존 스택을 사용합니다."
            return 0
        fi
    fi
    
# EKS 클러스터 생성 (전용 VPC 자동 생성)
log_info "EKS 클러스터 생성 시작 (전용 VPC 자동 생성)..."
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
    --tags "Environment=Learning,Project=CloudIntermediate,Isolation=Isolated" &
    
    local create_pid=$!
    
    # 클러스터 생성 진행 상황 모니터링 (5초마다 갱신)
    log_info "클러스터 생성 진행 상황 모니터링 시작..."
    while kill -0 $create_pid 2>/dev/null; do
        local cluster_status=$(eksctl get cluster --name $CLUSTER_NAME --region $REGION --output json 2>/dev/null | jq -r '.[0].Status // "CREATING"' 2>/dev/null || echo "CREATING")
        
        case "$cluster_status" in
            "CREATING")
                log_info "클러스터 생성 진행 중... (상태: $cluster_status)"
                ;;
            "ACTIVE")
                log_success "클러스터 생성 완료"
                break
                ;;
            "FAILED")
                log_error "클러스터 생성 실패"
                return 1
                ;;
            *)
                log_info "클러스터 상태: $cluster_status"
                ;;
        esac
        
        sleep 5
    done
    
    wait $create_pid
    local create_result=$?
    
    if [ $create_result -eq 0 ]; then
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
    
    # Force 옵션이 있으면 자동으로 y 선택
    if [ "$FORCE_DELETE" != "true" ]; then
        read -p "정말로 클러스터를 삭제하시겠습니까? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "클러스터 삭제를 취소했습니다."
            return 0
        fi
    else
        log_info "Force 옵션으로 자동 삭제 진행..."
    fi
    
    # 클러스터 존재 여부 확인
    if ! eksctl get cluster --name $CLUSTER_NAME --region $REGION &> /dev/null; then
        log_warning "클러스터 $CLUSTER_NAME이 존재하지 않습니다."
        
        # CloudFormation 스택이 있는지 확인
        if aws cloudformation describe-stacks --stack-name "eksctl-$CLUSTER_NAME-cluster" --region $REGION &> /dev/null; then
            log_info "CloudFormation 스택은 존재합니다. 스택 정리를 진행합니다."
            # 스택만 있는 상황에서도 정리 진행
        else
            log_info "클러스터와 스택 모두 존재하지 않습니다."
            return 0
        fi
    fi
    
    # 클러스터 삭제
    log_info "클러스터 삭제 중..."
    local delete_output=$(eksctl delete cluster --name $CLUSTER_NAME --region $REGION 2>&1)
    local delete_result=$?
    
    # 삭제 후 스택 상태 확인
    local stack_status=$(aws cloudformation describe-stacks --stack-name "eksctl-$CLUSTER_NAME-cluster" --region $REGION --query 'Stacks[0].StackStatus' --output text 2>/dev/null)
    
    if [ $delete_result -eq 0 ] && [ "$stack_status" != "DELETE_FAILED" ]; then
        log_success "EKS 클러스터 삭제 완료: $CLUSTER_NAME"
    else
        log_error "EKS 클러스터 삭제 실패"
        
        # 삭제 실패 이유 분석 및 상세 메시지 제공
        log_info "=== 삭제 실패 원인 분석 ==="
        
        # 1. CloudFormation 스택 상태 확인
        local stack_status=$(aws cloudformation describe-stacks --stack-name "eksctl-$CLUSTER_NAME-cluster" --region $REGION --query 'Stacks[0].StackStatus' --output text 2>/dev/null)
        if [ $? -eq 0 ] && [ "$stack_status" != "None" ]; then
            log_warning "CloudFormation 스택 상태: $stack_status"
            
            case "$stack_status" in
                "DELETE_FAILED")
                    log_error "CloudFormation 스택 삭제 실패"
                    log_info "스택 이벤트 확인:"
                    aws cloudformation describe-stack-events --stack-name "eksctl-$CLUSTER_NAME-cluster" --region $REGION --query 'StackEvents[?ResourceStatus==`DELETE_FAILED`].[LogicalResourceId,ResourceStatusReason]' --output table
                    ;;
                "DELETE_IN_PROGRESS")
                    log_warning "CloudFormation 스택이 아직 삭제 진행 중입니다"
                    log_info "삭제 완료까지 기다리거나 수동으로 삭제하세요"
                    ;;
                *)
                    log_warning "예상치 못한 스택 상태: $stack_status"
                    ;;
            esac
        fi
        
        # 2. VPC 의존성 확인
        log_info "VPC 의존성 확인 중..."
        local vpc_id=$(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query 'cluster.resourcesVpcConfig.vpcId' --output text 2>/dev/null)
        if [ $? -eq 0 ] && [ "$vpc_id" != "None" ] && [ -n "$vpc_id" ]; then
            log_info "클러스터 VPC ID: $vpc_id"
            
            # VPC 내 다른 리소스 확인
            local vpc_resources=$(aws ec2 describe-instances --filters "Name=vpc-id,Values=$vpc_id" --query 'Reservations[].Instances[?State.Name!=`terminated`].[InstanceId,State.Name]' --output table 2>/dev/null)
            if [ $? -eq 0 ] && [ -n "$vpc_resources" ]; then
                log_warning "VPC에 다른 EC2 인스턴스가 있습니다:"
                echo "$vpc_resources"
            fi
            
            # VPC 엔드포인트 확인
            local vpc_endpoints=$(aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=$vpc_id" --query 'VpcEndpoints[?State!=`deleted`].[VpcEndpointId,State]' --output table 2>/dev/null)
            if [ $? -eq 0 ] && [ -n "$vpc_endpoints" ]; then
                log_warning "VPC에 엔드포인트가 있습니다:"
                echo "$vpc_endpoints"
            fi
            
            # NAT Gateway 확인
            local nat_gateways=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$vpc_id" --query 'NatGateways[?State!=`deleted`].[NatGatewayId,State]' --output table 2>/dev/null)
            if [ $? -eq 0 ] && [ -n "$nat_gateways" ]; then
                log_warning "VPC에 NAT Gateway가 있습니다:"
                echo "$nat_gateways"
            fi
        fi
        
        # 3. IAM 역할 의존성 확인
        log_info "IAM 역할 의존성 확인 중..."
        local nodegroup_roles=$(aws eks describe-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name standard-workers --region $REGION --query 'nodegroup.nodeRole' --output text 2>/dev/null)
        if [ $? -eq 0 ] && [ "$nodegroup_roles" != "None" ] && [ -n "$nodegroup_roles" ]; then
            log_info "노드그룹 IAM 역할: $nodegroup_roles"
            
            # IAM 역할이 다른 리소스에서 사용 중인지 확인
            local role_usage=$(aws iam get-role --role-name $(echo $nodegroup_roles | cut -d'/' -f2) --query 'Role.AssumeRolePolicyDocument' 2>/dev/null)
            if [ $? -eq 0 ]; then
                log_info "IAM 역할 사용 정책 확인됨"
            fi
        fi
        
            # 4. 자동 리소스 정리 시도 (완전한 삭제 순서)
            log_info "=== 자동 리소스 정리 시도 (완전한 삭제 순서) ==="
            
            # 4-1. 노드그룹 스택 삭제
            log_info "노드그룹 스택 삭제 중..."
            local nodegroup_stacks=$(aws cloudformation list-stacks --region $REGION --query 'StackSummaries[?contains(StackName, `'$CLUSTER_NAME'`) && contains(StackName, `nodegroup`)].StackName' --output text 2>/dev/null)
            if [ -n "$nodegroup_stacks" ]; then
                for stack_name in $nodegroup_stacks; do
                    log_info "노드그룹 스택 삭제 중: $stack_name"
                    aws cloudformation delete-stack --stack-name $stack_name --region $REGION
                done
                
                # 노드그룹 스택 삭제 완료 대기
                log_info "노드그룹 스택 삭제 완료 대기 중..."
                for stack_name in $nodegroup_stacks; do
                    local delete_timeout=300  # 5분 타임아웃
                    local elapsed_time=0
                    
                    while [ $elapsed_time -lt $delete_timeout ]; do
                        if ! aws cloudformation describe-stacks --stack-name $stack_name --region $REGION &> /dev/null; then
                            log_success "노드그룹 스택 $stack_name 삭제 완료"
                            break
                        fi
                        
                        local stack_status=$(aws cloudformation describe-stacks --stack-name $stack_name --region $REGION --query 'Stacks[0].StackStatus' --output text 2>/dev/null)
                        log_info "노드그룹 스택 $stack_name 삭제 진행 중... (상태: $stack_status, 경과시간: ${elapsed_time}초)"
                        
                        sleep 10
                        elapsed_time=$((elapsed_time + 10))
                    done
                    
                    if [ $elapsed_time -ge $delete_timeout ]; then
                        log_warning "노드그룹 스택 $stack_name 삭제 타임아웃"
                    fi
                done
            fi
            
            # 4-2. 애드온 스택 삭제
            log_info "애드온 스택 삭제 중..."
            local addon_stacks=$(aws cloudformation list-stacks --region $REGION --query 'StackSummaries[?contains(StackName, `'$CLUSTER_NAME'`) && contains(StackName, `addon`)].StackName' --output text 2>/dev/null)
            if [ -n "$addon_stacks" ]; then
                for stack_name in $addon_stacks; do
                    log_info "애드온 스택 삭제 중: $stack_name"
                    aws cloudformation delete-stack --stack-name $stack_name --region $REGION
                done
                
                # 애드온 스택 삭제 완료 대기
                log_info "애드온 스택 삭제 완료 대기 중..."
                for stack_name in $addon_stacks; do
                    local delete_timeout=300  # 5분 타임아웃
                    local elapsed_time=0
                    
                    while [ $elapsed_time -lt $delete_timeout ]; do
                        if ! aws cloudformation describe-stacks --stack-name $stack_name --region $REGION &> /dev/null; then
                            log_success "애드온 스택 $stack_name 삭제 완료"
                            break
                        fi
                        
                        local stack_status=$(aws cloudformation describe-stacks --stack-name $stack_name --region $REGION --query 'Stacks[0].StackStatus' --output text 2>/dev/null)
                        log_info "애드온 스택 $stack_name 삭제 진행 중... (상태: $stack_status, 경과시간: ${elapsed_time}초)"
                        
                        sleep 10
                        elapsed_time=$((elapsed_time + 10))
                    done
                    
                    if [ $elapsed_time -ge $delete_timeout ]; then
                        log_warning "애드온 스택 $stack_name 삭제 타임아웃"
                    fi
                done
            fi
            
            if [ -n "$vpc_id" ] && [ "$vpc_id" != "None" ]; then
                log_info "VPC 리소스 정리 시작: $vpc_id"
            
            # 1. Load Balancer 삭제 (가장 먼저)
            log_info "Load Balancer 삭제 중..."
            local elb_v2_arns=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[?VpcId==`'$vpc_id'`].LoadBalancerArn' --output text 2>/dev/null)
            if [ -n "$elb_v2_arns" ]; then
                for lb_arn in $elb_v2_arns; do
                    log_info "Application/Network Load Balancer 삭제 중: $lb_arn"
                    aws elbv2 delete-load-balancer --load-balancer-arn $lb_arn
                done
            fi
            
            local elb_names=$(aws elb describe-load-balancers --query 'LoadBalancerDescriptions[?VPCId==`'$vpc_id'`].LoadBalancerName' --output text 2>/dev/null)
            if [ -n "$elb_names" ]; then
                for lb_name in $elb_names; do
                    log_info "Classic Load Balancer 삭제 중: $lb_name"
                    aws elb delete-load-balancer --load-balancer-name $lb_name
                done
            fi
            
            # 2. Target Group 삭제
            log_info "Target Group 삭제 중..."
            local target_groups=$(aws elbv2 describe-target-groups --query 'TargetGroups[?VpcId==`'$vpc_id'`].TargetGroupArn' --output text 2>/dev/null)
            if [ -n "$target_groups" ]; then
                for tg_arn in $target_groups; do
                    log_info "Target Group 삭제 중: $tg_arn"
                    aws elbv2 delete-target-group --target-group-arn $tg_arn
                done
            fi
            
            # 3. Auto Scaling Group 삭제
            log_info "Auto Scaling Group 삭제 중..."
            local asg_names=$(aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[?VPCZoneIdentifier!=null].AutoScalingGroupName' --output text 2>/dev/null)
            if [ -n "$asg_names" ]; then
                for asg_name in $asg_names; do
                    log_info "Auto Scaling Group 삭제 중: $asg_name"
                    aws autoscaling delete-auto-scaling-group --auto-scaling-group-name $asg_name --force-delete
                done
            fi
            
            # 4. Launch Template 삭제
            log_info "Launch Template 삭제 중..."
            local launch_templates=$(aws ec2 describe-launch-templates --query 'LaunchTemplates[?contains(Tags[?Key==`Name`].Value, `'$CLUSTER_NAME'`)].LaunchTemplateId' --output text 2>/dev/null)
            if [ -n "$launch_templates" ]; then
                for lt_id in $launch_templates; do
                    log_info "Launch Template 삭제 중: $lt_id"
                    aws ec2 delete-launch-template --launch-template-id $lt_id
                done
            fi
            
            # 5. EC2 인스턴스 삭제
            log_info "EC2 인스턴스 삭제 중..."
            local instance_ids=$(aws ec2 describe-instances --filters "Name=vpc-id,Values=$vpc_id" "Name=instance-state-name,Values=running,pending,stopping,stopped" --query 'Reservations[].Instances[].InstanceId' --output text 2>/dev/null)
            if [ -n "$instance_ids" ]; then
                for instance_id in $instance_ids; do
                    log_info "EC2 인스턴스 삭제 중: $instance_id"
                    aws ec2 terminate-instances --instance-ids $instance_id
                done
                
                # 인스턴스 삭제 완료 대기
                log_info "EC2 인스턴스 삭제 완료 대기 중..."
                for instance_id in $instance_ids; do
                    while aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].State.Name' --output text 2>/dev/null | grep -q "terminated"; do
                        sleep 10
                        log_info "EC2 인스턴스 $instance_id 삭제 중..."
                    done
                done
            fi
            
            # 6. VPC 엔드포인트 삭제
            log_info "VPC 엔드포인트 삭제 중..."
            local vpc_endpoint_ids=$(aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=$vpc_id" --query 'VpcEndpoints[?State!=`deleted`].VpcEndpointId' --output text 2>/dev/null)
            if [ -n "$vpc_endpoint_ids" ]; then
                for endpoint_id in $vpc_endpoint_ids; do
                    log_info "VPC 엔드포인트 삭제 중: $endpoint_id"
                    aws ec2 delete-vpc-endpoint --vpc-endpoint-id $endpoint_id
                done
            fi
            
            # 7. NAT Gateway 삭제
            log_info "NAT Gateway 삭제 중..."
            local nat_gateway_ids=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$vpc_id" --query 'NatGateways[?State!=`deleted`].NatGatewayId' --output text 2>/dev/null)
            if [ -n "$nat_gateway_ids" ]; then
                for nat_id in $nat_gateway_ids; do
                    log_info "NAT Gateway 삭제 중: $nat_id"
                    aws ec2 delete-nat-gateway --nat-gateway-id $nat_id
                done
                
                # NAT Gateway 삭제 완료 대기
                log_info "NAT Gateway 삭제 완료 대기 중..."
                for nat_id in $nat_gateway_ids; do
                    while aws ec2 describe-nat-gateways --nat-gateway-ids $nat_id --query 'NatGateways[0].State' --output text 2>/dev/null | grep -q "deleting"; do
                        sleep 10
                        log_info "NAT Gateway $nat_id 삭제 중..."
                    done
                done
            fi
            
            # 8. Elastic IP 삭제
            log_info "Elastic IP 삭제 중..."
            local eip_allocation_ids=$(aws ec2 describe-addresses --filters "Name=domain,Values=vpc" --query 'Addresses[?AssociationId==null].AllocationId' --output text 2>/dev/null)
            if [ -n "$eip_allocation_ids" ]; then
                for eip_id in $eip_allocation_ids; do
                    log_info "Elastic IP 삭제 중: $eip_id"
                    aws ec2 release-address --allocation-id $eip_id
                done
            fi
            
            # 9. 보안 그룹 삭제 (기본 보안 그룹 제외)
            log_info "보안 그룹 삭제 중..."
            local security_group_ids=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpc_id" --query 'SecurityGroups[?GroupName!=`default`].GroupId' --output text 2>/dev/null)
            if [ -n "$security_group_ids" ]; then
                for sg_id in $security_group_ids; do
                    log_info "보안 그룹 삭제 중: $sg_id"
                    aws ec2 delete-security-group --group-id $sg_id
                done
            fi
            
            # 10. 라우트 테이블 삭제 (메인 라우트 테이블 제외)
            log_info "라우트 테이블 삭제 중..."
            local route_table_ids=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$vpc_id" --query 'RouteTables[?Associations[0].Main!=`true`].RouteTableId' --output text 2>/dev/null)
            if [ -n "$route_table_ids" ]; then
                for rt_id in $route_table_ids; do
                    log_info "라우트 테이블 삭제 중: $rt_id"
                    aws ec2 delete-route-table --route-table-id $rt_id
                done
            fi
            
            # 11. 서브넷 삭제
            log_info "서브넷 삭제 중..."
            local subnet_ids=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id" --query 'Subnets[].SubnetId' --output text 2>/dev/null)
            if [ -n "$subnet_ids" ]; then
                for subnet_id in $subnet_ids; do
                    log_info "서브넷 삭제 중: $subnet_id"
                    aws ec2 delete-subnet --subnet-id $subnet_id
                done
            fi
            
            # 12. 인터넷 게이트웨이 분리 및 삭제
            log_info "인터넷 게이트웨이 분리 및 삭제 중..."
            local igw_id=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$vpc_id" --query 'InternetGateways[0].InternetGatewayId' --output text 2>/dev/null)
            if [ -n "$igw_id" ] && [ "$igw_id" != "None" ]; then
                log_info "인터넷 게이트웨이 분리 중: $igw_id"
                aws ec2 detach-internet-gateway --internet-gateway-id $igw_id --vpc-id $vpc_id
                log_info "인터넷 게이트웨이 삭제 중: $igw_id"
                aws ec2 delete-internet-gateway --internet-gateway-id $igw_id
            fi
            
            # 13. VPC 삭제 (마지막)
            log_info "VPC 삭제 중..."
            aws ec2 delete-vpc --vpc-id $vpc_id
            if [ $? -eq 0 ]; then
                log_success "VPC $vpc_id 삭제 완료"
            else
                log_warning "VPC 삭제 실패 - 다른 리소스가 여전히 연결되어 있을 수 있습니다"
            fi
        fi
        
        # 5. 지능형 재삭제 시도
        log_info "=== 지능형 재삭제 시도 ==="
        
        # CloudFormation 스택 재삭제 시도
        log_info "CloudFormation 스택 재삭제 시도..."
        local stack_delete_output=$(aws cloudformation delete-stack --stack-name "eksctl-$CLUSTER_NAME-cluster" --region $REGION 2>&1)
        
        # 삭제 실패 시 메시지 분석 및 대응
        if echo "$stack_delete_output" | grep -q "DELETE_FAILED\|DELETE_IN_PROGRESS"; then
            log_warning "CloudFormation 스택 삭제에 문제가 있습니다. 메시지 분석 중..."
            
            # 실패 원인별 대응
            if echo "$stack_delete_output" | grep -q "DELETE_FAILED"; then
                log_info "스택 삭제 실패 - 실패한 리소스 분석 중..."
                
                # 실패한 리소스 이벤트 분석
                local failed_events=$(aws cloudformation describe-stack-events --stack-name "eksctl-$CLUSTER_NAME-cluster" --region $REGION --query 'StackEvents[?ResourceStatus==`DELETE_FAILED`].[LogicalResourceId,ResourceStatusReason]' --output text 2>/dev/null)
                
                if [ -n "$failed_events" ]; then
                    log_info "실패한 리소스들:"
                    echo "$failed_events"
                    
                    # 실패 원인별 자동 대응
                    while IFS=$'\t' read -r resource_id reason; do
                        log_info "리소스 $resource_id 실패 원인: $reason"
                        
                        # NAT Gateway 관련 실패
                        if echo "$reason" | grep -q "NAT Gateway"; then
                            log_info "NAT Gateway 의존성 문제 해결 시도..."
                            # NAT Gateway 강제 삭제
                            local nat_ids=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$vpc_id" --query 'NatGateways[?State!=`deleted`].NatGatewayId' --output text 2>/dev/null)
                            for nat_id in $nat_ids; do
                                aws ec2 delete-nat-gateway --nat-gateway-id $nat_id
                                log_info "NAT Gateway $nat_id 강제 삭제 시도"
                            done
                        fi
                        
                        # VPC 관련 실패
                        if echo "$reason" | grep -q "VPC\|Subnet"; then
                            log_info "VPC 의존성 문제 해결 시도..."
                            # VPC 내 모든 리소스 강제 정리
                            local remaining_resources=$(aws ec2 describe-instances --filters "Name=vpc-id,Values=$vpc_id" --query 'Reservations[].Instances[?State.Name!=`terminated`].InstanceId' --output text 2>/dev/null)
                            if [ -n "$remaining_resources" ]; then
                                for instance_id in $remaining_resources; do
                                    aws ec2 terminate-instances --instance-ids $instance_id --force
                                    log_info "EC2 인스턴스 $instance_id 강제 종료"
                                done
                            fi
                        fi
                        
                        # IAM 관련 실패
                        if echo "$reason" | grep -q "IAM\|Role"; then
                            log_info "IAM 의존성 문제 해결 시도..."
                            # IAM 역할 정리
                            local roles=$(aws iam list-roles --query 'Roles[?contains(RoleName, `'$CLUSTER_NAME'`)].RoleName' --output text 2>/dev/null)
                            for role in $roles; do
                                # 정책 분리
                                local policies=$(aws iam list-attached-role-policies --role-name $role --query 'AttachedPolicies[].PolicyArn' --output text 2>/dev/null)
                                for policy in $policies; do
                                    aws iam detach-role-policy --role-name $role --policy-arn $policy
                                    log_info "IAM 역할 $role에서 정책 $policy 분리"
                                done
                                # 역할 삭제
                                aws iam delete-role --role-name $role
                                log_info "IAM 역할 $role 삭제"
                            done
                        fi
                        
                    done <<< "$failed_events"
                fi
            fi
            
            # 스택 재삭제 시도
            log_info "리소스 정리 후 스택 재삭제 시도..."
            aws cloudformation delete-stack --stack-name "eksctl-$CLUSTER_NAME-cluster" --region $REGION
            
            # 삭제 완료 대기 (최대 10분) - Stuck 리소스 자동 점검
            local delete_timeout=600
            local elapsed_time=0
            local stuck_check_interval=30  # 30초마다 stuck 리소스 점검
            
            while [ $elapsed_time -lt $delete_timeout ]; do
                if ! aws cloudformation describe-stacks --stack-name "eksctl-$CLUSTER_NAME-cluster" --region $REGION &> /dev/null; then
                    log_success "CloudFormation 스택 삭제 완료"
                    break
                fi
                
                local current_status=$(aws cloudformation describe-stacks --stack-name "eksctl-$CLUSTER_NAME-cluster" --region $REGION --query 'Stacks[0].StackStatus' --output text 2>/dev/null)
                log_info "스택 삭제 진행 중... (상태: $current_status, 경과시간: ${elapsed_time}초)"
                
                # DELETE_IN_PROGRESS 상태에서 stuck 리소스 점검
                if [ "$current_status" = "DELETE_IN_PROGRESS" ] && [ $((elapsed_time % stuck_check_interval)) -eq 0 ]; then
                    log_info "=== Stuck 리소스 점검 및 자동 조치 ==="
                    
                    # 1. VPC 의존성 점검
                    local vpc_id=$(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query 'cluster.resourcesVpcConfig.vpcId' --output text 2>/dev/null)
                    if [ $? -eq 0 ] && [ "$vpc_id" != "None" ] && [ -n "$vpc_id" ]; then
                        log_info "VPC 의존성 점검 중: $vpc_id"
                        
                        # NAT Gateway stuck 점검
                        local stuck_nat=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$vpc_id" --query 'NatGateways[?State==`deleting`].[NatGatewayId,State]' --output text 2>/dev/null)
                        if [ -n "$stuck_nat" ]; then
                            log_warning "Stuck NAT Gateway 발견:"
                            echo "$stuck_nat"
                            log_info "NAT Gateway 강제 삭제 시도..."
                            echo "$stuck_nat" | while read nat_id state; do
                                aws ec2 delete-nat-gateway --nat-gateway-id $nat_id
                                log_info "NAT Gateway $nat_id 재삭제 요청"
                            done
                        fi
                        
                        # Elastic IP stuck 점검
                        local stuck_eip=$(aws ec2 describe-addresses --filters "Name=domain,Values=vpc" --query 'Addresses[?AssociationId==null && State==`available`].[AllocationId,State]' --output text 2>/dev/null)
                        if [ -n "$stuck_eip" ]; then
                            log_warning "Stuck Elastic IP 발견:"
                            echo "$stuck_eip"
                            log_info "Elastic IP 강제 해제 시도..."
                            echo "$stuck_eip" | while read eip_id state; do
                                aws ec2 release-address --allocation-id $eip_id
                                log_info "Elastic IP $eip_id 해제"
                            done
                        fi
                        
                        # VPC Endpoint stuck 점검
                        local stuck_endpoints=$(aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=$vpc_id" --query 'VpcEndpoints[?State==`deleting`].[VpcEndpointId,State]' --output text 2>/dev/null)
                        if [ -n "$stuck_endpoints" ]; then
                            log_warning "Stuck VPC Endpoint 발견:"
                            echo "$stuck_endpoints"
                            log_info "VPC Endpoint 강제 삭제 시도..."
                            echo "$stuck_endpoints" | while read endpoint_id state; do
                                aws ec2 delete-vpc-endpoint --vpc-endpoint-id $endpoint_id
                                log_info "VPC Endpoint $endpoint_id 재삭제 요청"
                            done
                        fi
                        
                        # EC2 인스턴스 stuck 점검
                        local stuck_instances=$(aws ec2 describe-instances --filters "Name=vpc-id,Values=$vpc_id" "Name=instance-state-name,Values=shutting-down" --query 'Reservations[].Instances[].InstanceId' --output text 2>/dev/null)
                        if [ -n "$stuck_instances" ]; then
                            log_warning "Stuck EC2 인스턴스 발견:"
                            echo "$stuck_instances"
                            log_info "EC2 인스턴스 강제 종료 시도..."
                            echo "$stuck_instances" | while read instance_id; do
                                aws ec2 terminate-instances --instance-ids $instance_id --force
                                log_info "EC2 인스턴스 $instance_id 강제 종료"
                            done
                        fi
                        
                        # 보안 그룹 의존성 점검
                        local stuck_sg=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpc_id" --query 'SecurityGroups[?GroupName!=`default`].[GroupId,GroupName]' --output text 2>/dev/null)
                        if [ -n "$stuck_sg" ]; then
                            log_warning "남은 보안 그룹 발견:"
                            echo "$stuck_sg"
                            log_info "보안 그룹 강제 삭제 시도..."
                            echo "$stuck_sg" | while read sg_id sg_name; do
                                aws ec2 delete-security-group --group-id $sg_id
                                log_info "보안 그룹 $sg_id ($sg_name) 삭제"
                            done
                        fi
                        
                        # 서브넷 의존성 점검
                        local stuck_subnets=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id" --query 'Subnets[].SubnetId' --output text 2>/dev/null)
                        if [ -n "$stuck_subnets" ]; then
                            log_warning "남은 서브넷 발견:"
                            echo "$stuck_subnets"
                            log_info "서브넷 강제 삭제 시도..."
                            echo "$stuck_subnets" | while read subnet_id; do
                                aws ec2 delete-subnet --subnet-id $subnet_id
                                log_info "서브넷 $subnet_id 삭제"
                            done
                        fi
                    fi
                    
                    # 2. CloudFormation 이벤트 점검
                    log_info "CloudFormation 이벤트 점검 중..."
                    local failed_events=$(aws cloudformation describe-stack-events --stack-name "eksctl-$CLUSTER_NAME-cluster" --region $REGION --query 'StackEvents[?ResourceStatus==`DELETE_FAILED`].[LogicalResourceId,ResourceStatusReason]' --output text 2>/dev/null)
                    if [ -n "$failed_events" ]; then
                        log_warning "삭제 실패한 리소스 발견:"
                        echo "$failed_events"
                        
                        # 실패한 리소스별 맞춤 조치
                        echo "$failed_events" | while IFS=$'\t' read -r resource_id reason; do
                            log_info "리소스 $resource_id 실패 원인: $reason"
                            
                            # VPC 관련 실패 시 강제 정리
                            if echo "$reason" | grep -q "VPC\|Subnet\|SecurityGroup"; then
                                log_info "VPC 관련 리소스 강제 정리 시도..."
                                # VPC 내 모든 리소스 강제 정리 로직 실행
                            fi
                            
                            # NAT Gateway 관련 실패 시 강제 삭제
                            if echo "$reason" | grep -q "NAT Gateway"; then
                                log_info "NAT Gateway 강제 삭제 시도..."
                                # NAT Gateway 강제 삭제 로직 실행
                            fi
                        done
                    fi
                    
        # 3. 클러스터 이름 기반 모든 스택 삭제 시도
        log_info "클러스터 이름 기반 모든 스택 삭제 시도..."
        cleanup_all_cluster_stacks
                    aws cloudformation delete-stack --stack-name "eksctl-$CLUSTER_NAME-cluster" --region $REGION
                fi
                
                sleep 10
                elapsed_time=$((elapsed_time + 10))
            done
            
            if [ $elapsed_time -ge $delete_timeout ]; then
                log_warning "스택 삭제 타임아웃. 수동 개입이 필요할 수 있습니다."
            fi
        fi
        
        # 6. 최종 클러스터 삭제 시도
        log_info "=== 최종 클러스터 삭제 시도 ==="
        local final_delete_output=$(eksctl delete cluster --name $CLUSTER_NAME --region $REGION --force 2>&1)
        local final_delete_result=$?
        
        if [ $final_delete_result -eq 0 ]; then
            log_success "EKS 클러스터 최종 삭제 완료: $CLUSTER_NAME"
            return 0
        else
            log_error "최종 클러스터 삭제도 실패했습니다."
            log_info "삭제 출력: $final_delete_output"
            
            # 7. 수동 삭제 가이드 제공
            log_info "=== 수동 삭제 가이드 (자동 정리 실패 시) ==="
            log_info "1. CloudFormation 스택 수동 삭제:"
            log_info "   aws cloudformation delete-stack --stack-name eksctl-$CLUSTER_NAME-cluster --region $REGION"
            log_info ""
            log_info "2. VPC 수동 삭제 (다른 리소스가 없는 경우):"
            log_info "   aws ec2 delete-vpc --vpc-id $vpc_id"
            log_info ""
            log_info "3. IAM 역할 수동 삭제:"
            log_info "   aws iam detach-role-policy --role-name <role-name> --policy-arn <policy-arn>"
            log_info "   aws iam delete-role --role-name <role-name>"
            log_info ""
            log_info "4. 전체 리소스 정리 후 클러스터 재삭제:"
            log_info "   eksctl delete cluster --name $CLUSTER_NAME --region $REGION --force"
            
            return 1
        fi
    fi
}

# 클러스터 이름 기반 모든 스택 삭제
cleanup_all_cluster_stacks() {
    log_info "클러스터 이름 기반 모든 스택 삭제: $CLUSTER_NAME"
    
    # 클러스터 이름이 포함된 모든 스택 찾기 (생성 시간 순으로 정렬)
    local related_stacks=$(aws cloudformation list-stacks --region $REGION --query 'StackSummaries[?contains(StackName, `'$CLUSTER_NAME'`) && StackStatus != `DELETE_COMPLETE`].[StackName,StackStatus,CreationTime]' --output text 2>/dev/null)
    
    if [ -z "$related_stacks" ]; then
        log_info "삭제할 관련 스택이 없습니다."
        return 0
    fi
    
    log_info "발견된 관련 스택들 (생성 시간 순):"
    echo "$related_stacks" | sort -k3 -r | while IFS=$'\t' read -r stack_name stack_status creation_time; do
        log_info "  - $stack_name ($stack_status) - 생성: $creation_time"
    done
    
    # 생성 시간 역순으로 삭제 (가장 나중에 생성된 것부터)
    echo "$related_stacks" | sort -k3 -r | while IFS=$'\t' read -r stack_name stack_status creation_time; do
        if [ -n "$stack_name" ]; then
            log_info "스택 삭제: $stack_name (현재 상태: $stack_status, 생성: $creation_time)"
            
            # 이미 삭제 중인 스택은 대기
            if [ "$stack_status" = "DELETE_IN_PROGRESS" ]; then
                log_info "스택 $stack_name이 이미 삭제 진행 중입니다. 완료 대기..."
                wait_for_stack_deletion "$stack_name"
            else
                # 스택 삭제 시도
                aws cloudformation delete-stack --stack-name "$stack_name" --region $REGION
                wait_for_stack_deletion "$stack_name"
            fi
        fi
    done
}

# 스택 삭제 완료 대기
wait_for_stack_deletion() {
    local stack_name="$1"
    local timeout=600  # 10분
    local elapsed=0
    
    log_info "스택 $stack_name 삭제 완료 대기 중..."
    
    while [ $elapsed -lt $timeout ]; do
        if ! aws cloudformation describe-stacks --stack-name "$stack_name" --region $REGION &> /dev/null; then
            log_success "스택 $stack_name 삭제 완료"
            return 0
        fi
        
        # 현재 스택 상태 확인
        local current_status=$(aws cloudformation describe-stacks --stack-name "$stack_name" --region $REGION --query 'Stacks[0].StackStatus' --output text 2>/dev/null)
        
        if [ "$current_status" = "DELETE_FAILED" ]; then
            log_warning "스택 $stack_name 삭제 실패"
            return 1
        fi
        
        sleep 15
        elapsed=$((elapsed + 15))
        log_info "스택 $stack_name 삭제 대기 중... (${elapsed}초 경과, 상태: $current_status)"
    done
    
    log_warning "스택 $stack_name 삭제 타임아웃"
    return 1
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
        log_warning "EKS 클러스터 '$CLUSTER_NAME'을 찾을 수 없습니다."
        log_info "사용 가능한 클러스터 목록:"
        local existing_clusters=$(aws eks list-clusters --region $REGION --query 'clusters[]' --output text 2>/dev/null)
        if [ -n "$existing_clusters" ]; then
            aws eks list-clusters --region $REGION --query 'clusters[]' --output table
        else
            log_warning "현재 리전($REGION)에 EKS 클러스터가 없습니다."
        fi
        
        echo ""
        log_info "클러스터를 생성하려면 '1. EKS 클러스터 생성'을 선택하세요."
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
    echo "옵션:"
    echo "  --force                      # 자동으로 기존 리소스 삭제 (y/N 질문 건너뛰기)"
    echo ""
    echo "예시:"
    echo "  $0                           # Interactive 모드"
    echo "  $0 --action create           # EKS 클러스터 생성"
    echo "  $0 --action create --force   # 자동 삭제 후 클러스터 생성"
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
    # Force 옵션 초기화
    FORCE_DELETE="false"
    
    # Force 옵션 확인
    for arg in "$@"; do
        if [ "$arg" = "--force" ]; then
            FORCE_DELETE="true"
            break
        fi
    done
    
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
