#!/usr/bin/env python3
"""
Container 과정 자동화 시스템
Kubernetes, ECS, Fargate, 고가용성 아키텍처 실습 스크립트 자동 생성
"""

import os
import json
import logging
import subprocess
import tempfile
import shutil
from pathlib import Path
from dataclasses import dataclass
from typing import List, Dict, Any
import yaml

# 로깅 설정
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('container_course_automation.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

@dataclass
class CourseConfig:
    """Container 과정 설정"""
    course_name: str = "Cloud Container Course"
    duration_days: int = 2
    daily_hours: int = 7
    start_time: str = "09:00"
    end_time: str = "17:00"
    cloud_providers: List[str] = None
    required_tools: List[str] = None
    
    def __post_init__(self):
        if self.cloud_providers is None:
            self.cloud_providers = ["aws", "gcp"]
        if self.required_tools is None:
            self.required_tools = [
                "docker", "git", "github-cli", "aws-cli", "gcloud-cli", "kubectl", "helm"
            ]

@dataclass
class DayPlan:
    """일일 계획"""
    day: int
    title: str
    topics: List[str]
    duration: str
    objectives: List[str]

class ContainerCourseAutomation:
    """Container 과정 자동화 클래스"""
    
    def __init__(self, config: CourseConfig = None):
        self.config = config or CourseConfig()
        self.project_root = Path(__file__).parent.parent.parent.parent
        self.course_dir = self.project_root / "mcp_knowledge_base" / "cloud_container"
        self.scripts_dir = self.project_root / "mcp_knowledge_base" / "cloud_container" / "automation_tests"
        self.results = {}
        
    def setup_environment(self) -> bool:
        """환경 설정 및 도구 검증"""
        logger.info("환경 설정 시작...")
        
        try:
            # 필수 도구 확인
            missing_tools = self._check_required_tools()
            if missing_tools:
                logger.warning(f"누락된 도구: {missing_tools}")
                logger.info("일부 도구가 누락되었지만 계속 진행합니다...")
            
            # 디렉토리 생성
            self._create_directories()
            
            # 환경 변수 설정
            self._setup_environment_variables()
            
            logger.info("환경 설정 완료")
            return True
            
        except Exception as e:
            logger.error(f"환경 설정 실패: {e}")
            return False
    
    def _check_required_tools(self) -> List[str]:
        """필수 도구 검증"""
        missing_tools = []
        
        # 필수 도구 검증
        for tool in self.config.required_tools:
            try:
                if tool == "github-cli":
                    result = subprocess.run(["gh", "--version"], 
                                          capture_output=True, text=True, check=True)
                elif tool == "aws-cli":
                    result = subprocess.run(["aws", "--version"], 
                                          capture_output=True, text=True, check=True)
                elif tool == "gcloud-cli":
                    result = subprocess.run(["gcloud", "--version"], 
                                          capture_output=True, text=True, check=True)
                else:
                    result = subprocess.run([tool, "--version"], 
                                          capture_output=True, text=True, check=True)
                logger.info(f"[OK] {tool} 설치됨")
            except (subprocess.CalledProcessError, FileNotFoundError):
                missing_tools.append(tool)
                logger.warning(f"[WARN] {tool} 누락")
        
        return missing_tools
    
    def _create_directories(self):
        """필요한 디렉토리 생성"""
        directories = [
            self.course_dir / "automation",
            self.course_dir / "automation" / "day1",
            self.course_dir / "automation" / "day2",
            self.course_dir / "automation" / "scripts",
            self.course_dir / "automation" / "templates",
            self.course_dir / "automation" / "results"
        ]
        
        for directory in directories:
            directory.mkdir(parents=True, exist_ok=True)
            logger.info(f"[DIR] 디렉토리 생성: {directory}")
    
    def _setup_environment_variables(self):
        """환경 변수 설정"""
        env_vars = {
            "COURSE_NAME": self.config.course_name,
            "COURSE_DURATION": str(self.config.duration_days),
            "COURSE_START_TIME": self.config.start_time,
            "COURSE_END_TIME": self.config.end_time
        }
        
        for key, value in env_vars.items():
            os.environ[key] = value
            logger.info(f"[ENV] 환경 변수 설정: {key}={value}")
    
    def create_day_plans(self) -> List[DayPlan]:
        """일일 계획 생성"""
        day_plans = [
            DayPlan(
                day=1,
                title="Kubernetes 및 GKE 고급 오케스트레이션",
                topics=[
                    "Kubernetes 고급 아키텍처",
                    "컨테이너 오케스트레이션 고급 기법",
                    "AWS ECS 및 Fargate 심화",
                    "고급 CI/CD 파이프라인"
                ],
                duration="7시간",
                objectives=[
                    "GKE 클러스터 생성 및 애플리케이션 배포",
                    "마이크로서비스 아키텍처 구성",
                    "ECS Fargate 서비스 배포",
                    "GitOps 기반 배포 자동화"
                ]
            ),
            DayPlan(
                day=2,
                title="고가용성 및 확장성 아키텍처",
                topics=[
                    "고가용성 아키텍처 설계",
                    "로드 밸런싱 및 Auto Scaling",
                    "모니터링 및 로깅 시스템",
                    "종합 프로젝트 및 최적화"
                ],
                duration="7시간",
                objectives=[
                    "Multi-AZ/Multi-Region 아키텍처 구현",
                    "Auto Scaling + Load Balancer 연동",
                    "커스텀 메트릭 대시보드 구축",
                    "실제 서비스 시나리오 아키텍처 구현"
                ]
            )
        ]
        
        return day_plans
    
    def generate_day1_scripts(self) -> bool:
        """Day 1 스크립트 생성"""
        logger.info("Day 1 스크립트 생성 중...")
        
        try:
            # Kubernetes 고급 스크립트
            self._create_kubernetes_advanced_script()
            
            # GKE 클러스터 스크립트
            self._create_gke_cluster_script()
            
            # ECS Fargate 스크립트
            self._create_ecs_fargate_script()
            
            # 고급 CI/CD 스크립트
            self._create_advanced_cicd_script()
            
            logger.info("Day 1 스크립트 생성 완료")
            return True
            
        except Exception as e:
            logger.error(f"Day 1 스크립트 생성 실패: {e}")
            return False
    
    def _create_kubernetes_advanced_script(self):
        """Kubernetes 고급 스크립트 생성"""
        script_content = '''#!/bin/bash
# Kubernetes 고급 아키텍처 실습 스크립트

set -e

echo "Kubernetes 고급 아키텍처 실습 시작..."

# kubectl 설치 확인
if ! command -v kubectl &> /dev/null; then
    echo "ERROR: kubectl이 설치되지 않았습니다."
    exit 1
fi

# Kubernetes 클러스터 정보 확인
echo "Kubernetes 클러스터 정보:"
kubectl cluster-info

# 클러스터 노드 확인
echo "클러스터 노드:"
kubectl get nodes -o wide

# 네임스페이스 생성
echo "네임스페이스 생성 중..."
kubectl create namespace container-course --dry-run=client -o yaml | kubectl apply -f -

# Deployment 생성
cat > nginx-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: container-course
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
EOF

# Service 생성
cat > nginx-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: container-course
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
EOF

# ConfigMap 생성
cat > nginx-configmap.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: container-course
data:
  nginx.conf: |
    events {
        worker_connections 1024;
    }
    http {
        upstream backend {
            server nginx-service:80;
        }
        server {
            listen 80;
            location / {
                proxy_pass http://backend;
            }
        }
    }
EOF

# Secret 생성
cat > nginx-secret.yaml << 'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: nginx-secret
  namespace: container-course
type: Opaque
data:
  username: YWRtaW4=  # admin
  password: cGFzc3dvcmQ=  # password
EOF

# PersistentVolume 생성
cat > nginx-pv.yaml << 'EOF'
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nginx-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /tmp/nginx-data
EOF

# PersistentVolumeClaim 생성
cat > nginx-pvc.yaml << 'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nginx-pvc
  namespace: container-course
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

# Ingress 생성
cat > nginx-ingress.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  namespace: container-course
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: nginx.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80
EOF

# 리소스 배포
echo "Kubernetes 리소스 배포 중..."
kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-service.yaml
kubectl apply -f nginx-configmap.yaml
kubectl apply -f nginx-secret.yaml
kubectl apply -f nginx-pv.yaml
kubectl apply -f nginx-pvc.yaml
kubectl apply -f nginx-ingress.yaml

# 배포 상태 확인
echo "배포 상태 확인 중..."
kubectl get all -n container-course

# Pod 로그 확인
echo "Pod 로그 확인:"
kubectl logs -n container-course -l app=nginx --tail=10

# 서비스 엔드포인트 확인
echo "서비스 엔드포인트:"
kubectl get svc -n container-course

# 스케일링 테스트
echo "스케일링 테스트 중..."
kubectl scale deployment nginx-deployment --replicas=5 -n container-course
kubectl get pods -n container-course

# 롤백 테스트
echo "롤백 테스트 중..."
kubectl rollout undo deployment/nginx-deployment -n container-course
kubectl rollout status deployment/nginx-deployment -n container-course

echo "Kubernetes 고급 아키텍처 실습 완료!"
'''
        
        script_path = self.course_dir / "automation" / "day1" / "kubernetes_advanced.sh"
        script_path.write_text(script_content, encoding='utf-8')
        script_path.chmod(0o755)
        logger.info(f"Kubernetes 고급 스크립트 생성: {script_path}")
    
    def _create_gke_cluster_script(self):
        """GKE 클러스터 스크립트 생성"""
        script_content = '''#!/bin/bash
# GKE 클러스터 생성 및 관리 스크립트

set -e

echo "GKE 클러스터 생성 및 관리 실습 시작..."

# GCP 프로젝트 설정
if [ -z "$PROJECT_ID" ]; then
    echo "ERROR: PROJECT_ID 환경 변수를 설정하세요."
    exit 1
fi

# gcloud 설정
gcloud config set project $PROJECT_ID

# GKE 클러스터 생성
echo "GKE 클러스터 생성 중..."
gcloud container clusters create container-course-cluster \
    --zone=us-central1-a \
    --num-nodes=3 \
    --machine-type=e2-medium \
    --enable-autoscaling \
    --min-nodes=1 \
    --max-nodes=5 \
    --enable-autorepair \
    --enable-autoupgrade \
    --enable-ip-alias \
    --network=default \
    --subnetwork=default

# 클러스터 인증 정보 가져오기
gcloud container clusters get-credentials container-course-cluster \
    --zone=us-central1-a

# 클러스터 정보 확인
echo "GKE 클러스터 정보:"
kubectl cluster-info
kubectl get nodes

# 클러스터 자동 스케일링 설정
cat > cluster-autoscaler.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cluster-autoscaler
  namespace: kube-system
  labels:
    app: cluster-autoscaler
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cluster-autoscaler
  template:
    metadata:
      labels:
        app: cluster-autoscaler
    spec:
      serviceAccountName: cluster-autoscaler
      containers:
      - image: k8s.gcr.io/autoscaling/cluster-autoscaler:v1.21.0
        name: cluster-autoscaler
        resources:
          limits:
            cpu: 100m
            memory: 300Mi
          requests:
            cpu: 100m
            memory: 300Mi
        command:
        - ./cluster-autoscaler
        - --v=4
        - --stderrthreshold=info
        - --cloud-provider=gce
        - --skip-nodes-with-local-storage=false
        - --expander=least-waste
        - --node-group-auto-discovery=mig:name_prefix=container-course-cluster,min_nodes=1,max_nodes=5
        env:
        - name: GOOGLE_APPLICATION_CREDENTIALS
          value: /etc/ssl/certs/ca-certificates.crt
EOF

# 클러스터 자동 스케일러 배포
kubectl apply -f cluster-autoscaler.yaml

# 워크로드 배포 테스트
cat > workload-test.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: workload-test
  namespace: default
spec:
  replicas: 10
  selector:
    matchLabels:
      app: workload-test
  template:
    metadata:
      labels:
        app: workload-test
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        resources:
          requests:
            memory: "100Mi"
            cpu: "100m"
          limits:
            memory: "200Mi"
            cpu: "200m"
EOF

# 워크로드 배포
kubectl apply -f workload-test.yaml

# 스케일링 모니터링
echo "스케일링 모니터링 중..."
kubectl get pods -o wide
kubectl get nodes

# 클러스터 정리 (선택사항)
read -p "클러스터를 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "GKE 클러스터 삭제 중..."
    gcloud container clusters delete container-course-cluster \
        --zone=us-central1-a \
        --quiet
fi

echo "GKE 클러스터 생성 및 관리 실습 완료!"
'''
        
        script_path = self.course_dir / "automation" / "day1" / "gke_cluster.sh"
        script_path.write_text(script_content, encoding='utf-8')
        script_path.chmod(0o755)
        logger.info(f"GKE 클러스터 스크립트 생성: {script_path}")
    
    def _create_ecs_fargate_script(self):
        """ECS Fargate 스크립트 생성"""
        script_content = '''#!/bin/bash
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
aws ecs create-cluster \
    --cluster-name container-course-cluster \
    --capacity-providers FARGATE FARGATE_SPOT \
    --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1

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
aws logs create-log-group \
    --log-group-name /ecs/container-course \
    --region $AWS_REGION

# 태스크 정의 등록
echo "태스크 정의 등록 중..."
aws ecs register-task-definition \
    --cli-input-json file://task-definition.json

# VPC 및 서브넷 생성
echo "VPC 및 서브넷 생성 중..."
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --query 'Vpc.VpcId' \
    --output text)

aws ec2 create-tags \
    --resources $VPC_ID \
    --tags Key=Name,Value=container-course-vpc

# 인터넷 게이트웨이 생성
IGW_ID=$(aws ec2 create-internet-gateway \
    --query 'InternetGateway.InternetGatewayId' \
    --output text)

aws ec2 attach-internet-gateway \
    --vpc-id $VPC_ID \
    --internet-gateway-id $IGW_ID

# 서브넷 생성
SUBNET_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.1.0/24 \
    --availability-zone ${AWS_REGION}a \
    --query 'Subnet.SubnetId' \
    --output text)

# 라우트 테이블 생성
ROUTE_TABLE_ID=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --query 'RouteTable.RouteTableId' \
    --output text)

# 기본 라우트 추가
aws ec2 create-route \
    --route-table-id $ROUTE_TABLE_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $IGW_ID

# 서브넷과 라우트 테이블 연결
aws ec2 associate-route-table \
    --subnet-id $SUBNET_ID \
    --route-table-id $ROUTE_TABLE_ID

# 보안 그룹 생성
SECURITY_GROUP_ID=$(aws ec2 create-security-group \
    --group-name container-course-sg \
    --description "Security group for container course" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)

# 보안 그룹 규칙 설정
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

# ECS 서비스 생성
echo "ECS 서비스 생성 중..."
aws ecs create-service \
    --cluster container-course-cluster \
    --service-name container-course-service \
    --task-definition container-course-task \
    --desired-count 2 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNET_ID],securityGroups=[$SECURITY_GROUP_ID],assignPublicIp=ENABLED}"

# 서비스 상태 확인
echo "서비스 상태 확인 중..."
aws ecs describe-services \
    --cluster container-course-cluster \
    --services container-course-service

# 태스크 목록 확인
echo "태스크 목록:"
aws ecs list-tasks \
    --cluster container-course-cluster \
    --service-name container-course-service

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
aws application-autoscaling register-scalable-target \
    --service-namespace ecs \
    --resource-id service/container-course-cluster/container-course-service \
    --scalable-dimension ecs:service:DesiredCount \
    --min-capacity 1 \
    --max-capacity 10

# 정리 (선택사항)
read -p "ECS 리소스를 삭제하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "ECS 리소스 삭제 중..."
    aws ecs update-service \
        --cluster container-course-cluster \
        --service container-course-service \
        --desired-count 0
    
    aws ecs delete-service \
        --cluster container-course-cluster \
        --service container-course-service
    
    aws ecs delete-cluster \
        --cluster container-course-cluster
fi

echo "AWS ECS Fargate 실습 완료!"
'''
        
        script_path = self.course_dir / "automation" / "day1" / "ecs_fargate.sh"
        script_path.write_text(script_content, encoding='utf-8')
        script_path.chmod(0o755)
        logger.info(f"ECS Fargate 스크립트 생성: {script_path}")
    
    def _create_advanced_cicd_script(self):
        """고급 CI/CD 스크립트 생성"""
        script_content = '''#!/bin/bash
# 고급 CI/CD 파이프라인 실습 스크립트

set -e

echo "고급 CI/CD 파이프라인 실습 시작..."

# GitHub Actions 워크플로우 생성
mkdir -p .github/workflows

# Multi-stage 배포 파이프라인
cat > .github/workflows/advanced-cicd.yml << 'EOF'
name: Advanced CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: npm test
    
    - name: Run linting
      run: npm run lint
    
    - name: Run security scan
      run: npm audit --audit-level moderate

  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Log in to Container Registry
      uses: docker/login-action@v2
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v4
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=sha,prefix={{branch}}-
          type=raw,value=latest,enable={{is_default_branch}}
    
    - name: Build and push Docker image
      uses: docker/build-push-action@v4
      with:
        context: .
        platforms: linux/amd64,linux/arm64
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max

  deploy-dev:
    needs: build
    runs-on: ubuntu-latest
    environment: development
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to Development
      run: |
        echo "Deploying to development environment..."
        # GKE 배포
        gcloud container clusters get-credentials dev-cluster --zone=us-central1-a
        kubectl set image deployment/app-deployment app=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:develop
        kubectl rollout status deployment/app-deployment
    
    - name: Run smoke tests
      run: |
        echo "Running smoke tests..."
        # 스모크 테스트 실행
        curl -f http://dev.example.com/health || exit 1

  deploy-staging:
    needs: deploy-dev
    runs-on: ubuntu-latest
    environment: staging
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to Staging
      run: |
        echo "Deploying to staging environment..."
        # ECS 배포
        aws ecs update-service \
          --cluster staging-cluster \
          --service app-service \
          --force-new-deployment
    
    - name: Run integration tests
      run: |
        echo "Running integration tests..."
        # 통합 테스트 실행
        npm run test:integration

  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to Production
      run: |
        echo "Deploying to production environment..."
        # Blue-Green 배포
        kubectl apply -f k8s/production/
        kubectl rollout status deployment/app-deployment
    
    - name: Run production tests
      run: |
        echo "Running production tests..."
        # 프로덕션 테스트 실행
        npm run test:production
    
    - name: Notify deployment
      uses: 8398a7/action-slack@v3
      with:
        status: ${{ job.status }}
        channel: '#deployments'
        webhook_url: ${{ secrets.SLACK_WEBHOOK }}
EOF

# GitOps 설정
cat > argocd-app.yaml << 'EOF'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: container-course-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/container-course
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: container-course
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF

# Helm 차트 생성
mkdir -p helm-chart/templates

cat > helm-chart/Chart.yaml << 'EOF'
apiVersion: v2
name: container-course
description: Container Course Application
type: application
version: 0.1.0
appVersion: "1.0.0"
EOF

cat > helm-chart/values.yaml << 'EOF'
replicaCount: 3

image:
  repository: nginx
  tag: "1.21"
  pullPolicy: IfNotPresent

service:
  type: LoadBalancer
  port: 80

ingress:
  enabled: true
  className: "nginx"
  annotations: {}
  hosts:
    - host: container-course.local
      paths:
        - path: /
          pathType: Prefix
  tls: []

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80
EOF

cat > helm-chart/templates/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "container-course.fullname" . }}
  labels:
    {{- include "container-course.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "container-course.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "container-course.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
          livenessProbe:
            httpGet:
              path: /
              port: http
          readinessProbe:
            httpGet:
              path: /
              port: http
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
EOF

# Dockerfile 생성
cat > Dockerfile << 'EOF'
# Multi-stage build
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM nginx:1.21-alpine AS production

COPY --from=builder /app /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

# nginx 설정
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    upstream backend {
        server app:3000;
    }
    
    server {
        listen 80;
        server_name localhost;
        
        location / {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        location /health {
            access_log off;
            return 200 "healthy\\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF

echo "고급 CI/CD 파이프라인 실습 완료!"
'''
        
        script_path = self.course_dir / "automation" / "day1" / "advanced_cicd.sh"
        script_path.write_text(script_content, encoding='utf-8')
        script_path.chmod(0o755)
        logger.info(f"고급 CI/CD 스크립트 생성: {script_path}")
    
    def generate_day2_scripts(self) -> bool:
        """Day 2 스크립트 생성"""
        logger.info("Day 2 스크립트 생성 중...")
        
        try:
            # Day 2 스크립트 생성 모듈 import 및 실행
            from container_course_day2_scripts import (
                create_high_availability_script,
                create_monitoring_script,
                create_comprehensive_project_script
            )
            
            # 고가용성 아키텍처 스크립트
            create_high_availability_script(self.course_dir)
            
            # 모니터링 및 로깅 스크립트
            create_monitoring_script(self.course_dir)
            
            # 종합 프로젝트 스크립트
            create_comprehensive_project_script(self.course_dir)
            
            logger.info("Day 2 스크립트 생성 완료")
            return True
            
        except Exception as e:
            logger.error(f"Day 2 스크립트 생성 실패: {e}")
            return False
    
    def run_course_automation(self) -> bool:
        """Container 과정 자동화 실행"""
        logger.info("Container 과정 자동화 시작...")
        
        try:
            # 환경 설정
            if not self.setup_environment():
                return False
            
            # 일일 계획 생성
            day_plans = self.create_day_plans()
            
            # Day 1 스크립트 생성
            if not self.generate_day1_scripts():
                return False
                
            # Day 2 스크립트 생성
            if not self.generate_day2_scripts():
                return False
            
            # 결과 저장
            self._save_results(day_plans)
            
            logger.info("Container 과정 자동화 완료!")
            return True
            
        except Exception as e:
            logger.error(f"Container 과정 자동화 실패: {e}")
            return False
    
    def _save_results(self, day_plans: List[DayPlan]):
        """결과 저장"""
        results = {
            "course_name": self.config.course_name,
            "duration_days": self.config.duration_days,
            "generated_at": str(Path.cwd()),
            "day_plans": [
                {
                    "day": plan.day,
                    "title": plan.title,
                    "topics": plan.topics,
                    "duration": plan.duration,
                    "objectives": plan.objectives
                }
                for plan in day_plans
            ],
            "scripts_generated": {
                "day1": [
                    "kubernetes_advanced.sh",
                    "gke_cluster.sh", 
                    "ecs_fargate.sh",
                    "advanced_cicd.sh"
                ],
                "day2": [
                    "high_availability.sh",
                    "monitoring.sh",
                    "comprehensive_project.sh"
                ]
            }
        }
        
        results_file = self.course_dir / "automation" / "results" / "automation_results.json"
        results_file.write_text(json.dumps(results, indent=2, ensure_ascii=False), encoding='utf-8')
        
        logger.info(f"결과 저장: {results_file}")

def main():
    """메인 함수"""
    config = CourseConfig()
    automation = ContainerCourseAutomation(config)
    
    if automation.run_course_automation():
        print("Container 과정 자동화가 성공적으로 완료되었습니다.")
    else:
        print("Container 과정 자동화에 실패했습니다.")

if __name__ == "__main__":
    main()
