const request = require('supertest');
const app = require('./index');

describe('App', () => {
  test('GET / should return hello message', async () => {
    const response = await request(app).get('/');
    expect(response.status).toBe(200);
    expect(response.body.message).toBe('Hello from CI/CD pipeline!');
  });

  test('GET /health should return health status', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
    expect(response.body.status).toBe('healthy');
  });

  test('GET /info should return app info', async () => {
    const response = await request(app).get('/info');
    expect(response.status).toBe(200);
    expect(response.body.nodeVersion).toBeDefined();
  });
});
