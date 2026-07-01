FROM ubuntu:22.04

# Set timezone to Pacific Time non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    cmake \
    ninja-build \
    ccache \
    build-essential \
    clang \
    lld \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    python3-pip \
    curl \
    wget \
    ca-certificates \
    pkg-config \
    libssl-dev \
    libffi-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Upgrade pip, setuptools, and wheel
RUN python -m pip install --upgrade pip setuptools wheel

# Install nanobind early as it's required by MLIR CMake configuration
RUN python -m pip install nanobind

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Initialize git and submodules
RUN cd /workspace && \
    git init && \
    git config user.email "docker@build" && \
    git config user.name "Docker Build" && \
    git add -A && \
    git commit -m "Initial commit" && \
    git submodule update --init --recursive || true

# Fix script permissions before copying
RUN find /workspace/build_tools -type f -name "*.sh" -exec chmod +x {} \;

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set compiler flags to handle unknown warning options
ENV CXXFLAGS="-Wno-unknown-warning-option"
ENV CFLAGS="-Wno-unknown-warning-option"

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]