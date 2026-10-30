#!/bin/bash

# Install project dependencies
pnpm install --frozen-lockfile

# Automatically approve necessary build scripts
pnpm approve-builds --yes

# Compile TypeScript files with skipLibCheck to avoid type conflicts
tsc --build --skipLibCheck || {
  echo "TypeScript compilation failed."
  exit 1
}

# Build LangChain Core
pnpm build --filter @langchain/core

# Run tests
pnpm run test:unit:ci --filter @langchain/core