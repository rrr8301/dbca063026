FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NUSHELL_CARGO_PROFILE=ci
ENV NU_LOG_LEVEL=DEBUG
ENV CLIPPY_OPTIONS="-D warnings -D clippy::unwrap_used -D clippy::unchecked_time_subtraction"

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    pkg-config \
    libssl-dev \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup install 1.92.0 && rustup default 1.92.0

WORKDIR /app

COPY repo/ /app/

RUN cargo fetch

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
