const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const PORT = process.env.PORT || 3000;

// 미들웨어 설정
app.use(helmet());
app.use(cors());
app.use(express.json());

// 헬스체크 엔드포인트
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
    platform: 'AWS ECS'
  });
});

// 메인 엔드포인트
app.get('/', (req, res) => {
  res.json({
    message: 'Cloud Intermediate Application (AWS ECS)',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    platform: 'AWS ECS',
    region: process.env.AWS_REGION || 'ap-northeast-2'
  });
});

// API 엔드포인트
app.get('/api/status', (req, res) => {
  res.json({
    service: 'cloud-intermediate-app',
    status: 'running',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    platform: 'AWS ECS',
    region: process.env.AWS_REGION || 'ap-northeast-2'
  });
});

// 메트릭 엔드포인트 (Prometheus 형식)
app.get('/metrics', (req, res) => {
  const metrics = [
    `# HELP http_requests_total Total number of HTTP requests`,
    `# TYPE http_requests_total counter`,
    `http_requests_total{method="GET",status="200"} ${Math.floor(Math.random() * 1000)}`,
    `http_requests_total{method="GET",status="404"} ${Math.floor(Math.random() * 10)}`,
    `# HELP nodejs_memory_usage_bytes Node.js memory usage in bytes`,
    `# TYPE nodejs_memory_usage_bytes gauge`,
    `nodejs_memory_usage_bytes ${process.memoryUsage().heapUsed}`,
    `# HELP nodejs_uptime_seconds Node.js uptime in seconds`,
    `# TYPE nodejs_uptime_seconds gauge`,
    `nodejs_uptime_seconds ${process.uptime()}`
  ].join('\n');
  
  res.set('Content-Type', 'text/plain');
  res.send(metrics);
});

// 서버 시작
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`Platform: AWS ECS`);
  console.log(`Region: ${process.env.AWS_REGION || 'ap-northeast-2'}`);
});
