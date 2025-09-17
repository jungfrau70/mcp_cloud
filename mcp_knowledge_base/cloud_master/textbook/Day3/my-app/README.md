# Docker 기반 웹 애플리케이션

<div align="center">

← 이전: Cloud Master 2일차 | [다음: Cloud Master 3일차 →](/mcp_knowledge_base/cloud_master/textbook/Day3/README.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🏠 학습 경로로 돌아가기](/mcp_knowledge_base/index.md) | [📋 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>

이 프로젝트는 Docker를 사용한 웹 애플리케이션 데모 프로젝트입니다.

## 📋 프로젝트 개요

[📋 프로젝트 개요](#프로젝트-개요)

### 목적

[목적](#목적)
- Docker 컨테이너화 학습
- 웹 애플리케이션 배포 실습
- 멀티스테이지 빌드 최적화

### 기술 스택

[기술 스택](#기술-스택)
- **Backend**: Node.js, Express
- **Frontend**: HTML, CSS, JavaScript
- **Container**: Docker, Docker Compose
- **Database**: MongoDB (선택사항)

## 🚀 시작하기

[🚀 시작하기](#시작하기)

### 1. 프로젝트 클론

[1. 프로젝트 클론](#1-프로젝트-클론)
```bash
git clone <repository-url>
cd my-app
```

### 2. Docker로 실행

[2. Docker로 실행](#2-docker로-실행)
```bash
# 단일 컨테이너 실행
docker build -t my-app .
docker run -p 3000:3000 my-app

# Docker Compose로 실행
docker-compose up -d
```

### 3. 로컬 개발 환경

[3. 로컬 개발 환경](#3-로컬-개발-환경)
```bash
# 의존성 설치
npm install

# 개발 서버 실행
npm run dev

# 프로덕션 빌드
npm run build
```

## 📁 프로젝트 구조

[📁 프로젝트 구조](#프로젝트-구조)

```
my-app/
├── src/
│   ├── app.js              # 메인 애플리케이션
│   ├── app_v1.js           # 버전 1 애플리케이션
│   └── routes/             # 라우트 파일들
├── public/
│   ├── css/                # CSS 파일들
│   ├── js/                 # JavaScript 파일들
│   └── images/             # 이미지 파일들
├── tests/
│   └── app.test.js         # 테스트 파일
├── Dockerfile              # Docker 설정
├── docker-compose.yml      # Docker Compose 설정
├── .dockerignore           # Docker 무시 파일
├── package.json            # Node.js 의존성
└── README.md               # 프로젝트 문서
```

## 🐳 Docker 설정

[🐳 Docker 설정](#docker-설정)

### Dockerfile (멀티스테이지 빌드)

[Dockerfile (멀티스테이지 빌드)](#dockerfile-멀티스테이지-빌드)
```dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Production stage
FROM node:18-alpine AS production
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
USER node
CMD ["npm", "start"]
```

### Docker Compose

[Docker Compose](#docker-compose)
```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    volumes:
      - ./logs:/app/logs
    restart: unless-stopped

  mongodb:
    image: mongo:6.0
    ports:
      - "27017:27017"
    environment:
      - MONGO_INITDB_ROOT_USERNAME=admin
      - MONGO_INITDB_ROOT_PASSWORD=secret
    volumes:
      - mongodb_data:/data/db
    restart: unless-stopped

volumes:
  mongodb_data:
```

## 🔧 애플리케이션 기능

[🔧 애플리케이션 기능](#애플리케이션-기능)

### API 엔드포인트

[API 엔드포인트](#api-엔드포인트)
- `GET /` - 홈페이지
- `GET /health` - 헬스 체크
- `GET /api/status` - 애플리케이션 상태
- `POST /api/data` - 데이터 생성
- `GET /api/data` - 데이터 조회

### 환경 변수

[환경 변수](#환경-변수)
```bash
NODE_ENV=production
PORT=3000
MONGODB_URI=mongodb://admin:secret@mongodb:27017/myapp
LOG_LEVEL=info
```

## 📊 모니터링 및 로깅

[📊 모니터링 및 로깅](#모니터링-및-로깅)

### 헬스 체크

[헬스 체크](#헬스-체크)
```javascript
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});
```

### 로깅 설정

[로깅 설정](#로깅-설정)
```javascript
const winston = require('winston');

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' })
  ]
});
```

## 🧪 테스트

[🧪 테스트](#테스트)

### 단위 테스트

[단위 테스트](#단위-테스트)
```bash
npm test
```

### 통합 테스트

[통합 테스트](#통합-테스트)
```bash
npm run test:integration
```

### Docker 테스트

[Docker 테스트](#docker-테스트)
```bash
# 컨테이너 내부에서 테스트 실행
docker exec -it my-app npm test

# 테스트 전용 컨테이너 실행
docker run --rm my-app npm test
```

## 🚀 배포

[🚀 배포](#배포)

### AWS EC2 배포

[AWS EC2 배포](#aws-ec2-배포)
```bash
# EC2 인스턴스에 배포
docker build -t my-app .
docker save my-app | gzip > my-app.tar.gz
scp my-app.tar.gz ec2-user@your-ec2-ip:~/
ssh ec2-user@your-ec2-ip
docker load < my-app.tar.gz
docker run -d -p 3000:3000 --name my-app my-app
```

### GCP Compute Engine 배포

[GCP Compute Engine 배포](#gcp-compute-engine-배포)
```bash
# GCP 인스턴스에 배포
gcloud compute instances create-with-container my-app-instance \
  --container-image=my-app:latest \
  --machine-type=e2-micro \
  --zone=asia-northeast3-a
```

## 🔒 보안 설정

[🔒 보안 설정](#보안-설정)

### Docker 보안

[Docker 보안](#docker-보안)
- 비루트 사용자로 실행
- 최소 권한 원칙
- 보안 스캔 실행

### 애플리케이션 보안

[애플리케이션 보안](#애플리케이션-보안)
- 입력 검증
- SQL 인젝션 방지
- XSS 방지
- CORS 설정

## 📈 성능 최적화

[📈 성능 최적화](#성능-최적화)

### Docker 최적화

[Docker 최적화](#docker-최적화)
- 멀티스테이지 빌드
- .dockerignore 사용
- 캐시 레이어 최적화
- 이미지 크기 최소화

### 애플리케이션 최적화

[애플리케이션 최적화](#애플리케이션-최적화)
- 메모리 사용량 모니터링
- CPU 사용량 최적화
- 데이터베이스 쿼리 최적화
- 캐싱 전략

## 📚 추가 자료

[📚 추가 자료](#추가-자료)

- [Docker 공식 문서](https://docs.docker.com/)
- [Node.js 공식 문서](https://nodejs.org/docs/)
- [Express.js 공식 문서](https://expressjs.com/)
- [MongoDB 공식 문서](https://docs.mongodb.com/)

## 🤝 기여하기

[🤝 기여하기](#기여하기)

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

[📄 라이선스](#라이선스)

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 📞 문의

[📞 문의](#문의)

프로젝트에 대한 문의사항이 있으시면 이슈를 생성해 주세요.

---

**🎯 이 프로젝트를 통해 Docker를 활용한 웹 애플리케이션 개발과 배포를 학습할 수 있습니다.**

---

<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>

### 📧 연락처

[📧 연락처](#연락처)
- **이메일**: inhwan.jung@gmail.com
- **GitHub**: [프로젝트 저장소](https://github.com/jungfrau70/aws_gcp.git)

---

<div align="center">

[🏠 홈](/mcp_knowledge_base/index.md) | [📚 전체 커리큘럼](/mcp_knowledge_base/curriculum.md) | [🔗 학습 경로](/mcp_knowledge_base/cloud_master/learning-path.md)

</div>
