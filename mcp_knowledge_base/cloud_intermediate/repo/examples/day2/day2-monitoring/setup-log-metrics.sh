#!/bin/bash

# 로그 기반 메트릭 생성
gcloud logging metrics create myapp_errors \
  --description="Count of error logs" \
  --log-filter="severity>=ERROR"

# 로그 기반 알림 정책 생성
gcloud alpha monitoring policies create \
  --policy-from-file=log-based-alert-policy.yaml
