FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RUSTFLAGS="-C debuginfo=0"
ENV RUST_BACKTRACE=1

RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    git \
    python3 \
    python3-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && . $HOME/.cargo/env \
    && rustup toolchain install nightly-2026-04-01 \
    && rustup default nightly-2026-04-01

ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /app
COPY repo/ /app/

RUN cargo test --lib --tests --bins --all-features --no-run \
    -p polars-arrow \
    -p polars-compute \
    -p polars-core \
    -p polars-io \
    -p polars-lazy \
    -p polars-ops \
    -p polars-parquet \
    -p polars-plan \
    -p polars-row \
    -p polars-sql \
    -p polars-time \
    -p polars-utils

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
