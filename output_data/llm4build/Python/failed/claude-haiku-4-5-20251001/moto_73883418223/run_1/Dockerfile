FROM python:3.11-slim

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Install project dependencies
RUN pip install --upgrade pip setuptools wheel && \
    pip install -r requirements-dev.txt && \
    pip install pytest-github-actions-annotate-failures

# Create and set run.sh as entrypoint
RUN echo '#!/bin/bash\nset -e\ncd /workspace\nexport TESTS_SKIP_REQUIRES_DOCKER=true\npytest tests' > /workspace/run.sh && \
    chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]