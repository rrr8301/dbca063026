FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    pkg-config \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for Rust build
ENV CARGO_INCREMENTAL=0 \
    CARGO_NET_RETRY=10 \
    CI=1 \
    RUST_BACKTRACE=short \
    RUSTUP_MAX_RETRIES=10 \
    RUSTFLAGS="-D warnings -W unreachable-pub --cfg no_salsa_async_drops" \
    CC=deny_c \
    PATH="/root/.cargo/bin:$PATH"

# Install Rust toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable && \
    rustup update --no-self-update stable && \
    rustup default stable && \
    rustup component add --toolchain stable rust-src rustfmt && \
    rustup toolchain install nightly --profile minimal --component rustfmt

# Create working directory
WORKDIR /workspace

# Copy repository (assumes repo is available in build context)
COPY . .

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]