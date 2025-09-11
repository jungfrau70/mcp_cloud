#!/bin/bash
# AWS ECS Fargate 실습 스크립트

set -e

echo "AWS ECS Fargate 실습 시작..."

# AWS CLI 설정 확인
if ! command -v aws &> /dev/null; then
    echo "ERROR: AWS CLI가 설치되지 않았습니다."
    exit 1
fi

# AWS 리전 설정
if [ -z "$AWS_REGION" ]; then
    export AWS_REGION="us-west-2"
fi

# ECS 클러스터 생성
echo "ECS 클러스터 생성 중..."
aws ecs create-cluster     --cluster-name container-course-cluster     --capacity-providers FARGATE FARGATE_SPOT     --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1

# 태스크 정의 생성
cat > task-definition.json << 'EOF'
{
  "family": "container-course-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::ACCOUNT_ID:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "nginx",
      "image": "nginx:1.21",
      "portMappings": [
        {
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/container-course",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
EOF

# CloudWatch 로그 그룹 생성
aws logs create-log-group     --log-group-name /ecs/container-course     --region $AWS_REGION

# 태스크 정의 등록
echo "태스크 정의 등록 중..."
aws ecs register-task-definition     --cli-input-json file://task-definition.json

# VPC 및 서브넷 생성
echo "VPC 및 서브넷 생성 중..."
VPC_ID=$(aws ec2 create-vpc     --cidr-block 10.0.0.0/16     --query 'Vpc.VpcId'     --output text)

aws ec2 create-tags     --resources $VPC_ID     --tags Key=Name,Value=container-course-vpc

# 인터넷 게이트웨이 생성
IGW_ID=$(aws ec2 create-internet-gateway     --query 'InternetGateway.InternetGatewayId'     --output text)

aws ec2 attach-internet-gateway     --vpc-id $VPC_ID     --internet-gateway-id $IGW_ID

# 서브넷 생성
SUBNET_ID=$(aws ec2 create-subnet     --vpc-id $VPC_ID     --cidr-block 10.0.1.0/24     --availability-zone ${AWS_REGION}a     --query 'Subnet.SubnetId'     --output text)

# 라우트 테이블 생성
ROUTE_TABLE_ID=$(aws ec2 create-route-table     --vpc-id $VPC_ID     --query 'RouteTable.RouteTableId'     --output text)

# 기본 라우트 추가
aws ec2 create-route     --route-table-id $ROUTE_TABLE_ID     --destination-cidr-block 0.0.0.0/0     --gateway-id $IGW_ID

# 서브넷과 라우트 테이블 연결
aws ec2 associate-route-table     --subnet-id $SUBNET_ID     --route-table-id $ROUTE_TABLE_ID

# 보안 그룹 생성
SECURITY_GROUP_ID=$(aws ec2 create-security-group     --group-name container-course-sg     --description "Security group for container course"     --vpc-id $VPC_ID     --query 'GroupId'     --output text)

# 보안 그룹 규칙 설정
aws ec2 authorize-security-group-ingress     --group-id $SECURITY_GROUP_ID     --protocol tcp     --port 80     --cidr 0.0.0.0/0

# ECS 서비스 생성
echo "ECS 서비스 생성 중..."
aws ecs create-service     --cluster container-course-cluster     --service-name container-course-service     --task-definition container-course-task     --desired-count 2     --launch-type FARGATE     --network-configuration "awsvpcConfiguration={subnets=[$SUBNET_ID],securityGroups=[$SECURITY_GROUP_ID],assignPublicIp=ENABLED}"

# 서비스 상태 확인
echo "서비스 상태 확인 중..."
aws ecs describe-services     --cluster container-course-cluster     --services container-course-service

# 태스크 목록 확인
echo "태스크 목록:"
aws ecs list-tasks     --cluster container-course-cluster     --service-name container-course-service

# 자동 스케일링 설정
cat > auto-scaling-policy.json << 'EOF'
{
  "serviceNamespace": "ecs",
  "resourceId": "service/container-course-cluster/container-course-service",
  "scalableDimension": "ecs:service:DesiredCount",
  "minCapacity": 1,
  "maxCapacity": 10,
  "roleARN": "arn:aws:iam::ACCOUNT_ID:role/application-autoscaling-ecs-targets-role",
  "scheduledActions": [],
  "targetTrackingScalingPolicies": [
    {
      "targetId": "container-course-target",
      "policyName": "container-course-policy",
      "policyType": "TargetTrackingScaling",
      "targetTrackingScalingPolicyConfiguration": {
        "targetValue": 70.0,
        "predefinedMetricSpecification": {
          "predefinedMetricType": "ECSServiceAverageCPUUtilization"
        },
        "scaleOutCooldown": 300,
        "scaleInCooldown": 300
      }
    }
  ]
}
EOF

# 자동 스케일링 정책 등록
aws application-autoscaling register-scalable-target     --service-namespace ecs     --resource-id service/container-course-cluster/container-course-service     --scalable-dimension ecs:service:DesiredCount     --min-capacity 1     --max-capacity 10

# 정리 (선택사항)
read -p "ECS 리소스를 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "ECS 리소스 삭제 중..."
    aws ecs update-service         --cluster container-course-cluster         --service container-course-service         --desired-count 0
    
    aws ecs delete-service         --cluster container-course-cluster         --service container-course-service
    
    aws ecs delete-cluster         --cluster container-course-cluster
fi

echo "AWS ECS Fargate 실습 완료!"
