#!/bin/bash

# AWS Application Monitoring Helper 모듈
# 역할: AWS EKS 애플리케이션 배포 및 모니터링
# 
# 사용법:
#   ./aws-app-monitoring-helper.sh --action <액션> --provider aws

# =============================================================================
# 환경 설정 로드
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 공통 환경 설정 로드
if [ -f "$SCRIPT_DIR/common-environment.env" ]; then
    source "$SCRIPT_DIR/common-environment.env"
else
    echo "ERROR: 공통 환경 설정 파일을 찾을 수 없습니다"
    exit 1
fi

# AWS 환경 설정 로드
if [ -f "$SCRIPT_DIR/aws-environment.env" ]; then
    source "$SCRIPT_DIR/aws-environment.env"
    log_info "AWS 환경 설정 로드 완료"
else
    log_error "AWS 환경 설정 파일을 찾을 수 없습니다"
    exit 1
fi

# =============================================================================
# 사용법 출력
# =============================================================================
usage() {
    cat << EOF
AWS Application Monitoring Helper 모듈

사용법:
  $0 --action <액션> [옵션]

액션:
  app-deploy              # 애플리케이션 배포
  app-monitoring          # 애플리케이션 모니터링 설정
  app-scaling             # 애플리케이션 스케일링 설정
  app-logs                # 애플리케이션 로그 수집
  app-metrics             # 애플리케이션 메트릭 수집
  app-status              # 애플리케이션 상태 확인
  cleanup                 # 전체 정리

옵션:
  --cluster-name <name>   # EKS 클러스터 이름 (기본값: 환경변수)
  --namespace <namespace> # 네임스페이스 (기본값: default)
  --app-name <name>       # 애플리케이션 이름 (기본값: cloud-intermediate-app)
  --help, -h              # 도움말 표시

예시:
  $0 --action app-deploy
  $0 --action app-monitoring --namespace production
  $0 --action app-status --app-name my-app
EOF
}

# =============================================================================
# 환경 검증
# =============================================================================
validate_environment() {
    log_step "AWS Application 모니터링 환경 검증 중..."
    
    # AWS CLI 확인
    if ! check_command "aws"; then
        log_error "AWS CLI가 설치되지 않았습니다."
        return 1
    fi
    
    # kubectl 확인
    if ! check_command "kubectl"; then
        log_error "kubectl이 설치되지 않았습니다."
        return 1
    fi
    
    # eksctl 확인
    if ! check_command "eksctl"; then
        log_error "eksctl이 설치되지 않았습니다."
        return 1
    fi
    
    # AWS 자격 증명 확인
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS 자격 증명이 설정되지 않았습니다."
        return 1
    fi
    
    # EKS 클러스터 연결 확인
    if ! kubectl get nodes &> /dev/null; then
        log_warning "EKS 클러스터에 연결되지 않았습니다. 연결을 시도합니다..."
        aws eks update-kubeconfig --name "$EKS_CLUSTER_NAME" --region "$AWS_REGION"
    fi
    
    log_success "AWS Application 모니터링 환경 검증 완료"
    return 0
}

# =============================================================================
# 애플리케이션 배포
# =============================================================================
deploy_application() {
    local app_name="${1:-cloud-intermediate-app}"
    local namespace="${2:-default}"
    local image_tag="${3:-latest}"
    
    log_header "애플리케이션 배포: $app_name"
    
    # 네임스페이스 생성
    kubectl create namespace "$namespace" --dry-run=client -o yaml | kubectl apply -f -
    
    # 애플리케이션 매니페스트 생성
    cat > app-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $app_name
  namespace: $namespace
  labels:
    app: $app_name
spec:
  replicas: 2
  selector:
    matchLabels:
      app: $app_name
  template:
    metadata:
      labels:
        app: $app_name
    spec:
      containers:
      - name: $app_name
        image: nginx:1.21
        ports:
        - containerPort: 80
        env:
        - name: ENVIRONMENT
          value: "production"
        - name: APP_NAME
          value: "$app_name"
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: $app_name-service
  namespace: $namespace
  labels:
    app: $app_name
spec:
  selector:
    app: $app_name
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  type: LoadBalancer
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $app_name-ingress
  namespace: $namespace
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  rules:
  - host: $app_name.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: $app_name-service
            port:
              number: 80
EOF

    # 애플리케이션 배포
    kubectl apply -f app-deployment.yaml
    
    if [ $? -eq 0 ]; then
        log_success "애플리케이션 배포 완료: $app_name"
        update_progress "app-deploy" "completed" "애플리케이션 배포 완료: $app_name"
        
        # 배포 상태 확인
        check_deployment_status "$app_name" "$namespace"
    else
        log_error "애플리케이션 배포 실패: $app_name"
        update_progress "app-deploy" "failed" "애플리케이션 배포 실패: $app_name"
        return 1
    fi
}

