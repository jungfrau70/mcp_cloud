# GKE LoadBalancer 구성 옵션

## 🎛️ GKE LoadBalancer 구성 옵션 가이드

### 1. 기본 LoadBalancer 타입 옵션

#### External LoadBalancer (기본)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-external
  annotations:
    cloud.google.com/load-balancer-type: "External"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
```

#### Internal LoadBalancer
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-internal
  annotations:
    cloud.google.com/load-balancer-type: "Internal"
    networking.gke.io/load-balancer-subnet: "subnet-name"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
```

### 2. LoadBalancer 스코프 옵션

#### Regional LoadBalancer (기본)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-regional
  annotations:
    cloud.google.com/load-balancer-type: "External"
    networking.gke.io/load-balancer-type: "Regional"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
```

#### Global LoadBalancer
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-global
  annotations:
    cloud.google.com/load-balancer-type: "External"
    networking.gke.io/load-balancer-type: "Global"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
```

### 3. 네트워크 엔드포인트 그룹 (NEG) 옵션

#### Zonal NEG (기본)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-zonal-neg
  annotations:
    cloud.google.com/load-balancer-type: "External"
    cloud.google.com/neg: '{"ingress": true}'
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
```

#### Serverless NEG
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-serverless-neg
  annotations:
    cloud.google.com/load-balancer-type: "External"
    cloud.google.com/neg: '{"ingress": true}'
    cloud.google.com/backend-config: '{"default": "myapp-backend-config"}'
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
```

### 4. 백엔드 서비스 구성 옵션

#### 기본 BackendConfig
```yaml
apiVersion: cloud.google.com/v1
kind: BackendConfig
metadata:
  name: myapp-backend-config
spec:
  healthCheck:
    checkIntervalSec: 10
    timeoutSec: 5
    healthyThreshold: 2
    unhealthyThreshold: 3
    path: "/"
    port: 80
  sessionAffinity:
    affinityType: "CLIENT_IP"
  connectionDraining:
    drainingTimeoutSec: 60
```

#### 고급 BackendConfig
```yaml
apiVersion: cloud.google.com/v1
kind: BackendConfig
metadata:
  name: myapp-advanced-backend-config
spec:
  healthCheck:
    checkIntervalSec: 10
    timeoutSec: 5
    healthyThreshold: 2
    unhealthyThreshold: 3
    path: "/health"
    port: 8080
    requestPath: "/health"
    response: "OK"
  sessionAffinity:
    affinityType: "CLIENT_IP"
    affinityCookieTtlSec: 3600
  connectionDraining:
    drainingTimeoutSec: 60
  cdn:
    enabled: true
    cachePolicy:
      includeHost: true
      includeProtocol: true
      includeQueryString: true
      queryStringBlacklist: ["utm_source", "utm_medium"]
      queryStringWhitelist: ["utm_campaign"]
  timeoutSec: 30
  customRequestHeaders:
    headers:
    - headerName: "X-Custom-Header"
      headerValue: "myapp"
  customResponseHeaders:
    headers:
    - headerName: "X-Response-Header"
      headerValue: "gke-lb"
```

### 5. SSL/TLS 구성 옵션

#### SSL 인증서 설정
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-ssl
  annotations:
    cloud.google.com/load-balancer-type: "External"
    cloud.google.com/ssl-certificates: "myapp-ssl-cert"
    cloud.google.com/ssl-redirect: "true"
spec:
  type: LoadBalancer
  ports:
  - port: 443
    targetPort: 80
    name: https
  - port: 80
    targetPort: 80
    name: http
```

#### Google Managed SSL 인증서
```yaml
apiVersion: networking.gke.io/v1
kind: ManagedCertificate
metadata:
  name: myapp-ssl-cert
spec:
  domains:
  - myapp.example.com
---
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-managed-ssl
  annotations:
    cloud.google.com/load-balancer-type: "External"
    cloud.google.com/ssl-certificates: "myapp-ssl-cert"
spec:
  type: LoadBalancer
  ports:
  - port: 443
    targetPort: 80
```

### 6. 방화벽 및 보안 옵션

#### 방화벽 규칙 설정
```bash
# LoadBalancer용 방화벽 규칙
gcloud compute firewall-rules create allow-gke-lb \
    --allow tcp:80,tcp:443 \
    --source-ranges 0.0.0.0/0 \
    --target-tags gke-node \
    --description "Allow GKE LoadBalancer traffic"

