import os
import sys
import asyncio
import importlib
from unittest.mock import patch, AsyncMock

import pytest


@pytest.mark.unit
def test_scheduler_cron_time_settings(monkeypatch):
    # 준비: 모듈을 새로 로드하여 최신 스케줄 설정을 반영하도록 함
    if 'main' in sys.modules:
        importlib.invalidate_caches()
        sys.modules.pop('main')

    # 인증 우회 허용 (일부 경로에선 필요 없지만 안전하게)
    monkeypatch.setenv("DISABLE_AUTH", "true")
    monkeypatch.setenv("MCP_API_KEY", os.environ.get("MCP_API_KEY", "test_mcp_key"))

    # Act: main 모듈 로드
    import main as backend_main

    # Assert: APScheduler AsyncIOScheduler가 Asia/Seoul 로 설정되었는지 확인하기 위해
    # 직접 스케줄러 인스턴스는 외부로 노출되지 않으므로, 문자열(로그)와 add_job 파라미터 검증을 병행
    # 여기서는 내부 함수를 임시 패치해서 의도된 hour/minute를 확인
    with patch.object(backend_main, 'AsyncIOScheduler') as MockScheduler:
        instance = MockScheduler.return_value
        backend_main._start_scheduler(backend_main.app)
        # timezone 전달 확인
        MockScheduler.assert_called_with(timezone="Asia/Seoul")
        # add_job 인자 검증: positional/keyword 모두 처리
        call_args, call_kwargs = instance.add_job.call_args
        # trigger는 두 번째 positional 인자('cron')로 전달됨
        assert len(call_args) >= 2
        assert call_args[1] == 'cron'
        assert call_kwargs.get('hour') == 10
        assert call_kwargs.get('minute') == 30


@pytest.mark.unit
@pytest.mark.asyncio
async def test_run_now_endpoint_executes_generation(monkeypatch):
    # 인증 우회 및 키 설정
    monkeypatch.setenv("DISABLE_AUTH", "true")
    monkeypatch.setenv("MCP_API_KEY", os.environ.get("MCP_API_KEY", "test_mcp_key"))

    # 최신 상태로 모듈 로드
    if 'main' in sys.modules:
        importlib.invalidate_caches()
        sys.modules.pop('main')
    import main as backend_main

    # _generate_trending_docs 가 실제 네트워크 호출을 하지 않도록 모킹
    called = {'ran': False}
    async def fake_generate():
        called['ran'] = True
    monkeypatch.setattr(backend_main, '_generate_trending_docs', fake_generate)

    # 엔드포인트 함수 직접 호출 (FastAPI TestClient 대신 간단 검증)
    resp = await backend_main.run_trending_now()
    assert resp == { 'ok': True }
    assert called['ran'] is True


