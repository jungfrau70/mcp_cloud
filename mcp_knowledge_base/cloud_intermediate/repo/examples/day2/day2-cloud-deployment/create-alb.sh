#!/bin/bash

# ALB 생성
aws elbv2 create-load-balancer \
  --name myapp-alb \
  --subnets subnet-12345 subnet-67890 \
  --security-groups sg-12345

# 타겟 그룹 생성
aws elbv2 create-target-group \
  --name myapp-tg \
  --protocol HTTP \
  --port 80 \
  --vpc-id vpc-12345 \
  --target-type ip \
  --health-check-path / \
  --health-check-interval-seconds 30 \
  --health-check-timeout-seconds 5 \
  --healthy-threshold-count 2 \
  --unhealthy-threshold-count 3

# 리스너 생성
aws elbv2 create-listener \
  --load-balancer-arn arn:aws:elasticloadbalancing:us-west-2:123456789012:loadbalancer/app/myapp-alb/1234567890123456 \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/myapp-tg/1234567890123456
