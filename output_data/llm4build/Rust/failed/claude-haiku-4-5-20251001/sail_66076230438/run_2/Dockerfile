FROM rust:latest

# Install system dependencies
RUN apt-get update && apt-get install -y \
    protobuf-compiler \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Copy the entire project
COPY . .

# Set Cargo environment variables for CI builds
ENV CARGO_INCREMENTAL=0
ENV CARGO_PROFILE_DEV_DEBUG=0

# Install Rust toolchain and tools
RUN rustup default stable && \
    rustup component add llvm-tools-preview && \
    cargo install grcov cargo-nextest

# Create coverage directories
RUN mkdir -p coverage

# Run all tests
CMD ["cargo", "test", "--all"]