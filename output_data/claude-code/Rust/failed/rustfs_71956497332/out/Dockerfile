FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    pkg-config \
    libssl-dev \
    musl-tools \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install protoc
RUN curl -fsSL https://github.com/protocolbuffers/protobuf/releases/download/v33.1/protoc-33.1-linux-x86_64.zip -o /tmp/protoc.zip && \
    unzip /tmp/protoc.zip -d /usr/local && \
    rm /tmp/protoc.zip

# Install flatc
RUN apt-get update && apt-get install -y flatbuffers-compiler && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable && \
    . $HOME/.cargo/env && \
    rustup component add rustfmt clippy && \
    cargo install --locked cargo-nextest

ENV PATH="/root/.cargo/bin:$PATH"

# Set environment variables
ENV CARGO_TERM_COLOR=always
ENV RUST_BACKTRACE=1
ENV CARGO_BUILD_JOBS=2

WORKDIR /app

COPY repo/ /app/

RUN cargo build --bins 2>&1 | head -20 || true

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
