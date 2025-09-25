#!/usr/bin/env python3
"""
Container 과정 자동화 테스트
"""

import pytest
import tempfile
import shutil
from pathlib import Path
from unittest.mock import patch, MagicMock
import os

from .container_course_automation import ContainerCourseAutomation, CourseConfig, DayPlan

class TestContainerCourseAutomation:
    """Container 과정 자동화 테스트 클래스"""
    
    @pytest.fixture
    def temp_dir(self):
        """임시 디렉토리 생성"""
        temp_path = Path(tempfile.mkdtemp())
        yield temp_path
        shutil.rmtree(temp_path)
    
    @pytest.fixture
    def config(self):
        """테스트용 설정"""
        return CourseConfig(
            course_name="Test Container Course",
            duration_days=2,
            required_tools=["docker", "kubectl"]
        )
    
    @pytest.fixture
    def automation(self, config, temp_dir):
        """테스트용 자동화 객체"""
        with patch('container_course_automation.Path') as mock_path:
            mock_path.return_value.parent.parent.parent.parent = temp_dir
            return ContainerCourseAutomation(config)
    
    def test_config_initialization(self):
        """설정 초기화 테스트"""
        config = CourseConfig()
        assert config.course_name == "Cloud Container Course"
        assert config.duration_days == 2
        assert "docker" in config.required_tools
        assert "kubectl" in config.required_tools
    
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
        assert day_plans[0].title == "Kubernetes 및 GKE 고급 오케스트레이션"
        assert day_plans[1].day == 2
        assert day_plans[1].title == "고가용성 및 확장성 아키텍처"
    
    def test_kubernetes_advanced_script_generation(self, automation, temp_dir):
        """Kubernetes 고급 스크립트 생성 테스트"""
        automation.course_dir = temp_dir / "course"
        automation.course_dir.mkdir(parents=True)
        (automation.course_dir / "automation" / "day1").mkdir(parents=True)
        
        automation._create_kubernetes_advanced_script()
        
        script_path = automation.course_dir / "automation" / "day1" / "kubernetes_advanced.sh"
        assert script_path.exists()
        
        content = script_path.read_text(encoding='utf-8')
        assert "Kubernetes 고급 아키텍처 실습" in content
        assert "kubectl" in content
        assert "nginx-deployment.yaml" in content
    
    def test_gke_cluster_script_generation(self, automation, temp_dir):
        """GKE 클러스터 스크립트 생성 테스트"""
        automation.course_dir = temp_dir / "course"
        automation.course_dir.mkdir(parents=True)
        (automation.course_dir / "automation" / "day1").mkdir(parents=True)
        
        automation._create_gke_cluster_script()
        
        script_path = automation.course_dir / "automation" / "day1" / "gke_cluster.sh"
        assert script_path.exists()
        
        content = script_path.read_text(encoding='utf-8')
        assert "GKE 클러스터 생성" in content
        assert "gcloud container clusters create" in content
    
    def test_ecs_fargate_script_generation(self, automation, temp_dir):
        """ECS Fargate 스크립트 생성 테스트"""
        automation.course_dir = temp_dir / "course"
        automation.course_dir.mkdir(parents=True)
        (automation.course_dir / "automation" / "day1").mkdir(parents=True)
        
        automation._create_ecs_fargate_script()
        
        script_path = automation.course_dir / "automation" / "day1" / "ecs_fargate.sh"
        assert script_path.exists()
        
        content = script_path.read_text(encoding='utf-8')
        assert "AWS ECS Fargate" in content
        assert "aws ecs create-cluster" in content
    
    def test_advanced_cicd_script_generation(self, automation, temp_dir):
        """고급 CI/CD 스크립트 생성 테스트"""
        automation.course_dir = temp_dir / "course"
        automation.course_dir.mkdir(parents=True)
        (automation.course_dir / "automation" / "day1").mkdir(parents=True)
        
        automation._create_advanced_cicd_script()
        
        script_path = automation.course_dir / "automation" / "day1" / "advanced_cicd.sh"
        assert script_path.exists()
        
        content = script_path.read_text(encoding='utf-8')
        assert "고급 CI/CD 파이프라인" in content
        assert "GitHub Actions" in content
    
    def test_generate_day1_scripts(self, automation, temp_dir):
        """Day 1 스크립트 생성 테스트"""
        automation.course_dir = temp_dir / "course"
        automation.course_dir.mkdir(parents=True)
        (automation.course_dir / "automation" / "day1").mkdir(parents=True)
        
        result = automation.generate_day1_scripts()
        assert result is True
        
        # 생성된 스크립트들 확인
        scripts = [
            "kubernetes_advanced.sh",
            "gke_cluster.sh",
            "ecs_fargate.sh",
            "advanced_cicd.sh"
        ]
        
        for script in scripts:
            script_path = automation.course_dir / "automation" / "day1" / script
            assert script_path.exists()
    
    def test_generate_day2_scripts(self, automation, temp_dir):
        """Day 2 스크립트 생성 테스트"""
        automation.course_dir = temp_dir / "course"
        automation.course_dir.mkdir(parents=True)
        (automation.course_dir / "automation" / "day2").mkdir(parents=True)
        
        result = automation.generate_day2_scripts()
        assert result is True
        
        # 생성된 스크립트들 확인
        scripts = [
            "high_availability.sh",
            "monitoring.sh",
            "comprehensive_project.sh"
        ]
        
        for script in scripts:
            script_path = automation.course_dir / "automation" / "day2" / script
            assert script_path.exists()
    
    def test_save_results(self, automation, temp_dir):
        """결과 저장 테스트"""
        automation.course_dir = temp_dir / "course"
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
            required_tools=["docker"]
        )
        
        with patch('container_course_automation.Path') as mock_path:
            mock_path.return_value.parent.parent.parent.parent = tmp_path
            automation = ContainerCourseAutomation(config)
            
            with patch.object(automation, '_check_required_tools', return_value=[]):
                result = automation.run_course_automation()
                assert result is True
    
    def test_automation_with_missing_tools(self, tmp_path):
        """누락된 도구가 있는 경우 테스트"""
        config = CourseConfig(
            course_name="Missing Tools Test",
            duration_days=2,
            required_tools=["docker", "kubectl", "nonexistent-tool"]
        )
        
        with patch('container_course_automation.Path') as mock_path:
            mock_path.return_value.parent.parent.parent.parent = tmp_path
            automation = ContainerCourseAutomation(config)
            
            with patch.object(automation, '_check_required_tools', return_value=["nonexistent-tool"]):
                result = automation.run_course_automation()
                # 누락된 도구가 있어도 계속 진행
                assert result is True

if __name__ == "__main__":
    pytest.main([__file__])
