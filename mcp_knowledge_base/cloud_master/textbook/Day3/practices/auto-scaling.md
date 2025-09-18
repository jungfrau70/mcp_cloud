# 오토 스케일링 실습 가이드

## 🎯 학습 목표

### 핵심 학습 목표
- **AWS Auto Scaling** EC2 Auto Scaling Groups 및 Launch Templates
- **GCP Auto Scaling** Managed Instance Groups 및 Autoscaler
- **Kubernetes HPA** Horizontal Pod Autoscaler 설정
- **스케일링 정책** CPU, 메모리, 커스텀 메트릭 기반 스케일링

### 실습 후 달성할 수 있는 능력
- ✅ AWS Auto Scaling Groups 설정 및 관리
- ✅ GCP Managed Instance Groups 구성 및 최적화
- ✅ Kubernetes HPA를 이용한 컨테이너 스케일링
- ✅ 커스텀 메트릭 기반 스케일링 정책 구현

### 예상 소요 시간
- **AWS Auto Scaling**: 90-120분
- **GCP Auto Scaling**: 90-120분
- **Kubernetes HPA**: 60-90분
- **커스텀 메트릭 스케일링**: 90-120분
- **전체 과정**: 5-7시간

---

## 🛠️ 실습 학습

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/mcp_knowledge_base/cloud_master/repos/samples/day3/my-app/`
- **자동화 스크립트**: `/mcp_knowledge_base/cloud_master/repos/automation/day3/auto_scaling.sh`
- **클라우드 스크립트**: `/mcp_knowledge_base/cloud_master/repos/cloud-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **AWS CLI**: 2.0 이상
- **gcloud CLI**: 400.0 이상
- **kubectl**: 1.24 이상
- **Terraform**: 1.0 이상

#### 환경 설정
```bash
# AWS CLI 설정 확인
aws sts get-caller-identity

# gcloud CLI 설정 확인
gcloud auth list

# kubectl 설치 확인
kubectl version --client

# Terraform 설치 확인
terraform version
```

</details>

<details>
<summary>🔧 1단계: AWS Auto Scaling Groups</summary>

#### Launch Template 생성
```bash
# Launch Template 생성
aws ec2 create-launch-template \
  --launch-template-name web-template \
  --launch-template-data '{
    "ImageId": "ami-0c02fb55956c7d316",
    "InstanceType": "t3.micro",
    "KeyName": "my-key",
    "SecurityGroupIds": ["sg-12345"],
    "UserData": "'$(base64 -w 0 user-data.sh)'",
    "TagSpecifications": [{
      "ResourceType": "instance",
      "Tags": [{"Key": "Name", "Value": "web-instance"}]
    }]
  }'

# Launch Template 버전 생성
aws ec2 create-launch-template-version \
  --launch-template-name web-template \
  --source-version 1 \
  --launch-template-data '{
    "InstanceType": "t3.small",
    "ImageId": "ami-0c02fb55956c7d316"
  }'
```

#### Auto Scaling Group 생성
```bash
# Auto Scaling Group 생성
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name web-asg \
  --launch-template LaunchTemplateName=web-template,Version='$Latest' \
  --min-size 2 \
  --max-size 10 \
  --desired-capacity 2 \
  --vpc-zone-identifier "subnet-12345,subnet-67890" \
  --target-group-arns "arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/web-targets/1234567890123456" \
  --health-check-type ELB \
  --health-check-grace-period 300

# Auto Scaling Group 설정 확인
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names web-asg
```

#### 스케일링 정책 설정
```bash
# CPU 기반 스케일 아웃 정책
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name web-asg \
  --policy-name scale-out-cpu \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration '{
    "TargetValue": 70.0,
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ASGAverageCPUUtilization"
    },
    "ScaleOutCooldown": 300,
    "ScaleInCooldown": 300
  }'

# 커스텀 메트릭 기반 스케일링 정책
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name web-asg \
  --policy-name scale-out-requests \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration '{
    "TargetValue": 1000.0,
    "CustomizedMetricSpecification": {
      "MetricName": "RequestCount",
      "Namespace": "MyApp",
      "Statistic": "Average",
      "Dimensions": [{"Name": "AutoScalingGroupName", "Value": "web-asg"}]
    },
    "ScaleOutCooldown": 300,
    "ScaleInCooldown": 300
  }'
```

