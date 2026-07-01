FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /app
COPY repo/ /app/

RUN rustup update --no-self-update stable && \
    rustup default stable && \
    rustup component add --toolchain stable rust-src rustfmt && \
    rustup toolchain install nightly --profile minimal --component rustfmt

RUN cargo install taiki-e-install-action-nextest@latest 2>/dev/null || \
    cargo install cargo-nextest --locked

RUN cargo install cargo-machete

ENV CARGO_INCREMENTAL=0
ENV CARGO_NET_RETRY=10
ENV CI=1
ENV RUST_BACKTRACE=short
ENV RUSTUP_MAX_RETRIES=10
ENV RUSTFLAGS="-D warnings -W unreachable-pub --cfg no_salsa_async_drops"
ENV CC=deny_c

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
