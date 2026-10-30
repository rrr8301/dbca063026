FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable && \
    . $HOME/.cargo/env && \
    rustup component add --toolchain stable rust-src rustfmt && \
    rustup toolchain install nightly --profile minimal --component rustfmt

ENV PATH="/root/.cargo/bin:${PATH}"
ENV RUSTUP_HOME="/root/.rustup"
ENV CARGO_HOME="/root/.cargo"

# Set environment variables for the build
ENV CARGO_INCREMENTAL=0
ENV CARGO_NET_RETRY=10
ENV CI=1
ENV RUST_BACKTRACE=short
ENV RUSTUP_MAX_RETRIES=10
ENV RUSTFLAGS="-D warnings -W unreachable-pub --cfg no_salsa_async_drops"
ENV CC=deny_c

WORKDIR /app
COPY repo/ /app/

# Install nextest
RUN curl -LsSf https://get.nexte.st/latest/linux | tar zxf - -C ${CARGO_HOME}/bin

# Install cargo-machete
RUN cargo install cargo-machete

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
