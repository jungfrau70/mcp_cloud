# 자동 복구 시나리오 가이드

## 🎯 학습 목표

이 가이드를 통해 다음을 학습합니다:
- Kubernetes 자동 복구 메커니즘 이해
- 헬스체크 및 프로브 설정
- 자동 스케일링 및 장애 복구
- 모니터링 기반 자동화
- 실제 장애 시나리오 시뮬레이션

---

## 📋 목차

1. [Kubernetes 자동 복구 메커니즘](#kubernetes-자동-복구-메커니즘)
2. [헬스체크 및 프로브 설정](#헬스체크-및-프로브-설정)
3. [자동 스케일링 설정](#자동-스케일링-설정)
4. [장애 시뮬레이션 및 복구](#장애-시뮬레이션-및-복구)
5. [모니터링 기반 자동화](#모니터링-기반-자동화)
6. [실습 시나리오](#실습-시나리오)

---

## 🔧 Kubernetes 자동 복구 메커니즘

### Pod 자동 복구

#### 기본 자동 복구
```yaml
# deployment-with-recovery.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: container-demo-recovery
  namespace: container-demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: container-demo
  template:
    metadata:
      labels:
        app: container-demo
    spec:
      containers:
      - name: container-demo
        image: gcr.io/PROJECT_ID/container-demo:latest
        ports:
        - containerPort: 3000
        # 자동 복구를 위한 헬스체크 설정
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
        # 리소스 제한으로 OOMKilled 방지
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        # 자동 재시작 정책
        restartPolicy: Always
```

#### 고급 자동 복구 설정
```yaml
# advanced-recovery.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: container-demo-advanced
  namespace: container-demo
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 2
      maxUnavailable: 1
  selector:
    matchLabels:
      app: container-demo
  template:
    metadata:
      labels:
        app: container-demo
    spec:
      # Pod 분산 배치
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
                  - container-demo
              topologyKey: kubernetes.io/hostname
      containers:
      - name: container-demo
        image: gcr.io/PROJECT_ID/container-demo:latest
        ports:
        - containerPort: 3000
        # 다단계 헬스체크
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
          successThreshold: 1
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
          successThreshold: 1
        # 시작 프로브 (느린 시작 애플리케이션용)
        startupProbe:
          httpGet:
            path: /startup
            port: 3000
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 30
          successThreshold: 1
        # 리소스 제한
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        # 환경 변수
        env:
        - name: NODE_ENV
          value: "production"
        - name: HEALTH_CHECK_INTERVAL
          value: "10"
        - name: MAX_RETRY_COUNT
          value: "3"
```

---

## 🏥 헬스체크 및 프로브 설정

### 애플리케이션 헬스체크 엔드포인트

#### Node.js 애플리케이션 헬스체크
```javascript
// health-check.js
const express = require('express');
const app = express();

// 헬스체크 엔드포인트
app.get('/health', (req, res) => {
  try {
    // 데이터베이스 연결 확인
    const dbStatus = checkDatabaseConnection();
    
    // Redis 연결 확인
    const redisStatus = checkRedisConnection();
    
    // 메모리 사용량 확인
    const memoryUsage = process.memoryUsage();
    const memoryUsagePercent = memoryUsage.heapUsed / memoryUsage.heapTotal;
    
    if (dbStatus && redisStatus && memoryUsagePercent < 0.9) {
      res.status(200).json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        checks: {
          database: dbStatus,
          redis: redisStatus,
          memory: memoryUsagePercent
        }
      });
    } else {
      res.status(503).json({
        status: 'unhealthy',
        timestamp: new Date().toISOString(),
        checks: {
          database: dbStatus,
          redis: redisStatus,
          memory: memoryUsagePercent
        }
      });
    }
  } catch (error) {
    res.status(503).json({
      status: 'unhealthy',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// 준비 상태 체크
app.get('/ready', (req, res) => {
  try {
    // 애플리케이션 초기화 완료 확인
    const isReady = checkApplicationReady();
    
    if (isReady) {
      res.status(200).json({
        status: 'ready',
        timestamp: new Date().toISOString()
      });
    } else {
      res.status(503).json({
        status: 'not ready',
        timestamp: new Date().toISOString()
      });
    }
  } catch (error) {
    res.status(503).json({
      status: 'not ready',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// 시작 상태 체크
app.get('/startup', (req, res) => {
  try {
    // 애플리케이션 시작 완료 확인
    const isStarted = checkApplicationStarted();
    
    if (isStarted) {
      res.status(200).json({
        status: 'started',
        timestamp: new Date().toISOString()
      });
    } else {
      res.status(503).json({
        status: 'starting',
        timestamp: new Date().toISOString()
      });
    }
  } catch (error) {
    res.status(503).json({
      status: 'starting',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// 데이터베이스 연결 확인
function checkDatabaseConnection() {
  // 실제 데이터베이스 연결 확인 로직
  return true;
}

// Redis 연결 확인
function checkRedisConnection() {
  // 실제 Redis 연결 확인 로직
  return true;
}

// 애플리케이션 준비 상태 확인
function checkApplicationReady() {
  // 실제 애플리케이션 준비 상태 확인 로직
  return true;
}

// 애플리케이션 시작 상태 확인
function checkApplicationStarted() {
  // 실제 애플리케이션 시작 상태 확인 로직
  return true;
}

module.exports = app;
```

### 고급 프로브 설정

#### TCP 소켓 프로브
```yaml
# tcp-probe.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: container-demo-tcp
  namespace: container-demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: container-demo
  template:
    metadata:
      labels:
        app: container-demo
    spec:
      containers:
      - name: container-demo
        image: gcr.io/PROJECT_ID/container-demo:latest
        ports:
        - containerPort: 3000
        # TCP 소켓 프로브
        livenessProbe:
          tcpSocket:
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          tcpSocket:
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
```

#### 명령어 실행 프로브
```yaml
# exec-probe.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: container-demo-exec
  namespace: container-demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: container-demo
  template:
    metadata:
      labels:
        app: container-demo
    spec:
      containers:
      - name: container-demo
        image: gcr.io/PROJECT_ID/container-demo:latest
        ports:
        - containerPort: 3000
        # 명령어 실행 프로브
        livenessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - "curl -f http://localhost:3000/health || exit 1"
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - "curl -f http://localhost:3000/ready || exit 1"
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
```

---

## 📈 자동 스케일링 설정

### Horizontal Pod Autoscaler (HPA)

#### 기본 HPA 설정
```yaml
# hpa-basic.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: container-demo-hpa
  namespace: container-demo
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: container-demo
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
```

#### 고급 HPA 설정
```yaml
# hpa-advanced.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: container-demo-hpa-advanced
  namespace: container-demo
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: container-demo
  minReplicas: 3
  maxReplicas: 20
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
      - type: Pods
        value: 2
        periodSeconds: 60
      selectPolicy: Max
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
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: "100"
```

### Vertical Pod Autoscaler (VPA)

#### VPA 설정
```yaml
# vpa.yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: container-demo-vpa
  namespace: container-demo
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: container-demo
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: container-demo
      minAllowed:
        cpu: 100m
        memory: 128Mi
      maxAllowed:
        cpu: 1000m
        memory: 1Gi
      controlledResources: ["cpu", "memory"]
```

---

## 🧪 장애 시뮬레이션 및 복구

### 시나리오 1: Pod 장애 시뮬레이션

#### Pod 삭제 테스트
```bash
#!/bin/bash
# pod-failure-test.sh

echo "🧪 Pod 장애 시뮬레이션 시작"

# 현재 Pod 상태 확인
echo "📊 현재 Pod 상태:"
kubectl get pods -l app=container-demo -n container-demo

# Pod 삭제
echo "💥 Pod 삭제 중..."
kubectl delete pod -l app=container-demo -n container-demo

# 자동 복구 확인
echo "⏳ 자동 복구 대기 중..."
sleep 30

# 복구된 Pod 상태 확인
echo "✅ 복구된 Pod 상태:"
kubectl get pods -l app=container-demo -n container-demo

# 서비스 연속성 확인
echo "🔍 서비스 연속성 확인:"
kubectl port-forward svc/container-demo-service 8080:80 -n container-demo &
PF_PID=$!
sleep 5
curl -f http://localhost:8080/health
kill $PF_PID

echo "🎉 Pod 장애 시뮬레이션 완료"
```

#### 노드 장애 시뮬레이션
```bash
#!/bin/bash
# node-failure-test.sh

echo "🧪 노드 장애 시뮬레이션 시작"

# 노드 상태 확인
echo "📊 현재 노드 상태:"
kubectl get nodes

# 노드 선택 (첫 번째 워커 노드)
NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
echo "🎯 대상 노드: $NODE_NAME"

# 노드에 있는 Pod 확인
echo "📋 노드의 Pod 목록:"
kubectl get pods -o wide --field-selector spec.nodeName=$NODE_NAME -n container-demo

# 노드 드레인 (Pod 이동)
echo "🚚 노드 드레인 중..."
kubectl drain $NODE_NAME --ignore-daemonsets --delete-emptydir-data --force

# Pod 재배치 확인
echo "⏳ Pod 재배치 대기 중..."
sleep 60

# 재배치된 Pod 상태 확인
echo "✅ 재배치된 Pod 상태:"
kubectl get pods -o wide -n container-demo

# 서비스 연속성 확인
echo "🔍 서비스 연속성 확인:"
kubectl port-forward svc/container-demo-service 8080:80 -n container-demo &
PF_PID=$!
sleep 5
curl -f http://localhost:8080/health
kill $PF_PID

# 노드 복구
echo "🔧 노드 복구 중..."
kubectl uncordon $NODE_NAME

echo "🎉 노드 장애 시뮬레이션 완료"
```

### 시나리오 2: 애플리케이션 장애 시뮬레이션

#### 메모리 누수 시뮬레이션
```bash
#!/bin/bash
# memory-leak-test.sh

echo "🧪 메모리 누수 시뮬레이션 시작"

# 메모리 누수 Pod 생성
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: memory-leak-test
  namespace: container-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: memory-leak-test
  template:
    metadata:
      labels:
        app: memory-leak-test
    spec:
      containers:
      - name: memory-leak
        image: gcr.io/PROJECT_ID/container-demo:latest
        ports:
        - containerPort: 3000
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        env:
        - name: SIMULATE_MEMORY_LEAK
          value: "true"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
EOF

# 메모리 사용량 모니터링
echo "📊 메모리 사용량 모니터링:"
kubectl top pods -l app=memory-leak-test -n container-demo --watch
```

#### CPU 스파이크 시뮬레이션
```bash
#!/bin/bash
# cpu-spike-test.sh

echo "🧪 CPU 스파이크 시뮬레이션 시작"

# CPU 스파이크 Pod 생성
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cpu-spike-test
  namespace: container-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cpu-spike-test
  template:
    metadata:
      labels:
        app: cpu-spike-test
    spec:
      containers:
      - name: cpu-spike
        image: gcr.io/PROJECT_ID/container-demo:latest
        ports:
        - containerPort: 3000
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        env:
        - name: SIMULATE_CPU_SPIKE
          value: "true"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
EOF

# CPU 사용량 모니터링
echo "📊 CPU 사용량 모니터링:"
kubectl top pods -l app=cpu-spike-test -n container-demo --watch
```

---

## 📊 모니터링 기반 자동화

### Prometheus 알림 규칙

#### 자동 복구 알림
```yaml
# auto-recovery-alerts.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: auto-recovery-alerts
  namespace: container-demo
data:
  auto-recovery-rules.yml: |
    groups:
    - name: auto-recovery
      rules:
      - alert: PodCrashLoopBackOff
        expr: kube_pod_status_phase{phase="Running"} == 0 and kube_pod_status_phase{phase="Failed"} == 1
        for: 2m
        labels:
          severity: critical
          auto_recovery: "true"
        annotations:
          summary: "Pod is in CrashLoopBackOff state"
          description: "Pod {{ $labels.pod }} in namespace {{ $labels.namespace }} is in CrashLoopBackOff state"
      
      - alert: PodNotReady
        expr: kube_pod_status_ready{condition="True"} == 0
        for: 5m
        labels:
          severity: warning
          auto_recovery: "true"
        annotations:
          summary: "Pod is not ready"
          description: "Pod {{ $labels.pod }} in namespace {{ $labels.namespace }} is not ready"
      
      - alert: HighMemoryUsage
        expr: container_memory_usage_bytes / container_spec_memory_limit_bytes > 0.9
        for: 3m
        labels:
          severity: warning
          auto_recovery: "true"
        annotations:
          summary: "High memory usage detected"
          description: "Pod {{ $labels.pod }} in namespace {{ $labels.namespace }} has high memory usage"
      
      - alert: HighCPUUsage
        expr: rate(container_cpu_usage_seconds_total[5m]) > 0.8
        for: 3m
        labels:
          severity: warning
          auto_recovery: "true"
        annotations:
          summary: "High CPU usage detected"
          description: "Pod {{ $labels.pod }} in namespace {{ $labels.namespace }} has high CPU usage"
```

### 자동 복구 웹훅

#### 웹훅 서버
```javascript
// auto-recovery-webhook.js
const express = require('express');
const { WebhookClient } = require('discord.js');
const app = express();

app.use(express.json());

// Discord 웹훅 설정
const webhook = new WebhookClient({
  url: process.env.DISCORD_WEBHOOK_URL
});

// Prometheus Alertmanager 웹훅 처리
app.post('/webhook', async (req, res) => {
  try {
    const alerts = req.body.alerts;
    
    for (const alert of alerts) {
      if (alert.labels.auto_recovery === 'true') {
        await handleAutoRecovery(alert);
      }
    }
    
    res.status(200).send('OK');
  } catch (error) {
    console.error('Webhook 처리 오류:', error);
    res.status(500).send('Internal Server Error');
  }
});

// 자동 복구 처리
async function handleAutoRecovery(alert) {
  const { labels, annotations } = alert;
  
  try {
    // Discord 알림 전송
    await webhook.send({
      content: `🚨 **자동 복구 알림**\n` +
               `**알림**: ${annotations.summary}\n` +
               `**설명**: ${annotations.description}\n` +
               `**네임스페이스**: ${labels.namespace}\n` +
               `**Pod**: ${labels.pod}\n` +
               `**시간**: ${new Date().toISOString()}`
    });
    
    // 자동 복구 액션 실행
    if (labels.alertname === 'PodCrashLoopBackOff') {
      await restartPod(labels.namespace, labels.pod);
    } else if (labels.alertname === 'HighMemoryUsage') {
      await scaleUpDeployment(labels.namespace, labels.pod);
    }
    
  } catch (error) {
    console.error('자동 복구 처리 오류:', error);
  }
}

// Pod 재시작
async function restartPod(namespace, podName) {
  const { exec } = require('child_process');
  
  return new Promise((resolve, reject) => {
    exec(`kubectl delete pod ${podName} -n ${namespace}`, (error, stdout, stderr) => {
      if (error) {
        reject(error);
      } else {
        resolve(stdout);
      }
    });
  });
}

// Deployment 스케일 업
async function scaleUpDeployment(namespace, podName) {
  const { exec } = require('child_process');
  
  return new Promise((resolve, reject) => {
    exec(`kubectl scale deployment container-demo --replicas=+1 -n ${namespace}`, (error, stdout, stderr) => {
      if (error) {
        reject(error);
      } else {
        resolve(stdout);
      }
    });
  });
}

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`자동 복구 웹훅 서버가 포트 ${PORT}에서 실행 중입니다.`);
});
```

---

## 🚀 실습 시나리오

### 시나리오 1: 기본 자동 복구 테스트

#### 1단계: 환경 설정
```bash
# 자동 복구 테스트 환경 배포
kubectl apply -f auto-recovery-guide/deployment-with-recovery.yaml

# Pod 상태 확인
kubectl get pods -l app=container-demo -n container-demo -w
```

#### 2단계: Pod 장애 시뮬레이션
```bash
# Pod 삭제
kubectl delete pod -l app=container-demo -n container-demo

# 자동 복구 확인 (약 30초 내)
kubectl get pods -l app=container-demo -n container-demo
```

#### 3단계: 서비스 연속성 확인
```bash
# 서비스 접속 테스트
kubectl port-forward svc/container-demo-service 8080:80 -n container-demo &
curl http://localhost:8080/health
```

### 시나리오 2: 고급 자동 복구 테스트

#### 1단계: HPA 설정
```bash
# HPA 배포
kubectl apply -f auto-recovery-guide/hpa-advanced.yaml

# HPA 상태 확인
kubectl get hpa -n container-demo
```

#### 2단계: 부하 테스트
```bash
# 부하 생성기 실행
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh

# 부하 생성 (load-generator pod 내에서)
while true; do wget -q -O- http://container-demo-service:80; done
```

#### 3단계: 자동 스케일링 확인
```bash
# HPA 동작 확인
kubectl get hpa -n container-demo -w

# Pod 수 변화 확인
kubectl get pods -l app=container-demo -n container-demo -w
```

### 시나리오 3: 모니터링 기반 자동화

#### 1단계: 모니터링 설정
```bash
# Prometheus 알림 규칙 배포
kubectl apply -f auto-recovery-guide/auto-recovery-alerts.yaml

# 웹훅 서버 배포
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: auto-recovery-webhook
  namespace: container-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: auto-recovery-webhook
  template:
    metadata:
      labels:
        app: auto-recovery-webhook
    spec:
      containers:
      - name: webhook
        image: gcr.io/PROJECT_ID/auto-recovery-webhook:latest
        ports:
        - containerPort: 3000
        env:
        - name: DISCORD_WEBHOOK_URL
          value: "YOUR_DISCORD_WEBHOOK_URL"
EOF
```

#### 2단계: 장애 시뮬레이션
```bash
# 메모리 누수 시뮬레이션
kubectl apply -f auto-recovery-guide/memory-leak-test.yaml

# CPU 스파이크 시뮬레이션
kubectl apply -f auto-recovery-guide/cpu-spike-test.yaml
```

#### 3단계: 자동 복구 확인
```bash
# 웹훅 로그 확인
kubectl logs -f deployment/auto-recovery-webhook -n container-demo

# Discord 알림 확인
# Discord 채널에서 자동 복구 알림 확인
```

---

## ✅ 체크리스트

### 기본 자동 복구
- [ ] Pod 자동 재시작 설정
- [ ] 헬스체크 및 프로브 설정
- [ ] 리소스 제한 설정
- [ ] Pod 분산 배치 설정

### 고급 자동 복구
- [ ] HPA 설정 및 테스트
- [ ] VPA 설정 및 테스트
- [ ] 다단계 헬스체크 설정
- [ ] 시작 프로브 설정

### 모니터링 기반 자동화
- [ ] Prometheus 알림 규칙 설정
- [ ] 웹훅 서버 배포
- [ ] 자동 복구 액션 구현
- [ ] 알림 시스템 연동

### 장애 시뮬레이션
- [ ] Pod 장애 시뮬레이션
- [ ] 노드 장애 시뮬레이션
- [ ] 메모리 누수 시뮬레이션
- [ ] CPU 스파이크 시뮬레이션

---

## 📚 참고 자료

### 공식 문서
- [Kubernetes 프로브 공식 문서](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Kubernetes HPA 공식 문서](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Prometheus 알림 규칙 공식 문서](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/)

### 추가 학습 자료
- [Kubernetes 고급 가이드](./kubernetes-advanced-guide)
- [종합 실습 가이드](./comprehensive-practice-guide)
- [모니터링 설정 가이드](./monitoring-setup)

---

**💡 팁**: 자동 복구는 운영 환경에서 매우 중요한 기능입니다. 각 시나리오를 차근차근 따라하면서 실제 장애 상황에서의 대응 방법을 익혀보세요!
