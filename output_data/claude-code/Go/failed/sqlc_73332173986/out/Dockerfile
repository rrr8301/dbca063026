FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV GOPATH=/root/go
ENV PATH=/root/go/bin:/usr/local/go/bin:$PATH

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
    ca-certificates \
    sudo \
    gnupg \
    lsb-release \
    libossp-uuid16 \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    libxml2 \
    libxslt1.1 \
    libc6 \
    libicu74 \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.26.2
RUN curl -sL https://go.dev/dl/go1.26.2.linux-amd64.tar.gz | tar -xz -C /usr/local

# Configure sudo to allow passwordless commands
RUN echo 'root ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/root && \
    chmod 0440 /etc/sudoers.d/root

WORKDIR /app
COPY repo/ /app/

# Install project dependencies - these go to /root/go/bin
RUN go install gotest.tools/gotestsum@latest && \
    go install github.com/sqlc-dev/sqlc-gen-test@v0.1.0 && \
    go install ./scripts/test-json-process-plugin/ && \
    go install ./... && \
    CGO_ENABLED=0 go build ./... || true && \
    cd /app/internal/endtoend/testdata && CGO_ENABLED=0 go build ./... || true

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
