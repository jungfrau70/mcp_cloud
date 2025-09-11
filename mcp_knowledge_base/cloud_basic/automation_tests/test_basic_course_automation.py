#!/usr/bin/env python3
"""
Basic 과정 자동화 테스트
"""

import pytest
import tempfile
import shutil
from pathlib import Path
from unittest.mock import patch, MagicMock
import os

from basic_course_automation import BasicCourseAutomation, CourseConfig, DayPlan

class TestBasicCourseAutomation:
    """Basic 과정 자동화 테스트 클래스"""
    
    @pytest.fixture
    def config(self):
        """테스트용 설정"""
        return CourseConfig(
            course_name="Test Basic Course",
            duration_days=2,
            required_tools=["aws-cli"]
        )
    
    @pytest.fixture
    def automation(self, config, tmp_path):
        """테스트용 자동화 객체"""
        with patch('basic_course_automation.Path') as mock_path:
            mock_path.return_value.parent.parent.parent.parent = tmp_path
            return BasicCourseAutomation(config)
    
    def test_config_initialization(self):
        """설정 초기화 테스트"""
        config = CourseConfig()
        assert config.course_name == "Cloud Basic Course"
        assert config.duration_days == 2
        assert "aws-cli" in config.required_tools
        assert "gcloud-cli" in config.required_tools
    
    def test_setup_environment_variables(self, automation):
        """환경 변수 설정 테스트"""
        with patch.object(automation, '_check_required_tools', return_value=[]):
            with patch.object(automation, '_create_directories'):
                result = automation.setup_environment()
                assert result is True
                assert os.environ.get('COURSE_NAME') == automation.config.course_name
    
    def test_create_day_plans(self, automation):
        """일일 계획 생성 테스트"""
        day_plans = automation.create_day_plans()
        
        assert len(day_plans) == 2
        assert day_plans[0].day == 1
        assert day_plans[0].title == "AWS & GCP 기초 서비스 실습"
        assert day_plans[1].day == 2
        assert day_plans[1].title == "네트워크, 보안 및 데이터베이스 실습"
    
    def test_cloud_basics_script_generation(self, automation, tmp_path):
        """클라우드 기초 스크립트 생성 테스트"""
        automation.course_dir = tmp_path / "course"
        automation.course_dir.mkdir(parents=True)
        (automation.course_dir / "automation" / "day1").mkdir(parents=True)
        
        automation._create_cloud_basics_script()
        
        script_path = automation.course_dir / "automation" / "day1" / "cloud_basics.sh"
        assert script_path.exists()
        
        content = script_path.read_text(encoding='utf-8')
        assert "클라우드 기초 실습" in content
        assert "aws sts get-caller-identity" in content
        assert "gcloud auth list" in content
    
    def test_iam_script_generation(self, automation, tmp_path):
        """IAM 실습 스크립트 생성 테스트"""
        automation.course_dir = tmp_path / "course"
        automation.course_dir.mkdir(parents=True)
        (automation.course_dir / "automation" / "day1").mkdir(parents=True)
        
        automation._create_iam_script()
        
        script_path = automation.course_dir / "automation" / "day1" / "iam_basics.sh"
        assert script_path.exists()
        
        content = script_path.read_text(encoding='utf-8')
        assert "IAM 기초 실습" in content
        assert "aws iam create-user" in content
        assert "gcloud iam service-accounts create" in content
    
    def test_vm_services_script_generation(self, automation, tmp_path):
        """가상머신 서비스 스크립트 생성 테스트"""
        automation.course_dir = tmp_path / "course"
        automation.course_dir.mkdir(parents=True)
        (automation.course_dir / "automation" / "day1").mkdir(parents=True)
        
        automation._create_vm_services_script()
        
        script_path = automation.course_dir / "automation" / "day1" / "vm_services.sh"
        assert script_path.exists()
        
        content = script_path.read_text(encoding='utf-8')
        assert "가상머신 서비스 기초 실습" in content
        assert "aws ec2 run-instances" in content
        assert "gcloud compute instances create" in content
    
    def test_storage_services_script_generation(self, automation, tmp_path):
        """스토리지 서비스 스크립트 생성 테스트"""
        automation.course_dir = tmp_path / "course"
        automation.course_dir.mkdir(parents=True)
        (automation.course_dir / "automation" / "day1").mkdir(parents=True)
        
        automation._create_storage_services_script()
        
        script_path = automation.course_dir / "automation" / "day1" / "storage_services.sh"
        assert script_path.exists()
        
        content = script_path.read_text(encoding='utf-8')
        assert "스토리지 서비스 기초 실습" in content
        assert "aws s3 mb" in content
        assert "gsutil mb" in content
    
    def test_generate_day1_scripts(self, automation, tmp_path):
        """Day 1 스크립트 생성 테스트"""
        automation.course_dir = tmp_path / "course"
        automation.course_dir.mkdir(parents=True)
        (automation.course_dir / "automation" / "day1").mkdir(parents=True)
        
        result = automation.generate_day1_scripts()
        assert result is True
        
        # 생성된 스크립트들 확인
        scripts = [
            "cloud_basics.sh",
            "iam_basics.sh",
            "vm_services.sh",
            "storage_services.sh"
        ]
        
        for script in scripts:
            script_path = automation.course_dir / "automation" / "day1" / script
            assert script_path.exists()
    
    def test_generate_day2_scripts(self, automation, tmp_path):
        """Day 2 스크립트 생성 테스트"""
        automation.course_dir = tmp_path / "course"
        automation.course_dir.mkdir(parents=True)
        (automation.course_dir / "automation" / "day2").mkdir(parents=True)
        
        result = automation.generate_day2_scripts()
        assert result is True
        
        # 생성된 스크립트들 확인
        scripts = [
            "networking_basics.sh",
            "security_basics.sh",
            "database_services.sh",
            "comprehensive_practice.sh"
        ]
        
        for script in scripts:
            script_path = automation.course_dir / "automation" / "day2" / script
            assert script_path.exists()
    
    def test_save_results(self, automation, tmp_path):
        """결과 저장 테스트"""
        automation.course_dir = tmp_path / "course"
        automation.course_dir.mkdir(parents=True)
        (automation.course_dir / "automation" / "results").mkdir(parents=True)
        
        day_plans = automation.create_day_plans()
        automation._save_results(day_plans)
        
        results_file = automation.course_dir / "automation" / "results" / "automation_results.json"
        assert results_file.exists()
        
        import json
        results = json.loads(results_file.read_text(encoding='utf-8'))
        assert results["course_name"] == automation.config.course_name
        assert len(results["day_plans"]) == 2

