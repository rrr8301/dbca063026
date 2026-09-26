FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    libclang-dev \
    clang \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.93.1

ENV PATH="/root/.cargo/bin:${PATH}"

RUN cargo install --locked --git https://git.rust-bitcoin.org/rust-bitcoin/rust-bitcoin-maintainer-tools --rev 9de0de1f36f65a2cb9c617358d88aecd319282d9

WORKDIR /app

COPY repo/ /app/

RUN cargo rbmt toolchains

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
