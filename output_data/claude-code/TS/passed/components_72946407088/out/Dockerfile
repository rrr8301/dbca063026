FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    python3 \
    python3-distutils \
    openjdk-11-jdk \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22.22.2
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs=22.22.2-1nodesource1 && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm 10.33.0
RUN npm install -g pnpm@10.33.0

# Install Bazel 8.6.0
RUN curl -fsSLO https://github.com/bazelbuild/bazel/releases/download/8.6.0/bazel-8.6.0-linux-x86_64 && \
    chmod +x bazel-8.6.0-linux-x86_64 && \
    mv bazel-8.6.0-linux-x86_64 /usr/local/bin/bazel && \
    bazel --version

WORKDIR /app

# Copy repository
COPY repo/ /app/

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
