FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ca-certificates \
    build-essential \
    make \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Copy the repository
COPY . .

# Extract Go version from go.mod and install Go
RUN GO_VERSION=$(grep -oP '(?<=^go )[\d.]+' go.mod | head -1) && \
    curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

# Add Go to PATH
ENV PATH="/usr/local/go/bin:${PATH}"

# Set environment variables from workflow
ENV CGO_ENABLED=0
ENV ACT_OWNER=nektos
ENV ACT_REPOSITORY=nektos/act

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]