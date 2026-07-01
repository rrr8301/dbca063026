FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RUST_VERSION=1.93.0
ENV REDIS_VERSION=8.6.0
ENV RUSTFLAGS=-D\ warnings
ENV CARGO_TERM_COLOR=always

RUN apt-get update && apt-get install -y \
    build-essential \
    tcl \
    curl \
    ca-certificates \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain ${RUST_VERSION} \
    && . $HOME/.cargo/env

ENV PATH="/root/.cargo/bin:${PATH}"

RUN cargo install cargo-nextest --version 0.9.100

RUN mkdir -p /tmp/redis-build && \
    curl -fsSL "https://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz" -o /tmp/redis.tar.gz && \
    tar -xzf /tmp/redis.tar.gz -C /tmp/redis-build --strip-components=1 && \
    cd /tmp/redis-build && \
    make -j$(nproc) && \
    make install && \
    redis-server --version && \
    rm -rf /tmp/redis-build /tmp/redis.tar.gz

WORKDIR /app
COPY repo/ /app/

RUN cargo fetch

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
