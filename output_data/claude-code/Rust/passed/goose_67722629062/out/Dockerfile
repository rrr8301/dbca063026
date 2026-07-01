FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RUST_MIN_STACK=8388608
ENV CARGO_INCREMENTAL=0

RUN apt update -y && \
    apt install -y \
        curl \
        build-essential \
        pkg-config \
        libssl-dev \
        libdbus-1-dev \
        gnome-keyring \
        libxcb1-dev \
        git \
        clang \
        libclang-dev \
        cmake && \
    rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.92.0 && \
    . "$HOME/.cargo/env"

ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh

RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
