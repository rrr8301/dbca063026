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
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install Go with fallback logic
RUN set -e; \
    GO_VERSION="1.25"; \
    GO_FOUND=0; \
    for VERSION in "1.25" "1.23" "1.22"; do \
        GO_URL="https://go.dev/dl/go${VERSION}.linux-amd64.tar.gz"; \
        echo "Attempting to download Go ${VERSION}..."; \
        if curl -fsSL --head "$GO_URL" 2>/dev/null | grep -q "200"; then \
            echo "Found Go ${VERSION}"; \
            curl -fsSL "$GO_URL" -o /tmp/go.tar.gz && \
            tar -C /usr/local -xzf /tmp/go.tar.gz && \
            rm /tmp/go.tar.gz && \
            GO_FOUND=1; \
            break; \
        else \
            echo "Go ${VERSION} not found, trying next version..."; \
        fi; \
    done; \
    if [ $GO_FOUND -eq 0 ]; then \
        echo "Failed to download any supported Go version"; \
        exit 1; \
    fi

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