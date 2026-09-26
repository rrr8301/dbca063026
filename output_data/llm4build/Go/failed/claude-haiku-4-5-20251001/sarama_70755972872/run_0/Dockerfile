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

# Install Go stable version
RUN curl -fsSL https://go.dev/dl/?mode=json | grep -o '"version":"go[^"]*' | head -1 | cut -d'"' -f4 > /tmp/go_version.txt && \
    GO_VERSION=$(cat /tmp/go_version.txt) && \
    curl -fsSL https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz -o /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz /tmp/go_version.txt

# Set Go environment variables
ENV PATH="/usr/local/go/bin:${PATH}" \
    GOPATH="/root/go" \
    GOFLAGS="-trimpath" \
    DEBUG="true" \
    GOTOOLCHAIN="local" \
    GOLANGCI_LINT_VERSION="v2.11.4" \
    STATICCHECK_VERSION="2026.1" \
    TPARSE_VERSION="v0.18.0"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]