FROM node:24.14.1-alpine

WORKDIR /workspace

# Install pnpm
RUN npm install -g pnpm

# Copy project files
COPY . .

# Set environment variable for Node.js memory
ENV NODE_OPTIONS="--max-old-space-size=7168"

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build project
RUN pnpm build --summarize

# Run all tests
CMD ["sh", "-c", "pnpm test:ci:backend:unit --summarize && pnpm test:ci:backend:integration --summarize && pnpm turbo test --filter=n8n-nodes-base --summarize && VITEST_SHARD=1/2 pnpm test:ci:frontend --summarize -- --shard=1/2 && VITEST_SHARD=2/2 pnpm test:ci:frontend --summarize -- --shard=2/2"]