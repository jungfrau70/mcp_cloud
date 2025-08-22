# App stage - Build and runtime
FROM mcp-frontend:package AS app

WORKDIR /app

# Copy source code
COPY . .

# Expose port
EXPOSE 3000

# Set environment variables for dev hot-reload
ENV NODE_ENV=development
ENV HOST=0.0.0.0
ENV PORT=3000

# Default command will be overridden by docker-compose in dev to run `yarn dev`
CMD ["yarn", "dev", "--host", "0.0.0.0", "--port", "3000"]