class TestIntegration:
    """통합 테스트"""
    
    def test_full_automation_success(self, tmp_path):
        """전체 자동화 성공 테스트"""
        config = CourseConfig(
            course_name="Integration Test Course",
            duration_days=2,
            required_tools=["aws-cli"]
        )
        
        with patch('basic_course_automation.Path') as mock_path:
            mock_path.return_value.parent.parent.parent.parent = tmp_path
            automation = BasicCourseAutomation(config)
            
            with patch.object(automation, '_check_required_tools', return_value=[]):
                result = automation.run_course_automation()
                assert result is True
    
    def test_automation_with_missing_tools(self, tmp_path):
        """누락된 도구가 있는 경우 테스트"""
        config = CourseConfig(
            course_name="Missing Tools Test",
            duration_days=2,
            required_tools=["aws-cli", "gcloud-cli", "nonexistent-tool"]
        )
        
        with patch('basic_course_automation.Path') as mock_path:
            mock_path.return_value.parent.parent.parent.parent = tmp_path
            automation = BasicCourseAutomation(config)
            
            with patch.object(automation, '_check_required_tools', return_value=["nonexistent-tool"]):
                result = automation.run_course_automation()
                # 누락된 도구가 있어도 계속 진행
                assert result is True

if __name__ == "__main__":
    pytest.main([__file__])
