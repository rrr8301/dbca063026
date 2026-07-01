FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RUSTFLAGS=-Dwarnings
ENV RUST_VERSION=1.94.0
ENV RUST_BACKTRACE=1

RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain $RUST_VERSION --profile minimal
ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup override set $RUST_VERSION

WORKDIR /app
COPY repo/ /app/

RUN cargo fetch --locked

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
