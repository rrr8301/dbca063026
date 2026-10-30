FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV GOMODCACHE=/app/gomodcache
ENV GOARCH=amd64

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    git \
    gcc \
    g++ \
    make \
    libc6-dev \
    pkg-config \
    qemu-user \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://go.dev/dl/go1.26.2.linux-amd64.tar.gz | tar -C /usr/local -xz

ENV PATH=/usr/local/go/bin:$PATH

WORKDIR /app
COPY repo/ /app/

RUN go mod download

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
