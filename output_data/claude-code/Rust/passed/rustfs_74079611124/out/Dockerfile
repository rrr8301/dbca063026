FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_TERM_COLOR=always
ENV RUST_BACKTRACE=1
ENV CARGO_BUILD_JOBS=2

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    musl-tools \
    protobuf-compiler \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable \
    && . $HOME/.cargo/env \
    && rustup component add rustfmt clippy rust-src rust-analyzer

ENV PATH="/root/.cargo/bin:${PATH}"

RUN cargo install cargo-nextest --locked

WORKDIR /tmp
RUN curl -L -o flatc.zip https://github.com/google/flatbuffers/releases/download/v25.9.23/Linux.flatc.binary.zip && \
    unzip flatc.zip && \
    mv flatc /usr/local/bin/ && \
    chmod +x /usr/local/bin/flatc && \
    rm flatc.zip

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
