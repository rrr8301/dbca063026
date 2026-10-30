FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV GOMODCACHE=/app/gomodcache
ENV CMD_GO_USE_GIT_HASH=true
ENV GOARCH=amd64

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    git \
    build-essential \
    gcc-multilib \
    qemu-user \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sL https://go.dev/dl/go1.26.2.linux-amd64.tar.gz | tar -xz -C /usr/local

ENV PATH=/usr/local/go/bin:$PATH

WORKDIR /app

COPY repo/ /app/

RUN mkdir -p /app/gomodcache

RUN /usr/local/go/bin/go mod download

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
