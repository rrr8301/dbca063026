FROM ubuntu:22.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    cmake \
    ninja-build \
    python3-dev \
    python3-pip \
    python3-venv \
    curl \
    wget \
    ca-certificates \
    libgomp1 \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Create wheelhouse directory if it doesn't exist
RUN mkdir -p /workspace/wheelhouse

# Install Python build and test dependencies
RUN python3 -m pip install --upgrade pip setuptools wheel && \
    python3 -m pip install pytest numpy scipy scikit-learn pandas matplotlib boto3

# Ensure test scripts and management scripts are executable
RUN chmod -R +x /workspace/ops/pipeline/*.sh 2>/dev/null || true && \
    chmod +x /workspace/ops/pipeline/manage-artifacts.py 2>/dev/null || true && \
    chmod +x /workspace/ops/pipeline/*.py 2>/dev/null || true

# Set default command (can be overridden)
CMD ["/bin/bash"]