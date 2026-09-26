FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install build tools and dependencies for Node.js
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    python3 \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 24.x
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Install dependencies
RUN pnpm install

# Copy the test script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
