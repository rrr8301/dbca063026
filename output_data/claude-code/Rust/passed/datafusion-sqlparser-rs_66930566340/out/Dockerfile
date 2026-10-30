FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and Rust
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

# Add cargo/rustup to PATH
ENV PATH="/root/.cargo/bin:${PATH}"

# Add necessary components
RUN rustup component add rustfmt clippy

WORKDIR /app

COPY repo/ /app/

# Install cargo-tarpaulin
RUN cargo install cargo-tarpaulin

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
