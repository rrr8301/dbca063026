FROM python:3.12-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip install uv

# Copy project files
COPY . .

# Make run.sh executable
RUN chmod +x /app/run.sh

# Sync dependencies
RUN uv sync

# Start tests
ENTRYPOINT ["/app/run.sh"]