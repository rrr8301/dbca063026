FROM ubuntu:24.04

# Set environment variables
ENV TZ=UTC
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    pkg-config \
    libssl-dev \
    clang \
    cmake \
    mold \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install Rust and Cargo tools
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    /bin/bash -c "source $HOME/.cargo/env && \
    rustup toolchain install 1.93.0 && \
    rustup component add clippy --toolchain 1.93.0 && \
    rustup target add wasm32-unknown-unknown && \
    cargo install cargo-make --version 0.36.4 && \
    cargo install cargo-nextest --version 0.9.100"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace

# Configure git
RUN git config --global --add safe.directory '*'

# Copy run.sh and set permissions
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Create non-root user
RUN useradd -m testuser && chown -R testuser /workspace
USER testuser

# Set run.sh as entrypoint
ENTRYPOINT ["/workspace/run.sh"]