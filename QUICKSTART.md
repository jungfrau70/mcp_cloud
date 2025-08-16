# 🚀 MCP Cloud - 빠른 시작 가이드

## ⚡ 5분 만에 시작하기

### 1️⃣ 환경 준비
```bash
# Python 3.12+ 확인
python --version

# 가상환경 생성 및 활성화
python -m venv venv
venv\Scripts\activate  # Windows
# source venv/bin/activate  # Linux/Mac
```

### 2️⃣ 의존성 설치
```bash
# Backend 의존성
pip install -r backend/requirements.txt

# Frontend 의존성
cd frontend && yarn install && cd ..
```

### 3️⃣ 데이터베이스 시작
```bash
# PostgreSQL 컨테이너 시작
docker-compose up -d postgres

# 상태 확인
docker-compose ps postgres
```

### 4️⃣ 백엔드 실행
```bash
# 방법 1: 자동 실행 (권장)
backend\run_dev.bat

# 방법 2: 수동 실행
cd backend
python run_dev.py
```

### 5️⃣ 프론트엔드 실행
```bash
cd frontend
yarn dev
```

### 6️⃣ 접속 확인
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:7000
- **API 문서**: http://localhost:7000/docs

## 🧪 테스트 실행

```bash
# 백엔드 테스트
backend\run_tests.bat

# 프론트엔드 테스트
cd frontend && yarn test
```

## 🔧 문제 해결

### 가상환경 문제
```bash
# 가상환경 재생성
rm -rf venv/
python -m venv venv
venv\Scripts\activate
```

### 포트 충돌
```bash
# 다른 포트 사용
python run_dev.py --port 7001
```

### 데이터베이스 연결 실패
```bash
# 컨테이너 상태 확인
docker-compose ps
docker-compose logs postgres
```

## 📚 다음 단계

- [전체 README](README.md) - 상세한 프로젝트 정보
- [백엔드 개발 가이드](backend/README_DEV.md) - 백엔드 개발 상세 가이드
- [테스트 가이드](tests/README.md) - 테스트 환경 및 실행 방법

---

**즐거운 개발 되세요!** 🎉
