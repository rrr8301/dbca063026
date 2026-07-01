FROM golang:1.26.3-alpine AS go-base

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Copy Go from the golang image
COPY --from=go-base /usr/local/go /usr/local/go

# Install system dependencies and services
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    postgresql \
    postgresql-contrib \
    mysql-server \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GO111MODULE=on
ENV GOPROXY=https://proxy.golang.org,direct

# Create app directory
WORKDIR /app

# Copy the repo
COPY repo/ /app/

# Install npm dependencies
RUN npm ci

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
