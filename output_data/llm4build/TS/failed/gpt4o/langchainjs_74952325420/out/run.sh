#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Install project dependencies
pnpm install --frozen-lockfile

# Approve necessary build scripts interactively
pnpm approve-builds

# Compile TypeScript files
if ! tsc --build; then
  echo "TypeScript compilation failed."
  exit 1
fi

# Build LangChain Core
pnpm build --filter @langchain/core

# Run tests
pnpm run test:unit:ci --filter @langchain/core