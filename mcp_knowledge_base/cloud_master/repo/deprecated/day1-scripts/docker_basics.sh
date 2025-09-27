#!/bin/bash
# Cloud Master 1일차: Docker 기초 및 컨테이너 기술 실습 스크립트
# 교재: Cloud Master - 1일차: Docker, Git/GitHub, GitHub Actions 기초

set -e

# 색상 코드 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Cloud Master 1일차: Docker 기초 실습${NC}"
echo -e "${BLUE}========================================${NC}"

# 1. Docker 기초 및 컨테이너 기술 (120분)
echo -e "\n${YELLOW}1. Docker 기초 및 컨테이너 기술 실습${NC}"
echo "=========================================="

# Docker 설치 확인
echo -e "\n${BLUE}1.1 Docker 설치 확인${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}ERROR: Docker가 설치되지 않았습니다.${NC}"
    echo -e "${YELLOW}Docker 설치 가이드를 참조하세요:${NC}"
    echo "https://docs.docker.com/get-docker/"
    exit 1
fi

# Docker 버전 확인
echo -e "\n${BLUE}1.2 Docker 버전 확인${NC}"
echo "Docker 버전:"
docker --version

# Docker 정보 확인
echo -e "\n${BLUE}1.3 Docker 정보 확인${NC}"
echo "Docker 시스템 정보:"
docker info

# Hello World 테스트
echo -e "\n${BLUE}1.4 Hello World 컨테이너 테스트${NC}"
echo "[TEST] Hello World 컨테이너 실행:"
docker run --rm hello-world

# 2. Node.js 웹 애플리케이션 컨테이너화
echo -e "\n${YELLOW}2. Node.js 웹 애플리케이션 컨테이너화${NC}"
echo "=========================================="

# 샘플 애플리케이션 디렉토리 생성
echo -e "\n${BLUE}2.1 샘플 애플리케이션 생성${NC}"
mkdir -p sample-app
cd sample-app

# package.json 생성
echo -e "\n${BLUE}2.2 package.json 생성${NC}"
cat > package.json << 'EOF'
{
  "name": "sample-app",
  "version": "1.0.0",
  "description": "Sample Node.js app for Docker practice",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "dev": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF

# app.js 생성
echo -e "\n${BLUE}2.3 Express 애플리케이션 생성${NC}"
cat > app.js << 'EOF'
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// 미들웨어 설정
app.use(express.json());

// 기본 라우트
app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Docker!',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    version: process.env.npm_package_version || '1.0.0'
  });
});

// 헬스 체크 라우트
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// API 라우트
app.get('/api/info', (req, res) => {
  res.json({
    service: 'sample-app',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    node_version: process.version,
    platform: process.platform
  });
});

// 에러 핸들링
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// 404 핸들링
app.use((req, res) => {
  res.status(404).json({ error: 'Not Found' });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Server running on port ${port}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});
EOF

# Dockerfile 생성
echo -e "\n${BLUE}2.4 Dockerfile 생성${NC}"
cat > Dockerfile << 'EOF'
# 멀티스테이지 빌드 사용
FROM node:18-alpine AS builder

# 작업 디렉토리 설정
WORKDIR /app

# package.json과 package-lock.json 복사
COPY package*.json ./

# 의존성 설치
RUN npm ci --only=production && npm cache clean --force

# 프로덕션 이미지
FROM node:18-alpine AS production

# 보안을 위한 사용자 생성
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# 작업 디렉토리 설정
WORKDIR /app

# 의존성 복사
COPY --from=builder /app/node_modules ./node_modules
COPY --chown=nextjs:nodejs . .

# 포트 노출
EXPOSE 3000

# 사용자 변경
USER nextjs

# 헬스체크 추가
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# 애플리케이션 실행
CMD ["npm", "start"]
EOF

# .dockerignore 생성
echo -e "\n${BLUE}2.5 .dockerignore 생성${NC}"
cat > .dockerignore << 'EOF'
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.nyc_output
coverage
.DS_Store
EOF

# 3. Docker 이미지 빌드 및 실행
echo -e "\n${YELLOW}3. Docker 이미지 빌드 및 실행${NC}"
echo "=========================================="

# Docker 이미지 빌드
echo -e "\n${BLUE}3.1 Docker 이미지 빌드${NC}"
echo "Docker 이미지 빌드 중..."
docker build -t sample-app:latest .

# 이미지 확인
echo -e "\n${BLUE}3.2 생성된 이미지 확인${NC}"
echo "생성된 이미지:"
docker images | grep sample-app

# 컨테이너 실행
echo -e "\n${BLUE}3.3 컨테이너 실행${NC}"
echo "컨테이너 실행 중..."
docker run -d --name sample-app-container -p 3000:3000 sample-app:latest

