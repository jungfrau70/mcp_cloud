#!/bin/bash

# CloudWatch 로그 그룹 생성
aws logs create-log-group \
  --log-group-name /aws/ecs/myapp \
  --retention-in-days 30

# 로그 스트림 생성
aws logs create-log-stream \
  --log-group-name /aws/ecs/myapp \
  --log-stream-name myapp-stream

# 커스텀 메트릭 전송
aws cloudwatch put-metric-data \
  --namespace "MyApp/Performance" \
  --metric-data MetricName=ResponseTime,Value=150,Unit=Milliseconds

# 알람 생성
aws cloudwatch put-metric-alarm \
  --alarm-name "High CPU Usage" \
  --alarm-description "Alarm when CPU exceeds 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/ECS \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --alarm-actions arn:aws:sns:us-west-2:123456789012:myapp-alerts

# SNS 토픽 생성
aws sns create-topic --name myapp-alerts

# SNS 구독 생성
aws sns subscribe \
  --topic-arn arn:aws:sns:us-west-2:123456789012:myapp-alerts \
  --protocol email \
  --notification-endpoint admin@example.com