# =============================================================================
# 애플리케이션 모니터링 설정
# =============================================================================
setup_app_monitoring() {
    local app_name="${1:-cloud-intermediate-app}"
    local namespace="${2:-default}"
    
    log_header "애플리케이션 모니터링 설정: $app_name"
    
    # Prometheus ServiceMonitor 생성
    cat > app-servicemonitor.yaml << EOF
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: $app_name-monitor
  namespace: $namespace
  labels:
    app: $app_name
spec:
  selector:
    matchLabels:
      app: $app_name
  endpoints:
  - port: http
    path: /metrics
    interval: 30s
EOF

    kubectl apply -f app-servicemonitor.yaml
    
    # 애플리케이션 메트릭 엔드포인트 추가
    cat > app-metrics-patch.yaml << EOF
spec:
  template:
    spec:
      containers:
      - name: $app_name
        env:
        - name: ENABLE_METRICS
          value: "true"
        - name: METRICS_PORT
          value: "8080"
        ports:
        - name: metrics
          containerPort: 8080
          protocol: TCP
EOF

    kubectl patch deployment "$app_name" -n "$namespace" --patch-file app-metrics-patch.yaml
    
    # CloudWatch Container Insights 활성화
    setup_cloudwatch_insights "$namespace"
    
    log_success "애플리케이션 모니터링 설정 완료"
    update_progress "app-monitoring" "completed" "애플리케이션 모니터링 설정 완료"
}

# =============================================================================
# CloudWatch Container Insights 설정
# =============================================================================
setup_cloudwatch_insights() {
    local namespace="$1"
    
    log_step "CloudWatch Container Insights 설정"
    
    # CloudWatch Agent ConfigMap
    cat > cloudwatch-agent-config.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: cloudwatch-agent-config
  namespace: $namespace
data:
  cwagentconfig.json: |
    {
      "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "root"
      },
      "logs": {
        "logs_collected": {
          "files": {
            "collect_list": [
              {
                "file_path": "/var/log/containers/*.log",
                "log_group_name": "/aws/eks/$EKS_CLUSTER_NAME/application",
                "log_stream_name": "{instance_id}-{container_name}",
                "timezone": "UTC"
              }
            ]
          }
        }
      },
      "metrics": {
        "namespace": "CWAgent",
        "metrics_collected": {
          "cpu": {
            "measurement": ["cpu_usage_idle", "cpu_usage_iowait", "cpu_usage_user", "cpu_usage_system"],
            "metrics_collection_interval": 60
          },
          "disk": {
            "measurement": ["used_percent"],
            "metrics_collection_interval": 60,
            "resources": ["*"]
          },
          "mem": {
            "measurement": ["mem_used_percent"],
            "metrics_collection_interval": 60
          }
        }
      }
    }
EOF

    kubectl apply -f cloudwatch-agent-config.yaml
    
    # CloudWatch Agent DaemonSet
    cat > cloudwatch-agent-daemonset.yaml << EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: cloudwatch-agent
  namespace: $namespace
spec:
  selector:
    matchLabels:
      name: cloudwatch-agent
  template:
    metadata:
      labels:
        name: cloudwatch-agent
    spec:
      containers:
      - name: cloudwatch-agent
        image: amazon/cloudwatch-agent:latest
        resources:
          limits:
            memory: 200Mi
            cpu: 200m
          requests:
            memory: 200Mi
            cpu: 200m
        env:
        - name: HOST_IP
          valueFrom:
            fieldRef:
              fieldPath: status.hostIP
        - name: HOST_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: K8S_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: CI_VERSION
          value: "k8s/1.3.9"
        volumeMounts:
        - name: cwagentconfig
          mountPath: /opt/aws/amazon-cloudwatch-agent/etc
        - name: rootfs
          mountPath: /rootfs
          readOnly: true
        - name: dockersock
          mountPath: /var/run/docker.sock
          readOnly: true
        - name: varlibdocker
          mountPath: /var/lib/docker
          readOnly: true
        - name: sys
          mountPath: /sys
          readOnly: true
        - name: dev
          mountPath: /dev
          readOnly: true
      volumes:
      - name: cwagentconfig
        configMap:
          name: cloudwatch-agent-config
      - name: rootfs
        hostPath:
          path: /
      - name: dockersock
        hostPath:
          path: /var/run/docker.sock
      - name: varlibdocker
        hostPath:
          path: /var/lib/docker
      - name: sys
        hostPath:
          path: /sys
      - name: dev
        hostPath:
          path: /dev
      terminationGracePeriodSeconds: 60
