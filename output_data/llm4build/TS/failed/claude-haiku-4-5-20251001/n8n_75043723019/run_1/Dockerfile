FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 25.x
RUN curl -fsSL https://deb.nodesource.com/setup_25.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm@latest

# Set working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Create run script inline
RUN cat > /run.sh << 'EOF'
#!/bin/bash

set -e

# Set environment variables
export NODE_OPTIONS="--max-old-space-size=7168"
export COVERAGE_ENABLED="false"

# Verify pnpm cache directory exists
PNPM_STORE_PATH="$(pnpm store path --silent)"
if [ ! -d "$PNPM_STORE_PATH" ]; then
    mkdir -p "$PNPM_STORE_PATH"
fi

# Install dependencies
echo "Installing dependencies..."
pnpm install --frozen-lockfile

# Build project
echo "Building project..."
pnpm build --summarize

# Run backend unit tests
echo "Running backend unit tests..."
pnpm test:ci:backend:unit --summarize

# Run backend integration tests
echo "Running backend integration tests..."
pnpm test:ci:backend:integration --summarize

# Run nodes unit tests
echo "Running nodes unit tests..."
pnpm turbo test --filter=n8n-nodes-base --summarize

# Run frontend unit tests (shard 1/2)
echo "Running frontend unit tests (shard 1/2)..."
export VITEST_SHARD="1/2"
pnpm test:ci:frontend --summarize -- --shard=1/2

# Run frontend unit tests (shard 2/2)
echo "Running frontend unit tests (shard 2/2)..."
export VITEST_SHARD="2/2"
pnpm test:ci:frontend --summarize -- --shard=2/2

# Send test stats (optional, failures are ignored)
echo "Sending test stats..."
node .github/scripts/send-build-stats.mjs || true

echo "All tests completed successfully!"
EOF
RUN chmod +x /run.sh

# Set entrypoint
ENTRYPOINT ["/run.sh"]