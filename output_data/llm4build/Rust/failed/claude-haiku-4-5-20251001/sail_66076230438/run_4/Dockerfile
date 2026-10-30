FROM rust:latest

# Install system dependencies
RUN apt-get update && apt-get install -y \
    protobuf-compiler \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Set Cargo environment variables for CI builds
ENV CARGO_INCREMENTAL=0
ENV CARGO_PROFILE_DEV_DEBUG=0

# Install Rust components and tools
RUN rustup component add llvm-tools-preview && \
    cargo install grcov && \
    cargo install --locked cargo-nextest

WORKDIR /workspace

# Copy project files
COPY . .

# Run tests
CMD ["cargo", "test", "--all"]