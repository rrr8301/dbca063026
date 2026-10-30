FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_TERM_COLOR=always
ENV RUST_BACKTRACE=full
ENV CI=true
ENV CARGO_PROFILE_DEV_DEBUG="false"
ENV CARGO_PROFILE_TEST_DEBUG="false"
ENV CARGO_PROFILE_DEV_OPT_LEVEL=1
ENV CARGO_PROFILE_DEV_OVERFLOW_CHECKS="false"
ENV CARGO_TARGET_DIR=target
ENV ROCKSDB_DISABLE_JEMALLOC=1

RUN apt-get update && apt-get install -y \
    curl \
    git \
    clang \
    llvm \
    libclang-dev \
    cmake \
    make \
    ninja-build \
    pkg-config \
    libsnappy-dev \
    liblz4-dev \
    libzstd-dev \
    zlib1g-dev \
    libxcb1-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    && rm -rf /var/lib/apt/lists/*

ENV CC=clang
ENV CXX=clang++
RUN LIBCLANG_DIR=$(ls -d /usr/lib/llvm-*/lib | head -n 1) && \
    echo "export LIBCLANG_PATH=$LIBCLANG_DIR" >> /etc/profile.d/libclang.sh

# Install newer protobuf binary
RUN cd /tmp && \
    curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v25.0/protoc-25.0-linux-x86_64.zip && \
    apt-get update && apt-get install -y unzip && \
    unzip protoc-25.0-linux-x86_64.zip -d /usr/local && \
    rm -rf /tmp/protoc-25.0-linux-x86_64.zip && \
    rm -rf /var/lib/apt/lists/*

# Install Rust nightly
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly && \
    . $HOME/.cargo/env && \
    rustup component add rustfmt clippy

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
