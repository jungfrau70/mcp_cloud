#!/bin/bash

# ECS 클러스터 생성
aws ecs create-cluster \
  --cluster-name my-ecs-cluster \
  --capacity-providers FARGATE \
  --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1

# 태스크 정의 등록
aws ecs register-task-definition --cli-input-json file://task-definition.json

# 서비스 생성
aws ecs create-service \
  --cluster my-ecs-cluster \
  --service-name myapp-service \
  --task-definition myapp-task:1 \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-12345,subnet-67890],securityGroups=[sg-12345],assignPublicIp=ENABLED}" \
  --load-balancers "targetGroupArn=arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/myapp-tg/1234567890123456,containerName=myapp,containerPort=80"