EOF

    kubectl apply -f cloudwatch-agent-daemonset.yaml
    
    log_success "CloudWatch Container Insights 설정 완료"
    update_progress "cloudwatch-insights" "completed" "CloudWatch Container Insights 설정 완료"
}

# =============================================================================
# 애플리케이션 스케일링 설정
# =============================================================================
setup_app_scaling() {
    local app_name="${1:-cloud-intermediate-app}"
    local namespace="${2:-default}"
    
    log_header "애플리케이션 스케일링 설정: $app_name"
    
    # Horizontal Pod Autoscaler 생성
    cat > app-hpa.yaml << EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: $app_name-hpa
  namespace: $namespace
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: $app_name
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
EOF

    kubectl apply -f app-hpa.yaml
    
    # Vertical Pod Autoscaler 생성 (선택적)
    cat > app-vpa.yaml << EOF
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: $app_name-vpa
  namespace: $namespace
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: $app_name
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: $app_name
      minAllowed:
        cpu: 100m
        memory: 128Mi
      maxAllowed:
        cpu: 500m
        memory: 512Mi
EOF

    kubectl apply -f app-vpa.yaml
    
    log_success "애플리케이션 스케일링 설정 완료"
    update_progress "app-scaling" "completed" "애플리케이션 스케일링 설정 완료"
}

