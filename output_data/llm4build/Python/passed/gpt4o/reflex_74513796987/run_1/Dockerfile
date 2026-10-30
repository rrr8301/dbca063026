FROM python:3.11-slim

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    redis-server

# Set up work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Install Python dependencies using uv
RUN curl -sSL https://install.python-poetry.org | python3 - && \
    python3 -m venv .venv && \
    . .venv/bin/activate && \
    pip install uv && \
    uv sync

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]