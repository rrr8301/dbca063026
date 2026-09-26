FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    make \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Go - attempt 1.25, fallback to latest available
RUN set -e; \
    GO_VERSION="1.25"; \
    GO_URL="https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"; \
    if ! curl -fsSL --head "$GO_URL" 2>/dev/null | grep -q "200\|301\|302"; then \
        echo "Go ${GO_VERSION} not found, attempting to fetch latest available version..."; \
        GO_VERSION=$(curl -fsSL https://go.dev/dl/ | grep -oP 'go\d+\.\d+(?:\.\d+)?' | sort -V | tail -1 | sed 's/go//'); \
        GO_URL="https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"; \
        echo "Using Go ${GO_VERSION}"; \
    fi; \
    curl -fsSL "$GO_URL" -o /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

# Set Go environment variables
ENV PATH="/usr/local/go/bin:${PATH}" \
    GOPATH="/root/go" \
    GOROOT="/usr/local/go"

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]