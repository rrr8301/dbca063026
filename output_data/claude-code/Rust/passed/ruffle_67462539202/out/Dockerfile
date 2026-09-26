FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV FEATURES="lzma,jpegxr,imgtests"
ENV TEST_OPTS="--workspace --locked --no-fail-fast -j 4"
ENV CARGO_INCREMENTAL=1
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true
ENV XDG_RUNTIME_DIR=""
ENV PATH="/root/.cargo/bin:$PATH"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    ca-certificates \
    libasound2-dev \
    mesa-vulkan-drivers \
    libudev-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

# Install cargo-nextest
RUN cargo install --locked cargo-nextest

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
