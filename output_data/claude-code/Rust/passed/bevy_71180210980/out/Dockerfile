FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    build-essential \
    pkg-config \
    ca-certificates \
    libasound2-dev \
    libudev-dev \
    libwayland-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

ENV PATH="/root/.cargo/bin:${PATH}"
ENV CARGO_TERM_COLOR=always
ENV CARGO_INCREMENTAL=0
ENV CARGO_PROFILE_TEST_DEBUG=0
ENV CARGO_PROFILE_DEV_DEBUG=0
ENV NIGHTLY_TOOLCHAIN=nightly
ENV RUSTFLAGS="-D warnings"
ENV RUST_BACKTRACE=1

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh

RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