#### 스케일링 이벤트 모니터링
```bash
# 스케일링 활동 확인
aws autoscaling describe-scaling-activities --auto-scaling-group-name web-asg

# 스케일링 정책 확인
aws autoscaling describe-policies --auto-scaling-group-name web-asg

# CloudWatch 메트릭 확인
aws cloudwatch get-metric-statistics \
  --namespace AWS/AutoScaling \
  --metric-name GroupDesiredCapacity \
  --dimensions Name=AutoScalingGroupName,Value=web-asg \
  --start-time 2023-01-01T00:00:00Z \
  --end-time 2023-01-01T23:59:59Z \
  --period 3600 \
  --statistics Average
```

</details>

<details>
<summary>🔧 2단계: GCP Managed Instance Groups</summary>

#### 인스턴스 템플릿 생성
```bash
# 인스턴스 템플릿 생성
gcloud compute instance-templates create web-template \
  --machine-type e2-micro \
  --network my-vpc \
  --subnet web-subnet \
  --tags http-server \
  --image-family ubuntu-2004-lts \
  --image-project ubuntu-os-cloud \
  --metadata-from-file startup-script=startup-script.sh \
  --service-account=web-service-account@my-project.iam.gserviceaccount.com

# 템플릿 확인
gcloud compute instance-templates list
```

#### Managed Instance Group 생성
```bash
# Managed Instance Group 생성
gcloud compute instance-groups managed create web-group \
  --template web-template \
  --size 2 \
  --zone us-central1-a

# 자동 스케일링 설정
gcloud compute instance-groups managed set-autoscaling web-group \
  --max-num-replicas 10 \
  --min-num-replicas 2 \
  --target-cpu-utilization 0.7 \
  --zone us-central1-a \
  --cool-down-period 60

# 스케일링 정책 확인
gcloud compute instance-groups managed describe web-group --zone us-central1-a
```

#### 고급 스케일링 정책
```bash
# 커스텀 메트릭 기반 스케일링
gcloud compute instance-groups managed set-autoscaling web-group \
  --max-num-replicas 10 \
  --min-num-replicas 2 \
  --custom-metric-utilization metric-type=custom.googleapis.com/myapp/requests-per-second,target=1000 \
  --zone us-central1-a

# 로드 밸런싱 설정
gcloud compute instance-groups managed set-named-ports web-group \
  --named-ports http:80 \
  --zone us-central1-a

# 백엔드 서비스에 MIG 추가
gcloud compute backend-services add-backend web-backend \
  --instance-group web-group \
  --instance-group-zone us-central1-a \
  --global
```

#### 스케일링 모니터링
```bash
# MIG 상태 확인
gcloud compute instance-groups managed list-instances web-group --zone us-central1-a

# 스케일링 이벤트 확인
gcloud logging read "resource.type=gce_instance_group AND jsonPayload.event_type=autoscaler" --limit=50

# 메트릭 확인
gcloud monitoring metrics list --filter="metric.type:compute.googleapis.com/instance/cpu/utilization"
```

</details>

<details>
<summary>🔧 3단계: Kubernetes Horizontal Pod Autoscaler</summary>

#### HPA 기본 설정
```yaml
# hpa-basic.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-hpa
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
      - type: Pods
        value: 4
        periodSeconds: 15
      selectPolicy: Max
```

#### 커스텀 메트릭 HPA
```yaml
# hpa-custom-metrics.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-hpa-custom
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Pods
    pods:
      metric:
        name: requests_per_second
      target:
        type: AverageValue
        averageValue: "1000"
  - type: Object
    object:
      metric:
        name: queue_length
      describedObject:
        apiVersion: v1
        kind: Service
        name: web-app-service
      target:
        type: Value
        value: "10"
```

