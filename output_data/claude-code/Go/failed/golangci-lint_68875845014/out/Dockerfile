FROM golang:1.25-bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV GOLANGCI_LINT_INSTALLED=true
ENV GOPROXY=https://proxy.golang.org

RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

RUN go mod download

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
