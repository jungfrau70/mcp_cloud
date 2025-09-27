# 🐳 Docker 고급 활용 실습

> 📋 **실습 시간**: 90분  
> 📋 **난이도**: 중급  
> 📋 **선수 학습**: Docker 기초, Linux 명령어  
> 📋 **실습 환경**: AWS EC2 인스턴스 또는 로컬 환경

## 🎯 학습 목표

### 핵심 학습 목표
- **멀티스테이지 빌드**: 이미지 크기 최적화 및 보안 강화
- **Docker 최적화**: 프로덕션 환경에 적합한 컨테이너 이미지 생성
- **모니터링 통합**: Prometheus 메트릭 엔드포인트 구현

### 실습 후 달성할 수 있는 능력
- ✅ 멀티스테이지 빌드로 이미지 크기 50% 이상 감소
- ✅ 보안 강화된 컨테이너 이미지 생성
- ✅ Prometheus 메트릭 엔드포인트 구현
- ✅ 프로덕션 환경 최적화 기법 적용

### 예상 소요 시간
- **환경 준비**: 10분
- **멀티스테이지 Dockerfile 작성**: 30분
- **이미지 빌드 및 최적화**: 25분
- **컨테이너 실행 및 테스트**: 25분

---

## 🛠️ 실습 환경 준비

### 📁 실습 코드 및 자동화
- **실습 샘플 코드**: `/mcp_knowledge_base/cloud_intermediate/repos/samples/day1/docker-advanced/`
- **자동화 스크립트**: `/mcp_knowledge_base/cloud_intermediate/repos/automation/day1/docker-advanced-practice-automation.sh`
- **클라우드 스크립트**: `/mcp_knowledge_base/cloud_intermediate/repos/cloud-scripts/`

<details>
<summary>🚀 실습 환경 준비</summary>

#### 필수 도구
- **Docker**: 최신 버전 (20.10+)
- **Docker Compose**: 컨테이너 오케스트레이션
- **curl**: HTTP 요청 테스트
- **jq**: JSON 데이터 처리

#### 환경 설정
```bash
# Docker 설치 확인
docker --version
docker-compose --version

# Docker 서비스 시작
sudo systemctl start docker
sudo systemctl enable docker

# 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER
newgrp docker
```

</details>

<details>
<summary>🔧 1단계: 멀티스테이지 Dockerfile 작성</summary>

#### 실습 디렉토리 생성
```bash
# 실습 디렉토리 생성
mkdir -p ~/cloud_intermediate/samples/day1/docker-advanced
cd ~/cloud_intermediate/samples/day1/docker-advanced

# 실습 샘플 코드 복사 (있는 경우)
cp -r /mcp_knowledge_base/cloud_intermediate/repos/samples/day1/docker-advanced/* ./
```

#### 멀티스테이지 Dockerfile 생성
```dockerfile
# 멀티스테이지 빌드 - Stage 1: 빌드 환경
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

# Stage 2: 프로덕션 환경
FROM nginx:alpine AS production

# 보안 강화: non-root 사용자 생성
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# 앱 파일 복사
COPY --from=builder /app/dist /usr/share/nginx/html
COPY --from=builder /app/nginx.conf /etc/nginx/nginx.conf

# 포트 설정
EXPOSE 80

# 헬스체크 추가
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/health || exit 1

# non-root 사용자로 실행
USER nextjs

CMD ["nginx", "-g", "daemon off;"]
```

#### package.json 생성
```json
{
  "name": "docker-advanced-app",
  "version": "1.0.0",
  "description": "Docker 고급 실습용 앱",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "build": "echo 'Build completed'",
    "test": "echo 'Tests passed'"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

#### nginx.conf 생성
```nginx
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    server {
        listen 80;
        server_name localhost;
        
        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }
        
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
        
        location /metrics {
            access_log off;
            return 200 "# Prometheus metrics\n";
            add_header Content-Type text/plain;
        }
    }
}
```

</details>

<details>
<summary>🔧 2단계: Docker 이미지 빌드 및 최적화</summary>

#### 기본 이미지 빌드 (최적화 전)
```bash
# 기본 Dockerfile 생성 (비최적화)
cat > Dockerfile.basic << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
EXPOSE 80
CMD ["npm", "start"]
EOF

