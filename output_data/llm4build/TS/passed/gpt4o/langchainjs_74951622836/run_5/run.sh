#!/bin/bash

# Activate environment variables
export PUPPETEER_SKIP_DOWNLOAD="true"
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD="true"

# Install project dependencies
pnpm install --frozen-lockfile

# Automatically approve build scripts for necessary packages
echo "auto-approve" | pnpm approve-builds

# Compile TypeScript files
tsc --build tsconfig.json || exit 1

# Build LangChain Core
pnpm run build:compile --filter @langchain/core || exit 1

# Run tests
pnpm run test:unit:ci --filter @langchain/core || exit 1