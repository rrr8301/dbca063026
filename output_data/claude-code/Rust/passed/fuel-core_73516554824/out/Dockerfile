FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    tcl \
    curl \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.93.0 --target wasm32-unknown-unknown
ENV PATH="/root/.cargo/bin:${PATH}"

# Install mold linker
RUN apt-get update && apt-get install -y mold && rm -rf /var/lib/apt/lists/*

# Install Redis
ENV REDIS_VERSION=8.6.0
RUN apt-get update && apt-get install -y build-essential tcl curl ca-certificates && \
    curl -fsSL "https://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz" -o /tmp/redis.tar.gz && \
    tar -xzf /tmp/redis.tar.gz -C /tmp && \
    cd "/tmp/redis-${REDIS_VERSION}" && \
    make -j"$(nproc)" && \
    make install && \
    redis-server --version && \
    rm -rf /tmp/redis-${REDIS_VERSION} /tmp/redis.tar.gz

# Set working directory and copy repo
WORKDIR /app
COPY repo/ /app/

# Copy and run the test script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
