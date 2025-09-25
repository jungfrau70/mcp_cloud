#!/bin/bash
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
