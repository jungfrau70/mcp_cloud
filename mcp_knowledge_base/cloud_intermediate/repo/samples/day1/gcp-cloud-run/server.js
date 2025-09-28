const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const PORT = process.env.PORT || 8080;

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
    environment: process.env.NODE_ENV || 'production',
    platform: 'Google Cloud Run',
    region: process.env.GOOGLE_CLOUD_REGION || 'asia-northeast1'
  });
});

// 메인 엔드포인트
app.get('/', (req, res) => {
  res.json({
    message: 'Cloud Intermediate Application (GCP Cloud Run)',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'production',
    platform: 'Google Cloud Run',
    region: process.env.GOOGLE_CLOUD_REGION || 'asia-northeast1'
  });
});

// API 엔드포인트
app.get('/api/status', (req, res) => {
  res.json({
    service: 'cloud-intermediate-app-gcp',
    status: 'running',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'production',
    platform: 'Google Cloud Run',
    region: process.env.GOOGLE_CLOUD_REGION || 'asia-northeast1'
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
    `nodejs_uptime_seconds ${process.uptime()}`,
    `# HELP cloud_run_instances Cloud Run instance count`,
    `# TYPE cloud_run_instances gauge`,
    `cloud_run_instances 1`
  ].join('\n');
  
  res.set('Content-Type', 'text/plain');
  res.send(metrics);
});

// 서버 시작
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'production'}`);
  console.log(`Platform: Google Cloud Run`);
  console.log(`Region: ${process.env.GOOGLE_CLOUD_REGION || 'asia-northeast1'}`);
});
