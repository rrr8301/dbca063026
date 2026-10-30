FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    git \
    pkg-config \
    libasound2-dev \
    mesa-vulkan-drivers \
    libudev-dev \
    libfontconfig-dev \
    libclang-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust stable
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

# Set environment variables
ENV PATH="/root/.cargo/bin:${PATH}" \
    CARGO_NET_GIT_FETCH_WITH_CLI='true' \
    CARGO_INCREMENTAL='1' \
    XDG_RUNTIME_DIR='' \
    FEATURES='lzma,jpegxr,imgtests' \
    TEST_OPTS='--workspace --locked --no-fail-fast -j 4' \
    RUFFLE_TEST_OPTS='--compile-mode=compile-and-verify'

WORKDIR /app

# Copy repository
COPY repo/ /app/

# Install cargo-nextest
RUN cargo install cargo-nextest --locked

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