# 특정 IP 대역만 허용
gcloud compute firewall-rules create allow-gke-lb-restricted \
    --allow tcp:80,tcp:443 \
    --source-ranges 203.0.113.0/24,198.51.100.0/24 \
    --target-tags gke-node \
    --description "Allow GKE LoadBalancer from specific IPs"
```

#### IAP (Identity-Aware Proxy) 설정
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-iap
  annotations:
    cloud.google.com/load-balancer-type: "External"
    cloud.google.com/iap: "true"
    cloud.google.com/backend-config: '{"default": "myapp-backend-config"}'
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
```

### 7. 로드 밸런싱 알고리즘 옵션

#### Round Robin (기본)
```yaml
apiVersion: cloud.google.com/v1
kind: BackendConfig
metadata:
  name: myapp-backend-config
spec:
  # 기본적으로 Round Robin 사용
  healthCheck:
    checkIntervalSec: 10
    timeoutSec: 5
    healthyThreshold: 2
    unhealthyThreshold: 3
```

#### Session Affinity
```yaml
apiVersion: cloud.google.com/v1
kind: BackendConfig
metadata:
  name: myapp-session-affinity-config
spec:
  sessionAffinity:
    affinityType: "CLIENT_IP"
    affinityCookieTtlSec: 3600
  healthCheck:
    checkIntervalSec: 10
    timeoutSec: 5
```

#### Least Connections
```yaml
apiVersion: cloud.google.com/v1
kind: BackendConfig
metadata:
  name: myapp-least-connections-config
spec:
  # GKE에서는 기본적으로 Round Robin 사용
  # Least Connections는 Cloud Load Balancer 레벨에서 설정
  healthCheck:
    checkIntervalSec: 10
    timeoutSec: 5
```

### 8. 모니터링 및 로깅 옵션

#### Cloud Logging 설정
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-with-logging
  annotations:
    cloud.google.com/load-balancer-type: "External"
    cloud.google.com/backend-config: '{"default": "myapp-backend-config"}'
    cloud.google.com/logging: "true"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
```

#### Cloud Monitoring 설정
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-with-monitoring
  annotations:
    cloud.google.com/load-balancer-type: "External"
    cloud.google.com/backend-config: '{"default": "myapp-backend-config"}'
    cloud.google.com/monitoring: "true"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
```

### 9. 비용 최적화 옵션

#### Preemptible 노드 사용
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-cost-optimized
  annotations:
    cloud.google.com/load-balancer-type: "External"
    cloud.google.com/backend-config: '{"default": "myapp-backend-config"}'
    cloud.google.com/neg: '{"ingress": true}'
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
```

#### Regional Persistent Disk 사용
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-regional-optimized
  annotations:
    cloud.google.com/load-balancer-type: "External"
    networking.gke.io/load-balancer-type: "Regional"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
```

### 10. 고가용성 옵션

#### Multi-Zone 배포
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-multi-zone
  annotations:
    cloud.google.com/load-balancer-type: "External"
    cloud.google.com/neg: '{"ingress": true}'
    cloud.google.com/backend-config: '{"default": "myapp-backend-config"}'
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
```

#### Cross-Region 배포
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-cross-region
  annotations:
    cloud.google.com/load-balancer-type: "External"
    networking.gke.io/load-balancer-type: "Global"
    cloud.google.com/neg: '{"ingress": true}'
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
```

## 🛠️ 구성 옵션 선택 가이드

### 기본 구성 (비용 효율적)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-basic
  annotations:
    cloud.google.com/load-balancer-type: "External"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
```

### 고성능 구성 (프로덕션)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-production
  annotations:
    cloud.google.com/load-balancer-type: "External"
    cloud.google.com/neg: '{"ingress": true}'
    cloud.google.com/backend-config: '{"default": "myapp-backend-config"}'
    cloud.google.com/ssl-certificates: "myapp-ssl-cert"
spec:
  type: LoadBalancer
  ports:
  - port: 443
    targetPort: 80
    name: https
  - port: 80
    targetPort: 80
    name: http
```

### 보안 강화 구성
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service-secure
  annotations:
    cloud.google.com/load-balancer-type: "External"
    cloud.google.com/iap: "true"
    cloud.google.com/ssl-certificates: "myapp-ssl-cert"
    cloud.google.com/backend-config: '{"default": "myapp-backend-config"}'
spec:
  type: LoadBalancer
  ports:
  - port: 443
    targetPort: 80
```

이 구성 옵션들을 통해 GKE LoadBalancer를 다양한 요구사항에 맞게 설정할 수 있습니다.
