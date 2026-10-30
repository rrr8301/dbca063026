FROM ubuntu:22.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install build tools, sanitizers, and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    cmake \
    ninja-build \
    build-essential \
    g++ \
    gcc \
    make \
    clang \
    llvm \
    llvm-dev \
    llvm-14 \
    python3 \
    python3-dev \
    python3-pip \
    r-base \
    r-base-dev \
    openjdk-11-jdk \
    curl \
    wget \
    pkg-config \
    libssl-dev \
    zlib1g-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create symlink for llvm-symbolizer
RUN ln -sf /usr/bin/llvm-symbolizer-14 /usr/bin/llvm-symbolizer || \
    ln -sf /usr/lib/llvm-14/bin/llvm-symbolizer /usr/bin/llvm-symbolizer || true

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Make run.sh executable and set as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]