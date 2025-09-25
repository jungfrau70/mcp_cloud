#!/usr/bin/env python3
"""
Basic 과정 Day 2 스크립트 생성 모듈
네트워킹, 보안, 데이터베이스, 종합 실습 스크립트
"""

from pathlib import Path

def create_networking_script(course_dir: Path):
    """네트워킹 기초 스크립트 생성"""
    script_content = '''#!/bin/bash
# 네트워킹 기초 실습 스크립트

set -e

echo "네트워킹 기초 실습 시작..."

# AWS VPC 생성
echo "AWS VPC 생성 중..."
VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text)
aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=basic-course-vpc

# 인터넷 게이트웨이 생성
IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID

# 서브넷 생성
SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.1.0/24 --availability-zone us-west-2a --query 'Subnet.SubnetId' --output text)

# 라우트 테이블 생성
ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)

# 기본 라우트 추가
aws ec2 create-route --route-table-id $ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID

# 서브넷과 라우트 테이블 연결
aws ec2 associate-route-table --subnet-id $SUBNET_ID --route-table-id $ROUTE_TABLE_ID

# GCP VPC 네트워크 생성
echo "GCP VPC 네트워크 생성 중..."
gcloud compute networks create basic-course-network --subnet-mode custom

# GCP 서브넷 생성
gcloud compute networks subnets create basic-course-subnet \
    --network=basic-course-network \
    --range=10.1.0.0/24 \
    --region=us-central1

echo "네트워킹 기초 실습 완료!"
'''
    
    script_path = course_dir / "automation" / "day2" / "networking_basics.sh"
    script_path.write_text(script_content, encoding='utf-8')
    script_path.chmod(0o755)

def create_security_script(course_dir: Path):
    """보안 그룹 및 방화벽 스크립트 생성"""
    script_content = '''#!/bin/bash
# 보안 그룹 및 방화벽 실습 스크립트

set -e

echo "보안 그룹 및 방화벽 실습 시작..."

# AWS 보안 그룹 생성
echo "AWS 보안 그룹 생성 중..."
SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name basic-course-sg --description "Basic Course Security Group" --vpc-id $VPC_ID --query 'GroupId' --output text)

# 보안 그룹 규칙 설정
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 443 --cidr 0.0.0.0/0

# GCP 방화벽 규칙 생성
echo "GCP 방화벽 규칙 생성 중..."
gcloud compute firewall-rules create allow-ssh-http-https \
    --network=basic-course-network \
    --allow tcp:22,tcp:80,tcp:443 \
    --source-ranges 0.0.0.0/0 \
    --target-tags basic-course

echo "보안 그룹 및 방화벽 실습 완료!"
'''
    
    script_path = course_dir / "automation" / "day2" / "security_basics.sh"
    script_path.write_text(script_content, encoding='utf-8')
    script_path.chmod(0o755)

def create_database_script(course_dir: Path):
    """데이터베이스 서비스 스크립트 생성"""
    script_content = '''#!/bin/bash
# 데이터베이스 서비스 기초 실습 스크립트

set -e

echo "데이터베이스 서비스 기초 실습 시작..."

# AWS RDS MySQL 인스턴스 생성
echo "AWS RDS MySQL 인스턴스 생성 중..."
aws rds create-db-instance \
    --db-instance-identifier basic-course-db \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --master-username admin \
    --master-user-password BasicCourse123! \
    --allocated-storage 20 \
    --vpc-security-group-ids $SECURITY_GROUP_ID \
    --db-subnet-group-name basic-course-subnet-group

# GCP Cloud SQL MySQL 인스턴스 생성
echo "GCP Cloud SQL MySQL 인스턴스 생성 중..."
gcloud sql instances create basic-course-db \
    --database-version=MYSQL_8_0 \
    --tier=db-f1-micro \
    --region=us-central1 \
    --root-password=BasicCourse123!

# 데이터베이스 생성
gcloud sql databases create basic_course_db --instance=basic-course-db

echo "데이터베이스 서비스 기초 실습 완료!"
'''
    
    script_path = course_dir / "automation" / "day2" / "database_services.sh"
    script_path.write_text(script_content, encoding='utf-8')
    script_path.chmod(0o755)

def create_comprehensive_script(course_dir: Path):
    """종합 실습 스크립트 생성"""
    script_content = '''#!/bin/bash
# 종합 실습 스크립트

set -e

echo "종합 실습 시작..."

# 웹 애플리케이션 배포
echo "웹 애플리케이션 배포 중..."

# 간단한 웹 서버 배포
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Basic Course Web App</title>
</head>
<body>
    <h1>Welcome to Cloud Basic Course!</h1>
    <p>This is a simple web application deployed on cloud.</p>
</body>
</html>
EOF

# AWS에 웹 서버 배포
aws s3 cp index.html s3://$BUCKET_NAME/index.html
aws s3 website s3://$BUCKET_NAME --index-document index.html

# GCP에 웹 서버 배포
gsutil cp index.html gs://$GCP_BUCKET_NAME/index.html
gsutil web set -m index.html gs://$GCP_BUCKET_NAME

echo "종합 실습 완료!"
'''
    
    script_path = course_dir / "automation" / "day2" / "comprehensive_practice.sh"
    script_path.write_text(script_content, encoding='utf-8')
    script_path.chmod(0o755)
