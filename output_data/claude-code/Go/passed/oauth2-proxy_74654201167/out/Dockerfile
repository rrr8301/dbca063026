FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    ca-certificates \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://go.dev/dl/go1.25.0.linux-amd64.tar.gz | tar -C /usr/local -xz

ENV PATH="/usr/local/go/bin:${PATH}"
ENV HOME=/root

WORKDIR /app
COPY repo/ /app/

RUN go mod download

RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/v2.11.4/install.sh | sh -s -- -b /usr/local/bin v2.11.4

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
