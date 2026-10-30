FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_INCREMENTAL=0
ENV CARGO_NET_RETRY=10
ENV CARGO_TERM_COLOR=always
ENV RUSTUP_MAX_RETRIES=10
ENV PYTHON_VERSION="3.14"
ENV NEXTEST_PROFILE=ci
ENV MDTEST_EXTERNAL="1"
ENV CARGO_PROFILE_DEV_DEBUG=line-tables-only

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    pkg-config \
    python3 \
    python3-dev \
    python3-venv \
    mold \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup show

RUN cargo install cargo-nextest --version 0.9.101 --locked
RUN cargo install cargo-insta

RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
