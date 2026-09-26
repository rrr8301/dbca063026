FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    curl \
    wget \
    make \
    python3-dev \
    python3-setuptools \
    python3-pip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.24 (latest stable)
RUN curl -fsSL https://go.dev/dl/go1.24.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

# Set Go environment variables
ENV PATH="/usr/local/go/bin:${PATH}" \
    GOARCH="amd64" \
    CGO_ENABLED="1"

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Install Python packages (with --break-system-packages for Ubuntu 24.04 PEP 668 compliance)
# Use --ignore-installed to avoid conflicts with system-installed packages
RUN pip install --no-cache-dir --break-system-packages --ignore-installed -U pytest setuptools wheel

# Copy and set run script as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]