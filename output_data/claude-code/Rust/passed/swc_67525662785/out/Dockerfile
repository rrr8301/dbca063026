FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

ENV PATH="/root/.cargo/bin:$PATH"

# Add wasm32-wasip1 target
RUN rustup target add wasm32-wasip1

# Install Node.js 20 and yarn
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

# Enable corepack
RUN corepack enable

# Install node dependencies
RUN yarn install

# Install jest and mocha globally (with retry logic)
RUN yarn global add jest@27 mocha || \
    yarn global add jest@27 mocha || \
    yarn global add jest@27 mocha || \
    yarn global add jest@27 mocha || \
    yarn global add jest@27 mocha || \
    yarn global add jest@27 mocha || \
    yarn global add jest@27 mocha || \
    yarn global add jest@27 mocha || true

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
