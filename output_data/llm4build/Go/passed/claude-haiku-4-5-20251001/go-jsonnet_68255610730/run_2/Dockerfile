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

# Set Go environment variables
ENV GOARCH="amd64" \
    CGO_ENABLED="1"

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Install Python packages (with --break-system-packages for Ubuntu 24.04 PEP 668 compliance)
RUN pip install --no-cache-dir --break-system-packages -U wheel pytest setuptools

# Copy and set run script as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]