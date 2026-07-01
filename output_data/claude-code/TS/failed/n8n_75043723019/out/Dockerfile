FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_OPTIONS=--max-old-space-size=7168

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    python3 \
    python3-dev \
    pkg-config \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 25.x
RUN curl -fsSL https://deb.nodesource.com/setup_25.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm@latest

# Set working directory
WORKDIR /app

# Copy repository
COPY repo/ /app/

# Install project dependencies with frozen lockfile
RUN pnpm install --frozen-lockfile

# Build the project
RUN pnpm build --summarize

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Run tests
ENTRYPOINT ["/run.sh"]
