#!/bin/bash
set -e

# Install dependencies with frozen lockfile
pnpm install --frozen-lockfile

# Build LangChain Core using tsx to handle TypeScript imports
NODE_OPTIONS="--loader tsx" pnpm build --filter @langchain/core

# Run unit tests
pnpm run test:unit:ci --filter @langchain/core