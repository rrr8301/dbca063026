#!/bin/bash
set -e

# Install dependencies with frozen lockfile
pnpm install --frozen-lockfile

# Build internal packages first (tsconfig, build tools, etc.)
pnpm build --filter internal/tsconfig
pnpm build --filter internal/build

# Build LangChain Core
pnpm build --filter @langchain/core

# Run unit tests
pnpm run test:unit:ci --filter @langchain/core