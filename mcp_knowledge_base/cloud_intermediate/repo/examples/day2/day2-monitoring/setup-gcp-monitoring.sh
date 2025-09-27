#!/bin/bash

# 커스텀 메트릭 생성
gcloud monitoring metrics-descriptors create \
  --config-from-file=metric-descriptor.yaml

# 메트릭 데이터 전송
gcloud monitoring time-series create \
  --config-from-file=time-series.yaml

# 알림 정책 생성
gcloud alpha monitoring policies create \
  --policy-from-file=alert-policy.yaml
