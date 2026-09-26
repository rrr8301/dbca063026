FROM ubuntu:22.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    cmake \
    ninja-build \
    python3 \
    python3-pip \
    build-essential \
    clang \
    lld \
    llvm \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install sccache for build caching
RUN pip3 install --no-cache-dir sccache

# Create LLVM symlink at expected location (if not already present)
RUN mkdir -p /opt/llvm/bin && \
    ln -sf /usr/bin/clang /opt/llvm/bin/clang && \
    ln -sf /usr/bin/clang++ /opt/llvm/bin/clang++

# Set working directory
WORKDIR /workspace

# Copy the repository
COPY . /workspace/

# Make run.sh executable and set as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]