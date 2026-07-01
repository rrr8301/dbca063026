FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set timezone
RUN echo "UTC" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Install base dependencies with proper GPG setup before adding PPA
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    git \
    curl \
    wget \
    ca-certificates \
    build-essential \
    cmake \
    g++ \
    gcc \
    make \
    clang \
    lld \
    openjdk-11-jdk \
    software-properties-common \
    gnupg \
    dirmngr \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Add deadsnakes PPA with proper error handling
RUN apt-get update && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y --no-install-recommends \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.12 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Install Bazel binary directly (supports both x86_64 and ARM64)
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/* && \
    mkdir -p /usr/local/bin && \
    curl -fsSL https://github.com/bazelbuild/bazel/releases/download/7.0.0/bazel-7.0.0-linux-arm64 -o /usr/local/bin/bazel && \
    chmod +x /usr/local/bin/bazel

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git for safe directory access
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && \
    chown -R testuser:testuser /workspace

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Switch to non-root user
USER testuser

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]