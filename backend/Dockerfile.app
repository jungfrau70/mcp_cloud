# App stage - Build and runtime for backend
FROM mcp-backend:package AS app

RUN apt-get update && apt-get install -y groff less

WORKDIR /app

# Copy application code
COPY . . 

# Ensure Python dependencies available in runtime image (defensive against stale base)
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Health check (fix malformed URL + allow longer startup for embeddings/RAG init)
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -fsS http://localhost:8000/health || exit 1

EXPOSE 8000

# Use system Python directly with reload for hot-reload in dev
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload", "--log-level", "info"]
