#!/usr/bin/env python3
"""
Container 과정 Day 2 스크립트 생성 모듈
고가용성, 모니터링, 종합 프로젝트 스크립트
"""

from pathlib import Path

def create_high_availability_script(course_dir: Path):
    """고가용성 아키텍처 스크립트 생성"""
    script_content = '''#!/bin/bash
# 고가용성 아키텍처 실습 스크립트

set -e

echo "고가용성 아키텍처 실습 시작..."

# AWS Multi-AZ 설정
echo "AWS Multi-AZ 설정 중..."
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=ha-vpc}]'

# GCP Multi-Region 설정
echo "GCP Multi-Region 설정 중..."
gcloud compute instances create ha-instance-1 --zone=us-central1-a --image-family=ubuntu-2004-lts
gcloud compute instances create ha-instance-2 --zone=us-central1-b --image-family=ubuntu-2004-lts

echo "고가용성 아키텍처 실습 완료!"
'''
    
    script_path = course_dir / "automation" / "day2" / "high_availability.sh"
    script_path.write_text(script_content, encoding='utf-8')
    script_path.chmod(0o755)

def create_monitoring_script(course_dir: Path):
    """모니터링 및 로깅 스크립트 생성"""
    script_content = '''#!/bin/bash
# 모니터링 및 로깅 시스템 실습 스크립트

set -e

echo "모니터링 및 로깅 시스템 실습 시작..."

# Prometheus 설정
cat > prometheus.yml << 'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
    - role: pod
EOF

# Grafana 대시보드 설정
cat > grafana-dashboard.json << 'EOF'
{
  "dashboard": {
    "title": "Container Course Dashboard",
    "panels": [
      {
        "title": "CPU Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(cpu_usage_total[5m])"
          }
        ]
      }
    ]
  }
}
EOF

echo "모니터링 및 로깅 시스템 실습 완료!"
'''
    
    script_path = course_dir / "automation" / "day2" / "monitoring.sh"
    script_path.write_text(script_content, encoding='utf-8')
    script_path.chmod(0o755)

def create_comprehensive_project_script(course_dir: Path):
    """종합 프로젝트 스크립트 생성"""
    script_content = '''#!/bin/bash
# 종합 프로젝트 실습 스크립트

set -e

echo "종합 프로젝트 실습 시작..."

# 전체 아키텍처 배포
echo "전체 아키텍처 배포 중..."

# Kubernetes 클러스터 배포
kubectl apply -f k8s/

# 모니터링 스택 배포
helm install prometheus prometheus-community/kube-prometheus-stack

# 로드 밸런서 설정
kubectl apply -f ingress/

echo "종합 프로젝트 실습 완료!"
'''
    
    script_path = course_dir / "automation" / "day2" / "comprehensive_project.sh"
    script_path.write_text(script_content, encoding='utf-8')
    script_path.chmod(0o755)
