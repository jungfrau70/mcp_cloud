#!/bin/bash

# CloudWatch 대시보드 생성
aws cloudwatch put-dashboard \
  --dashboard-name "MyApp Dashboard" \
  --dashboard-body file://cloudwatch-dashboard.json

# 대시보드 확인
aws cloudwatch get-dashboard --dashboard-name "MyApp Dashboard"