#### HPA 배포 및 테스트
```bash
# HPA 생성
kubectl apply -f hpa-basic.yaml

# HPA 상태 확인
kubectl get hpa

# HPA 상세 정보 확인
kubectl describe hpa web-app-hpa

# 부하 테스트 실행
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh

# 부하 테스트 명령어 (컨테이너 내부에서 실행)
while true; do wget -q -O- http://web-app-service; done

# HPA 스케일링 모니터링
watch kubectl get hpa,deployment,pods
```

#### Vertical Pod Autoscaler (VPA)
```yaml
# vpa.yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: web-app-vpa
  namespace: default
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: web-app
      minAllowed:
        cpu: 100m
        memory: 128Mi
      maxAllowed:
        cpu: 1000m
        memory: 1Gi
      controlledResources: ["cpu", "memory"]
```

</details>

<details>
<summary>🔧 4단계: 고급 스케일링 전략</summary>

#### 다중 메트릭 스케일링
```yaml
# multi-metric-hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-multi-metric-hpa
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 2
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  - type: Pods
    pods:
      metric:
        name: requests_per_second
      target:
        type: AverageValue
        averageValue: "500"
  - type: External
    external:
      metric:
        name: queue_length
        selector:
          matchLabels:
            queue: "web-queue"
      target:
        type: AverageValue
        averageValue: "5"
```

#### 스케일링 이벤트 알림
```yaml
# scaling-alerts.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: scaling-alerts
  namespace: default
data:
  scaling-alerts.yaml: |
    groups:
    - name: scaling
      rules:
      - alert: HighCPUUtilization
        expr: rate(container_cpu_usage_seconds_total[5m]) > 0.8
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High CPU utilization detected"
          description: "CPU utilization is {{ $value }}%"
      
      - alert: ScalingEvent
        expr: increase(kube_horizontalpodautoscaler_status_current_replicas[5m]) > 0
        for: 0m
        labels:
          severity: info
        annotations:
          summary: "HPA scaling event"
          description: "HPA scaled to {{ $value }} replicas"
```

#### 스케일링 성능 최적화
```yaml
# optimized-hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-optimized-hpa
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 3
  maxReplicas: 50
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
      - type: Pods
        value: 2
        periodSeconds: 60
      selectPolicy: Min
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 50
        periodSeconds: 15
      - type: Pods
        value: 4
        periodSeconds: 15
      selectPolicy: Max
```

</details>

---

## 📚 참고 자료

### 유용한 명령어
```bash
# AWS Auto Scaling 관리
aws autoscaling describe-auto-scaling-groups          # ASG 목록
aws autoscaling describe-scaling-activities           # 스케일링 활동
aws autoscaling describe-policies                     # 스케일링 정책

# GCP Auto Scaling 관리
gcloud compute instance-groups managed list           # MIG 목록
gcloud compute instance-groups managed describe       # MIG 상세 정보
gcloud compute instance-groups managed list-instances # 인스턴스 목록

# Kubernetes HPA 관리
kubectl get hpa                                       # HPA 목록
kubectl describe hpa <name>                           # HPA 상세 정보
kubectl top pods                                      # 리소스 사용량
```

### 문제 해결
1. **ASG 스케일링 실패**
   - Launch Template 확인
   - 서브넷 용량 확인
   - 보안 그룹 규칙 확인

2. **HPA 스케일링 안됨**
   - 메트릭 서버 설치 확인
   - 리소스 요청/제한 설정 확인
   - 메트릭 수집 상태 확인

---

## 🧹 실습 정리

### 자동 정리
```bash
# Day3 오토 스케일링 실습 자동 정리
./mcp_knowledge_base/cloud_master/repos/automation/day3/auto_scaling.sh --cleanup
```

### 수동 정리
```bash
# AWS Auto Scaling 정리
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name web-asg --force-delete
aws ec2 delete-launch-template --launch-template-name web-template

# GCP Auto Scaling 정리
gcloud compute instance-groups managed delete web-group --zone us-central1-a
gcloud compute instance-templates delete web-template

# Kubernetes HPA 정리
kubectl delete hpa web-app-hpa
kubectl delete vpa web-app-vpa
```

### 정리 확인
- [ ] AWS Auto Scaling Group 삭제
- [ ] Launch Template 삭제
- [ ] GCP Managed Instance Group 삭제
- [ ] Kubernetes HPA/VPA 삭제
