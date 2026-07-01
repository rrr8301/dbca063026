#!/bin/bash

# Install project dependencies
pnpm install --frozen-lockfile

# Automatically approve necessary build scripts
# Use --yes to automatically approve all builds
pnpm approve-builds --yes

# Compile TypeScript files without --skipLibCheck
tsc --build || {
  echo "TypeScript compilation failed."
  exit 1
}

# Build LangChain Core
pnpm build --filter @langchain/core

# Run tests
pnpm run test:unit:ci --filter @langchain/core