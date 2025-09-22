// Day2 - Advanced Express Application with Database and Monitoring
// Cloud Master Day2 강의안 기반

const express = require('express');
const { createClient } = require('redis');
const { Pool } = require('pg');
const client = require('prom-client');

const app = express();
const PORT = process.env.PORT || 3000;

// Prometheus 메트릭 설정
const register = new client.Registry();
client.collectDefaultMetrics({ register });

// 커스텀 메트릭
const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10]
});

const httpRequestTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

const activeConnections = new client.Gauge({
  name: 'active_connections',
  help: 'Number of active connections'
});

register.registerMetric(httpRequestDuration);
register.registerMetric(httpRequestTotal);
register.registerMetric(activeConnections);

// Redis 클라이언트 설정
let redisClient;
if (process.env.REDIS_URL) {
  redisClient = createClient({
    url: process.env.REDIS_URL
  });
  
  redisClient.on('error', (err) => {
    console.error('Redis Client Error:', err);
  });
  
  redisClient.connect().catch(console.error);
}

// PostgreSQL 클라이언트 설정
let pool;
if (process.env.DATABASE_URL) {
  pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
  });
}

// 미들웨어
app.use(express.json());
app.use(express.static('public'));

// 요청 시간 측정 미들웨어
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const labels = {
      method: req.method,
      route: req.route ? req.route.path : req.path,
      status_code: res.statusCode
    };
    
    httpRequestDuration.observe(labels, duration);
    httpRequestTotal.inc(labels);
  });
  
  next();
});

// 연결 수 추적
let connectionCount = 0;
app.use((req, res, next) => {
  connectionCount++;
  activeConnections.set(connectionCount);
  
  res.on('close', () => {
    connectionCount--;
    activeConnections.set(connectionCount);
  });
  
  next();
});

// 기본 라우트
app.get('/', async (req, res) => {
  try {
    const info = {
      message: 'Cloud Master Day2 - Advanced CI/CD with Docker Compose',
      version: '2.0.0',
      environment: process.env.NODE_ENV || 'development',
      timestamp: new Date().toISOString(),
      features: [
        'Advanced Express Server',
        'PostgreSQL Database Integration',
        'Redis Caching',
        'Prometheus Metrics',
        'Docker Compose Stack',
        'Nginx Load Balancing'
      ]
    };
    
    // Redis 캐싱
    if (redisClient && redisClient.isOpen) {
      await redisClient.setEx('home_info', 300, JSON.stringify(info));
    }
    
    res.json(info);
  } catch (error) {
    console.error('Error in home route:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 헬스 체크 엔드포인트
app.get('/health', async (req, res) => {
  const health = {
    status: 'healthy',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    services: {}
  };
  
  // 데이터베이스 상태 확인
  if (pool) {
    try {
      await pool.query('SELECT 1');
      health.services.database = 'healthy';
    } catch (error) {
      health.services.database = 'unhealthy';
      health.status = 'unhealthy';
    }
  }
  
  // Redis 상태 확인
  if (redisClient && redisClient.isOpen) {
    try {
      await redisClient.ping();
      health.services.redis = 'healthy';
    } catch (error) {
      health.services.redis = 'unhealthy';
      health.status = 'unhealthy';
    }
  }
  
  res.status(health.status === 'healthy' ? 200 : 503).json(health);
});

// 메트릭 엔드포인트
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// API 엔드포인트
app.get('/api/info', async (req, res) => {
  try {
    const info = {
      service: 'github-actions-demo',
      day: 2,
      features: [
        'Multi-stage Docker Build',
        'Docker Compose Stack',
        'Database Integration',
        'Redis Caching',
        'Prometheus Monitoring',
        'Nginx Load Balancing',
        'Matrix Build Strategy',
        'Environment-specific Deployment'
      ],
      metrics: {
        active_connections: connectionCount,
        uptime: process.uptime()
      }
    };
    
    res.json(info);
  } catch (error) {
    console.error('Error in API info route:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 데이터베이스 테스트 엔드포인트
app.get('/api/db/test', async (req, res) => {
  if (!pool) {
    return res.status(503).json({ error: 'Database not configured' });
  }
  
  try {
    const result = await pool.query('SELECT NOW() as current_time, version() as postgres_version');
    res.json({
      status: 'success',
      data: result.rows[0]
    });
  } catch (error) {
    console.error('Database test error:', error);
    res.status(500).json({ error: 'Database connection failed' });
  }
});

// Redis 테스트 엔드포인트
app.get('/api/redis/test', async (req, res) => {
  if (!redisClient || !redisClient.isOpen) {
    return res.status(503).json({ error: 'Redis not configured' });
  }
  
  try {
    const testKey = 'test:' + Date.now();
    const testValue = 'test_value_' + Math.random();
    
    await redisClient.setEx(testKey, 60, testValue);
    const retrievedValue = await redisClient.get(testKey);
    await redisClient.del(testKey);
    
    res.json({
      status: 'success',
      data: {
        test_key: testKey,
        test_value: testValue,
        retrieved_value: retrievedValue,
        match: testValue === retrievedValue
      }
    });
  } catch (error) {
    console.error('Redis test error:', error);
    res.status(500).json({ error: 'Redis operation failed' });
  }
});

// 서버 시작
app.listen(PORT, () => {
  console.log(`🚀 Day2 Advanced Server running on port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`📈 Metrics: http://localhost:${PORT}/metrics`);
  console.log(`ℹ️  API info: http://localhost:${PORT}/api/info`);
  console.log(`🗄️  DB test: http://localhost:${PORT}/api/db/test`);
  console.log(`🔴 Redis test: http://localhost:${PORT}/api/redis/test`);
});

module.exports = app;