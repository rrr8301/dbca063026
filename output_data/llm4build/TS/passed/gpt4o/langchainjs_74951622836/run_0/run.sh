#!/bin/bash

# Activate environment variables
export PUPPETEER_SKIP_DOWNLOAD="true"
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD="true"

# Install project dependencies
pnpm install --frozen-lockfile

# Build LangChain Core
pnpm build --filter @langchain/core

# Run tests
pnpm run test:unit:ci --filter @langchain/core