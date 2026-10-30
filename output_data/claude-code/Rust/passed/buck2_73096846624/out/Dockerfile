FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    lsb-release \
    ca-certificates \
    build-essential \
    git \
    opam \
    libzstd-dev \
    python3-pip \
    erlang \
    wget \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly-2026-01-18
ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup component add clippy

RUN apt-get update && apt-get install -y \
    libncurses-dev \
    libgmp-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

ENV PATH="/root/.ghcup/bin:${PATH}"

RUN ghcup install ghc 9.10.1

RUN curl -L https://go.dev/dl/go1.22.0.linux-amd64.tar.gz | tar -xz -C /usr/local

ENV PATH="/usr/local/go/bin:${PATH}"

RUN pip install uv

RUN uv tool install 'conan==1.*'

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
