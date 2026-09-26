FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    gcc \
    g++ \
    make \
    pkg-config \
    libpcsclite-dev \
    protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://go.dev/dl/go1.25.10.linux-amd64.tar.gz | tar -xz -C /usr/local

ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh

RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
