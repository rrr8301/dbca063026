FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    build-essential \
    git \
    wget \
    pkg-config \
    opam \
    libzstd-dev \
    python3-pip \
    erlang \
    golang-go \
    ghc \
    cabal-install \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . $HOME/.cargo/env && \
    rustup toolchain install nightly-2026-01-18 && \
    rustup component add --toolchain nightly-2026-01-18 clippy llvm-tools-preview rust-src && \
    rustup default nightly-2026-01-18

RUN pip3 install uv && uv tool install conan==1.*

WORKDIR /app
COPY repo/ /app/

RUN chmod +x /app/test.py

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
