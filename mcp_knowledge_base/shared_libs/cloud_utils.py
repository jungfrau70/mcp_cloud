"""
클라우드 공통 유틸리티 함수
AWS/GCP 공통 작업을 위한 유틸리티 클래스
"""

import boto3
import json
import logging
from typing import Dict, List, Optional, Any
from pathlib import Path

logger = logging.getLogger(__name__)

class CloudUtils:
    """클라우드 공통 유틸리티 클래스"""
    
    def __init__(self, config: Dict[str, Any]):
        """
        CloudUtils 초기화
        
        Args:
            config: 클라우드 설정 정보
        """
        self.config = config
        self.aws_region = config.get('aws_region', 'us-west-2')
        self.gcp_region = config.get('gcp_region', 'us-central1')
        self.project_prefix = config.get('project_prefix', 'cloud-training')
        
        # AWS 클라이언트 초기화
        self.aws_clients = {}
        self._init_aws_clients()
    
    def _init_aws_clients(self):
        """AWS 클라이언트 초기화"""
        try:
            self.aws_clients['ec2'] = boto3.client('ec2', region_name=self.aws_region)
            self.aws_clients['s3'] = boto3.client('s3', region_name=self.aws_region)
            self.aws_clients['iam'] = boto3.client('iam')
            logger.info("✅ AWS 클라이언트 초기화 완료")
        except Exception as e:
            logger.warning(f"⚠️ AWS 클라이언트 초기화 실패: {e}")
    
    def create_vpc(self, course_name: str, day: int) -> Optional[str]:
        """
        VPC 생성 (Basic 과정 Day2 연계)
        
        Args:
            course_name: 과정명 (basic, master, container)
            day: 일차 (1, 2, 3)
            
        Returns:
            VPC ID 또는 None
        """
        try:
            vpc_name = f"{self.project_prefix}-{course_name}-day{day}-vpc"
            
            response = self.aws_clients['ec2'].create_vpc(
                CidrBlock='10.0.0.0/16',
                TagSpecifications=[{
                    'ResourceType': 'vpc',
                    'Tags': [
                        {'Key': 'Name', 'Value': vpc_name},
                        {'Key': 'Course', 'Value': course_name},
                        {'Key': 'Day', 'Value': str(day)}
                    ]
                }]
            )
            
            vpc_id = response['Vpc']['VpcId']
            logger.info(f"✅ VPC 생성 완료: {vpc_id} ({vpc_name})")
            return vpc_id
            
        except Exception as e:
            logger.error(f"❌ VPC 생성 실패: {e}")
            return None
    
    def create_subnet(self, vpc_id: str, course_name: str, day: int) -> Optional[str]:
        """
        서브넷 생성 (Basic 과정 Day2 연계)
        
        Args:
            vpc_id: VPC ID
            course_name: 과정명
            day: 일차
            
        Returns:
            서브넷 ID 또는 None
        """
        try:
            subnet_name = f"{self.project_prefix}-{course_name}-day{day}-subnet"
            
            response = self.aws_clients['ec2'].create_subnet(
                VpcId=vpc_id,
                CidrBlock='10.0.1.0/24',
                AvailabilityZone=f"{self.aws_region}a",
                TagSpecifications=[{
                    'ResourceType': 'subnet',
                    'Tags': [
                        {'Key': 'Name', 'Value': subnet_name},
                        {'Key': 'Course', 'Value': course_name},
                        {'Key': 'Day', 'Value': str(day)}
                    ]
                }]
            )
            
            subnet_id = response['Subnet']['SubnetId']
            logger.info(f"✅ 서브넷 생성 완료: {subnet_id} ({subnet_name})")
            return subnet_id
            
        except Exception as e:
            logger.error(f"❌ 서브넷 생성 실패: {e}")
            return None
    
    def create_s3_bucket(self, course_name: str, day: int) -> Optional[str]:
        """
        S3 버킷 생성 (Basic 과정 Day1 연계)
        
        Args:
            course_name: 과정명
            day: 일차
            
        Returns:
            버킷명 또는 None
        """
        try:
            import time
            bucket_name = f"{self.project_prefix}-{course_name}-day{day}-{int(time.time())}"
            
            self.aws_clients['s3'].create_bucket(
                Bucket=bucket_name,
                CreateBucketConfiguration={'LocationConstraint': self.aws_region}
            )
            
            # 태그 설정
            self.aws_clients['s3'].put_bucket_tagging(
                Bucket=bucket_name,
                Tagging={
                    'TagSet': [
                        {'Key': 'Course', 'Value': course_name},
                        {'Key': 'Day', 'Value': str(day)}
                    ]
                }
            )
            
            logger.info(f"✅ S3 버킷 생성 완료: {bucket_name}")
            return bucket_name
            
        except Exception as e:
            logger.error(f"❌ S3 버킷 생성 실패: {e}")
            return None
    
    def create_iam_user(self, course_name: str, day: int) -> Optional[str]:
        """
        IAM 사용자 생성 (Basic 과정 Day1 연계)
        
        Args:
            course_name: 과정명
            day: 일차
            
        Returns:
            사용자명 또는 None
        """
        try:
            username = f"{self.project_prefix}-{course_name}-day{day}-user"
            
            response = self.aws_clients['iam'].create_user(
                UserName=username,
                Tags=[
                    {'Key': 'Course', 'Value': course_name},
                    {'Key': 'Day', 'Value': str(day)}
                ]
            )
            
            logger.info(f"✅ IAM 사용자 생성 완료: {username}")
            return username
            
        except Exception as e:
            logger.error(f"❌ IAM 사용자 생성 실패: {e}")
            return None
    
    def cleanup_resources(self, course_name: str, day: int) -> bool:
        """
        과정별 리소스 정리
        
        Args:
            course_name: 과정명
            day: 일차
            
        Returns:
            정리 성공 여부
        """
        try:
            # VPC 정리
            vpcs = self.aws_clients['ec2'].describe_vpcs(
                Filters=[
                    {'Name': 'tag:Course', 'Values': [course_name]},
                    {'Name': 'tag:Day', 'Values': [str(day)]}
                ]
            )
            
            for vpc in vpcs['Vpcs']:
                self.aws_clients['ec2'].delete_vpc(VpcId=vpc['VpcId'])
                logger.info(f"✅ VPC 삭제 완료: {vpc['VpcId']}")
            
            # S3 버킷 정리
            buckets = self.aws_clients['s3'].list_buckets()
            for bucket in buckets['Buckets']:
                if f"{self.project_prefix}-{course_name}-day{day}" in bucket['Name']:
                    # 버킷 비우기
                    objects = self.aws_clients['s3'].list_objects_v2(Bucket=bucket['Name'])
                    if 'Contents' in objects:
                        for obj in objects['Contents']:
                            self.aws_clients['s3'].delete_object(Bucket=bucket['Name'], Key=obj['Key'])
                    
                    # 버킷 삭제
                    self.aws_clients['s3'].delete_bucket(Bucket=bucket['Name'])
                    logger.info(f"✅ S3 버킷 삭제 완료: {bucket['Name']}")
            
            logger.info(f"✅ {course_name} Day{day} 리소스 정리 완료")
            return True
            
        except Exception as e:
            logger.error(f"❌ 리소스 정리 실패: {e}")
            return False
    
    def get_course_resources(self, course_name: str, day: int) -> Dict[str, List[str]]:
        """
        과정별 생성된 리소스 조회
        
        Args:
            course_name: 과정명
            day: 일차
            
        Returns:
            리소스 정보 딕셔너리
        """
        resources = {
            'vpcs': [],
            'subnets': [],
            'buckets': [],
            'users': []
        }
        
        try:
            # VPC 조회
            vpcs = self.aws_clients['ec2'].describe_vpcs(
                Filters=[
                    {'Name': 'tag:Course', 'Values': [course_name]},
                    {'Name': 'tag:Day', 'Values': [str(day)]}
                ]
            )
            resources['vpcs'] = [vpc['VpcId'] for vpc in vpcs['Vpcs']]
            
            # S3 버킷 조회
            buckets = self.aws_clients['s3'].list_buckets()
            resources['buckets'] = [
                bucket['Name'] for bucket in buckets['Buckets'] 
                if f"{self.project_prefix}-{course_name}-day{day}" in bucket['Name']
            ]
            
            logger.info(f"✅ {course_name} Day{day} 리소스 조회 완료")
            return resources
            
        except Exception as e:
            logger.error(f"❌ 리소스 조회 실패: {e}")
            return resources
