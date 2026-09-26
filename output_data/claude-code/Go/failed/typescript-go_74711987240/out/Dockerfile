FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    wget \
    unzip \
    tar \
    gzip \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22.22.0
RUN curl -fsSL https://nodejs.org/dist/v22.22.0/node-v22.22.0-linux-x64.tar.xz -o node.tar.xz && \
    tar -xf node.tar.xz -C /usr/local --strip-components=1 && \
    rm node.tar.xz && \
    npm install -g npm@11.12.1

# Install Microsoft Go 1.26
RUN curl -fsSL https://github.com/microsoft/go/releases/download/v1.26.3-1/go1.26.3-1.linux-amd64.tar.gz -o go.tar.gz && \
    tar -xf go.tar.gz -C /usr/local && \
    rm go.tar.gz && \
    /usr/local/go/bin/go version

ENV PATH="/usr/local/go/bin:$PATH"
ENV GOPATH="/root/go"
ENV GOBIN="/root/go/bin"

# Add GOBIN to PATH
RUN echo "export PATH=$GOBIN:$PATH" >> /root/.bashrc

WORKDIR /app

COPY repo/ /app/

# Install npm dependencies
RUN npm ci

# Install gotestsum (only if not already installed)
RUN go install gotest.tools/gotestsum@latest

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
