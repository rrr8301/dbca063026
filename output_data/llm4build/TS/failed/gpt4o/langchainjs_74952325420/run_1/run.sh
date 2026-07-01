#!/bin/bash

# Install project dependencies
pnpm install --frozen-lockfile

# Compile TypeScript files
tsc --build

# Build LangChain Core
pnpm build --filter @langchain/core

# Run tests
pnpm run test:unit:ci --filter @langchain/core