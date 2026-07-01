FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    cmake \
    python3 \
    python3-dev \
    python3-setuptools \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.24 (latest 1.24.x)
RUN curl -fsSL https://golang.org/dl/go1.24.0.linux-amd64.tar.gz | tar -xz -C /usr/local \
    && ln -s /usr/local/go/bin/go /usr/bin/go \
    && ln -s /usr/local/go/bin/gofmt /usr/bin/gofmt

# Verify Go installation
RUN go version

# Install Python tools
RUN pip install -U wheel pytest setuptools

# Set up workspace
WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Install project dependencies (git submodules)
RUN git submodule init && git submodule update

# Copy the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
