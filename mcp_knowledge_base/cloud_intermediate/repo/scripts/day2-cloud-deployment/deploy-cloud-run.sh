#!/bin/bash

# Cloud Run 서비스 배포
gcloud run deploy myapp \
  --image gcr.io/my-project/myapp:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 3000 \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 10 \
  --concurrency 80 \
  --timeout 300 \
  --set-env-vars NODE_ENV=production

# 도메인 매핑
gcloud run domain-mappings create \
  --service myapp \
  --domain myapp.example.com \
  --region us-central1

# SSL 인증서 생성
gcloud compute ssl-certificates create myapp-ssl \
  --domains myapp.example.com \
  --global
