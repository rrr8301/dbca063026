FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.25.9
RUN wget https://go.dev/dl/go1.25.9.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.25.9.linux-amd64.tar.gz && \
    rm go1.25.9.linux-amd64.tar.gz

ENV PATH=/usr/local/go/bin:$PATH

WORKDIR /app

COPY repo/ /app/

RUN go mod download

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
