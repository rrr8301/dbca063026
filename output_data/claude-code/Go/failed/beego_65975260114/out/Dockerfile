FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV GOPATH=/home/runner/go
ENV PATH=/usr/local/go/bin:$GOPATH/bin:$PATH

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    ca-certificates \
    postgresql \
    postgresql-contrib \
    postgresql-client \
    mysql-server \
    default-mysql-client \
    sqlite3 \
    libsqlite3-dev \
    redis-server \
    memcached \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.24.2
RUN wget https://golang.org/dl/go1.24.2.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

# Create necessary directories
RUN mkdir -p /var/run/mysqld /var/log/mysql && \
    chown -R mysql:mysql /var/run/mysqld /var/log/mysql && \
    mkdir -p /var/run/postgresql && \
    chown -R postgres:postgres /var/run/postgresql

WORKDIR /app
COPY repo/ /app/

# Download Go dependencies
RUN go mod download

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
