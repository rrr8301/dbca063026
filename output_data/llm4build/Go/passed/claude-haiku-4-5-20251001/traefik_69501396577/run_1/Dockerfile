FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy the repository
COPY . .

# Extract Go version from .go-version file and install Go
RUN GO_VERSION=$(cat .go-version | tr -d ' \n\r') && \
    echo "Attempting to download Go version: $GO_VERSION" && \
    if ! curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -o go.tar.gz; then \
        echo "Failed to download go${GO_VERSION}.linux-amd64.tar.gz, trying without 'go' prefix"; \
        GO_VERSION=$(echo $GO_VERSION | sed 's/^go//') && \
        curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -o go.tar.gz; \
    fi && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

# Add Go to PATH
ENV PATH="/usr/local/go/bin:${PATH}"

# Verify Go installation
RUN go version

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]