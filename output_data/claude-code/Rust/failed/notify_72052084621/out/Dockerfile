FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_TERM_COLOR=always
ENV RUST_BACKTRACE=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Rust toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile=minimal && \
    . $HOME/.cargo/env && \
    rustup override set 1.88 && \
    rustup update 1.88

ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
