#!/bin/bash
set -e

# Install dependencies with frozen lockfile
pnpm install --frozen-lockfile

# Build LangChain Core using tsx loader for TypeScript support
NODE_OPTIONS="--loader tsx/esm" pnpm build --filter @langchain/core

# Run unit tests
pnpm run test:unit:ci --filter @langchain/core