FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV GOPROXY=https://proxy.golang.org
ENV GOLANGCI_LINT_INSTALLED=true
ENV GL_TEST_RUN=1
ENV CGO_ENABLED=1

RUN apt-get update && apt-get install -y \
    build-essential \
    ca-certificates \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q https://go.dev/dl/go1.25.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.25.0.linux-amd64.tar.gz && \
    rm go1.25.0.linux-amd64.tar.gz

ENV PATH=$PATH:/usr/local/go/bin

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
