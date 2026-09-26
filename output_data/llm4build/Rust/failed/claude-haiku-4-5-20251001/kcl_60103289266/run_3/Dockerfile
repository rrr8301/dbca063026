FROM ubuntu:latest

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    make \
    build-essential \
    pkg-config \
    libssl-dev \
    python3 \
    python3-pip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.23 (latest stable, 1.24 not yet released)
RUN wget -q https://go.dev/dl/go1.23.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.23.linux-amd64.tar.gz && \
    rm go1.23.linux-amd64.tar.gz && \
    /usr/local/go/bin/go version
ENV PATH="/usr/local/go/bin:${PATH}"

# Install Rust 1.91 nightly with clippy and rustfmt
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
    -y --default-toolchain nightly-2024-12-19 --component clippy --component rustfmt && \
    . /root/.cargo/env && \
    rustc --version && \
    cargo --version
ENV PATH="/root/.cargo/bin:${PATH}"

# Create working directory
WORKDIR /workspace

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]