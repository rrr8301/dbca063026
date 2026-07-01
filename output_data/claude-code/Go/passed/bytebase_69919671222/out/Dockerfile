FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    tar \
    gzip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.26.0
RUN curl -fsSL https://go.dev/dl/go1.26.0.linux-amd64.tar.gz -o /tmp/go1.26.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf /tmp/go1.26.0.linux-amd64.tar.gz && \
    rm /tmp/go1.26.0.linux-amd64.tar.gz

ENV PATH=$PATH:/usr/local/go/bin

# Install mongosh v2.5.0
RUN mkdir -p /tmp/mongosh && cd /tmp/mongosh && \
    curl -fsSL https://downloads.mongodb.com/compass/mongosh-2.5.0-linux-x64.tgz -o mongosh.tgz && \
    tar -xzf mongosh.tgz && \
    mkdir -p /usr/local/bin && \
    cp mongosh-2.5.0-linux-x64/bin/mongosh /usr/local/bin/mongosh && \
    chmod +x /usr/local/bin/mongosh && \
    rm -rf /tmp/mongosh

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
