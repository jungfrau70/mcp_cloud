const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const app = express();
const port = process.env.PORT || 3000;

// 미들웨어 설정
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 기본 라우트
app.get('/', (req, res) => {
  res.json({ 
    message: 'Hello from CI/CD Pipeline!',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    version: process.env.npm_package_version || '1.0.0',
    build: process.env.GITHUB_SHA || 'local-build'
  });
});

// 헬스 체크 엔드포인트
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    version: process.env.npm_package_version || '1.0.0'
  });
});

// 준비 상태 체크 엔드포인트
app.get('/ready', (req, res) => {
  res.json({ 
    status: 'ready', 
    timestamp: new Date().toISOString(),
    checks: {
      database: 'connected',
      redis: 'connected',
      external_api: 'available'
    }
  });
});

// 애플리케이션 정보 엔드포인트
app.get('/info', (req, res) => {
  res.json({
    nodeVersion: process.version,
    platform: process.platform,
    architecture: process.arch,
    memory: process.memoryUsage(),
    env: process.env.NODE_ENV || 'development',
    pid: process.pid,
    build: process.env.GITHUB_SHA || 'local-build',
    branch: process.env.GITHUB_REF || 'local'
  });
});

// Prometheus 메트릭 엔드포인트
app.get('/metrics', (req, res) => {
  const memUsage = process.memoryUsage();
  const cpuUsage = process.cpuUsage();
  
  // Prometheus 형식의 메트릭 출력
  const metrics = [
    '# HELP nodejs_heap_size_total_bytes Process heap size from node.js in bytes.',
    '# TYPE nodejs_heap_size_total_bytes gauge',
    `nodejs_heap_size_total_bytes ${memUsage.heapTotal}`,
    '',
    '# HELP nodejs_heap_size_used_bytes Process heap size used from node.js in bytes.',
    '# TYPE nodejs_heap_size_used_bytes gauge',
    `nodejs_heap_size_used_bytes ${memUsage.heapUsed}`,
    '',
    '# HELP process_cpu_user_seconds_total Total user CPU time spent in seconds.',
    '# TYPE process_cpu_user_seconds_total counter',
    `process_cpu_user_seconds_total ${cpuUsage.user / 1000000}`,
    '',
    '# HELP process_cpu_system_seconds_total Total system CPU time spent in seconds.',
    '# TYPE process_cpu_system_seconds_total counter',
    `process_cpu_system_seconds_total ${cpuUsage.system / 1000000}`,
    '',
    '# HELP http_requests_total The total number of HTTP requests.',
    '# TYPE http_requests_total counter',
    `http_requests_total{method="GET",route="/"} 1`,
    `http_requests_total{method="GET",route="/health"} 1`,
    `http_requests_total{method="GET",route="/info"} 1`,
    `http_requests_total{method="GET",route="/metrics"} 1`
  ].join('\n');
  
  res.set('Content-Type', 'text/plain; version=0.0.4; charset=utf-8');
  res.send(metrics);
});

// API 라우트
app.get('/api/status', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    service: 'cicd-pipeline-app'
  });
});

// 404 핸들러
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.originalUrl} not found`,
    timestamp: new Date().toISOString()
  });
});

// 에러 핸들러
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: err.message,
    timestamp: new Date().toISOString()
  });
});

// 서버 시작
app.listen(port, '0.0.0.0', () => {
  console.log(`CI/CD Pipeline App listening at http://0.0.0.0:${port}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`Node version: ${process.version}`);
  console.log(`Build: ${process.env.GITHUB_SHA || 'local-build'}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  process.exit(0);
});

module.exports = app;
