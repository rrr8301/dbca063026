FROM golang:1.24-bookworm

# Set timezone and locale
ENV TZ=America/Los_Angeles \
    DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    CI=true \
    GITHUB_ACTIONS=true

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Go is already installed in the base image
ENV PATH="/usr/local/go/bin:${PATH}" \
    GOPATH="/home/testuser/go"

# Install Node.js (LTS version compatible with yarn)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install yarn
RUN npm install -g yarn

# Install golangci-lint using go install (more reliable than the installer script)
RUN go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.59.1

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