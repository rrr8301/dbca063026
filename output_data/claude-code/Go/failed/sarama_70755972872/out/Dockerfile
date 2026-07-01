FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    wget \
    make \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go stable
RUN wget -q https://go.dev/dl/go1.25.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.25.0.linux-amd64.tar.gz && \
    rm go1.25.0.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:$PATH"
ENV GOTOOLCHAIN=local
ENV DEBUG=true
ENV GOFLAGS=-trimpath
ENV TPARSE=/tmp/tparse

WORKDIR /app

COPY repo/ /app/

RUN go mod download && go mod verify

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
