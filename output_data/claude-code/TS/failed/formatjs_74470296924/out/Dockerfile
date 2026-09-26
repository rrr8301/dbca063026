FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_OPTIONS=--max-old-space-size=4096

RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    build-essential \
    python3 \
    python3-pip \
    openjdk-17-jdk-headless \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 24.14.0
RUN curl -fsSL https://nodejs.org/dist/v24.14.0/node-v24.14.0-linux-x64.tar.xz | tar -xJ -C /usr/local --strip-components=1

# Install pnpm 10.4.1
RUN npm install -g pnpm@10.4.1

# Install Bazel 9.1.0
RUN wget https://github.com/bazelbuild/bazel/releases/download/9.1.0/bazel-9.1.0-linux-x86_64 -O /usr/local/bin/bazel && \
    chmod +x /usr/local/bin/bazel

# Install Rust 1.95.0
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.95.0 && \
    . $HOME/.cargo/env

WORKDIR /app
COPY repo/ /app/

# Install dependencies using pnpm with lockfile
RUN pnpm install --frozen-lockfile 2>&1 || pnpm install

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
