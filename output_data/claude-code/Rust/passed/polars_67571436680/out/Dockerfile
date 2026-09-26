FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RUSTFLAGS="-C debuginfo=0"
ENV RUST_BACKTRACE=1

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    python3 \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /app
COPY repo /app

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
