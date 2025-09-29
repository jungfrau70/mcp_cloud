# Docker Advanced 실습 데모 애플리케이션

이 애플리케이션은 Docker 고급 실습을 위한 샘플 애플리케이션입니다.

## 기능
- Express.js 기반 웹 서버
- 헬스 체크 엔드포인트
- 시스템 정보 API
- 보안 미들웨어 적용

## 실행 방법
```bash
npm install
npm start
```

## API 엔드포인트
- GET / - 기본 정보
- GET /health - 헬스 체크
- GET /api/info - 시스템 정보
