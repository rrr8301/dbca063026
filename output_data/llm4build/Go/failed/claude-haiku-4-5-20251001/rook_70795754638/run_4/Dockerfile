FROM ubuntu:22.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    make \
    gcc \
    g++ \
    jq \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Go using golang-go package (system Go) as fallback
# This ensures Go is available; version will be system default
RUN apt-get update && apt-get install -y --no-install-recommends \
    golang-go \
    && rm -rf /var/lib/apt/lists/*

# Attempt to install Go 1.25 from golang.org, but fall back to system Go if unavailable
RUN set +e; \
    curl -fsSL https://go.dev/dl/go1.25.linux-amd64.tar.gz -o /tmp/go.tar.gz 2>/dev/null && \
    if [ -f /tmp/go.tar.gz ]; then \
        tar -C /usr/local -xzf /tmp/go.tar.gz && \
        rm /tmp/go.tar.gz; \
    fi; \
    set -e

# Set Go environment variables
ENV PATH="/usr/local/go/bin:$PATH" \
    GOPATH="/root/go" \
    GOROOT="/usr/local/go"

# Create work directory
WORKDIR /workspace

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]