#!/bin/bash
# 고가용성 아키텍처 실습 스크립트

set -e

echo "고가용성 아키텍처 실습 시작..."

# AWS Multi-AZ 설정
echo "AWS Multi-AZ 설정 중..."
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=ha-vpc}]'

# GCP Multi-Region 설정
echo "GCP Multi-Region 설정 중..."
gcloud compute instances create ha-instance-1 --zone=us-central1-a --image-family=ubuntu-2004-lts
gcloud compute instances create ha-instance-2 --zone=us-central1-b --image-family=ubuntu-2004-lts

echo "고가용성 아키텍처 실습 완료!"
