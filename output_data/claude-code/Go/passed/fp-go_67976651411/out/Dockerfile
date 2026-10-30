FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CGO_ENABLED=1

# Install system dependencies including build tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    build-essential \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.24.x
RUN curl -fsSL https://golang.org/dl/go1.24.0.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

ENV PATH="/usr/local/go/bin:$PATH"

# Set working directory
WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Copy and run the test script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
