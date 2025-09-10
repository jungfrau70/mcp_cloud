# MCP Cloud - 테스트 가이드

## 📖 개요

이 문서는 MCP Cloud 프로젝트의 테스트 환경 설정 및 실행 방법을 설명합니다. pytest를 기반으로 한 백엔드 테스트와 Vitest를 기반으로 한 프론트엔드 테스트를 포함합니다.

## 🧪 테스트 환경 구성

### 백엔드 테스트 (pytest)

#### 의존성 설치
```bash
# 가상환경 활성화
venv\Scripts\activate

# 테스트 의존성 설치
pip install -r backend/requirements-pytest.txt

# 추가 테스트 도구
pip install pytest-cov pytest-xdist pytest-mock
```

#### 테스트 실행 방법

##### 방법 1: Python 스크립트 사용 (권장)
```bash
cd backend
python run_dev.py --test
```

##### 방법 2: Windows 배치 파일 사용
```cmd
backend\run_tests.bat
```

##### 방법 3: 직접 pytest 실행
```bash
cd backend
python -m pytest tests/ -v
```

#### 테스트 실행 옵션

```bash
# 기본 테스트 실행
pytest tests/

# 상세 출력
pytest tests/ -v

# 커버리지 포함
pytest --cov=backend tests/

# 커버리지 리포트 생성
pytest --cov=backend --cov-report=html tests/

# 병렬 실행
pytest -n auto tests/

# 특정 테스트 파일
pytest tests/test_ai_agent.py

# 특정 테스트 함수
pytest tests/test_ai_agent.py::TestTerraformCodeGenerator::test_generate_code_success

# 실패한 테스트만 재실행
pytest --lf

# 출력 캡처 비활성화
pytest -s

# 트레이스백 상세 출력
pytest --tb=long

# 특정 테스트에서 중단점 설정
pytest --pdb
```

### 프론트엔드 테스트 (Vitest)

```bash
cd frontend
yarn test          # 테스트 실행
yarn test:coverage # 커버리지 포함 테스트
yarn test:ui       # UI 테스트 러너
```

## 📁 테스트 구조

```
tests/
├── conftest.py                    # pytest 공통 설정
├── test_ai_agent.py              # AI Agent 기능 테스트
├── test_api_integration.py        # API 통합 테스트
├── test_cloud_connectors.py       # 클라우드 커넥터 테스트
├── test_database.py               # 데이터베이스 테스트
├── test_terraform.py              # Terraform 엔진 테스트
└── test_security.py               # 보안 기능 테스트
```

## 🔧 테스트 설정

### conftest.py 설정

```python
import sys
import os

# 백엔드 모듈 경로 추가
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'backend')))

# 공통 fixtures 및 설정
```

### 환경 변수 설정

테스트 실행 시 필요한 환경 변수:
```bash
# 테스트용 데이터베이스
DATABASE_URL=postgresql://testuser:testpass@localhost:5434/test_db

# 테스트용 API 키
GEMINI_API_KEY=test_key
MCP_API_KEY=test_mcp_key

# 테스트 환경
ENVIRONMENT=test
DEBUG=false
```

## 🗄️ 테스트 데이터베이스

### PostgreSQL 테스트 데이터베이스

```bash
# 테스트용 데이터베이스 생성
createdb -U postgres mcp_test_db

# 테스트용 사용자 생성
psql -U postgres -c "CREATE USER testuser WITH PASSWORD 'testpass';"
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE mcp_test_db TO testuser;"
```

### SQLite 인메모리 (빠른 테스트용)

```python
# conftest.py에서 설정
@pytest.fixture
def test_db():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    return engine
```

## 🧪 테스트 작성 가이드

### 테스트 클래스 구조

```python
import pytest
from unittest.mock import Mock, patch

class TestFeatureName:
    """기능명 테스트 클래스"""
    
    def setup_method(self):
        """테스트 메서드 실행 전 설정"""
        self.mock_service = Mock()
        self.test_instance = FeatureClass(self.mock_service)
    
    def test_success_case(self):
        """성공 케이스 테스트"""
        # Given
        expected_result = "success"
        self.mock_service.method.return_value = expected_result
        
        # When
        result = self.test_instance.method()
        
        # Then
        assert result == expected_result
        self.mock_service.method.assert_called_once()
    
    def test_error_case(self):
        """오류 케이스 테스트"""
        # Given
        self.mock_service.method.side_effect = Exception("Test error")
        
        # When & Then
        with pytest.raises(Exception) as exc_info:
            self.test_instance.method()
        
        assert "Test error" in str(exc_info.value)
```

### Mock 사용법

