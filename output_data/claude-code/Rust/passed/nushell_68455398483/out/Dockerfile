FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NUSHELL_CARGO_PROFILE=ci
ENV NU_LOG_LEVEL=DEBUG
ENV PATH="/root/.cargo/bin:$PATH"

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

WORKDIR /app

COPY repo/ /app/

RUN rustup update beta

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
