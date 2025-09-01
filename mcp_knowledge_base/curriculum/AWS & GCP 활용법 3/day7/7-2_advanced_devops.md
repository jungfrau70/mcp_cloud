# 7-2. 클라우드 기반 DevOps 심화 실습

## 학습 목표
- GitOps 워크플로우 구현
- 인프라 자동화 및 모니터링
- 고급 CI/CD 파이프라인 구축
- 클라우드 네이티브 아키텍처 설계

---

## GitOps 워크플로우

### GitOps 원칙
```
GitOps 핵심 원칙:
├── 선언적 (Declarative): 원하는 상태를 선언
├── 버전 관리 (Versioned): 모든 변경사항을 Git에 저장
├── 자동화 (Automated): 변경사항 자동 적용
└── 관찰 가능 (Observable): 상태 변화 실시간 모니터링
```

### ArgoCD를 사용한 GitOps
```yaml
# argocd-application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: bootcamp-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/username/bootcamp-repo
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

---

## 인프라 자동화

### Terraform + GitHub Actions
```yaml
# .github/workflows/terraform.yml
name: Terraform Infrastructure

on:
  push:
    branches: [ main ]
    paths: [ 'terraform/**' ]
  pull_request:
    branches: [ main ]
    paths: [ 'terraform/**' ]

jobs:
  terraform:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.5.0
    
    - name: Terraform Init
      working-directory: ./terraform
      run: terraform init
    
    - name: Terraform Format Check
      working-directory: ./terraform
      run: terraform fmt -check
    
    - name: Terraform Plan
      working-directory: ./terraform
      run: terraform plan -out=tfplan
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    
    - name: Terraform Apply
      if: github.ref == 'refs/heads/main'
      working-directory: ./terraform
      run: terraform apply tfplan
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

---

## 고급 CI/CD 파이프라인

### 멀티 스테이지 파이프라인
```yaml
# .github/workflows/advanced-deploy.yml
name: Advanced CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: ${{ env.IMAGE_NAME }}:${{ github.sha }}
        format: 'sarif'
        output: 'trivy-results.sarif'
    
    - name: Upload Trivy scan results
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'

  test:
    runs-on: ubuntu-latest
    needs: security-scan
    strategy:
      matrix:
        node-version: [16.x, 18.x]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: npm test
    
    - name: Run integration tests
      run: npm run test:integration

  build:
    runs-on: ubuntu-latest
    needs: test
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Log in to Container Registry
      uses: docker/login-action@v2
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Build and push Docker image
      uses: docker/build-push-action@v4
      with:
        context: .
        push: true
        tags: |
          ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
        cache-from: type=gha
        cache-to: type=gha,mode=max

  deploy-staging:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/develop'
    environment: staging
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to staging
      run: |
        echo "Deploying to staging environment"
        # 스테이징 환경 배포 스크립트

  deploy-production:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main'
    environment: production
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to production
      run: |
        echo "Deploying to production environment"
        # 프로덕션 환경 배포 스크립트
```

---

## 클라우드 네이티브 모니터링

### Prometheus + Grafana 설정
```yaml
# monitoring/prometheus-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    
    rule_files:
      - "rules/*.yaml"
    
    alerting:
      alertmanagers:
        - static_configs:
            - targets:
              - alertmanager:9093
    
    scrape_configs:
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
            action: keep
            regex: true
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
            action: replace
            target_label: __metrics_path__
            regex: (.+)
          - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
            action: replace
            regex: ([^:]+)(?::\d+)?;(\d+)
            replacement: $1:$2
            target_label: __address__
```

### Grafana 대시보드
```json
{
  "dashboard": {
    "title": "Bootcamp Application Metrics",
    "panels": [
      {
        "title": "CPU Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(container_cpu_usage_seconds_total{container=\"web-app\"}[5m])",
            "legendFormat": "CPU Usage"
          }
        ]
      },
      {
        "title": "Memory Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "container_memory_usage_bytes{container=\"web-app\"}",
            "legendFormat": "Memory Usage"
          }
        ]
      }
    ]
  }
}
```

---

## 자동화된 백업 및 복구

### AWS S3 백업 자동화
```python
# backup_lambda.py
import boto3
import json
from datetime import datetime

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    rds = boto3.client('rds')
    
    # RDS 스냅샷 생성
    timestamp = datetime.now().strftime('%Y-%m-%d-%H-%M-%S')
    snapshot_id = f"backup-{timestamp}"
    
    response = rds.create_db_snapshot(
        DBSnapshotIdentifier=snapshot_id,
        DBInstanceIdentifier='bootcamp-db'
    )
    
    # S3에 백업 메타데이터 저장
    backup_info = {
        'snapshot_id': snapshot_id,
        'timestamp': timestamp,
        'status': 'created'
    }
    
    s3.put_object(
        Bucket='backup-metadata',
        Key=f"backups/{snapshot_id}.json",
        Body=json.dumps(backup_info)
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps(f'Backup {snapshot_id} created successfully')
    }
```

### GCP Cloud Functions 백업
```python
# backup_function.py
from google.cloud import storage
from google.cloud import sql_v1
import json
from datetime import datetime

def backup_database(event, context):
    storage_client = storage.Client()
    sql_client = sql_v1.SqlInstancesServiceClient()
    
    # Cloud SQL 백업 생성
    timestamp = datetime.now().strftime('%Y-%m-%d-%H-%M-%S')
    backup_name = f"backup-{timestamp}"
    
    project_id = "your-project-id"
    instance = "bootcamp-instance"
    
    request = sql_v1.SqlBackupRunsInsertRequest(
        project=project_id,
        instance=instance,
        body=sql_v1.BackupRun(
            description=f"Automated backup {backup_name}"
        )
    )
    
    operation = sql_client.insert(request=request)
    
    # 백업 메타데이터를 Cloud Storage에 저장
    bucket = storage_client.bucket('backup-metadata')
    blob = bucket.blob(f"backups/{backup_name}.json")
    
    backup_info = {
        'backup_name': backup_name,
        'timestamp': timestamp,
        'status': 'created'
    }
    
    blob.upload_from_string(json.dumps(backup_info))
    
    return f'Backup {backup_name} created successfully'
```

---

## 인프라 테스트 자동화

### Terratest를 사용한 인프라 테스트
```go
// test/terraform_test.go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/gruntwork-io/terratest/modules/aws"
    "github.com/stretchr/testify/assert"
)

func TestTerraformBasicExample(t *testing.T) {
    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../terraform",
        Vars: map[string]interface{}{
            "environment": "test",
        },
    })

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    // VPC ID 가져오기
    vpcId := terraform.Output(t, terraformOptions, "vpc_id")
    
    // VPC가 존재하는지 확인
    vpc := aws.GetVpcById(t, vpcId, "ap-northeast-2")
    assert.NotNil(t, vpc)
    
    // VPC CIDR 블록 확인
    expectedCidr := "10.0.0.0/16"
    assert.Equal(t, expectedCidr, *vpc.CidrBlock)
}
```

---

## 실습 과제

### 기본 실습
1. **GitOps 워크플로우 구성**
2. **자동화된 CI/CD 파이프라인 구축**
3. **모니터링 대시보드 설정**

### 고급 실습
1. **멀티 클라우드 자동화 파이프라인**
2. **인프라 테스트 자동화**
3. **백업 및 재해 복구 자동화**

---

## 다음 단계
- 클라우드 네이티브 아키텍처 설계
- 마이크로서비스 아키텍처 구현
- 클라우드 보안 고급 주제
