FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RUST_BACKTRACE=full
ENV CI=true
ENV CARGO_INCREMENTAL=0
ENV CARGO_PROFILE_TEST_DEBUG=0
ENV CARGO_PROFILE_DEV_DEBUG=0
ENV CARGO_PROFILE_RELEASE_DEBUG=0
ENV CARGO_TERM_COLOR=always
ENV CARGO_ARGS="--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env"
ENV WORKSPACE_EXCLUDES="--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher"
ENV INSTA_WORKSPACE_ROOT="/app"

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    libssl-dev \
    libsqlite3-dev \
    python3 \
    python3-pip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /app
COPY repo/ /app/

RUN rustc --version && cargo --version

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
