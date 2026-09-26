FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    CI=true \
    GITHUB_ACTIONS=true

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    pkg-config \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git to trust the workspace directory
RUN git config --global --add safe.directory '*'

# Install Rust toolchain (nightly) as root
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly && \
    . $HOME/.cargo/env && \
    rustup component add rustfmt clippy

# Ensure cargo is in PATH for subsequent commands
ENV PATH="/root/.cargo/bin:${PATH}"

# Create non-root user and set up Rust for them
RUN useradd -m testuser && \
    chown -R testuser:testuser /workspace && \
    chown -R testuser:testuser /root/.cargo && \
    chown -R testuser:testuser /root/.rustup

# Switch to non-root user
USER testuser

# Set Rust environment for testuser
ENV PATH="/root/.cargo/bin:${PATH}" \
    CARGO_HOME="/root/.cargo" \
    RUSTUP_HOME="/root/.rustup"

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]