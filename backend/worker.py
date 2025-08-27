import os
from celery import Celery

# Broker/Backend from environment (default to Redis local for dev)
BROKER_URL = os.getenv("CELERY_BROKER_URL", "redis://localhost:6379/0")
RESULT_BACKEND = os.getenv("CELERY_RESULT_BACKEND", BROKER_URL)

celery_app = Celery("mcp_backend", broker=BROKER_URL, backend=RESULT_BACKEND)

# Queues per role
celery_app.conf.task_queues = {
    "plan": {},
    "apply": {},
    "test": {},
}

celery_app.conf.task_default_queue = "plan"
celery_app.conf.result_expires = 3600
celery_app.conf.task_time_limit = int(os.getenv("CELERY_TASK_TIME_LIMIT", "3600"))
celery_app.conf.task_soft_time_limit = int(os.getenv("CELERY_TASK_SOFT_TIME_LIMIT", "1800"))

try:
    # Optional: OpenTelemetry instrumentation in worker process
    from observability import setup_tracer, instrument_celery

    setup_tracer()
    instrument_celery()
except Exception:
    pass


@celery_app.task(name="plan.run", bind=True, autoretry_for=(Exception,), retry_backoff=True, retry_kwargs={"max_retries": 3})
def run_plan(self, deployment_id: int, template: str, variables: dict) -> dict:
    # Placeholder for terraform plan execution logic
    # Return structured result to be stored by API layer
    return {"deployment_id": deployment_id, "status": "PLAN_OK", "summary": "plan executed (stub)"}


@celery_app.task(name="apply.run", bind=True, autoretry_for=(Exception,), retry_backoff=True, retry_kwargs={"max_retries": 2})
def run_apply(self, deployment_id: int) -> dict:
    return {"deployment_id": deployment_id, "status": "APPLY_OK", "summary": "apply executed (stub)"}


@celery_app.task(name="test.run", bind=True, autoretry_for=(Exception,), retry_backoff=True, retry_kwargs={"max_retries": 2})
def run_test(self, deployment_id: int) -> dict:
    return {"deployment_id": deployment_id, "status": "TEST_OK", "summary": "tests executed (stub)"}


