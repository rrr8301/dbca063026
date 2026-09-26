FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RUSTFLAGS=--deny\ warnings
ENV AWS_LC_SYS_NO_JITTER_ENTROPY=1
ENV PATH="/root/.cargo/bin:$PATH"

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    pkg-config \
    cmake \
    nasm \
    perl \
    golang-go \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
