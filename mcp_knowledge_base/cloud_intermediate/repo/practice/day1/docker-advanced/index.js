const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// 미들웨어 설정
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 기본 라우트
app.get('/', (req, res) => {
  res.json({ 
    message: 'Hello from optimized Docker container!',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    version: process.env.npm_package_version || '1.0.0'
  });
});

// 헬스 체크 엔드포인트
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage()
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
    pid: process.pid
  });
});

// Prometheus 메트릭 엔드포인트
app.get('/metrics', (req, res) => {
  const os = require('os');
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
    '# HELP nodejs_external_memory_bytes Node.js external memory size in bytes.',
    '# TYPE nodejs_external_memory_bytes gauge',
    `nodejs_external_memory_bytes ${memUsage.external}`,
    '',
    '# HELP nodejs_heap_space_size_total_bytes Process heap space size total from node.js in bytes.',
    '# TYPE nodejs_heap_space_size_total_bytes gauge',
    `nodejs_heap_space_size_total_bytes{space="new"} ${memUsage.heapTotal}`,
    '',
    '# HELP process_cpu_user_seconds_total Total user CPU time spent in seconds.',
    '# TYPE process_cpu_user_seconds_total counter',
    `process_cpu_user_seconds_total ${cpuUsage.user / 1000000}`,
    '',
    '# HELP process_cpu_system_seconds_total Total system CPU time spent in seconds.',
    '# TYPE process_cpu_system_seconds_total counter',
    `process_cpu_system_seconds_total ${cpuUsage.system / 1000000}`,
    '',
    '# HELP process_start_time_seconds Start time of the process since unix epoch in seconds.',
    '# TYPE process_start_time_seconds gauge',
    `process_start_time_seconds ${Math.floor(Date.now() / 1000) - process.uptime()}`,
    '',
    '# HELP process_resident_memory_bytes Resident memory size in bytes.',
    '# TYPE process_resident_memory_bytes gauge',
    `process_resident_memory_bytes ${memUsage.rss}`,
    '',
    '# HELP nodejs_version_info Node.js version info.',
    '# TYPE nodejs_version_info gauge',
    `nodejs_version_info{version="${process.version}",major="${process.version.split('.')[0].substring(1)}",minor="${process.version.split('.')[1]}",patch="${process.version.split('.')[2]}"} 1`,
    '',
    '# HELP http_requests_total The total number of HTTP requests.',
    '# TYPE http_requests_total counter',
    `http_requests_total{method="GET",route="/"} 1`,
    `http_requests_total{method="GET",route="/health"} 1`,
    `http_requests_total{method="GET",route="/info"} 1`,
    `http_requests_total{method="GET",route="/metrics"} 1`,
    '',
    '# HELP http_request_duration_seconds The HTTP request latencies in seconds.',
    '# TYPE http_request_duration_seconds histogram',
    `http_request_duration_seconds_bucket{le="0.1"} 0`,
    `http_request_duration_seconds_bucket{le="0.5"} 0`,
    `http_request_duration_seconds_bucket{le="1"} 0`,
    `http_request_duration_seconds_bucket{le="+Inf"} 0`,
    `http_request_duration_seconds_sum 0`,
    `http_request_duration_seconds_count 0`
  ].join('\n');
  
  res.set('Content-Type', 'text/plain; version=0.0.4; charset=utf-8');
  res.send(metrics);
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
  console.log(`App listening at http://0.0.0.0:${port}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`Node version: ${process.version}`);
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
