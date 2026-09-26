FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/go/bin:${PATH}"

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    postgresql-client \
    mysql-client \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.26
RUN curl -L https://go.dev/dl/go1.26.3.linux-amd64.tar.gz | tar -xz -C /usr/local

# Install CockroachDB
RUN curl -L https://binaries.cockroachdb.com/cockroach-latest.linux-amd64.tgz | tar xz -C /tmp && \
    cp /tmp/cockroach-*/cockroach /usr/local/bin/ && \
    rm -rf /tmp/cockroach-*

WORKDIR /app
COPY repo/ /app/

# Copy and run the test script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