# =============================================================================
# 애플리케이션 로그 수집
# =============================================================================
setup_app_logs() {
    local app_name="${1:-cloud-intermediate-app}"
    local namespace="${2:-default}"
    
    log_header "애플리케이션 로그 수집 설정: $app_name"
    
    # Fluent Bit 설정
    cat > fluent-bit-config.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-bit-config
  namespace: $namespace
data:
  fluent-bit.conf: |
    [SERVICE]
        Flush         1
        Log_Level     info
        Daemon        off
        Parsers_File  parsers.conf
        HTTP_Server   On
        HTTP_Listen   0.0.0.0
        HTTP_Port     2020

    [INPUT]
        Name              tail
        Tag               kube.*
        Path              /var/log/containers/*.log
        Parser            docker
        DB                /var/log/flb_kube.db
        Mem_Buf_Limit     5MB
        Skip_Long_Lines   On
        Refresh_Interval  10

    [FILTER]
        Name                kubernetes
        Match               kube.*
        Kube_URL            https://kubernetes.default.svc:443
        Kube_CA_File        /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        Kube_Token_File     /var/run/secrets/kubernetes.io/serviceaccount/token
        Kube_Tag_Prefix     kube.var.log.containers.
        Merge_Log           On
        Keep_Log            Off
        K8S-Logging.Parser  On
        K8S-Logging.Exclude Off

    [OUTPUT]
        Name                cloudwatch_logs
        Match               kube.*
        region              $AWS_REGION
        log_group_name      /aws/eks/$EKS_CLUSTER_NAME/application
        log_stream_prefix   fluent-bit-
        auto_create_group   true

  parsers.conf: |
    [PARSER]
        Name        docker
        Format      json
        Time_Key    time
        Time_Format %Y-%m-%dT%H:%M:%S.%L
        Time_Keep   On
EOF

    kubectl apply -f fluent-bit-config.yaml
    
    # Fluent Bit DaemonSet
    cat > fluent-bit-daemonset.yaml << EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluent-bit
  namespace: $namespace
spec:
  selector:
    matchLabels:
      name: fluent-bit
  template:
    metadata:
      labels:
        name: fluent-bit
    spec:
      serviceAccountName: fluent-bit
      containers:
      - name: fluent-bit
        image: amazon/aws-for-fluent-bit:latest
        env:
        - name: AWS_REGION
          value: $AWS_REGION
        - name: AWS_ACCESS_KEY_ID
          valueFrom:
            secretKeyRef:
              name: fluent-bit-secret
              key: aws-access-key-id
        - name: AWS_SECRET_ACCESS_KEY
          valueFrom:
            secretKeyRef:
              name: fluent-bit-secret
              key: aws-secret-access-key
        volumeMounts:
        - name: varlog
          mountPath: /var/log
          readOnly: true
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
        - name: fluent-bit-config
          mountPath: /fluent-bit/etc/
        - name: fluent-bit-state
          mountPath: /var/log
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
      - name: fluent-bit-config
        configMap:
          name: fluent-bit-config
      - name: fluent-bit-state
        hostPath:
          path: /var/log
EOF

    kubectl apply -f fluent-bit-daemonset.yaml
    
    log_success "애플리케이션 로그 수집 설정 완료"
    update_progress "app-logs" "completed" "애플리케이션 로그 수집 설정 완료"
}

# =============================================================================
# 애플리케이션 메트릭 수집
# =============================================================================
setup_app_metrics() {
    local app_name="${1:-cloud-intermediate-app}"
    local namespace="${2:-default}"
    
    log_header "애플리케이션 메트릭 수집 설정: $app_name"
    
    # Prometheus ServiceMonitor 생성
    cat > app-metrics-servicemonitor.yaml << EOF
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: $app_name-metrics
  namespace: $namespace
  labels:
    app: $app_name
spec:
  selector:
    matchLabels:
      app: $app_name
  endpoints:
  - port: metrics
    path: /metrics
    interval: 30s
    scrapeTimeout: 10s
EOF

    kubectl apply -f app-metrics-servicemonitor.yaml
    
    # 애플리케이션 메트릭 엔드포인트 서비스
    cat > app-metrics-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: $app_name-metrics
  namespace: $namespace
  labels:
    app: $app_name
spec:
  selector:
    app: $app_name
  ports:
  - name: metrics
    port: 8080
    targetPort: 8080
    protocol: TCP
EOF

    kubectl apply -f app-metrics-service.yaml
    
    log_success "애플리케이션 메트릭 수집 설정 완료"
    update_progress "app-metrics" "completed" "애플리케이션 메트릭 수집 설정 완료"
}

# =============================================================================
# 애플리케이션 상태 확인
# =============================================================================
check_app_status() {
    local app_name="${1:-cloud-intermediate-app}"
    local namespace="${2:-default}"
    
    log_header "애플리케이션 상태 확인: $app_name"
    
    # 배포 상태 확인
    log_step "배포 상태 확인"
    kubectl get deployment "$app_name" -n "$namespace" -o wide
    
    # 파드 상태 확인
    log_step "파드 상태 확인"
    kubectl get pods -l app="$app_name" -n "$namespace" -o wide
    
    # 서비스 상태 확인
    log_step "서비스 상태 확인"
    kubectl get svc -l app="$app_name" -n "$namespace" -o wide
    
    # Ingress 상태 확인
    log_step "Ingress 상태 확인"
    kubectl get ingress -l app="$app_name" -n "$namespace" -o wide
    
    # HPA 상태 확인
    log_step "HPA 상태 확인"
    kubectl get hpa -n "$namespace" -o wide
    
    # 로그 확인
    log_step "최근 로그 확인"
    kubectl logs -l app="$app_name" -n "$namespace" --tail=10
    
    # 메트릭 확인
    log_step "리소스 사용량 확인"
    kubectl top pods -l app="$app_name" -n "$namespace"
    
    update_progress "app-status" "completed" "애플리케이션 상태 확인 완료"
}

# =============================================================================
# 배포 상태 확인
# =============================================================================
check_deployment_status() {
    local app_name="$1"
    local namespace="$2"
    
    log_info "배포 상태 확인 중..."
    
    # 배포 완료 대기
    kubectl rollout status deployment/"$app_name" -n "$namespace" --timeout=300s
    
    if [ $? -eq 0 ]; then
        log_success "배포가 성공적으로 완료되었습니다"
        
        # 서비스 엔드포인트 확인
        local service_name="${app_name}-service"
        local external_ip=$(kubectl get svc "$service_name" -n "$namespace" -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
        
        if [ -n "$external_ip" ]; then
            log_info "애플리케이션 URL: http://$external_ip"
        fi
    else
        log_error "배포가 실패했습니다"
        return 1
    fi
}

# =============================================================================
# 전체 정리
# =============================================================================
cleanup_all() {
    local app_name="${1:-cloud-intermediate-app}"
    local namespace="${2:-default}"
    
    log_header "AWS Application 모니터링 환경 전체 정리"
    
    # 애플리케이션 리소스 삭제
    kubectl delete deployment "$app_name" -n "$namespace" --ignore-not-found=true
    kubectl delete service "$app_name-service" -n "$namespace" --ignore-not-found=true
    kubectl delete ingress "$app_name-ingress" -n "$namespace" --ignore-not-found=true
    kubectl delete hpa "$app_name-hpa" -n "$namespace" --ignore-not-found=true
    kubectl delete vpa "$app_name-vpa" -n "$namespace" --ignore-not-found=true
    
    # 모니터링 리소스 삭제
    kubectl delete servicemonitor "$app_name-monitor" -n "$namespace" --ignore-not-found=true
    kubectl delete servicemonitor "$app_name-metrics" -n "$namespace" --ignore-not-found=true
    kubectl delete service "$app_name-metrics" -n "$namespace" --ignore-not-found=true
    
    # CloudWatch Agent 삭제
    kubectl delete daemonset cloudwatch-agent -n "$namespace" --ignore-not-found=true
    kubectl delete configmap cloudwatch-agent-config -n "$namespace" --ignore-not-found=true
    
    # Fluent Bit 삭제
    kubectl delete daemonset fluent-bit -n "$namespace" --ignore-not-found=true
    kubectl delete configmap fluent-bit-config -n "$namespace" --ignore-not-found=true
    
    # 설정 파일 정리
    rm -f app-deployment.yaml app-servicemonitor.yaml app-metrics-patch.yaml
    rm -f app-hpa.yaml app-vpa.yaml app-metrics-servicemonitor.yaml
    rm -f app-metrics-service.yaml cloudwatch-agent-config.yaml
    rm -f cloudwatch-agent-daemonset.yaml fluent-bit-config.yaml
    rm -f fluent-bit-daemonset.yaml
    
    log_success "AWS Application 모니터링 환경 정리 완료"
    update_progress "cleanup" "completed" "AWS Application 모니터링 환경 정리 완료"
}

# =============================================================================
# 메인 실행 로직
# =============================================================================
main() {
    local action=""
    local cluster_name="$EKS_CLUSTER_NAME"
    local namespace="default"
    local app_name="cloud-intermediate-app"
    
    # 인수 파싱
    while [[ $# -gt 0 ]]; do
        case $1 in
            --action)
                action="$2"
                shift 2
                ;;
            --cluster-name)
                cluster_name="$2"
                shift 2
                ;;
            --namespace)
                namespace="$2"
                shift 2
                ;;
            --app-name)
                app_name="$2"
                shift 2
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            *)
                log_error "알 수 없는 옵션: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # 액션이 지정되지 않은 경우
    if [ -z "$action" ]; then
        log_error "액션이 지정되지 않았습니다."
        usage
        exit 1
    fi
    
    # 환경 검증
    if ! validate_environment; then
        log_error "환경 검증 실패"
        exit 1
    fi
    
    # 액션 실행
    case "$action" in
        "app-deploy")
            deploy_application "$app_name" "$namespace"
            ;;
        "app-monitoring")
            setup_app_monitoring "$app_name" "$namespace"
            ;;
        "app-scaling")
            setup_app_scaling "$app_name" "$namespace"
            ;;
        "app-logs")
            setup_app_logs "$app_name" "$namespace"
            ;;
        "app-metrics")
            setup_app_metrics "$app_name" "$namespace"
            ;;
        "app-status")
            check_app_status "$app_name" "$namespace"
            ;;
        "cleanup")
            cleanup_all "$app_name" "$namespace"
            ;;
        "aws-app-monitoring")
            # 메뉴에서 호출되는 통합 액션
            deploy_application "$app_name" "$namespace"
            setup_app_monitoring "$app_name" "$namespace"
            setup_app_scaling "$app_name" "$namespace"
            check_app_status "$app_name" "$namespace"
            ;;
        *)
            log_error "알 수 없는 액션: $action"
            usage
            exit 1
            ;;
    esac
    
    # 실행 요약 보고
    generate_summary
}

# =============================================================================
# 스크립트 실행
# =============================================================================
main "$@"
