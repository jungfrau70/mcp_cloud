#!/bin/bash

# 통합 모니터링 체크 스크립트
echo "=== Monitoring Status Check ==="

# AWS CloudWatch 메트릭 수집
if command -v aws &> /dev/null; then
    echo "AWS CloudWatch Metrics:"
    aws cloudwatch get-metric-statistics \
      --namespace AWS/ECS \
      --metric-name CPUUtilization \
      --dimensions Name=ServiceName,Value=myapp-service \
      --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
      --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
      --period 300 \
      --statistics Average
fi

# GCP Cloud Monitoring 메트릭 수집
if command -v gcloud &> /dev/null; then
    echo "GCP Cloud Monitoring Metrics:"
    gcloud monitoring time-series list \
      --filter="metric.type=\"compute.googleapis.com/instance/cpu/utilization\"" \
      --interval="1h"
fi

# 알림 상태 확인
echo "Alert Status:"
if command -v aws &> /dev/null; then
    aws cloudwatch describe-alarms --state-value ALARM
fi

if command -v gcloud &> /dev/null; then
    gcloud alpha monitoring policies list --filter="enabled=true"
fi
