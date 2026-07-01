FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles \
    DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    CI=true \
    GITHUB_ACTIONS=true \
    CARGO_INCREMENTAL=0 \
    CARGO_NET_RETRY=10 \
    CARGO_TERM_COLOR=always \
    RUSTUP_MAX_RETRIES=10 \
    PACKAGE_NAME=ruff \
    PYTHON_VERSION=3.14 \
    NEXTEST_PROFILE=ci \
    MDTEST_EXTERNAL=1 \
    CARGO_PROFILE_DEV_DEBUG=line-tables-only

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    pkg-config \
    libssl-dev \
    ca-certificates \
    tzdata \
    mold \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m testuser

# Switch to non-root user
USER testuser

# Install Rust via rustup as non-root user
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable && \
    . $HOME/.cargo/env && \
    rustup component add rustfmt clippy

# Set up Rust environment for the user
ENV PATH="/home/testuser/.cargo/bin:${PATH}"

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY --chown=testuser:testuser . .

# Configure git to trust the workspace directory
RUN git config --global --add safe.directory '*'

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]