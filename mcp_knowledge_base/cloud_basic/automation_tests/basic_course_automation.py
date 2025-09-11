#!/usr/bin/env python3
"""
Basic 과정 자동화 시스템
AWS/GCP 기초 서비스, IAM, VM, 스토리지, 네트워킹, 보안, 데이터베이스 실습 스크립트 자동 생성
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
        logging.FileHandler('basic_course_automation.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

@dataclass
class CourseConfig:
    """Basic 과정 설정"""
    course_name: str = "Cloud Basic Course"
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
                "aws-cli", "gcloud-cli"
            ]

@dataclass
class DayPlan:
    """일일 계획"""
    day: int
    title: str
    topics: List[str]
    duration: str
    objectives: List[str]

class BasicCourseAutomation:
    """Basic 과정 자동화 클래스"""
    
    def __init__(self, config: CourseConfig = None):
        self.config = config or CourseConfig()
        self.project_root = Path(__file__).parent.parent.parent.parent
        self.course_dir = self.project_root / "mcp_knowledge_base" / "cloud_basic"
        self.scripts_dir = self.project_root / "mcp_knowledge_base" / "cloud_basic" / "automation_tests"
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
                if tool == "aws-cli":
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
                title="AWS & GCP 기초 서비스 실습",
                topics=[
                    "클라우드 개념 및 계정 생성",
                    "IAM 기초 실습",
                    "가상머신 서비스 기초",
                    "스토리지 서비스 기초"
                ],
                duration="7시간",
                objectives=[
                    "AWS/GCP 계정 생성 및 기본 설정",
                    "IAM을 통한 사용자 및 권한 관리",
                    "EC2/Compute Engine 인스턴스 생성 및 관리",
                    "S3/Cloud Storage 버킷 생성 및 파일 관리"
                ]
            ),
            DayPlan(
                day=2,
                title="네트워크, 보안 및 데이터베이스 실습",
                topics=[
                    "네트워킹 기초 실습",
                    "보안 그룹 및 방화벽 실습",
                    "데이터베이스 서비스 기초",
                    "종합 실습 및 비교 분석"
                ],
                duration="7시간",
                objectives=[
                    "VPC 네트워크 구성 및 관리",
                    "보안 그룹/방화벽 규칙 설정",
                    "RDS/Cloud SQL 데이터베이스 생성 및 관리",
                    "웹 애플리케이션 클라우드 배포"
                ]
            )
        ]
        
        return day_plans
    
    def generate_day1_scripts(self) -> bool:
        """Day 1 스크립트 생성"""
        logger.info("Day 1 스크립트 생성 중...")
        
        try:
            # 클라우드 기초 스크립트
            self._create_cloud_basics_script()
            
            # IAM 실습 스크립트
            self._create_iam_script()
            
            # 가상머신 서비스 스크립트
            self._create_vm_services_script()
            
            # 스토리지 서비스 스크립트
            self._create_storage_services_script()
            
            logger.info("Day 1 스크립트 생성 완료")
            return True
            
        except Exception as e:
            logger.error(f"Day 1 스크립트 생성 실패: {e}")
            return False
    
    def _create_cloud_basics_script(self):
        """클라우드 기초 스크립트 생성"""
        script_content = '''#!/bin/bash
# 클라우드 기초 실습 스크립트

set -e

echo "클라우드 기초 실습 시작..."

# AWS 계정 설정 확인
echo "AWS 계정 설정 확인 중..."
if ! aws sts get-caller-identity &> /dev/null; then
    echo "ERROR: AWS CLI가 설정되지 않았습니다."
    echo "다음 명령어로 AWS를 설정하세요:"
    echo "aws configure"
    exit 1
fi

# GCP 계정 설정 확인
echo "GCP 계정 설정 확인 중..."
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 &> /dev/null; then
    echo "ERROR: GCP CLI가 설정되지 않았습니다."
    echo "다음 명령어로 GCP를 설정하세요:"
    echo "gcloud auth login"
    exit 1
fi

# AWS 계정 정보 확인
echo "AWS 계정 정보:"
aws sts get-caller-identity

# GCP 계정 정보 확인
echo "GCP 계정 정보:"
gcloud auth list

# AWS 리전 설정
echo "AWS 리전 설정 중..."
aws configure set default.region us-west-2

# GCP 프로젝트 설정
echo "GCP 프로젝트 설정 중..."
if [ -z "$PROJECT_ID" ]; then
    echo "ERROR: PROJECT_ID 환경 변수를 설정하세요."
    echo "export PROJECT_ID=your-project-id"
    exit 1
fi

gcloud config set project $PROJECT_ID

# AWS 서비스 목록 확인
echo "AWS 서비스 목록:"
aws ec2 describe-regions --query 'Regions[].RegionName' --output table

# GCP 서비스 목록 확인
echo "GCP 서비스 목록:"
gcloud services list --enabled

echo "클라우드 기초 실습 완료!"
'''
        
        script_path = self.course_dir / "automation" / "day1" / "cloud_basics.sh"
        script_path.write_text(script_content, encoding='utf-8')
        script_path.chmod(0o755)
        logger.info(f"클라우드 기초 스크립트 생성: {script_path}")
    
    def _create_iam_script(self):
        """IAM 실습 스크립트 생성"""
        script_content = '''#!/bin/bash
# IAM 기초 실습 스크립트

set -e

echo "IAM 기초 실습 시작..."

# AWS IAM 사용자 생성
echo "AWS IAM 사용자 생성 중..."
USER_NAME="basic-course-user"
GROUP_NAME="basic-course-group"

# IAM 그룹 생성
aws iam create-group --group-name $GROUP_NAME || echo "그룹이 이미 존재합니다."

# IAM 사용자 생성
aws iam create-user --user-name $USER_NAME || echo "사용자가 이미 존재합니다."

# 사용자를 그룹에 추가
aws iam add-user-to-group --user-name $USER_NAME --group-name $GROUP_NAME

# 정책 생성
cat > basic-course-policy.json << 'EOF'
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*",
                "ec2:RunInstances",
                "ec2:TerminateInstances",
                "s3:GetObject",
                "s3:PutObject",
                "s3:ListBucket"
            ],
            "Resource": "*"
        }
    ]
}
EOF

# 정책 생성
aws iam create-policy --policy-name BasicCoursePolicy --policy-document file://basic-course-policy.json || echo "정책이 이미 존재합니다."

# 그룹에 정책 연결
aws iam attach-group-policy --group-name $GROUP_NAME --policy-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/BasicCoursePolicy

# GCP 서비스 계정 생성
echo "GCP 서비스 계정 생성 중..."
SERVICE_ACCOUNT_NAME="basic-course-sa"
SERVICE_ACCOUNT_EMAIL="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"

# 서비스 계정 생성
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME --display-name="Basic Course Service Account" || echo "서비스 계정이 이미 존재합니다."

# 서비스 계정에 권한 부여
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/compute.instanceAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/storage.admin"

# 서비스 계정 키 생성
gcloud iam service-accounts keys create basic-course-key.json \
    --iam-account=$SERVICE_ACCOUNT_EMAIL

echo "IAM 기초 실습 완료!"
echo "생성된 리소스:"
echo "- AWS IAM 사용자: $USER_NAME"
echo "- AWS IAM 그룹: $GROUP_NAME"
echo "- GCP 서비스 계정: $SERVICE_ACCOUNT_EMAIL"
echo "- GCP 서비스 계정 키: basic-course-key.json"
'''
        
        script_path = self.course_dir / "automation" / "day1" / "iam_basics.sh"
        script_path.write_text(script_content, encoding='utf-8')
        script_path.chmod(0o755)
        logger.info(f"IAM 실습 스크립트 생성: {script_path}")
    
    def _create_vm_services_script(self):
        """가상머신 서비스 스크립트 생성"""
        script_content = '''#!/bin/bash
# 가상머신 서비스 기초 실습 스크립트

set -e

echo "가상머신 서비스 기초 실습 시작..."

# AWS EC2 인스턴스 생성
echo "AWS EC2 인스턴스 생성 중..."
INSTANCE_NAME="basic-course-instance"
KEY_NAME="basic-course-key"
SECURITY_GROUP_NAME="basic-course-sg"

# 키 페어 생성
aws ec2 create-key-pair --key-name $KEY_NAME --query 'KeyMaterial' --output text > $KEY_NAME.pem
chmod 400 $KEY_NAME.pem

# 보안 그룹 생성
aws ec2 create-security-group --group-name $SECURITY_GROUP_NAME --description "Basic Course Security Group" || echo "보안 그룹이 이미 존재합니다."

# 보안 그룹 규칙 설정
aws ec2 authorize-security-group-ingress --group-name $SECURITY_GROUP_NAME --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name $SECURITY_GROUP_NAME --protocol tcp --port 80 --cidr 0.0.0.0/0

# EC2 인스턴스 생성
aws ec2 run-instances \
    --image-id ami-0c02fb55956c7d316 \
    --count 1 \
    --instance-type t2.micro \
    --key-name $KEY_NAME \
    --security-groups $SECURITY_GROUP_NAME \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$INSTANCE_NAME'}]'

# GCP Compute Engine 인스턴스 생성
echo "GCP Compute Engine 인스턴스 생성 중..."
GCP_INSTANCE_NAME="basic-course-instance"
ZONE="us-central1-a"

# GCP 인스턴스 생성
gcloud compute instances create $GCP_INSTANCE_NAME \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-standard \
    --tags=basic-course

# 방화벽 규칙 생성
gcloud compute firewall-rules create allow-ssh-http \
    --allow tcp:22,tcp:80 \
    --source-ranges 0.0.0.0/0 \
    --target-tags basic-course

# 인스턴스 상태 확인
echo "AWS EC2 인스턴스 상태:"
aws ec2 describe-instances --filters "Name=tag:Name,Values=$INSTANCE_NAME" --query 'Reservations[].Instances[].State.Name' --output table

echo "GCP Compute Engine 인스턴스 상태:"
gcloud compute instances list --filter="name=$GCP_INSTANCE_NAME"

echo "가상머신 서비스 기초 실습 완료!"
echo "생성된 리소스:"
echo "- AWS EC2 인스턴스: $INSTANCE_NAME"
echo "- GCP Compute Engine 인스턴스: $GCP_INSTANCE_NAME"
'''
        
        script_path = self.course_dir / "automation" / "day1" / "vm_services.sh"
        script_path.write_text(script_content, encoding='utf-8')
        script_path.chmod(0o755)
        logger.info(f"가상머신 서비스 스크립트 생성: {script_path}")
    
    def _create_storage_services_script(self):
        """스토리지 서비스 스크립트 생성"""
        script_content = '''#!/bin/bash
# 스토리지 서비스 기초 실습 스크립트

set -e

echo "스토리지 서비스 기초 실습 시작..."

# AWS S3 버킷 생성
echo "AWS S3 버킷 생성 중..."
BUCKET_NAME="basic-course-bucket-$(date +%s)"
REGION="us-west-2"

# S3 버킷 생성
aws s3 mb s3://$BUCKET_NAME --region $REGION

# 버킷 정책 설정
cat > bucket-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
        }
    ]
}
EOF

aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://bucket-policy.json

# 테스트 파일 생성 및 업로드
echo "Hello from AWS S3!" > test-file.txt
aws s3 cp test-file.txt s3://$BUCKET_NAME/

# GCP Cloud Storage 버킷 생성
echo "GCP Cloud Storage 버킷 생성 중..."
GCP_BUCKET_NAME="basic-course-bucket-$(date +%s)"

# GCP 버킷 생성
gsutil mb gs://$GCP_BUCKET_NAME

# 테스트 파일 업로드
echo "Hello from GCP Cloud Storage!" > gcp-test-file.txt
gsutil cp gcp-test-file.txt gs://$GCP_BUCKET_NAME/

# 버킷 목록 확인
echo "AWS S3 버킷 목록:"
aws s3 ls

echo "GCP Cloud Storage 버킷 목록:"
gsutil ls

# 파일 다운로드 테스트
echo "파일 다운로드 테스트 중..."
aws s3 cp s3://$BUCKET_NAME/test-file.txt downloaded-aws-file.txt
gsutil cp gs://$GCP_BUCKET_NAME/gcp-test-file.txt downloaded-gcp-file.txt

echo "다운로드된 파일 내용:"
echo "AWS S3:"
cat downloaded-aws-file.txt
echo "GCP Cloud Storage:"
cat downloaded-gcp-file.txt

# 정리
rm -f test-file.txt gcp-test-file.txt downloaded-aws-file.txt downloaded-gcp-file.txt bucket-policy.json

echo "스토리지 서비스 기초 실습 완료!"
echo "생성된 리소스:"
echo "- AWS S3 버킷: $BUCKET_NAME"
echo "- GCP Cloud Storage 버킷: $GCP_BUCKET_NAME"
'''
        
        script_path = self.course_dir / "automation" / "day1" / "storage_services.sh"
        script_path.write_text(script_content, encoding='utf-8')
        script_path.chmod(0o755)
        logger.info(f"스토리지 서비스 스크립트 생성: {script_path}")
    
    def generate_day2_scripts(self) -> bool:
        """Day 2 스크립트 생성"""
        logger.info("Day 2 스크립트 생성 중...")
        
        try:
            # Day 2 스크립트 생성 모듈 import 및 실행
            from basic_course_day2_scripts import (
                create_networking_script,
                create_security_script,
                create_database_script,
                create_comprehensive_script
            )
            
            # 네트워킹 기초 스크립트
            create_networking_script(self.course_dir)
            
            # 보안 그룹 및 방화벽 스크립트
            create_security_script(self.course_dir)
            
            # 데이터베이스 서비스 스크립트
            create_database_script(self.course_dir)
            
            # 종합 실습 스크립트
            create_comprehensive_script(self.course_dir)
            
            logger.info("Day 2 스크립트 생성 완료")
            return True
            
        except Exception as e:
            logger.error(f"Day 2 스크립트 생성 실패: {e}")
            return False
    
    def run_course_automation(self) -> bool:
        """Basic 과정 자동화 실행"""
        logger.info("Basic 과정 자동화 시작...")
        
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
            
            logger.info("Basic 과정 자동화 완료!")
            return True
            
        except Exception as e:
            logger.error(f"Basic 과정 자동화 실패: {e}")
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
                    "cloud_basics.sh",
                    "iam_basics.sh",
                    "vm_services.sh",
                    "storage_services.sh"
                ],
                "day2": [
                    "networking_basics.sh",
                    "security_basics.sh",
                    "database_services.sh",
                    "comprehensive_practice.sh"
                ]
            }
        }
        
        results_file = self.course_dir / "automation" / "results" / "automation_results.json"
        results_file.write_text(json.dumps(results, indent=2, ensure_ascii=False), encoding='utf-8')
        
        logger.info(f"결과 저장: {results_file}")

def main():
    """메인 함수"""
    config = CourseConfig()
    automation = BasicCourseAutomation(config)
    
    if automation.run_course_automation():
        print("Basic 과정 자동화가 성공적으로 완료되었습니다.")
    else:
        print("Basic 과정 자동화에 실패했습니다.")

if __name__ == "__main__":
    main()
