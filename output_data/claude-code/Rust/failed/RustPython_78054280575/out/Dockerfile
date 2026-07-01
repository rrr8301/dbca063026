FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RUST_BACKTRACE=full
ENV CI=true
ENV CARGO_INCREMENTAL=0
ENV CARGO_PROFILE_TEST_DEBUG=0
ENV CARGO_PROFILE_DEV_DEBUG=0
ENV CARGO_PROFILE_RELEASE_DEBUG=0
ENV CARGO_TERM_COLOR=always

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    libssl-dev \
    pkg-config \
    python3 \
    python3-dev \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
