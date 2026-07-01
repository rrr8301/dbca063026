FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    gdb \
    pkg-config \
    libssl-dev \
    python3 \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust using rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
    -y \
    --default-toolchain 1.91.1 \
    --profile minimal \
    --component rustfmt,clippy,rust-analyzer

ENV PATH="/root/.cargo/bin:${PATH}"

# Install nextest
RUN cargo install --version 0.9.98 cargo-nextest

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Run the test script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
