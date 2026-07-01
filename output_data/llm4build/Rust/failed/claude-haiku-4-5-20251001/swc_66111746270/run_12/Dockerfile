FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    pkg-config \
    libssl-dev \
    cmake \
    ninja-build \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js v20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Rust via rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
    -y \
    --default-toolchain stable \
    --profile minimal && \
    . $HOME/.cargo/env && \
    rustup target add wasm32-wasip1 && \
    rustup component add rustfmt

# Set Rust environment variables
ENV PATH="/root/.cargo/bin:${PATH}"

# Enable corepack for yarn
RUN corepack enable

# Set environment variables from the workflow
ENV CI=1
ENV CARGO_INCREMENTAL=0
ENV CARGO_TERM_COLOR=always
ENV DIFF=0
ENV RUST_LOG=off
ENV SKIP_YARN_COREPACK_CHECK=1

# Create working directory
WORKDIR /workspace

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Copy source code (will be provided at build time or runtime)
# This allows flexibility for both local and CI/CD usage
ONBUILD COPY . /workspace/

# Default command (can be overridden)
CMD ["/workspace/run.sh"]