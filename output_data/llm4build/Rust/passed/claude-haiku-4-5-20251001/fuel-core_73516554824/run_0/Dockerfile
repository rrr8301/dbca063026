FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    tcl \
    curl \
    ca-certificates \
    git \
    cmake \
    pkg-config \
    mold \
    && rm -rf /var/lib/apt/lists/*

# Install Rust toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.93.0
ENV PATH="/root/.cargo/bin:${PATH}"

# Build and install Redis 8.6.0
RUN curl -fsSL "https://download.redis.io/releases/redis-8.6.0.tar.gz" -o /tmp/redis.tar.gz && \
    tar -xzf /tmp/redis.tar.gz -C /tmp && \
    cd /tmp/redis-8.6.0 && \
    make -j"$(nproc)" && \
    make install && \
    rm -rf /tmp/redis* && \
    redis-server --version

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]