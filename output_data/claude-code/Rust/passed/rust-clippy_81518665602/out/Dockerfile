FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV RUST_BACKTRACE=1
ENV CARGO_TARGET_DIR=/app/target
ENV NO_FMT_TEST=1
ENV CARGO_INCREMENTAL=0
ENV RUSTFLAGS=-D\ warnings

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Set working directory
WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Install the specific nightly toolchain
RUN rustup toolchain install nightly-2026-06-11 && \
    rustup default nightly-2026-06-11 && \
    rustup component add cargo llvm-tools rust-src rust-std rustc rustc-dev rustfmt

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
