FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    clang \
    pkg-config \
    ca-certificates \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.26.1
RUN curl -fsSL https://go.dev/dl/go1.26.1.linux-amd64.tar.gz -o /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

# Install Node.js and pnpm
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g pnpm && \
    rm -rf /var/lib/apt/lists/*

# Set PATH for Go
ENV PATH=/usr/local/go/bin:$PATH

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Download Go dependencies
RUN go mod download

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
