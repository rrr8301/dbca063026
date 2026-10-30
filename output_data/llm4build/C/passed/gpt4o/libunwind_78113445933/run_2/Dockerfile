FROM ubuntu:26.04

# Set timezone and locale
ENV TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install tzdata first to avoid interactive prompts
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install git and build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    autoconf \
    automake \
    libtool \
    make \
    g++-14-arm-linux-gnueabi \
    gcc-14-arm-linux-gnueabi \
    qemu-user \
    qemu-user-static \
    abigail-tools \
    curl \
    wget \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git to allow ownership mismatch
RUN git config --global --add safe.directory '*'

# Run as root (required for privileged operations: core dumps, ulimit, /proc access)
USER root

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]