FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    wget \
    git \
    gdb \
    pkg-config \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.91.1 \
    && . $HOME/.cargo/env

ENV PATH="/root/.cargo/bin:${PATH}"

RUN cargo install cargo-nextest --version 0.9.98

WORKDIR /app

COPY repo/ /app/

RUN cargo build --workspace --all-features 2>&1 | tail -20 || true

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
