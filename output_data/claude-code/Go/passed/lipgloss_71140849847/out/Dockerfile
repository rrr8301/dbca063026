FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV GO111MODULE=on
ENV PATH=$PATH:/usr/local/go/bin:/root/go/bin

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.25.0
RUN curl -sL https://go.dev/dl/go1.25.0.linux-amd64.tar.gz -o go1.25.0.tar.gz && \
    tar -C /usr/local -xzf go1.25.0.tar.gz && \
    rm go1.25.0.tar.gz

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh

RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
