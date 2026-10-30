FROM ghcr.io/diodeinc/kicad:9.0.7-trixie-full

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install cargo-nextest
RUN cargo install cargo-nextest

WORKDIR /workspace
COPY . .

# Run tests
CMD ["cargo", "nextest", "run", "--workspace", "--profile", "ci", "--locked"]