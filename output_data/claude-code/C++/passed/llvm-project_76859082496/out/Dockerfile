FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    git \
    python3 \
    python3-dev \
    python3-pip \
    python3-psutil \
    clang \
    lld \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install sccache
RUN curl -L https://github.com/mozilla/sccache/releases/download/v0.7.7/sccache-v0.7.7-x86_64-unknown-linux-musl.tar.gz \
    -o /tmp/sccache.tar.gz && \
    mkdir -p /tmp/sccache_extract && \
    tar xzf /tmp/sccache.tar.gz -C /tmp/sccache_extract && \
    mv /tmp/sccache_extract/sccache-v0.7.7-x86_64-unknown-linux-musl/sccache /usr/local/bin/ && \
    chmod +x /usr/local/bin/sccache && \
    rm -rf /tmp/sccache.tar.gz /tmp/sccache_extract


WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
