FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install build tools and dependencies
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install --no-upgrade --no-install-recommends -y \
    git \
    curl \
    wget \
    build-essential \
    clang-20 \
    libc++-20-dev \
    libc++abi-20-dev \
    libclang-rt-20-dev \
    lld-20 \
    llvm-20 \
    apt-transport-https \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Add Bazel repository and install Bazel
RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | apt-key add - && \
    echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install --no-upgrade --no-install-recommends -y bazel && \
    rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Copy entire repository (including c++ directory)
COPY . /workspace/

# Copy run.sh and make it executable
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]