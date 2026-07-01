FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV RUSTFLAGS=-D\ warnings
ENV CARGO_TERM_COLOR=always

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    ca-certificates \
    tcl \
    git \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.93.0 && \
    . $HOME/.cargo/env && \
    rustc --version && \
    cargo --version

ENV PATH="/root/.cargo/bin:${PATH}"

# Install mold linker
RUN curl -fsSL https://github.com/rui314/mold/releases/download/v2.32.0/mold-2.32.0-x86_64-linux.tar.gz -o /tmp/mold.tar.gz && \
    tar -xzf /tmp/mold.tar.gz -C /usr/local --strip-components=1 && \
    rm /tmp/mold.tar.gz && \
    mold --version

# Install Redis from source
ENV REDIS_VERSION=8.6.0
RUN curl -fsSL "https://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz" -o /tmp/redis.tar.gz && \
    tar -xzf /tmp/redis.tar.gz -C /tmp && \
    cd "/tmp/redis-${REDIS_VERSION}" && \
    make -j"$(nproc)" && \
    make install && \
    redis-server --version && \
    rm -rf /tmp/redis-${REDIS_VERSION} /tmp/redis.tar.gz

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]