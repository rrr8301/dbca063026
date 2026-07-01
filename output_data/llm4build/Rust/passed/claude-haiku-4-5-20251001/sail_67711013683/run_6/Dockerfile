FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    pkg-config \
    libssl-dev \
    python3 \
    python3-dev \
    python3-pip \
    sudo \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Rust via rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile default
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Rust stable toolchain with llvm-tools-preview
RUN rustup toolchain install stable --profile default --component llvm-tools-preview

# Install protoc with proper includes
RUN curl -L https://github.com/protocolbuffers/protobuf/releases/download/v27.0/protoc-27.0-linux-x86_64.zip -o /tmp/protoc.zip && \
    unzip -o /tmp/protoc.zip -d /usr/local && \
    rm /tmp/protoc.zip && \
    protoc --version

# Install grcov for coverage
RUN cargo install grcov

# Install cargo-tarpaulin for coverage
RUN cargo install cargo-tarpaulin

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Set Cargo environment variables for CI builds
ENV CARGO_INCREMENTAL=0
ENV CARGO_PROFILE_DEV_DEBUG=0

# Run tests
CMD ["/bin/bash", "-c", "set -e && mkdir -p coverage && echo 'Running cargo test --all...' && cargo test --all && echo 'Generating Rust unit coverage report...' && cargo tarpaulin --out Xml --output-dir coverage && echo 'Running cargo test --all -- --ignored...' && cargo test --all -- --ignored && echo 'Generating Rust slow coverage report...' && cargo tarpaulin --out Xml --output-dir coverage && echo 'All tests completed successfully!'"]