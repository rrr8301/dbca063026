FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/go/bin:$PATH"
ENV GOPATH="/root/go"

# Install system dependencies including Go, PostgreSQL, MySQL
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    postgresql \
    postgresql-contrib \
    mysql-server \
    mysql-client \
    ca-certificates \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Configure sudo for passwordless execution (we're running as root in container)
RUN echo "root ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/nopasswd && \
    chmod 0440 /etc/sudoers.d/nopasswd

# Install Go 1.26.2
RUN wget https://go.dev/dl/go1.26.2.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.26.2.linux-amd64.tar.gz && \
    rm go1.26.2.linux-amd64.tar.gz && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

WORKDIR /app
COPY repo/ /app/

RUN mkdir -p /root/go/bin

# Run the test script
COPY run.sh /run.sh
RUN chmod +x /run.sh
ENTRYPOINT ["/run.sh"]
