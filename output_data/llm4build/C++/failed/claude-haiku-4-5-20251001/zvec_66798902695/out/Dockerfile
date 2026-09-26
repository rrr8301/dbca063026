FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    cmake \
    ninja-build \
    python3.10 \
    python3.10-dev \
    python3.10-venv \
    python3-pip \
    pkg-config \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.10 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git to trust the workspace directory
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && \
    chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]