#!/bin/bash

# MCP Cloud Docker 이미지 빌드 스크립트

set -e  # 오류 발생 시 즉시 종료

echo "🚀 MCP Cloud Docker 이미지 빌드 시작..."

# 1. 백엔드 package 이미지 빌드
echo "📦 백엔드 package 이미지 빌드 중..."
cd backend
docker build -f Dockerfile.package -t mcp-backend:package .
if [ $? -ne 0 ]; then
    echo "❌ 백엔드 package 이미지 빌드 실패"
    exit 1
fi
echo "✅ 백엔드 package 이미지 빌드 완료"

# 2. 백엔드 app 이미지 빌드
echo "🔧 백엔드 app 이미지 빌드 중..."
docker build -f Dockerfile.app -t mcp-backend:app .
if [ $? -ne 0 ]; then
    echo "❌ 백엔드 app 이미지 빌드 실패"
    exit 1
fi
echo "✅ 백엔드 app 이미지 빌드 완료"

cd ..

# 3. 프론트엔드 package 이미지 빌드
echo "📦 프론트엔드 package 이미지 빌드 중..."
cd frontend
docker build -f Dockerfile.package -t mcp-frontend:package .
if [ $? -ne 0 ]; then
    echo "❌ 프론트엔드 package 이미지 빌드 실패"
    echo "💡 디버깅 정보:"
    echo "   - package.json 확인: cat package.json"
    echo "   - yarn.lock 확인: ls -la yarn.lock"
    echo "   - 로컬 빌드 테스트: yarn install && yarn nuxt --version"
    exit 1
fi
echo "✅ 프론트엔드 package 이미지 빌드 완료"

# 4. 프론트엔드 app 이미지 빌드
echo "🔧 프론트엔드 app 이미지 빌드 중..."
docker build -f Dockerfile.app -t mcp-frontend:app .
if [ $? -ne 0 ]; then
    echo "❌ 프론트엔드 app 이미지 빌드 실패"
    exit 1
fi
echo "✅ 프론트엔드 app 이미지 빌드 완료"

cd ..

echo "🎉 모든 Docker 이미지 빌드 완료!"
echo ""
echo "📋 빌드된 이미지 목록:"
docker images | grep "mcp-"

echo ""
echo "🚀 Docker Compose로 실행하려면:"
echo "docker-compose up -d"
