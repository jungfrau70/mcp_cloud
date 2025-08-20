# App stage - Build and runtime for backend
FROM mcp-backend:package AS app

WORKDIR /app

# Copy application code
COPY . . 

# Health check (fix malformed URL + allow longer startup for embeddings/RAG init)
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -fsS http://localhost:8000/health || exit 1

EXPOSE 8000

# Use system Python directly with reload for hot-reload in dev
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
