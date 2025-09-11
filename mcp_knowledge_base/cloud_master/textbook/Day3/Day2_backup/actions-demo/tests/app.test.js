const request = require('supertest');
const app = require('../app');

describe('App Tests', () => {
  // 테스트 환경 설정
  beforeAll(() => {
    process.env.NODE_ENV = 'test';
  });

  test('GET / should return welcome message', async () => {
    const response = await request(app).get('/');
    expect(response.status).toBe(200);
    expect(response.body.message).toBe('Hello GitHub Actions!');
  });

  test('GET /health should return health status', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
    expect(response.body.status).toBe('OK');
  });
});


