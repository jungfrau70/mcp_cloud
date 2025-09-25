#!/bin/bash

# Cloud Container Day2 실습 개선 스크립트
# 고가용성 아키텍처, 고급 모니터링, 보안 강화, 성능 최적화, 재해 복구

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 로그 함수들
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}=== $1 ===${NC}"; }

# 환경 변수 설정
export HA_CLUSTER_NAME="cloud-container-ha-cluster"
export REGION="asia-northeast3"
export PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
export NAMESPACE="production"

# Multi-AZ 클러스터 생성
create_ha_cluster() {
    log_header "Multi-AZ 고가용성 클러스터 생성"
    
    log_info "고가용성 클러스터 생성 중..."
    log_info "클러스터명: $HA_CLUSTER_NAME"
    log_info "리전: $REGION"
    log_info "프로젝트: $PROJECT_ID"
    
    gcloud container clusters create "$HA_CLUSTER_NAME" \
        --region="$REGION" \
        --num-nodes=2 \
        --machine-type=e2-medium \
        --enable-autoscaling \
        --min-nodes=1 \
        --max-nodes=10 \
        --node-locations=asia-northeast3-a,asia-northeast3-b,asia-northeast3-c \
        --enable-autorepair \
        --enable-autoupgrade \
        --disk-size=20GB \
        --disk-type=pd-standard \
        --enable-ip-alias \
        --network="default" \
        --subnetwork="default" \
        --enable-autoscaling \
        --enable-autorepair \
        --enable-autoupgrade \
        --enable-network-policy
    
    if [ $? -eq 0 ]; then
        log_success "고가용성 클러스터 생성 완료"
        
        log_info "클러스터 인증 설정 중..."
        gcloud container clusters get-credentials "$HA_CLUSTER_NAME" --region="$REGION"
        
        if [ $? -eq 0 ]; then
            log_success "클러스터 인증 설정 완료"
            
            log_info "클러스터 정보:"
            kubectl cluster-info
            
            log_info "노드 분산 확인:"
            kubectl get nodes -o wide
        else
            log_error "클러스터 인증 설정 실패"
            return 1
        fi
    else
        log_error "고가용성 클러스터 생성 실패"
        return 1
    fi
}

# Pod Anti-Affinity 설정
setup_pod_anti_affinity() {
    log_header "Pod Anti-Affinity 설정"
    
    # Production 네임스페이스 생성
    kubectl create namespace "$NAMESPACE" 2>/dev/null || true
    
    # Anti-Affinity 매니페스트 생성
    cat > anti-affinity-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ha-app
  namespace: $NAMESPACE
  labels:
    app: ha-app
spec:
  replicas: 6
  selector:
    matchLabels:
      app: ha-app
  template:
    metadata:
      labels:
        app: ha-app
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - ha-app
              topologyKey: kubernetes.io/hostname
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - ha-app
            topologyKey: topology.kubernetes.io/zone
      containers:
      - name: ha-app
        image: gcr.io/google-samples/hello-app:1.0
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: ha-app-service
  namespace: $NAMESPACE
spec:
  selector:
    app: ha-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: LoadBalancer
EOF
    
    log_info "Anti-Affinity 배포 생성 중..."
    kubectl apply -f anti-affinity-deployment.yaml
    
    if [ $? -eq 0 ]; then
        log_success "Anti-Affinity 배포 완료"
        
        log_info "Pod 분산 확인 중..."
        kubectl get pods -n "$NAMESPACE" -o wide
        
        log_info "Pod 분산 분석:"
        kubectl get pods -n "$NAMESPACE" -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.nodeName}{"\t"}{.status.phase}{"\n"}{end}' | column -t
    else
        log_error "Anti-Affinity 배포 실패"
        return 1
    fi
}

# 고급 모니터링 설정
setup_advanced_monitoring() {
    log_header "고급 모니터링 설정"
    
    # Prometheus 스택 설치
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    log_info "고급 모니터링 스택 설치 중..."
    helm install prometheus prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --create-namespace \
        --set grafana.adminPassword=admin123 \
        --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
        --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
        --set prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues=false \
        --set alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.resources.requests.storage=10Gi \
        --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=50Gi
    
    if [ $? -eq 0 ]; then
        log_success "고급 모니터링 스택 설치 완료"
        
        # ServiceMonitor 생성
        cat > servicemonitor.yaml << EOF
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: ha-app-monitor
  namespace: monitoring
  labels:
    app: ha-app
spec:
  selector:
    matchLabels:
      app: ha-app
  endpoints:
  - port: http
    path: /metrics
    interval: 30s
EOF
        
        kubectl apply -f servicemonitor.yaml
        
        log_info "모니터링 리소스 확인:"
        kubectl get pods -n monitoring
        
        log_info "Grafana 접속 정보:"
        echo "사용자명: admin"
        echo "비밀번호: admin123"
        echo ""
        
        # 포트 포워딩
        kubectl port-forward --namespace monitoring svc/prometheus-grafana 3000:80 &
        PF_PID=$!
        
        log_success "Grafana 접속: http://localhost:3000"
        log_info "포트 포워딩 PID: $PF_PID"
    else
        log_error "고급 모니터링 스택 설치 실패"
        return 1
    fi
}

