FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.25
RUN curl -sL https://go.dev/dl/go1.25.5.linux-amd64.tar.gz | tar -C /usr/local -xz

ENV PATH=$PATH:/usr/local/go/bin

WORKDIR /app

COPY repo/ /app/

# Pre-create DuckDB extensions directory for caching
RUN mkdir -p ~/.duckdb/extensions

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
