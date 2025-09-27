#!/bin/bash

# 배포 자동화 스크립트
set -e

echo "Starting automated deployment..."

# 1. Docker 이미지 빌드
echo "Building Docker image..."
docker build -t myapp:$GITHUB_SHA .
docker tag myapp:$GITHUB_SHA myapp:latest

# 2. 이미지 푸시
echo "Pushing to registry..."
docker push myapp:$GITHUB_SHA
docker push myapp:latest

# 3. AWS ECS 배포
if [ "$DEPLOY_TO_AWS" = "true" ]; then
    echo "Deploying to AWS ECS..."
    aws ecs update-service \
      --cluster my-ecs-cluster \
      --service myapp-service \
      --force-new-deployment
fi

# 4. GCP Cloud Run 배포
if [ "$DEPLOY_TO_GCP" = "true" ]; then
    echo "Deploying to GCP Cloud Run..."
    gcloud run deploy myapp \
      --image gcr.io/my-project/myapp:$GITHUB_SHA \
      --region us-central1
fi

echo "Deployment completed successfully!"
