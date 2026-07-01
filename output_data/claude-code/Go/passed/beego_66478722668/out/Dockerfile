FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV GO_VERSION=1.22.0
ENV GOPATH=/root/go
ENV PATH=${GOPATH}/bin:/usr/local/go/bin:${PATH}

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    ca-certificates \
    wget \
    postgresql \
    postgresql-contrib \
    mysql-server \
    mysql-client \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Install Go
RUN cd /tmp && \
    wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz

# Set up workspace
WORKDIR /app
COPY repo/ /app/

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
