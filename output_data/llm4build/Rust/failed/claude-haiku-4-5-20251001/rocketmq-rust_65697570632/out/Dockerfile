FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    clang llvm libclang-dev \
    cmake make ninja-build pkg-config \
    protobuf-compiler \
    libsnappy-dev liblz4-dev libzstd-dev zlib1g-dev \
    libxcb1-dev libxkbcommon-dev libxkbcommon-x11-dev \
    git curl wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Rust nightly
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly && \
    . $HOME/.cargo/env && \
    rustup component add rustfmt clippy

ENV PATH="/root/.cargo/bin:${PATH}"

# Set Rust environment variables
ENV CARGO_TERM_COLOR=always
ENV RUST_BACKTRACE=full
ENV CI=true
ENV CARGO_PROFILE_DEV_DEBUG=false
ENV CARGO_PROFILE_TEST_DEBUG=false
ENV CARGO_PROFILE_DEV_OPT_LEVEL=1
ENV CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false
ENV CARGO_TARGET_DIR=target
ENV ROCKSDB_DISABLE_JEMALLOC=1

# Determine LIBCLANG_PATH and set compiler environment variables
RUN LIBCLANG_DIR=$(ls -d /usr/lib/llvm-*/lib | head -n 1) && \
    echo "export LIBCLANG_PATH=$LIBCLANG_DIR" >> /root/.bashrc && \
    echo "export CC=clang" >> /root/.bashrc && \
    echo "export CXX=clang++" >> /root/.bashrc

ENV CC=clang
ENV CXX=clang++
ENV LIBCLANG_PATH=/usr/lib/llvm-18/lib

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and set run.sh as entrypoint
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]