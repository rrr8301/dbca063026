FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    clang \
    protobuf-compiler \
    libprotobuf-dev \
    curl \
    wget \
    cmake \
    pkg-config \
    mold \
    ca-certificates \
    python3 \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Verify mold installation
RUN which mold && mold --version

# Verify protoc installation
RUN protoc --version

# Install Rust stable toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
ENV PATH="/root/.cargo/bin:${PATH}"

# Install cargo-nextest
RUN cargo install cargo-nextest --locked

# Set working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Set environment variable for Cargo
ENV CARGO_TERM_COLOR=always

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]