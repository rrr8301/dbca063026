FROM node:24.14.1-alpine

# Install git (required for prepare script and lefthook)
RUN apk add --no-cache git

# Install pnpm
RUN npm install -g pnpm

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Verify pnpm cache directory exists
RUN mkdir -p "$(pnpm store path --silent)"

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build project
RUN pnpm build --summarize

# Set environment variables for tests
ENV NODE_OPTIONS="--max-old-space-size=7168"
ENV COVERAGE_ENABLED="false"

# Run all tests
CMD ["sh", "-c", "pnpm test:ci:backend:unit --summarize && pnpm test:ci:backend:integration --summarize && pnpm turbo test --filter=n8n-nodes-base --summarize && pnpm test:ci:frontend --summarize -- --shard=1/2 && pnpm test:ci:frontend --summarize -- --shard=2/2 && node .github/scripts/send-build-stats.mjs || true"]