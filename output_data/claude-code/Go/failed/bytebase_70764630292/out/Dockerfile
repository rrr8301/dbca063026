FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    tar \
    git \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.26.0
RUN cd /tmp && \
    wget -q https://go.dev/dl/go1.26.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.26.0.linux-amd64.tar.gz && \
    rm go1.26.0.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:$PATH"

# Install mongosh 2.5.0
RUN mkdir -p /tmp/mongosh-install && cd /tmp/mongosh-install && \
    ARCH="x64" && \
    MONGOSH_VERSION="2.5.0" && \
    ARCHIVE="mongosh-${MONGOSH_VERSION}-linux-${ARCH}.tgz" && \
    curl -fsSL "https://downloads.mongodb.com/compass/${ARCHIVE}" -o "${ARCHIVE}" && \
    tar -xzf "${ARCHIVE}" && \
    mkdir -p /root/.local/bin && \
    cp "mongosh-${MONGOSH_VERSION}-linux-${ARCH}/bin/mongosh" /root/.local/bin/mongosh && \
    chmod +x /root/.local/bin/mongosh && \
    rm -rf /tmp/mongosh-install && \
    /root/.local/bin/mongosh --version

ENV PATH="/root/.local/bin:$PATH"

WORKDIR /app

COPY repo/ /app/

# Install project dependencies
RUN go mod download

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
