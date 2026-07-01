FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    liblzma-dev \
    libssl-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
ENV PATH="/root/.cargo/bin:${PATH}"

# Install just task runner
RUN cargo install just

# Install nextest with --locked flag
RUN cargo install --locked cargo-nextest

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Set entrypoint
COPY /run.sh /run.sh
RUN chmod +x /run.sh
ENTRYPOINT ["/run.sh"]