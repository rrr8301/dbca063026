FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CI=1
ENV CARGO_INCREMENTAL=0
ENV CARGO_TERM_COLOR=always
ENV DIFF=0
ENV RUST_LOG=off

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
    -y \
    --default-toolchain nightly-2026-04-10 \
    --target wasm32-wasip1,wasm32-unknown-unknown

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g corepack

WORKDIR /app
COPY repo/ /app/

RUN corepack enable && \
    pnpm install --frozen-lockfile || \
    npm install -g jest@27 mocha || true

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
