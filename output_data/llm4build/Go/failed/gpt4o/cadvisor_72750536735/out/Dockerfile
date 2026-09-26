FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    make \
    curl \
    wget \
    gcc \
    g++ \
    cmake \
    ninja-build \
    libc6-dev \
    pkg-config \
    sudo \
    libipmctl5 \
    libipmctl-dev

# Install Go (use a valid version, e.g., 1.20)
RUN wget https://golang.org/dl/go1.20.7.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.20.7.linux-amd64.tar.gz && \
    rm go1.20.7.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Ensure all scripts have executable permissions
RUN chmod +x /app/run.sh
RUN chmod +x /app/build/integration-in-docker.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]