# 보안 강화 설정
setup_security() {
    log_header "보안 강화 설정"
    
    # Network Policy 생성
    cat > network-policy.yaml << EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ha-app-network-policy
  namespace: $NAMESPACE
spec:
  podSelector:
    matchLabels:
      app: ha-app
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: monitoring
    - podSelector:
        matchLabels:
          app: ha-app
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: ha-app
    ports:
    - protocol: TCP
      port: 8080
  - to: []
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
EOF
    
    log_info "Network Policy 적용 중..."
    kubectl apply -f network-policy.yaml
    
    # Pod Security Policy 생성
    cat > pod-security-policy.yaml << EOF
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ha-app-psp
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
EOF
    
    log_info "Pod Security Policy 적용 중..."
    kubectl apply -f pod-security-policy.yaml
    
    # RBAC 설정
    cat > rbac.yaml << EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ha-app-sa
  namespace: $NAMESPACE
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: $NAMESPACE
  name: ha-app-role
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["services"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ha-app-rolebinding
  namespace: $NAMESPACE
subjects:
- kind: ServiceAccount
  name: ha-app-sa
  namespace: $NAMESPACE
roleRef:
  kind: Role
  name: ha-app-role
  apiGroup: rbac.authorization.k8s.io
EOF
    
    log_info "RBAC 설정 적용 중..."
    kubectl apply -f rbac.yaml
    
    if [ $? -eq 0 ]; then
        log_success "보안 강화 설정 완료"
        
        log_info "보안 리소스 확인:"
        kubectl get networkpolicy -n "$NAMESPACE"
        kubectl get psp
        kubectl get sa,role,rolebinding -n "$NAMESPACE"
    else
        log_error "보안 강화 설정 실패"
        return 1
    fi
}

# 성능 최적화 설정
setup_performance_optimization() {
    log_header "성능 최적화 설정"
    
    # VPA (Vertical Pod Autoscaler) 설치
    log_info "VPA 설치 중..."
    kubectl apply -f https://github.com/kubernetes/autoscaler/releases/download/vertical-pod-autoscaler-0.12.0/vpa-release.yaml
    
    # VPA 매니페스트 생성
    cat > vpa.yaml << EOF
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: ha-app-vpa
  namespace: $NAMESPACE
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ha-app
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: ha-app
      minAllowed:
        cpu: 100m
        memory: 50Mi
      maxAllowed:
        cpu: 1000m
        memory: 500Mi
      controlledResources: ["cpu", "memory"]
EOF
    
    log_info "VPA 적용 중..."
    kubectl apply -f vpa.yaml
    
    # HPA 설정 (CPU + Memory 기반)
    cat > hpa.yaml << EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ha-app-hpa
  namespace: $NAMESPACE
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ha-app
  minReplicas: 3
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 70
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
EOF
    
    log_info "고급 HPA 적용 중..."
    kubectl apply -f hpa.yaml
    
    # QoS 클래스 확인
    log_info "QoS 클래스 확인:"
    kubectl get pods -n "$NAMESPACE" -o custom-columns=NAME:.metadata.name,QOS-CLASS:.status.qosClass
    
    if [ $? -eq 0 ]; then
        log_success "성능 최적화 설정 완료"
        
        log_info "자동 스케일링 리소스 확인:"
        kubectl get vpa -n "$NAMESPACE"
        kubectl get hpa -n "$NAMESPACE"
    else
        log_error "성능 최적화 설정 실패"
        return 1
    fi
}

# 재해 복구 설정 (Velero)
setup_disaster_recovery() {
    log_header "재해 복구 설정 (Velero)"
    
    # Velero 설치 확인
    if ! command -v velero &> /dev/null; then
        log_warning "Velero가 설치되지 않았습니다. 설치하시겠습니까? (y/N)"
        read -p "설치: " install_velero
        if [[ "$install_velero" =~ ^[Yy]$ ]]; then
            install_velero
        else
            log_error "Velero 설치가 필요합니다"
            return 1
        fi
    fi
    
    # GCS 버킷 생성 (백업 저장소)
    BUCKET_NAME="velero-backups-$(date +%s)"
    log_info "GCS 버킷 생성 중: $BUCKET_NAME"
    
    gsutil mb gs://"$BUCKET_NAME"
    
    # Velero 서비스 계정 생성
    log_info "Velero 서비스 계정 생성 중..."
    gcloud iam service-accounts create velero-sa --display-name="Velero Service Account"
    
    # 권한 부여
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
        --member="serviceAccount:velero-sa@$PROJECT_ID.iam.gserviceaccount.com" \
        --role="roles/storage.admin"
    
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
        --member="serviceAccount:velero-sa@$PROJECT_ID.iam.gserviceaccount.com" \
        --role="roles/compute.storageAdmin"
    
    # Velero 설치
    log_info "Velero 설치 중..."
    velero install \
        --provider gcp \
        --plugins velero/velero-plugin-for-gcp:v1.5.0 \
        --bucket "$BUCKET_NAME" \
        --secret-file ./credentials-velero \
        --use-volume-snapshots=false
    
    # 백업 생성
    log_info "백업 생성 중..."
    velero backup create ha-app-backup --include-namespaces "$NAMESPACE"
    
    if [ $? -eq 0 ]; then
        log_success "재해 복구 설정 완료"
        
        log_info "백업 상태 확인:"
        velero backup get
        
        log_info "백업 상세 정보:"
        velero backup describe ha-app-backup
    else
        log_error "재해 복구 설정 실패"
        return 1
    fi
}

# Velero 설치
install_velero() {
    log_info "Velero 설치 중..."
    
    # Velero 바이너리 다운로드
    wget https://github.com/vmware-tanzu/velero/releases/download/v1.11.0/velero-v1.11.0-linux-amd64.tar.gz
    tar -xzf velero-v1.11.0-linux-amd64.tar.gz
    sudo mv velero-v1.11.0-linux-amd64/velero /usr/local/bin/
    
    # 정리
    rm -rf velero-v1.11.0-linux-amd64.tar.gz velero-v1.11.0-linux-amd64/
    
    if command -v velero &> /dev/null; then
        log_success "Velero 설치 완료"
    else
        log_error "Velero 설치 실패"
        return 1
    fi
}

# 통합 테스트
run_integration_test() {
    log_header "통합 테스트 실행"
    
    log_info "1. 클러스터 상태 확인"
    kubectl get nodes -o wide
    kubectl get pods -n "$NAMESPACE" -o wide
    
    log_info "2. 서비스 상태 확인"
    kubectl get services -n "$NAMESPACE"
    
    log_info "3. 자동 스케일링 상태 확인"
    kubectl get hpa -n "$NAMESPACE"
    kubectl get vpa -n "$NAMESPACE"
    
    log_info "4. 보안 정책 확인"
    kubectl get networkpolicy -n "$NAMESPACE"
    kubectl get psp
    
    log_info "5. 모니터링 상태 확인"
    kubectl get pods -n monitoring
    
    log_info "6. 백업 상태 확인"
    velero backup get 2>/dev/null || log_warning "Velero 백업 정보를 가져올 수 없습니다"
    
    log_success "통합 테스트 완료"
}

# 정리 함수
cleanup() {
    log_header "Day2 실습 정리"
    
    log_warning "모든 리소스를 정리하시겠습니까? (y/N)"
    read -p "확인: " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        log_info "리소스 정리 중..."
        
        # 애플리케이션 삭제
        kubectl delete -f anti-affinity-deployment.yaml 2>/dev/null
        kubectl delete -f network-policy.yaml 2>/dev/null
        kubectl delete -f pod-security-policy.yaml 2>/dev/null
        kubectl delete -f rbac.yaml 2>/dev/null
        kubectl delete -f vpa.yaml 2>/dev/null
        kubectl delete -f hpa.yaml 2>/dev/null
        kubectl delete -f servicemonitor.yaml 2>/dev/null
        
        # 모니터링 스택 삭제
        helm uninstall prometheus -n monitoring 2>/dev/null
        kubectl delete namespace monitoring 2>/dev/null
        
        # 네임스페이스 삭제
        kubectl delete namespace "$NAMESPACE" 2>/dev/null
        
        # 클러스터 삭제
        gcloud container clusters delete "$HA_CLUSTER_NAME" --region="$REGION" --quiet
        
        # 로컬 파일 정리
        rm -f *.yaml
        
        log_success "정리 완료"
    else
        log_info "정리 취소됨"
    fi
}

# Day2 메인 메뉴
day2_main_menu() {
    while true; do
        clear
        log_header "Cloud Container Day2 실습"
        echo "1. Multi-AZ 클러스터 생성"
        echo "2. Pod Anti-Affinity 설정"
        echo "3. 고급 모니터링 설정"
        echo "4. 보안 강화 설정"
        echo "5. 성능 최적화 설정"
        echo "6. 재해 복구 설정 (Velero)"
        echo "7. 통합 테스트"
        echo "8. 전체 실습 실행"
        echo "9. 정리"
        echo "0. 이전 메뉴로 돌아가기"
        echo ""
        read -p "메뉴를 선택하세요: " choice
        
        case $choice in
            1) create_ha_cluster ;;
            2) setup_pod_anti_affinity ;;
            3) setup_advanced_monitoring ;;
            4) setup_security ;;
            5) setup_performance_optimization ;;
            6) setup_disaster_recovery ;;
            7) run_integration_test ;;
            8) 
                log_header "전체 Day2 실습 실행"
                create_ha_cluster && \
                setup_pod_anti_affinity && \
                setup_advanced_monitoring && \
                setup_security && \
                setup_performance_optimization && \
                setup_disaster_recovery && \
                run_integration_test && \
                log_success "Day2 실습 완료!"
                ;;
            9) cleanup ;;
            0) return ;;
            *)
                log_error "잘못된 선택입니다. 다시 시도하세요."
                sleep 2
                ;;
        esac
        
        echo ""
        read -p "계속하려면 Enter를 누르세요..."
    done
}

# 스크립트 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    day2_main_menu
fi
