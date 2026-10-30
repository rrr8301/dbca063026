FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RUST_MIN_STACK=8388608
ENV CARGO_INCREMENTAL=0

RUN apt-get update -y && apt-get install -y \
    build-essential \
    cmake \
    curl \
    git \
    libdbus-1-dev \
    gnome-keyring \
    libxcb1-dev \
    ca-certificates \
    clang \
    llvm-dev \
    libclang-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.91.1 \
    && . $HOME/.cargo/env

ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /app
COPY repo/ /app/

RUN cargo fetch

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
