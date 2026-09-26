FROM python:3.11-slim

# Set timezone to Pacific Time non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Upgrade pip and install project dependencies
RUN python -m pip install --upgrade pip && \
    pip install -r requirements-dev.txt && \
    pip install pytest-github-actions-annotate-failures

# Set entrypoint to run tests
ENV TESTS_SKIP_REQUIRES_DOCKER=true
ENTRYPOINT ["pytest", "tests"]