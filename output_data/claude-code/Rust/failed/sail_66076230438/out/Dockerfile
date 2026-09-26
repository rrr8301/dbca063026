FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    pkg-config \
    libssl-dev \
    protobuf-compiler \
    python3.11 \
    python3-pip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Rust components
RUN rustup toolchain install stable --profile default --component llvm-tools-preview

# Install build tools more efficiently
RUN cargo install grcov --locked

# Install cargo-nextest using pre-built binary
RUN curl -LsSf https://get.nexte.st/latest/linux | tar zxf - -C ${CARGO_HOME:-~/.cargo}/bin

# Set working directory
WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Prepare coverage directories
RUN mkdir -p target/llvm-profiles/rust-unit && \
    mkdir -p target/llvm-profiles/rust-slow

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
