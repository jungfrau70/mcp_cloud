#!/bin/bash

# Cloud Monitoring 대시보드 생성
gcloud monitoring dashboards create \
  --config-from-file=gcp-dashboard.json

# 대시보드 목록 확인
gcloud monitoring dashboards list
