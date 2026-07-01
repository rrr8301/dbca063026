FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RUST_BACKTRACE=1
ENV CARGO_TARGET_DIR=/app/target
ENV NO_FMT_TEST=1
ENV CARGO_INCREMENTAL=0
ENV RUSTFLAGS="-D warnings"

RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

ENV PATH=/root/.cargo/bin:$PATH

# Install the specific Rust nightly
RUN rustup toolchain install nightly-2026-06-11 && \
    rustup default nightly-2026-06-11 && \
    rustup component add cargo llvm-tools rust-src rust-std rustc rustc-dev rustfmt

WORKDIR /app
COPY repo/ /app/

RUN cargo build --tests --features internal 2>&1

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
