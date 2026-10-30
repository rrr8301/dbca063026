FROM node:22.22.0-alpine

ENV DEBIAN_FRONTEND=noninteractive

RUN apk add --no-cache \
    curl \
    wget \
    git \
    build-base \
    python3 \
    ca-certificates

# Install Go 1.25 (has covdata tool needed for coverage)
RUN wget -q https://go.dev/dl/go1.25.10.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
    tar -xzf /tmp/go.tar.gz -C /usr/local && \
    rm /tmp/go.tar.gz

ENV PATH=/usr/local/go/bin:$PATH \
    GOPATH=/root/go \
    GOBIN=/root/go/bin

RUN mkdir -p /root/go/bin

WORKDIR /app

COPY repo/ /app/

# Install project dependencies
RUN npm ci

# Install gotestsum
RUN go install gotest.tools/gotestsum@latest

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
