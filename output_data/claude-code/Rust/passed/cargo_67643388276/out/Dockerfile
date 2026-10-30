FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_PROFILE_DEV_DEBUG=1
ENV CARGO_PROFILE_TEST_DEBUG=1
ENV CARGO_INCREMENTAL=0
ENV CARGO_PUBLIC_NETWORK_TESTS=1
ENV RUSTUP_WINDOWS_PATH_ADD_BIN=0
ENV CARGO_CONTAINER_TESTS=1

RUN apt update -y && apt install -y \
    curl \
    build-essential \
    lldb \
    gcc-multilib \
    libsecret-1-0 \
    libsecret-1-dev \
    libssl-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup update --no-self-update stable
RUN rustup target add i686-unknown-linux-gnu
RUN rustup target add wasm32-unknown-unknown
RUN rustup component add rustfmt || echo "rustfmt not available"

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
