FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ROOK_UNIT_JQ_PATH=/usr/bin/jq

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    make \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.25
RUN curl -sL https://go.dev/dl/go1.25.0.linux-amd64.tar.gz | tar -xz -C /usr/local && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

# Install jq 1.7
RUN curl -sL https://github.com/jqlang/jq/releases/download/jq-1.7/jq-linux-amd64 -o /usr/bin/jq && \
    chmod +x /usr/bin/jq

WORKDIR /app
COPY repo/ /app/

RUN go mod download

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
