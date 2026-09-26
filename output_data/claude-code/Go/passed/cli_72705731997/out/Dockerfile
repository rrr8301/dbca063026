FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q https://go.dev/dl/go1.26.2.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.26.2.linux-amd64.tar.gz && \
    rm go1.26.2.linux-amd64.tar.gz

ENV PATH=/usr/local/go/bin:$PATH
ENV CGO_ENABLED=1

WORKDIR /app

COPY repo/ /app/

RUN go mod download

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
