FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV SCCACHE_GHA_ENABLED=on

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-venv \
    build-essential \
    cmake \
    git \
    curl \
    wget \
    pkg-config \
    ca-certificates \
    autoconf \
    automake \
    libtool \
    m4 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
