FROM ubuntu:24.04

# Set timezone to avoid tzdata prompts
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    git \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    clang \
    clang-format \
    lld \
    gcc \
    g++ \
    make \
    doxygen \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Configure sudo to work without password for root
RUN echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install Python build tools
# Use --break-system-packages for Ubuntu 24.04 which enforces PEP 668
RUN pip3 install --no-cache-dir --break-system-packages meson pytest

# Set environment variable to allow pip to install packages system-wide
ENV PIP_BREAK_SYSTEM_PACKAGES=1

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Make all scripts executable
RUN chmod +x /workspace/run.sh && \
    chmod +x /workspace/.github/workflows/install-ubuntu-dependencies.sh && \
    chmod +x /workspace/test/ci-build.sh

ENTRYPOINT ["/workspace/run.sh"]