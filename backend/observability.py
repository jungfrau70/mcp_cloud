import os
import logging

try:
    from opentelemetry import trace
    from opentelemetry.sdk.resources import Resource
    from opentelemetry.sdk.trace import TracerProvider
    from opentelemetry.sdk.trace.export import BatchSpanProcessor
    from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
    from opentelemetry.instrumentation.requests import RequestsInstrumentor
    from opentelemetry.instrumentation.httpx import HTTPXClientInstrumentor
    from opentelemetry.instrumentation.psycopg2 import Psycopg2Instrumentor
    from opentelemetry.instrumentation.redis import RedisInstrumentor
    from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
    OTEL_AVAILABLE = True
except Exception:  # pragma: no cover - optional dependency
    OTEL_AVAILABLE = False

logger = logging.getLogger(__name__)


def setup_tracer() -> None:
    """Initialize OpenTelemetry tracer provider with OTLP exporter.

    Safe no-op if OpenTelemetry is not installed.
    """
    if not OTEL_AVAILABLE:
        logger.info("OpenTelemetry not available; skipping tracer setup")
        return

    endpoint = os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT", "http://localhost:4317")
    service_name = os.getenv("OTEL_SERVICE_NAME", "mcp-backend")
    resource = Resource.create({"service.name": service_name})

    provider = TracerProvider(resource=resource)
    exporter = OTLPSpanExporter(endpoint=endpoint, insecure=True)
    processor = BatchSpanProcessor(exporter)
    provider.add_span_processor(processor)
    trace.set_tracer_provider(provider)

    # Base client instrumentation (does not require FastAPI app)
    try:
        RequestsInstrumentor().instrument()
    except Exception:
        pass
    try:
        HTTPXClientInstrumentor().instrument()
    except Exception:
        pass
    try:
        Psycopg2Instrumentor().instrument()
    except Exception:
        pass
    try:
        RedisInstrumentor().instrument()
    except Exception:
        pass


def instrument_fastapi(app) -> None:
    """Attach FastAPI/ASGI instrumentation to an app instance.

    Safe no-op if OpenTelemetry is not installed.
    """
    if not OTEL_AVAILABLE:
        return
    try:
        FastAPIInstrumentor().instrument_app(app)
    except Exception:
        # Keep the app running even if instrumentation fails
        logger.exception("Failed to instrument FastAPI app with OpenTelemetry")


def instrument_celery() -> None:
    """Enable Celery instrumentation.

    This should be called in the Celery worker process.
    """
    if not OTEL_AVAILABLE:
        return
    try:
        from opentelemetry.instrumentation.celery import CeleryInstrumentor

        CeleryInstrumentor().instrument()
    except Exception:
        logger.exception("Failed to instrument Celery with OpenTelemetry")


