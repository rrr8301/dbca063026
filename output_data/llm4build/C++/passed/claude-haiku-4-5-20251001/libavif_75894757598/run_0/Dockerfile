FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=America/Los_Angeles \
    DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    CI=true \
    GITHUB_ACTIONS=true

# Install system dependencies
RUN apt-get update -y && apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    gcc-14 \
    g++-14 \
    git \
    make \
    nasm \
    pkg-config \
    libtool \
    autoconf \
    automake \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    wget \
    libpng-dev \
    libjpeg-turbo8-dev \
    zlib1g-dev \
    libyuv-dev \
    libxml2-dev \
    imagemagick \
    meson \
    && rm -rf /var/lib/apt/lists/*

# Install Rust for rav1e
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable && \
    . $HOME/.cargo/env && \
    cargo install cargo-c --features=vendored-openssl

# Create non-root user
RUN useradd -m testuser

# Set working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git to allow workspace directory
RUN git config --global --add safe.directory '*'

# Change ownership to testuser
RUN chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

# Set up environment for Rust
ENV PATH="/home/testuser/.cargo/bin:${PATH}"

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]