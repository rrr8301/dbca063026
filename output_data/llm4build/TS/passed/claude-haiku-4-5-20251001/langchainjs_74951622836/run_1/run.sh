#!/bin/bash
set -e

# Install dependencies with frozen lockfile
pnpm install --frozen-lockfile

# Build LangChain Core with tsx loader for TypeScript support
NODE_OPTIONS="--experimental-strip-types" pnpm build --filter @langchain/core

# Run unit tests
pnpm run test:unit:ci --filter @langchain/core