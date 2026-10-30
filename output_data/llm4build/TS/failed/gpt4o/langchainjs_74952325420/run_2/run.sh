#!/bin/bash

# Install project dependencies
pnpm install --frozen-lockfile

# Compile TypeScript files
tsc --build

# Ensure TypeScript files are compiled correctly
if [ $? -ne 0 ]; then
  echo "TypeScript compilation failed."
  exit 1
fi

# Build LangChain Core
pnpm build --filter @langchain/core

# Run tests
pnpm run test:unit:ci --filter @langchain/core