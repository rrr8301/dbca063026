FROM ubuntu:latest

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
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Go stable version (1.25.x)
RUN curl -fsSL https://go.dev/dl/go1.25.0.linux-amd64.tar.gz -o /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

# Set Go environment variables
ENV PATH="/usr/local/go/bin:${PATH}" \
    GOPATH="/root/go" \
    GOFLAGS="-trimpath" \
    DEBUG="true" \
    GOLANGCI_LINT_VERSION="v2.11.4" \
    STATICCHECK_VERSION="2026.1" \
    TPARSE_VERSION="v0.18.0"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and make run.sh executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]