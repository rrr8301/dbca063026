FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    python3 \
    python3-dev \
    openjdk-11-jdk \
    ca-certificates \
    gnupg \
    lsb-release \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22.22.2 using NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm

# Install Bazel/Bazelisk
RUN npm install -g @bazel/bazelisk

WORKDIR /app

COPY repo/ /app/

# Install project dependencies
RUN pnpm install --frozen-lockfile

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
