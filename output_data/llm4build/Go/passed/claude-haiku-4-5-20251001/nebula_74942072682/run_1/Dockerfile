FROM golang:latest

# Set timezone and locale
ENV TZ=America/Los_Angeles
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    make \
    curl \
    wget \
    ca-certificates \
    protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

# Install golangci-lint v2.5
RUN curl -fsSL https://github.com/golangci/golangci-lint/releases/download/v2.5.0/golangci-lint-2.5.0-linux-amd64.tar.gz -o /tmp/golangci-lint.tar.gz && \
    tar -C /tmp -xzf /tmp/golangci-lint.tar.gz && \
    mv /tmp/golangci-lint-2.5.0-linux-amd64/golangci-lint /usr/local/bin/ && \
    rm -rf /tmp/golangci-lint* && \
    chmod +x /usr/local/bin/golangci-lint

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git to allow workspace directory
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && \
    chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]