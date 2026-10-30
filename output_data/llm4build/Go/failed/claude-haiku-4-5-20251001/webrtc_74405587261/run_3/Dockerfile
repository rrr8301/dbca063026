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

# Create non-root user BEFORE installing Go tools
RUN useradd -m testuser

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git for safe directory
RUN git config --global --add safe.directory '*'

# Set proper ownership of workspace and GOPATH
RUN chown -R testuser:testuser /workspace && \
    mkdir -p /home/testuser/go && \
    chown -R testuser:testuser /home/testuser/go

# Switch to non-root user
USER testuser

# Install golangci-lint as testuser
RUN go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.59.1

# Update PATH to include testuser's go bin
ENV PATH="/home/testuser/go/bin:${PATH}"

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]