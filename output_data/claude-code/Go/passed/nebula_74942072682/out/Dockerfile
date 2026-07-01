FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.25
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/* && \
    wget https://go.dev/dl/go1.25.10.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.25.10.linux-amd64.tar.gz && \
    rm go1.25.10.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/root/go"
ENV PATH="${GOPATH}/bin:${PATH}"

WORKDIR /app
COPY repo/ /app/

RUN go mod download

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
