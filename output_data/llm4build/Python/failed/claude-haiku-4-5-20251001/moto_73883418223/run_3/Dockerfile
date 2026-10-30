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
    if [ -f requirements-dev.txt ]; then pip install -r requirements-dev.txt; fi && \
    pip install pytest-github-actions-annotate-failures

ENTRYPOINT ["pytest"]