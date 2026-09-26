FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    CI=true \
    GITHUB_ACTIONS=true \
    DEBUG=true \
    GOTOOLCHAIN=local \
    GOFLAGS=-trimpath

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Go (stable version)
RUN curl -fsSL https://go.dev/dl/go1.22.0.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

# Set Go environment
ENV PATH=/usr/local/go/bin:$PATH \
    GOPATH=/home/testuser/go

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git for safe directory
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && \
    chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

# Entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]