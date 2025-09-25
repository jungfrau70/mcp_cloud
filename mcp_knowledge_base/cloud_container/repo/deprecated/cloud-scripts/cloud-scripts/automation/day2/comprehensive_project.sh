#!/bin/bash
# 종합 프로젝트 실습 스크립트

set -e

echo "종합 프로젝트 실습 시작..."

# 전체 아키텍처 배포
echo "전체 아키텍처 배포 중..."

# Kubernetes 클러스터 배포
kubectl apply -f k8s/

# 모니터링 스택 배포
helm install prometheus prometheus-community/kube-prometheus-stack

# 로드 밸런서 설정
kubectl apply -f ingress/

echo "종합 프로젝트 실습 완료!"
