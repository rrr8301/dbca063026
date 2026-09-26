FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    wget \
    python3.11 \
    python3.11-dev \
    python3-pip \
    pkg-config \
    libssl-dev \
    llvm \
    protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable \
    && . $HOME/.cargo/env \
    && rustup toolchain install stable --profile default --component llvm-tools-preview \
    && cargo install grcov \
    && cargo install --locked cargo-nextest \
    && rustup update

RUN . $HOME/.cargo/env && cargo --version && rustc --version

ENV PATH="/root/.cargo/bin:${PATH}"
ENV CARGO_INCREMENTAL=0
ENV CARGO_PROFILE_DEV_DEBUG=0

RUN mkdir -p target/llvm-profiles/rust-unit target/llvm-profiles/rust-slow

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
