#!/bin/bash
# 데이터베이스 서비스 기초 실습 스크립트

set -e

echo "데이터베이스 서비스 기초 실습 시작..."

# AWS RDS MySQL 인스턴스 생성
echo "AWS RDS MySQL 인스턴스 생성 중..."
aws rds create-db-instance     --db-instance-identifier basic-course-db     --db-instance-class db.t3.micro     --engine mysql     --master-username admin     --master-user-password BasicCourse123!     --allocated-storage 20     --vpc-security-group-ids $SECURITY_GROUP_ID     --db-subnet-group-name basic-course-subnet-group

# GCP Cloud SQL MySQL 인스턴스 생성
echo "GCP Cloud SQL MySQL 인스턴스 생성 중..."
gcloud sql instances create basic-course-db     --database-version=MYSQL_8_0     --tier=db-f1-micro     --region=us-central1     --root-password=BasicCourse123!

# 데이터베이스 생성
gcloud sql databases create basic_course_db --instance=basic-course-db

echo "데이터베이스 서비스 기초 실습 완료!"
