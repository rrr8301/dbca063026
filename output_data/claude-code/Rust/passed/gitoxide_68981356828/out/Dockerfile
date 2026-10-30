FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_TERM_COLOR=always
ENV CLICOLOR=1
ENV GIX_TEST_IGNORE_ARCHIVES=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    liblzma-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile default && \
    . $HOME/.cargo/env && \
    rustup component add rustfmt clippy

# Install just and nextest
RUN . $HOME/.cargo/env && cargo install just && cargo install --locked cargo-nextest

# Set up workspace
WORKDIR /app
COPY repo /app/

# Create the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
