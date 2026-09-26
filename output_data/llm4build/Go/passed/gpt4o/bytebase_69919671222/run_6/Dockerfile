# Dockerfile
FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    make \
    gcc \
    g++ \
    cmake \
    ninja-build \
    clang \
    cargo \
    pkg-config \
    libssl-dev \
    libpq-dev \  # Add PostgreSQL client library
    && rm -rf /var/lib/apt/lists/*

# Install Go
RUN wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz && \
    rm go1.21.0.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Fix go.mod issues
RUN sed -i 's/^go 1.26.0$/go 1.21/' go.mod
RUN sed -i '/^godebug/d' go.mod

# Install Go dependencies
RUN go mod tidy && go mod download

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]