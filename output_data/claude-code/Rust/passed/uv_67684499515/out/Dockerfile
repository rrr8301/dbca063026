FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_INCREMENTAL=0
ENV CARGO_NET_RETRY=10
ENV CARGO_TERM_COLOR=always
ENV PYTHON_VERSION=3.12
ENV RUSTUP_MAX_RETRIES=10
ENV PATH="/root/.local/bin:$PATH"

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    wget \
    git \
    ca-certificates \
    pkg-config \
    libssl-dev \
    gnome-keyring \
    btrfs-progs \
    util-linux \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
ENV PATH="/root/.cargo/bin:$PATH"

WORKDIR /app

COPY repo/ /app/

RUN rustup show

RUN mkdir -p /root/.local/bin /tmp/uv_download && \
    curl -fsSL https://github.com/astral-sh/uv/releases/download/0.10.10/uv-x86_64-unknown-linux-gnu.tar.gz \
    | tar xz -C /tmp/uv_download && \
    cp /tmp/uv_download/uv-x86_64-unknown-linux-gnu/uv /root/.local/bin/uv && \
    chmod +x /root/.local/bin/uv && \
    rm -rf /tmp/uv_download

RUN ./scripts/install-mold.sh || true

RUN uv python install

RUN cargo install cargo-nextest

RUN mkdir -p /btrfs /tmpfs /minix

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
