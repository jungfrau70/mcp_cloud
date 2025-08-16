# App stage - Build and runtime for backend
FROM mcp-backend:package AS app

WORKDIR /app

# Copy application code
COPY . . 

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000   /health || exit 1

EXPOSE 8000

# Use system Python directly
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
