# Backend Development Guide

## 개요
이 문서는 MCP Cloud 백엔드를 가상환경 및 pytest 환경에서 개발하고 테스트하는 방법을 설명합니다.

## 사전 요구사항

### Python 환경
- Python 3.12 이상
- pip (Python 패키지 관리자)

### 가상환경
프로젝트 루트에 `venv/` 디렉토리가 있어야 합니다.

```bash
# 가상환경이 없는 경우 생성
python -m venv venv
```

## 빠른 시작

### 1. 가상환경 활성화

#### Windows CMD
```cmd
venv\Scripts\activate
```

#### Windows PowerShell
```powershell
venv\Scripts\Activate.ps1
```

#### Linux/Mac
```bash
source venv/bin/activate
```

### 2. 의존성 설치
```bash
# 기본 의존성
pip install -r requirements.txt

# 테스트 의존성
pip install -r requirements-pytest.txt
```

### 3. 백엔드 서버 실행

#### 방법 1: Python 스크립트 사용 (권장)
```bash
cd backend
python run_dev.py
```

#### 방법 2: 직접 uvicorn 실행
```bash
cd backend
uvicorn main:app --reload --host 0.0.0.0 --port 7000
```

#### 방법 3: Windows 배치 파일 사용
```cmd
backend\run_dev.bat
```

### 4. 테스트 실행

#### 방법 1: Python 스크립트 사용
```bash
cd backend
python run_dev.py --test
```

#### 방법 2: 직접 pytest 실행
```bash
cd backend
python -m pytest tests/ -v
```

#### 방법 3: Windows 배치 파일 사용
```cmd
backend\run_tests.bat
```

## 개발 환경 설정

### 환경 변수
백엔드는 다음 환경 변수를 자동으로 설정합니다:

- `DATABASE_URL`: PostgreSQL 연결 문자열
- `GEMINI_API_KEY`: Gemini API 키 (개발용 더미 값)
- `MCP_API_KEY`: MCP API 키
- `AWS_DEFAULT_REGION`: AWS 기본 리전
- `ENVIRONMENT`: 환경 설정 (development)
- `DEBUG`: 디버그 모드 (true)

### 클라우드 자격 증명
- **AWS**: `env/rootkey.csv` 파일에서 자동 읽기
- **GCP**: `env/alpha-ktixap-43e9bf90eb00.json` 파일 사용

## 테스트 환경

### 테스트 실행 옵션
```bash
# 모든 테스트 실행
pytest tests/

# 커버리지 포함
pytest --cov=backend tests/

# 특정 테스트 파일
pytest tests/test_ai_agent.py

# 특정 테스트 함수
pytest tests/test_ai_agent.py::TestTerraformCodeGenerator::test_generate_code_success

# 실패한 테스트만 재실행
pytest --lf

# 상세 출력
pytest -v

# 병렬 실행
pytest -n auto tests/
```

### 테스트 데이터베이스
- 테스트는 별도 데이터베이스 또는 SQLite 인메모리 사용
- `conftest.py`에서 공통 테스트 설정 관리
- 외부 API 호출은 unittest.mock으로 모킹

## 문제 해결

### 일반적인 문제들

#### 1. 가상환경 활성화 실패
```bash
# 가상환경 재생성
rm -rf venv/
python -m venv venv
```

#### 2. 패키지 설치 실패
```bash
# pip 업그레이드
pip install --upgrade pip

# 캐시 클리어
pip cache purge
```

#### 3. 포트 충돌
```bash
# 다른 포트 사용
python run_dev.py --port 7001
```

#### 4. 데이터베이스 연결 실패
```bash
# PostgreSQL 컨테이너 시작
docker-compose up -d postgres

# 또는 로컬 PostgreSQL 서비스 확인
```

### 디버깅 도구

#### FastAPI 내장 도구
- **Swagger UI**: http://localhost:7000/docs
- **ReDoc**: http://localhost:7000/redoc
- **Health Check**: http://localhost:7000/health

#### 로깅
```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

#### pytest 디버깅
```bash
# 출력 캡처 비활성화
pytest -s

# 트레이스백 상세 출력
pytest --tb=long

