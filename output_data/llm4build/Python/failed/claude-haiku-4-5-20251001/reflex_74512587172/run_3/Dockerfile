FROM python:3.12-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    redis-server \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip install uv

# Copy project files
COPY . .

# Sync dependencies
RUN uv sync

# Expose Redis port
EXPOSE 6379

# Start Redis and run tests
ENTRYPOINT ["/app/run.sh"]