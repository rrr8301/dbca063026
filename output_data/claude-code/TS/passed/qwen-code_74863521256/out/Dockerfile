FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_VERSION=22

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    python3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js from NodeSource repository
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Configure npm for rate limiting (matching the workflow)
RUN npm config set fetch-retry-mintimeout 20000 \
    && npm config set fetch-retry-maxtimeout 120000 \
    && npm config set fetch-retries 5 \
    && npm config set fetch-timeout 300000

# Install dependencies
RUN npm ci --prefer-offline --no-audit --progress=false

# Increase vitest hookTimeout to handle slower Docker environments
# Patch the vitest config to increase timeout from 10s to 30s
RUN find repo/packages -name "vitest.config.ts" -o -name "vitest.config.js" | while read f; do \
    if [ -f "$f" ]; then \
      sed -i "s/test: {/test: { hookTimeout: 30000,/" "$f" || true; \
    fi; \
  done

# Build the project
RUN npm run build

# Copy and run the test script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
