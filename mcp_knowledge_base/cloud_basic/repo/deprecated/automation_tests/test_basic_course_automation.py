import pytest
from unittest.mock import patch, MagicMock, ANY
from pathlib import Path

from .basic_course_automation import BasicCourseAutomation

@pytest.fixture
def automation():
    """Fixture to create a BasicCourseAutomation instance with mocked clients."""
    with patch('boto3.client') as mock_boto_client, \
         patch('googleapiclient.discovery.build') as mock_gcp_build:
        
        mock_iam = MagicMock()
        mock_ec2 = MagicMock()
        mock_s3 = MagicMock()
        
        def boto_side_effect(service_name, region_name=None):
            if service_name == 'iam':
                return mock_iam
            if service_name == 'ec2':
                mock_ec2.create_security_group.return_value = {'GroupId': 'sg-12345'}
                mock_ec2.run_instances.return_value = {'Instances': [{'InstanceId': 'i-12345'}]}
                return mock_ec2
            if service_name == 's3':
                return mock_s3
            return MagicMock()

        mock_boto_client.side_effect = boto_side_effect

        mock_gcp_iam_service = MagicMock()
        mock_gcp_compute_service = MagicMock()
        mock_gcp_storage_service = MagicMock()
        
        mock_images = MagicMock()
        mock_images.getFromFamily.return_value.execute.return_value = {'selfLink': 'dummy-image-link'}
        mock_gcp_compute_service.images.return_value = mock_images

        def gcp_side_effect(service_name, version):
            if service_name == 'iam':
                return mock_gcp_iam_service
            if service_name == 'compute':
                return mock_gcp_compute_service
            if service_name == 'storage':
                return mock_gcp_storage_service
            return MagicMock()

        mock_gcp_build.side_effect = gcp_side_effect

        automation_instance = BasicCourseAutomation(Path('/fake/path'))
        
        automation_instance.mock_aws_iam = mock_iam
        automation_instance.mock_aws_ec2 = mock_ec2
        automation_instance.mock_aws_s3 = mock_s3
        automation_instance.mock_gcp_iam = mock_gcp_iam_service
        automation_instance.mock_gcp_compute = mock_gcp_compute_service
        automation_instance.mock_gcp_storage = mock_gcp_storage_service
        
        yield automation_instance


class TestBasicCourseAutomation:
    """Tests for the updated BasicCourseAutomation script."""

    def test_day1_aws_basics(self, automation):
        """Verify that AWS resources are created correctly for Day 1."""
        result = automation.day1_aws_basics()
        assert result is True

        automation.mock_aws_iam.create_user.assert_called_once_with(
            UserName=f"{automation.config['project_prefix']}-user"
        )

        automation.mock_aws_ec2.create_security_group.assert_called_once_with(
            GroupName=f"{automation.config['project_prefix']}-sg",
            Description='Allow SSH, HTTP, HTTPS'
        )
        automation.mock_aws_ec2.authorize_security_group_ingress.assert_called_once()

        automation.mock_aws_ec2.run_instances.assert_called_once_with(
            ImageId=automation.config['aws_ami_id'],
            InstanceType='t2.micro',
            MinCount=1,
            MaxCount=1,
            SecurityGroupIds=['sg-12345'],
            TagSpecifications=[{'ResourceType': 'instance', 'Tags': [{'Key': 'Name', 'Value': f"{automation.config['project_prefix']}-instance"}]}]
        )

        automation.mock_aws_s3.create_bucket.assert_called_once_with(
            Bucket=ANY,
            CreateBucketConfiguration={'LocationConstraint': automation.config['aws_region']}
        )

    def test_day2_gcp_basics(self, automation):
        """Verify that GCP resources are created correctly for Day 2."""
        automation.config['gcp_project_id'] = 'mock-gcp-project'
        
        result = automation.day2_gcp_basics()
        assert result is True

        automation.mock_gcp_iam.projects().serviceAccounts().create.assert_called_once_with(
            name='projects/mock-gcp-project',
            body={'accountId': f"{automation.config['project_prefix']}-sa", 'serviceAccount': {'displayName': 'MCP Basic Course SA'}}
        )

        automation.mock_gcp_compute.instances().insert.assert_called_once()

        automation.mock_gcp_storage.buckets().insert.assert_called_once()

    def test_cleanup_aws_resources(self, automation):
        """Verify that AWS cleanup logic is called."""
        automation.created_resources["aws"] = [
            {"type": "ec2_instance", "id": "i-12345"},
            {"type": "security_group", "id": "sg-12345"},
            {"type": "iam_user", "name": "test-user"},
            {"type": "s3_bucket", "name": "test-bucket"}
        ]
        
        with patch('time.sleep'):
            automation.cleanup_resources()

            automation.mock_aws_ec2.terminate_instances.assert_called_once_with(InstanceIds=['i-12345'])
            automation.mock_aws_ec2.delete_security_group.assert_called_once_with(GroupId='sg-12345')
            automation.mock_aws_iam.delete_user.assert_called_once_with(UserName='test-user')
            automation.mock_aws_s3.delete_bucket.assert_called_once_with(Bucket='test-bucket')