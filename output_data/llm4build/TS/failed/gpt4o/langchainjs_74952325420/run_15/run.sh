#!/bin/bash

# Install project dependencies
pnpm install --frozen-lockfile

# Approve necessary build scripts interactively
pnpm approve-builds

# Compile TypeScript files
tsc --build || {
  echo "TypeScript compilation failed."
  exit 1
}

# Build LangChain Core
pnpm build --filter @langchain/core

# Run tests
pnpm run test:unit:ci --filter @langchain/core