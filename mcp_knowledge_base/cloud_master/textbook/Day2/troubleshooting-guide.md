<div align="center">

[← 이전: Cloud Master 2일차 메인](/mcp_knowledge_base/cloud_master/README.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🏠 학습 경로로 돌아가기](/mcp_knowledge_base/index.md) | [← 이전: Cloud Master 메인](/mcp_knowledge_base/cloud_master/README.md) | [📋 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md) | [← 이전: 종합 실습 가이드](/mcp_knowledge_base/cloud_master/textbook/Day2/comprehensive-practice-guide.md) | [다음: Cloud Master 3일차 →](/mcp_knowledge_base/cloud_master/textbook/Day3/README.md)

</div>

# 트러블슈팅 가이드



## 📋 목차
1. [비용 관리 관련 문제](#비용-관리-관련-문제)
2. [모니터링 관련 문제](#모니터링-관련-문제)
3. [Kubernetes 관련 문제](#kubernetes-관련-문제)
4. [네트워킹 관련 문제](#네트워킹-관련-문제)
5. [성능 및 최적화 문제](#성능-및-최적화-문제)
6. [일반적인 오류 코드](#일반적인-오류-코드)

---

## 💰 비용 관리 관련 문제

### 문제 1: Cost Explorer 데이터가 표시되지 않음

#### 증상
```bash
ERROR: No data available for the selected time period
```

#### 원인
- Cost Explorer가 활성화되지 않음
- 데이터 수집 시간 부족 (24시간 필요)
- 권한 부족

#### 해결 방법
```bash
# Cost Explorer 활성화 확인
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost

# 권한 확인
aws iam list-attached-user-policies --user-name your-username

# 필요한 권한 추가
aws iam attach-user-policy \
  --user-name your-username \
  --policy-arn arn:aws:iam::aws:policy/CostExplorerReadOnlyAccess
```

### 문제 2: 예산 알림이 발송되지 않음

#### 증상
- 예산 초과 시 알림이 오지 않음
- SNS 토픽이 작동하지 않음

#### 원인
- SNS 구독 확인 안됨
- 예산 설정 오류
- 알림 채널 설정 문제

#### 해결 방법
```bash
# SNS 구독 상태 확인
aws sns get-subscription-attributes \
  --subscription-arn arn:aws:sns:us-east-1:123456789012:MyTopic:subscription-id

# 구독 확인 요청
aws sns confirm-subscription \
  --topic-arn arn:aws:sns:us-east-1:123456789012:MyTopic \
  --token CONFIRMATION_TOKEN

# 예산 설정 확인
aws budgets describe-budgets \
  --account-id 123456789012

# 테스트 알림 발송
aws sns publish \
  --topic-arn arn:aws:sns:us-east-1:123456789012:MyTopic \
  --message "Test message"
```

### 문제 3: GCP 비용 데이터가 표시되지 않음

#### 증상
```bash
ERROR: No billing data available
```

#### 원인
- Billing 계정이 연결되지 않음
- 프로젝트에 Billing이 활성화되지 않음
- 권한 부족

#### 해결 방법
```bash
# Billing 계정 확인
gcloud alpha billing accounts list

# 프로젝트에 Billing 연결
gcloud alpha billing projects link PROJECT_ID \
  --billing-account=BILLING_ACCOUNT_ID

# Billing 권한 확인
gcloud projects get-iam-policy PROJECT_ID

# 필요한 권한 추가
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="user:your-email@example.com" \
  --role="roles/billing.user"
```

---

## 📊 모니터링 관련 문제

### 문제 1: CloudWatch 메트릭이 수집되지 않음

#### 증상
- CloudWatch 대시보드에 데이터가 없음
- 커스텀 메트릭이 표시되지 않음

#### 원인
- CloudWatch Agent가 설치되지 않음
- IAM 권한 부족
- 메트릭 네임스페이스 오류

#### 해결 방법
```bash
# CloudWatch Agent 상태 확인
sudo systemctl status amazon-cloudwatch-agent

# CloudWatch Agent 재시작
sudo systemctl restart amazon-cloudwatch-agent

# IAM 권한 확인
aws iam list-attached-user-policies --user-name your-username

# 필요한 권한 추가
aws iam attach-user-policy \
  --user-name your-username \
  --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy

# 메트릭 수동 전송 테스트
aws cloudwatch put-metric-data \
  --namespace "Test" \
  --metric-data MetricName=TestMetric,Value=1,Unit=Count
```

### 문제 2: GCP Cloud Monitoring 메트릭이 수집되지 않음

#### 증상
- Cloud Monitoring 대시보드에 데이터가 없음
- VM 메트릭이 표시되지 않음

#### 원인
- Ops Agent가 설치되지 않음
- API가 활성화되지 않음
- 권한 부족

#### 해결 방법
```bash
# Ops Agent 상태 확인
sudo systemctl status google-cloud-ops-agent

# Ops Agent 재시작
sudo systemctl restart google-cloud-ops-agent

# API 활성화 확인
gcloud services list --enabled

# Monitoring API 활성화
gcloud services enable monitoring.googleapis.com

# 권한 확인
gcloud projects get-iam-policy PROJECT_ID

# 필요한 권한 추가
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="user:your-email@example.com" \
  --role="roles/monitoring.metricWriter"
```

### 문제 3: 알림이 발송되지 않음

#### 증상
- 임계값 초과 시 알림이 오지 않음
- 알림 채널이 작동하지 않음

#### 원인
- 알림 채널 설정 오류
- 알림 정책 설정 문제
- ### 📧 연락처
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: [프로젝트 저장소](https://github.com/jungfrau70/aws_gcp.git)
## 🌐 네트워킹 관련 문제

### 문제 1: Pod 간 통신이 안됨

#### 증상
- Pod에서 다른 Pod로 접근할 수 없음
- Service Discovery가 작동하지 않음

#### 원인
- 네트워크 정책 문제
- DNS 설정 오류
- Service 설정 문제

#### 해결 방법
```bash
# Pod 네트워크 확인
kubectl exec -it POD_NAME -- nslookup kubernetes.default

# Service DNS 확인
kubectl exec -it POD_NAME -- nslookup SERVICE_NAME

# 네트워크 정책 확인
kubectl get networkpolicies
kubectl describe networkpolicy NETWORK_POLICY_NAME

# Service 엔드포인트 확인
kubectl get endpoints SERVICE_NAME
kubectl describe endpoints SERVICE_NAME
```

### 문제 2: Ingress가 작동하지 않음

#### 증상
- Ingress가 생성되었지만 외부 접근이 안됨
- 로드 밸런서가 생성되지 않음

#### 원인
- Ingress Controller가 설치되지 않음
- Ingress 설정 오류
- 로드 밸런서 설정 문제

#### 해결 방법
```bash
# Ingress Controller 확인
kubectl get pods -n kube-system | grep ingress

# AWS ALB Ingress Controller 설치
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.4/docs/install/v2_4_4_full.yaml

# GCP Ingress Controller 확인
kubectl get pods -n kube-system | grep ingress-gce

# Ingress 상태 확인
kubectl get ingress
kubectl describe ingress INGRESS_NAME

# 로드 밸런서 상태 확인 (AWS)
aws elbv2 describe-load-balancers

# 로드 밸런서 상태 확인 (GCP)
gcloud compute forwarding-rules list
```

---

## ⚡ 성능 및 최적화 문제

### 문제 1: 애플리케이션 응답 시간이 느림

#### 증상
- 사용자 요청 처리 시간이 길음
- API 응답 시간이 느림

#### 원인
- 리소스 부족
- 네트워크 지연
- 데이터베이스 성능 문제

#### 해결 방법
```bash
# Pod 리소스 사용량 확인
kubectl top pods
kubectl describe pod POD_NAME

# 노드 리소스 사용량 확인
kubectl top nodes
kubectl describe node NODE_NAME

# 애플리케이션 로그 확인
kubectl logs POD_NAME -f

# 네트워크 지연 확인
kubectl exec -it POD_NAME -- ping SERVICE_NAME

# 데이터베이스 연결 확인
kubectl exec -it POD_NAME -- telnet DATABASE_HOST DATABASE_PORT
```

### 문제 2: 클러스터 자동 스케일링이 느림

#### 증상
- 부하 증가 시 노드 추가가 늦음
- Pod 스케일링이 느림

#### 원인
- Cluster Autoscaler 설정 문제
- 노드 프로비저닝 시간이 길음
- HPA 설정 문제

#### 해결 방법
```bash
# Cluster Autoscaler 로그 확인
kubectl logs -n kube-system deployment/cluster-autoscaler

# HPA 설정 확인
kubectl get hpa
kubectl describe hpa HPA_NAME

# 노드 그룹 설정 확인 (AWS)
aws eks describe-nodegroup \
  --cluster-name CLUSTER_NAME \
  --nodegroup-name NODEGROUP_NAME

# 노드 풀 설정 확인 (GCP)
gcloud container node-pools describe NODE_POOL_NAME \
  --cluster=CLUSTER_NAME \
  --zone=ZONE
```

### 문제 3: 비용이 예상보다 높음

#### 증상
- 월별 비용이 예산을 초과
- 리소스 사용률이 낮은데 비용이 높음

#### 원인
- 미사용 리소스가 많음
- 인스턴스 타입이 과도함
- 할인 옵션을 활용하지 않음

#### 해결 방법
```bash
# 리소스 사용률 확인
kubectl top nodes
kubectl top pods

# 미사용 리소스 식별
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running"

# 인스턴스 타입 최적화
kubectl get nodes -o wide

# 할인 옵션 확인
aws ce get-reservation-coverage \
  --time-period Start=2024-01-01,End=2024-01-31

# 비용 권장사항 확인
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE
```

---

## 🚨 일반적인 오류 코드

### AWS 오류 코드

| 오류 코드 | 의미 | 해결 방법 |
|-----------|------|-----------|
| **AccessDenied** | 권한 부족 | IAM 권한 확인 및 추가 |
| **InvalidParameter** | 잘못된 매개변수 | 매개변수 값 확인 |
| **ResourceNotFound** | 리소스 없음 | 리소스 존재 여부 확인 |
| **LimitExceeded** | 한도 초과 | AWS 한도 증가 요청 |
| **InsufficientCapacity** | 용량 부족 | 다른 AZ 또는 인스턴스 타입 시도 |

### GCP 오류 코드

| 오류 코드 | 의미 | 해결 방법 |
|-----------|------|------|
| **PERMISSION_DENIED** | 권한 부족 | IAM 권한 확인 및 추가 |
| **INVALID_ARGUMENT** | 잘못된 인수 | 인수 값 확인 |
| **NOT_FOUND** | 리소스 없음 | 리소스 존재 여부 확인 |
| **QUOTA_EXCEEDED** | 할당량 초과 | 할당량 증가 요청 |
| **RESOURCE_EXHAUSTED** | 리소스 부족 | 다른 리전 또는 존 시도 |

### Kubernetes 오류 코드

| 오류 코드 | 의미 | 해결 방법 |
|-----------|------|------|
| **ImagePullBackOff** | 이미지 다운로드 실패 | 이미지 경로 및 권한 확인 |
| **CrashLoopBackOff** | 컨테이너 재시작 실패 | 애플리케이션 로그 확인 |
| **Pending** | 스케줄링 대기 | 리소스 및 노드 상태 확인 |
| **Failed** | Pod 실행 실패 | 이벤트 및 로그 확인 |

---

## 🔧 디버깅 도구 및 명령어

### AWS 디버깅
```bash
# 로그 확인
aws logs describe-log-groups
aws logs get-log-events --log-group-name /aws/eks/my-cluster

# 메트릭 확인
aws cloudwatch get-metric-statistics \
  --namespace AWS/EKS \
  --metric-name CPUUtilization \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --period 300 \
  --statistics Average

# 이벤트 확인
aws eks describe-cluster --name my-cluster
```

### GCP 디버깅
```bash
# 로그 확인
gcloud logging read "resource.type=gke_cluster" --limit=50

# 메트릭 확인
gcloud monitoring metrics list --filter="metric.type:kubernetes.io/container/cpu/core_usage_time"

# 이벤트 확인
gcloud container clusters describe my-cluster --zone=us-central1-a
```

### Kubernetes 디버깅
```bash
# 클러스터 상태 확인
kubectl cluster-info
kubectl get nodes
kubectl get pods --all-namespaces

# 리소스 사용량 확인
kubectl top nodes
kubectl top pods

# 이벤트 확인
kubectl get events --sort-by=.metadata.creationTimestamp

# 로그 확인
kubectl logs POD_NAME -f
kubectl logs POD_NAME --previous
```

---

## 📞 지원 및 도움말

### 공식 문서
- [AWS EKS 트러블슈팅 가이드](https://docs.aws.amazon.com/eks/latest/userguide/troubleshooting.html)
- [GCP GKE 트러블슈팅 가이드](https://cloud.google.com/kubernetes-engine/docs/troubleshooting)
- [Kubernetes 트러블슈팅 가이드](https://kubernetes.io/docs/tasks/debug-application-cluster/)
- [AWS CloudWatch 트러블슈팅 가이드](https://docs.aws.amazon.com/cloudwatch/latest/monitoring/troubleshooting.html)

### 커뮤니티 지원
- [Kubernetes Slack](https://kubernetes.slack.com/)
- [AWS Developer Forums](https://forums.aws.amazon.com/)
- [Google Cloud Community](https://cloud.google.com/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/kubernetes)

### 문제 보고
문제가 지속되면 다음 정보와 함께 이슈를 생성하세요:
- 오류 메시지 전체
- 클러스터 환경 정보
- 재현 단계
- 로그 파일
- 설정 파일

---

## ✅ 체크리스트

### 문제 해결 전 확인사항
- [ ] 최신 버전 사용 중인가요?
- [ ] 권한 설정이 올바른가요?
- [ ] 네트워크 연결이 정상인가요?
- [ ] 리소스 할당량이 충분한가요?
- [ ] 로그를 확인했나요?

### 문제 해결 후 확인사항
- [ ] 문제가 해결되었나요?
- [ ] 다른 기능에 영향을 주지 않나요?
- [ ] 성능이 정상인가요?
- [ ] 모니터링이 정상 작동하나요?
- [ ] 비용이 예상 범위 내인가요?

이 가이드를 통해 대부분의 문제를 해결할 수 있습니다. 추가 도움이 필요하면 언제든 문의하세요! 🚀

---



---

<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>