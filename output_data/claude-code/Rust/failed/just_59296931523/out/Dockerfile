FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RUSTFLAGS=--deny\ warnings
ENV USER=root
ENV XDG_RUNTIME_DIR=/tmp/xdg-runtime
ENV HOME=/root

RUN mkdir -p /tmp/xdg-runtime && chmod 0700 /tmp/xdg-runtime

RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    git \
    python3 \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /app

COPY repo/ /app/

RUN cargo build

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
