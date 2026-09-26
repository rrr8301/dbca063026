FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3 \
    python3-pip \
    make \
    jq \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L -o go.tar.gz https://go.dev/dl/go1.25.10.linux-amd64.tar.gz && \
    tar -xzf go.tar.gz -C /usr/local && \
    rm go.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/root/go"

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
