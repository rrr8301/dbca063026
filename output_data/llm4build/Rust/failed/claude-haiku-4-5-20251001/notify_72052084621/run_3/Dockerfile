FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles \
    DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
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

# Install rustup and Rust as testuser
USER testuser
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain none && \
    . $HOME/.cargo/env && \
    rustup toolchain install 1.88

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY --chown=testuser:testuser . .

# Make run.sh executable
RUN chmod +x /workspace/run.sh

# Configure git safe directory
RUN git config --global --add safe.directory '*'

# Add Rust to PATH
ENV PATH="/home/testuser/.cargo/bin:${PATH}"

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]