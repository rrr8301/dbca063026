FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies including Go
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    make \
    python3 \
    python3-pip \
    build-essential \
    pkg-config \
    golang-go \
    && rm -rf /var/lib/apt/lists/*

# Install Rust nightly 1.91
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile default --default-toolchain 1.91 && \
    . $HOME/.cargo/env && \
    rustup component add clippy rustfmt

ENV PATH="${HOME}/.cargo/bin:${PATH}" \
    HOME=/root

WORKDIR /app
COPY repo/ /app/

# Copy and prepare run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
