#!/usr/bin/env python3
"""
Cloud Container 과정 자동화 스크립트
Kubernetes, GKE, ECS, Fargate 실습 자동화

교재 연계성:
- Cloud Container 1일차: Kubernetes 및 GKE 고급 오케스트레이션
  * Kubernetes 고급 아키텍처 (150분)
  * 컨테이너 오케스트레이션 고급 기법 (150분)
  * AWS ECS 및 Fargate 심화 (120분)
  * 고급 CI/CD 파이프라인 (90분)

- Cloud Container 2일차: 고가용성 및 확장성 아키텍처
  * 고가용성 아키텍처 설계 (120분)
  * 로드 밸런싱 및 Auto Scaling (90분)
  * 모니터링 및 로깅 시스템 (90분)
  * 보안 및 네트워크 정책 (90분)

학습 시나리오: "Kubernetes 클러스터에서의 마이크로서비스 운영"
"""

import os
import sys
import json
import yaml
import time
import logging
from pathlib import Path
from typing import Dict, List, Any, Optional
import subprocess
from datetime import datetime

# 로깅 설정
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class CloudContainerCourseAutomation:
    """Cloud Container 과정 자동화 클래스"""
    
    def __init__(self, config_path: Optional[Path] = None):
        self.config_path = config_path or Path("cloud_container_config.json")
        self.course_config = self.load_course_config()
        self.shared_resources = self.load_shared_resources()
        
    def load_course_config(self) -> Dict[str, Any]:
        """과정 설정 로드"""
        default_config = {
            "course_name": "Cloud Container",
            "duration_days": 2,
            "prerequisites": ["Cloud Master"],
            "learning_objectives": [
                "Kubernetes 클러스터 구축 및 관리",
                "GKE, EKS, AKS 클러스터 운영",
                "컨테이너 오케스트레이션 실습",
                "고가용성 아키텍처 설계",
                "모니터링 및 로깅 설정"
            ],
            "practical_exercises": [
                "Kubernetes 기본 실습",
                "GKE 클러스터 생성",
                "ECS/Fargate 배포",
                "Helm 차트 관리",
                "모니터링 설정"
            ]
        }
        
        if self.config_path.exists():
            try:
                with open(self.config_path, 'r', encoding='utf-8') as f:
                    return {**default_config, **json.load(f)}
            except Exception as e:
                logger.warning(f"설정 파일 로드 실패: {e}")
        
        return default_config
    
    def load_shared_resources(self) -> Dict[str, Any]:
        """공유 리소스 로드"""
        shared_resources_path = Path("../../integrated_automation/shared_resources")
        
        resources = {
            "aws_resources": {},
            "gcp_resources": {},
            "docker_resources": {},
            "kubernetes_resources": {}
        }
        
        # 공유 리소스 파일들 로드
        for resource_file in ["shared_resources.json", "shared_state.json"]:
            file_path = shared_resources_path / resource_file
            if file_path.exists():
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                        resources.update(data)
                except Exception as e:
                    logger.warning(f"공유 리소스 로드 실패 {resource_file}: {e}")
        
        return resources
    
    def setup_environment(self) -> bool:
        """환경 설정"""
        logger.info("🔧 Cloud Container 과정 환경 설정 중...")
        
        try:
            # 필수 도구 확인
            required_tools = ["kubectl", "helm", "docker", "gcloud"]
            for tool in required_tools:
                if not self.check_tool_installation(tool):
                    logger.error(f"❌ 필수 도구 누락: {tool}")
                    return False
            
            # Kubernetes 클러스터 연결 확인
            if not self.check_kubernetes_connection():
                logger.warning("⚠️ Kubernetes 클러스터에 연결할 수 없습니다")
            
            logger.info("✅ 환경 설정 완료")
            return True
            
        except Exception as e:
            logger.error(f"❌ 환경 설정 실패: {e}")
            return False
    
    def check_tool_installation(self, tool: str) -> bool:
        """도구 설치 확인"""
        try:
            result = subprocess.run([tool, "--version"], 
                                  capture_output=True, text=True, timeout=10)
            return result.returncode == 0
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return False
    
    def check_kubernetes_connection(self) -> bool:
        """Kubernetes 클러스터 연결 확인"""
        try:
            result = subprocess.run(["kubectl", "cluster-info"], 
                                  capture_output=True, text=True, timeout=10)
            return result.returncode == 0
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return False
    
    def run_practical_exercises(self) -> bool:
        """실습 실행"""
        logger.info("💻 Cloud Container 실습 실행 중...")
        
        exercises = self.course_config.get("practical_exercises", [])
        
        for i, exercise in enumerate(exercises, 1):
            logger.info(f"📚 실습 {i}: {exercise}")
            
            try:
                if not self.execute_exercise(exercise, i):
                    logger.error(f"❌ 실습 {i} 실패: {exercise}")
                    return False
                
                logger.info(f"✅ 실습 {i} 완료: {exercise}")
                time.sleep(2)  # 실습 간 간격
                
            except Exception as e:
                logger.error(f"❌ 실습 {i} 오류: {e}")
                return False
        
        logger.info("🎉 모든 실습 완료!")
        return True
    
    def execute_exercise(self, exercise: str, exercise_num: int) -> bool:
        """개별 실습 실행"""
        exercise_commands = {
            "Kubernetes 기본 실습": [
                "kubectl get nodes",
                "kubectl get pods --all-namespaces",
                "kubectl create namespace cloud-container-test"
            ],
            "GKE 클러스터 생성": [
                "gcloud container clusters list",
                "gcloud config get-value project"
            ],
            "ECS/Fargate 배포": [
                "aws ecs list-clusters",
                "aws ecs list-services --cluster default"
            ],
            "Helm 차트 관리": [
                "helm list --all-namespaces",
                "helm repo list"
            ],
            "모니터링 설정": [
                "kubectl get pods -n kube-system | grep monitoring",
                "kubectl get services -n kube-system | grep prometheus"
            ]
        }
        
        commands = exercise_commands.get(exercise, [])
        
        for command in commands:
            try:
                logger.info(f"  실행: {command}")
                result = subprocess.run(command.split(), 
                                      capture_output=True, text=True, timeout=30)
                
                if result.returncode != 0:
                    logger.warning(f"  경고: {command} - {result.stderr}")
                else:
                    logger.info(f"  성공: {command}")
                    
            except subprocess.TimeoutExpired:
                logger.warning(f"  시간 초과: {command}")
            except Exception as e:
                logger.warning(f"  오류: {command} - {e}")
        
        return True
    
    def generate_report(self) -> Dict[str, Any]:
        """실습 보고서 생성"""
        report = {
            "course_name": self.course_config["course_name"],
            "completion_time": datetime.now().isoformat(),
            "learning_objectives": self.course_config["learning_objectives"],
            "practical_exercises": self.course_config["practical_exercises"],
            "shared_resources_used": self.shared_resources,
            "status": "completed"
        }
        
        # 보고서 저장
        report_path = Path("cloud_container_report.json")
        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        
        logger.info(f"📄 보고서 저장: {report_path}")
        return report
    
    def run_course(self) -> bool:
        """전체 과정 실행"""
        logger.info("🚀 Cloud Container 과정 시작")
        
        try:
            # 1. 환경 설정
            if not self.setup_environment():
                return False
            
            # 2. 실습 실행
            if not self.run_practical_exercises():
                return False
            
            # 3. 보고서 생성
            self.generate_report()
            
            logger.info("🎓 Cloud Container 과정 완료!")
            return True
            
        except Exception as e:
            logger.error(f"❌ 과정 실행 실패: {e}")
            return False

def main():
    """메인 함수"""
    try:
        automation = CloudContainerCourseAutomation()
        success = automation.run_course()
        
        if success:
            print("✅ Cloud Container 과정이 성공적으로 완료되었습니다!")
            sys.exit(0)
        else:
            print("❌ Cloud Container 과정 실행 중 오류가 발생했습니다.")
            sys.exit(1)
            
    except KeyboardInterrupt:
        print("\n⚠️ 사용자에 의해 중단되었습니다.")
        sys.exit(1)
    except Exception as e:
        print(f"❌ 예상치 못한 오류: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()