#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone <repository-url> /app
cd /app

# Install dependencies
pnpm install --prod false --frozen-lockfile

# Build CLI
cd ./packages/cli
pnpm build
cd -

# Build eslint-parser
cd ./packages/eslint-parser
pnpm build
cd -

# Run tests
pnpm test