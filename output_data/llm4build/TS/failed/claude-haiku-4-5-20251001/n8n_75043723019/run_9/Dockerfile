FROM node:24.14.1-alpine

# Install pnpm
RUN npm install -g pnpm

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Create entrypoint script
RUN mkdir -p /scripts && cat > /scripts/run.sh << 'SCRIPT_EOF'
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
SCRIPT_EOF
chmod +x /scripts/run.sh

# Set entrypoint
ENTRYPOINT ["/scripts/run.sh"]