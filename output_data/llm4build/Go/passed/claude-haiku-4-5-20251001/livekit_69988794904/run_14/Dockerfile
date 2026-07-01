FROM golang:1.24

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Allow Go to automatically download newer toolchains if needed
ENV GOTOOLCHAIN=auto

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    redis-server \
    && rm -rf /var/lib/apt/lists/*

# Go is already installed in the golang:1.24 base image
# Verify Go installation
RUN go version

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh && \
    dos2unix /workspace/run.sh || sed -i 's/\r$//' /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]