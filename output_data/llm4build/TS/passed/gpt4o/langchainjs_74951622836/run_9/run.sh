#!/bin/bash

# Activate environment variables
export PUPPETEER_SKIP_DOWNLOAD="true"
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD="true"

# Install project dependencies
pnpm install --frozen-lockfile

# Approve build scripts for necessary packages
# Use a non-interactive way to approve builds
pnpm approve-builds

# Compile TypeScript files
if [ ! -f tsconfig.json ]; then
  echo "Error: tsconfig.json not found!"
  exit 1
fi
tsc --build tsconfig.json || exit 1

# Build LangChain Core
pnpm run build:compile --filter @langchain/core || exit 1

# Run tests
pnpm run test:unit:ci --filter @langchain/core || exit 1