FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=America/Los_Angeles \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    CI=true \
    GITHUB_ACTIONS=true

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ca-certificates \
    build-essential \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.24 (or latest available if 1.24 not released)
RUN set -e; \
    GO_VERSION="1.24"; \
    GO_URL="https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"; \
    if ! curl -fsSL --head "$GO_URL" 2>/dev/null | grep -q "200 OK"; then \
        GO_VERSION="1.23"; \
        GO_URL="https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"; \
    fi; \
    curl -fsSL "$GO_URL" -o /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

# Install Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install golangci-lint
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /usr/local/go/bin v1.60.3

# Set Go environment
ENV PATH="/usr/local/go/bin:${PATH}" \
    GOPATH="/home/testuser/go" \
    GOROOT="/usr/local/go"

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

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]