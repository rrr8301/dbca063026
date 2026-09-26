FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_TERM_COLOR=always
ENV RUST_BACKTRACE=full
ENV CI=true
ENV CARGO_PROFILE_DEV_DEBUG=false
ENV CARGO_PROFILE_TEST_DEBUG=false
ENV CARGO_PROFILE_DEV_OPT_LEVEL=1
ENV CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false
ENV CARGO_TARGET_DIR=target
ENV ROCKSDB_DISABLE_JEMALLOC=1

WORKDIR /app

RUN apt-get update && \
    apt-get install -y \
      curl \
      clang llvm libclang-dev \
      cmake make ninja-build pkg-config \
      protobuf-compiler \
      libsnappy-dev liblz4-dev libzstd-dev zlib1g-dev \
      libxcb1-dev libxkbcommon-dev libxkbcommon-x11-dev && \
    rm -rf /var/lib/apt/lists/*

ENV CC=clang
ENV CXX=clang++

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly && \
    export PATH="/root/.cargo/bin:$PATH" && \
    rustup component add rustfmt clippy

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
