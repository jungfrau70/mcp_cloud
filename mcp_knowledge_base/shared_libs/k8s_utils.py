"""
Kubernetes 공통 유틸리티 함수
Container 과정의 K8s 실습을 위한 유틸리티 클래스
"""

import yaml
import json
import logging
import time
from typing import Dict, List, Optional, Any
from pathlib import Path

logger = logging.getLogger(__name__)

class K8sUtils:
    """Kubernetes 공통 유틸리티 클래스"""
    
    def __init__(self, config: Dict[str, Any]):
        """
        K8sUtils 초기화
        
        Args:
            config: Kubernetes 설정 정보
        """
        self.config = config
        self.project_prefix = config.get('project_prefix', 'cloud-training')
        self.namespace = config.get('namespace', 'default')
        self.gcp_project = config.get('gcp_project', '')
        self.gcp_region = config.get('gcp_region', 'us-central1')
        
        logger.info("✅ K8sUtils 초기화 완료")
    
    def create_deployment_manifest(self, course_name: str, day: int) -> Optional[Path]:
        """
        Deployment 매니페스트 생성 (Container 과정 Day1 연계)
        
        Args:
            course_name: 과정명
            day: 일차
            
        Returns:
            매니페스트 파일 경로 또는 None
        """
        try:
            manifests_dir = Path(f"k8s_manifests/{course_name}_day{day}")
            manifests_dir.mkdir(parents=True, exist_ok=True)
            
            # Deployment 매니페스트
            deployment = {
                'apiVersion': 'apps/v1',
                'kind': 'Deployment',
                'metadata': {
                    'name': f'{self.project_prefix}-{course_name}-day{day}-deployment',
                    'labels': {
                        'app': f'{self.project_prefix}-{course_name}-day{day}',
                        'course': course_name,
                        'day': str(day)
                    }
                },
                'spec': {
                    'replicas': 3,
                    'selector': {
                        'matchLabels': {
                            'app': f'{self.project_prefix}-{course_name}-day{day}'
                        }
                    },
                    'template': {
                        'metadata': {
                            'labels': {
                                'app': f'{self.project_prefix}-{course_name}-day{day}',
                                'course': course_name,
                                'day': str(day)
                            }
                        },
                        'spec': {
                            'containers': [{
                                'name': f'{course_name}-day{day}-app',
                                'image': f'{self.project_prefix}-{course_name}-day{day}:latest',
                                'ports': [{'containerPort': 3000}],
                                'env': [
                                    {'name': 'NODE_ENV', 'value': 'production'},
                                    {'name': 'COURSE', 'value': course_name},
                                    {'name': 'DAY', 'value': str(day)}
                                ],
                                'resources': {
                                    'requests': {
                                        'memory': '128Mi',
                                        'cpu': '100m'
                                    },
                                    'limits': {
                                        'memory': '256Mi',
                                        'cpu': '200m'
                                    }
                                },
                                'livenessProbe': {
                                    'httpGet': {
                                        'path': '/health',
                                        'port': 3000
                                    },
                                    'initialDelaySeconds': 30,
                                    'periodSeconds': 10
                                },
                                'readinessProbe': {
                                    'httpGet': {
                                        'path': '/ready',
                                        'port': 3000
                                    },
                                    'initialDelaySeconds': 5,
                                    'periodSeconds': 5
                                }
                            }]
                        }
                    }
                }
            }
            
            with open(manifests_dir / "deployment.yaml", 'w') as f:
                yaml.dump(deployment, f, default_flow_style=False)
            
            # Service 매니페스트
            service = {
                'apiVersion': 'v1',
                'kind': 'Service',
                'metadata': {
                    'name': f'{self.project_prefix}-{course_name}-day{day}-service',
                    'labels': {
                        'app': f'{self.project_prefix}-{course_name}-day{day}',
                        'course': course_name,
                        'day': str(day)
                    }
                },
                'spec': {
                    'selector': {
                        'app': f'{self.project_prefix}-{course_name}-day{day}'
                    },
                    'ports': [{
                        'port': 80,
                        'targetPort': 3000,
                        'protocol': 'TCP'
                    }],
                    'type': 'ClusterIP'
                }
            }
            
            with open(manifests_dir / "service.yaml", 'w') as f:
                yaml.dump(service, f, default_flow_style=False)
            
            # Ingress 매니페스트
            ingress = {
                'apiVersion': 'networking.k8s.io/v1',
                'kind': 'Ingress',
                'metadata': {
                    'name': f'{self.project_prefix}-{course_name}-day{day}-ingress',
                    'labels': {
                        'app': f'{self.project_prefix}-{course_name}-day{day}',
                        'course': course_name,
                        'day': str(day)
                    },
                    'annotations': {
                        'kubernetes.io/ingress.class': 'nginx',
                        'nginx.ingress.kubernetes.io/rewrite-target': '/'
                    }
                },
                'spec': {
                    'rules': [{
                        'host': f'{course_name}-day{day}.{self.project_prefix}.local',
                        'http': {
                            'paths': [{
                                'path': '/',
                                'pathType': 'Prefix',
                                'backend': {
                                    'service': {
                                        'name': f'{self.project_prefix}-{course_name}-day{day}-service',
                                        'port': {'number': 80}
                                    }
                                }
                            }]
                        }
                    }]
                }
            }
            
            with open(manifests_dir / "ingress.yaml", 'w') as f:
                yaml.dump(ingress, f, default_flow_style=False)
            
            # ConfigMap 매니페스트
            configmap = {
                'apiVersion': 'v1',
                'kind': 'ConfigMap',
                'metadata': {
                    'name': f'{self.project_prefix}-{course_name}-day{day}-config',
                    'labels': {
                        'app': f'{self.project_prefix}-{course_name}-day{day}',
                        'course': course_name,
                        'day': str(day)
                    }
                },
                'data': {
                    'app.properties': f'''course.name={course_name}
course.day={day}
app.version=1.0.0
environment=production
''',
                    'nginx.conf': '''server {
    listen 80;
    server_name localhost;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
'''
                }
            }
            
            with open(manifests_dir / "configmap.yaml", 'w') as f:
                yaml.dump(configmap, f, default_flow_style=False)
            
            # Secret 매니페스트
            secret = {
                'apiVersion': 'v1',
                'kind': 'Secret',
                'metadata': {
                    'name': f'{self.project_prefix}-{course_name}-day{day}-secret',
                    'labels': {
                        'app': f'{self.project_prefix}-{course_name}-day{day}',
                        'course': course_name,
                        'day': str(day)
                    }
                },
                'type': 'Opaque',
                'data': {
                    'database-url': 'bW9uZ29kYjovL2xvY2FsaG9zdDozMjcxLw==',  # base64 encoded
                    'api-key': 'c2VjcmV0LWFwaS1rZXk='  # base64 encoded
                }
            }
            
            with open(manifests_dir / "secret.yaml", 'w') as f:
                yaml.dump(secret, f, default_flow_style=False)
            
            # PersistentVolumeClaim 매니페스트
            pvc = {
                'apiVersion': 'v1',
                'kind': 'PersistentVolumeClaim',
                'metadata': {
                    'name': f'{self.project_prefix}-{course_name}-day{day}-pvc',
                    'labels': {
                        'app': f'{self.project_prefix}-{course_name}-day{day}',
                        'course': course_name,
                        'day': str(day)
                    }
                },
                'spec': {
                    'accessModes': ['ReadWriteOnce'],
                    'resources': {
                        'requests': {
                            'storage': '1Gi'
                        }
                    }
                }
            }
            
            with open(manifests_dir / "pvc.yaml", 'w') as f:
                yaml.dump(pvc, f, default_flow_style=False)
            
            logger.info(f"✅ K8s 매니페스트 생성 완료: {manifests_dir}")
            return manifests_dir
            
        except Exception as e:
            logger.error(f"❌ K8s 매니페스트 생성 실패: {e}")
            return None
    
    def create_helm_chart(self, course_name: str, day: int) -> Optional[Path]:
        """
        Helm 차트 생성 (Container 과정 Day1 연계)
        
        Args:
            course_name: 과정명
            day: 일차
            
        Returns:
            Helm 차트 디렉토리 경로 또는 None
        """
        try:
            chart_dir = Path(f"helm_charts/{course_name}_day{day}")
            chart_dir.mkdir(parents=True, exist_ok=True)
            
            # Chart.yaml
            chart_yaml = {
                'apiVersion': 'v2',
                'name': f'{self.project_prefix}-{course_name}-day{day}',
                'description': f'Cloud Training {course_name.title()} Day {day} Helm Chart',
                'type': 'application',
                'version': '0.1.0',
                'appVersion': '1.0.0',
                'keywords': ['cloud', 'training', course_name, f'day{day}'],
                'home': f'https://github.com/your-repo/{self.project_prefix}',
                'sources': [f'https://github.com/your-repo/{self.project_prefix}'],
                'maintainers': [{
                    'name': 'Cloud Training Team',
                    'email': 'training@example.com'
                }]
            }
            
            with open(chart_dir / "Chart.yaml", 'w') as f:
                yaml.dump(chart_yaml, f, default_flow_style=False)
            
            # values.yaml
            values_yaml = {
                'replicaCount': 3,
                'image': {
                    'repository': f'{self.project_prefix}-{course_name}-day{day}',
                    'pullPolicy': 'IfNotPresent',
                    'tag': 'latest'
                },
                'service': {
                    'type': 'ClusterIP',
                    'port': 80,
                    'targetPort': 3000
                },
                'ingress': {
                    'enabled': True,
                    'className': 'nginx',
                    'annotations': {
                        'nginx.ingress.kubernetes.io/rewrite-target': '/'
                    },
                    'hosts': [{
                        'host': f'{course_name}-day{day}.{self.project_prefix}.local',
                        'paths': [{'path': '/', 'pathType': 'Prefix'}]
                    }],
                    'tls': []
                },
                'resources': {
                    'limits': {
                        'cpu': '200m',
                        'memory': '256Mi'
                    },
                    'requests': {
                        'cpu': '100m',
                        'memory': '128Mi'
                    }
                },
                'autoscaling': {
                    'enabled': True,
                    'minReplicas': 2,
                    'maxReplicas': 10,
                    'targetCPUUtilizationPercentage': 80
                },
                'nodeSelector': {},
                'tolerations': [],
                'affinity': {}
            }
            
            with open(chart_dir / "values.yaml", 'w') as f:
                yaml.dump(values_yaml, f, default_flow_style=False)
            
            # templates 디렉토리 생성
            templates_dir = chart_dir / "templates"
            templates_dir.mkdir(exist_ok=True)
            
            # _helpers.tpl
            helpers_tpl = '''{{/*
Expand the name of the chart.
*/}}
{{- define "{{ include "{{ .Chart.Name }}.fullname" . }}-name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "{{ include "{{ .Chart.Name }}.fullname" . }}-fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "{{ include "{{ .Chart.Name }}.fullname" . }}-chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "{{ include "{{ .Chart.Name }}.fullname" . }}-labels" -}}
helm.sh/chart: {{ include "{{ include "{{ .Chart.Name }}.fullname" . }}-chart" . }}
{{ include "{{ include "{{ .Chart.Name }}.fullname" . }}-selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "{{ include "{{ .Chart.Name }}.fullname" . }}-selectorLabels" -}}
app.kubernetes.io/name: {{ include "{{ include "{{ .Chart.Name }}.fullname" . }}-name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
'''
            
            with open(templates_dir / "_helpers.tpl", 'w') as f:
                f.write(helpers_tpl)
            
            logger.info(f"✅ Helm 차트 생성 완료: {chart_dir}")
            return chart_dir
            
        except Exception as e:
            logger.error(f"❌ Helm 차트 생성 실패: {e}")
            return None
    
    def create_gke_cluster_config(self, course_name: str, day: int) -> Optional[Path]:
        """
        GKE 클러스터 설정 생성 (Container 과정 Day1 연계)
        
        Args:
            course_name: 과정명
            day: 일차
            
        Returns:
            설정 파일 경로 또는 None
        """
        try:
            config_dir = Path(f"gke_configs/{course_name}_day{day}")
            config_dir.mkdir(parents=True, exist_ok=True)
            
            # 클러스터 설정
            cluster_config = {
                'name': f'{self.project_prefix}-{course_name}-day{day}-cluster',
                'location': self.gcp_region,
                'nodePools': [{
                    'name': 'default-pool',
                    'initialNodeCount': 3,
                    'config': {
                        'machineType': 'e2-medium',
                        'diskSizeGb': 20,
                        'diskType': 'pd-standard',
                        'imageType': 'COS_CONTAINERD',
                        'preemptible': False
                    },
                    'autoscaling': {
                        'enabled': True,
                        'minNodeCount': 1,
                        'maxNodeCount': 5
                    },
                    'management': {
                        'autoUpgrade': True,
                        'autoRepair': True
                    }
                }],
                'networkConfig': {
                    'enableIntraNodeVisibility': True
                },
                'addonsConfig': {
                    'httpLoadBalancing': {
                        'disabled': False
                    },
                    'horizontalPodAutoscaling': {
                        'disabled': False
                    },
                    'networkPolicyConfig': {
                        'disabled': False
                    }
                },
                'masterAuth': {
                    'clientCertificateConfig': {
                        'issueClientCertificate': False
                    }
                }
            }
            
            with open(config_dir / "cluster_config.yaml", 'w') as f:
                yaml.dump(cluster_config, f, default_flow_style=False)
            
            # 노드 풀 설정
            node_pool_config = {
                'name': f'{self.project_prefix}-{course_name}-day{day}-pool',
                'config': {
                    'machineType': 'e2-standard-2',
                    'diskSizeGb': 50,
                    'diskType': 'pd-ssd',
                    'imageType': 'COS_CONTAINERD',
                    'preemptible': False,
                    'oauthScopes': [
                        'https://www.googleapis.com/auth/cloud-platform'
                    ]
                },
                'autoscaling': {
                    'enabled': True,
                    'minNodeCount': 2,
                    'maxNodeCount': 10
                },
                'management': {
                    'autoUpgrade': True,
                    'autoRepair': True
                }
            }
            
            with open(config_dir / "node_pool_config.yaml", 'w') as f:
                yaml.dump(node_pool_config, f, default_flow_style=False)
            
            # 배포 스크립트
            deploy_script = f'''#!/bin/bash
# GKE 클러스터 생성 및 배포 스크립트
# Course: {course_name}, Day: {day}

set -e

# 변수 설정
PROJECT_ID="{self.gcp_project}"
CLUSTER_NAME="{self.project_prefix}-{course_name}-day{day}-cluster"
REGION="{self.gcp_region}"
ZONE="{self.gcp_region}-a"

echo "🚀 GKE 클러스터 생성 시작: $CLUSTER_NAME"

# GCP 프로젝트 설정
gcloud config set project $PROJECT_ID

# 클러스터 생성
gcloud container clusters create $CLUSTER_NAME \\
    --region=$REGION \\
    --num-nodes=3 \\
    --machine-type=e2-medium \\
    --disk-size=20 \\
    --disk-type=pd-standard \\
    --enable-autoscaling \\
    --min-nodes=1 \\
    --max-nodes=5 \\
    --enable-autorepair \\
    --enable-autoupgrade \\
    --enable-ip-alias \\
    --enable-network-policy

echo "✅ GKE 클러스터 생성 완료: $CLUSTER_NAME"

# 클러스터 인증 정보 가져오기
gcloud container clusters get-credentials $CLUSTER_NAME --region=$REGION

echo "✅ 클러스터 인증 정보 설정 완료"

# 네임스페이스 생성
kubectl create namespace {self.namespace}

echo "✅ 네임스페이스 생성 완료: {self.namespace}"

# 애플리케이션 배포
kubectl apply -f ../k8s_manifests/{course_name}_day{day}/

echo "✅ 애플리케이션 배포 완료"

# 상태 확인
kubectl get pods -n {self.namespace}
kubectl get services -n {self.namespace}
kubectl get ingress -n {self.namespace}

echo "🎉 GKE 클러스터 설정 및 배포 완료!"
'''
            
            with open(config_dir / "deploy.sh", 'w') as f:
                f.write(deploy_script)
            
            # 실행 권한 부여
            import os
            os.chmod(config_dir / "deploy.sh", 0o755)
            
            logger.info(f"✅ GKE 클러스터 설정 생성 완료: {config_dir}")
            return config_dir
            
        except Exception as e:
            logger.error(f"❌ GKE 클러스터 설정 생성 실패: {e}")
            return None