# 특정 테스트에서 중단점 설정
pytest --pdb
```

## 성능 최적화

### 개발 환경
- **Hot Reload**: 코드 변경 시 자동 재시작
- **테스트 병렬화**: `pytest -n auto` 사용
- **커버리지 캐싱**: pytest-cov 플러그인 활용

### 메모리 관리
- 불필요한 패키지 제거
- 테스트 실행 후 메모리 정리
- 가상환경 크기 최소화

## 워크플로우

### 1. 개발 시작
```bash
# 가상환경 활성화
venv\Scripts\activate

# 의존성 설치
pip install -r backend/requirements.txt

# 백엔드 서버 시작
cd backend
python run_dev.py
```

### 2. 코드 작성 및 테스트
```bash
# 새 터미널에서 테스트 실행
cd backend
python run_dev.py --test
```

### 3. 개발 완료
```bash
# 서버 중지 (Ctrl+C)
# 가상환경 비활성화
deactivate
```

## 추가 리소스

### 문서
- [FastAPI 공식 문서](https://fastapi.tiangolo.com/)
- [pytest 공식 문서](https://docs.pytest.org/)
- [SQLAlchemy 공식 문서](https://docs.sqlalchemy.org/)

### 도구
- **API 테스트**: Postman, Insomnia
- **데이터베이스**: pgAdmin, DBeaver
- **코드 품질**: Black, Flake8, mypy

### 커뮤니티
- FastAPI Discord
- pytest GitHub Discussions
- Python 한국 사용자 그룹

## Gemini / LLM 쿼터 초과 처리 (2025-08 추가)

무료 티어 또는 제한된 Gemini API 사용 중 429(ResourceExhausted) 오류가 반복될 수 있습니다. `rag_service.py` 에서는 다음 대응을 구현했습니다:

1. 429/쿼터 관련 예외 감지 → 다음 후보 모델 순차 폴백 (기본: flash → flash-8b → pro)
2. 모든 후보 모델 소진 시 600초(기본, `RAG_QUOTA_COOLDOWN_SECS`로 조정) 쿨다운 적용
3. 쿨다운 기간엔 LLM 미호출, 로컬 벡터 검색 상위 결과 요약 반환
4. 사용자 메시지에 대안 제시: 다른 API Key, 모델 변경, 쿼터 리셋, 캐시 활용

### 설정/튜닝 방법
- 환경변수:
	- `RAG_LLM_FALLBACK_MODELS`: 콤마 구분 커스텀 모델 순서 (예: `gemini-1.5-flash,gemini-1.5-flash-8b,gemini-1.5-pro`)
	- `RAG_PRIMARY_MODEL`: 첫 번째 기본 모델 (미설정 시 flash)
	- `RAG_QUOTA_COOLDOWN_SECS`: 쿨다운 초 (기본 600)
- 쿨다운 시간 조정: `RAG_QUOTA_COOLDOWN_SECS=300` 등 설정
- 폴백 비활성화: `RAG_LLM_FALLBACK_MODELS`를 단일 모델로 설정하거나 코드에서 모델 리스트 로직 제거
- 경량 모델 우선: `RAG_LLM_FALLBACK_MODELS=gemini-1.5-flash-8b,gemini-1.5-flash` (저비용→기본)

### 로컬 캐시 활용 아이디어 (추후)
- 동일 질문 해시 기반 (SHA-1) => 최근 N개 응답 메모리/디스크 캐시
- 캐시 hit 시 LLM 호출 생략, TTL 정책 적용
- 추가 시 주의: 민감 데이터 포함 가능성 -> PII 마스킹 or opt-in 환경 변수

### 장애 시 빠른 점검 체크리스트
| 항목 | 확인 | 액션 |
|------|------|------|
| GEMINI_API_KEY | 값/유효성 | 키 재발급/롤링 |
| 모델 폴백 순서 | `RAG_LLM_FALLBACK_MODELS` | 순서 조정(경량→고사양) |
| 429 빈도 | 로그 | 모델 교체/쿼터 업그레이드 |
| 쿨다운 동작 | "쿨다운" 경고 존재 | 기간 조정/비활성화 |
| 벡터 스토어 최신성 | 업데이트 로그 | `/api/v1/knowledge/docs` 저장 시 refresh_vector 사용 |

### 향후 개선 제안
- 지연 재시도 (Exponential Backoff) 후 부분 응답 스트리밍
- 멀티 LLM 폴백 체인 (Gemini -> OpenAI -> 로컬 LLM)
- 비용/쿼터 대시보드 집계 엔드포인트 추가

이 섹션은 LLM 호출 관련 운영 안정성을 높이기 위한 참고용입니다.
