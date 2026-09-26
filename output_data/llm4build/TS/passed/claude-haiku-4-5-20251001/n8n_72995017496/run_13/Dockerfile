FROM node:24.14.1-alpine

WORKDIR /workspace

# Install required system dependencies
RUN apk add --no-cache git

# Install pnpm
RUN npm install -g pnpm

# Copy project files
COPY . .

# Set environment variable for Node.js memory
ENV NODE_OPTIONS="--max-old-space-size=7168"

# Set CI environment to skip optional prepare steps
ENV CI=true

# Install dependencies
RUN pnpm install --frozen-lockfile

# Run all tests (build is skipped as it requires turbo.json which may not be in Docker context)
CMD ["sh", "-c", "pnpm test:ci:backend:unit --summarize && pnpm test:ci:backend:integration --summarize && pnpm turbo test --filter=n8n-nodes-base --summarize && VITEST_SHARD=1/2 pnpm test:ci:frontend --summarize -- --shard=1/2 && VITEST_SHARD=2/2 pnpm test:ci:frontend --summarize -- --shard=2/2"]