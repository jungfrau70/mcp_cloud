#!/usr/bin/env python3
"""
Cloud Basic 과정 자동화 스크립트
AWS/GCP 기초 실습 자동화
"""

import os
import sys
import json
import time
import subprocess
import logging
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Any, Optional
import boto3
from google.cloud import storage
import docker

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

class BasicCourseAutomation:
    """Cloud Basic 과정 자동화 클래스"""
    
    def __init__(self, base_path: Path):
        self.base_path = base_path
        self.course_name = "cloud_basic"
        self.duration_days = 2
        self.status = "not_started"
        self.completed_days = []
        self.created_resources = []
        
        # AWS/GCP 클라이언트 초기화
        self.aws_client = None
        self.gcp_client = None
        self.docker_client = None
        
        # 설정 로드
        self.config = self.load_config()
    
    def load_config(self) -> Dict[str, Any]:
        """설정 파일 로드"""
        config_file = self.base_path / "automation_tests" / "config.json"
        
        default_config = {
            "aws_region": "us-west-2",
            "gcp_region": "us-central1",
            "project_prefix": "cloud-training-basic",
            "enable_monitoring": True,
            "enable_logging": True,
            "shared_resources": True
        }
        
        if config_file.exists():
            try:
                with open(config_file, 'r', encoding='utf-8') as f:
                    config = json.load(f)
                logger.info("✅ 설정 파일 로드 완료")
                return {**default_config, **config}
            except Exception as e:
                logger.warning(f"⚠️ 설정 파일 로드 실패: {e}")
        
        return default_config
    
    def initialize_clients(self) -> bool:
        """클라우드 클라이언트 초기화"""
        logger.info("🔧 클라우드 클라이언트 초기화 중...")
        
        success = True
        
        # AWS 클라이언트 초기화
        try:
            self.aws_client = boto3.client('ec2', region_name=self.config['aws_region'])
            logger.info("✅ AWS 클라이언트 초기화 완료")
        except Exception as e:
            logger.warning(f"⚠️ AWS 클라이언트 초기화 실패: {e}")
            success = False
        
        # GCP 클라이언트 초기화
        try:
            self.gcp_client = storage.Client()
            logger.info("✅ GCP 클라이언트 초기화 완료")
        except Exception as e:
            logger.warning(f"⚠️ GCP 클라이언트 초기화 실패: {e}")
            success = False
        
        # Docker 클라이언트 초기화
        try:
            self.docker_client = docker.from_env()
            logger.info("✅ Docker 클라이언트 초기화 완료")
        except Exception as e:
            logger.warning(f"⚠️ Docker 클라이언트 초기화 실패: {e}")
            success = False
        
        return success
    
    def day1_aws_basics(self) -> bool:
        """1일차: AWS 기초 실습"""
        logger.info("🌅 1일차: AWS 기초 실습 시작")
        
        try:
            # VPC 생성
            vpc_response = self.aws_client.create_vpc(
                CidrBlock='10.0.0.0/16',
                TagSpecifications=[{
                    'ResourceType': 'vpc',
                    'Tags': [{'Key': 'Name', 'Value': f"{self.config['project_prefix']}-vpc"}]
                }]
            )
            vpc_id = vpc_response['Vpc']['VpcId']
            self.created_resources.append(f"VPC: {vpc_id}")
            logger.info(f"✅ VPC 생성 완료: {vpc_id}")
            
            # 서브넷 생성
            subnet_response = self.aws_client.create_subnet(
                VpcId=vpc_id,
                CidrBlock='10.0.1.0/24',
                AvailabilityZone=f"{self.config['aws_region']}a",
                TagSpecifications=[{
                    'ResourceType': 'subnet',
                    'Tags': [{'Key': 'Name', 'Value': f"{self.config['project_prefix']}-subnet"}]
                }]
            )
            subnet_id = subnet_response['Subnet']['SubnetId']
            self.created_resources.append(f"Subnet: {subnet_id}")
            logger.info(f"✅ 서브넷 생성 완료: {subnet_id}")
            
            # S3 버킷 생성
            bucket_name = f"{self.config['project_prefix']}-bucket-{int(time.time())}"
            s3_client = boto3.client('s3')
            s3_client.create_bucket(
                Bucket=bucket_name,
                CreateBucketConfiguration={'LocationConstraint': self.config['aws_region']}
            )
            self.created_resources.append(f"S3 Bucket: {bucket_name}")
            logger.info(f"✅ S3 버킷 생성 완료: {bucket_name}")
            
            self.completed_days.append("day1")
            logger.info("✅ 1일차 AWS 기초 실습 완료")
            return True
            
        except Exception as e:
            logger.error(f"❌ 1일차 AWS 기초 실습 실패: {e}")
            return False
    
    def day2_gcp_basics(self) -> bool:
        """2일차: GCP 기초 실습"""
        logger.info("🌅 2일차: GCP 기초 실습 시작")
        
        try:
            # GCP Storage 버킷 생성
            bucket_name = f"{self.config['project_prefix']}-bucket-{int(time.time())}"
            bucket = self.gcp_client.bucket(bucket_name)
            bucket.create()
            self.created_resources.append(f"GCP Storage Bucket: {bucket_name}")
            logger.info(f"✅ GCP Storage 버킷 생성 완료: {bucket_name}")
            
            # Compute Engine 인스턴스 생성 (시뮬레이션)
            instance_name = f"{self.config['project_prefix']}-instance"
            self.created_resources.append(f"GCP Compute Instance: {instance_name}")
            logger.info(f"✅ GCP Compute 인스턴스 생성 시뮬레이션 완료: {instance_name}")
            
            self.completed_days.append("day2")
            logger.info("✅ 2일차 GCP 기초 실습 완료")
            return True
            
        except Exception as e:
            logger.error(f"❌ 2일차 GCP 기초 실습 실패: {e}")
            return False
    
    def cleanup_resources(self) -> bool:
        """생성된 리소스 정리"""
        logger.info("🧹 리소스 정리 시작")
        
        try:
            # AWS 리소스 정리
            if self.aws_client:
                # VPC 삭제 (서브넷과 함께)
                vpcs = self.aws_client.describe_vpcs(
                    Filters=[{'Name': 'tag:Name', 'Values': [f"{self.config['project_prefix']}-vpc"]}]
                )
                for vpc in vpcs['Vpcs']:
                    self.aws_client.delete_vpc(VpcId=vpc['VpcId'])
                    logger.info(f"✅ VPC 삭제 완료: {vpc['VpcId']}")
            
            # GCP 리소스 정리
            if self.gcp_client:
                buckets = list(self.gcp_client.list_buckets())
                for bucket in buckets:
                    if self.config['project_prefix'] in bucket.name:
                        bucket.delete()
                        logger.info(f"✅ GCP Storage 버킷 삭제 완료: {bucket.name}")
            
            logger.info("✅ 리소스 정리 완료")
            return True
            
        except Exception as e:
            logger.error(f"❌ 리소스 정리 실패: {e}")
            return False
    
    def generate_report(self) -> Dict[str, Any]:
        """실습 보고서 생성"""
        report = {
            "course_name": self.course_name,
            "duration_days": self.duration_days,
            "status": self.status,
            "completed_days": self.completed_days,
            "created_resources": self.created_resources,
            "completion_rate": len(self.completed_days) / self.duration_days * 100,
            "timestamp": datetime.now().isoformat()
        }
        
        # 보고서 파일 저장
        report_file = self.base_path / "automation_tests" / "basic_course_report.json"
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        
        logger.info(f"📄 보고서 저장: {report_file}")
        return report
    
    def run_course(self) -> bool:
        """전체 과정 실행"""
        logger.info(f"🚀 {self.course_name} 과정 시작")
        self.status = "in_progress"
        
        # 클라이언트 초기화
        if not self.initialize_clients():
            logger.error("❌ 클라이언트 초기화 실패")
            return False
        
        # 1일차 실습
        if not self.day1_aws_basics():
            logger.error("❌ 1일차 실습 실패")
            return False
        
        # 2일차 실습
        if not self.day2_gcp_basics():
            logger.error("❌ 2일차 실습 실패")
            return False
        
        # 보고서 생성
        report = self.generate_report()
        
        # 과정 완료
        self.status = "completed"
        logger.info(f"🎉 {self.course_name} 과정 완료!")
        logger.info(f"📊 완료율: {report['completion_rate']:.1f}%")
        
        return True

def main():
    """메인 함수"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Cloud Basic 과정 자동화')
    parser.add_argument('--base-path', type=str, default='.', 
                       help='기본 경로 (기본값: 현재 디렉토리)')
    parser.add_argument('--cleanup', action='store_true',
                       help='생성된 리소스 정리')
    parser.add_argument('--report-only', action='store_true',
                       help='보고서만 생성')
    
    args = parser.parse_args()
    
    base_path = Path(args.base_path).resolve()
    automation = BasicCourseAutomation(base_path)
    
    if args.cleanup:
        success = automation.cleanup_resources()
    elif args.report_only:
        report = automation.generate_report()
        print(json.dumps(report, ensure_ascii=False, indent=2))
        success = True
    else:
        success = automation.run_course()
    
    return 0 if success else 1

if __name__ == "__main__":
    sys.exit(main())