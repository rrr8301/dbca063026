FROM ubuntu:22.04

# Set timezone to Pacific Time (non-interactive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    make \
    curl \
    wget \
    ca-certificates \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Extract Go version from go.mod and install Go
RUN GO_VERSION=$(grep "^go " go.mod | awk '{print $2}') && \
    curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

# Add Go to PATH
ENV PATH="/usr/local/go/bin:${PATH}"

# Install golangci-lint
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /usr/local/bin v2.11.4

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN dos2unix /workspace/run.sh && chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]