
const express = require('express');
const cors = require('cors');
const app = express();
const port = process.env.PORT || 3000;

// 미들웨어 설정
app.use(cors());
app.use(express.json());

// 기본 라우트
app.get('/', (req, res) => {
  res.json({
    message: 'GitHub Actions CI/CD 실습 애플리케이션',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// 헬스 체크 엔드포인트
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    timestamp: new Date().toISOString()
  });
});

// API 엔드포인트
app.get('/api/status', (req, res) => {
  res.json({
    service: 'GitHub Actions CI/CD Practice',
    status: 'running',
    version: '1.0.0'
  });
});

// 테스트 환경이 아닐 때만 서버 시작
if (process.env.NODE_ENV !== 'test') {
  app.listen(port, () => {
    console.log(`🚀 서버가 포트 ${port}에서 실행 중입니다.`);
    console.log(`📊 헬스 체크: http://localhost:${port}/health`);
  });
}

module.exports = app;