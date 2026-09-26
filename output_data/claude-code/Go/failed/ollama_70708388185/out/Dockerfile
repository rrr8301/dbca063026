FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CGO_ENABLED=1
ENV PATH="/usr/local/go/bin:${PATH}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    git \
    build-essential \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://golang.org/dl/go1.26.0.linux-$(dpkg --print-architecture).tar.gz | tar xz -C /usr/local

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

RUN go mod download

RUN npm ci --prefix ./app/ui/app

RUN go install github.com/tkrajina/typescriptify-golang-structs/tscriptify@latest

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