# 실행 중인 컨테이너 확인
echo -e "\n${BLUE}3.4 실행 중인 컨테이너 확인${NC}"
echo "실행 중인 컨테이너:"
docker ps | grep sample-app

# 4. 애플리케이션 테스트
echo -e "\n${YELLOW}4. 애플리케이션 테스트${NC}"
echo "=========================================="

# 애플리케이션 응답 대기
echo -e "\n${BLUE}4.1 애플리케이션 시작 대기${NC}"
echo "애플리케이션 시작을 기다리는 중..."
sleep 10

# 기본 라우트 테스트
echo -e "\n${BLUE}4.2 기본 라우트 테스트${NC}"
echo "[TEST] 기본 라우트 테스트:"
curl -s http://localhost:3000/ | jq . || echo "jq가 설치되지 않았습니다. JSON 응답을 확인하세요."

# 헬스 체크 테스트
echo -e "\n${BLUE}4.3 헬스 체크 테스트${NC}"
echo "[TEST] 헬스 체크 테스트:"
curl -s http://localhost:3000/health | jq . || echo "jq가 설치되지 않았습니다. JSON 응답을 확인하세요."

# API 정보 테스트
echo -e "\n${BLUE}4.4 API 정보 테스트${NC}"
echo "[TEST] API 정보 테스트:"
curl -s http://localhost:3000/api/info | jq . || echo "jq가 설치되지 않았습니다. JSON 응답을 확인하세요."

# 5. Docker 개념 학습
echo -e "\n${YELLOW}5. Docker 개념 학습${NC}"
echo "=========================================="

echo -e "\n${BLUE}5.1 Docker 핵심 개념${NC}"
echo "- 이미지(Image): 애플리케이션과 실행 환경을 포함한 읽기 전용 템플릿"
echo "- 컨테이너(Container): 이미지를 실행한 인스턴스"
echo "- Dockerfile: 이미지를 빌드하기 위한 명령어 집합"
echo "- 레지스트리(Registry): Docker 이미지를 저장하고 공유하는 서비스"

echo -e "\n${BLUE}5.2 멀티스테이지 빌드의 장점${NC}"
echo "- 최종 이미지 크기 최적화"
echo "- 보안 강화 (불필요한 빌드 도구 제거)"
echo "- 빌드 캐시 효율성 향상"

# 6. 실습 결과 검증
echo -e "\n${YELLOW}6. 실습 결과 검증${NC}"
echo "=========================================="

# 컨테이너 상태 확인
echo -e "\n${BLUE}6.1 컨테이너 상태 확인${NC}"
docker ps -a | grep sample-app

# 컨테이너 로그 확인
echo -e "\n${BLUE}6.2 컨테이너 로그 확인${NC}"
echo "컨테이너 로그 (최근 10줄):"
docker logs --tail 10 sample-app-container

# 이미지 상세 정보
echo -e "\n${BLUE}6.3 이미지 상세 정보${NC}"
docker inspect sample-app:latest | grep -E '"Id"|"Created"|"Size"'

# 7. 정리 및 다음 단계
echo -e "\n${YELLOW}7. 정리 및 다음 단계${NC}"
echo "=========================================="

# 컨테이너 정리
echo -e "\n${BLUE}7.1 컨테이너 정리${NC}"
echo "[CLEANUP] 컨테이너 정리 중..."
docker stop sample-app-container
docker rm sample-app-container

# 이미지 정리 (선택사항)
echo -e "\n${BLUE}7.2 이미지 정리 (선택사항)${NC}"
echo "이미지를 유지하려면 다음 명령어를 실행하지 마세요:"
echo "docker rmi sample-app:latest"

echo -e "\n${GREEN}🎉 Docker 기초 실습이 완료되었습니다!${NC}"

echo -e "\n${BLUE}다음 실습:${NC}"
echo "1. Git/GitHub 기초 (git_github_basics.sh)"
echo "2. GitHub Actions 기초 (github_actions.sh)"
echo "3. VM 배포 (vm_deployment.sh)"

echo -e "\n${BLUE}실습 실행 방법:${NC}"
echo "chmod +x *.sh"
echo "./git_github_basics.sh"

echo -e "\n${BLUE}교재 참조:${NC}"
echo "- [Docker 고급 가이드](cloud_master/textbook/Day1/docker-advanced-guide.md)"
echo "- [1일차 실습 가이드](cloud_master/textbook/Day1/README.md)"

# 상위 디렉토리로 이동
cd ..

echo -e "\n${GREEN}Docker 기초 실습 완료! 🚀${NC}"
