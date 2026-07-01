FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Configure apt with retry logic and use multiple mirrors for resilience
RUN apt-get update -qq --allow-insecure-repositories || \
    (echo "Primary mirror failed, retrying..."; sleep 5; apt-get update -qq) || \
    (echo "Retrying with different approach..."; apt-get update -qq -o Acquire::http::timeout=30) || true

# Install dependencies with retry logic
RUN apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    ninja-build \
    python3 \
    python3-venv \
    python3-pip \
    wget \
    curl \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install clang-23 from pre-built binaries with retry logic
RUN mkdir -p /opt && \
    cd /tmp && \
    (wget -q --timeout=60 --tries=3 https://github.com/llvm/llvm-project/releases/download/llvmorg-23.0.0/clang+llvm-23.0.0-x86_64-linux-gnu-ubuntu-22.04.tar.xz || \
     wget -q --timeout=60 --tries=3 https://github.com/llvm/llvm-project/releases/download/llvmorg-23.0.0/clang+llvm-23.0.0-x86_64-linux-gnu-ubuntu-22.04.tar.xz) && \
    tar -xf clang+llvm-23.0.0-x86_64-linux-gnu-ubuntu-22.04.tar.xz && \
    mv clang+llvm-23.0.0-x86_64-linux-gnu-ubuntu-22.04 /opt/clang-23 && \
    rm clang+llvm-23.0.0-x86_64-linux-gnu-ubuntu-22.04.tar.xz && \
    ln -s /opt/clang-23/bin/clang /usr/local/bin/clang-23 && \
    ln -s /opt/clang-23/bin/clang++ /usr/local/bin/clang++-23 && \
    ln -s /opt/clang-23/bin/lld /usr/local/bin/lld-23

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]