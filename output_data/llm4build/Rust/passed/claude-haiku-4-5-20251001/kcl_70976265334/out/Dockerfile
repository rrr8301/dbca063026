FROM ubuntu:24.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git wget curl make \
    python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.91
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Rust components
RUN rustup component add clippy rustfmt

# Install Go 1.24
RUN wget https://go.dev/dl/go1.24.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.24.linux-amd64.tar.gz && \
    rm go1.24.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# Create and activate virtual environment
RUN python3 -m venv /workspace/venv
ENV VIRTUAL_ENV="/workspace/venv"
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

# Install Python packages
RUN /workspace/venv/bin/python3 -m pip install pytest pytest-html pytest-xdist ruamel.yaml

WORKDIR /workspace