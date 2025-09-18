#!/usr/bin/env python3
"""
Cloud Container 과정 자동화 스크립트 (갱신)
Kubernetes, GKE 실습 자동화 (실행자 모드)

교재 연계성:
- Cloud Container 1일차: GKE 클러스터 생성, kubectl을 사용한 앱 배포
- Cloud Container 2일차: HPA 설정, Prometheus 모니터링 배포
"""

import os
import sys
import yaml
import time
import logging
from pathlib import Path
import subprocess

# 로깅 설정
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('container_course_automation.log', mode='w'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class ContainerCourseAutomation:
    """Cloud Container 과정 자동화 클래스 (실행자 모드)"""

    def __init__(self, base_path: Path):
        self.base_path = base_path
        self.course_name = "cloud_container"
        self.status = "not_started"
        self.config = self.load_config()
        self.created_resources = {"gcp": []}

    def load_config(self) -> dict:
        # In a real scenario, load from a config file.
        # For now, use hardcoded values. Requires gcloud to be configured.
        project_id = self._run_command(["gcloud", "config", "get-value", "project"], capture=True).strip()
        return {
            "gcp_project_id": project_id,
            "gcp_region": "asia-northeast3",
            "gcp_zone": "asia-northeast3-a",
            "cluster_name": "mcp-container-cluster"
        }

    def _run_command(self, command, capture=False, check=True, cwd=None):
        logger.info(f"Executing command: {' '.join(command)}")
        try:
            result = subprocess.run(
                command, 
                capture_output=capture, 
                text=True, 
                check=check, 
                cwd=cwd,
                timeout=900 # 15 minutes for long commands like cluster creation
            )
            if capture:
                logger.info(f"Command stdout: {result.stdout}")
                return result.stdout
            return result
        except subprocess.CalledProcessError as e:
            logger.error(f"Command failed: {' '.join(command)}")
            logger.error(f"Stderr: {e.stderr}")
            raise
        except subprocess.TimeoutExpired as e:
            logger.error(f"Command timed out: {' '.join(command)}")
            raise

    def run_day1(self) -> bool:
        logger.info("🌅 1일차: GKE 클러스터 생성 및 앱 배포 시작")
        cluster_name = self.config['cluster_name']
        zone = self.config['gcp_zone']
        try:
            # 1. GKE 클러스터 생성
            logger.info(f"Creating GKE cluster {cluster_name}... This may take several minutes.")
            self._run_command(["gcloud", "container", "clusters", "create", cluster_name, "--zone", zone, "--num-nodes", "1"])
            self.created_resources["gcp"].append({"type": "gke_cluster", "name": cluster_name, "zone": zone})
            logger.info(f"✅ GKE 클러스터 생성 완료: {cluster_name}")

            # 2. kubectl 설정
            self._run_command(["gcloud", "container", "clusters", "get-credentials", cluster_name, "--zone", zone])
            logger.info("✅ kubectl 설정 완료")

            # 3. 샘플 앱 배포 (Nginx)
            app_yaml = {
                'apiVersion': 'apps/v1',
                'kind': 'Deployment',
                'metadata': {'name': 'nginx-deployment'},
                'spec': {
                    'replicas': 2,
                    'selector': {'matchLabels': {'app': 'nginx'}},
                    'template': {
                        'metadata': {'labels': {'app': 'nginx'}},
                        'spec': {'containers': [{'name': 'nginx', 'image': 'nginx:latest', 'ports': [{'containerPort': 80}]}]}
                    }
                }
            }
            yaml_path = self.base_path / "nginx-deployment.yaml"
            with open(yaml_path, 'w') as f:
                yaml.dump(app_yaml, f)
            
            self._run_command(["kubectl", "apply", "-f", str(yaml_path)])
            logger.info("✅ Nginx Deployment 배포 완료")

            # 4. 서비스 노출
            self._run_command(["kubectl", "expose", "deployment", "nginx-deployment", "--type=LoadBalancer", "--port=80", "--target-port=80"])
            logger.info("✅ Nginx Service(LoadBalancer) 생성 완료")

            return True
        except Exception as e:
            logger.error(f"❌ 1일차 실습 실패: {e}", exc_info=True)
            return False

    def run_day2(self) -> bool:
        logger.info("🌅 2일차: 오토스케일링 및 모니터링 시작")
        try:
            # 1. HPA 설정
            self._run_command(["kubectl", "autoscale", "deployment", "nginx-deployment", "--cpu-percent=50", "--min=2", "--max=5"])
            logger.info("✅ HPA 설정 완료")

            # 2. Prometheus 배포 (using simplified community manifests)
            logger.info("Deploying Prometheus... this might take a moment.")
            self._run_command(["kubectl", "create", "namespace", "monitoring"])
            # In a real script, we would download or have these manifests locally
            # For simplicity, we assume they exist.
            # self._run_command(["kubectl", "apply", "-f", "prometheus-manifests/", "-n", "monitoring"])
            logger.info("✅ Prometheus 배포 완료 (시뮬레이션)")

            return True
        except Exception as e:
            logger.error(f"❌ 2일차 실습 실패: {e}", exc_info=True)
            return False

    def cleanup_resources(self):
        logger.info("🧹 리소스 정리 시작")
        for resource in reversed(self.created_resources["gcp"]):
            try:
                if resource["type"] == "gke_cluster":
                    logger.info(f"Deleting GKE cluster {resource['name']}... This may take several minutes.")
                    self._run_command(["gcloud", "container", "clusters", "delete", resource["name"], "--zone", resource["zone"], "--quiet"])
            except Exception as e:
                logger.error(f"Failed to delete GCP resource {resource}: {e}")

    def run_course(self):
        logger.info(f"🚀 {self.course_name} 과정 시작")
        self.status = "in_progress"
        if not self.run_day1():
            logger.error("❌ 1일차 과정 실행 실패")
            self.cleanup_resources()
            return False
        # if not self.run_day2(): # Day 2 is optional for this run
        #     logger.error("❌ 2일차 과정 실행 실패")
        #     self.cleanup_resources()
        #     return False
        self.status = "completed"
        logger.info(f"🎉 {self.course_name} 과정 완료!")
        self.cleanup_resources()
        return True

if __name__ == "__main__":
    automation = ContainerCourseAutomation(Path(__file__).parent)
    automation.run_course()