```python
from unittest.mock import Mock, patch, MagicMock

class TestWithMocks:
    def test_external_api_call(self):
        """외부 API 호출 모킹 테스트"""
        with patch('requests.get') as mock_get:
            # Mock 응답 설정
            mock_response = Mock()
            mock_response.status_code = 200
            mock_response.json.return_value = {"data": "test"}
            mock_get.return_value = mock_response
            
            # 테스트 실행
            result = call_external_api()
            
            # 검증
            assert result["data"] == "test"
            mock_get.assert_called_once_with("https://api.example.com/data")
```

### Fixture 사용법

```python
import pytest

@pytest.fixture
def sample_data():
    """샘플 데이터 fixture"""
    return {
        "id": 1,
        "name": "Test Item",
        "status": "active"
    }

@pytest.fixture
def mock_database():
    """Mock 데이터베이스 fixture"""
    with patch('database.connection') as mock_db:
        yield mock_db

def test_with_fixtures(sample_data, mock_database):
    """Fixture를 사용한 테스트"""
    mock_database.query.return_value = sample_data
    
    result = get_item(1)
    assert result["name"] == "Test Item"
```

## 📊 테스트 커버리지

### 커버리지 설정

```ini
# .coveragerc
[run]
source = backend
omit = 
    */tests/*
    */venv/*
    */migrations/*
    */__pycache__/*

[report]
exclude_lines =
    pragma: no cover
    def __repr__
    if self.debug:
    if settings.DEBUG
    raise AssertionError
    raise NotImplementedError
    if 0:
    if __name__ == .__main__.:
    class .*\bProtocol\):
    @(abc\.)?abstractmethod
```

### 커버리지 실행

```bash
# 기본 커버리지
pytest --cov=backend tests/

# HTML 리포트 생성
pytest --cov=backend --cov-report=html tests/

# XML 리포트 생성 (CI/CD용)
pytest --cov=backend --cov-report=xml tests/

# 터미널에서 상세 출력
pytest --cov=backend --cov-report=term-missing tests/
```

## 🚀 CI/CD 통합

### GitHub Actions 예시

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.12'
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r backend/requirements-pytest.txt
    
    - name: Run tests
      env:
        DATABASE_URL: postgresql://postgres:postgres@localhost:5432/postgres
        GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
      run: |
        cd backend
        python -m pytest tests/ --cov=backend --cov-report=xml
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./backend/coverage.xml
```

## 🔍 디버깅

### 테스트 디버깅 옵션

```bash
# 출력 캡처 비활성화
pytest -s

# 특정 테스트에서 중단점 설정
pytest --pdb

# 트레이스백 상세 출력
pytest --tb=long

# 로그 레벨 설정
pytest --log-cli-level=DEBUG

# 특정 테스트만 실행
pytest -k "test_name"
```

### VS Code 설정

```json
// .vscode/settings.json
{
    "python.testing.pytestEnabled": true,
    "python.testing.unittestEnabled": false,
    "python.testing.pytestArgs": [
        "tests"
    ],
    "python.testing.cwd": "${workspaceFolder}/backend"
}
```

## 📈 성능 테스트

### 병렬 테스트 실행

```bash
# CPU 코어 수에 따른 병렬 실행
pytest -n auto tests/

# 특정 수의 워커로 실행
pytest -n 4 tests/

# 메모리 제한 설정
pytest -n auto --dist=worksteal tests/
```

### 테스트 시간 측정

```bash
# 테스트 실행 시간 측정
pytest --durations=10 tests/

# 느린 테스트 식별
pytest --durations=0 tests/
```

## 🧹 테스트 정리

### 테스트 데이터 정리

```python
@pytest.fixture(autouse=True)
def cleanup_test_data():
    """테스트 후 데이터 정리"""
    yield
    # 테스트 후 정리 작업
    cleanup_database()
    cleanup_files()
```

### 임시 파일 정리

```python
import tempfile
import shutil

@pytest.fixture
def temp_dir():
    """임시 디렉토리 fixture"""
    temp_dir = tempfile.mkdtemp()
    yield temp_dir
    shutil.rmtree(temp_dir)
```

## 📚 추가 리소스

### pytest 공식 문서
- [pytest 공식 문서](https://docs.pytest.org/)
- [pytest fixtures](https://docs.pytest.org/en/stable/explanation/fixtures.html)
- [pytest plugins](https://docs.pytest.org/en/stable/reference/plugin_list.html)

### 테스트 모범 사례
- [Python Testing with pytest](https://pytest.org/latest/)
- [Effective Python Testing](https://realpython.com/python-testing/)
- [Test-Driven Development](https://en.wikipedia.org/wiki/Test-driven_development)

### 도구 및 플러그인
- **pytest-cov**: 커버리지 측정
- **pytest-xdist**: 병렬 테스트 실행
- **pytest-mock**: Mock 객체 지원
- **pytest-asyncio**: 비동기 테스트 지원
- **pytest-html**: HTML 리포트 생성

---

**테스트는 코드 품질의 보증서입니다!** 🧪✨
