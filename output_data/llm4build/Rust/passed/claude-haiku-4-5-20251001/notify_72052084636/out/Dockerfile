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

# Create non-root user first
RUN useradd -m testuser

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git to trust the workspace directory
RUN git config --global --add safe.directory '*'

# Transfer ownership to testuser
RUN chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

# Install Rust via rustup for testuser
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable && \
    . $HOME/.cargo/env

ENV PATH="/home/testuser/.cargo/bin:${PATH}"

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]