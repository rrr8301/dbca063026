FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_TERM_COLOR=always
ENV MISE_TRUSTED_CONFIG_PATHS=/app
ENV MISE_EXPERIMENTAL=1
ENV MISE_LOCKFILE=1
ENV RUST_BACKTRACE=1
ENV RUSTC_WRAPPER=sccache
ENV SCCACHE_DIR=$HOME/.cache/sccache
ENV SCCACHE_CACHE_SIZE=20G

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
    ca-certificates \
    pkg-config \
    libssl-dev \
    libffi-dev \
    bash \
    bc \
    jq \
    coreutils \
    cmake \
    perl \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain=nightly
ENV PATH="/root/.cargo/bin:$PATH"

RUN curl -fsSL https://github.com/mozilla/sccache/releases/download/v0.8.1/sccache-v0.8.1-x86_64-unknown-linux-musl.tar.gz | tar xz -C /usr/local/bin --strip-components=1 \
    && chmod +x /usr/local/bin/sccache

RUN mkdir -p ~/.cache/sccache \
    && sccache --zero-stats

WORKDIR /app
COPY repo/ /app/

RUN cargo build --all-features
RUN echo "$PWD/target/debug" >> ~/.cargo/bin/PATH

RUN mise install

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
