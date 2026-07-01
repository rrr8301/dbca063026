FROM ubuntu:24.04

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

# Install Go
# Using a recent stable version; adjust if .github/env specifies otherwise
ENV GOLANG_VERSION=1.22.0
RUN curl -fsSL https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz | tar -xz -C /usr/local

# Set Go environment variables
ENV PATH=/usr/local/go/bin:$PATH \
    GOPATH=/go \
    GOROOT=/usr/local/go

# Create work directory
WORKDIR /workspace

# Copy the repository
COPY . .

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]