FROM node:24.14.1-alpine

WORKDIR /workspace

# Install required system dependencies
RUN apk add --no-cache git

# Install pnpm
RUN npm install -g pnpm

# Copy all project files including turbo configuration
COPY . .

# Verify turbo.json exists
RUN test -f turbo.json || test -f turbo.jsonc || (echo "Error: turbo.json or turbo.jsonc not found" && exit 1)

# Set environment variable for Node.js memory
ENV NODE_OPTIONS="--max-old-space-size=7168"

# Set CI environment to skip optional prepare steps
ENV CI=true

# Install dependencies
RUN pnpm install --frozen-lockfile

# Run all tests
CMD ["sh", "-c", "pnpm test:ci:backend:unit --summarize && pnpm test:ci:backend:integration --summarize && pnpm turbo test --filter=n8n-nodes-base --summarize && VITEST_SHARD=1/2 pnpm test:ci:frontend --summarize -- --shard=1/2 && VITEST_SHARD=2/2 pnpm test:ci:frontend --summarize -- --shard=2/2"]