# 기본 이미지 빌드
docker build -f Dockerfile.basic -t docker-advanced:basic .

# 이미지 크기 확인
docker images docker-advanced:basic
```

#### 멀티스테이지 최적화 이미지 빌드
```bash
# 최적화된 이미지 빌드
docker build -t docker-advanced:optimized .

# 이미지 크기 비교
echo "=== 이미지 크기 비교 ==="
docker images | grep docker-advanced

# 이미지 레이어 분석
docker history docker-advanced:basic
docker history docker-advanced:optimized
```

#### 이미지 최적화 확인
```bash
# 이미지 상세 정보 확인
docker inspect docker-advanced:optimized

# 이미지 보안 스캔 (Docker Scout 사용 가능한 경우)
docker scout cves docker-advanced:optimized
```

</details>

<details>
<summary>🔧 3단계: 컨테이너 실행 및 테스트</summary>

#### 최적화된 컨테이너 실행
```bash
# 컨테이너 실행
docker run -d --name test-container -p 8080:80 docker-advanced:optimized

# 컨테이너 상태 확인
docker ps
docker logs test-container
```

#### 헬스체크 테스트
```bash
# 헬스체크 엔드포인트 테스트
curl http://localhost:8080/health

# 메트릭 엔드포인트 테스트
curl http://localhost:8080/metrics

# 기본 페이지 테스트
curl http://localhost:8080/
```

#### 리소스 사용량 모니터링
```bash
# 컨테이너 리소스 사용량 확인
docker stats test-container --no-stream

# 컨테이너 상세 정보 확인
docker inspect test-container

# 컨테이너 내부 프로세스 확인
docker exec test-container ps aux
```

#### 성능 테스트
```bash
# 부하 테스트 (ab 도구 사용)
ab -n 1000 -c 10 http://localhost:8080/

# 메모리 사용량 모니터링
docker exec test-container cat /proc/meminfo
```

</details>

---

## 📚 참고 자료

### 유용한 명령어
```bash
# Docker 이미지 관리
docker images
docker rmi <image_id>
docker system prune -a

# 컨테이너 관리
docker ps -a
docker logs <container_name>
docker exec -it <container_name> /bin/sh
```

### 문제 해결
1. **권한 문제**
   - `sudo usermod -aG docker $USER`
   - `newgrp docker`

2. **포트 충돌**
   - `docker ps`로 사용 중인 포트 확인
   - 다른 포트 사용: `-p 8081:80`

3. **이미지 빌드 실패**
   - Dockerfile 문법 확인
   - 베이스 이미지 존재 여부 확인

---

## 🧹 실습 정리

### 자동 정리
```bash
# Day1 Docker 실습 자동 정리
./mcp_knowledge_base/cloud_intermediate/repos/automation/day1/docker-advanced-practice-automation.sh --cleanup
```

### 수동 정리
```bash
# 컨테이너 정리
docker stop test-container
docker rm test-container

# 이미지 정리
docker rmi docker-advanced:basic docker-advanced:optimized

# 시스템 정리
docker system prune -a
```

### 정리 확인
- [ ] 실행 중인 컨테이너 정리 완료
- [ ] 불필요한 이미지 제거 완료
- [ ] 디스크 공간 정리 확인

---

## 🎯 학습 성과 확인

### 실습 완료 체크리스트
- [ ] 멀티스테이지 Dockerfile 작성 완료
- [ ] 이미지 크기 50% 이상 감소 확인
- [ ] 헬스체크 엔드포인트 정상 동작
- [ ] 메트릭 엔드포인트 구현 완료
- [ ] 보안 강화된 컨테이너 실행

### 다음 단계
- **Kubernetes 기초 실습**으로 진행
- **클라우드 컨테이너 서비스** 실습 준비
- **통합 모니터링 허브** 구축 실습

---

**💡 궁금한 점이 있으시면 언제든 문의해주세요!**  
**문제가 발생하거나 도움이 필요하시면 실시간으로 지원해드리겠습니다.**
